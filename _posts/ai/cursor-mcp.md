---
author: djaigo
title: Cursor 接入 MCP (Model Context Protocol) 详细指南
categories:
  - ai
  - tools
date: 2025-05-20 17:07:33
tags:
  - cursor
  - mcp
  - ai
  - 工具集成
---

# Cursor 接入 MCP (Model Context Protocol) 详细指南

MCP (Model Context Protocol) 是 Anthropic 推出的一个开放协议，允许 AI 助手安全地访问外部工具和数据源。通过 MCP，Cursor 可以连接到各种服务，如文件系统、数据库、API 等，从而扩展 AI 助手的能力。

## 什么是 MCP？

MCP 是一个标准化的协议，用于：
- **安全访问外部资源**：让 AI 助手能够安全地访问文件、数据库、API 等
- **扩展功能**：通过服务器（Servers）提供额外的工具和资源
- **标准化接口**：统一的协议规范，便于集成各种服务

## MCP 架构

```mermaid
flowchart TD
    A["Cursor<br/>(Client)"]
    B["MCP Server<br/>(工具/资源)"]
    
    A -->|MCP Protocol<br/>(JSON-RPC)| B
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
```

## 前置要求

1. **Cursor 版本**：确保使用支持 MCP 的 Cursor 版本（通常需要较新版本）
2. **Node.js**：如果使用 Node.js 编写的 MCP 服务器，需要安装 Node.js
3. **Python**：如果使用 Python 编写的 MCP 服务器，需要安装 Python

## 配置步骤

```mermaid
flowchart TD
    Start["开始配置 MCP"]
    Step1["1. 创建配置文件"]
    Step2["2. 配置 MCP 服务器"]
    Step3["3. 重启 Cursor"]
    Step4["4. 验证连接"]
    Success["配置完成"]
    
    Start --> Step1
    Step1 --> Step2
    Step2 --> Step3
    Step3 --> Step4
    Step4 --> Success
```

### 1. 创建 MCP 配置文件

在 Cursor 中，MCP 配置通常存储在配置文件中。配置文件位置：

- **macOS**: `~/Library/Application Support/Cursor/User/globalStorage/rooveterinaryinc.roo-cline/settings/cline_mcp_settings.json`
- **Windows**: `%APPDATA%\Cursor\User\globalStorage\rooveterinaryinc.roo-cline\settings\cline_mcp_settings.json`
- **Linux**: `~/.config/Cursor/User/globalStorage/rooveterinaryinc.roo-cline/settings/cline_mcp_settings.json`

### 2. 配置 MCP 服务器

创建或编辑配置文件，添加 MCP 服务器配置：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/directory"
      ]
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"
      }
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://user:password@localhost:5432/dbname"
      ]
    }
  }
}
```

### 3. 常用 MCP 服务器示例

```mermaid
mindmap
  root((MCP 服务器))
    文件系统
      访问本地文件
      读取/写入权限控制
    GitHub
      API 集成
      仓库管理
      代码访问
    数据库
      PostgreSQL
      SQLite
      MySQL
    搜索服务
      Brave Search
      网络搜索
    自定义服务器
      Node.js
      Python
```

#### 文件系统服务器

允许访问指定目录的文件：

```json
{
  "filesystem": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/Users/username/projects"
    ]
  }
}
```

#### GitHub 服务器

连接到 GitHub API：

```json
{
  "github": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-github"
    ],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
    }
  }
}
```

#### PostgreSQL 服务器

连接数据库：

```json
{
  "postgres": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-postgres",
      "postgresql://user:password@localhost:5432/mydb"
    ]
  }
}
```

#### SQLite 服务器

连接 SQLite 数据库：

```json
{
  "sqlite": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-sqlite",
      "/path/to/database.db"
    ]
  }
}
```

#### Brave Search 服务器

集成搜索功能：

```json
{
  "brave-search": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-brave-search"
    ],
    "env": {
      "BRAVE_API_KEY": "your_api_key"
    }
  }
}
```

## 创建自定义 MCP 服务器

```mermaid
flowchart TD
    A["选择语言"] --> B{Node.js 或 Python?}
    B -->|Node.js| C["安装 SDK"]
    B -->|Python| D["安装 mcp 包"]
    C --> E["创建服务器文件"]
    D --> E
    E --> F["实现工具/资源"]
    F --> G["添加到配置"]
    G --> H["重启 Cursor"]
```

### 使用 Node.js 创建

1. **初始化项目**：

```bash
mkdir my-mcp-server
cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk
```

2. **创建服务器文件** (`server.js`)：

```javascript
#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

const server = new Server(
  {
    name: 'my-custom-server',
    version: '0.1.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 列出可用工具
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'get_weather',
      description: '获取指定城市的天气信息',
      inputSchema: {
        type: 'object',
        properties: {
          city: {
            type: 'string',
            description: '城市名称',
          },
        },
        required: ['city'],
      },
    },
  ],
}));

