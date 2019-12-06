---
title: golang package net/http/client
tags:
  - net
  - http
categories:
  - golang
date: 2018-08-01 18:35:27
---
大概记录一下golang里面的net/http包内client.go的文件，及其相关内容 
<!-- more -->

# client
## Client struct
Client 是一个HTTP client
Client Transport通常具有内部状态（缓存TCP连接），所以Client应该被重用而不是工具需求创建
Client 是协程安全的
Client 是比RoundTripper更高级，并处理HTTP的细节（cookie和redirect）
重定向后，Client将会转发初始请求的所有headers，除：
- headers具有敏感信息（Authorization，WWW-Authenticate，Cookie）传递给不受信任的目标。在重定向时不是子域匹配的域或初始域的完全匹配域时会被忽略
- 传递Cookie是Jar non-nil，由于每个重定向都有可能改变cookie jar，导致重定向cookie与初始请求cookie不一致，任何改变的cookie将会被忽略，并通过Jar将初始请求的cookie填充那些被忽略的cookie，如果Jar为nil，则初始cookie将不加更改地转发

```golang
type Client struct {
    // Transport 指定进行单个http请求的机制
    // 如果为空会使用默认的机制
    Transport RoundTripper

    // CheckRedirect 处理重定向的一种策略
    // 如果不为空，会在http重定向之前调用
    // req 表示即将发出的请求
    // via 表示已经发出的请求
    // 如果CheckRedirect返回error，Client的Get方法返回原先的响应（Body closed）
    // 并且CheckRedirect的error（会添加进url.Error里面）会替代req的issue
    // 特殊情况，如果CheckRedirect返回ErrUseLastResponse，则返回最近的响应（Body unclosed），和nil error
    // 如果CheckRedirect为nil，则使用默认策略，即10次连续请求后停止
    CheckRedirect func(req *Request, via []*Request) error

    // Jar 定义cookie jar
    // 对于每个请求都会添加Jar cookie value
    // 对于每个响应都会修改更新Jar cookie value
    // 对于每个重定向都会查询Jar
    // 当Jar为nil时，只有在请求明确设置cookie时才会发送cookie
    Jar CookieJar

    // Timeout 对每个请求限制时间
    // Timeout 包括连接（任何重定向，读取响应）
    // 在GET、Head、Post、Do返回后计时器人会运行，并可能会中断读取response.Body
    // Timeout 为0，表示没有timeout
    // Client使用Request.Cancel机制取消对底层传输的请求
    // 传递给Client.Do的请求仍可以设置Request.Cancel;,两者都会取消请求
    // 为了兼容性，如果发现Transport使用CancelRequest方法，Client则会忽略（弃用）
    // 可以实现RoundTripper的Request.Cancel方法来代替实现CancelRequest
    Timeout time.Duration
}
```
## Client Method
```golang
func (c *Client) send(req *Request, deadline time.Time) (resp *Response, didTimeout func() bool, err error)
```
send 发送请求，返回响应。send总是关闭req.Body
1. 如果c.Jar不为nil，req填充c.Jar
2. 利用req发送请求，获取resp
3. 如果c.Jar不为nil，c.Jar填充resp.Cookies

```golang
func (c *Client) deadline() time.Time
```
deadline 返回Client的deadline，如果c.Timeout大于0，返回当前时间加上c.Timeout，否则返回time.Time{}
```golang
func (c *Client) transport() RoundTripper
```
transport 返回Client的RoundTripper，c.Transport为nil，返回DefaultTransport
```golang
func (c *Client) Get(url string) (resp *Response, err error)
```
Get 对url发起GET请求
```golang
func (c *Client) checkRedirect(req *Request, via []*Request) error
```
checkRedirect 返回Client.CheckRedirect的执行结果，如果c.CheckRedirect为空，则返回defaultCheckRedirect的执行结果
```golang
func (c *Client) Do(req *Request) (*Response, error)
```
Do 发送一个HTTP请求并返回一个HTTP响应
1. 判断req.URL是否为空，为空返回error
3. 通过c.send()获取请求的resp
4. 使用redirectBehavior()判断是否需要重定向
5. 如果不需要重定向，则返回resp
6. 获取req.Header中的“Location”
7. 将其解析成URL struct
8. 拼成Request struct
9. 保存当前req的header
10. 将当前req.URL转换为referer，并添加进req.Header中
11. 调用c.checkRedirect()，如果返回ErrUseLastResponse，则直接返回resp和nil
12. 如果resp.ContentLength == -1 或者 resp.ContentLength <= 2 << 10，就将resp.Body直接丢掉
13. 如果c.checkRedirect()返回其他错误，直接返回当前resp和错误信息

```golang
func (c *Client) makeHeadersCopier(ireq *Request) func(*Request)
```
makeHeadersCopier 创建一个复制初始请求Header的函数。对于每一个重定向，该函数必须调用，因此它可以将Header复制到新的请求中
```golang
func (c *Client) Post(url string, contentType string, body io.Reader) (resp *Response, err error)
```
Post 利用post请求相应的数据，调用者读取完数据后必须resp.Body.Close()，如果body是io.Closer则在请求后关闭
如果需要添加其他的header，需要使用NewRequest和Client.Do
```golang
func (c *Client) PostForm(url string, data url.Values) (resp *Response, err error)
```
PostForm 对指定的url和参数对进行POST请求，默认设置Header ContentType为 application/x-www-form-urlencoded 
如果需要添加其他的header，需要使用NewRequest和Client.Do
如果err为nil，则resp总是non-nil resp.Body，调用者需要在读取数据后关闭resp.Body
```golang
func (c *Client) Head(url string) (resp *Response, err error)
```
Head 利用head请求指定url
如果响应的是以下状态码，则Head会跟随重定向：
1. 301 (Moved Permanently)  
2. 302 (Found)  
3. 303 (See Other)  
4. 307 (Temporary Redirect)  
5. 308 (Permanent Redirect)


