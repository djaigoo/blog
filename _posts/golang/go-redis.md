---
author: djaigo
title: go-redis
date: 2022-04-12 13:56:00
categories:
  - golang
tags:
  - redis
---
# go-redis
golang实现的redis客户端

## call chain
调用分层
* 获取客户端
* 函数生成命令对象
* 命令对象转换为RESP协议
* 网络层发送协议
* 网络层接收协议
* 转换为命令响应
* 返回给调用者

pipeline调用内部逻辑
```go
client.Pipelined() {
	client.processPipeline() {
		hooks.processPipeline(
			baseClient._generalProcessPipeline() {
				baseClient.withConn(
					baseClient.pipelineProcessCmds() {
						Conn.WithWriter(
							Writer.WriteArgs()
						)
						Conn.WithReader(
							Cmder.readReply()
						)
					}
				)
			}
		）
	}
}
```

## core object
* 执行单元：`client`，`baseClient`，`pipeline`，`txPipeline`
* 协议：`Reader`，`Writer`
* 连接池：`connPool`，`singlePool`，`stickyPool`

# client
向用户提供对redis的操作

## option
配置redis地址，超时，连接池等信息
```go
// Options keeps the settings to setup redis connection.
type Options struct {
	// 网络模式
	Network string
	// 地址
	Addr string

	// 拨号器
	Dialer func(ctx context.Context, network, addr string) (net.Conn, error)

	// 连接hook
	OnConnect func(ctx context.Context, cn *Conn) error

	// 用户名 用于 redis ACL
	Username string
	// 密码
	Password string

	// 数据库
	DB int

	// 最大重试次数
	MaxRetries int
	// 重试最小间隔
	MinRetryBackoff time.Duration
	// 最大重试间隔
	MaxRetryBackoff time.Duration

	// 拨号超时
	DialTimeout time.Duration
	// 读超时
	ReadTimeout time.Duration
	// 写超时
	WriteTimeout time.Duration

	// 连接池类型
	// true for FIFO pool, false for LIFO pool.
	PoolFIFO bool
	// 最大连接数 默认 十倍runtime.GOMAXPROCS.
	PoolSize int
	// 最小空闲连接数
	MinIdleConns int
	// 连接最大存活时间
	MaxConnAge time.Duration
	// 获取连接超时时间
	PoolTimeout time.Duration
	// 空闲连接超时时间
	IdleTimeout time.Duration
	// 空闲连接检测频次
	IdleCheckFrequency time.Duration

	// 只读节点
	readOnly bool

	// TLS 配置
	TLSConfig *tls.Config

	// 限流器
	Limiter Limiter
}

// 默认值
func (opt *Options) init() {
	if opt.Addr == "" {
		opt.Addr = "localhost:6379"
	}
	if opt.Network == "" {
		if strings.HasPrefix(opt.Addr, "/") {
			opt.Network = "unix"
		} else {
			opt.Network = "tcp"
		}
	}
	if opt.DialTimeout == 0 {
		opt.DialTimeout = 5 * time.Second
	}
	if opt.Dialer == nil {
		opt.Dialer = func(ctx context.Context, network, addr string) (net.Conn, error) {
			netDialer := &net.Dialer{
				Timeout:   opt.DialTimeout,
				KeepAlive: 5 * time.Minute,
			}
			if opt.TLSConfig == nil {
				return netDialer.DialContext(ctx, network, addr)
			}
			return tls.DialWithDialer(netDialer, network, addr, opt.TLSConfig)
		}
	}
	if opt.PoolSize == 0 {
		opt.PoolSize = 10 * runtime.GOMAXPROCS(0)
	}
	switch opt.ReadTimeout {
	case -1:
		opt.ReadTimeout = 0
	case 0:
		opt.ReadTimeout = 3 * time.Second
	}
	switch opt.WriteTimeout {
	case -1:
		opt.WriteTimeout = 0
	case 0:
		opt.WriteTimeout = opt.ReadTimeout
	}
	if opt.PoolTimeout == 0 {
		opt.PoolTimeout = opt.ReadTimeout + time.Second
	}
	if opt.IdleTimeout == 0 {
		opt.IdleTimeout = 5 * time.Minute
	}
	if opt.IdleCheckFrequency == 0 {
		opt.IdleCheckFrequency = time.Minute
	}

	if opt.MaxRetries == -1 {
		opt.MaxRetries = 0
	} else if opt.MaxRetries == 0 {
		opt.MaxRetries = 3
	}
	switch opt.MinRetryBackoff {
	case -1:
		opt.MinRetryBackoff = 0
	case 0:
		opt.MinRetryBackoff = 8 * time.Millisecond
	}
	switch opt.MaxRetryBackoff {
	case -1:
		opt.MaxRetryBackoff = 0
	case 0:
		opt.MaxRetryBackoff = 512 * time.Millisecond
	}
}
```