// 处理工具调用
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === 'get_weather') {
    // 实现天气查询逻辑
    const city = args.city;
    return {
      content: [
        {
          type: 'text',
          text: `${city} 的天气是晴天，温度 25°C`,
        },
      ],
    };
  }

  throw new Error(`未知工具: ${name}`);
});

// 启动服务器
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('MCP 服务器已启动');
}

main().catch(console.error);
```

3. **添加到配置**：

```json
{
  "my-custom-server": {
    "command": "node",
    "args": [
      "/path/to/my-mcp-server/server.js"
    ]
  }
}
```

### 使用 Python 创建

1. **安装依赖**：

```bash
pip install mcp
```

2. **创建服务器文件** (`server.py`)：

```python
#!/usr/bin/env python3

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

app = Server("my-python-server")

@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="calculate",
            description="执行数学计算",
            inputSchema={
                "type": "object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": "数学表达式"
                    }
                },
                "required": ["expression"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "calculate":
        expression = arguments.get("expression", "")
        try:
            result = eval(expression)
            return [TextContent(type="text", text=str(result))]
        except Exception as e:
            return [TextContent(type="text", text=f"错误: {str(e)}")]
    
    raise ValueError(f"未知工具: {name}")

if __name__ == "__main__":
    stdio_server(app).run()
```

3. **添加到配置**：

```json
{
  "my-python-server": {
    "command": "python3",
    "args": [
      "/path/to/server.py"
    ]
  }
}
```

## 验证配置

```mermaid
sequenceDiagram
    participant U as 用户
    participant C as Cursor
    participant M as MCP Server
    
    U->>C: 重启 Cursor
    C->>M: 建立连接
    M-->>C: 连接成功
    C->>M: 列出可用工具
    M-->>C: 返回工具列表
    U->>C: 使用工具
    C->>M: 调用工具
    M-->>C: 返回结果
    C-->>U: 显示结果
```

1. **重启 Cursor**：修改配置后需要重启 Cursor
2. **检查连接**：在 Cursor 中，MCP 服务器应该自动连接
3. **测试功能**：尝试使用 MCP 提供的工具

## 常见问题

```mermaid
flowchart TD
    Problem["遇到问题"]
    Problem --> Q1{服务器无法启动?}
    Problem --> Q2{权限问题?}
    Problem --> Q3{环境变量未生效?}
    
    Q1 -->|是| S1["检查命令路径<br/>检查依赖安装<br/>查看日志"]
    Q2 -->|是| S2["检查文件权限<br/>检查路径存在<br/>检查数据库凭据"]
    Q3 -->|是| S3["检查 env 配置<br/>重启 Cursor<br/>检查变量名"]
    
    S1 --> Solution["问题解决"]
    S2 --> Solution
    S3 --> Solution
```

### 1. MCP 服务器无法启动

**问题**：服务器启动失败

**解决方案**：
- 检查命令路径是否正确
- 确保依赖已安装（如 Node.js、Python）
- 查看 Cursor 的日志文件

### 2. 权限问题

**问题**：无法访问文件或资源

**解决方案**：
- 检查文件系统权限
- 确保配置的路径存在且可访问
- 对于数据库，检查连接字符串和凭据

### 3. 环境变量未生效

**问题**：环境变量配置不生效

**解决方案**：
- 确保在配置文件的 `env` 字段中正确设置
- 重启 Cursor 使配置生效
- 检查环境变量名称是否正确

## 最佳实践

1. **安全性**：
   - 不要在配置文件中硬编码敏感信息
   - 使用环境变量存储 API 密钥和密码
   - 限制文件系统访问范围

2. **性能**：
   - 只启用需要的 MCP 服务器
   - 避免配置过多服务器导致启动缓慢

3. **维护**：
   - 定期更新 MCP 服务器版本
   - 备份配置文件
   - 使用版本控制管理自定义服务器

## 官方资源

- **MCP 规范**：https://modelcontextprotocol.io
- **官方服务器列表**：https://github.com/modelcontextprotocol/servers
- **SDK 文档**：
  - Node.js: https://github.com/modelcontextprotocol/typescript-sdk
  - Python: https://github.com/modelcontextprotocol/python-sdk

## 总结

```mermaid
graph TB
    subgraph MCP["MCP 功能"]
        F1["访问文件系统"]
        F2["连接数据库"]
        F3["调用 API"]
        F4["集成第三方服务"]
        F5["扩展 AI 助手能力"]
    end
    
    subgraph Benefits["带来的好处"]
        B1["处理复杂任务"]
        B2["访问更多资源"]
        B3["提高工作效率"]
        B4["增强 AI 能力"]
    end
    
    MCP --> Benefits
    
    style MCP fill:#e1f5ff
    style Benefits fill:#fff4e1
```

通过 MCP，Cursor 可以：
- ✅ 访问文件系统
- ✅ 连接数据库
- ✅ 调用 API
- ✅ 集成第三方服务
- ✅ 扩展 AI 助手能力

配置 MCP 后，Cursor 的功能将大大增强，能够处理更复杂的任务和访问更多资源。