# RoundTripper interface

RoundTripper 定义执行单个HTTP事务，实现必须是协程安全的
```golang
type RoundTripper interface {
    // RoundTrip 执行单个HTTP事务，为request返回response
    // RoundTrip 没有试着去解释这个响应，当它获得一个响应时会返回err==nil，不管这个响应的返回码是什么
    // 一个包含错误响应的err是non-nil的
    // RoundTrip 也没有试着去处理高层协议细节，例如：redirects,authentication,cookies
    // 除了使用和关闭Request的Body之外，RoundTrip不应该修改请求
    // RoundTrip 会分离一个goroutine去处理read fields
    // 在Response Body未关闭之前，调用者不能修改请求
    // RoundTrip 总是要关闭body和error，但是可能会是异步执行，所以调用者如果想重用调用主体则必须等待Close之后调用
    // Request的URL和Header必须初始化
    RoundTrip(*Request) (*Response, error)
}
```



# cancelTimerBody struct
## cancelTimerBody struct
cancelTimerBody 是一个io.ReadCloser接口的实现，具有：
- 当读错误或者关闭，stop()会被调用
- 当读失败，如果reqDidTimeout为真，则会将错误封装进net.Error提示达到timeout

```golang
type cancelTimerBody struct {
    // stop 停止time.Timer等待取消请求
    stop          func() 
    rc            io.ReadCloser
    reqDidTimeout func() bool
}
```
## cancelTimerBody method
```golang
func (b *cancelTimerBody) Read(p []byte) (n int, err error)
```
Read 从b.rc中读取n个byte存放进p
1. 如果err为nil直接返回
2. 如果err不为nil，会执行b.stop()，如果err==io.EOF直接返回
3. 判断b.reqDidTimeout()为真，封装成httpError错误
4. 返回读取字节数和错误


```golang
func (b *cancelTimerBody) Close() error
```
Close 关闭b，调用b.rc.Close()和b.stop()

# client function
```golang
func refererForURL(lastReq, newReq *url.URL) string
```
refererForURL 将lastReq转换成header中Referer的值
1. 如果lastReq.Scheme为https，但newReq.Scheme为http，直接返回空字符串
2. 将lastReq生成字符串referer
3. 如果lastReq.User不为nil，则去掉referer中user字段
4. 返回referer

```golang
func send(ireq *Request, rt RoundTripper, deadline time.Time) (resp *Response, didTimeout func() bool, err error)
```
send 发送一个http请求，调用者需要在读完后调用resp.Body.Close()
```golang
func setRequestCancel(req *Request, rt RoundTripper, deadline time.Time) (stopTimer func(), didTimeout func() bool)
```
setRequestCancel 如果deadline为non-zero，则为req设置Cancel
```golang
func basicAuth(username, password string) string
```
basicAuth 将username和password合并，并使用base64转换，但并不保证结果是已url编码的
```golang
func Get(url string) (resp *Response, err error)
```
Get 使用默认客户端调用Get()
```golang
func alwaysFalse() bool
```
alwaysFalse 返回false
```golang
func redirectBehavior(reqMethod string, resp *Response, ireq *Request) (redirectMethod string, shouldRedirect, includeBody bool)
```
redirectBehavior 描述当状态码为3xx时的操作
1. 301,302,303：只保留GET和HEAD方法，需要重定向，不需要includeBody
2. 307,308：
  - 如果resp.Header中包含Location为空字符串，则重定向方法为当前请求方法，不需要重定向，需要includeBody
  - 如果ireq.GetBody为nil并且ireq.ContentLength不为0，则重定向方法为当前请求方法，不需要重定向，需要includeBody
  - 其他情况重定向方法为当前请求方法，需要重定向，需要includeBody
返回重定向方法，是否重定向，是否需要body

```golang
func defaultCheckRedirect(req *Request, via []*Request) error
```
defaultCheckRedirect 默认检查重定向机制，如果重定向了10次则返回`errors.New("stopped after 10 redirects")`
```golang
func Post(url string, contentType string, body io.Reader) (resp *Response, err error)
```
Post 使用默认客户端调用Post()
```golang
func PostForm(url string, data url.Values) (resp *Response, err error)
```
PostForm 使用默认客户端调用PostForm()
```golang
func Head(url string) (resp *Response, err error)
```
Head 使用默认客户端调用Head()
```golang
func shouldCopyHeaderOnRedirect(headerKey string, initial, dest *url.URL) bool
```
shouldCopyHeaderOnRedirect 当headerkey为"Authorization", "Www-Authenticate", "Cookie", "Cookie2"之一时回去判断dest.Addr是initial.Addr的子域
如果不为上述情况直接返回true
```golang
func isDomainOrSubdomain(sub, parent string) bool
```
isDomainOrSubdomain 返回sub是否是parent的子域或者完全匹配，两个域名必须是规范形式

