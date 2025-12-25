---
author: djaigo
title: HTTP协议
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/net.png'
categories:
  - net
tags:
  - http
  - http2
  - http3
  - 超文本传输协议
---

# HTTP协议

HTTP（HyperText Transfer Protocol，超文本传输协议）是应用层协议，用于在 Web 浏览器和 Web 服务器之间传输超文本（HTML、CSS、JavaScript 等）和其他资源。

## HTTP 的基本概念

```mermaid
graph TB
    A[HTTP协议] --> B[客户端-服务器模型]
    A --> C[请求-响应模式]
    A --> D[无状态协议]
    A --> E[应用层协议]
    
    B --> B1[客户端发起请求]
    B --> B2[服务器处理并响应]
    
    C --> C1[客户端发送HTTP请求]
    C --> C2[服务器返回HTTP响应]
    
    D --> D3[每次请求独立<br/>不保存状态]
    
    E --> E4[基于TCP/IP]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
    style D fill:#ffffcc
    style E fill:#ffccff
```

## HTTP 的特点

### 1. 无状态（Stateless）

- **定义**：服务器不会保存客户端的状态信息
- **影响**：每次请求都是独立的
- **解决方案**：使用 Cookie、Session 等技术维护状态

### 2. 无连接（Connectionless）

- **定义**：每次请求都需要建立新的连接
- **HTTP/1.0**：每个请求一个连接
- **HTTP/1.1**：支持持久连接（Keep-Alive）

### 3. 基于请求-响应

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Client->>Server: HTTP请求
    Note over Server: 处理请求
    Server-->>Client: HTTP响应
    Note over Client,Server: 连接关闭或保持
```

## HTTP 在协议栈中的位置

```mermaid
graph TB
    A[应用层<br/>HTTP/HTTPS] --> B[传输层<br/>TCP/UDP]
    B --> C[网络层<br/>IP]
    C --> D[数据链路层<br/>Ethernet]
    
    E[HTTP/1.1] --> F[TCP]
    G[HTTP/2] --> F
    H[HTTP/3] --> I[UDP + QUIC]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
    style D fill:#ffffcc
```

## HTTP 版本演进

| 版本 | 发布时间 | 主要特性 |
|------|---------|---------|
| **HTTP/0.9** | 1991 | 仅支持 GET 方法 |
| **HTTP/1.0** | 1996 | 支持多种方法、状态码、头部 |
| **HTTP/1.1** | 1997 | 持久连接、管道化、分块传输 |
| **HTTP/2** | 2015 | 多路复用、头部压缩、服务器推送 |
| **HTTP/3** | 2020 | 基于 QUIC、0-RTT、多路复用 |

# HTTP 请求和响应

## HTTP 请求格式

### 请求结构

```text
请求行
请求头部
空行
请求体（可选）
```

### 请求示例

```http
GET /index.html HTTP/1.1
Host: www.example.com
User-Agent: Mozilla/5.0
Accept: text/html,application/xhtml+xml
Accept-Language: zh-CN,zh;q=0.9
Connection: keep-alive
```

### 请求行

```mermaid
graph TB
    A[请求行] --> B[请求方法]
    A --> C[请求URI]
    A --> D[HTTP版本]
    
    B --> B1[GET<br/>POST<br/>PUT<br/>DELETE等]
    C --> C1[/index.html<br/>/api/users?id=1]
    D --> D1[HTTP/1.1<br/>HTTP/2<br/>HTTP/3]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
    style D fill:#ffffcc
```

## HTTP 响应格式

### 响应结构

```text
状态行
响应头部
空行
响应体
```

### 响应示例

```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 1234
Server: nginx/1.18.0
Date: Mon, 01 Jan 2024 12:00:00 GMT

<html>
  <body>Hello World</body>
</html>
```

### 状态行

```mermaid
graph TB
    A[状态行] --> B[HTTP版本]
    A --> C[状态码]
    A --> D[状态描述]
    
    B --> B1[HTTP/1.1]
    C --> C2[200<br/>404<br/>500等]
    D --> D3[OK<br/>Not Found<br/>Internal Server Error]
    
    style A fill:#ffcccc
    style C fill:#ccffcc
