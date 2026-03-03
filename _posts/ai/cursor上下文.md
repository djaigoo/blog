---
author: djaigo
title: Cursor 上下文指南
categories:
  - ai
date: 2025-02-27 00:00:00
tags:
  - cursor
  - ai
  - golang
  - 上下文
  - 规则
  - 技能
  - MCP
---

# Cursor 上下文指南

本文介绍 Cursor 中影响 AI 行为的各类「上下文」：规则、命令、技能、子代理、语义搜索、@ 提及、MCP 与插件，帮助你更高效地使用 Cursor。

---

## 规则

**规则（Rules）** 为 AI 提供持久、可复用的指导，用于编码规范、项目约定或针对特定文件类型的模式。

### 存放位置与格式

- 规则文件放在 **`.cursor/rules/`** 目录下，扩展名为 **`.mdc`**。
- 使用 YAML frontmatter 配置作用范围。

### Frontmatter 字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `description` | string | 规则简介，在规则选择器中展示 |
| `globs` | string | 文件匹配模式，如 `**/*.ts`，仅当匹配文件被打开时应用 |
| `alwaysApply` | boolean | 为 `true` 时，每次对话都会应用 |

### 示例

**全局规则**（每次对话都生效）：

```yaml
---
description: 项目核心编码规范
alwaysApply: true
---
```

**按文件类型生效**：

```yaml
---
description: 本项目的 TypeScript 约定
globs: **/*.ts
alwaysApply: false
---
```

**Go 项目示例**：仅在对 `.go` 文件操作时应用

```yaml
---
description: Go 项目 error 处理与并发约定
globs: **/*.go
alwaysApply: false
---

# Go 约定

## Error 处理
- 使用 `errors.Is` / `errors.As` 做错误判断，不要用 `err.Error() == "xxx"` 做字符串比较。
- 业务错误用 `fmt.Errorf("xxx: %w", err)` 包装，便于上层 `errors.Unwrap`。

## 并发
- 优先用 `context.Context` 做取消与超时，避免裸 `select` 等 channel 做生命周期控制。
- 需要并发安全时优先 `sync.Mutex` 或 `sync.Map`，明确注释读写关系。
```

### 使用建议

- 单条规则尽量 **不超过 500 行**，一事一规则。
- 内容要**可执行**，并配有**具体示例**。

---

## 命令

**命令（Commands）** 是你在聊天或编辑器中触发的快捷操作，会附带固定上下文或行为模式。

常见命令包括：

- **Chat / 聊天**：打开 AI 对话，可结合当前选区、打开的文件等上下文。
- **Edit / 编辑**：在选中的代码上直接应用 AI 修改（Inline Edit）。
- **Composer**：多文件、多步骤的编辑与生成（Agent 模式）。
- **Terminal**：在终端中执行命令，AI 可读取输出并继续操作。

命令会决定「当前焦点」（例如选中的代码、当前文件、项目根目录），从而影响 AI 看到的上下文范围。

**Go 场景示例**：

- 在 `internal/service/user.go` 里选中一段 HTTP 调用的代码，用 **Edit**：AI 会围绕这段 Go 代码做修改（如加超时、重试、错误包装）。
- 用 **Composer** 说「给所有 handler 加上 request ID 中间件」：AI 会搜索 `**/*.go` 中的 gin/echo 路由注册，并批量插入中间件。
- 在 **Terminal** 里先执行 `go test ./...`，再把报错贴给 AI：AI 会结合测试失败信息与相关 `*_test.go` 做修复建议。

---

## 技能

**技能（Skills）** 是教 AI 完成特定任务的说明文档，例如：按团队标准做 Code Review、按固定格式写 commit message、查数据库 schema 等。

### 存放位置

| 类型 | 路径 | 作用范围 |
|------|------|----------|
| 个人技能 | `~/.cursor/skills/技能名/` | 所有项目 |
| 项目技能 | `.cursor/skills/技能名/` | 当前仓库，可随代码共享 |

每个技能是一个**目录**，其中必须包含 **`SKILL.md`**。

### SKILL.md 结构

```markdown
---
name: 技能名
description: 简要说明「做什么」以及「何时使用」
---

# 技能名称

## 步骤说明
清晰的步骤与约定...

## 示例
具体输入输出或示例...
```

- **name**：小写字母、数字、连字符，建议 ≤64 字符。
- **description**：要写清「做什么」和「什么时候用」，便于 AI 自动选用；用第三人称、具体场景描述。

### 使用建议

- 主文件 **SKILL.md 建议控制在 500 行以内**，详细内容放到同目录下的 `reference.md`、`examples.md` 等。
- 描述里包含**触发关键词**（如「Code Review」「commit message」「PDF」），提高被选中的概率。

**Go 技能示例**：项目内 `.cursor/skills/go-commit/SKILL.md`