## hook
在执行时的钩子，通过钩子可以在执行redis操作时，额外执行用户自定义的操作，如链路追踪，消息打点
```go
type Hook interface {
	BeforeProcess(ctx context.Context, cmd Cmder) (context.Context, error)
	AfterProcess(ctx context.Context, cmd Cmder) error

	BeforeProcessPipeline(ctx context.Context, cmds []Cmder) (context.Context, error)
	AfterProcessPipeline(ctx context.Context, cmds []Cmder) error
}
```

执行命令，单命令，批量命令，事务命令
* `func (hs hooks) process(ctx context.Context, cmd Cmder, fn func(context.Context, Cmder) error) error`，带hook的处理单命令
* `func (hs hooks) processPipeline(ctx context.Context, cmds []Cmder, fn func(context.Context, []Cmder) error) error`，带hook的处理多命令
* `func (hs hooks) processTxPipeline(ctx context.Context, cmds []Cmder, fn func(context.Context, []Cmder) error) error`，带hook的事务处理多命令


## baseClient
主要负责连接池管理和redis命令处理
```go
type baseClient struct {
	opt      *Options
	connPool pool.Pooler

	onClose func() error // hook called when client is closed
}
```

管理连接
* `func (c *baseClient) newConn(ctx context.Context) (*pool.Conn, error)`，新建连接
* `func (c *baseClient) getConn(ctx context.Context) (*pool.Conn, error)`，从池中获取连接
* `func (c *baseClient) initConn(ctx context.Context, cn *pool.Conn) error`，初始化连接
* `func (c *baseClient) releaseConn(ctx context.Context, cn *pool.Conn, err error)`，释放连接
* `func (c *baseClient) withConn(ctx context.Context, fn func(context.Context, *pool.Conn) error) error`，绑定连接执行fn

执行命令
* `func (c *baseClient) process(ctx context.Context, cmd Cmder) error`，处理单命令
* `func (c *baseClient) processPipeline(ctx context.Context, cmds []Cmder) error`，处理多个命令
* `func (c *baseClient) processTxPipeline(ctx context.Context, cmds []Cmder) error`，事务处理多个命令
* `func (c *baseClient) pipelineProcessCmds(ctx context.Context, cn *pool.Conn, cmds []Cmder) (bool, error)`，执行多个命令
* `func (c *baseClient) txPipelineProcessCmds(ctx context.Context, cn *pool.Conn, cmds []Cmder) (bool, error)`，事务执行多个命令

## Client
封装与用户的交互
```go
type Client struct {
	*baseClient
	cmdable
	hooks
	ctx context.Context
}
```

执行命令
* `func (c *Client) Do(ctx context.Context, args ...interface{}) *Cmd`，执行命令，手动拼接命令
* `func (c *Client) Process(ctx context.Context, cmd Cmder) error`，执行命令
* `func (c *Client) processPipeline(ctx context.Context, cmds []Cmder) error`，执行多个命令
* `func (c *Client) processTxPipeline(ctx context.Context, cmds []Cmder) error`，事务执行多个命令
* `func (c *Client) Pipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，管道执行fn
* `func (c *Client) Pipeline() Pipeliner`，返回管道
* `func (c *Client) TxPipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，事务管道执行fn
* `func (c *Client) TxPipeline() Pipeliner`，返回事务管道

## Conn
单连接客户端，比Client多了些有状态的命令，用的比较少
```go
type conn struct {
	baseClient
	cmdable
	statefulCmdable
	hooks // TODO: inherit hooks
}

type Conn struct {
	*conn
	ctx context.Context
}
```