```

# HTTP 方法

## 常用 HTTP 方法

```mermaid
graph TB
    A[HTTP方法] --> B[GET]
    A --> C[POST]
    A --> D[PUT]
    A --> E[DELETE]
    A --> F[HEAD]
    A --> G[OPTIONS]
    A --> H[PATCH]
    
    B --> B1[获取资源<br/>幂等<br/>安全]
    C --> C2[创建资源<br/>非幂等]
    D --> D3[更新资源<br/>幂等]
    E --> E4[删除资源<br/>幂等]
    F --> F5[获取头部<br/>不返回 body]
    G --> G6[查询支持的方法]
    H --> H7[部分更新<br/>非幂等]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
    style D fill:#ffffcc
    style E fill:#ffccff
```

## 方法详解

### 1. GET

- **用途**：获取资源
- **特点**：幂等、安全、可缓存
- **请求体**：无
- **示例**：`GET /api/users?id=1`

### 2. POST

- **用途**：创建资源或提交数据
- **特点**：非幂等、不安全、不可缓存
- **请求体**：有
- **示例**：`POST /api/users`（创建用户）

### 3. PUT

- **用途**：完整更新资源
- **特点**：幂等、不安全、不可缓存
- **请求体**：有（完整资源）
- **示例**：`PUT /api/users/1`（更新用户）

### 4. DELETE

- **用途**：删除资源
- **特点**：幂等、不安全、不可缓存
- **请求体**：通常无
- **示例**：`DELETE /api/users/1`

### 5. HEAD

- **用途**：获取响应头，不返回响应体
- **特点**：幂等、安全、可缓存
- **用途**：检查资源是否存在、获取元数据

### 6. OPTIONS

- **用途**：查询服务器支持的方法
- **特点**：幂等、安全
- **用途**：CORS 预检请求

### 7. PATCH

- **用途**：部分更新资源
- **特点**：非幂等、不安全
- **请求体**：有（部分资源）
- **示例**：`PATCH /api/users/1`（更新用户部分字段）

## 方法对比表

| 方法 | 幂等性 | 安全性 | 可缓存 | 请求体 |
|------|--------|--------|--------|--------|
| **GET** | 是 | 是 | 是 | 否 |
| **POST** | 否 | 否 | 否 | 是 |
| **PUT** | 是 | 否 | 否 | 是 |
| **DELETE** | 是 | 否 | 否 | 否 |
| **HEAD** | 是 | 是 | 是 | 否 |
| **OPTIONS** | 是 | 是 | 是 | 否 |
| **PATCH** | 否 | 否 | 否 | 是 |

# HTTP 状态码

## 状态码分类

```mermaid
graph TB
    A[HTTP状态码] --> B[1xx 信息性]
    A --> C[2xx 成功]
    A --> D[3xx 重定向]
    A --> E[4xx 客户端错误]
    A --> F[5xx 服务器错误]
    
    B --> B1[100 Continue<br/>101 Switching Protocols]
    C --> C2[200 OK<br/>201 Created<br/>204 No Content]
    D --> D3[301 Moved Permanently<br/>302 Found<br/>304 Not Modified]
    E --> E4[400 Bad Request<br/>401 Unauthorized<br/>404 Not Found]
    F --> F5[500 Internal Server Error<br/>502 Bad Gateway<br/>503 Service Unavailable]
    
    style A fill:#ffcccc
    style C fill:#ccffcc
    style E fill:#ffcccc
    style F fill:#ffcccc
