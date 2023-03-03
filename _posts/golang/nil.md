---
title: golang nil
tags:
  - golang
categories:
  - tech
date: 2019-04-17 09:29:31
---

实现看一下定义
```go
// nil is a predeclared identifier representing the zero value for a
// pointer, channel, func, interface, map, or slice type.
var nil Type // Type must be a pointer, channel, func, interface, map, or slice type

// Type is here for the purposes of documentation only. It is a stand-in
// for any Go type, but represents the same type for any given function
// invocation.
type Type int
```

`nil`是一个预先声明的标识符，表示指针、通道、`func`、接口、映射或切片类型的零值。
`Type`是一个类型代理，表示全部类型，底层实现是`_type`。

