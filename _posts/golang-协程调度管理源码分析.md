---
author: djaigo
title: golang 调度过程源码分析
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - runtime
date: 2020-10-12 16:15:17
---

golang 版本：go version go1.15.2 darwin/amd64

根据启动函数来分析golang MPG的生存周期，忽略cgo相关代码。

# MPG
MPG是golang调度的重要对象：
* M，表示一个内核线程，是执行用户代码的实际场所
* P，表示一个处理器，管理M需要运行G的相关资源，如内存分配，G的可执行列表，G的空闲列表等
* G，表示一个goroutine，调度基本单元，维护goroutine内部资源，如栈信息，defer列表等

# 启动
启动汇编函数
```asm
// runtime/asm_amd64.s

TEXT runtime·rt0_go(SB),NOSPLIT,$0
    // ... 省略 ...

	// create istack out of the given (operating system) stack.
	// _cgo_init may update stackguard.
	// 给 runtime.g0 创建栈
	MOVQ	$runtime·g0(SB), DI
	LEAQ	(-64*1024+104)(SP), BX
	MOVQ	BX, g_stackguard0(DI)
	MOVQ	BX, g_stackguard1(DI)
	MOVQ	BX, (g_stack+stack_lo)(DI)
	MOVQ	SP, (g_stack+stack_hi)(DI)

    // ... 省略 ...

	// set the per-goroutine and per-mach "registers"
	get_tls(BX)
	LEAQ	runtime·g0(SB), CX
	MOVQ	CX, g(BX)
	LEAQ	runtime·m0(SB), AX

	// save m->g0 = g0
	// 绑定 m0 和 g0
	MOVQ	CX, m_g0(AX)
	// save m0 to g0->m
	MOVQ	AX, g_m(CX)

	CLD				// convention is D is always left cleared
	CALL	runtime·check(SB)

	MOVL	16(SP), AX		// copy argc
	MOVL	AX, 0(SP)
	MOVQ	24(SP), AX		// copy argv
	MOVQ	AX, 8(SP)
	CALL	runtime·args(SB)       // 解析命令行参数
	CALL	runtime·osinit(SB)     // 获取CPU核数
	CALL	runtime·schedinit(SB)  // 初始化调度

	// create a new goroutine to start program
	MOVQ	$runtime·mainPC(SB), AX		// entry
	PUSHQ	AX
	PUSHQ	$0			// arg size
	CALL	runtime·newproc(SB)// 执行runtime.main
	POPQ	AX
	POPQ	AX

	// start this M
	CALL	runtime·mstart(SB) // 启动m0

	CALL	runtime·abort(SB)	// mstart should never return
	RET
```

`rt0_go`函数主要流程：
* 初始化`g0`、`m0`
* `g0`和`m0`互相绑定
* 初始化相关数据，初始化指定个数的`p`
* 创建新`g`绑定`runtime.main`函数，加入`p`的可执行列表中
* 启动`m0`开始循环调度。

## schedinit
```go
// runtime/proc.go

func schedinit() {
	// ... 省略 ...
	
	_g_ := getg() // 获取当前绑定的g
	
	// 限制M的数量
	sched.maxmcount = 10000

	// ... 省略 ...

    // 创建 p
	lock(&sched.lock)
	sched.lastpoll = uint64(nanotime())
	procs := ncpu
	if n, ok := atoi32(gogetenv("GOMAXPROCS")); ok && n > 0 {
		procs = n
	}
	if procresize(procs) != nil {
		throw("unknown runnable goroutine during bootstrap")
	}
	unlock(&sched.lock)
}
```

`schedinit`函数主要流程：
* 初始化全局调度相关值
* 限制`m`的最多个数
* 初始化指定个数的`p`

## newproc
```go
// runtime/proc.go

func newproc(siz int32, fn *funcval) {
	argp := add(unsafe.Pointer(&fn), sys.PtrSize)
	gp := getg()
	pc := getcallerpc()
	systemstack(func() {
		newg := newproc1(fn, argp, siz, gp, pc)

		_p_ := getg().m.p.ptr()
		runqput(_p_, newg, true)

		if mainStarted { // mainStarted 是在 runtime.main 中设置为 true 
			wakep() // 尝试找一个p绑定m
		}
	})
}
```

`newproc`函数主要流程：
* 创建栈大小为`siz`的新`g`，并关联`fn`
* 将新`g`存放于`_p_`的可执行队列中
* 此时刚初始化，并没有执行`runtime.main`所以不会执行`wakep`

```go
// runtime/proc.go

func newproc1(fn *funcval, argp unsafe.Pointer, narg int32, callergp *g, callerpc uintptr) *g {
	_g_ := getg()

	acquirem() // disable preemption because it can be holding p in a local var
	siz := narg
	siz = (siz + 7) &^ 7
	
	_p_ := _g_.m.p.ptr() // 获取 p
	newg := gfget(_p_)   // 从 p 的空闲 g 列表中获取 g
	if newg == nil {     // 没有空闲的 g
		newg = malg(_StackMin)           // 创建一个拥有最小栈的 g
		casgstatus(newg, _Gidle, _Gdead) // 转换状态
		allgadd(newg)                    // 向全局 g 列表中添加 g
	}

	// ... 省略 ...

    // 填充 g
	memclrNoHeapPointers(unsafe.Pointer(&newg.sched), unsafe.Sizeof(newg.sched))
	newg.sched.sp = sp
	newg.stktopsp = sp
	newg.sched.pc = funcPC(goexit) + sys.PCQuantum // 当g执行完后的处理函数
	newg.sched.g = guintptr(unsafe.Pointer(newg))
	gostartcallfn(&newg.sched, fn)
	newg.gopc = callerpc
	newg.ancestors = saveAncestors(callergp)
	newg.startpc = fn.fn
	if _g_.m.curg != nil {
		newg.labels = _g_.m.curg.labels
	}
	if isSystemGoroutine(newg, false) {
		atomic.Xadd(&sched.ngsys, +1)
	}
	casgstatus(newg, _Gdead, _Grunnable) // 切换成可执行状态

    // 分配goid，如果没有则向p批量获取
	if _p_.goidcache == _p_.goidcacheend {
		_p_.goidcache = atomic.Xadd64(&sched.goidgen, _GoidCacheBatch)
		_p_.goidcache -= _GoidCacheBatch - 1
		_p_.goidcacheend = _p_.goidcache + _GoidCacheBatch
	}
	newg.goid = int64(_p_.goidcache)
	_p_.goidcache++

	releasem(_g_.m)

	return newg
}
```

