---
author: djaigo
title: Protobuf 服务定义与 gRPC 使用
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - protobuf
tags:
  - protobuf
  - grpc
  - proto3
  - 服务定义
date: 2025-02-02 11:00:00
---

在 `.proto` 中除了定义消息类型（Message），还可以定义**服务（Service）**和**RPC 方法**，再通过编译器配合 gRPC 等插件生成服务端与客户端代码。本文介绍 Protobuf 的服务定义语法，以及如何用 gRPC（以 Go 为例）实现服务端与调用端。消息与字段语法见 [Protocol Buffer](/tools/protobuf/protocol-buffer.html)。

# 服务定义

## service 与 rpc 语法

在 `.proto` 中使用 `service` 定义服务名，用 `rpc` 定义方法：每个方法指定请求与响应类型（一般为 Message）。

```proto
syntax = "proto3";

package example.hello;
option go_package = "example/hello";

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}

service Greeter {
  rpc SayHello(HelloRequest) returns (HelloReply);
}
```

- **service**：服务名会参与生成接口与类型名（如 Go 中的 `GreeterServer`、`GreeterClient`）。
- **rpc**：方法名、请求类型、响应类型；请求/响应通常为已定义的 Message，也可以是 `stream` 流式（见下）。

## RPC 的四种类型

gRPC 支持四种 RPC 形式：

| 类型 | 请求 | 响应 | 说明 |
|------|------|------|------|
| **Unary** | 单条消息 | 单条消息 | 一问一答 |
| **Server streaming** | 单条消息 | 流 | 客户端发一条，服务端返回多条 |
| **Client streaming** | 流 | 单条消息 | 客户端发多条，服务端返回一条 |
| **Bidirectional streaming** | 流 | 流 | 双向流 |

在 proto 中用 `stream` 修饰请求或响应类型即可：

```proto
service Example {
  rpc Unary(Req) returns (Resp);                    // 一元
  rpc ServerStream(Req) returns (stream Resp);       // 服务端流
  rpc ClientStream(stream Req) returns (Resp);      // 客户端流
  rpc BidiStream(stream Req) returns (stream Resp); // 双向流
}

message Req { string id = 1; }
message Resp { string data = 1; }
```

## 服务与方法选项

可以对 `service` 或单个 `rpc` 方法挂载选项（如自定义 option 或部分 gRPC 生态的 option）。Proto 内置的 `ServiceOptions`、`MethodOptions` 可扩展，例如：

```proto
import "google/protobuf/descriptor.proto";

extend google.protobuf.ServiceOptions {
  optional string my_service_option = 50006;
}
extend google.protobuf.MethodOptions {
  optional string my_method_option = 50007;
}

service MyService {
  option (my_service_option) = "value";

  rpc MyMethod(Req) returns (Resp) {
    option (my_method_option) = "method_value";
  }
}
```

生成代码时，插件可读取这些 option 做代码生成或运行时行为配置。

# 代码生成

## 安装插件（Go + gRPC）

生成 Go 的 Message 代码需要 **protoc-gen-go**，生成 gRPC 服务/客户端接口需要 **protoc-gen-go-grpc**：

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

确保 `$GOPATH/bin` 或 `$GOBIN` 在 `PATH` 中，以便 `protoc` 能找到 `protoc-gen-go` 和 `protoc-gen-go-grpc`。

## 使用 protoc 生成

假设 `.proto` 在 `./proto` 下，且文件中已有 `option go_package = "example/hello";`：

```bash
protoc -I./proto \
  --go_out=./proto --go_opt=paths=source_relative \
  --go-grpc_out=./proto --go-grpc_opt=paths=source_relative \
  ./proto/hello.proto
```

- **--go_out**：生成 `*.pb.go`（Message 与序列化）。
- **--go-grpc_out**：生成 `*_grpc.pb.go`（服务端接口与客户端实现）。
- **paths=source_relative**：生成文件与源 `.proto` 同目录；也可用 `module=xxx` 按 Go 模块路径生成。

生成后通常会得到：
- `hello.pb.go`：`HelloRequest`、`HelloReply` 等结构体及序列化方法。
- `hello_grpc.pb.go`：`GreeterServer` 接口、`GreeterClient` 类型、`RegisterGreeterServer`、`NewGreeterClient` 等。