```

## 常用状态码

### 2xx 成功

| 状态码 | 说明 | 使用场景 |
|--------|------|---------|
| **200 OK** | 请求成功 | 标准成功响应 |
| **201 Created** | 资源已创建 | POST 创建资源成功 |
| **204 No Content** | 无内容 | DELETE 成功，无需返回内容 |

### 3xx 重定向

| 状态码 | 说明 | 使用场景 |
|--------|------|---------|
| **301 Moved Permanently** | 永久重定向 | 网站迁移 |
| **302 Found** | 临时重定向 | 临时跳转 |
| **304 Not Modified** | 未修改 | 缓存有效 |

### 4xx 客户端错误

| 状态码 | 说明 | 使用场景 |
|--------|------|---------|
| **400 Bad Request** | 请求错误 | 请求格式错误 |
| **401 Unauthorized** | 未授权 | 需要认证 |
| **403 Forbidden** | 禁止访问 | 无权限 |
| **404 Not Found** | 未找到 | 资源不存在 |
| **405 Method Not Allowed** | 方法不允许 | 不支持的方法 |

### 5xx 服务器错误

| 状态码 | 说明 | 使用场景 |
|--------|------|---------|
| **500 Internal Server Error** | 服务器错误 | 服务器内部错误 |
| **502 Bad Gateway** | 网关错误 | 网关或代理错误 |
| **503 Service Unavailable** | 服务不可用 | 服务器过载或维护 |

# HTTP 头部

## 请求头部

### 常用请求头

```mermaid
graph TB
    A[请求头部] --> B[Host]
    A --> C[User-Agent]
    A --> D[Accept]
    A --> E[Content-Type]
    A --> F[Authorization]
    A --> G[Cookie]
    A --> H[Connection]
    
    B --> B1[指定服务器域名]
    C --> C2[客户端信息]
    D --> D3[接受的内容类型]
    E --> E4[请求体类型]
    F --> F5[认证信息]
    G --> G6[Cookie数据]
    H --> H7[连接控制]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
```

### 请求头示例

```http
GET /api/users HTTP/1.1
Host: api.example.com
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
Accept: application/json
Accept-Language: zh-CN,zh;q=0.9,en;q=0.8
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Cookie: session_id=abc123; user_id=456
```

## 响应头部

### 常用响应头

```mermaid
graph TB
    A[响应头部] --> B[Content-Type]
    A --> C[Content-Length]
    A --> D[Set-Cookie]
    A --> E[Cache-Control]
    A --> F[Location]
    A --> G[Server]
    A --> H[Date]
    
    B --> B1[响应体类型]
    C --> C2[响应体长度]
    D --> D3[设置Cookie]
    E --> E4[缓存控制]
    F --> F5[重定向地址]
    G --> G6[服务器信息]
    H --> H7[响应时间]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
```

### 响应头示例

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 1234
Cache-Control: max-age=3600
Set-Cookie: session_id=abc123; Path=/; HttpOnly
Server: nginx/1.18.0
Date: Mon, 01 Jan 2024 12:00:00 GMT
```

## 重要头部详解

### 1. Content-Type

- **用途**：指定请求/响应体的媒体类型
- **常见值**：
  - `text/html`：HTML 文档
  - `application/json`：JSON 数据
  - `application/xml`：XML 数据
  - `multipart/form-data`：表单数据

### 2. Cache-Control

- **用途**：控制缓存行为
- **常见值**：
  - `no-cache`：不缓存
  - `max-age=3600`：缓存 3600 秒
  - `private`：仅客户端缓存
  - `public`：可被代理缓存

### 3. Authorization

- **用途**：携带认证信息
- **常见格式**：
  - `Bearer <token>`：JWT Token
  - `Basic <credentials>`：基本认证
  - `Digest <credentials>`：摘要认证

# HTTP/1.1 特性

## 持久连接（Keep-Alive）

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Note over Client,Server: HTTP/1.0: 每个请求一个连接
    Client->>Server: 请求1
    Server-->>Client: 响应1
    Note over Client,Server: 连接关闭
    
    Client->>Server: 请求2
    Server-->>Client: 响应2
    Note over Client,Server: 连接关闭
    
    Note over Client,Server: HTTP/1.1: 持久连接
    Client->>Server: 请求1
    Server-->>Client: 响应1
    Note over Client,Server: 连接保持
    Client->>Server: 请求2
    Server-->>Client: 响应2
    Client->>Server: 请求3
    Server-->>Client: 响应3
    Note over Client,Server: 连接关闭