`newproc1`函数主要流程：
* 从空闲`g`列表中获取或新建`g`，将`g`的信息填充

## mstart
```go
// runtime/proc.go

func mstart() {
	_g_ := getg()

    // 设置 _g_ 的栈信息
	osStack := _g_.stack.lo == 0
	if osStack {
		size := _g_.stack.hi
		if size == 0 {
			size = 8192 * sys.StackGuardMultiplier
		}
		_g_.stack.hi = uintptr(noescape(unsafe.Pointer(&size)))
		_g_.stack.lo = _g_.stack.hi - size + 1024
	}
	_g_.stackguard0 = _g_.stack.lo + _StackGuard
	_g_.stackguard1 = _g_.stackguard0
	
	mstart1() // 不会返回
}
```

`mstart`函数主要流程：
* 填充`g`的栈信息
* 让`m`开始执行`g`上的代码

```go
// runtime/proc.go

func mstart1() {
	_g_ := getg()

	// ... 省略 ...
	
	if _g_.m == &m0 {
		mstartm0() // 启动 m0 初始化信号处理
	}

	if fn := _g_.m.mstartfn; fn != nil {
		fn() // 执行m绑定的启动时调用的函数
	}

	if _g_.m != &m0 {
		acquirep(_g_.m.nextp.ptr())
		_g_.m.nextp = 0
	}
	schedule() // 开始调度
}
```

`mstart1`函数主要流程：
* 如果是`m0`，则初始化信号处理
* 如果有`mstartfn`，则执行
* 如果不是`m0`，则绑定`p`
* 调用`schedule`启动golang进程的调度。

## runtime.main
```go
// runtime/proc.go

func main() {
	g := getg()

    // 确认栈的最大值
	if sys.PtrSize == 8 {
		maxstacksize = 1000000000
	} else {
		maxstacksize = 250000000
	}

	// Allow newproc to start new Ms.
	mainStarted = true // 标志 newproc 时可以启动 m

	if GOARCH != "wasm" { // no threads on wasm yet, so no sysmon
		systemstack(func() {
			newm(sysmon, nil, -1) // 新建 m 去执行 sysmon
		})
	}

	lockOSThread()
	
	doInit(&runtime_inittask) // 执行runtime包中的init函数

	// Record when the world started.
	runtimeInitTime = nanotime()

	gcenable() // 开启GC

	main_init_done = make(chan bool)
	doInit(&main_inittask) // 执行main包中的init函数
	close(main_init_done)
	
	unlockOSThread()

	fn := main_main // fn 指向main包的main函数
	fn() // 执行main包的main函数

	exit(0)
}
```

runtime.main函数主要功能：
* 设置了栈的最大值
* 创建m去执行sysmon
* 调用runtime包的init函数
* 启动GC
* 执行main包的init函数
* 退出

## startm
除了m0是汇编初始化的，其他的m都是由startm创建的。
```go
func startm(_p_ *p, spinning bool) {
	lock(&sched.lock)
	if _p_ == nil { // _p_ 为空
		_p_ = pidleget() // 从p空闲列表中获取一个
		if _p_ == nil {  // 获取失败
			unlock(&sched.lock)
			if spinning {
				// 如果是自旋状态，调用方增加了nmspinning，但是没有空闲的P，因此可以取消增量并放弃
				if int32(atomic.Xadd(&sched.nmspinning, -1)) < 0 {
					throw("startm: negative nmspinning")
				}
			}
			return
		}
	}
	mp := mget() // 从m空闲列表中获取m
	if mp == nil { // 如果空闲列表没有
		id := mReserveID() // 获取 m id
		unlock(&sched.lock)

		var fn func()
		if spinning {
			fn = mspinning // 设置 m 的自旋状态函数
		}
		newm(fn, _p_, id) // 创建一个m对象
		return
	}
	unlock(&sched.lock)
	if mp.spinning {
		throw("startm: m is spinning")
	}
	if mp.nextp != 0 {
		throw("startm: m has p")
	}
	if spinning && !runqempty(_p_) {
		throw("startm: p has runnable gs")
	}
	// 由调用者确定是否自旋，并将m.nextp设置为p
	mp.spinning = spinning
	mp.nextp.set(_p_)
	notewakeup(&mp.park)
}
```

`startm`函数主要流程：
* 获取一个`p`，失败则返回
  * 获取一个`m`，如果失败就创建`m`并返回
* `m`暂存`p`

### newm

```go
func newm(fn func(), _p_ *p, id int64) {
	mp := allocm(_p_, fn, id) // 创建新m
	mp.nextp.set(_p_) // 暂存p
	mp.sigmask = initSigmask // 信号掩码
	newm1(mp) // 绑定操作系统线程
}
```

```go
func allocm(_p_ *p, fn func(), id int64) *m {
	_g_ := getg()
	acquirem() // disable GC because it can be called from sysmon
	if _g_.m.p == 0 {
		acquirep(_p_) // 临时绑定p
	}

    // 清理可以安全删除的m的g0栈信息
	if sched.freem != nil { 
		lock(&sched.lock)
		var newList *m
		for freem := sched.freem; freem != nil; {
			if freem.freeWait != 0 {
				next := freem.freelink
				freem.freelink = newList
				newList = freem
				freem = next
				continue
			}
			stackfree(freem.g0.stack) // 清空freem.g0的栈信息
			freem = freem.freelink
		}
		sched.freem = newList // 更新已被释放的m列表
		unlock(&sched.lock)
	}

	mp := new(m)
	mp.mstartfn = fn // 绑定m启动函数
	mcommoninit(mp, id) // 绑定mp的id

	// 初始化g0栈信息
	if iscgo || GOOS == "solaris" || GOOS == "illumos" || GOOS == "windows" || GOOS == "plan9" || GOOS == "darwin" || GOOS == "ios" {
		mp.g0 = malg(-1)
	} else {
		mp.g0 = malg(8192 * sys.StackGuardMultiplier)
	}
	mp.g0.m = mp

	if _p_ == _g_.m.p.ptr() {
		releasep() // 解绑p
	}
	releasem(_g_.m)

	return mp
}
```

```go
func newm1(mp *m) {
	execLock.rlock() // Prevent process clone.
	newosproc(mp) // 绑定操作系统线程
	execLock.runlock()
}
```

`newm`函数主要流程：
* 释放可以清理的`m`的`g0`栈空间
* 新建`m`，绑定`id`和启动函数，申请`g0`栈空间
* `m`暂存当前`p`
* 创建与`m`对应的操作系统线程


