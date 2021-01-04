---
author: djaigo
title: golang 编译指示
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - compile
date: 2020-03-15 10:09:36
enable html: false
---

# 编译指示
函数声明前一行写上`//go:`后面跟上编译指示，在编译的时候，go编译器会进行指定的操作


```go
// cmd/compile/internal/gc/lex.go

const (
	// Func pragmas.
	Nointerface    PragmaFlag = 1 << iota
	Noescape                  // func parameters don't escape
	Norace                    // func must not have race detector annotations
	Nosplit                   // func should not execute on separate stack
	Noinline                  // func should not be inlined
	NoCheckPtr                // func should not be instrumented by checkptr
	CgoUnsafeArgs             // treat a pointer to one arg as a pointer to them all
	UintptrEscapes            // pointers converted to uintptr escape

	// Runtime-only func pragmas.
	// See ../../../../runtime/README.md for detailed descriptions.
	Systemstack        // func must run on system stack
	Nowritebarrier     // emit compiler error instead of write barrier
	Nowritebarrierrec  // error on write barrier in this or recursive callees
	Yeswritebarrierrec // cancels Nowritebarrierrec in this function and callees

	// Runtime and cgo type pragmas
	NotInHeap // values of this type must not be heap allocated

	// Go command pragmas
	GoBuildPragma
)

func pragmaFlag(verb string) PragmaFlag {
	switch verb {
	case "go:build":
		return GoBuildPragma
	case "go:nointerface":
		if objabi.Fieldtrack_enabled != 0 {
			return Nointerface
		}
	case "go:noescape":
		return Noescape
	case "go:norace":
		return Norace
	case "go:nosplit":
		return Nosplit | NoCheckPtr // implies NoCheckPtr (see #34972)
	case "go:noinline":
		return Noinline
	case "go:nocheckptr":
		return NoCheckPtr
	case "go:systemstack":
		return Systemstack
	case "go:nowritebarrier":
		return Nowritebarrier
	case "go:nowritebarrierrec":
		return Nowritebarrierrec | Nowritebarrier // implies Nowritebarrier
	case "go:yeswritebarrierrec":
		return Yeswritebarrierrec
	case "go:cgo_unsafe_args":
		return CgoUnsafeArgs | NoCheckPtr // implies NoCheckPtr (see #34968)
	case "go:uintptrescapes":
		// For the next function declared in the file
		// any uintptr arguments may be pointer values
		// converted to uintptr. This directive
		// ensures that the referenced allocated
		// object, if any, is retained and not moved
		// until the call completes, even though from
		// the types alone it would appear that the
		// object is no longer needed during the
		// call. The conversion to uintptr must appear
		// in the argument list.
		// Used in syscall/dll_windows.go.
		return UintptrEscapes
	case "go:notinheap":
		return NotInHeap
	}
	return 0
}
```

# 通用标签
## noescape
`//go:noescape`表示当前函数的局部变量不能逃逸，它只能指示一个只有声明没有主体的函数。
例如：在原子操作，函数内创建的变量是不能向外传递指针，只能传递值
```go
//go:noescape
func Xadd(ptr *uint32, delta int32) uint32
```

## norace
`//go:norace`表示当前函数不需要竞态检测。
例如：处理错误信号时，在没有m或g的外部堆栈上运行，所以没有竞争
```go
//go:norace
func badsignal(sig uintptr, c *sigctxt) {
    ......
}
```

## nosplit
`//go:nosplit`表示当前函数不需要栈溢出检测。
例如：当创建新的协程的函数是在`g0`栈上执行的，`g0`栈是不需要栈溢出检测的，所以就使用`nosplit`进行标记。
```go
//go:nosplit
func newproc(siz int32, fn *funcval) {
	......
}
```


## noinline
`//go:noinline`表示当前函数不需要内联。
例如：原子获取`uint32`指针指向的值
```go
//go:noinline
func Load(ptr *uint32) uint32 {
	return *ptr
}
```


## linkname
`//go:linkname`表示函数之间的链接，可以将不可导出函数通过链接方式指向另一个包外的函数。
例如：将`runtime/timestub.go`的`time_now()`链接到`time/time.go`的`time.now()`
```go
import _ "unsafe" // for go:linkname

//go:linkname time_now time.now
func time_now() (sec int64, nsec int32, mono int64) {
	sec, nsec = walltime()
	return sec, nsec, nanotime()
}
```

# 仅运行时可用标签
## systemstack
`//go:systemstack`表示当前函数只能在系统栈上运行，即`m->g0`的栈上运行。进入该标签函数必须要在`func systemstack(fn func())`作为参数fn的一部分。
例如：创建新协程时需要使用系统栈进行创建相关操作
```go
systemstack(func() {
	newg := newproc1(fn, argp, siz, gp, pc) // 创建新g
})

//go:systemstack
func newproc1(fn *funcval, argp unsafe.Pointer, narg int32, callergp *g, callerpc uintptr) *g {
    ......
}
```

## nowritebarrier
`//go:nowritebarrier`表示允许编译器用错误替换写屏障

## nowritebarrierrec
`//go:nowritebarrierrec`表示允许编译器用错误替换写屏障，并允许递归

## yeswritebarrierrec
`//go:yeswritebarrierrec`表示编译器遇到写屏障时停止

# 运行时或cgo标签

## notinheap
`//go:notinheap`表示当前对象不能使用堆内存进行分配
例如：`mcache`不是由GC内存分配的，所以需要标记
```go
//go:notinheap
type mcache struct {
	......
}
```


# 命令标签
## build
`//go:build`
