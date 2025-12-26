---
author: djaigo
title: golang MPG调度
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - mpg
  - infra
---

# MPG
MPG是golang的并发模型，结构源码在`runtime/runtime2.go`里面，主体逻辑结构在`runtime/proc.go`里，是golang可以高并发的根本。
* M，连接一个内核态的线程，goroutine跑在M上，每个M都会有一个g0的G，用于协调P队列里的G，在调度或系统调用时会用到g0的栈
* P，维护执行G队列，管理G上下文
* G，代表goroutine的元数据，包括栈信息，M信息，计数器等

除了MPG之外，还有Sched来负责全局队列的处理。
四者协同完成整个golang的高并发处理的主要逻辑，还有其他小的结构进行辅助，例如：sudog（G队列）、stack（栈信息）等。

M、P数量：
* P的数量可以在启动时通过环境变量`$GOMAXPROCS`，或在代码中通过`runtime`包的`GOMAXPROCS()`设置。P的数量限制了最大goroutine并发执行数。
* M的数量在启动时会被`schedinit()`设置成`sched.maxmcount = 10000`，可在代码中调用`runtime/debug`包的`SetMaxThreads()`。M的数量限制了最大可用的系统线程数。

M、P创建：
* P，在系统确定了P的数量后就会创建指定个数的P
* M，如果P没有M，则会去全局休眠M队列中找，如果还没有则会创建M

M调度策略：
* work stealing，当M执行G结束后，会从绑定P中获取G，而不是销毁当前M
* hand off，当G调用阻塞系统调用时，M释放绑定的P，将P交给空闲的M

## 生命周期
程序启动第一时间都会调用`runtime.main()`，进行相关值的初始化。
```
// The main goroutine.
func main() {
	g := getg()

	// Racectx of m0->g0 is used only as the parent of the main goroutine.
	// It must not be used for anything else.
	g.m.g0.racectx = 0

	// Max stack size is 1 GB on 64-bit, 250 MB on 32-bit.
	// Using decimal instead of binary GB and MB because
	// they look nicer in the stack overflow failure message.
	// 设置栈的最大值
	if sys.PtrSize == 8 {
		maxstacksize = 1000000000
	} else {
		maxstacksize = 250000000
	}

	// Allow newproc to start new Ms.
	// 允许新P创建M
	mainStarted = true

	if GOARCH != "wasm" { // no threads on wasm yet, so no sysmon
		systemstack(func() {
			newm(sysmon, nil, -1)
		})
	}

	// Lock the main goroutine onto this, the main OS thread,
	// during initialization. Most programs won't care, but a few
	// do require certain calls to be made by the main thread.
	// Those can arrange for main.main to run in the main thread
	// by calling runtime.LockOSThread during initialization
	// to preserve the lock.
	lockOSThread()

	if g.m != &m0 {
		throw("runtime.main not on m0")
	}

	doInit(&runtime_inittask) // must be before defer
	if nanotime() == 0 {
		throw("nanotime returning zero")
	}

	// Defer unlock so that runtime.Goexit during init does the unlock too.
	needUnlock := true
	defer func() {
		if needUnlock {
			unlockOSThread()
		}
	}()

	// Record when the world started.
	// 记录启动时间
	runtimeInitTime = nanotime()

	gcenable() // 开启GC
    ...
	needUnlock = false
	unlockOSThread()

	if isarchive || islibrary {
		// A program compiled with -buildmode=c-archive or c-shared
		// has a main, but it is not executed.
		return
	}
	
	// 执行main包的main函数
	fn := main_main // make an indirect call, as the linker doesn't know the address of the main package when laying down the runtime
	fn()
	if raceenabled {
		racefini() // 竞态检测
	}

	// Make racy client program work: if panicking on
	// another goroutine at the same time as main returns,
	// let the other goroutine finish printing the panic trace.
	// Once it does, it will exit. See issues 3934 and 20018.
    // 如果goroutine panic了则创建另一个goroutine打印相关信息，完成之后新建goroutine将退出
	if atomic.Load(&runningPanicDefers) != 0 {
		// Running deferred functions should not take long.
		for c := 0; c < 1000; c++ {
			if atomic.Load(&runningPanicDefers) == 0 {
				break
			}
			Gosched()
		}
	}
	if atomic.Load(&panicking) != 0 {
		gopark(nil, nil, waitReasonPanicWait, traceEvGoStop, 1)
	}

	exit(0) // 退出进程
	for {
		var x *int32
		*x = 0
	}
}
```