## netpoll
`netpoll`可以让调度器从就绪的网络事件中获取可执行的goroutine。
由于golang对每个系统的netpoll做了条件编译，这里就拿linux的实现来说明。
```go
func netpoll(delay int64) gList {
	var events [128]epollevent
retry:
	n := epollwait(epfd, &events[0], int32(len(events)), waitms)
	
	var toRun gList
	for i := int32(0); i < n; i++ {
		ev := &events[i]
		var mode int32
		if ev.events&(_EPOLLIN|_EPOLLRDHUP|_EPOLLHUP|_EPOLLERR) != 0 {
			mode += 'r'
		}
		if ev.events&(_EPOLLOUT|_EPOLLHUP|_EPOLLERR) != 0 {
			mode += 'w'
		}
		if mode != 0 {
			pd := *(**pollDesc)(unsafe.Pointer(&ev.data))
			pd.everr = false
			if ev.events == _EPOLLERR {
				pd.everr = true
			}
			netpollready(&toRun, pd, mode) // 将符合的g填充进toRun中
		}
	}
	return toRun
}
```

`netpoll`函数主要流程：
* 调用`epollwait`获取就绪的文件描述符
* 将`pd`中的就绪`g`追加进`toRun`里面
* 返回`toRun`

# 调度
```go
// runtime/proc.go

func schedule() {
	_g_ := getg()

	// 如果_g_绑定的m有锁定的g，则抛弃_g_，转而执行锁定的g
	if _g_.m.lockedg != 0 {
		stoplockedm()
		execute(_g_.m.lockedg.ptr(), false) // Never returns.
	}

top:
	pp := _g_.m.p.ptr()
	pp.preempt = false

	// 如果准备GC，则休眠当前m，直到被唤醒
	if sched.gcwaiting != 0 {
		gcstopm()
		goto top
	}
	if pp.runSafePointFn != 0 {
		runSafePointFn()
	}

	checkTimers(pp, 0)

	var gp *g
	var inheritTime bool

	tryWakeP := false
	if trace.enabled || trace.shutdown {
		gp = traceReader()
		if gp != nil {
			casgstatus(gp, _Gwaiting, _Grunnable)
			traceGoUnpark(gp, 0)
			tryWakeP = true
		}
	}
	if gp == nil && gcBlackenEnabled != 0 {
		// 找GCWorker
		gp = gcController.findRunnableGCWorker(_g_.m.p.ptr())
		tryWakeP = tryWakeP || gp != nil
	}
	if gp == nil {
		// 为了让全局可执行队列的g能够运行，这里每操作一定次数就从全局队列中获取
		if _g_.m.p.ptr().schedtick%61 == 0 && sched.runqsize > 0 {
			lock(&sched.lock)
			gp = globrunqget(_g_.m.p.ptr(), 1)
			unlock(&sched.lock)
		}
	}
	if gp == nil {
		// 从本地可执行队列中获取
		gp, inheritTime = runqget(_g_.m.p.ptr())
	}
	if gp == nil {
		// 从其他地方找一个g来执行，如果没有则阻塞在这里
		gp, inheritTime = findrunnable() // blocks until work is available
	}

	// This thread is going to run a goroutine and is not spinning anymore,
	// so if it was marked as spinning we need to reset it now and potentially
	// start a new spinning M.
	if _g_.m.spinning {
		// 如果当前m正在自旋，则重置自旋状态
		resetspinning()
	}
	
	if tryWakeP {
		wakep() // GCworker 或 tracereader 需要唤醒p
	}
	if gp.lockedm != 0 {
		// m将自己的p让给gp锁定的m，自己阻塞等待新p
		startlockedm(gp)
		goto top
	}

	execute(gp, inheritTime) // 执行gp
}
```

`schedule`函数主要流程：
* 如果`g`有绑定的`m`，则直接让绑定`m`执行`g`
* 如果要GC，则休眠当前`m`，等待唤醒
* 从`traceReader`、`GCWorker`、`globrunqget`、`runqget`、`findrunnable`函数中获取一个可执行gp
* 重置自旋状态
* 如果需要唤醒`p`，则尝试唤醒`p`
* 如果获取的`gp`有锁定的`m`，则让出自己的`p`给`gp`锁定的`m`，自己则阻塞等待被唤醒
* 执行`gp`

## findrunnable
```go
// runtime/proc.go

func findrunnable() (gp *g, inheritTime bool) {
	_g_ := getg()

top:
	_p_ := _g_.m.p.ptr()
	if sched.gcwaiting != 0 {
		gcstopm()
		goto top
	}
	if _p_.runSafePointFn != 0 {
		runSafePointFn()
	}

	now, pollUntil, _ := checkTimers(_p_, 0)

    // 如果有finalizer可用，直接唤醒
	if fingwait && fingwake {
		if gp := wakefing(); gp != nil {
			ready(gp, 0, true)
		}
	}

	// 本地获取
	if gp, inheritTime := runqget(_p_); gp != nil {
		return gp, inheritTime
	}

	// 全局获取
	// global runq
	if sched.runqsize != 0 {
		lock(&sched.lock)
		gp := globrunqget(_p_, 0)
		unlock(&sched.lock)
		if gp != nil {
			return gp, false
		}
	}

	// 没有可以执行的goroutine

	// 获取网络事件完成的gp，优化
	if netpollinited() && atomic.Load(&netpollWaiters) > 0 && atomic.Load64(&sched.lastpoll) != 0 {
		if list := netpoll(0); !list.empty() { // non-blocking
			gp := list.pop()
			injectglist(&list)
			casgstatus(gp, _Gwaiting, _Grunnable)
			if trace.enabled {
				traceGoUnpark(gp, 0)
			}
			return gp, false
		}
	}

	// 从其他的P偷取
	// Steal work from other P's.
	procs := uint32(gomaxprocs)
	ranTimer := false
	
    // 将m置为自旋状态
	if !_g_.m.spinning {
		_g_.m.spinning = true
		atomic.Xadd(&sched.nmspinning, 1)
	}

    // 随机从别的p中偷取4次
	for i := 0; i < 4; i++ {
		for enum := stealOrder.start(fastrand()); !enum.done(); enum.next() {
			if sched.gcwaiting != 0 {
				goto top
			}
			stealRunNextG := i > 2 // first look for ready queues with more than 1 g
			p2 := allp[enum.position()]
			if _p_ == p2 {
				continue
			}
			if gp := runqsteal(_p_, p2, stealRunNextG); gp != nil {
				return gp, false
			}

			if i > 2 || (i > 1 && shouldStealTimers(p2)) {
				tnow, w, ran := checkTimers(p2, now)
				now = tnow
				if w != 0 && (pollUntil == 0 || w < pollUntil) {
					pollUntil = w
				}
				if ran {
					if gp, inheritTime := runqget(_p_); gp != nil {
						return gp, inheritTime
					}
					ranTimer = true
				}
			}
		}
	}
	if ranTimer {
		// Running a timer may have made some goroutine ready.
		goto top
	}
	// ... 省略 ...    
}
```