```

**优势**：
- 减少连接建立和关闭的开销
- 提高性能
- 使用 `Connection: keep-alive` 头部

## 管道化（Pipelining）

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Note over Client,Server: 无管道化
    Client->>Server: 请求1
    Server-->>Client: 响应1
    Client->>Server: 请求2
    Server-->>Client: 响应2
    
    Note over Client,Server: 管道化
    Client->>Server: 请求1
    Client->>Server: 请求2
    Client->>Server: 请求3
    Server-->>Client: 响应1
    Server-->>Client: 响应2
    Server-->>Client: 响应3
```

**特点**：
- 客户端可以发送多个请求而不等待响应
- 服务器必须按顺序返回响应
- 实际使用较少（存在队头阻塞问题）

## 分块传输编码（Chunked Transfer Encoding）

```mermaid
graph TB
    A[分块传输] --> B[服务器]
    B --> C[分块1: 1000字节]
    B --> D[分块2: 2000字节]
    B --> E[分块3: 0字节<br/>结束标记]
    
    C --> F[客户端]
    D --> F
    E --> F
    F --> G[组装完整响应]
    
    style A fill:#ffcccc
    style G fill:#ccffcc
```

**用途**：
- 传输大小未知的内容
- 流式传输
- 使用 `Transfer-Encoding: chunked` 头部

## Host 头部

- **用途**：指定服务器域名
- **重要性**：支持虚拟主机（一个 IP 多个域名）
- **示例**：`Host: www.example.com`

# HTTP/2 协议

## HTTP/2 概述

HTTP/2 是 HTTP/1.1 的升级版本，于 2015 年发布，主要目标是提高性能。

## HTTP/2 核心特性

```mermaid
graph TB
    A[HTTP/2特性] --> B[多路复用]
    A --> C[头部压缩]
    A --> D[服务器推送]
    A --> E[二进制分帧]
    A --> F[流优先级]
    
    B --> B1[单连接多请求<br/>解决队头阻塞]
    C --> C2[HPACK压缩<br/>减少头部大小]
    D --> D3[主动推送资源]
    E --> E4[二进制协议<br/>更高效]
    F --> F5[请求优先级控制]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccffcc
    style D fill:#ccffcc
```

## 多路复用（Multiplexing）

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Note over Client,Server: HTTP/1.1: 顺序请求
    Client->>Server: 请求1
    Server-->>Client: 响应1
    Client->>Server: 请求2
    Server-->>Client: 响应2
    
    Note over Client,Server: HTTP/2: 多路复用
    par 并行请求
        Client->>Server: 请求1 (流1)
        Client->>Server: 请求2 (流2)
        Client->>Server: 请求3 (流3)
    end
    par 并行响应
        Server-->>Client: 响应2 (流2)
        Server-->>Client: 响应1 (流1)
        Server-->>Client: 响应3 (流3)
    end
```

**优势**：
- 单连接处理多个请求
- 解决 HTTP/1.1 的队头阻塞问题
- 提高资源利用率

## 头部压缩（Header Compression）

```mermaid
graph TB
    A[HTTP/1.1头部] --> B[重复头部字段]
    B --> C[每次传输完整头部]
    C --> D[头部大小: ~500-800字节]
    
    E[HTTP/2头部] --> F[HPACK压缩]
    F --> G[静态表<br/>动态表]
    G --> H[头部大小: ~20-30字节]
    
    style A fill:#ffcccc
    style D fill:#ffcccc
    style E fill:#ccffcc
    style H fill:#ccffcc