在程序启动时会创建m0，同时创建g0，在`runtime/proc.go`声明：
```go
var (
	m0 m
	g0 g
)
```

> 特殊的m0，是启动程序后的编号为0的主线程，这个M对应的实例会在全局变量`runtime.m0`中，不需要在heap上分配，m0负责执行初始化操作和启动第一个G，在之后M0就和其他的一样了。

初始化P，创建`main()`的g1，将g1存放于p的本地G队列中，启动m0，m0绑定p，如果绑定不成功就会进入全局休眠M队列等待被唤醒，从p中获取可执行的G，如果没有课执行的G则会进入自旋状态，如果获取到g1，设置g1的运行环境，运行g1，g1退出，m0继续通过p获取G。

> 自旋状态，是指M绑定的P没有可以执行的G，此时M执行的g0，轮询P的本地空闲G队列有没有可执行的G

## 三者关系
*   `G`需要绑定在`M`上才能运行；
*   `M`需要绑定`P`才能运行；
*   程序中的多个`M`并不会同时都处于执行状态，最多只有`GOMAXPROCS`个`M`在执行。

 早期版本的Golang是没有`P`的，调度是由`G`与`M`完成。 这样的问题在于每当创建、终止Goroutine或者需要调度时，需要一个全局的锁来保护调度的相关对象(sched)。 全局锁严重影响Goroutine的并发性能。
 通过引入`P`，实现了一种叫做`work-stealing`的调度算法：

*   每个`P`维护一个`G`队列；
*   当一个`G`被创建出来，或者变为可执行状态时，就把他放到`P`的可执行队列中；
*   当一个`G`执行结束时，`P`会从队列中把该`G`取出；如果此时`P`的队列为空，即没有其他`G`可以执行， 就随机选择另外一个`P`，从其可执行的`G`队列中偷取一半。

该算法避免了在Goroutine调度时使用全局锁。


# 可视化
## trace
代码：
```
package main

import (
    "fmt"
    "os"
    "runtime/trace"
)

func main() {
    f, err := os.Create("trace.out")
    if err != nil {
        panic(err)
    }
    
    defer f.Close()
    
    err = trace.Start(f)
    if err != nil {
        panic(err)
    }
    defer trace.Stop()
    
    fmt.Println("Hello world!")
}
```

运行程序会生成一个trace.out的文件，可以通过tool工具将其可视化
```
➜ go tool trace trace.out
```

这样写会对代码侵入太强，可以写成测试文件，在test的时候生成trace.out文件，在`Test()`不需要显式的调用上面的代码，代码如下：
```
package main

import (
    "fmt"
    "testing"
)

func Test(t *testing.T) {
    fmt.Println("Hello world!")
}
```

执行代码
```
go test -trace trace.out -run Test
```

也可以生成trace.out文件。
在有了trace.out文件后，执行`go tool trace trace.out`，启动http服务可视化查看MPG的相关信息。


## debug
代码：
```go
package main

import (
    "fmt"
)

func main() {
    fmt.Println("Hello world!")
}
```