`findrunnable`函数主要流程：
* 如果有`finalizer`可执行`gp`，直接唤醒
* 如果从本地可执行队列中获取可执行`gp`，返回`gp`
* 如果从全局可执行队列中获取可执行`gp`，返回`gp`
* 如果有就绪的网络事件的`gp`，返回`gp`
* 从其他的`p`中偷取部分`gp`，返回`gp`

### runqsteal
```go
// runtime/proc.go

func runqsteal(_p_, p2 *p, stealRunNextG bool) *g {
	t := _p_.runqtail
	n := runqgrab(p2, &_p_.runq, t, stealRunNextG)
	if n == 0 {
		return nil
	}
	n--
	gp := _p_.runq[(t+n)%uint32(len(_p_.runq))].ptr()
	if n == 0 {
		return gp
	}
	h := atomic.LoadAcq(&_p_.runqhead)
	atomic.StoreRel(&_p_.runqtail, t+n)
	return gp
}
```

`runqsteal`函数主要流程：
* 获取本地队列队尾坐标
* 从`p2`中获取部分可执行队列
* 如果只偷取了一个，直接返回
* 否则需要原子修改可执行队列的首尾指针

#### runqgrab
```
// runtime/proc.go

func runqgrab(_p_ *p, batch *[256]guintptr, batchHead uint32, stealRunNextG bool) uint32 {
	for {
		h := atomic.LoadAcq(&_p_.runqhead)
		t := atomic.LoadAcq(&_p_.runqtail) 
		n := t - h
		n = n - n/2
		if n == 0 {
			if stealRunNextG {
				// Try to steal from _p_.runnext.
				if next := _p_.runnext; next != 0 {
					// 休眠让p不会执行将要偷取的
					if _p_.status == _Prunning {
						if GOOS != "windows" {
							usleep(3)
						} else {
							osyield()
						}
					}
					if !_p_.runnext.cas(next, 0) {
						continue
					}
					batch[batchHead%uint32(len(batch))] = next
					return 1
				}
			}
			return 0
		}
		if n > uint32(len(_p_.runq)/2) { // 保证队列没有改动
			continue
		}
		// 偷取前半g可执行队列
		for i := uint32(0); i < n; i++ {
			g := _p_.runq[(h+i)%uint32(len(_p_.runq))]
			batch[(batchHead+i)%uint32(len(batch))] = g
		}
		// 提交本次消费，如果失败则从新再试一次
		if atomic.CasRel(&_p_.runqhead, h, h+n) {
			return n
		}
	}
}
```

runqgrab函数主要流程：
* 原子获取待偷取`p`可执行队列首尾位置
* 如果没有，则判断是否需要偷取`next`指针的`gp`
* 复制`p`的前半部分可执行队列
* 原子的修改`p`的可执行队列的首尾指针位置

## execute
```go
// runtime/proc.go

func execute(gp *g, inheritTime bool) {
	_g_ := getg()

    // 互相绑定 _g_.m.curg = gp
    gp.m = _g_.m
    casgstatus(gp, _Grunnable, _Grunning) // 转换状态
	gp.waitsince = 0
	gp.preempt = false
	gp.stackguard0 = gp.stack.lo + _StackGuard
	if !inheritTime {
		_g_.m.p.ptr().schedtick++
	}

	gogo(&gp.sched)
}
```

`execute`函数主要流程：
* `m`和`g`相互绑定
* 设置相关值
* 调用`gogo`函数执行`gp`

### gogo
```asm
// runtime/asm_amd64.s

TEXT runtime·gogo(SB), NOSPLIT, $16-8
	MOVQ	buf+0(FP), BX		// gobuf
	MOVQ	gobuf_g(BX), DX
	MOVQ	0(DX), CX		// make sure g != nil
	get_tls(CX)
	MOVQ	DX, g(CX)
	MOVQ	gobuf_sp(BX), SP	// restore SP
	MOVQ	gobuf_ret(BX), AX
	MOVQ	gobuf_ctxt(BX), DX
	MOVQ	gobuf_bp(BX), BP
	MOVQ	$0, gobuf_sp(BX)	// clear to help garbage collector
	MOVQ	$0, gobuf_ret(BX)
	MOVQ	$0, gobuf_ctxt(BX)
	MOVQ	$0, gobuf_bp(BX)
	MOVQ	gobuf_pc(BX), BX
	JMP	BX
```

`gogo`函数主要流程：
* 将`gobuf`的内容存放到相关寄存器中
* 将`gobuf`的内容清空
* 执行`gobuf.pc`

## Gosched
除了上述的通过运行时启动调度之外，golang还提供了手动的调度函数`Gosched`函数，该函数在运行时内外都可以触发下一次调度。
```go
func Gosched() {
	checkTimeouts()
	mcall(gosched_m)
}
```

```go
func gosched_m(gp *g) {
	goschedImpl(gp)
}
```

```go
func goschedImpl(gp *g) {
	status := readgstatus(gp)
	if status&^_Gscan != _Grunning {
		dumpgstatus(gp)
		throw("bad g status")
	}
	casgstatus(gp, _Grunning, _Grunnable)
	dropg() // 解绑g和m
	lock(&sched.lock)
	globrunqput(gp) // 放入全局可执行队列
	unlock(&sched.lock)

	schedule() // 下一次调度
}
```

Gosched函数主要流程：
* 获取gp的状态
* 切换gp的状态为_Grunnable
* 解绑g和m
* 将g存入全局可执行队列中
* 启动下一次调度

# 销毁
```asm
TEXT runtime·goexit(SB),NOSPLIT,$0-0
	BYTE	$0x90	// NOP
	CALL	runtime·goexit1(SB)	// does not return
	// traceback from goexit1 must hit code range of goexit
	BYTE	$0x90	// NOP
```

```go
func goexit1() {
   if raceenabled {
      racegoend()
   }
   if trace.enabled {
      traceGoEnd()
   }
   mcall(goexit0)
}
```

