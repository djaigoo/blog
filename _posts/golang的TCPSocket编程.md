---
author: djaigo
title: golang TCP Socket编程
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - net
  - tcp
date: 2020-04-09 12:22:55
---

golang版本：1.14.1
主要是对golang net包的Conn接口函数进行测试，这里只是分析常见的几个错误，如果要了解详细的错误可以查看man手册。

# Dial
Dial主要实现了TCP三次握手的环节。握手环节中有很多种情况：网络不可达，服务器backlog满了，网络超时等。
## network is unreachable
会返回`connect: network is unreachable`

## connection refused
目标服务器的指定端口未被监听。
TCP层发送完第一次握手后就会收到目标主机返回的RST包，golang会返回`connect: connection refused`。
示例：
```go
func main() {
    conn, err := net.Dial("tcp", ":8080")
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer conn.Close()
}
```

对应控制台输出
```sh
dial tcp :8080: connect: connection refused
```

## connection timed out
Dial是阻塞的，如果不设置超时，协程会长时间阻塞（golang tcp超时是3分钟），这样很影响程序运行。
如果网络环境不好情况下经常有丢包发生，我们也可以手动设置超时时间来控制超时时间。
TCP会一直重传第一次握手的包，直到设置的超时时间后还没有收到第二次握手，网络状态一直是`SYN_SENT`，golang返回`i/o timeout`。还有连接时超时返回`connect: connection timed out`错误
示例：
```go
func main() {
    conn, err := net.DialTimeout("tcp", "google.com:443", 1*time.Second)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer conn.Close()
}
```

对应控制台输出
```sh
dial tcp 172.217.160.78:443: i/o timeout
```

## cannot assign requested address
无法申请端口建立socket连接。
当前机器没有可用端口哦，由系统返回该错误。
可以修改系统配置，增加可用端口范围，来缓解端口不足的问题
```text
# vi /etc/sysctl.conf
net.ipv4.ip_local_port_range = 1024     65535
```

# Read
## EOF
当前连接处于`CLOSE_WAIT`是调用`Read`会返回`EOF`

## i/o timeout
调用`Read`函数时间超过设置`SetReadDeadline`时会返回`i/o timeout`

## connection reset by peer
在`Read`函数阻塞期间收到对端发送的`RST`包时会返回`read: connection reset by peer`
向一个对端已关闭本端未关闭的连接（即本端处于`CLOSE_WAIT`）调用`Write`函数后再调用`Read`函数可以模拟这一个场景。

## use of closed network connection
对已关闭的连接进行`Read`时会返回`use of closed network connection`

## connection timed out
试图读取连接时超时

## network is down
读取一个未连接socket

# Write
## 无错误
当前连接处于对端已关闭本端未关闭（即本端处于`CLOSE_WAIT`）状态时调用`Write`函数，golang不会返回error，在TCP层面会收到`RST`包。当调用`Close`函数时，系统会标记连接为全关闭，禁止在该连接上读写，所以会返回`RST`包，如果要进入半关闭需要调用`Shutdown`函数。

## use of closed network connection
当前连接处于`FIN_WAIT_2`状态和已经完全关闭的连接调用`Write`会返回`use of closed network connection`

## broken pipe
当连接收到`RST`包后，连接已断开，此时调用`Write`会返回`write: broken pipe`

## connection timed out

# Close
## use of closed network connection
当前连接关闭多次

## socket is not connected
多次关闭socket

# 总结
1. 对**本端关闭的连接**进行`Read`、`Write`和`Close`都会返回`use of closed network connection`
2. 对**对端关闭本端未关闭的连接**进行`Write`时对端会返回`RST`包（重置连接但golang不会返回错误），进行`Read`时会返回`EOF`错误
3. 对**重置连接（收到RST包的连接）**进行`Write`会返回`write: broken pipe`错误，进行`Read`会返回`read: connection reset by peer`
4. 未在规定的时间完成`Read`和`Write`会返回`i/o timeout`错误

# 测试代码
## syscall server
```go
func socketServer() {
    fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_STREAM, syscall.IPPROTO_TCP)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer func() {
        err = syscall.Close(fd)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
    }()
    sa := &syscall.SockaddrInet4{
        Port: 8080,
        Addr: [4]byte{127, 0, 0, 1},
    }
    err = syscall.Bind(fd, sa)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    err = syscall.Listen(fd, 2)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    for {
        nfd, csa, err := syscall.Accept(fd)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
        fmt.Printf("fd %d sa %#v\n", nfd, csa)
        
        buf := make([]byte, 1024)
        n, err := syscall.Read(nfd, buf)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
        fmt.Println("read data:", string(buf[:n]))
        n, err = syscall.Write(fd, buf)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
        err = syscall.Close(nfd)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
        break
    }
}

```

## syscall client
```go
func socketClient() {
    fd, err := syscall.Socket(syscall.AF_INET, syscall.SOCK_STREAM, syscall.IPPROTO_TCP)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer func() {
        err = syscall.Close(fd)
        if err != nil {
            fmt.Println(err.Error())
            return
        }
    }()
    sa := &syscall.SockaddrInet4{
        Port: 8080,
        Addr: [4]byte{127, 0, 0, 1},
    }
    err = syscall.Connect(fd, sa)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    buf := []byte("1234567890")
    n, err := syscall.Write(fd, buf)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    fmt.Println("send data", n, string(buf))
}
```

## net server
```go
func netServer() {
    l, err := net.Listen("tcp", ":8080")
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    conn, err := l.Accept()
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    
    buf := make([]byte, 1024)
    n, err := conn.Write(buf)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    n, err = conn.Read(buf)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    fmt.Println(n)
    
    err = conn.Close()
    if err != nil {
        fmt.Println(err.Error())
        return
    }
}
```

## net client
```go
func netClient() {
    conn, err := net.Dial("tcp", "127.0.0.1:8080")
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer func() {
        err = conn.Close()
        if err != nil {
            fmt.Println(err.Error())
            return
        }
    }()

    buf := make([]byte, 1024)
    conn.SetWriteDeadline(time.Now().Add(5 * time.Second))
    n, err := conn.Write(buf)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    conn.SetReadDeadline(time.Now().Add(5 * time.Second))
    n, err = conn.Read(buf)
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    fmt.Println(string(buf[:n]))
}
```


# 参考文献
[Go语言TCP Socket编程](https://tonybai.com/2015/11/17/tcp-programming-in-golang/)
[TCP连接异常：broken pipe 和EOF](https://blog.csdn.net/lanyang123456/article/details/89288824)
