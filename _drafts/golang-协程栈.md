---
author: djaigo
title: golang-协程栈
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - runtime
date: 2020-10-28 11:01:55
---

golang栈的增长方向
```go
func main() {
	a := 1
	b := 2
	fmt.Println(&a, &b)
}

// output: 0xc00036a2b0 0xc00036a2b8
```

由此可见栈的增长方向是由低地址向高地址增长