```go
func goexit0(gp *g) {
	_g_ := getg()

    // 切换g的状态 
    casgstatus(gp, _Grunning, _Gdead)
    // 标记系统goroutine 
    if isSystemGoroutine(gp, false) {
       atomic.Xadd(&sched.ngsys, -1)
    }
	// 清理gp相关的数据
	gp.m = nil
	locked := gp.lockedm != 0
	gp.lockedm = 0
	_g_.m.lockedg = 0
	gp.preemptStop = false
	gp.paniconfault = false
	gp._defer = nil // should be true already but just in case.
	gp._panic = nil // non-nil for Goexit during panic. points at stack-allocated data.
	gp.writebuf = nil
	gp.waitreason = 0
	gp.param = nil
	gp.labels = nil
	gp.timer = nil

	dropg() // 解绑当前m和gp

	if GOARCH == "wasm" { // no threads yet on wasm
		gfput(_g_.m.p.ptr(), gp) // 将gp存放到p的空闲列表中
		schedule() // 下一次调度
	}

	gfput(_g_.m.p.ptr(), gp) // 将gp存放到p的空闲列表中
	if locked {
		// 如果gp锁定了m，则将这个m杀死
		if GOOS != "plan9" { 
			gogo(&_g_.m.g0.sched)
		} else {
			_g_.m.lockedExt = 0
		}
	}
	schedule() // 下一次调度
}
```

`goexit0`函数主要流程：
* 切换`g`的状态
* 解绑`g`所有绑定的数据
* 如果是`wasm`架构，直接将`g`存于空闲列表中，并开始下一次调度
* 否则，直接将`g`存于空闲列表中，如果`g`有锁定的`m`，则将`m`杀死，开始下一次调度

# 切换
## 执行完毕切换
上面说到，当goroutine执行完毕时，会执行goexit0函数，进而执行下一次调度
## 主动切换
当goroutine中阻塞的操作时，就需要让出CPU，让其他的goroutine执行。所有主动切换都是调用gopark函数来实现的。
### gopark
```go
func gopark(unlockf func(*g, unsafe.Pointer) bool, lock unsafe.Pointer, reason waitReason, traceEv byte, traceskip int) {
	if reason != waitReasonSleep {
		checkTimeouts()
	}
	mp := acquirem()
	gp := mp.curg
	status := readgstatus(gp)
	if status != _Grunning && status != _Gscanrunning {
		throw("gopark: bad g status")
	}
	// 填充相关参数
	mp.waitlock = lock
	mp.waitunlockf = unlockf
	gp.waitreason = reason
	mp.waittraceev = traceEv
	mp.waittraceskip = traceskip
	releasem(mp)
	// can't do anything that might move the G between Ms here.
	mcall(park_m)
}
```

`gopark`函数主要流程：
* 获取当前`m`绑定的`gp`
* 填充相关参数
* 利用`g0`调用`park_m`函数

```go
func park_m(gp *g) {
	_g_ := getg()

	casgstatus(gp, _Grunning, _Gwaiting)
	dropg() // 解绑g和m

	if fn := _g_.m.waitunlockf; fn != nil {
		ok := fn(gp, _g_.m.waitlock) // 尝试调用解锁函数
		_g_.m.waitunlockf = nil
		_g_.m.waitlock = nil
		if !ok {
			// 如果解锁成功
			casgstatus(gp, _Gwaiting, _Grunnable)
			execute(gp, true) // 直接执行gp
		}
	}
	schedule() // 下一次调度
}
```

`park_m`函数主要流程：
* 切换`g`的状态为等待
* 尝试解锁，如果成功则切换状态为可执行，直接调用`execute`函数执行
* 否则，进入下一个调度

### goready
当goroutine通过`gopark`函数由`_Grunning`到`_Gwaiting`，反向操作`goready`函数则是将`_Gwaiting`到`_Grunnable`。
```go
func goready(gp *g, traceskip int) {
	systemstack(func() {
		ready(gp, traceskip, true)
	})
}
```

```go
func ready(gp *g, traceskip int, next bool) {
	status := readgstatus(gp)

	_g_ := getg()
	mp := acquirem()
	// 如果不是 _Gwaiting 抛异常
	if status&^_Gscan != _Gwaiting {
		dumpgstatus(gp)
		throw("bad g->status in ready")
	}

    // 切换状态
	casgstatus(gp, _Gwaiting, _Grunnable)
	runqput(_g_.m.p.ptr(), gp, next) // 存放到本地可执行队列中
	wakep()                          // 尝试去唤起p去执行
	releasem(mp)
}
```

`ready`函数主要流程：
* 获取`gp`的状态
* 获取当前的`g`
* 检测`gp`状态是不是`_Gwaiting`
* 由`_Gwaiting`转换为`_Grunnable`状态
* 放进当前`g`的`m`的`p`中的本地可执行队列中

## 抢占切换
golang调度本质上是非抢占式的，golang利用标志位标志当前的goroutine是否可以被抢占，而触发时机是在栈扩容的时候。
golang中有个监控函数，监控着整个进程运行的相关数据，其中就包括检查某个goroutine是否占用CPU时间过长，从而进行标记抢占标记位。
```go
func sysmon() {
    // ... 省略 ...
    
	for {
		// ... 省略 ...
		
		// 解绑在陷入系统调用中的p，和抢占长时间运行的g
		if retake(now) != 0 {
			idle = 0
		} else {
			idle++
		}
		
		// ... 省略 ...
	}
}
```


### retake
```go
func retake(now int64) uint32 {
	n := 0
	lock(&allpLock)
	for i := 0; i < len(allp); i++ {
		_p_ := allp[i]
		if _p_ == nil {
			continue
		}
		pd := &_p_.sysmontick // sysmon 信息记录
		s := _p_.status
		sysretake := false
		if s == _Prunning || s == _Psyscall {
			// 处于 _Prunning 或者 _Psyscall 状态时，如果上一次触发调度的时间已经过去了 10ms，
			// 我们就会通过 runtime.preemptone 抢占当前处理器
			// 如果G运行时间太长则抢占G
			t := int64(_p_.schedtick)
			if int64(pd.schedtick) != t {
				pd.schedtick = uint32(t)
				pd.schedwhen = now
			} else if pd.schedwhen+forcePreemptNS <= now {
				preemptone(_p_)
				// 在_Psyscall时preemptone函数不会工作，因为m没有绑定p
				sysretake = true
			}
		}
		if s == _Psyscall {
			// 当处理器处于 _Psyscall 状态时
			// 当处理器的运行队列不为空或者不存在空闲处理器时并且当系统调用时间超过了 10ms 时
			t := int64(_p_.syscalltick)
			if !sysretake && int64(pd.syscalltick) != t {
				pd.syscalltick = uint32(t)
				pd.syscallwhen = now
				continue
			}
			
			if runqempty(_p_) && atomic.Load(&sched.nmspinning)+atomic.Load(&sched.npidle) > 0 && pd.syscallwhen+10*1000*1000 > now {
				// 如果_p_没有可执行的g，且有自旋的m或空闲的p，且系统调用时间没有超过10ms
				continue
			}
			// Drop allpLock so we can take sched.lock.
			unlock(&allpLock)
			
			// 将p的状态设置为_Pidle，计数器n加1，_p_的系统调用次数+1
			incidlelocked(-1)
			if atomic.Cas(&_p_.status, s, _Pidle) {
				n++
				_p_.syscalltick++
				handoffp(_p_) // 让 p 去找其他的事情干
			}
			incidlelocked(1)
			lock(&allpLock)
		}
	}
	unlock(&allpLock)
	return uint32(n)
}
```