在执行之前设置`GODEBUG=schedtrace=10`，单位毫秒
执行结果
```sh
GODEBUG=schedtrace=10 go run main.go 
SCHED 0ms: gomaxprocs=4 idleprocs=1 threads=6 spinningthreads=1 idlethreads=0 runqueue=0 [1 0 0 0]
SCHED 18ms: gomaxprocs=4 idleprocs=0 threads=9 spinningthreads=1 idlethreads=2 runqueue=1 [0 4 0 0]
SCHED 30ms: gomaxprocs=4 idleprocs=1 threads=9 spinningthreads=1 idlethreads=2 runqueue=0 [0 0 0 0]
SCHED 42ms: gomaxprocs=4 idleprocs=2 threads=9 spinningthreads=0 idlethreads=3 runqueue=1 [0 0 0 0]
SCHED 53ms: gomaxprocs=4 idleprocs=4 threads=9 spinningthreads=0 idlethreads=4 runqueue=0 [0 0 0 0]
SCHED 66ms: gomaxprocs=4 idleprocs=0 threads=9 spinningthreads=1 idlethreads=2 runqueue=1 [0 0 0 0]
SCHED 79ms: gomaxprocs=4 idleprocs=3 threads=9 spinningthreads=0 idlethreads=4 runqueue=0 [0 0 0 0]
```

* `SCHED 0ms`：调试信息输出标志字符串，后面是执行的时间戳
* `gomaxprocs`：P的数量，本例有4个P，默认与cpu核心数量一致，可以通过GOMAXPROCS来设置
* `idleprocs`：处于idle状态P的数量
* `threads`：M的数量，包含scheduler使用的M数量，加上runtime自用的类似sysmon这样的thread的数量
* `spinningthreads`: 处于自旋状态M数量
* `idlethread`: 处于idle状态的M的数量
* `runqueue=0`：Scheduler全局队列中G的数量
* `[0 0 0 0]`: 分别为4个的`local queue`中的G的数量

# 关键字段说明
## M
```go
type m struct {
	g0      *g     // goroutine with scheduling stack
	morebuf gobuf  // gobuf arg to morestack
	divmod  uint32 // div/mod denominator for arm - known to liblink

	// Fields not known to debuggers.
	procid        uint64       // for debuggers, but offset not hard-coded
	gsignal       *g           // signal-handling g
	goSigStack    gsignalStack // Go-allocated signal handling stack
	sigmask       sigset       // storage for saved signal mask
	tls           [6]uintptr   // thread-local storage (for x86 extern register)
	mstartfn      func()
	curg          *g       // 当前执行的G，检测gp
	caughtsig     guintptr // goroutine running during fatal signal
	p             puintptr // 绑定的P执行go代码 (如果没有执行go代码则为nil)
	nextp         puintptr
	oldp          puintptr // 执行系统调用之前的P
	id            int64
	mallocing     int32
	throwing      int32
	preemptoff    string // if != "", keep curg running on this m
	locks         int32  // m的引用计数 
	dying         int32
	profilehz     int32
	spinning      bool // m is out of work and is actively looking for work
	blocked       bool // m is blocked on a note
	newSigstack   bool // minit on C thread called sigaltstack
	printlock     int8
	incgo         bool   // m is executing a cgo call
	freeWait      uint32 // if == 0, safe to free g0 and delete m (atomic)
	fastrand      [2]uint32 // 两个随机值，不能同时为0
	needextram    bool
	traceback     uint8
	ncgocall      uint64      // number of cgo calls in total
	ncgo          int32       // number of cgo calls currently in progress
	cgoCallersUse uint32      // if non-zero, cgoCallers in use temporarily
	cgoCallers    *cgoCallers // cgo traceback if crashing in cgo call
	park          note
	alllink       *m // on allm
	schedlink     muintptr    // M的单链表
	lockedg       guintptr    // M锁定的G
	createstack   [32]uintptr // stack that created this thread.
	lockedExt     uint32      // tracking for external LockOSThread
	lockedInt     uint32      // tracking for internal lockOSThread
	nextwaitm     muintptr    // next m waiting for lock
	waitunlockf   func(*g, unsafe.Pointer) bool
	waitlock      unsafe.Pointer
	waittraceev   byte
	waittraceskip int
	startingtrace bool
	syscalltick   uint32
	freelink      *m // 对应全局休眠M队列

	// these are here because they are too large to be on the stack
	// of low-level NOSPLIT functions.
	libcall   libcall
	libcallpc uintptr // for cpu profiler
	libcallsp uintptr
	libcallg  guintptr
	syscall   libcall // stores syscall parameters on windows

	vdsoSP uintptr // SP for traceback while in VDSO call (0 if not in call)
	vdsoPC uintptr // PC for traceback while in VDSO call

	// preemptGen counts the number of completed preemption
	// signals. This is used to detect when a preemption is
	// requested, but fails. Accessed atomically.
	preemptGen uint32

	// Whether this is a pending preemption signal on this M.
	// Accessed atomically.
	signalPending uint32

	dlogPerM

	mOS

	// Up to 10 locks held by this m, maintained by the lock ranking code.
	locksHeldLen int
	locksHeld    [10]heldLockInfo
}
```