执行命令
* `func (c *Conn) Process(ctx context.Context, cmd Cmder) error`，执行命令
* `func (c *Conn) processPipeline(ctx context.Context, cmds []Cmder) error`，执行多个命令
* `func (c *Conn) processTxPipeline(ctx context.Context, cmds []Cmder) error`，事务执行命令
* `func (c *Conn) Pipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，利用管道执行fn
* `func (c *Conn) Pipeline() Pipeliner`，返回管道
* `func (c *Conn) TxPipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，利用事务管道执行fn
* `func (c *Conn) TxPipeline() Pipeliner`，返回事务管道

## Tx
事务执行命令，会监视所有操作的key
```go
type Tx struct {
	baseClient
	cmdable
	statefulCmdable
	hooks
	ctx context.Context
}
```

执行命令
* `func (c *Tx) Process(ctx context.Context, cmd Cmder) error`，执行命令
* `func (c *Tx) Close(ctx context.Context) error`，关闭连接
* `func (c *Tx) Watch(ctx context.Context, keys ...string) *StatusCmd`，监视keys
* `func (c *Tx) Unwatch(ctx context.Context, keys ...string) *StatusCmd`，取消监视keys
* `func (c *Tx) Pipeline() Pipeliner`，返回管道
* `func (c *Tx) Pipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，利用管道执行fn
* `func (c *Tx) TxPipelined(ctx context.Context, fn func(Pipeliner) error) ([]Cmder, error)`，利用事务管道执行fn
* `func (c *Tx) TxPipeline() Pipeliner`，返回事务管道


# command
处理redis命令的文件
* commands.go，用于描述redis命令，处理请求
* command.go，用于描述代码层级的结构，处理响应

## commands

commands.go为每个redis命令实现了一个或多个操作函数，针对每个命令返回值的不同，返回指定的响应结构体（即command.go中定义的结构），有些指令还会预处理参数方便用户使用。
时间格式化：
```go
func formatMs(ctx context.Context, dur time.Duration) int64 {
	if dur > 0 && dur < time.Millisecond {
		internal.Logger.Printf(
			ctx,
			"specified duration is %s, but minimal supported value is %s - truncating to 1ms",
			dur, time.Millisecond,
		)
		return 1
	}
	return int64(dur / time.Millisecond)
}

func formatSec(ctx context.Context, dur time.Duration) int64 {
	if dur > 0 && dur < time.Second {
		internal.Logger.Printf(
			ctx,
			"specified duration is %s, but minimal supported value is %s - truncating to 1s",
			dur, time.Second,
		)
		return 1
	}
	return int64(dur / time.Second)
}
```

参数格式化：
```go
func appendArgs(dst, src []interface{}) []interface{} {
	if len(src) == 1 {
		return appendArg(dst, src[0])
	}

	dst = append(dst, src...)
	return dst
}

