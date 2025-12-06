---
author: djaigo
title: mcp协议
categories:
  - ai
date: 2025-06-20 10:05:41
tags:
  - mcp
  - ai
  - llm
  - gpt
---


# MCP
[官方文档](https://docs.modelcontextprotocol.com/) 

[github](https://github.com/modelcontextprotocol/modelcontextprotocol)
什么是MCP？

Model Control Protocol (MCP)协议

# 架构
MCP 采用客户端 - 服务器架构，其中：

* 主机是发起连接的大语言模型应用程序（如 Claude 桌面应用程序或集成开发环境）
* 客户端在主机应用程序内部与服务器保持一对一的连接
* 服务器向客户端提供上下文、工具和提示


## 传输层
传输层负责处理客户端与服务器之间的实际通信。MCP 支持多种传输机制：
* Stdio transport
  - 使用标准输入 / 输出进行通信
  - 适用于本地进程
* Streamable HTTP transport
  - 使用 HTTP，并可选择通过服务器发送事件（Server-Sent Events）进行流化
  - 使用 HTTP POST 进行客户端到服务器的消息传递

所有传输方式均使用[JSON-RPC 2.0](https://www.jsonrpc.org/specification) 来交换消息。

## 消息类型
MCP 支持以下消息类型：

* 请求消息

```ts
interface Request {
  method: string;
  params?: { ... };
}
```

* 结果消息
```ts
interface Result {
  [key: string]: unknown;
}
```

* 错误消息
```ts
interface Error {
  code: number;
  message: string;
  data?: unknown;
}
```

* 通知消息
```ts
interface Notification {
  method: string;
  params?: { ... };
}
```


# 连接生命周期
## 初始化

1. 客户端发送带有协议版本和功能的initialize请求
2. 服务器以其协议版本和功能进行响应
3. 客户端发送initialized通知作为确认
4. 正常消息交换开始

## 信息交换
初始化后，支持以下模式：

* 请求 - 响应：客户端或服务器发送请求，另一方做出响应
* 通知：任何一方发送单向消息

## 终止
任何一方都可以终止连接：

* 通过close()正常关闭
* 传输断开连接
* 错误情况

# 错误处理
MCP标准错误码

```ts
enum ErrorCode {
  // Standard JSON-RPC error codes
  ParseError = -32700,
  InvalidRequest = -32600,
  MethodNotFound = -32601,
  InvalidParams = -32602,
  InternalError = -32603,
}
```

SDK 和应用程序可以定义高于 -32000 的自定义错误代码。
错误通过以下方式传播：

* 对请求的错误响应
* 传输层的错误事件
* 协议级错误处理程序


# MCP资源
MCP支持的数据内容：
* File contents
* Database records
* API responses
* Live system data
* Screenshots and images
* Log files
* And more

每个资源都由唯一的URI标识，并且可以包含文本或二进制数据。

URI格式：`[protocol]://[host]/[path]`
例如：
* `file:///home/user/documents/report.pdf`
* `postgres://database/customers/schema`
* `screen://localhost/display1`

协议和路径结构由MCP服务器实现定义。服务器可以定义自己的自定义URI方案。

资源类型包括：
* 文本资源，由UTF-8编码的文本内容
  - Source code
  - Configuration files
  - Log files
  - JSON/XML data
  - Plain text
* 二进制资源
  - Images
  - PDFs
  - Audio files
  - Video files
  - Other non-text formats

## 访问资源
Direct resources
服务器通过`resources/list`请求公开资源列表。每个资源都包括：

```ts
{
  uri: string;           // Unique identifier for the resource
  name: string;          // Human-readable name
  description?: string;  // Optional description
  mimeType?: string;     // Optional MIME type
  size?: number;         // Optional size in bytes
}
```


Resource templates
对于动态资源，服务器可以暴露[URI templates](https://datatracker.ietf.org/doc/html/rfc6570)给客户端构建有效资源URI的URI模板：

```ts
{
  uriTemplate: string;   // URI template following RFC 6570
  name: string;          // Human-readable name for this type
  description?: string;  // Optional description
  mimeType?: string;     // Optional MIME type for all matching resources
}
```

Reading resources
要读取资源，客户端可以通过`resources/read`请求资源URI。

服务器以资源内容列表响应：
```ts
{
  contents: [
    {
      uri: string;        // The URI of the resource
      mimeType?: string;  // Optional MIME type

      // One of:
      text?: string;      // For text resources
      blob?: string;      // For binary resources (base64 encoded)
    }
  ]
}
```

> 服务器可以返回多个资源，以响应一个`resources/read`请求。例如，在读取目录时返回目录中的文件列表。


## 资源更新
MCP通过两种机制支持资源的实时更新：

List changes
当客户列表通过通知/资源/list_changed通知更改时，服务器可以通知客户端。

Content changes
客户可以订阅更新特定资源：
* 客户发送`resources/subscribe`资源URI
* 服务器在资源更改时发送`notifications/resources/updated`
* 客户可以通过`resources/read`获取最新内容
* 客户可以`resources/unsubscribe`退订



# MCP Prompt
MCP Prompt创建可重复使用的提示模板和工作流程。

提示使服务器能够定义可重复使用的提示模板和工作流程，客户端可以轻松地浮在用户和LLM上。它们提供了一种标准化和共享常见LLM交互的强大方法。

## 结构
```ts
{
  name: string;              // Unique identifier for the prompt
  description?: string;      // Human-readable description
  arguments?: [              // Optional list of arguments
    {
      name: string;          // Argument identifier
      description?: string;  // Argument description
      required?: boolean;    // Whether argument is required
    }
  ]
}
```

获取prompt，客户端可以通过发送`prompts/list`请求来发现可用的提示。
使用prompt，要使用提示，客户`prompts/get`请求

动态prompt
嵌入资源上下文
```ts
{
  "name": "analyze-project",
  "description": "Analyze project logs and code",
  "arguments": [
    {
      "name": "timeframe",
      "description": "Time period to analyze logs",
      "required": true
    },
    {
      "name": "fileUri",
      "description": "URI of code file to review",
      "required": true
    }
  ]
}

// 处理 prompts/get 请求
{
  "messages": [
    {
      "role": "user",
      "content": {
        "type": "text",
        "text": "Analyze these system logs and the code file for any issues:"
      }
    },
    {
      "role": "user",
      "content": {
        "type": "resource",
        "resource": {
          "uri": "logs://recent?timeframe=1h",
          "text": "[2024-03-14 15:32:11] ERROR: Connection timeout in network.py:127\n[2024-03-14 15:32:15] WARN: Retrying connection (attempt 2/3)\n[2024-03-14 15:32:20] ERROR: Max retries exceeded",
          "mimeType": "text/plain"
        }
      }
    },
    {
      "role": "user",
      "content": {
        "type": "resource",
        "resource": {
          "uri": "file:///path/to/code.py",
          "text": "def connect_to_service(timeout=30):\n    retries = 3\n    for attempt in range(retries):\n        try:\n            return establish_connection(timeout)\n        except TimeoutError:\n            if attempt == retries - 1:\n                raise\n            time.sleep(5)\n\ndef establish_connection(timeout):\n    # Connection implementation\n    pass",
          "mimeType": "text/x-python"
        }
      }
    }
  ]
}
```
多步workflow
```ts
const debugWorkflow = {
  name: "debug-error",
  async getMessages(error: string) {
    return [
      {
        role: "user",
        content: {
          type: "text",
          text: `Here's an error I'm seeing: ${error}`,
        },
      },
      {
        role: "assistant",
        content: {
          type: "text",
          text: "I'll help analyze this error. What have you tried so far?",
        },
      },
      {
        role: "user",
        content: {
          type: "text",
          text: "I've tried restarting the service, but the error persists.",
        },
      },
    ];
  },
};
```



# MCP Tools
MCP工具可以让LLM通过服务器执行相关操作，它使服务器能够向客户端公开可执行功能。通过工具，LLM可以与外部系统进行交互，执行计算并采取行动。

> 工具旨在由模型控制，这意味着AI模型能够自动调用它们的目的是将工具从服务器暴露到客户端（循环中的人类以授予批准）。

MCP中的工具允许服务器公开可执行的功能，这些功能可以由客户端调用并由LLM使用来执行操作。工具的关键方面包括：
* Discovery：客户可以通过发送工具/列表请求获得可用工具的列表
* Invocation：使用工具/呼叫请求调用工具，服务器执行请求的操作并返回结果
* Flexibility：工具可以从简单计算到复杂的API交互

像资源一样，工具通过唯一名称标识，可以包括描述以指导其使用情况。但是，与资源不同，工具代表可以修改状态或与外部系统交互的动态操作。

## 结构
每个工具都用以下结构来定义：
```ts
{
  name: string;          // Unique identifier for the tool
  description?: string;  // Human-readable description
  inputSchema: {         // JSON Schema for the tool's parameters
    type: "object",
    properties: { ... }  // Tool-specific parameters
  },
  annotations?: {        // Optional hints about tool behavior
    title?: string;      // Human-readable title for the tool
    readOnlyHint?: boolean;    // If true, the tool does not modify its environment
    destructiveHint?: boolean; // If true, the tool may perform destructive updates
    idempotentHint?: boolean;  // If true, repeated calls with same args have no additional effect
    openWorldHint?: boolean;   // If true, tool interacts with external entities
  }
}
```

## 发现和更新
MCP支持动态工具发现：
* 客户可以随时列出可用工具
* 当工具使用通知/工具/list_changed更改工具时，服务器可以通知客户端
* 可以在运行时添加或删除工具
* 工具定义可以更新（尽管应小心进行）


## 错误处理
工具错误应在结果对象中报告，而不是MCP协议级错误。这使LLM可以看到并有可能处理错误。当工具遇到错误时：
* 在结果中设置为true
* 在内容数组中包括错误详细信息

这种方法使LLM可以看到发生错误并有可能采取纠正措施或要求人为干预。

## 工具注释
工具注释提供了有关工具行为的其他元数据，帮助客户端了解如何呈现和管理工具。这些注释是描述工具的性质和影响的提示，但不应依靠用于安全决定。
工具注释有几个关键目的：
* 提供特定于UX的信息而不影响模型上下文
* 帮助客户适当地分类和介绍工具
* 传达有关工具潜在副作用的信息
* 协助开发直观界面以供工具批准

MCP规范定义了工具的以下注释：

| Annotation | Type | Default | Description |
| ---------- | ---- | ------- | ----------- |
| title      | string | - | 工具的用户可见名称，用于展示 |
| readOnlyHint | boolean | false | 如果为true，工具不修改其环境 |
| destructiveHint | boolean | false | 如果为true，工具可能执行破坏性更新（只有在ReadOnlyHint为false时才有意义） |
| idempotentHint | boolean | false | 如果为true，重复调用相同参数没有额外效果（只有在ReadOnlyHint为false时有意义） |
| openWorldHint | boolean | false | 如果为true，工具与外部实体交互 |

工具注释的最佳实践

* 对副作用保持准确：清楚地指出工具是否修改其环境以及这些修改是否具有破坏性。
* 使用描述性标题：提供对人类友好的标题，清楚地描述了该工具的目的。
* 正确地指出势力：仅当具有相同参数的重复调用确实没有其他效果时，将工具标记为divempotent。
* 设置适当的开放/封闭世界提示：指示工具是否与封闭的系统（例如数据库）或开放系统（例如Web）进行交互。
* 请记住注释是提示：工具文章中的所有属性都是提示，并且不能保证对工具行为的忠实描述。客户绝不应该仅根据注释做出关键性决策。


# MCP Sampling
Sampling是一个强大的MCP功能，它允许服务器通过客户端请求LLM完成，从而在保持安全性和隐私的同时实现复杂的代理行为。

Sampling流程遵循以下步骤：
* 服务器向客户端发送请求：服务器向客户端发送一个名为 `sampling/createMessage` 的请求。此请求是整个采样流程的起始点，意味着服务器发起了希望通过客户端获取大语言模型（LLM）完成内容的需求。
* 客户端审查并可修改请求：客户端收到请求后，会对其进行审查，并且拥有修改请求内容的权限。这一步骤给予客户端一定的自主性，可根据实际情况对服务器发出的请求进行调整。
* 客户端从大语言模型采样：客户端依据审查或修改后的请求，从大语言模型（LLM）中获取相应的完成内容。这里的 “采样” 指的是从大语言模型获取与请求相关的文本或其他类型数据的过程。
* 客户端审查完成内容：客户端得到大语言模型给出的完成内容后，会再次进行审查。这一步骤有助于确保完成内容符合预期，或者对内容进行必要的检查。
* 客户端将结果返回给服务器：经过审查后，客户端把最终的结果发送回服务器，至此完成整个采样流程。服务器能够基于这个返回的结果进行后续操作。

> 基于`human-in-the-loop`设计可确保用户保持对LLM看到和生成的内容的控制。

## 请求格式
```ts
{
  messages: [
    {
      role: "user" | "assistant",
      content: {
        type: "text" | "image",

        // For text:
        text?: string,

        // For images:
        data?: string,             // base64 encoded
        mimeType?: string
      }
    }
  ],
  modelPreferences?: {
    hints?: [{
      name?: string                // Suggested model name/family
    }],
    costPriority?: number,         // 0-1, importance of minimizing cost
    speedPriority?: number,        // 0-1, importance of low latency
    intelligencePriority?: number  // 0-1, importance of capabilities
  },
  systemPrompt?: string,
  includeContext?: "none" | "thisServer" | "allServers",
  temperature?: number,
  maxTokens: number,
  stopSequences?: string[],
  metadata?: Record<string, unknown>
}
```

`messages`包含对话历史记录，以发送到LLM。每条消息都有：
* `role`：“用户”或“助手”
* `content`：消息内容，可以是：
  * `text`字段的文本内容
  * `data`和`mimeType`字段表示图片内容，data是base64编码的数据


`modelPreferences`对象允许服务器指定其模型选择偏好：
* `hints`：型号名称建议的数组可以使用该建议来选择适当的型号：
  * `name`：可以匹配完整或部分模型名称的字符串（例如，“ Claude-3”，“ SONNET”）
  * 客户可以将提示映射到来自不同提供商的同等模型
  * 以优先顺序评估多个提示
* 优先级值（0-1归一化）：
  * `costPriority`：最小化成本的重要性
  * `speedPriority`：低潜伏期响应的重要性
  * `intelligencePriority`：高级模型功能的重要性


`systemPrompt`字段允许服务器请求特定的系统提示。客户端可以修改或忽略此事。

`includeContext`指定MCP包含的上下文：
* `none`，没有上下文
* `thisServer`，包括请求服务器中的上下文
* `allServers`，包括所有连接的MCP服务器的上下文


Sampling 参数用以下方式微调LLM抽样
* `temperature`：控制随机性（0.0至1.0）
* `maxTokens`：最大令牌生成
* `stopSequences`：停止生成的序列数组
* `metadata`：其他特定提供者的参数

## 响应格式
```ts
{
  model: string,  // Name of the model used
  stopReason?: "endTurn" | "stopSequence" | "maxTokens" | string,
  role: "user" | "assistant",
  content: {
    type: "text" | "image",
    text?: string,
    data?: string,
    mimeType?: string
  }
}
```

## `human-in-the-loop`

Sampling在设计时就考虑到了人工监督，具体如下：
对于提示（prompts）：
* 客户端应向用户展示提议的提示内容。比如在向大语言模型发送请求前，客户端要把准备好的提示呈现给用户看。
* 用户应能够修改或拒绝提示。例如用户觉得提示的表述不准确，就可以进行修改；如果认为提示不合适，也能直接拒绝。
* 系统提示可以被过滤或修改。比如系统给出的提示可能不符合特定场景需求，用户或客户端可以对其过滤或修改。
* 上下文包含由客户端控制。即客户端决定是否包含以及包含哪些上下文信息，像决定是不包含额外上下文，还是仅包含请求服务器的上下文，亦或是所有连接的 MCP 服务器的上下文。

对于完成结果（completions）：
* 客户端应向用户展示完成结果。也就是大语言模型给出的回复内容要展示给用户。
* 用户应能够修改或拒绝完成结果。比如用户觉得模型生成的内容不符合要求，就可以修改或者不采用这个结果。
* 客户端可以过滤或修改完成结果。比如客户端发现结果中有敏感信息，就可以进行过滤修改。
* 用户控制使用哪个模型。用户可以根据自己的需求，依据模型偏好等因素，决定使用哪个模型来生成内容。


# MCP Roots
Roots是MCP中的一个概念，它定义了服务器可以运行的边界。他们为客户提供了一种通知服务器有关相关资源及其位置的方法。

Roots是客户端建议服务器应重点关注的URI。当客户端连接到服务器时，它会声明该服务器应使用的哪个。虽然主要用于文件系统路径，但根可以是任何有效的URI，包括HTTP URL。

例如：
```ts
file:///home/user/projects/myapp
https://api.example.com/v1
```

Roots 具有几个重要作用：
* 指引作用（Guidance）：Roots 能告知服务器相关资源及其所在位置。比如在一个软件开发项目中，客户端通过 Roots 告诉服务器项目文件所在的具体路径，像 “file:///home/user/projects/myapp”，服务器就能据此找到相关资源。
* 明确性作用（Clarity）：Roots 能清晰界定哪些资源属于你的工作空间。例如，在一个包含多个项目的工作环境中，通过不同的 Roots 可以明确每个项目的资源边界，使开发者清楚知道哪些资源属于特定的工作空间。
* 组织作用（Organization）：多个 Roots 能让你同时处理不同的资源。假设一个项目既需要访问本地的代码仓库，又要调用远程的 API 接口，通过设置如 “file:///home/user/projects/frontend” 和 “https://api.example.com/v1” 这样不同的 Roots，就可以同时对这两种不同类型的资源进行操作。


Roots 的工作方式，分为客户端和服务器端两方面。

* 在客户端方面：
  * 当客户端支持 Roots 时，在连接过程中会声明其具备 Roots 相关能力。例如在与服务器建立连接时，通过特定的协议或消息表明自己能处理 Roots 相关事务。
  * 客户端会向服务器提供一系列建议的 Roots 列表。比如客户端可能会给出类似 “file:///home/user/projects/myapp” 这样的 URI 作为建议的 Root。
  * 如果支持的话，当 Roots 发生变化时，客户端会通知服务器。假设原本建议的 Root 是 “file:///home/user/projects/myapp”，若该路径发生变动，客户端就会告知服务器。

* 在服务器端方面：
  * 尽管 Roots 主要是提供信息，并非严格强制要求，但服务器应该尊重客户端提供的 Roots。也就是说，服务器会按照客户端给出的 Roots 相关信息进行后续操作。
  * 服务器会使用 Root 的统一资源标识符（URI）来定位和访问资源。例如根据 “file:///home/user/projects/myapp” 这个 URI 去找到对应的文件系统路径下的资源。
  * 服务器会优先在 Root 的边界范围内执行操作。比如有多个操作任务，与 Root 相关的操作会被优先处理。


常见的使用场景，具体如下：
* `Project directories` 即项目目录，Roots 常被用于定义项目所在的目录位置，比如指定某个项目位于 “file:///home/user/projects/myapp” 这样的文件路径下。
* `Repository locations` 指存储库位置，Roots 可用来明确存储库所在之处，例如代码仓库等。
* `API endpoints` 表示 API 端点，Roots 可用于界定 API 的访问地址，像 “https://api.example.com/v1” 这样的网址。
* `Configuration locations` 是配置位置，Roots 能够确定配置文件所在的地方。
* `Resource boundaries` 即资源边界，Roots 可以用来定义资源的范围界限，明确哪些资源属于特定的范畴。


# MCP Transports
## 消息格式
MCP使用JSON-RPC 2.0作为电线格式。该传输层负责将MCP协议消息转换为JSON-RPC格式，用于传输和转换接收到的JSON-RPC消息回到MCP协议消息。

* Requests
```ts
{
  jsonrpc: "2.0",
  id: number | string,
  method: string,
  params?: object
}
```

* Responses
```ts
{
  jsonrpc: "2.0",
  id: number | string,
  result?: object,
  error?: {
    code: number,
    message: string,
    data?: unknown
  }
}
```
​
* Notifications
```ts
{
  jsonrpc: "2.0",
  method: string,
  params?: object
}
```
​
## 传输类型
### 标准输入输出（stdio）

stdio传输可以通过标准输入和输出流进行通信。这对于本地集成和命令行工具特别有用。

使用stdio时：
* 构建命令行工具
* 实施本地集成
* 需要简单的过程通信
* 使用Shell脚本


### 流式HTTP（Streamable HTTP）
流式HTTP传输使用HTTP POST请求，用于客户对服务器通信和可选的服务器式事件（SSE）流以服务器到客户通信。

使用流http时使用：
* 构建基于Web的集成
* 需要通过http的客户端服务器通信
* 需要稳定会话
* 支持多个并发客户
* 实现可重新连接


基于流的 HTTP 传输（Streamable HTTP）的工作方式，具体如下：

1. 客户端到服务器的通信：客户端发送给服务器的每一条 JSON - RPC 消息，都会作为一个新的 HTTP POST 请求，发送到 MCP 端点。
2. 服务器的响应：服务器有两种响应方式：
  * 单个 JSON 响应：内容类型为 `application/json`。
  * SSE 流：内容类型为 `text/event-stream`，用于发送多条消息。
3. 服务器到客户端的通信：服务器可以通过以下两种方式向客户端发送请求或通知：
  * 由客户端请求发起的 SSE 流：即客户端发起请求后，服务器利用该请求对应的 SSE 流来发送信息。
  * 来自对 MCP 端点的 HTTP GET 请求的 SSE 流：服务器通过客户端对 MCP 端点的 HTTP GET 请求所对应的 SSE 流，向客户端发送数据。 例如，在代码示例中，客户端向服务器的 “/mcp” 端点发送 POST 请求，服务器根据需求选择返回单个 JSON 响应或 SSE 流；同时，服务器可以通过客户端发起的请求或客户端对 “/mcp” 的 GET 请求所对应的 SSE 流，向客户端发送数据。


流式HTTP支持状态会话，以维护多个请求的上下文：
* 会话初始化：服务器可以在初始化期间分配会话ID，记录在`Mcp-Session-Id`响应头中
* 会话持久性：客户必须使用`Mcp-Session-Id`会话ID包含在所有后续请求中
* 会话终止：可以通过发送带有会话ID的`HTTP DELETE`请求来明确终止会话


为了支持恢复断裂的连接，流式HTTP提供：
* 事件ID：服务器可以将唯一ID附加到SSE事件以进行跟踪
* 上一次活动的简历：客户可以通过发送最后一个事件ID标头恢复
* 消息重播：服务器可以从断开点重播错过的消息

这即使通过不稳定的网络连接也可以确保可靠的消息传递。

### 自定义传输
MCP使实施特定需求的自定义运输变得容易。任何运输实施都只需要符合运输接口：

您可以实施以下自定义运输：
* 自定义网络协议
* 专门的沟通渠道
* 与现有系统集成
* 性能优化