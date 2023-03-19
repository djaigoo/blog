---
author: djaigo
title: golang-defer
tags:
categories:
  - golang
date: 2022-11-28 16:34:29
---

defer在当前函数执行结束之前执行另一个行数

defer将编译成代码
调用defer处改为deferproc函数，表示defer函数注册，返回值大于0表示panic，用于recover
在函数返回处指定deferreturn函数

g结构持有defer链表，`_defer`指向defer链表，将g的所有defer链接起来，新注册的defer会添加到链表头，执行时也是从头开始，实现后进先出的逻辑

deferproc函数
参数：
siz：表示参数返回值大小
fn：延迟执行函数指针

defer结构
```go
type _defer struct {
  siz int32 // 参数和返回值共占多少字节，具体空间会直接挂在在defer结构体后面，用于调用时快速赋值，执行时拷贝到调用者参数与返回值空间
  started bool // 标记defer是否已经执行
  sp uintptr // 调用者函数栈指针，用于判断函数自己注册的defer是否执行完毕
  pc uintptr // 记录deferproc返回地址
  fn *funcval // 注册函数指针
  _panic *_panic // 关联panic信息
  link *_defer // 用于挂载defer链表
}
```

deferproc函数会将栈上相应值存到`_defer`结构中

全局defer缓存池
用于快速申请释放`_defer`结构，避免频繁的堆分配回收

deferreturn执行时会将defer结构体中的参数拷贝到调用者栈帧上，然后通过注册的函数指针调用函数

如果注册函数拥有捕获列表，就会创建闭包对象，会将捕获列表中的变量进行堆分配，存入闭包结构中

判断是否当前函数执行完所有defer，判断defer链表头部的节点的sp是否等于当前函数的栈指针

该版本存在的问题
所有defer都在堆上分配，在创建和执行时需要来回拷贝参数，比较耗时
操作defer链表，寻址较慢

go1.13改版
在栈上创建defer结构，将栈上的defer注册到defer链表中，这样减少了堆分配，但是不能适用于循环中
所以在defer结构体中新加字段`heap`标识是否是堆分配defer
执行时直接在栈上取值，少了堆栈拷贝

go1.14改版
使用开放代码插入代码设置需要执行的defer
新增字段
```go
type _defer struct {
  openDefer bool // 是否是开放代码实现的defer
  fd unsafe.Pointer // defer标记位图
  varp uintptr
  framepc uintptr
}
```

前置
利用编译器将需要defer的函数直接插入到函数返回前的执行代码
利用`df byte`最多标记8个defer，用1表示需要执行，0表示不执行
执行
在执行延迟函数时需要判断df标记位，如果需要执行则将标志位置为0，避免重复执行

依然不适合循环中的defer和当前函数超过8个defer的函数

为了让panic时找到开放代码的函数需要使用栈扫描的方式去执行，通过附加字段进行查找

defer池
defer注册
  需要来回拷贝参数
defer执行

单defer
多defer
  defer嵌套

循环defer无法优化
将部分defer信息存在栈帧
开放代码
  不创建defer结构体
  栈扫描 找到未注册的defer进行执行