`retake`函数主要流程：
* 遍历所有的`p`
* 如果`p`长时间没有调度则标记抢占标志位
* 如果`p`在系统调用中，且超过阈值时间，则解绑`p`
* 返回解绑`p`的个数

### preemptone
```go
func preemptone(_p_ *p) bool {
	mp := _p_.m.ptr()
	if mp == nil || mp == getg().m {
		// 如果mp为空，或mp是当前运行的m
		return false
	}
	gp := mp.curg
	if gp == nil || gp == mp.g0 {
		// gp 不能使 g0
		return false
	}

	gp.preempt = true // 标志gp可以被抢占

	gp.stackguard0 = stackPreempt // 直接设置为栈顶，方便触发栈扩容

	// Request an async preemption of this P.
	if preemptMSupported && debug.asyncpreemptoff == 0 {
		_p_.preempt = true // 标记p快速调度
		preemptM(mp)       // 向mp发送抢占信号
	}

	return true
}
```

### handoffp
```go
func handoffp(_p_ *p) {
	// 如果本地有可执行的G或全局可执行队列长度不为0，则直接开始执行
	if !runqempty(_p_) || sched.runqsize != 0 {
		startm(_p_, false)
		return
	}
	// 如果可以执行GC，则立即执行
	if gcBlackenEnabled != 0 && gcMarkWorkAvailable(_p_) {
		startm(_p_, false)
		return
	}
	// 如果没有自旋的m和空闲的p，并且增加自旋数成功，则让_p_绑定一个m进入自旋
	if atomic.Load(&sched.nmspinning)+atomic.Load(&sched.npidle) == 0 && atomic.Cas(&sched.nmspinning, 0, 1) {
		startm(_p_, true)
		return
	}
	lock(&sched.lock)
	if sched.gcwaiting != 0 { // 即将GC
		_p_.status = _Pgcstop
		sched.stopwait--
		if sched.stopwait == 0 {
			notewakeup(&sched.stopnote)
		}
		unlock(&sched.lock)
		return
	}
	if _p_.runSafePointFn != 0 && atomic.Cas(&_p_.runSafePointFn, 1, 0) {
		sched.safePointFn(_p_)
		sched.safePointWait--
		if sched.safePointWait == 0 {
			notewakeup(&sched.safePointNote)
		}
	}
	// 此时如果全局队列有可执行的g，则执行
	if sched.runqsize != 0 {
		unlock(&sched.lock)
		startm(_p_, false)
		return
	}
	// 如果这是最后运行的P并且没有人正在轮询网络，则需要唤醒另一个M来轮询网络。
	if sched.npidle == uint32(gomaxprocs-1) && atomic.Load64(&sched.lastpoll) != 0 {
		unlock(&sched.lock)
		startm(_p_, false)
		return
	}
	if when := nobarrierWakeTime(_p_); when != 0 {
		wakeNetPoller(when)
	}
	// 都没有则将_p_存放到空闲P列表中
	pidleput(_p_)
	unlock(&sched.lock)
}
```

`retake`函数主要流程：
* 如果`p`的本地可执行队列不为空，或全局可执行队列不为空，则绑定`m`去执行
* 如果`p`可以执行GC工作，则绑定m去执行
* 如果没有m在自旋且没有空闲的`p`，且成功设置自旋值，则获取一个`m`，进入自旋
* 如果此时在检测全局可执行队列是否为空，有则绑定`m`去执行
* 如果是最后一个正在运行的`p`，则绑定`m`去轮询网络
* 都没有则将`p`存放进空闲`p`列表

### newstack
```go
func newstack() {
	thisg := getg() // 当前执行的g
	
	gp := thisg.m.curg // m绑定的g

	// 判断是否抢占触发的栈扩张
	preempt := atomic.Loaduintptr(&gp.stackguard0) == stackPreempt

    // ... 省略 ...

	if preempt {
		// Act like goroutine called runtime.Gosched.
		gopreempt_m(gp) // never return
	}
    // ... 省略 ...
}
```

```go
func gopreempt_m(gp *g) {
	if trace.enabled {
		traceGoPreempt()
	}
	goschedImpl(gp)
}
```

`goschedImpl`函数就是上述Gosched函数的主要执行实体了。

如果检测到是抢占，则将m绑定的g放入全局可执行队列中。


## 系统调用切换
golang提供了系统调用接口：
```go
func Syscall(trap, a1, a2, a3 uintptr) (r1, r2 uintptr, err Errno)
func RawSyscall(trap, a1, a2, a3 uintptr) (r1, r2 uintptr, err Errno)
```

更多参数可以调用Syscall6或Syscall9。

### Syscall
```asm
TEXT	·Syscall(SB),NOSPLIT,$0-56
	CALL	runtime·entersyscall(SB)
	MOVQ	a1+8(FP), DI
	MOVQ	a2+16(FP), SI
	MOVQ	a3+24(FP), DX
	MOVQ	trap+0(FP), AX	// syscall entry
	ADDQ	$0x2000000, AX
	SYSCALL
	JCC	ok
	MOVQ	$-1, r1+32(FP)
	MOVQ	$0, r2+40(FP)
	MOVQ	AX, err+48(FP)
	CALL	runtime·exitsyscall(SB)
	RET
ok:
	MOVQ	AX, r1+32(FP)
	MOVQ	DX, r2+40(FP)
	MOVQ	$0, err+48(FP)
	CALL	runtime·exitsyscall(SB)
	RET
```

`Syscall`函数主要流程：
* 调用`runtime.entersyscall`
* 将参数存至寄存器
* 执行系统调用
* 将返回值压栈
* 调用`runtime.exitsyscall`

