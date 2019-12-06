---
title: golang builtin 注释详解
date: 2018-07-31 15:03:40
updated: 2018-07-31 17:54:00
tags:
 - builtin
categories:
 - golang
---
## golang builtin.go
注释一下golang里面的builtin源码
<!-- more -->


```golang
// bool 布尔类型
const (
	true  = 0 == 0 // Untyped bool.
	false = 0 != 0 // Untyped bool.
)
type bool bool

// uint8 无符号8位整型，0 through 255
type uint8 uint8

// uint16 无符号16位整型，0 through 65535
type uint16 uint16

// uint32 无符号32位整型，0 through 4294967295.
type uint32 uint32

// uint64 无符号64位整型，0 through 18446744073709551615.
type uint64 uint64

// int8 8位整型，-128 through 127.
type int8 int8

// int16 16位整型，-32768 through 32767.
type int16 int16

// int32 32位整型，-2147483648 through 2147483647.
type int32 int32

// int64 64整型，-9223372036854775808 through 9223372036854775807.
type int64 int64

// float32 32位浮点
type float32 float32

// float64 64位浮点
type float64 float64

// complex64 64位复数
type complex64 complex64

// complex128 128位复数
type complex128 complex128

// string 8位字符集，不一定表示utf-8编码的文本，字符串可能为空，但不是nil，字符串类型的值是不可变的。
type string string

// int 等同于int32
type int int

// uint 等同于uint32
type uint uint

// uintptr 一个能够容纳任何指针的整型
type uintptr uintptr

// byte 等同于uint8，用于表示字符
type byte = uint8

// rune 等同于int32，用于表示字符
type rune = int32

// iota 从0开始的整型索引
const iota = 0 // Untyped int.

// nil 用于表示pointer， channel, func, interface, map, slice的空值
var nil Type

// Type 用于文档说明，表示Go type，对于任何给定的函数调用表示相同的类型
type Type int

// Type1 同上
type Type1 int

// IntegerType 用于文档说明，表示int, uint, int8 etc.
type IntegerType int

// FloatType 用于文档说明，表示float32 or float64.
type FloatType float32

// ComplexType 用于文档说明，表示complex64 or complex128.
type ComplexType complex64

// append 在slice后面添加元素，底层具有不确定性调用append必须接受返回值
func append(slice []Type, elems ...Type) []Type

// copy 将src slice复制到dst slice，返回copy元素个数
func copy(dst, src []Type) int

// delete 删除指定map的指定key，如果map为nil，或者map中没有指定key，则no-op
func delete(m map[Type]Type1, key Type)

// len 根据不同类型返回v的长度
//	Array: v的元素个数.
//	Pointer to array: *v的元素个数，v为nil，则panic invalid memory address.
//	Slice, or map: v的元素个数，v为nil，则返回0.
//	String: v的byte个数.
//	Channel: channel buffer的未读排队元素个数，v为nil，则返回0.
func len(v Type) int

// cap 根据不同类型返回v的容量
//	Array: v的元素个数.
//	Pointer to array: *v的元素个数，v为nil，则panic invalid memory address.
//	Slice: v能存放最大元素个数，v为nil，则返回0.
//	Channel: channel buffer的容量，如果v为空，则返回0.
func cap(v Type) int

// make 申请空间并初始化slice、map、chan对象，返回对象实体
//	Slice: 创建指定size和capacity的slice。
//	Map: 创建一个空map
//	Channel: 创建一个带指定size buffer的channel
func make(t Type, size ...IntegerType) Type

// new 申请指定类型的内存空间，返回指定类型的指针，值为zero value
func new(Type) *Type

// complex 创建一个复数，返回相应的精度
func complex(r, i FloatType) ComplexType

// real 返回复数的实部，返回相应的精度
func real(c ComplexType) FloatType

// imag 返回复数的虚部，返回相应的精度
func imag(c ComplexType) FloatType

// close 关闭双向或者仅发送的channel，只能由发送者调用，具有在发送最后值之后关闭channel的效果
// 在接收关闭的channel时，不会阻塞，直接返回zero value，并且第二个返回值返回false，表示channel已经关闭
func close(c chan<- Type)

// panic 当系统出现严重错误，必须终止当前goroutine时执行，当前goroutine会立即退出，
// 当前goroutine F下的子goroutine H会继续执行，执行结果返回给当前goroutine的调用者G，
// G会终止执行，并运行之前所有注册的defer函数，出栈的方式退出所有goroutine。
// 最终进程终止，所有goroutine全部被终止，并返回错误码和panic值。
// 可以通过recover进行控制。
func panic(v interface{})

// recover 在goroutine panic之前使用defer注册recover函数，可以保证其他goroutine不受影响
func recover() interface{}

// print 往标准错误输出
func print(args ...Type)

// println 往标准错误换行输出
func println(args ...Type)

// error 接口
type error interface {
	Error() string
}
```