func appendArg(dst []interface{}, arg interface{}) []interface{} {
	switch arg := arg.(type) {
	case []string:
		for _, s := range arg {
			dst = append(dst, s)
		}
		return dst
	case []interface{}:
		dst = append(dst, arg...)
		return dst
	case map[string]interface{}:
		for k, v := range arg {
			dst = append(dst, k, v)
		}
		return dst
	case map[string]string:
		for k, v := range arg {
			dst = append(dst, k, v)
		}
		return dst
	default:
		return append(dst, arg)
	}
}
```

## command

command.go定义了Cmder接口用于golang和redis之间的交互，主要作用是将golang对象转为RESP协议发送给redis。

用户读取信息的操作接口
```go
type Cmder interface {
	Name() string         // redis 命令
	FullName() string     // 多个单词的redis命令
	Args() []interface{}  // 命令参数列表
	String() string       // 格式化
	stringArg(int) string // 格式化参数
	firstKeyPos() int8
	setFirstKeyPos(int8)

	readTimeout() *time.Duration      // 读超时
	readReply(rd *proto.Reader) error // 读取值

	SetErr(error)
	Err() error
}
```

最基本操作单元
```go
type baseCmd struct {
	ctx    context.Context
	args   []interface{} // 命令参数 cmd args...
	err    error
	keyPos int8

	_readTimeout *time.Duration
}
```

参数
* `func (cmd *baseCmd) Name() string`，返回第一个参数，一般第一个参数都是操作命令
* `func (cmd *baseCmd) FullName() string`，返回操作命令，redis有多个单词组成的命令
* `func (cmd *baseCmd) Args() []interface{}`，返回参数列表
* `func (cmd *baseCmd) stringArg(pos int) string`，以字符串形式返回指定位置的参数，利用断言机制
错误
* `func (cmd *baseCmd) SetErr(e error)`，设置错误
* `func (cmd *baseCmd) Err() error`，返回错误
读超时
* `func (cmd *baseCmd) readTimeout() *time.Duration`，返回读超时
* `func (cmd *baseCmd) setReadTimeout(d time.Duration)`，设置读超时


```go
type Cmd struct {
	baseCmd

	val interface{}
}
```

序列化
* `func (cmd *Cmd) String() string`，格式化Cmd，即格式化参数和返回值

返回值
* `func (cmd *Cmd) SetVal(val interface{})`，设置返回值
* `func (cmd *Cmd) Val() interface{}`，获取返回值
* `func (cmd *Cmd) Result() (interface{}, error)`，获取返回值和错误

还实现了将返回值转换为指定类型的函数，包括：`Text`，`Int`，`Int64`，`Uint64`，`Float32`，`Float64`，`Bool`，`Slice`，`StringSlice`，`Int64Slice`，`Uint64Slice`，`Float32Slice`，`Float64Slice`，`BoolSlice`

读取返回值
```go
func (cmd *Cmd) readReply(rd *proto.Reader) (err error) {
	cmd.val, err = rd.ReadReply(sliceParser)
	return err
}

// sliceParser implements proto.MultiBulkParse.
func sliceParser(rd *proto.Reader, n int64) (interface{}, error) {
	vals := make([]interface{}, n)
	for i := 0; i < len(vals); i++ {
		v, err := rd.ReadReply(sliceParser)
		if err != nil {
			if err == Nil {
				vals[i] = nil
				continue
			}
			if err, ok := err.(proto.RedisError); ok {
				vals[i] = err
				continue
			}
			return nil, err
		}
		vals[i] = v
	}
	return vals, nil
}
```

## SliceCmd
```go
type SliceCmd struct {
	baseCmd

	val []interface{}
}

// Scan scans the results from the map into a destination struct. The map keys
// are matched in the Redis struct fields by the `redis:"field"` tag.
func (cmd *SliceCmd) Scan(dst interface{}) error {
	if cmd.err != nil {
		return cmd.err
	}

	// Pass the list of keys and values.
	// Skip the first two args for: HMGET key
	var args []interface{}
	if cmd.args[0] == "hmget" {
		args = cmd.args[2:]
	} else {
		// Otherwise, it's: MGET field field ...
		args = cmd.args[1:]
	}

	return hscan.Scan(dst, args, cmd.val)
}

func (cmd *SliceCmd) readReply(rd *proto.Reader) error {
	v, err := rd.ReadArrayReply(sliceParser)
	if err != nil {
		return err
	}
	cmd.val = v.([]interface{})
	return nil
}
```

## StatusCmd
```go
type StatusCmd struct {
	baseCmd

	val string
}

func (cmd *StatusCmd) readReply(rd *proto.Reader) (err error) {
	cmd.val, err = rd.ReadString()
	return err
}
```

## IntCmd
```go
type IntCmd struct {
	baseCmd

	val int64
}

func (cmd *IntCmd) readReply(rd *proto.Reader) (err error) {
	cmd.val, err = rd.ReadIntReply()
	return err
}
```

## IntSliceCmd
```go
type IntSliceCmd struct {
	baseCmd

	val []int64
}

func (cmd *IntSliceCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make([]int64, n)
		for i := 0; i < len(cmd.val); i++ {
			num, err := rd.ReadIntReply()
			if err != nil {
				return nil, err
			}
			cmd.val[i] = num
		}
		return nil, nil
	})
	return err
}
```

## DurationCmd
```go
type DurationCmd struct {
	baseCmd

	val       time.Duration
	precision time.Duration
}