## P
```go
type p struct {
	id          int32
	status      uint32 // one of pidle/prunning/...
	link        puintptr   // P的单链表
	schedtick   uint32     // incremented on every scheduler call
	syscalltick uint32     // incremented on every system call
	sysmontick  sysmontick // last tick observed by sysmon
	m           muintptr   // 当前的M，如果空闲则为nil
	mcache      *mcache
	pcache      pageCache
	raceprocctx uintptr

	deferpool    [5][]*_defer // pool of available defer structs of different sizes (see panic.go)
	deferpoolbuf [5][32]*_defer

	// Cache of goroutine ids, amortizes accesses to runtime·sched.goidgen.
	goidcache    uint64
	goidcacheend uint64

	// Queue of runnable goroutines. Accessed without lock.
	runqhead uint32         // 队首下标
	runqtail uint32         // 队尾下标
	runq     [256]guintptr  // 可执行队列，最多256个
	// runnext, if non-nil, is a runnable G that was ready'd by
	// the current G and should be run next instead of what's in
	// runq if there's time remaining in the running G's time
	// slice. It will inherit the time left in the current time
	// slice. If a set of goroutines is locked in a
	// communicate-and-wait pattern, this schedules that set as a
	// unit and eliminates the (potentially large) scheduling
	// latency that otherwise arises from adding the ready'd
	// goroutines to the end of the run queue.
	runnext guintptr

	// Available G's (status == Gdead)
	gFree struct {
		gList
		n int32
	}

	sudogcache []*sudog     // 本地G的队列
	sudogbuf   [128]*sudog

	// Cache of mspan objects from the heap.
	mspancache struct {
		// We need an explicit length here because this field is used
		// in allocation codepaths where write barriers are not allowed,
		// and eliminating the write barrier/keeping it eliminated from
		// slice updates is tricky, moreso than just managing the length
		// ourselves.
		len int
		buf [128]*mspan
	}

	tracebuf traceBufPtr

	// traceSweep indicates the sweep events should be traced.
	// This is used to defer the sweep start event until a span
	// has actually been swept.
	traceSweep bool
	// traceSwept and traceReclaimed track the number of bytes
	// swept and reclaimed by sweeping in the current sweep loop.
	traceSwept, traceReclaimed uintptr

	palloc persistentAlloc // per-P to avoid mutex

	_ uint32 // Alignment for atomic fields below

	// The when field of the first entry on the timer heap.
	// This is updated using atomic functions.
	// This is 0 if the timer heap is empty.
	timer0When uint64

	// Per-P GC state
	gcAssistTime         int64    // Nanoseconds in assistAlloc
	gcFractionalMarkTime int64    // Nanoseconds in fractional mark worker (atomic)
	gcBgMarkWorker       guintptr // (atomic)
	gcMarkWorkerMode     gcMarkWorkerMode

	// gcMarkWorkerStartTime is the nanotime() at which this mark
	// worker started.
	gcMarkWorkerStartTime int64

	// gcw is this P's GC work buffer cache. The work buffer is
	// filled by write barriers, drained by mutator assists, and
	// disposed on certain GC state transitions.
	gcw gcWork

	// wbBuf is this P's GC write barrier buffer.
	//
	// TODO: Consider caching this in the running G.
	wbBuf wbBuf

	runSafePointFn uint32 // if 1, run sched.safePointFn at next safe point

	// Lock for timers. We normally access the timers while running
	// on this P, but the scheduler can also do it from a different P.
	timersLock mutex

	// Actions to take at some time. This is used to implement the
	// standard library's time package.
	// Must hold timersLock to access.
	timers []*timer

	// Number of timers in P's heap.
	// Modified using atomic instructions.
	numTimers uint32

	// Number of timerModifiedEarlier timers on P's heap.
	// This should only be modified while holding timersLock,
	// or while the timer status is in a transient state
	// such as timerModifying.
	adjustTimers uint32

	// Number of timerDeleted timers in P's heap.
	// Modified using atomic instructions.
	deletedTimers uint32

	// Race context used while executing timer functions.
	timerRaceCtx uintptr

	// preempt is set to indicate that this P should be enter the
	// scheduler ASAP (regardless of what G is running on it).
	preempt bool

	pad cpu.CacheLinePad
}
```