#### entersyscall
```go
func entersyscall() {
   reentersyscall(getcallerpc(), getcallersp())
}
```

```go
func reentersyscall(pc, sp uintptr) {
	_g_ := getg()
	_g_.m.locks++

	_g_.stackguard0 = stackPreempt // 等待被抢占
	_g_.throwsplit = true

	// Leave SP around for GC and traceback.
	save(pc, sp) // 保存现场
	_g_.syscallsp = sp
	_g_.syscallpc = pc
	casgstatus(_g_, _Grunning, _Gsyscall) // 切换状态
	if _g_.syscallsp < _g_.stack.lo || _g_.stack.hi < _g_.syscallsp {
		systemstack(func() {
			print("entersyscall inconsistent ", hex(_g_.syscallsp), " [", hex(_g_.stack.lo), ",", hex(_g_.stack.hi), "]\n")
			throw("entersyscall")
		})
	}

	if trace.enabled {
		systemstack(traceGoSysCall)
		// systemstack itself clobbers g.sched.{pc,sp} and we might
		// need them later when the G is genuinely blocked in a
		// syscall
		save(pc, sp)
	}

	if atomic.Load(&sched.sysmonwait) != 0 {
		systemstack(entersyscall_sysmon)
		save(pc, sp)
	}

	if _g_.m.p.ptr().runSafePointFn != 0 {
		// runSafePointFn may stack split if run on this stack
		systemstack(runSafePointFn)
		save(pc, sp)
	}

	_g_.m.syscalltick = _g_.m.p.ptr().syscalltick
	_g_.sysblocktraced = true
	pp := _g_.m.p.ptr()
	pp.m = 0
	_g_.m.oldp.set(pp)
	_g_.m.p = 0
	atomic.Store(&pp.status, _Psyscall) // 切换p的状态
	if sched.gcwaiting != 0 {
		systemstack(entersyscall_gcwait)
		save(pc, sp)
	}

	_g_.m.locks--
}
```

#### exitsyscall
```go
func exitsyscall() {
	_g_ := getg()

	_g_.m.locks++ 

	oldp := _g_.m.oldp.ptr()
	_g_.m.oldp = 0
	if exitsyscallfast(oldp) { // 尝试获取系统调用前绑定的p
		_g_.m.p.ptr().syscalltick++
		casgstatus(_g_, _Gsyscall, _Grunning)
		_g_.syscallsp = 0
		_g_.m.locks--
		if _g_.preempt {
			// 如果抢占，就设置stackguard0为stackPreempt
			_g_.stackguard0 = stackPreempt
		} else {
			// 否则恢复真实栈帧
			_g_.stackguard0 = _g_.stack.lo + _StackGuard
		}
		_g_.throwsplit = false

		if sched.disable.user && !schedEnabled(_g_) {
			// Scheduling of this goroutine is disabled.
			Gosched() // 开始调度
		}

		return
	}

	// 没有p被绑定的情况
	_g_.sysexitticks = 0
	_g_.m.locks--

	// Call the scheduler.
	mcall(exitsyscall0)

	_g_.syscallsp = 0
	_g_.m.p.ptr().syscalltick++
	_g_.throwsplit = false
}
```

`exitsyscall`函数主要流程：
* 获取系统调用前绑定的`oldp`
* 尝试获取`oldp`或从空闲列表获取`p`
* 如果成功获取`p`，改变相关设置，开始下一轮调度
* 如果没有获取，则调用`exitsyscall0`

```go
func exitsyscall0(gp *g) {
	_g_ := getg()

	casgstatus(gp, _Gsyscall, _Grunnable)
	dropg()
	lock(&sched.lock)
	var _p_ *p
	if schedEnabled(_g_) { // 如果可以调度_g_
		_p_ = pidleget() // 从p空闲列表中获取p
	}
	if _p_ == nil {
		globrunqput(gp) // 没有可用的p，就将gp存放于全局可执行列表中
	} else if atomic.Load(&sched.sysmonwait) != 0 {
		atomic.Store(&sched.sysmonwait, 0)
		notewakeup(&sched.sysmonnote)
	}
	unlock(&sched.lock)
	if _p_ != nil { // 如果有可用的p
		acquirep(_p_) // 直接绑定当前的m
		execute(gp, false) // 执行gp
	}
	if _g_.m.lockedg != 0 { // 如果m有锁定的g
		// Wait until another thread schedules gp and so m again.
		stoplockedm()   // 释放p，休眠m，会阻塞
		execute(gp, false) // 执行gp
	}
	stopm() // 将m休眠，并存于m空闲列表中，会阻塞
	schedule() // 下一次调度
}
```

`exitsyscall0`函数主要流程：
* 切换`gp`状态为`_Grunnable`
* 解绑`g`和`m`
* 尝试获取一个空闲的`_p_`
* 如果没有获取到就把`gp`放到全局可执行列表中
* 如果获取到了，就直接绑定当前的`m`，执行`gp`
* 如果有`m`有锁定的`g`，释放p，休眠m，等待被唤醒
* 否则`m`将放置与全局`m`空闲列表中，等待下一次调度

exitsyscall0函数如果没有p则会将m休眠

### RawSyscall
```asm
TEXT ·RawSyscall(SB),NOSPLIT,$0-56
	MOVQ	a1+8(FP), DI
	MOVQ	a2+16(FP), SI
	MOVQ	a3+24(FP), DX
	MOVQ	trap+0(FP), AX	// syscall entry
	ADDQ	$0x2000000, AX
	SYSCALL
	JCC	ok1
	MOVQ	$-1, r1+32(FP)
	MOVQ	$0, r2+40(FP)
	MOVQ	AX, err+48(FP)
	RET
ok1:
	MOVQ	AX, r1+32(FP)
	MOVQ	DX, r2+40(FP)
	MOVQ	$0, err+48(FP)
	RET
```

`RawSyscall`函数主要流程：
* 将参数存至寄存器
* 执行系统调用
* 将返回值压栈

`RawSyscall`函数并没有执行`runtime.entersyscall`和`runtime.exitsyscall`函数，由于没有执行相关操作导致golang无法准确的调度，可能会导致长时间系统调用，其他的goroutine无法得到执行。