```

**HPACK 压缩**：
- **静态表**：预定义的常用头部
- **动态表**：连接期间动态添加的头部
- **压缩效果**：减少 80-90% 的头部大小

## 服务器推送（Server Push）

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Client->>Server: 请求 HTML
    Server-->>Client: HTML响应
    Note over Server: 主动推送相关资源
    Server-->>Client: 推送 CSS
    Server-->>Client: 推送 JavaScript
    Server-->>Client: 推送图片
    
    Note over Client: 客户端可以选择接受或拒绝推送
```

**优势**：
- 服务器主动推送资源
- 减少往返次数
- 提高页面加载速度

**注意**：
- 客户端可以拒绝推送
- 需要合理使用，避免浪费带宽

## 二进制分帧（Binary Framing）

```mermaid
graph TB
    A[HTTP/2帧] --> B[帧头<br/>9字节]
    A --> C[帧负载<br/>可变长度]
    
    B --> B1[长度: 24位]
    B --> B2[类型: 8位]
    B --> B3[标志: 8位]
    B --> B4[流标识: 31位]
    
    C --> C5[DATA帧]
    C --> C6[HEADERS帧]
    C --> C7[SETTINGS帧]
    C --> C8[PUSH_PROMISE帧]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
```

**帧类型**：
- **DATA**：数据帧
- **HEADERS**：头部帧
- **SETTINGS**：设置帧
- **PUSH_PROMISE**：推送承诺帧
- **RST_STREAM**：流重置帧
- **PING**：心跳帧

## HTTP/2 升级

### 通过 ALPN 升级

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Client->>Server: TLS握手<br/>ALPN: h2
    Server->>Server: 支持HTTP/2
    Server-->>Client: 选择h2协议
    Note over Client,Server: 使用HTTP/2通信
```

### 通过 HTTP Upgrade

```http
GET / HTTP/1.1
Host: www.example.com
Connection: Upgrade, HTTP2-Settings
Upgrade: h2c
HTTP2-Settings: <base64url encoding of HTTP/2 SETTINGS payload>
```

## HTTP/2 限制

- **队头阻塞**：虽然解决了请求级别的队头阻塞，但 TCP 层面仍有队头阻塞
- **服务器推送**：实际使用较少，浏览器支持有限
- **连接迁移**：不支持连接迁移（IP 变化需要重新连接）

# HTTP/3 协议

## HTTP/3 概述

HTTP/3 是 HTTP/2 的下一代协议，于 2020 年发布，基于 QUIC（Quick UDP Internet Connections）协议。

## HTTP/3 核心特性

```mermaid
graph TB
    A[HTTP/3特性] --> B[基于UDP]
    A --> C[QUIC协议]
    A --> D[0-RTT连接]
    A --> E[多路复用]
    A --> F[连接迁移]
    A --> G[改进的拥塞控制]
    
    B --> B1[避免TCP队头阻塞]
    C --> C2[内置加密<br/>TLS 1.3]
    D --> D3[快速建立连接]
    E --> E4[流级别多路复用]
    F --> F5[IP变化保持连接]
    G --> G6[更好的网络适应性]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccffcc
    style D fill:#ccffcc
    style E fill:#ccffcc
    style F fill:#ccffcc
```

## QUIC 协议

```mermaid
graph TB
    A[QUIC协议] --> B[传输层]
    A --> C[应用层]
    
    B --> D[UDP传输]
    B --> E[可靠传输]
    B --> F[拥塞控制]
    
    C --> G[TLS 1.3加密]
    C --> H[HTTP/3]
    C --> I[多路复用]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccccff
```

**QUIC 特点**：
- 基于 UDP，避免 TCP 队头阻塞
- 内置 TLS 1.3 加密
- 支持连接迁移
- 改进的拥塞控制

## 0-RTT 连接

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Note over Client,Server: 首次连接
    Client->>Server: Client Hello
    Server->>Server: 生成配置
    Server-->>Client: Server Hello + Config
    Client->>Server: 请求数据
    Server-->>Client: 响应数据
    
    Note over Client,Server: 后续连接 (0-RTT)
    Client->>Server: Client Hello + 请求数据
    Server-->>Client: 响应数据
    Note over Client,Server: 无需等待握手完成
```