## G
```go
type g struct {
	// Stack parameters.
	// stack describes the actual stack memory: [stack.lo, stack.hi).
	// stackguard0 is the stack pointer compared in the Go stack growth prologue.
	// It is stack.lo+StackGuard normally, but can be StackPreempt to trigger a preemption.
	// stackguard1 is the stack pointer compared in the C stack growth prologue.
	// It is stack.lo+StackGuard on g0 and gsignal stacks.
	// It is ~0 on other goroutine stacks, to trigger a call to morestackc (and crash).
	stack       stack   // offset known to runtime/cgo
	stackguard0 uintptr // offset known to liblink
	stackguard1 uintptr // offset known to liblink

	_panic       *_panic // innermost panic - offset known to liblink
	_defer       *_defer // innermost defer
	m            *m      // 当前M；offset known to arm liblink
	sched        gobuf
	syscallsp    uintptr        // if status==Gsyscall, syscallsp = sched.sp to use during gc
	syscallpc    uintptr        // if status==Gsyscall, syscallpc = sched.pc to use during gc
	stktopsp     uintptr        // expected sp at top of stack, to check in traceback
	param        unsafe.Pointer // passed parameter on wakeup
	atomicstatus uint32     // G的状态
	stackLock    uint32     // sigprof/scang lock; TODO: fold in to atomicstatus
	goid         int64      // goroutine id
	schedlink    guintptr   // 下一个G的地址
	waitsince    int64      // approx time when the g become blocked
	waitreason   waitReason // if status==Gwaiting

	preempt       bool // preemption signal, duplicates stackguard0 = stackpreempt
	preemptStop   bool // transition to _Gpreempted on preemption; otherwise, just deschedule
	preemptShrink bool // shrink stack at synchronous safe point

	// asyncSafePoint is set if g is stopped at an asynchronous
	// safe point. This means there are frames on the stack
	// without precise pointer information.
	asyncSafePoint bool

	paniconfault bool // panic (instead of crash) on unexpected fault address
	gcscandone   bool // g has scanned stack; protected by _Gscan bit in status
	throwsplit   bool // must not split stack
	// activeStackChans indicates that there are unlocked channels
	// pointing into this goroutine's stack. If true, stack
	// copying needs to acquire channel locks to protect these
	// areas of the stack.
	activeStackChans bool

	raceignore     int8     // ignore race detection events
	sysblocktraced bool     // StartTrace has emitted EvGoInSyscall about this goroutine
	sysexitticks   int64    // cputicks when syscall has returned (for tracing)
	traceseq       uint64   // trace event sequencer
	tracelastp     puintptr // last P emitted an event for this goroutine
	lockedm        muintptr
	sig            uint32
	writebuf       []byte
	sigcode0       uintptr
	sigcode1       uintptr
	sigpc          uintptr
	gopc           uintptr         // pc of go statement that created this goroutine
	ancestors      *[]ancestorInfo // ancestor information goroutine(s) that created this goroutine (only used if debug.tracebackancestors)
	startpc        uintptr         // pc of goroutine function
	racectx        uintptr
	waiting        *sudog         // sudog structures this g is waiting on (that have a valid elem ptr); in lock order
	cgoCtxt        []uintptr      // cgo traceback context
	labels         unsafe.Pointer // profiler labels
	timer          *timer         // cached timer for time.Sleep
	selectDone     uint32         // are we participating in a select and did someone win the race?

	// Per-G GC state

	// gcAssistBytes is this G's GC assist credit in terms of
	// bytes allocated. If this is positive, then the G has credit
	// to allocate gcAssistBytes bytes without assisting. If this
	// is negative, then the G must correct this by performing
	// scan work. We track this in bytes to make it fast to update
	// and check for debt in the malloc hot path. The assist ratio
	// determines how this corresponds to scan work debt.
	gcAssistBytes int64
}
```

