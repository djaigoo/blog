---
author: djaigo
title: Go 错误处理详解
tags:
categories:
  - golang
---

# Go 错误处理详解

Go 语言的错误处理是其设计哲学的重要组成部分。与其他语言使用异常机制不同，Go 采用显式的错误返回值来处理错误，这使得错误处理更加清晰和可控。

## 目录

- [error 接口的定义](#error-接口的定义)
- [错误创建](#错误创建)
- [错误包装](#错误包装)
- [错误检查](#错误检查)
- [自定义错误类型](#自定义错误类型)
- [panic vs error 的选择](#panic-vs-error-的选择)
- [错误处理模式](#错误处理模式)
- [错误处理最佳实践](#错误处理最佳实践)
- [错误处理在项目中的应用](#错误处理在项目中的应用)

# error 接口的定义

## 接口定义

`error` 是 Go 语言内置的接口类型，定义非常简单：

```go
type error interface {
    Error() string
}
```

任何实现了 `Error() string` 方法的类型都可以作为错误类型使用。

## 接口特点

1. **简单性**：只有一个方法，实现简单
2. **显式性**：错误必须显式返回和处理
3. **可组合性**：可以与其他类型组合使用
4. **可扩展性**：可以自定义错误类型

## 空错误

`nil` 表示没有错误，这是 Go 语言中表示"成功"的惯用法：

```go
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil  // nil 表示成功
}
```

# 错误创建

## errors.New

`errors.New` 是最简单的错误创建方式，用于创建简单的错误消息。

```go
package main

import (
    "errors"
    "fmt"
)

func main() {
    err := errors.New("something went wrong")
    fmt.Println(err)  // 输出: something went wrong
}
```

### 特点

- 创建简单的字符串错误
- 每次调用都创建新的错误实例
- 适合简单的错误场景

## fmt.Errorf

`fmt.Errorf` 用于创建格式化的错误消息，类似于 `fmt.Printf`。

```go
package main

import (
    "fmt"
)

func main() {
    name := "Alice"
    age := -1
    
    err := fmt.Errorf("invalid age %d for user %s", age, name)
    fmt.Println(err)  // 输出: invalid age -1 for user Alice
}
```

### 格式化选项

```go
// 基本格式化
err := fmt.Errorf("user %s not found", username)

// 数字格式化
err := fmt.Errorf("invalid port: %d", port)

// 多参数格式化
err := fmt.Errorf("failed to connect to %s:%d: %v", host, port, cause)
```

## 错误创建对比

| 方法 | 适用场景 | 特点 |
|------|---------|------|
| `errors.New` | 简单错误消息 | 快速、轻量 |
| `fmt.Errorf` | 需要格式化的错误 | 灵活、可读性强 |

# 错误包装

错误包装是 Go 1.13 引入的重要特性，允许在错误传播过程中添加上下文信息，同时保持原始错误的可访问性。

## fmt.Errorf with %w

`%w` 动词用于包装错误，保留原始错误信息。

```go
package main

import (
    "errors"
    "fmt"
)

func readFile(filename string) error {
    // 模拟文件读取错误
    err := errors.New("file not found")
    // 包装错误，添加上下文
    return fmt.Errorf("failed to read file %s: %w", filename, err)
}

func main() {
    err := readFile("config.json")
    fmt.Println(err)  // 输出: failed to read file config.json: file not found
    
    // 检查原始错误
    if errors.Is(err, errors.New("file not found")) {
        fmt.Println("原始错误是: file not found")
    }
}
```

### 错误链

错误包装形成错误链，可以通过 `errors.Unwrap` 获取上一级错误：

```go
package main

import (
    "errors"
    "fmt"
)

func main() {
    originalErr := errors.New("original error")
    wrappedErr1 := fmt.Errorf("level 1: %w", originalErr)
    wrappedErr2 := fmt.Errorf("level 2: %w", wrappedErr1)
    
    fmt.Println(wrappedErr2)  // 输出: level 2: level 1: original error
    
    // 解包错误
    unwrapped := errors.Unwrap(wrappedErr2)
    fmt.Println(unwrapped)  // 输出: level 1: original error
}
```

## errors.Wrap（第三方库）

虽然标准库没有 `errors.Wrap`，但 `pkg/errors` 等第三方库提供了类似功能：

```go
import "github.com/pkg/errors"

func readConfig() error {
    err := readFile("config.json")
    if err != nil {
        return errors.Wrap(err, "failed to read config")
    }
    return nil
}
```

**注意**：Go 1.13+ 推荐使用 `fmt.Errorf` 配合 `%w` 进行错误包装。

## 包装 vs 不包装

```go
// ❌ 不推荐：丢失原始错误信息
func badExample(err error) error {
    return fmt.Errorf("operation failed: %v", err)  // 使用 %v 会丢失错误链
}

// ✅ 推荐：保留错误链
func goodExample(err error) error {
    return fmt.Errorf("operation failed: %w", err)  // 使用 %w 保留错误链
}
```

# 错误检查

## errors.Is

`errors.Is` 用于检查错误链中是否包含指定的错误。

```go
package main

import (
    "errors"
    "fmt"
    "os"
)

func main() {
    _, err := os.Open("nonexistent.txt")
    
    // 检查是否是文件不存在错误
    if errors.Is(err, os.ErrNotExist) {
        fmt.Println("文件不存在")
    }
    
    // 检查自定义错误
    targetErr := errors.New("custom error")
    wrappedErr := fmt.Errorf("wrapped: %w", targetErr)
    
    if errors.Is(wrappedErr, targetErr) {
        fmt.Println("找到了目标错误")
    }
}
```

### 工作原理

`errors.Is` 会沿着错误链向上查找，直到找到匹配的错误或到达链的末尾：

```go
func example() {
    originalErr := errors.New("not found")
    err1 := fmt.Errorf("level 1: %w", originalErr)
    err2 := fmt.Errorf("level 2: %w", err1)
    
    // 即使错误被多层包装，errors.Is 也能找到
    if errors.Is(err2, originalErr) {
        fmt.Println("找到了原始错误")
    }
}
```

## errors.As

`errors.As` 用于将错误转换为特定的错误类型，类似于类型断言。

```go
package main

import (
    "errors"
    "fmt"
    "os"
)

func main() {
    _, err := os.Open("nonexistent.txt")
    
    // 使用 errors.As 检查并提取 PathError
    var pathErr *os.PathError
    if errors.As(err, &pathErr) {
        fmt.Printf("操作: %s, 路径: %s, 错误: %v\n", 
            pathErr.Op, pathErr.Path, pathErr.Err)
    }
}
```

### 自定义错误类型检查

```go
package main

import (
    "errors"
    "fmt"
)

// 自定义错误类型
type NotFoundError struct {
    Resource string
    ID       string
}

func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s with id %s not found", e.Resource, e.ID)
}

func findUser(id string) error {
    // 模拟未找到
    return &NotFoundError{Resource: "user", ID: id}
}

func main() {
    err := findUser("123")
    
    // 使用 errors.As 检查并提取自定义错误
    var notFoundErr *NotFoundError
    if errors.As(err, &notFoundErr) {
        fmt.Printf("资源: %s, ID: %s\n", notFoundErr.Resource, notFoundErr.ID)
    }
}
```

### errors.Is vs errors.As

| 方法 | 用途 | 返回值 | 适用场景 |
|------|------|--------|---------|
| `errors.Is` | 检查错误是否匹配 | bool | 检查特定的错误值 |
| `errors.As` | 提取错误类型 | bool + 类型转换 | 需要访问错误的具体字段 |

## errors.Unwrap

`errors.Unwrap` 用于获取被包装的原始错误。

```go
package main

import (
    "errors"
    "fmt"
)

func main() {
    originalErr := errors.New("original")
    wrappedErr := fmt.Errorf("wrapped: %w", originalErr)
    
    unwrapped := errors.Unwrap(wrappedErr)
    fmt.Println(unwrapped)  // 输出: original
}
```

# 自定义错误类型

## 简单错误类型

```go
package main

import "fmt"

// 自定义错误类型
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %s: %s", e.Field, e.Message)
}

func validateUser(name string, age int) error {
    if name == "" {
        return &ValidationError{Field: "name", Message: "cannot be empty"}
    }
    if age < 0 {
        return &ValidationError{Field: "age", Message: "cannot be negative"}
    }
    return nil
}

func main() {
    err := validateUser("", -1)
    if err != nil {
        fmt.Println(err)
    }
}
```

## 带错误码的错误类型

```go
package main

import "fmt"

// 错误码类型
type ErrorCode int

const (
    ErrCodeNotFound ErrorCode = iota + 1
    ErrCodeInvalidInput
    ErrCodePermissionDenied
    ErrCodeInternal
)

// 带错误码的错误类型
type AppError struct {
    Code    ErrorCode
    Message string
    Cause   error
}

func (e *AppError) Error() string {
    if e.Cause != nil {
        return fmt.Sprintf("[%d] %s: %v", e.Code, e.Message, e.Cause)
    }
    return fmt.Sprintf("[%d] %s", e.Code, e.Message)
}

func (e *AppError) Unwrap() error {
    return e.Cause
}

func findUser(id string) error {
    // 模拟未找到
    return &AppError{
        Code:    ErrCodeNotFound,
        Message: "user not found",
        Cause:   fmt.Errorf("user with id %s does not exist", id),
    }
}

func main() {
    err := findUser("123")
    fmt.Println(err)
    
    // 检查错误码
    var appErr *AppError
    if errors.As(err, &appErr) {
        if appErr.Code == ErrCodeNotFound {
            fmt.Println("处理未找到错误")
        }
    }
}
```

## 实现 Unwrap 方法

为了支持 `errors.Is` 和 `errors.As`，自定义错误类型应该实现 `Unwrap()` 方法：

```go
type WrappedError struct {
    Message string
    Err     error
}

func (e *WrappedError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %v", e.Message, e.Err)
    }
    return e.Message
}

func (e *WrappedError) Unwrap() error {
    return e.Err
}
```

# panic vs error 的选择

## 何时使用 error

`error` 用于处理**可预期的错误**，这些错误是程序正常流程的一部分：

```go
// ✅ 使用 error：文件不存在是可预期的
func readFile(filename string) ([]byte, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to read file: %w", err)
    }
    return data, nil
}

// ✅ 使用 error：网络请求失败是可预期的
func fetchData(url string) ([]byte, error) {
    resp, err := http.Get(url)
    if err != nil {
        return nil, fmt.Errorf("failed to fetch: %w", err)
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}
```

## 何时使用 panic

`panic` 用于处理**不可恢复的程序错误**，这些错误表示程序出现了严重问题：

```go
// ✅ 使用 panic：程序配置错误，无法继续运行
func init() {
    if os.Getenv("DATABASE_URL") == "" {
        panic("DATABASE_URL environment variable is required")
    }
}

// ✅ 使用 panic：数组越界等编程错误
func getElement(arr []int, index int) int {
    if index < 0 || index >= len(arr) {
        panic(fmt.Sprintf("index %d out of bounds [0:%d]", index, len(arr)))
    }
    return arr[index]
}
```

## 对比表

| 特性 | error | panic |
|------|-------|-------|
| **用途** | 可预期的错误 | 不可恢复的错误 |
| **处理方式** | 显式返回和处理 | 自动传播到 recover |
| **影响范围** | 局部影响 | 可能导致程序崩溃 |
| **性能** | 正常函数返回 | 需要栈展开，性能开销大 |
| **适用场景** | 业务逻辑错误 | 编程错误、配置错误 |

## 最佳实践

### 1. 优先使用 error

```go
// ❌ 不推荐：使用 panic 处理可预期错误
func divide(a, b int) int {
    if b == 0 {
        panic("division by zero")
    }
    return a / b
}

// ✅ 推荐：使用 error 处理可预期错误
func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}
```

### 2. panic 用于不可恢复错误

```go
// ✅ 合理使用 panic：初始化失败
func initDatabase() {
    db, err := sql.Open("postgres", dsn)
    if err != nil {
        panic(fmt.Sprintf("failed to initialize database: %v", err))
    }
    // 数据库连接是程序运行的基础，失败应该 panic
}
```

### 3. 在库函数中避免 panic

```go
// ❌ 不推荐：库函数中使用 panic
func LibraryFunction(input string) {
    if input == "" {
        panic("input cannot be empty")  // 库函数不应该 panic
    }
}

// ✅ 推荐：库函数返回 error
func LibraryFunction(input string) error {
    if input == "" {
        return errors.New("input cannot be empty")
    }
    return nil
}
```

# 错误处理模式

## 1. 早期返回模式（Early Return）

尽早返回错误，减少嵌套：

```go
// ❌ 不推荐：深层嵌套
func processUser(userID string) error {
    user, err := getUser(userID)
    if err == nil {
        data, err := fetchData(user.ID)
        if err == nil {
            result, err := processData(data)
            if err == nil {
                return saveResult(result)
            }
            return err
        }
        return err
    }
    return err
}

// ✅ 推荐：早期返回
func processUser(userID string) error {
    user, err := getUser(userID)
    if err != nil {
        return fmt.Errorf("failed to get user: %w", err)
    }
    
    data, err := fetchData(user.ID)
    if err != nil {
        return fmt.Errorf("failed to fetch data: %w", err)
    }
    
    result, err := processData(data)
    if err != nil {
        return fmt.Errorf("failed to process data: %w", err)
    }
    
    return saveResult(result)
}
```

## 2. 错误包装模式

在错误传播过程中添加上下文：

```go
func readConfig() error {
    data, err := os.ReadFile("config.json")
    if err != nil {
        return fmt.Errorf("failed to read config: %w", err)
    }
    
    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return fmt.Errorf("failed to parse config: %w", err)
    }
    
    return nil
}
```

## 3. 错误分类处理

根据错误类型采取不同处理策略：

```go
func handleRequest(req *Request) error {
    err := processRequest(req)
    if err != nil {
        // 根据错误类型采取不同策略
        var notFoundErr *NotFoundError
        if errors.As(err, &notFoundErr) {
            // 返回 404
            return respondWithStatus(404, err)
        }
        
        var validationErr *ValidationError
        if errors.As(err, &validationErr) {
            // 返回 400
            return respondWithStatus(400, err)
        }
        
        // 其他错误返回 500
        return respondWithStatus(500, err)
    }
    return nil
}
```

## 4. 错误日志记录

在关键位置记录错误：

```go
func processOrder(orderID string) error {
    order, err := getOrder(orderID)
    if err != nil {
        log.Printf("failed to get order %s: %v", orderID, err)
        return fmt.Errorf("failed to get order: %w", err)
    }
    
    if err := validateOrder(order); err != nil {
        log.Printf("order %s validation failed: %v", orderID, err)
        return fmt.Errorf("order validation failed: %w", err)
    }
    
    return nil
}
```

## 5. 错误聚合

收集多个错误后统一处理：

```go
type Errors []error

func (e Errors) Error() string {
    var msgs []string
    for _, err := range e {
        msgs = append(msgs, err.Error())
    }
    return strings.Join(msgs, "; ")
}

func validateUser(user User) error {
    var errs Errors
    
    if user.Name == "" {
        errs = append(errs, errors.New("name is required"))
    }
    if user.Email == "" {
        errs = append(errs, errors.New("email is required"))
    }
    if user.Age < 0 {
        errs = append(errs, errors.New("age cannot be negative"))
    }
    
    if len(errs) > 0 {
        return errs
    }
    return nil
}
```

# 错误处理最佳实践

## 1. 总是检查错误

```go
// ❌ 不推荐：忽略错误
data, _ := os.ReadFile("file.txt")

// ✅ 推荐：总是检查错误
data, err := os.ReadFile("file.txt")
if err != nil {
    return fmt.Errorf("failed to read file: %w", err)
}
```

## 2. 提供有意义的错误消息

```go
// ❌ 不推荐：错误消息不明确
if err != nil {
    return err
}

// ✅ 推荐：添加上下文信息
if err != nil {
    return fmt.Errorf("failed to process user %s: %w", userID, err)
}
```

## 3. 使用 %w 包装错误

```go
// ❌ 不推荐：使用 %v 会丢失错误链
return fmt.Errorf("operation failed: %v", err)

// ✅ 推荐：使用 %w 保留错误链
return fmt.Errorf("operation failed: %w", err)
```

## 4. 避免过度包装

```go
// ❌ 不推荐：过度包装导致错误消息冗长
func level1() error {
    return fmt.Errorf("level 1: %w", level2())
}

func level2() error {
    return fmt.Errorf("level 2: %w", level3())
}

func level3() error {
    return errors.New("original error")
}

// ✅ 推荐：在关键位置包装，避免每层都包装
func level1() error {
    err := level2()
    if err != nil {
        return fmt.Errorf("high-level operation failed: %w", err)
    }
    return nil
}
```

## 5. 使用 errors.Is 和 errors.As

```go
// ❌ 不推荐：字符串比较
if err.Error() == "file not found" {
    // ...
}

// ✅ 推荐：使用 errors.Is
if errors.Is(err, os.ErrNotExist) {
    // ...
}

// ✅ 推荐：使用 errors.As 提取错误类型
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println(pathErr.Path)
}
```

## 6. 为自定义错误实现 Unwrap

```go
type CustomError struct {
    Message string
    Cause   error
}

func (e *CustomError) Error() string {
    return e.Message
}

// 实现 Unwrap 以支持 errors.Is 和 errors.As
func (e *CustomError) Unwrap() error {
    return e.Cause
}
```

## 7. 在 defer 中处理清理错误

```go
func processFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer func() {
        if closeErr := file.Close(); closeErr != nil {
            log.Printf("failed to close file: %v", closeErr)
        }
    }()
    
    // 处理文件
    return nil
}
```

## 8. 避免在库函数中使用 panic

```go
// ❌ 不推荐：库函数中使用 panic
func LibraryFunc(input string) {
    if input == "" {
        panic("input cannot be empty")
    }
}

// ✅ 推荐：库函数返回 error
func LibraryFunc(input string) error {
    if input == "" {
        return errors.New("input cannot be empty")
    }
    return nil
}
```

# 错误处理在项目中的应用

## HTTP 服务中的错误处理

```go
package main

import (
    "encoding/json"
    "errors"
    "fmt"
    "log"
    "net/http"
)

// 错误响应结构
type ErrorResponse struct {
    Error   string `json:"error"`
    Code    int    `json:"code"`
    Message string `json:"message"`
}

// 错误处理中间件
func errorHandler(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                log.Printf("panic recovered: %v", err)
                respondError(w, http.StatusInternalServerError, "internal server error")
            }
        }()
        
        next(w, r)
    }
}

// 统一错误响应
func respondError(w http.ResponseWriter, code int, message string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(code)
    json.NewEncoder(w).Encode(ErrorResponse{
        Error:   http.StatusText(code),
        Code:    code,
        Message: message,
    })
}

// 用户处理函数
func getUserHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.URL.Query().Get("id")
    if userID == "" {
        respondError(w, http.StatusBadRequest, "user id is required")
        return
    }
    
    user, err := getUser(userID)
    if err != nil {
        // 根据错误类型返回不同的状态码
        var notFoundErr *NotFoundError
        if errors.As(err, &notFoundErr) {
            respondError(w, http.StatusNotFound, err.Error())
            return
        }
        
        log.Printf("failed to get user: %v", err)
        respondError(w, http.StatusInternalServerError, "failed to get user")
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}

func main() {
    http.HandleFunc("/user", errorHandler(getUserHandler))
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

## gRPC 服务中的错误处理

```go
package main

import (
    "context"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

func (s *UserService) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    user, err := s.repo.GetUser(req.Id)
    if err != nil {
        // 转换为 gRPC 错误
        var notFoundErr *NotFoundError
        if errors.As(err, &notFoundErr) {
            return nil, status.Error(codes.NotFound, "user not found")
        }
        
        // 记录内部错误
        log.Printf("failed to get user: %v", err)
        return nil, status.Error(codes.Internal, "internal server error")
    }
    
    return user, nil
}
```

## 数据库操作中的错误处理

```go
package main

import (
    "database/sql"
    "errors"
    "fmt"
)

func (r *UserRepository) GetUserByID(id string) (*User, error) {
    var user User
    err := r.db.QueryRow("SELECT id, name, email FROM users WHERE id = $1", id).
        Scan(&user.ID, &user.Name, &user.Email)
    
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, &NotFoundError{Resource: "user", ID: id}
        }
        return nil, fmt.Errorf("failed to query user: %w", err)
    }
    
    return &user, nil
}

func (r *UserRepository) CreateUser(user *User) error {
    _, err := r.db.Exec(
        "INSERT INTO users (id, name, email) VALUES ($1, $2, $3)",
        user.ID, user.Name, user.Email,
    )
    
    if err != nil {
        // 检查唯一约束冲突
        if isUniqueConstraintError(err) {
            return &ValidationError{
                Field:   "email",
                Message: "email already exists",
            }
        }
        return fmt.Errorf("failed to create user: %w", err)
    }
    
    return nil
}
```

## 配置加载中的错误处理

```go
package main

import (
    "encoding/json"
    "errors"
    "fmt"
    "os"
)

type Config struct {
    DatabaseURL string `json:"database_url"`
    Port        int    `json:"port"`
}

func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        if errors.Is(err, os.ErrNotExist) {
            return nil, fmt.Errorf("config file %s not found", path)
        }
        return nil, fmt.Errorf("failed to read config file: %w", err)
    }
    
    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return nil, fmt.Errorf("failed to parse config: %w", err)
    }
    
    // 验证必需字段
    if config.DatabaseURL == "" {
        return nil, errors.New("database_url is required")
    }
    if config.Port == 0 {
        return nil, errors.New("port is required")
    }
    
    return &config, nil
}
```

## 错误处理工具函数

```go
package main

import (
    "errors"
    "fmt"
    "log"
)

// 错误处理辅助函数
func HandleError(err error, context string) error {
    if err != nil {
        log.Printf("%s: %v", context, err)
        return fmt.Errorf("%s: %w", context, err)
    }
    return nil
}

// 检查并记录错误
func CheckError(err error, message string) {
    if err != nil {
        log.Printf("%s: %v", message, err)
    }
}

// 错误重试函数
func Retry(attempts int, fn func() error) error {
    var err error
    for i := 0; i < attempts; i++ {
        err = fn()
        if err == nil {
            return nil
        }
        log.Printf("attempt %d failed: %v", i+1, err)
    }
    return fmt.Errorf("failed after %d attempts: %w", attempts, err)
}
```

# 总结

Go 语言的错误处理机制具有以下特点：

## 核心原则

1. **显式错误处理**：错误必须显式返回和处理
2. **错误即值**：错误是普通的值，可以传递和比较
3. **错误包装**：支持错误链，保留上下文信息
4. **类型安全**：通过自定义错误类型提供类型安全

## 关键要点

1. **总是检查错误**：不要忽略任何错误
2. **提供上下文**：使用 `fmt.Errorf` 和 `%w` 添加上下文
3. **使用 errors.Is 和 errors.As**：正确检查和处理错误
4. **合理使用 panic**：只在不可恢复的错误时使用
5. **实现 Unwrap**：自定义错误类型应实现 `Unwrap()` 方法

## 最佳实践

- 使用早期返回模式减少嵌套
- 在关键位置记录错误日志
- 根据错误类型采取不同的处理策略
- 在库函数中避免使用 panic
- 为自定义错误提供有意义的错误消息

掌握 Go 语言的错误处理机制，能够编写出更加健壮和可维护的代码。

# 参考文献

- [Go 官方文档：错误处理](https://go.dev/blog/error-handling-and-go)
- [Go 官方文档：errors 包](https://pkg.go.dev/errors)
- [Effective Go: Errors](https://go.dev/doc/effective_go#errors)
- [Go 1.13 错误处理改进](https://go.dev/blog/go1.13-errors)
