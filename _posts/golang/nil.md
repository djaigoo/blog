---
title: golang nil
tags:
  - golang
categories:
  - tech
date: 2019-04-17 09:29:31
---

# Go nil 详解

## 概述

`nil` 是 Go 语言中一个预先声明的标识符，用于表示指针、通道、函数、接口、映射或切片类型的零值。`nil` 不是关键字，而是一个预声明的标识符，可以在作用域内被重新定义（但不推荐）。

## nil 的定义

从 Go 源码中可以看到 `nil` 的定义：

```go
// nil is a predeclared identifier representing the zero value for a
// pointer, channel, func, interface, map, or slice type.
var nil Type // Type must be a pointer, channel, func, interface, map, or slice type

// Type is here for the purposes of documentation only. It is a stand-in
// for any Go type, but represents the same type for any given function
// invocation.
type Type int
```

**说明**：
- `nil` 是一个预先声明的标识符，表示指针、通道、函数、接口、映射或切片类型的零值
- `Type` 是一个类型代理，表示全部类型，底层实现是 `_type`

## nil 的类型

`nil` 本身没有固定的类型，它的类型取决于上下文。`nil` 可以用于以下类型：

1. **指针类型**（pointer）
2. **通道类型**（channel）
3. **函数类型**（func）
4. **接口类型**（interface）
5. **映射类型**（map）
6. **切片类型**（slice）

### 示例

```go
var p *int = nil           // 指针类型
var c chan int = nil        // 通道类型
var f func() = nil          // 函数类型
var i interface{} = nil     // 接口类型
var m map[string]int = nil  // 映射类型
var s []int = nil           // 切片类型
```

## nil 的使用场景

### 1. 指针的零值

```go
var p *int
if p == nil {
    fmt.Println("p is nil")
}

// 使用前需要初始化
p = new(int)
*p = 42
```

### 2. 切片的零值

```go
var s []int
if s == nil {
    fmt.Println("s is nil")
}

// nil 切片可以安全地使用
s = append(s, 1, 2, 3)  // 可以追加元素
fmt.Println(len(s))     // 0，nil 切片长度为 0
fmt.Println(cap(s))      // 0，nil 切片容量为 0
```

### 3. 映射的零值

```go
var m map[string]int
if m == nil {
    fmt.Println("m is nil")
}

// nil 映射可以读取，但不能写入
// fmt.Println(m["key"])  // 返回零值，不会 panic
// m["key"] = 1           // panic: assignment to entry in nil map

// 使用前需要初始化
m = make(map[string]int)
m["key"] = 1
```

### 4. 通道的零值

```go
var c chan int
if c == nil {
    fmt.Println("c is nil")
}

// nil 通道可以读取和写入，但会阻塞
// <-c  // 永久阻塞
// c <- 1  // 永久阻塞

// 使用前需要初始化
c = make(chan int)
```

### 5. 函数的零值

```go
var f func()
if f == nil {
    fmt.Println("f is nil")
}

// 不能调用 nil 函数
// f()  // panic: call of nil function

// 使用前需要赋值
f = func() {
    fmt.Println("function called")
}
f()
```

### 6. 接口的零值

```go
var i interface{}
if i == nil {
    fmt.Println("i is nil")
}

// 接口的 nil 判断需要注意
var p *int = nil
i = p
if i == nil {
    // 这里不会执行，因为 i 的类型是 *int，值才是 nil
    fmt.Println("i is nil")
}
// 正确的判断方式
if i == nil || (reflect.ValueOf(i).Kind() == reflect.Ptr && reflect.ValueOf(i).IsNil()) {
    fmt.Println("i is nil or points to nil")
}
```

## nil 的比较

### 基本比较

```go
var p *int = nil
var s []int = nil
var m map[string]int = nil

fmt.Println(p == nil)  // true
fmt.Println(s == nil)  // true
fmt.Println(m == nil)  // true
```

### 接口的 nil 比较陷阱

接口的 `nil` 比较需要特别注意：

```go
type MyError struct {
    msg string
}

func (e *MyError) Error() string {
    return e.msg
}

func returnsError() error {
    var p *MyError = nil
    return p  // 返回的是 (error, *MyError) 类型，值部分是 nil，但类型部分不是 nil
}

func main() {
    err := returnsError()
    if err != nil {
        // 这里会执行，因为 err 的类型是 *MyError，不是 nil
        fmt.Println("error is not nil")
    }
    // 正确的判断方式
    if err != nil && reflect.ValueOf(err).IsNil() {
        fmt.Println("error is nil")
    }
}
```

**原因**：接口值由两部分组成：类型（type）和值（value）。只有当类型和值都为 `nil` 时，接口才等于 `nil`。

## nil 与零值

`nil` 是某些类型的零值，但不是所有类型的零值：

| 类型 | 零值 | 是否为 nil |
|------|------|-----------|
| 指针 | `nil` | 是 |
| 切片 | `nil` | 是 |
| 映射 | `nil` | 是 |
| 通道 | `nil` | 是 |
| 函数 | `nil` | 是 |
| 接口 | `nil` | 是 |
| 数值类型 | `0` | 否 |
| 字符串 | `""` | 否 |
| 布尔类型 | `false` | 否 |
| 结构体 | 各字段的零值 | 否 |

## 常见陷阱

### 1. 接口 nil 判断

```go
// 错误示例
func badCheck(err error) {
    if err != nil {
        // 即使 err 的值是 nil，这里也可能执行
    }
}

// 正确示例
func goodCheck(err error) {
    if err != nil {
        // 使用反射或类型断言进行更精确的判断
        if reflect.ValueOf(err).IsNil() {
            return
        }
    }
}
```

### 2. 映射的 nil 写入

```go
var m map[string]int
m["key"] = 1  // panic: assignment to entry in nil map

// 正确做法
m = make(map[string]int)
m["key"] = 1
```

### 3. 通道的 nil 操作

```go
var c chan int
<-c  // 永久阻塞
c <- 1  // 永久阻塞

// 正确做法
c = make(chan int)
```

### 4. 切片的 nil 判断

```go
var s []int
if s == nil {
    // nil 切片
}
if len(s) == 0 {
    // 空切片（可能是 nil，也可能不是）
}

// 注意：nil 切片和空切片在使用上几乎相同
s = append(s, 1)  // 都可以追加元素
```

## 最佳实践

1. **明确初始化**：使用映射、通道、切片前，明确初始化或使用 `make`
2. **接口 nil 判断**：判断接口是否为 `nil` 时，注意类型和值都需要为 `nil`
3. **使用 len() 判断**：对于切片，使用 `len(s) == 0` 比 `s == nil` 更通用
4. **避免重新定义 nil**：虽然可以重新定义 `nil`，但强烈不推荐

## 总结

- `nil` 是 Go 语言中指针、通道、函数、接口、映射、切片类型的零值
- `nil` 本身没有固定类型，类型取决于上下文
- 接口的 `nil` 判断需要特别注意类型和值两部分
- 使用 `nil` 值前需要初始化，否则可能导致 panic 或阻塞
- `nil` 切片和空切片在使用上几乎相同，但概念上有区别