## Sched
```go
type schedt struct {
	// accessed atomically. keep at top to ensure alignment on 32-bit systems.
	goidgen   uint64
	lastpoll  uint64 // time of last network poll, 0 if currently polling
	pollUntil uint64 // time to which current poll is sleeping

	lock mutex // 操作锁，锁定schedt

	// When increasing nmidle, nmidlelocked, nmsys, or nmfreed, be
	// sure to call checkdead().

	midle        muintptr // 空闲M单链表
	nmidle       int32    // 空闲M的个数
	nmidlelocked int32    // number of locked m's waiting for work
	mnext        int64    // number of m's that have been created and next M ID
	maxmcount    int32    // maximum number of m's allowed (or die)
	nmsys        int32    // number of system m's not counted for deadlock
	nmfreed      int64    // cumulative number of freed m's

	ngsys uint32 // number of system goroutines; updated atomically

	pidle      puintptr // 空闲的P
	npidle     uint32
	nmspinning uint32 // See "Worker thread parking/unparking" comment in proc.go.

	// Global runnable queue.
	runq     gQueue  // 全局可执行队列
	runqsize int32   // 全局队列大小

	// disable控制有选择的禁用调度
	//
	// 使用schedEnableUser(enable bool)进行控制
	//
	// disable需要被sched.lock保护
	disable struct {
		// user是否禁止调度goroutines.
		user     bool
		runnable gQueue // pending runnable Gs
		n        int32  // length of runnable
	}

	// Global cache of dead G's.
	gFree struct {
		lock    mutex
		stack   gList // Gs with stacks
		noStack gList // Gs without stacks
		n       int32
	}

	// Central cache of sudog structs.
	sudoglock  mutex  // 全局空闲G队列锁
	sudogcache *sudog // 全局空闲G队列

	// Central pool of available defer structs of different sizes.
	deferlock mutex
	deferpool [5]*_defer

	// freem is the list of m's waiting to be freed when their
	// m.exited is set. Linked through m.freelink.
	freem *m // 全局休眠M队列

	gcwaiting  uint32 // gc is waiting to run
	stopwait   int32
	stopnote   note
	sysmonwait uint32
	sysmonnote note

	// safepointFn should be called on each P at the next GC
	// safepoint if p.runSafePointFn is set.
	safePointFn   func(*p)
	safePointWait int32
	safePointNote note

	profilehz int32 // cpu profiling rate

	procresizetime int64 // nanotime() of last change to gomaxprocs
	totaltime      int64 // ∫gomaxprocs dt up to procresizetime

	// sysmonlock protects sysmon's actions on the runtime.
	//
	// Acquire and hold this mutex to block sysmon from interacting
	// with the rest of the runtime.
	sysmonlock mutex
}
```