# 辅助函数
## getg
获取当前的`g`，由于是编译器填充的，所以没有源码。
一般都是从TLS寄存器获取的。
## mcall
```asm
TEXT runtime·mcall(SB), NOSPLIT, $0-8
	MOVQ	fn+0(FP), DI

	get_tls(CX)
	MOVQ	g(CX), AX	// save state in g->sched
	MOVQ	0(SP), BX	// caller's PC
	MOVQ	BX, (g_sched+gobuf_pc)(AX)
	LEAQ	fn+0(FP), BX	// caller's SP
	MOVQ	BX, (g_sched+gobuf_sp)(AX)
	MOVQ	AX, (g_sched+gobuf_g)(AX)
	MOVQ	BP, (g_sched+gobuf_bp)(AX)

	// switch to m->g0 & its stack, call fn
	MOVQ	g(CX), BX
	MOVQ	g_m(BX), BX
	MOVQ	m_g0(BX), SI
	CMPQ	SI, AX	// if g == m->g0 call badmcall
	JNE	3(PC)
	MOVQ	$runtime·badmcall(SB), AX
	JMP	AX
	MOVQ	SI, g(CX)	// g = m->g0
	MOVQ	(g_sched+gobuf_sp)(SI), SP	// sp = m->g0->sched.sp
	PUSHQ	AX
	MOVQ	DI, DX
	MOVQ	0(DI), DI
	CALL	DI // 执行fn，不能返回
	POPQ	AX
	MOVQ	$runtime·badmcall2(SB), AX
	JMP	AX
	RET
```

`mcall`函数切换到`m`的`g0`调用`fn(g)`，`fn`是不能返回的。

## systemstack
```asm
TEXT runtime·systemstack(SB), NOSPLIT, $0-8
	MOVQ	fn+0(FP), DI	// DI = fn
	get_tls(CX)
	MOVQ	g(CX), AX	// AX = g
	MOVQ	g_m(AX), BX	// BX = m

	CMPQ	AX, m_gsignal(BX) // g == m.gsignal
	JEQ	noswitch

	MOVQ	m_g0(BX), DX	// DX = g0
	CMPQ	AX, DX // g == g0
	JEQ	noswitch

	CMPQ	AX, m_curg(BX) // g == m.curg
	JNE	bad

	// 保存当前g的栈信息
	MOVQ	$runtime·systemstack_switch(SB), SI
	MOVQ	SI, (g_sched+gobuf_pc)(AX)
	MOVQ	SP, (g_sched+gobuf_sp)(AX)
	MOVQ	AX, (g_sched+gobuf_g)(AX)
	MOVQ	BP, (g_sched+gobuf_bp)(AX)

	// 切换到g0
	MOVQ	DX, g(CX)
	MOVQ	(g_sched+gobuf_sp)(DX), BX
	// make it look like mstart called systemstack on g0, to stop traceback
	SUBQ	$8, BX
	MOVQ	$runtime·mstart(SB), DX
	MOVQ	DX, 0(BX)
	MOVQ	BX, SP

	// call target function
	MOVQ	DI, DX
	MOVQ	0(DI), DI
	CALL	DI // 执行目标函数

	// 恢复原有g
	get_tls(CX)
	MOVQ	g(CX), AX
	MOVQ	g_m(AX), BX
	MOVQ	m_curg(BX), AX
	MOVQ	AX, g(CX)
	MOVQ	(g_sched+gobuf_sp)(AX), SP
	MOVQ	$0, (g_sched+gobuf_sp)(AX)
	RET
```

systemstack函数主要流程：
* 检测相关参数
* 保存g现场
* 切换到g0，并执行fn(g)
* 恢复原有g

## acquirem
```go
func acquirem() *m {
	_g_ := getg()
	_g_.m.locks++
	return _g_.m
}
```
`acquirem`函数主要是增加`locks`引用计数，并返回当前的m。主要是防止GC回收m。

## releasem
```go
func releasem(mp *m) {
	_g_ := getg()
	mp.locks--
	if mp.locks == 0 && _g_.preempt {
		_g_.stackguard0 = stackPreempt
	}
}
```

`releasem`函数主要是减少`locks`引用计数，并判断是否需要`g`被抢占

## acquirep
```go
func acquirep(_p_ *p) {
	wirep(_p_)
}
```

```go
func wirep(_p_ *p) {
	_g_ := getg()
	_g_.m.p.set(_p_)
	_p_.m.set(_g_.m)
	_p_.status = _Prunning
}
```

`acquirep`函数主要流程：
* 绑定`p`和`m`
* 将`p`的状态置为`_Prunning`

## releasep
```go
func releasep() *p {
	_g_ := getg()
	_p_ := _g_.m.p.ptr()
	_g_.m.p = 0
	_p_.m = 0
	_p_.status = _Pidle
	return _p_
}
```

`releasep`函数主要流程：
* 解绑`m`和`p`
* 将`p`的状态置为`_Pidle`
* 返回`p`

# 疑问
## p的本地可执行列表无锁，其他p怎么偷取可执行列表
通过原子cas的方式提交列表头尾位置，如果失败则重新偷取。

## g进入_Gwaiting状态后去哪里了

* 如果`g`是被抢占了，则将g的状态改为`_Grunnable`，放入全局可执行队列中
* 如果是主动切换，调用`gopark`的调用者需要维护`sudog`列表（`sudog`用于保存调用`gopark`的`g`），接收已完成的`goroutine`，然后调用`goready`，将他们状态置为`_Grunnable`，存入本地的可执行队列中。

## m进入自旋，在干嘛
`m`自旋，即`m`阻塞于`schedule()`的`findrunnable()`，`m`会一直尝试获取可执行的`g`去工作。

## g0栈复用
`g0`的栈在golang中不同系统采用不同的初始化方式。
```go
if iscgo || GOOS == "solaris" || GOOS == "illumos" || GOOS == "windows" || GOOS == "plan9" || GOOS == "darwin" || GOOS == "ios" {
		// 如果是上面的情况 g0栈是用的 pthread_create 线程栈
		mp.g0 = malg(-1)
	} else {
		mp.g0 = malg(8192 * sys.StackGuardMultiplier)
	}
```


每次切到`g0`栈执行指令时，`g0->sched.sp`在初始化后没有修改该过，所以每次切换到g0时栈起始值相同，每次调用`mcall`都会从指定栈位置开始执行相关操作，以此来复用g0栈。

# 参考文献
* [详尽干货！从源码角度看 Golang 的调度](https://mp.weixin.qq.com/s?__biz=MzU1ODEzNjI2NA==&mid=2247487178&amp;idx=2&amp;sn=121f293c1502b10e7569a0e7216de79e&source=41#wechat_redirect)
* [深入golang runtime的调度](https://zboya.github.io/post/go_scheduler/)