```markdown
---
name: go-commit
description: 根据 git diff 生成符合 Conventional Commits 的 Go 项目 commit message。在用户要求写 commit、提交代码、或提到 commit message 时使用。
---

# Go 项目 Commit 规范

## 格式
type(scope): subject，如 feat(auth): 增加 JWT 校验中间件

## 类型
feat / fix / refactor / test / docs / chore

## 示例
- 改了 internal/handler/user.go → scope 可为 handler 或 auth
- 改了 go.mod → chore(deps): 升级 xxx 版本
```

### 技能中的 scripts 使用

技能目录下可以增加 **`scripts/`** 子目录，存放可执行脚本。AI 会按 SKILL.md 的说明去**执行**或**阅读**这些脚本，从而完成固定流程（如检查、生成、校验），而不必每次临时生成代码。

**这样做的好处**：

- **结果一致**：同一脚本在同样输入下输出可复现，便于团队统一流程。
- **省 token**：逻辑在脚本里，SKILL.md 只需写「何时跑、怎么跑」，不必把大段代码塞进上下文。
- **更可靠**：脚本可单独测试、版本管理，比 AI 现场写一长段命令更少出错。

**目录结构示例**（带 scripts 的技能）：

```
.cursor/skills/go-check/
├── SKILL.md
└── scripts/
    ├── run-checks.sh    # 执行 go vet、静态检查等
    └── list-deps.sh     # 列出当前模块依赖，供 AI 参考
```

**在 SKILL.md 里要写清**：该脚本是让 Agent **执行**（常见），还是仅**阅读**作参考。路径用相对路径，如 `scripts/xxx.sh`，不要用反斜杠（避免 Windows 风格路径）。

**Go 技能 + scripts 示例**：`.cursor/skills/go-check/SKILL.md`

```markdown
---
name: go-check
description: 对当前 Go 模块执行静态检查与测试，并根据输出给出修复建议。在用户要求检查代码、提交前校验、或说「跑一下检查」时使用。
---

# Go 检查流程

## 步骤

1. 在项目根目录执行：`bash .cursor/skills/go-check/scripts/run-checks.sh`
2. 若脚本返回非 0 或输出中有 FAIL/error，根据报错逐条修复。
3. 修复后再次执行脚本，直到通过。

## 脚本说明

- **run-checks.sh**：依次执行 `go vet ./...`、`go test -short ./...`（可选：`golangci-lint run`）。脚本会打印每步结果并返回第一个失败步骤的退出码。Agent 应**执行**该脚本并根据输出修改代码。
```

**scripts/run-checks.sh 示例**（仅作参考，实际路径以你项目为准）：

```bash
#!/usr/bin/env bash
set -e
cd "$(git rev-parse --show-toplevel)" || exit 1
echo "==> go vet ./..."
go vet ./... || exit 1
echo "==> go test -short ./..."
go test -short ./... || exit 1
echo "==> all checks passed"
```

这样，技能通过「说明 + 脚本」把「怎么检查」固定下来，AI 只需执行脚本、解读输出并改代码，无需在对话里重复写一长串命令。

---

## 子代理

**子代理（Subagents）** 是 Cursor 在复杂任务中调起的专门 Agent，在独立上下文中执行多步操作。

常见类型示例：

- **explore**：快速浏览代码库、按模式找文件、搜关键词，适合「理解项目结构」「找某类 API」。
- **generalPurpose**：通用多步任务，如调研、搜索、执行多步计划。
- **shell**：专门执行终端命令（如 git、构建、脚本）。

使用子代理时，会传入**任务描述**和可选**只读/可写**等约束；子代理完成后将结果汇总回主对话。适合「先探索再决策」或「把终端/探索交给专门 Agent」的场景。

**Go 场景示例**：

- 让 **explore** 找「所有调用 `redis.Get` 的地方」：便于统一改成带 context 的 API 或排查缓存逻辑。
- 让 **shell** 执行 `go build ./cmd/... && go test ./internal/...`：在主对话里根据构建/测试结果再决定改哪几个 `.go` 文件。

---

## 语义搜索

**语义搜索（Semantic Search）** 按「含义」在代码库中查找，而不是单纯关键词匹配。

- 适合问题如：「用户认证是在哪里实现的？」「错误是在哪一步被吞掉的？」
- 搜索时可指定**目录或文件**缩小范围，例如只搜 `backend/` 或某个组件文件。
- 结果会返回相关代码片段及其路径，便于 AI 或你快速定位逻辑。

在对话中，AI 会根据你的问题自动发起语义搜索，把检索到的代码作为上下文参与回答或修改。

**Go 项目中的典型问法**（会触发语义搜索并带回相关代码）：

- 「gin 路由是在哪里注册的？」→ 常会找到 `router.Group`、`GET`/`POST` 等。
- 「请求里的 `context.Context` 是在哪一层注入的？」→ 会找到中间件或 handler 入口。
- 「数据库连接池是在哪里初始化的？」→ 会找到 `sql.Open`、`gorm.Open` 或类似封装。
- 「这个 error 在哪里被 wrap 的？」→ 结合 `%w`、`errors.Wrap` 等用法定位。

---

## @ 提及