# 字段和结构体
## G状态
```go
const (
	// G status
	//
	// 除了指示G的一般状态外，G状态还像goroutine堆栈上的锁一样（因此具有执行用户代码的能力）。

	// _Gidle表示此goroutine已分配，尚未初始化。
	_Gidle = iota // 0

	// _Grunnable表示此goroutine在运行队列中，当前未执行用户代码，没有堆栈。
	_Grunnable // 1

	// _Grunning表示此goroutine可以执行用户代码。
	// 该goroutine拥有堆栈，且不在运行队列中。
	// 它已分配一个M和一个P。
	_Grunning // 2

	// _Gsyscall表示此goroutine正在执行系统调用。
	// 它不执行用户代码，堆栈由该goroutine拥有，它不在运行队列中。
	// 它被分配了一个M。
	_Gsyscall // 3

	// _Gwaiting 意味着goroutine被runtime阻止。
	// 它不执行用户代码，它也不再运行队列，但应该被记录下来（例如：等待chan中的数据），必要时可以调用ready()恢复。
	// 除chan操作可以在适当的锁下读取或写入堆栈的某些部分外，不应该拥有该堆栈。
	_Gwaiting // 4

	// _Gmoribund_unused当前未使用，但已在gdb脚本中进行了硬编码。
	_Gmoribund_unused // 5

	// _Gdead表示此goroutine当前未使用。
	// 它有可能已退出，在空闲列表或刚被初始化。它不能执行用户代码。它可能拥有堆栈也可能不拥有堆栈。
	// G及其堆栈（如果有）由退出G或从空闲列表中获得G的M拥有。
	_Gdead // 6

	// _Genqueue_unused当前未使用。
	_Genqueue_unused // 7

	// _Gcopystack表示此goroutine的堆栈正在迁移。
	// 它不能执行用户代码，并且不再运行队列中。
	// 堆栈由将其放入_Gcopystack的goroutine拥有。
	_Gcopystack // 8

	// _Gscan与上述状态之一组合表示GC正在扫描堆栈（除_Grunning）。
	// goroutine未执行用户代码，并且堆栈由设置_Gscan位的goroutine拥有。
	// _Gscanrunning不同: 它用于短暂阻止状态转换，而GC则通知G扫描其自身的堆栈。否则就像_Grunning。
	// atomicstatus&~Gscan 给出goroutine将在扫描完成时返回的状态。
	_Gscan         = 0x1000
	_Gscanrunnable = _Gscan + _Grunnable // 0x1001
	_Gscanrunning  = _Gscan + _Grunning  // 0x1002
	_Gscansyscall  = _Gscan + _Gsyscall  // 0x1003
	_Gscanwaiting  = _Gscan + _Gwaiting  // 0x1004
)
```

## P状态
```go
const (
	// P status

	// _Pidle表示不使用P来运行用户代码或调度程序。
	// 它在空闲的P列表中，可供调度程序使用，但可能只是在其他状态之间转换。
	//
	// P由空闲列表或转换其状态的任何内容所拥有。它的运行队列为空。
	_Pidle = iota

	// _Prunning表示P由M拥有，并用于运行用户代码或调度程序。
	// 仅拥有此P的M允许从_Prunning更改P的状态。
	// M可以将P转换为_Pidle（如果没有更多工作要做），_Psyscall（进入系统调用时）或_Pgcstop（以停止GC）。
	// M也可以将P的所有权直接移交给另一个M（例如，调度锁定的G）。
	_Prunning

	// _Psyscall表示P没有运行用户代码。
	// 它与系统调用中的M有亲缘关系，但不归其所有，并且可能被另一个M窃取。
	// 这类似于_Pidle，但使用轻量级转换并保持M相似性。
	//
	// 必须通过CAS离开_Psyscall才能窃取或重新获得P。
	// 注意ABA危害：
	// 即使M在系统调用后成功将其原始P恢复为_Prunning，它也必须了解该P在此期间可能已被另一个M使用。
	_Psyscall

	// _Pgcstop表示对STW(stop the world)暂停P并由STW的M拥有。
	// STW的M甚至在_Pgcstop中也继续使用其P。
	// 从_Prunning过渡到_Pgcstop会导致M释放其P并停放。
	//
	// P保留其运行队列，STW将使用非空运行队列在P上重新启动调度程序。
	_Pgcstop

	// _Pdead表示不再使用P（GOMAXPROCS缩小），如果P的数量增加将会复用P。
	// 一个死掉的P大部分被剥夺了其资源，尽管还剩下一些东西（例如跟踪缓冲区）。
	_Pdead
)
```