func (cmd *DurationCmd) readReply(rd *proto.Reader) error {
	n, err := rd.ReadIntReply()
	if err != nil {
		return err
	}
	switch n {
	// -2 if the key does not exist
	// -1 if the key exists but has no associated expire
	case -2, -1:
		cmd.val = time.Duration(n)
	default:
		cmd.val = time.Duration(n) * cmd.precision
	}
	return nil
}
```

## TimeCmd
```go
type TimeCmd struct {
	baseCmd

	val time.Time
}

func (cmd *TimeCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		if n != 2 {
			return nil, fmt.Errorf("got %d elements, expected 2", n)
		}

		sec, err := rd.ReadInt()
		if err != nil {
			return nil, err
		}

		microsec, err := rd.ReadInt()
		if err != nil {
			return nil, err
		}

		cmd.val = time.Unix(sec, microsec*1000)
		return nil, nil
	})
	return err
}
```

## BoolCmd
```go
type BoolCmd struct {
	baseCmd

	val bool
}

func (cmd *BoolCmd) readReply(rd *proto.Reader) error {
	v, err := rd.ReadReply(nil)
	// `SET key value NX` returns nil when key already exists. But
	// `SETNX key value` returns bool (0/1). So convert nil to bool.
	if err == Nil {
		cmd.val = false
		return nil
	}
	if err != nil {
		return err
	}
	switch v := v.(type) {
	case int64:
		cmd.val = v == 1
		return nil
	case string:
		cmd.val = v == "OK"
		return nil
	default:
		return fmt.Errorf("got %T, wanted int64 or string", v)
	}
}
```

## StringCmd
```go
type StringCmd struct {
	baseCmd

	val string
}

func (cmd *StringCmd) readReply(rd *proto.Reader) (err error) {
	cmd.val, err = rd.ReadString()
	return err
}
```

还封装了`Bytes`，`Bool`，`Int`，`Int64`，`Uint64`，`Float32`，`Float64`，`Time`，`Scan`

## FloatCmd
```go
type FloatCmd struct {
	baseCmd

	val float64
}

func (cmd *FloatCmd) readReply(rd *proto.Reader) (err error) {

	cmd.val, err = rd.ReadFloatReply()
	return err
}
```

## FloatSliceCmd
```go
type FloatSliceCmd struct {
	baseCmd

	val []float64
}

func (cmd *FloatSliceCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make([]float64, n)
		for i := 0; i < len(cmd.val); i++ {
			switch num, err := rd.ReadFloatReply(); {
			case err == Nil:
				cmd.val[i] = 0
			case err != nil:
				return nil, err
			default:
				cmd.val[i] = num
			}
		}
		return nil, nil
	})
	return err
}
```

## StringSliceCmd
```go
type StringSliceCmd struct {
	baseCmd

	val []string
}

func (cmd *StringSliceCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make([]string, n)
		for i := 0; i < len(cmd.val); i++ {
			switch s, err := rd.ReadString(); {
			case err == Nil:
				cmd.val[i] = ""
			case err != nil:
				return nil, err
			default:
				cmd.val[i] = s
			}
		}
		return nil, nil
	})
	return err
}
```

## BoolSliceCmd
```go
type BoolSliceCmd struct {
	baseCmd

	val []bool
}

func (cmd *BoolSliceCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make([]bool, n)
		for i := 0; i < len(cmd.val); i++ {
			n, err := rd.ReadIntReply()
			if err != nil {
				return nil, err
			}
			cmd.val[i] = n == 1
		}
		return nil, nil
	})
	return err
}
```

## StringStringMapCmd
```go
type StringStringMapCmd struct {
	baseCmd

	val map[string]string
}

func (cmd *StringStringMapCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make(map[string]string, n/2)
		for i := int64(0); i < n; i += 2 {
			key, err := rd.ReadString()
			if err != nil {
				return nil, err
			}

			value, err := rd.ReadString()
			if err != nil {
				return nil, err
			}

			cmd.val[key] = value
		}
		return nil, nil
	})
	return err
}

func (cmd *StringStringMapCmd) Scan(dest interface{}) error {
	if cmd.err != nil {
		return cmd.err
	}

	strct, err := hscan.Struct(dest)
	if err != nil {
		return err
	}

	for k, v := range cmd.val {
		if err := strct.Scan(k, v); err != nil {
			return err
		}
	}

	return nil
}
```

## StringIntMapCmd
```go
type StringIntMapCmd struct {
	baseCmd

	val map[string]int64
}