# gRPC 使用（Go 示例）

## 服务端：实现接口并注册

gRPC 生成的服务端接口要求实现其定义的所有 RPC 方法。**推荐**在实现体中**嵌入**未实现的存根，以保持“新加 RPC 方法不破坏现有实现”的向前兼容：

```go
package main

import (
    "context"
    "log"
    "net"

    "google.golang.org/grpc"
    pb "example/hello"
)

type server struct {
    pb.UnimplementedGreeterServer  // 必须嵌入，以支持后续新增方法
}

func (s *server) SayHello(ctx context.Context, req *pb.HelloRequest) (*pb.HelloReply, error) {
    return &pb.HelloReply{Message: "Hello, " + req.GetName()}, nil
}

func main() {
    lis, err := net.Listen("tcp", ":50051")
    if err != nil {
        log.Fatal(err)
    }
    s := grpc.NewServer()
    pb.RegisterGreeterServer(s, &server{})
    log.Println("serving on :50051")
    if err := s.Serve(lis); err != nil {
        log.Fatal(err)
    }
}
```

- **UnimplementedGreeterServer**：由 `protoc-gen-go-grpc` 生成，已实现所有方法并返回 “unimplemented” 错误；业务实现只覆盖需要的方法即可。
- **RegisterGreeterServer**：将实现注册到 `grpc.Server`，供客户端调用。

## 客户端：创建连接并调用

```go
package main

import (
    "context"
    "log"
    "time"

    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    pb "example/hello"
)

func main() {
    conn, err := grpc.Dial("localhost:50051", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatal(err)
    }
    defer conn.Close()
    client := pb.NewGreeterClient(conn)

    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()
    resp, err := client.SayHello(ctx, &pb.HelloRequest{Name: "world"})
    if err != nil {
        log.Fatal(err)
    }
    log.Printf("reply: %s", resp.GetMessage())
}
```

- **grpc.Dial**：建立到服务端的连接；生产环境一般使用 `grpc.WithTransportCredentials` 配置 TLS。
- **NewGreeterClient**：由 `*_grpc.pb.go` 生成，入参为 `*grpc.ClientConn`。
- **SayHello**：对应 proto 中的一元 RPC；流式 RPC 会返回 `*grpc.ClientStream` / `*grpc.ServerStream`，需按流式 API 读写。

## 流式 RPC 简要

- **服务端流**：服务端实现的方法签名为 `func (Req) (ServerStream, error)`，在实现中通过 `stream.Send(Resp)` 多次发送。
- **客户端流**：服务端方法签名为 `func (ClientStream) (Resp, error)`，在实现中通过 `stream.Recv()` 循环接收。
- **双向流**：方法签名为 `func (BidiStream) error`，可同时 `Recv` / `Send`，通常在不同 goroutine 中处理收发。

错误与超时通过 `context` 和 `status` 包处理；Metadata 可通过 `metadata` 包在请求/响应中传递键值对。详见 [grpc-go 文档](https://pkg.go.dev/google.golang.org/grpc)。

# 小结

| 内容 | 说明 |
|------|------|
| **服务定义** | `.proto` 中 `service` + `rpc`，支持 unary 与 `stream` 四种组合 |
| **代码生成** | `protoc` + `protoc-gen-go` + `protoc-gen-go-grpc` 生成 pb.go 与 _grpc.pb.go |
| **服务端** | 实现生成接口并嵌入 `UnimplementedXxxServer`，`RegisterXxxServer` 注册 |
| **客户端** | `grpc.Dial` 建连，`NewXxxClient` 后按方法调用或使用流式 API |

Protobuf 负责消息与服务的**定义与序列化**，gRPC 负责**传输与 RPC 框架**；二者配合即可完成跨语言的服务定义与调用。更多消息类型与字段规则见 [Protocol Buffer](/tools/protobuf/protocol-buffer.html)。

# 参考文献

- [Protocol Buffers 官方文档](https://protobuf.dev/)
- [gRPC Go 文档](https://grpc.io/docs/languages/go/)
- [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc)
- [grpc-go 仓库](https://github.com/grpc/grpc-go)