## runtime2.go 全局变量
```go
var (
	allglen    uintptr // allgs的长度
	allm       *m      // 所有m的单链表
	allp       []*p    // 所有的P列表，len(allp) == gomaxprocs，只能通过GOMAXPROCS()修改
	allpLock   mutex   // Protects P-less reads of allp and all writes
	gomaxprocs int32         // 最大P的数量
	ncpu       int32         // CPU数
	forcegc    forcegcstate
	sched      schedt        // 调度者
	newprocs   int32

	// Information about what cpu features are available.
	// Packages outside the runtime should not use these
	// as they are not an external api.
	// Set on startup in asm_{386,amd64}.s
	processorVersionInfo uint32
	isIntel              bool
	lfenceBeforeRdtsc    bool

	goarm                uint8 // set by cmd/link on arm systems
	framepointer_enabled bool  // set by cmd/link
)

var (
	allgs    []*g  // 所有g的单链表
	allglock mutex // 修改单链表锁
)
```


## sodug
```
type hchan struct {
	qcount   uint           // 队列元素总数
	dataqsiz uint           // 循环队列的大小
	buf      unsafe.Pointer // 指向dataqsiz元素数组
	elemsize uint16
	closed   uint32
	elemtype *_type // element type
	sendx    uint   // send index
	recvx    uint   // receive index
	recvq    waitq  // list of recv waiters
	sendq    waitq  // list of send waiters

	// lock保护hchan的所有字段，也保护sudog的所有字段在这个channel。
	//
	// 锁住此锁时，请勿更改另一个G的状态（特别是不要对G调用ready），因为这会因堆栈收缩而死锁。
	lock mutex
}

type waitq struct {
	first *sudog
	last  *sudog
}

// sudog 表示可执行G的列表，一个G可能在多个sudog中，
// 并且许多G可能正在等待同一个同步对象，因此一个对象可能有许多sudog。
// 
// sudog 由特殊的池分配，所以只能通过acquireSudog和releaseSudog来分配和释放sudog。
type sudog struct {
	// 由hchan.lock来保护以下字段，收缩栈依赖sudog的操作

	g *g

	next *sudog
	prev *sudog
	elem unsafe.Pointer // data element (may point to stack)

	// 以下字段永远不能同时访问
	// 对于channel，waitlink仅由g访问。
	// 对于信号量，仅在持有semaRoot锁时才能访问所有字段（包括上述字段）。

	acquiretime int64
	releasetime int64
	ticket      uint32

	// isSelect表示g正在参与选择，因此必须对g.selectDone进行CAS操作才能wake-up竞争。
	isSelect bool

	parent   *sudog // semaRoot binary tree
	waitlink *sudog // g.waiting list or semaRoot
	waittail *sudog // semaRoot
	c        *hchan // channel，引用chan的底层实现
}
```



# 参考文献
* [[典藏版] Golang 调度器 GMP 原理与调度全分析](https://learnku.com/articles/41728)
* [Golang调度器源码分析](http://ga0.github.io/golang/2015/09/20/golang-runtime-scheduler.html)
