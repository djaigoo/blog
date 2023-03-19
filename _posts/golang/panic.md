---
author: djaigo
title: golang-panic
tags:
categories:
  - golang
date: 2022-11-28 16:34:36
---



在g结构中用`_panic`标识当前g的所有的panic链表，链接起一个一个panic结构体，发生新panic时使用头插插入链表

一旦发生panic，panic后面的代码就不会执行，会触发`runtime.gopanic`函数，转而执行注册的defer函数，会将defer结构的`_panic`字段设置当前panic，如果正常结束则移除当前defer结构，执行下一个defer，如果当前执行的defer函数中有panic，会将新panic插入链表头，新panic成为当前执行的panic，然后执行defer链表，发现第一个defer已经执行并且执行的panic不是新panic，则将defer执行的panic标记为已终止，并且移除当前的defer



```go
type _panic struct {
  argp unsafe.Pointer // 指向defer参数空间地址
  arg interface{} // panic参数
  link *_panic // 链接之前发生的panic
  recovered bool // 表示panic是否被恢复
  aborted bool // 表示panic是否被终止
}
```



recover
将当前执行的panic置为已恢复，当执行完当前defer函数后会检测当前panic是否已恢复，如果已恢复则删除当前panic，并且当前执行的defer也会移除，但是会记录当前defer的pc和sp，用于跳出panic流程，sp用于记录调用defer函数的函数栈指针，pc用于记录defer函数注册时的deferproc函数返回地址，通过sp可以恢复调用者的栈帧，通过pc可以跳转到defer函数注册时的返回地址

recover后又panic
等同于panic后执行defer函数中panic，移除当defer，执行下一个defer，将下一个defer的触发panic置为当前panic



打印panic信息
会从panic链表尾开始输出，如果panic已经恢复会在输出时加上`[recovered]`标记




panic结构
panic链表
  defer链表先标记后释放
panic信息输出

recover
  recover panic
  recover之后需要跳转代码位置
  recover之后又panic
    panic结构是否一处
    
