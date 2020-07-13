---
author: djaigo
title: golang 编译指示
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - compile
date: 2020-03-15 10:09:36
updated: 2020-01-15
enable html: false
---

# 编译指示
函数声明前一行写上`//go:`后面跟上编译指示，在编译的时候，go编译器会进行指定的操作


```go
// cmd/compile/internal/gc/lex.go
const (
	// Func pragmas.
	Nointerface    syntax.Pragma = 1 << iota
	Noescape                     // func parameters don't escape
	Norace                       // func must not have race detector annotations
	Nosplit                      // func should not execute on separate stack
	Noinline                     // func should not be inlined
	CgoUnsafeArgs                // treat a pointer to one arg as a pointer to them all
	UintptrEscapes               // pointers converted to uintptr escape

	// Runtime-only func pragmas.
	// See ../../../../runtime/README.md for detailed descriptions.
	Systemstack        // func must run on system stack
	Nowritebarrier     // emit compiler error instead of write barrier
	Nowritebarrierrec  // error on write barrier in this or recursive callees
	Yeswritebarrierrec // cancels Nowritebarrierrec in this function and callees

	// Runtime-only type pragmas
	NotInHeap // values of this type must not be heap allocated
)

func pragmaValue(verb string) syntax.Pragma {
	switch verb {
	case "go:nointerface":
		if objabi.Fieldtrack_enabled != 0 {
			return Nointerface
		}
	case "go:noescape":
		return Noescape
	case "go:norace":
		return Norace
	case "go:nosplit":
		return Nosplit
	case "go:noinline":
		return Noinline
	case "go:systemstack":
		return Systemstack
	case "go:nowritebarrier":
		return Nowritebarrier
	case "go:nowritebarrierrec":
		return Nowritebarrierrec | Nowritebarrier // implies Nowritebarrier
	case "go:yeswritebarrierrec":
		return Yeswritebarrierrec
	case "go:cgo_unsafe_args":
		return CgoUnsafeArgs
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