func (cmd *StringIntMapCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make(map[string]int64, n/2)
		for i := int64(0); i < n; i += 2 {
			key, err := rd.ReadString()
			if err != nil {
				return nil, err
			}

			n, err := rd.ReadIntReply()
			if err != nil {
				return nil, err
			}

			cmd.val[key] = n
		}
		return nil, nil
	})
	return err
}
```

## StringStructMapCmd
```go
type StringStructMapCmd struct {
	baseCmd

	val map[string]struct{}
}

func (cmd *StringStructMapCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make(map[string]struct{}, n)
		for i := int64(0); i < n; i++ {
			key, err := rd.ReadString()
			if err != nil {
				return nil, err
			}
			cmd.val[key] = struct{}{}
		}
		return nil, nil
	})
	return err
}
```

## ZSliceCmd
```go
type ZSliceCmd struct {
	baseCmd

	val []Z
}

func (cmd *ZSliceCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		cmd.val = make([]Z, n/2)
		for i := 0; i < len(cmd.val); i++ {
			member, err := rd.ReadString()
			if err != nil {
				return nil, err
			}

			score, err := rd.ReadFloatReply()
			if err != nil {
				return nil, err
			}

			cmd.val[i] = Z{
				Member: member,
				Score:  score,
			}
		}
		return nil, nil
	})
	return err
}
```

## ZWithKeyCmd
```go
type ZWithKeyCmd struct {
	baseCmd

	val *ZWithKey
}

func (cmd *ZWithKeyCmd) readReply(rd *proto.Reader) error {
	_, err := rd.ReadArrayReply(func(rd *proto.Reader, n int64) (interface{}, error) {
		if n != 3 {
			return nil, fmt.Errorf("got %d elements, expected 3", n)
		}

		cmd.val = &ZWithKey{}
		var err error

		cmd.val.Key, err = rd.ReadString()
		if err != nil {
			return nil, err
		}

		cmd.val.Member, err = rd.ReadString()
		if err != nil {
			return nil, err
		}

		cmd.val.Score, err = rd.ReadFloatReply()
		if err != nil {
			return nil, err
		}

		return nil, nil
	})
	return err
}
```

## ScanCmd
```go
type ScanCmd struct {
	baseCmd

	page   []string
	cursor uint64

	process cmdable
}

func (cmd *ScanCmd) readReply(rd *proto.Reader) (err error) {
	cmd.page, cmd.cursor, err = rd.ReadScanReply()
	return err
}

func (cmd *ScanCmd) Iterator() *ScanIterator {
	return &ScanIterator{
		cmd: cmd,
	}
}
```

# proto
详细文档：见RESP[协议文档](https://redis.io/topics/protocol)

```go
const (
	ErrorReply  = '-' // 简单错误   -<string>\r\n
	StatusReply = '+' // 简单字符串 +<string>\r\n
	IntReply    = ':' // 数字      :<number>\r\n
	StringReply = '$' // 二进制数据 $<length>\r\n<bytes>\r\n
	ArrayReply  = '*' // 数组      *<elements number>\r\n... numelements other types ...
)
```

## request
用于发送RESP字节流协议
```go
type writer interface {
	io.Writer
	io.ByteWriter
	// io.StringWriter
	WriteString(s string) (n int, err error)
}

type Writer struct {
	writer

	lenBuf []byte
	numBuf []byte
}
```

golang数据转为RESP协议
* `func (w *Writer) WriteArgs(args []interface{}) error`，写入多个基本类型
* `func (w *Writer) writeLen(n int) error`，写入长度
* `func (w *Writer) WriteArg(v interface{}) error`，写入基本类型
* `func (w *Writer) bytes(b []byte) error`，写入字节流
* `func (w *Writer) string(s string) error`，写入字符串
* `func (w *Writer) uint(n uint64) error`，写入uint
* `func (w *Writer) int(n int64) error`，写入int
* `func (w *Writer) float(f float64) error`，写入浮点
* `func (w *Writer) crlf() error`，写入回车换行

## reply
用于接收redis返回的数据
```go
type MultiBulkParse func(*Reader, int64) (interface{}, error)

