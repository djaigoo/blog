---
title: golang-context
tags:
  - golang
categories:
  - base
draft: true
date: 2018-09-12 16:26:11
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png
---
剖析一下golang的context包
<!--more-->
# Context
## Context 结构体
Context 承载着deadline，cancelation signal，和其他值。Context的方法都是协程安全的。
context结构
```go
type Context interface {
	// Deadline 返回应该取消代表此上下文完成的工作的时间
	// 如果返回ok==false，表示deadline没有被设置
	// 连续调用Deadline，会返回相同的结果
	Deadline() (deadline time.Time, ok bool)

	// Done 返回一个channel，context退出将会关闭这个channel
	// Done 有可能返回nil，表示context没有被取消 
	// 连续调用Deadline，会返回相同的结果
	//
	// WithCancel 当cancel被调用时，将会调用Done去关闭
	// WithDeadline 当deadline到期时调用Done
	// WithTimeout 当超时时，调用Done
	//
	// Done 为了在select中使用：
	// Stream使用DoSomething生成值并将它们发送到out，直到DoSomething返回错误或ctx.Done关闭。
	//  func Stream(ctx context.Context, out chan<- Value) error {
	//  	for {
	//  		v, err := DoSomething(ctx)
	//  		if err != nil {
	//  			return err
	//  		}
	//  		select {
	//  		case <-ctx.Done():
	//  			return ctx.Err()
	//  		case out <- v:
	//  		}
	//  	}
	//  }
	Done() <-chan struct{}

	// Err 如果Done没有被关闭，Err返回nil
	// 如果Done被关闭，Err返回非空error
	// 如果context被cancel，则Canceled；或者如果context deadline已过，则DeadlineExceeded
	// Err返回非零错误后，对Err的连续调用返回相同的错误。
	Err() error

	// Value 返回和context相关的key或nil
	// 如果没有相关连的key，使用相同的key连续调用Value会返回相同的结果
	// 仅将context值用于转换进程和API边界的请求范围数据，而不是将可选参数传递给函数。
	//
	// key定义context中的特定值，希望在Context中存储值的函数通常在全局中分配键变量然后使用该键作为context.WithValue和Context.Value的参数。
	// key可以是支持相等的任何类型;包应该将键定义为未导出类型以避免冲突。
	// 
	// 定义Context键的包应该为使用该键存储的值提供类型安全的访问器：
	//
	// 	// Package user defines a User type that's stored in Contexts.
	// 	package user
	//
	// 	import "context"
	//
	// 	// User is the type of value stored in the Contexts.
	// 	type User struct {...}
	//
	// 	// key is an unexported type for keys defined in this package.
	// 	// This prevents collisions with keys defined in other packages.
	// 	type key int
	//
	// 	// userKey is the key for user.User values in Contexts. It is
	// 	// unexported; clients use user.NewContext and user.FromContext
	// 	// instead of using this key directly.
	// 	var userKey key
	//
	// 	// NewContext returns a new Context that carries value u.
	// 	func NewContext(ctx context.Context, u *User) context.Context {
	// 		return context.WithValue(ctx, userKey, u)
	// 	}
	//
	// 	// FromContext returns the User value stored in ctx, if any.
	// 	func FromContext(ctx context.Context) (*User, bool) {
	// 		u, ok := ctx.Value(userKey).(*User)
	// 		return u, ok
	// 	}
	Value(key interface{}) interface{}
}
```

## context 函数
### 初始化
context有两个初始化函数，两个函数都是返回一个非nil的空context。
```go
func Background() Context
func TODO() Context
```
* Background()：永远不会被取消，没有value，没有deadline。它通常由主函数，初始化和测试使用，并作为传入请求的顶级Context。
* TODO()：当不清楚使用哪个Context或者它还不可用时（因为周围的函数尚未扩展为接受Context参数）。静态分析工具可识别TODO，以确定上下文是否在程序中正确传播。
### 添加参数
```go
type CancelFunc func()

func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
func WithDeadline(parent Context, d time.Time) (Context, CancelFunc)
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
func WithValue(parent Context, key, val interface{}) Context
```
* CancelFunc()：告诉操作者怎样停止操作，并且不等待工作停止。第一次调用后，对CancelFunc的后续调用不执行任何操作。
* WithCancel()：返回带有新Done通道的副本。当返回的cancel函数被调用，或者parent的Done管道被关闭，都会关闭ctx的Done管道。
* WithDeadline()：返回带有新调整deadline（截止日期为d）的parent副本。如果d在parent的deadline之后，则副本的deadline等同于parent的deadline。当截止日期到期，或返回的CancelFunc被调用，或parent的Done管道关闭，都会导致副本的Done管道关闭。调用CancelFunc 会释放context与其关联的资源，因此代码应在此context运行的操作完成后立即调用cancel。
* WithTimeout()：返回WithDeadline(parent, time.Now().Add(timeout))
* WithValue()：返回带有key为val的parent副本。context的value仅用于转换进程和API的请求范围数据，而不是将可选参数传递给函数。参数key必须是可以比较的，不应该是字符串类型或任何其他内置类型，以避免使用上下文的包之间的冲突。WithValue的调用者应该为key定义他们自己的类型。为了避免在分配接口{}时分配，上下文键通常具有具体类型struct {}，或者导出的context关键变量的静态类型应该是指针或接口。