**优势**：
- 首次连接后，后续连接可以立即发送数据
- 减少延迟
- 提高用户体验

## 连接迁移

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Note over Client,Server: 连接ID: CID1, IP: 192.168.1.1
    Client->>Server: 请求1
    Server-->>Client: 响应1
    
    Note over Client: IP变化: 192.168.1.2
    Note over Client,Server: HTTP/2: 需要重新连接
    Note over Client,Server: HTTP/3: 保持连接
    Client->>Server: 请求2 (新IP, 相同CID)
    Server-->>Client: 响应2
```

**优势**：
- IP 地址变化时保持连接
- 移动网络切换时不断线
- 提高连接稳定性

## 流级别多路复用

```mermaid
graph TB
    A[HTTP/3流] --> B[流1]
    A --> C[流2]
    A --> D[流3]
    
    B --> E[独立传输]
    C --> E
    D --> E
    
    E --> F[无队头阻塞]
    F --> G[流1阻塞不影响流2]
    
    style A fill:#ffcccc
    style F fill:#ccffcc
```

**优势**：
- 流级别的多路复用
- 完全解决队头阻塞问题
- 更好的性能

## HTTP/3 升级

### 通过 Alt-Svc 头部

```http
HTTP/2 200 OK
Alt-Svc: h3=":443"; ma=86400
```

客户端收到后，后续请求可以使用 HTTP/3。

### 直接连接

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant Server as 服务器
    
    Client->>Server: QUIC连接请求
    Server->>Server: 支持HTTP/3
    Server-->>Client: QUIC连接建立
    Note over Client,Server: 使用HTTP/3通信
```

# HTTP 版本对比

## 特性对比表

| 特性 | HTTP/1.1 | HTTP/2 | HTTP/3 |
|------|---------|--------|--------|
| **传输协议** | TCP | TCP | UDP + QUIC |
| **多路复用** | 否 | 是（请求级） | 是（流级） |
| **头部压缩** | 否 | HPACK | QPACK |
| **服务器推送** | 否 | 是 | 是 |
| **二进制协议** | 否 | 是 | 是 |
| **0-RTT** | 否 | 否 | 是 |
| **连接迁移** | 否 | 否 | 是 |
| **队头阻塞** | 是 | TCP 层面有 | 无 |

## 性能对比

```mermaid
graph TB
    A[性能指标] --> B[HTTP/1.1]
    A --> C[HTTP/2]
    A --> D[HTTP/3]
    
    B --> B1[延迟: 高<br/>吞吐: 低<br/>队头阻塞: 严重]
    C --> C2[延迟: 中<br/>吞吐: 中<br/>队头阻塞: TCP层面]
    D --> D3[延迟: 低<br/>吞吐: 高<br/>队头阻塞: 无]
    
    style B fill:#ffcccc
    style C fill:#ffffcc
    style D fill:#ccffcc
```

## 选择建议

```mermaid
flowchart TD
    A[选择HTTP版本] --> B{需要HTTPS?}
    B -->|否| C[HTTP/1.1]
    B -->|是| D{支持HTTP/3?}
    D -->|是| E[HTTP/3<br/>最佳性能]
    D -->|否| F{支持HTTP/2?}
    F -->|是| G[HTTP/2<br/>良好性能]
    F -->|否| H[HTTP/1.1<br/>基础支持]
    
    style A fill:#ffcccc
    style E fill:#ccffcc
    style G fill:#ccffcc
    style C fill:#ffcccc
```

# HTTP 最佳实践

## 1. 使用 HTTPS

```mermaid
graph TB
    A[HTTP] --> B[明文传输]
    B --> C[安全风险]
    
    D[HTTPS] --> E[加密传输]
    E --> F[安全可靠]
    
    style A fill:#ffcccc
    style C fill:#ffcccc
    style D fill:#ccffcc
    style F fill:#ccffcc
```