**@ 提及（@-mentions）** 用来显式把某类内容加入当前对话的上下文。

常用类型：

- **@ 文件**：如 `@src/utils.ts`，把该文件内容加入上下文。
- **@ 文件夹**：如 `@src/components/`，表示该目录下的文件可被引用或搜索。
- **@ Codebase**：让 AI 在整个代码库中搜索与当前问题相关的内容。
- **@ Docs**：引用官方或项目文档（若已配置）。
- **@ Web**：允许 AI 使用网络搜索获取最新信息。
- **@ Chat**：引用本对话中之前的某条消息。

使用 @ 可以避免「没打开文件所以 AI 看不到」的问题，精确控制上下文范围并节省 token。

**Go 项目中的 @ 用法示例**：

| 意图 | 示例 |
|------|------|
| 让 AI 按现有 handler 风格写新接口 | `@internal/handler/user.go` 再问「仿照这个加一个 GetUserByID」 |
| 改某包下的所有错误处理 | `@internal/service/` 再说「把这里面的 error 都改成 %w 包装」 |
| 结合依赖与入口一起看 | `@cmd/server/main.go` 和 `@go.mod`，问「启动时如何加载配置」 |
| 只让 AI 在 Go 代码里找 | 先 `@internal/` 再问「哪里用到了 redis 的 SetNX」 |

---

## MCP

**MCP（Model Context Protocol）** 让 Cursor 能调用外部服务或数据源，扩展 AI 的能力。

- **MCP 服务**：提供一组「工具」（tools），例如：查数据库、调 API、读文档、执行自定义脚本。
- 在 Cursor 中配置 MCP 服务器后，AI 在对话中可以直接调用这些工具（如地图、天气、翻译等），并把结果纳入回答。
- 配置一般在 Cursor 设置或项目/用户的 MCP 配置文件中完成，不同 MCP 提供不同的「工具」列表和参数说明。

适合需要「实时数据」「外部系统」或「固定流程工具」的场景。

---

## 插件

**插件（Extensions）** 是 Cursor（基于 VS Code）的扩展，用于增强编辑器和工作流。

- 与「上下文」直接相关的是：**语言支持、Linter、格式化、主题**等，它们会影响 AI 看到的代码高亮、诊断信息和项目结构。
- 部分插件会提供**自定义命令**或**面板**，这些命令的输入输出也可能成为你与 AI 协作时的上下文（例如运行测试、查看 Git 状态）。
- Cursor 内置的 AI 功能（Chat、Composer、Rules、Skills）与插件并存：插件改的是「编辑器能力」，Rules/Skills/MCP 改的是「AI 的上下文与行为」。

---

## Go 项目综合示例

在一个典型 Go Web 项目（如 `cmd/` + `internal/handler`、`internal/service`）里，可以这样组合使用：

1. **规则**：在 `.cursor/rules/` 下放 `go-standards.mdc`，`globs: **/*.go`，写明 error 处理、context 传递、并发约定；编辑任意 `.go` 时 AI 都会遵循。
2. **@ 提及**：改某个 handler 时输入 `@internal/handler/user.go`，再 @ 对应的 `internal/service/user.go`，让 AI 同时看到接口与实现，避免改错层。
3. **语义搜索**：直接问「JWT 是在哪一层校验的？」「数据库事务在哪里开启？」，AI 会搜代码并引用具体位置。
4. **技能**：若团队统一 commit 格式，在 `.cursor/skills/go-commit/` 里写 SKILL.md，以后说「帮我写一下这次改动的 commit」即可按规范生成。
5. **Composer + 子代理**：说「给所有调用外部 API 的地方加上 5 秒超时和重试」时，AI 可能先用 explore 找 `http.Client` 或 gRPC 调用，再在对应 `.go` 里批量加 `context.WithTimeout` 和重试逻辑。

这样，规则约束风格、@ 控制上下文、语义搜索补全理解、技能统一流程，Go 项目里的 Cursor 使用会更稳定、可复现。

---

## 小结

| 机制 | 作用 | 典型用途 |
|------|------|----------|
| **规则** | 持久、可复用的 AI 行为约束 | 编码规范、项目约定、文件级模式 |
| **命令** | 决定触发方式和焦点范围 | 聊天 / 编辑 / Composer / 终端 |
| **技能** | 教 AI 完成特定任务 | Code Review、commit 规范、领域流程 |
| **子代理** | 专门 Agent 执行多步任务 | 探索代码库、执行 Shell、多步规划 |
| **语义搜索** | 按含义检索代码 | 理解项目、定位逻辑、补全上下文 |
| **@ 提及** | 显式加入文件/文件夹/文档/网络 | 精确控制对话上下文 |
| **MCP** | 调用外部工具与服务 | 地图、天气、数据库、API 等 |
| **插件** | 扩展编辑器能力 | 语言、Lint、格式化、自定义命令 |

合理组合规则、技能、@ 提及和 MCP，可以让 Cursor 的 AI 更贴合你的项目和习惯，减少重复说明，提高回答与修改的准确度。