### 内部类型
#### interface
context包里面除了Context接口，还有canceler接口。caceler用于With*函数的返回值cancel的值
```go
type canceler interface {
	cancel(removeFromParent bool, err error)
	Done() <-chan struct{}
}
```

#### struct
context包里面emptyCtx，cancelCtx，timerCtx，valueCtx结构
emptyCtx是默认的context，是Background和TODO的直接返回值
```go
type emptyCtx int

func (*emptyCtx) Deadline() (deadline time.Time, ok bool) {
	return
}

func (*emptyCtx) Done() <-chan struct{} {
	return nil
}

func (*emptyCtx) Err() error {
	return nil
}

func (*emptyCtx) Value(key interface{}) interface{} {
	return nil
}

func (e *emptyCtx) String() string {
	switch e {
	case background:
		return "context.Background"
	case todo:
		return "context.TODO"
	}
	return "unknown empty Context"
}

var (
	background = new(emptyCtx)
	todo       = new(emptyCtx)
)

func Background() Context {
	return background
}

func TODO() Context {
	return todo
}
```
cancelCtx结构用于在WithCancel()返回值
```go
type cancelCtx struct {
	Context

	mu       sync.Mutex            // protects following fields
	done     chan struct{}         // created lazily, closed by first cancel call
	children map[canceler]struct{} // set to nil by the first cancel call
	err      error                 // set to non-nil by the first cancel call
}

func (c *cancelCtx) Done() <-chan struct{} {
	c.mu.Lock()
	if c.done == nil {
		c.done = make(chan struct{})
	}
	d := c.done
	c.mu.Unlock()
	return d
}

func (c *cancelCtx) Err() error {
	c.mu.Lock()
	err := c.err
	c.mu.Unlock()
	return err
}

func (c *cancelCtx) String() string {
	return fmt.Sprintf("%v.WithCancel", c.Context)
}

// cancel closes c.done, cancels each of c's children, and, if
// removeFromParent is true, removes c from its parent's children.
func (c *cancelCtx) cancel(removeFromParent bool, err error) {
	if err == nil {
		panic("context: internal error: missing cancel error")
	}
	c.mu.Lock()
	if c.err != nil {
		c.mu.Unlock()
		return // already canceled
	}
	c.err = err
	if c.done == nil {
		c.done = closedchan
	} else {
		close(c.done)
	}
	for child := range c.children {
		// NOTE: acquiring the child's lock while holding parent's lock.
		child.cancel(false, err)
	}
	c.children = nil
	c.mu.Unlock()

	if removeFromParent {
		removeChild(c.Context, c)
	}
}
```
timerCtx结构用于WithDeadline()的返回值
```go
type timerCtx struct {
	cancelCtx
	timer *time.Timer // Under cancelCtx.mu.

	deadline time.Time
}

func (c *timerCtx) Deadline() (deadline time.Time, ok bool) {
	return c.deadline, true
}

func (c *timerCtx) String() string {
	return fmt.Sprintf("%v.WithDeadline(%s [%s])", c.cancelCtx.Context, c.deadline, time.Until(c.deadline))
}

func (c *timerCtx) cancel(removeFromParent bool, err error) {
	c.cancelCtx.cancel(false, err)
	if removeFromParent {
		// Remove this timerCtx from its parent cancelCtx's children.
		removeChild(c.cancelCtx.Context, c)
	}
	c.mu.Lock()
	if c.timer != nil {
		c.timer.Stop()
		c.timer = nil
	}
	c.mu.Unlock()
}
```
valueCtx结构用WithValue()函数的返回值
```go
type valueCtx struct {
	Context
	key, val interface{}
}

func (c *valueCtx) String() string {
	return fmt.Sprintf("%v.WithValue(%#v, %#v)", c.Context, c.key, c.val)
}

func (c *valueCtx) Value(key interface{}) interface{} {
	if c.key == key {
		return c.val
	}
	return c.Context.Value(key)
}

```