**建议**：
- 所有 Web 应用使用 HTTPS
- 使用有效的 SSL/TLS 证书
- 配置 HSTS（HTTP Strict Transport Security）

## 2. 合理使用缓存

```mermaid
graph TB
    A[缓存策略] --> B[静态资源]
    A --> C[动态内容]
    
    B --> D[长期缓存<br/>max-age=31536000]
    C --> E[短期缓存<br/>max-age=3600]
    C --> F[不缓存<br/>no-cache]
    
    style A fill:#ffcccc
    style D fill:#ccffcc
    style E fill:#ccffcc
```

**建议**：
- 静态资源使用长期缓存
- 动态内容使用短期缓存或 ETag
- 合理设置 Cache-Control 头部

## 3. 压缩响应

```mermaid
graph TB
    A[响应压缩] --> B[Gzip]
    A --> C[Brotli]
    
    B --> D[兼容性好<br/>压缩率中等]
    C --> E[压缩率高<br/>现代浏览器支持]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccffcc
```

**建议**：
- 启用 Gzip 或 Brotli 压缩
- 压缩文本资源（HTML、CSS、JavaScript）
- 不压缩已压缩的资源（图片、视频）

## 4. 使用 HTTP/2 或 HTTP/3

**建议**：
- 优先使用 HTTP/3（如果支持）
- 其次使用 HTTP/2
- 提供降级到 HTTP/1.1 的兼容性

## 5. 优化请求

```mermaid
graph TB
    A[请求优化] --> B[减少请求数量]
    A --> C[减少请求大小]
    A --> D[使用CDN]
    
    B --> B1[合并资源<br/>内联小资源]
    C --> C2[压缩资源<br/>移除无用代码]
    D --> D3[就近访问<br/>减少延迟]
    
    style A fill:#ffcccc
    style B fill:#ccffcc
    style C fill:#ccffcc
    style D fill:#ccffcc
```

# HTTP 常见问题

## 1. 队头阻塞（Head-of-Line Blocking）

**问题**：HTTP/1.1 中，如果第一个请求响应慢，后续请求会被阻塞。

**解决方案**：
- 使用 HTTP/2 多路复用
- 使用 HTTP/3 流级别多路复用
- 使用多个域名（域名分片）

## 2. 连接数限制

**问题**：浏览器对同一域名有连接数限制（通常 6 个）。

**解决方案**：
- 使用 HTTP/2（单连接多请求）
- 使用域名分片
- 使用 CDN

## 3. 缓存问题

**问题**：缓存策略不当导致内容不更新或浪费带宽。

**解决方案**：
- 使用版本号或哈希值
- 合理设置 Cache-Control
- 使用 ETag 和 Last-Modified

## 4. CORS 跨域问题

**问题**：浏览器同源策略限制跨域请求。

**解决方案**：
- 使用 CORS 头部
- 使用 JSONP（已过时）
- 使用代理服务器

# 总结

HTTP 协议是 Web 的基础协议，经历了多个版本的演进：

## 核心特点

- **无状态**：每次请求独立
- **请求-响应模式**：客户端请求，服务器响应
- **应用层协议**：基于 TCP/IP

## 版本演进

- **HTTP/1.1**：持久连接、管道化
- **HTTP/2**：多路复用、头部压缩、服务器推送
- **HTTP/3**：基于 QUIC、0-RTT、连接迁移

## 最佳实践

- 使用 HTTPS
- 合理使用缓存
- 启用压缩
- 使用 HTTP/2 或 HTTP/3
- 优化请求

理解 HTTP 协议有助于：
- 优化 Web 性能
- 解决网络问题
- 设计 RESTful API
- 理解 Web 工作原理

# 参考文献

- [RFC 7230 - HTTP/1.1 Message Syntax and Routing](https://tools.ietf.org/html/rfc7230)
- [RFC 7540 - HTTP/2](https://tools.ietf.org/html/rfc7540)
- [RFC 9114 - HTTP/3](https://tools.ietf.org/html/rfc9114)
- 《HTTP权威指南》