const Nil = RedisError("redis: nil") // nolint:errname

type RedisError string

func (e RedisError) Error() string { return string(e) }

func (RedisError) RedisError() {}

type Reader struct {
	rd   *bufio.Reader
	_buf []byte
}
```

基础字节流
* `func (r *Reader) Buffered() int`，缓冲区内容大小
* `func (r *Reader) Peek(n int) ([]byte, error)`，读取但不偏移
* `func (r *Reader) Reset(rd io.Reader)`，重置
* `func (r *Reader) ReadLine() ([]byte, error)`，读取下一行

解析协议
* `func (r *Reader) ReadReply(m MultiBulkParse) (interface{}, error)`，解析响应，m为解析多行的函数
* `func (r *Reader) ReadIntReply() (int64, error)`，解析数字
* `func (r *Reader) ReadString() (string, error)`，解析字符串
* `func (r *Reader) ReadArrayReply(m MultiBulkParse) (interface{}, error)`，解析数组
* `func (r *Reader) ReadArrayLen() (int, error)`，解析数组长度
* `func (r *Reader) ReadScanReply() ([]string, uint64, error)`，解析scan数据

读取下一行内容并解析成指定类型
* `func (r *Reader) readTmpBytesReply() ([]byte, error)`，读取一行字节流内容
* `func (r *Reader) ReadInt() (int64, error)`，将字节流解析有符号数字
* `func (r *Reader) ReadUint() (uint64, error)`，将字节流解析无符号数字
* `func (r *Reader) ReadFloatReply() (float64, error)`，将字节流解析浮点

## scan
解析结构体的redis tag，利用反射设置
* `func Scan(b []byte, v interface{}) error`，将字节流的值反射入v
* `func ScanSlice(data []string, slice interface{}) error`，将字符串数组反射入slice

# net
## Conn
封装对resp协议的读写
```go
type Conn struct {
	usedAt  int64 // atomic
	netConn net.Conn

	rd *proto.Reader
	bw *bufio.Writer // 用于写字节
	wr *proto.Writer // 用于写协议

	Inited    bool // 是否初始化
	pooled    bool // 是否归还池
	createdAt time.Time
}
```

连接属性
* `func (cn *Conn) UsedAt() time.Time`，获取上次使用时间
* `func (cn *Conn) SetUsedAt(tm time.Time)`，设置使用时间
* `func (cn *Conn) SetNetConn(netConn net.Conn)`，设置底层网络连接
* `func (cn *Conn) RemoteAddr() net.Addr`，获取远端地址

连接操作
* `func (cn *Conn) Write(b []byte) (int, error)`，写入二进制数据
* `func (cn *Conn) WithReader(ctx context.Context, timeout time.Duration, fn func(rd *proto.Reader) error) error`，带有reader的读协议
* `func (cn *Conn) WithWrite(ctx context.Context, timeout time.Duration, fn func(wr *proto.Writer) error`，带有writer的写协议
* `func (cn *Conn) Close() error`，关闭连接


## Pooler
连接池接口，用于管控连接池连接
```go
type Pooler interface {
	NewConn(context.Context) (*Conn, error)
	CloseConn(*Conn) error

	Get(context.Context) (*Conn, error)
	Put(context.Context, *Conn)
	Remove(context.Context, *Conn, error)

	Len() int
	IdleLen() int
	Stats() *Stats

	Close() error
}
```

### ConnPool
基础连接池
```go
type ConnPool struct {
	opt *Options

	dialErrorsNum uint32 // atomic

	lastDialError atomic.Value

	queue chan struct{} // 并发控制

	connsMu      sync.Mutex
	conns        []*Conn // 所有连接的连接对象 包含不是池连接
	idleConns    []*Conn // 空闲连接
	poolSize     int     // 分配出去的池连接个数
	idleConnsLen int

	stats Stats

	_closed  uint32 // atomic
	closedCh chan struct{}
}

type Options struct {
	Dialer  func(context.Context) (net.Conn, error) // 拨号器
	OnClose func(*Conn) error                       // 关闭事件处理

	PoolFIFO           bool // 是否是先进先出
	PoolSize           int
	MinIdleConns       int
	MaxConnAge         time.Duration
	PoolTimeout        time.Duration
	IdleTimeout        time.Duration
	IdleCheckFrequency time.Duration
}

type Stats struct {
	Hits     uint32 // number of times free connection was found in the pool
	Misses   uint32 // number of times free connection was NOT found in the pool
	Timeouts uint32 // number of times a wait timeout occurred

	TotalConns uint32 // number of total connections in the pool
	IdleConns  uint32 // number of idle connections in the pool
	StaleConns uint32 // number of stale connections removed from the pool
}
```

并发的控制
* `func (p *ConnPool) getTurn()`，阻塞获取执行权限
* `func (p *ConnPool) waitTurn(ctx context.Context) error`，等待获取执行权限
* `func (p *ConnPool) freeTurn()`，释放执行权限

池化的管理
* `func (p *ConnPool) Get(ctx context.Context) (*Conn, error)`，获取连接
* `func (p *ConnPool) Put(ctx context.Context, cn *Conn)`，归还连接
* `func (p *ConnPool) Remove(ctx context.Context, cn *Conn, reason error)`，移除连接
* `func (p *ConnPool) CloseConn(cn *Conn) error`，关闭连接
* `func (p *ConnPool) Len() int`，连接池连接数
* `func (p *ConnPool) IdleLen() int`，空闲连接数
* `func (p *ConnPool) Stats() *Stats`，返回状态
* `func (p *ConnPool) Close() error`，关闭连接池
* `func (p *ConnPool) Filter(fn func(*Conn) bool) error`，对连接池每个连接执行过滤函数fn

异步清理空闲连接
* `func (p *ConnPool) reaper(frequency time.Duration)`，定时清理过期连接
* `func (p *ConnPool) ReapStaleConns() (int, error)`，清理过期连接
* `func (p *ConnPool) isStaleConn(cn *Conn) bool`，判断是否是过期连接

### SingleConnPool
池里面只有一个连接的连接池 用于有连接状态的请求连接池
```go
type SingleConnPool struct {
	pool      Pooler
	cn        *Conn
	stickyErr error
}
```

复写底层pool的方法
* `func (p *SingleConnPool) NewConn(ctx context.Context) (*Conn, error)`，新建连接
* `func (p *SingleConnPool) CloseConn(cn *Conn) error`，关闭连接
* `func (p *SingleConnPool) Get(ctx context.Context) (*Conn, error)`，获取连接
* `func (p *SingleConnPool) Put(ctx context.Context, cn *Conn) `，归还连接
* `func (p *SingleConnPool) Remove(ctx context.Context, cn *Conn, reason error)`，移除连接
* `func (p *SingleConnPool) Close() error`，关闭连接池


### StickyConnPool
黏性连接池，用于事务连接管理，可主动关闭连接
```go
type StickyConnPool struct {
	pool   Pooler
	// 引用计数
	shared int32 // atomic

	state uint32 // atomic
	// 单个连接的通道数据
	ch    chan *Conn

	_badConnError atomic.Value
}
```

复写底层pool方法
* `func (p *StickyConnPool) NewConn(ctx context.Context) (*Conn, error)`，新建连接
* `func (p *StickyConnPool) CloseConn(cn *Conn) error`，关闭连接
* `func (p *StickyConnPool) Get(ctx context.Context) (*Conn, error)`，获取连接
* `func (p *StickyConnPool) Put(ctx context.Context, cn *Conn)`，归还连接
* `func (p *StickyConnPool) Remove(ctx context.Context, cn *Conn, reason error)`，移除连接
* `func (p *StickyConnPool) Close() error`，关闭连接池
* `func (p *StickyConnPool) Len() int`，连接池连接数
* `func (p *StickyConnPool) IdleLen() int`，空闲连接数
* `func (p *StickyConnPool) Stats() *Stats`，连接池状态

重置操作
* `func (p *StickyConnPool) Reset(ctx context.Context) error`，重置连接


# 总结

* 命令操作使用函数式编程，让调用更紧密，上层不需要关心底层逻辑
* 各模块之间使用接口，让底层实现更加灵活
* 三层结构（操作-连接-协议）层次分明，各司其职，结构清晰




