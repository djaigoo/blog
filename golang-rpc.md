---
title: golang-rpc
tags:
  - rpc
categories:
  - golang
draft: true
date: 2018-09-26 15:04:11
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png
---

# 概述
 RPC（Remote Procedure Call），即远程过程调用。RPC最常见的一种方式是基于http协议的RESTful API，常用于微服务架构中。
## RPC 工作原理
 RPC的工作原理如图：
 ![RPC调用图](https://img-1251474779.cos.ap-beijing.myqcloud.com/5GCF9FN3QGZJTSZ2J60L.png)
RPC中client中的本地进程可以通过约定的RPC接口调用server的远端进程。其基本步骤为：
1. 本地进程将请求数据编码为约定的数据类型（json，xml，二进制等等）
2. 再通过约定的网络协议进行传输（http，http2，tcp，udp等等）
3. 到了server后，将收到的数据进行解码，然后分发给对应的进程
4. 对应进程处理完后将响应信息编码
5. 编码后的响应信息通过约定的网络协议进行传输
6. client接收到响应后，将响应信息解码
7. 将解码的响应信息发送给调用的本地进程

## RPC 使用场景
RPC的使用可以让不同系统之间进行通信，不同服务间进行通信，横向扩展了计算能力。

# golang 的RPC包
RPC包提供对通过网络或其他I / O连接的对象的导出方法的访问。服务器注册一个对象，使其作为服务可见，并具有对象类型的名称。注册后，可以远程访问对象的导出方法。服务器可以注册不同类型的多个对象（服务），但是注册相同类型的多个对象是错误的。
只有满足一定的标准才能够用于远端访问：
- 导出方法的类型
- 导出方法
- 该方法有两个参数
- 方法的第二个参数是指针
- 该方法具有返回类型错误

总的来说，方法应该类似`func (t *T) MethodName(argType T1, replyType *T2) error`，T1和T2可以被encoding/gob编码。即使使用不同的编解码器，这些要求也适用。将来，这些要求可能会因自定义编解码器而变得柔和。
方法的第一个参数表示调用者提供的参数;第二个参数是要返回给调用者的结果参数；方法返回值，如果为空，将作为客户端看到的字符串传回，就好像由errors.New创建的，如果返回错误，则不会将reply参数发送给客户端。
服务器可以通过调用ServeConn来处理单个连接上的请求。更典型的是，它将创建网络侦听器并调用Accept，或者对于HTTP侦听器，调用HandleHTTP和http.Serve。
希望使用该服务的客户端建立连接，然后在连接上调用NewClient。便捷功能Dial（DialHTTP）执行原始网络连接（HTTP连接）的两个步骤。结果Client对象有两个方法，Call和Go，指定要调用的服务和方法，包含参数的指针和接收结果参数的指针。
Call方法等待远程调用完成，而Go方法异步启动调用并使用Call结构的Done通道发出完成信号。除非设置了显式编解码器，否则使用encoding/gob包来传输数据。
## Server
### Server 结构体
```go
// Server represents an RPC Server.
type Server struct {
	serviceMap sync.Map   // map[string]*service
	reqLock    sync.Mutex // protects freeReq
	freeReq    *Request
	respLock   sync.Mutex // protects freeResp
	freeResp   *Response
}
```
### Server 方法
#### NewServer
```go
// NewServer returns a new Server.
func NewServer() *Server {
	return &Server{}
}

// DefaultServer is the default instance of *Server.
var DefaultServer = NewServer()
```


#### Register
Register 在服务器中发布满足以下条件的接收器值的方法集：
* 导出类型导出方法
* 两个参数都是导出类型
* 第二个参数是指针
* 返回值为error，如果接受方不是导出类型或没有合适的方法，则返回错误，它还使用包日志记录错误。

客户端使用“Type.Method”形式的字符串访问每个方法，其中Type是接收者的具体类型。
```go
func (server *Server) Register(rcvr interface{}) error {
   return server.register(rcvr, "", false)
}
```

#### RegisterName
```go
func (server *Server) RegisterName(name string, rcvr interface{}) error {
	return server.register(rcvr, name, true)
}
```
#### register
```go
func (server *Server) register(rcvr interface{}, name string, useName bool) error {
	s := new(service)
	s.typ = reflect.TypeOf(rcvr)
	s.rcvr = reflect.ValueOf(rcvr)
	sname := reflect.Indirect(s.rcvr).Type().Name()
	if useName {
		sname = name
	}
	if sname == "" {
		s := "rpc.Register: no service name for type " + s.typ.String()
		log.Print(s)
		return errors.New(s)
	}
	if !isExported(sname) && !useName {
		s := "rpc.Register: type " + sname + " is not exported"
		log.Print(s)
		return errors.New(s)
	}
	s.name = sname

	// Install the methods
	s.method = suitableMethods(s.typ, true)

	if len(s.method) == 0 {
		str := ""

		// To help the user, see if a pointer receiver would work.
		method := suitableMethods(reflect.PtrTo(s.typ), false)
		if len(method) != 0 {
			str = "rpc.Register: type " + sname + " has no exported methods of suitable type (hint: pass a pointer to value of that type)"
		} else {
			str = "rpc.Register: type " + sname + " has no exported methods of suitable type"
		}
		log.Print(str)
		return errors.New(str)
	}

	if _, dup := server.serviceMap.LoadOrStore(sname, s); dup {
		return errors.New("rpc: service already defined: " + sname)
	}
	return nil
}
```

#### suitableMethods
suitableMethods 返回适当的典型RPC方法，如果reportErr为true，他将使用log报告错误。
```go
func suitableMethods(typ reflect.Type, reportErr bool) map[string]*methodType {
	methods := make(map[string]*methodType)
	for m := 0; m < typ.NumMethod(); m++ {
		method := typ.Method(m)
		mtype := method.Type
		mname := method.Name
		// Method must be exported.
		if method.PkgPath != "" {
			continue
		}
		// Method needs three ins: receiver, *args, *reply.
		if mtype.NumIn() != 3 {
			if reportErr {
				log.Printf("rpc.Register: method %q has %d input parameters; needs exactly three\n", mname, mtype.NumIn())
			}
			continue
		}
		// First arg need not be a pointer.
		argType := mtype.In(1)
		if !isExportedOrBuiltinType(argType) {
			if reportErr {
				log.Printf("rpc.Register: argument type of method %q is not exported: %q\n", mname, argType)
			}
			continue
		}
		// Second arg must be a pointer.
		replyType := mtype.In(2)
		if replyType.Kind() != reflect.Ptr {
			if reportErr {
				log.Printf("rpc.Register: reply type of method %q is not a pointer: %q\n", mname, replyType)
			}
			continue
		}
		// Reply type must be exported.
		if !isExportedOrBuiltinType(replyType) {
			if reportErr {
				log.Printf("rpc.Register: reply type of method %q is not exported: %q\n", mname, replyType)
			}
			continue
		}
		// Method needs one out.
		if mtype.NumOut() != 1 {
			if reportErr {
				log.Printf("rpc.Register: method %q has %d output parameters; needs exactly one\n", mname, mtype.NumOut())
			}
			continue
		}
		// The return type of the method must be error.
		if returnType := mtype.Out(0); returnType != typeOfError {
			if reportErr {
				log.Printf("rpc.Register: return type of method %q is %q, must be error\n", mname, returnType)
			}
			continue
		}
		methods[mname] = &methodType{method: method, ArgType: argType, ReplyType: replyType}
	}
	return methods
}
```
#### sendResponse
```go
func (server *Server) sendResponse(sending *sync.Mutex, req *Request, reply interface{}, codec ServerCodec, errmsg string) {
	resp := server.getResponse()
	// Encode the response header
	resp.ServiceMethod = req.ServiceMethod
	if errmsg != "" {
		resp.Error = errmsg
		reply = invalidRequest
	}
	resp.Seq = req.Seq
	sending.Lock()
	err := codec.WriteResponse(resp, reply)
	if debugLog && err != nil {
		log.Println("rpc: writing response:", err)
	}
	sending.Unlock()
	server.freeResponse(resp)
}
```

#### ServeConn
```go
func (server *Server) ServeConn(conn io.ReadWriteCloser) {
	buf := bufio.NewWriter(conn)
	srv := &gobServerCodec{
		rwc:    conn,
		dec:    gob.NewDecoder(conn),
		enc:    gob.NewEncoder(buf),
		encBuf: buf,
	}
	server.ServeCodec(srv)
}
```
#### ServeCodec
```go
func (server *Server) ServeCodec(codec ServerCodec) {
	sending := new(sync.Mutex)
	wg := new(sync.WaitGroup)
	for {
		service, mtype, req, argv, replyv, keepReading, err := server.readRequest(codec)
		if err != nil {
			if debugLog && err != io.EOF {
				log.Println("rpc:", err)
			}
			if !keepReading {
				break
			}
			// send a response if we actually managed to read a header.
			if req != nil {
				server.sendResponse(sending, req, invalidRequest, codec, err.Error())
				server.freeRequest(req)
			}
			continue
		}
		wg.Add(1)
		go service.call(server, sending, wg, mtype, req, argv, replyv, codec)
	}
	// We've seen that there are no more requests.
	// Wait for responses to be sent before closing codec.
	wg.Wait()
	codec.Close()
}
```

#### ServeRequest
```go
func (server *Server) ServeRequest(codec ServerCodec) error {
	sending := new(sync.Mutex)
	service, mtype, req, argv, replyv, keepReading, err := server.readRequest(codec)
	if err != nil {
		if !keepReading {
			return err
		}
		// send a response if we actually managed to read a header.
		if req != nil {
			server.sendResponse(sending, req, invalidRequest, codec, err.Error())
			server.freeRequest(req)
		}
		return err
	}
	service.call(server, sending, nil, mtype, req, argv, replyv, codec)
	return nil
}
```



## Client

## jsonrpc






