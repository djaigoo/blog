---
author: djaigo
title: golang MPG 场景源码剖析
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - mpg
  - infra
date: 2020-09-29 17:50:35
updated: 2020-09-29 17:50:35
---

# 场景分析
场景流程图
![流程图](https://img-1251474779.cos.ap-beijing.myqcloud.com/golang%20MPG.svg)
* G创建G
p拥有g1，m绑定p后，执行g1，g1创建g2，g2优先加入g1。

* G执行完毕
当g1执行完毕后，m切换到g0，负责goroutine的切换，从p中获取g2，在从g0切换到g2，并执行g2。

* G本地队列满再创建G
g1创建g2，但p的本地G空闲队列已满，则会p的空闲队列的前一半随机排序后和g2存放到全局空闲G队列中。

* 唤醒M
在创建 G 时，运行的 G 会尝试唤醒其他空闲的P和M组合去执行。如果g1唤醒了m2，m2且与p2绑定，但p2没有可执行的G，m2会执行g0，进入自旋状态（一直获取可以执行的G）。

* 唤醒的M向全局空闲G队列获取
自旋的M会向全局空闲G队列获取可执行的G，获取公式：`n=min(len(GQ)/GOMAXPROCS+1,len(GQ)/2+1)`，其中GQ是全局空闲G队列，最少获取一个。

* M向M偷取G
当m1进入自旋状态，且全局空闲G队列也为空，则会向m2队尾偷取一般的G放入与m1绑定的p1的本地空闲G队列中。

* 自旋最大限制
M必须绑定了P才会自旋，所以最多有`GOMAXPROCS`个M自旋，其他的M会存入全局休眠M队列。

* G调用阻塞系统调用
m1执行的g1调用了阻塞的系统调用，那么p1会解绑m1，会从全局休眠M队列中获取一个M，进而执行后面的G，如果全局休眠M队列没有可以用的M，那么久创建一个M。退出系统调用时，g1会被标记可执行状态存放到全局空闲G队列，m1则会存放到全局休眠M队列。

* G调用非阻塞系统调用
m1执行的g1调用了阻塞的系统调用，p1会和m1解绑，但m1会记住p1。退出系统调用时，m1和g1会优先找p1绑定，如果无法绑定，则会获取空闲的P，依旧没有g1会被标记可执行状态存放到全局空闲G队列，m1则会存放到全局休眠M队列。

# 函数说明
## stubs.go
* `getg()`
返回当前的G，由编译器重写这个指令，是从TLS（thread-local storage）获取还是专用寄存器获取
* `mcall(fn func(*g))`
从g切换到g0的栈并调用`fn(g)`，g是调用mcall的g。mcall将g的当前`PC/SP`保存在`g-> sched`中，以便以后可以恢复。是由fn去安排延迟任务，通常是记录一个g在一个data数据结构。然后会有人去调用`ready()`。当g已经被重新调度，mcall会恢复原来的g。fn绝对不能返回；通常，它以调用schedule结束，以使m运行其他goroutine。mcall只能从g堆栈（不是g0，不是gsignal）中调用。不能是`go:noescape`，如果fn是堆栈分配的闭包，fn将g放在运行队列中，并且g在fn返回之前执行，则闭包将在继续执行时失效。
* `systemstack(fn func())`
在系统堆栈上执行`fn`。如果是`the per-OS-thread`（`g0`）或`the signal handling`（`gsignal`）的堆栈，`systemstack`直接调用`fn`；否则`systemstack`是在普通goroutine的受限堆栈上执行，这种情况`systemstack`会切换到`the per-OS-thread`的堆栈，调用`fn`，然后在切回。
通常使用`func()`作为参数，以便与调用系统堆栈周围的代码共享输入和输出：
```go
... set up y ...
systemstack(func() {
	x = bigcall(y)
})
... use x ...
```

## proc.go
> M关联的G（`m->curg`，简称`gp`），M的指针`mp`，M上的P的指针`pp`

* `main_main()`
表示main包的`main()`
* `main()`
主goroutine，进行初始化并调用`main_main()`
* `forcegchelper()`
初始化强制GC，通过定时器触发
* `Gosched()`
切换goroutine，并不会暂停当前的goroutine，会自动恢复。
* `goschedguarded()`
类似`Gosched()`，而且还会检查禁止状态，并在这些情况下选择不让步。
* `gopark(unlockf func(*g, unsafe.Pointer) bool, lock unsafe.Pointer, reason waitReason, traceEv byte, traceskip int)`
将当前goroutine进入等待状态，并调用unlockf。如果unlockf返回false则恢复goroutine。unlockf一定不能访问此G的堆栈，因为它可能在调用gopark和调用unlockf之间移动。reason表示goroutine为什么park。它显示在堆栈跟踪和堆dump中，reason应具有唯一性和描述性，不要重复使用reason。
* `goparkunlock(lock *mutex, reason waitReason, traceEv byte, traceskip int)`
将当前goroutine置于等待状态并释放lock
* `goready(gp *g, traceskip int)`
使用g0的堆栈调用`ready(gp *g, traceskip int, next bool)`
* `acquireSudog() *sudog`
从本地可执行队列中获取一个sudog。如果本地队列没有，就从全局队列pop队首，如果全局队列也没有就new一个。返回本地队列pop的队首元素。
* `releaseSudog(s *sudog)`
将sudog存放到队列中。如果本地队列长度等于容量（队列已满），将本地队列的后半sudog逆序拼成list，存放到全局队列的队首后，再将s存放到本地队列的队尾。
* `funcPC(f interface{}) uintptr`
返回f这个函数的指针，如果f不是函数，则行为不确定。注意：在带有插件的程序中，funcPC可以为同一函数返回不同的值（因为在地址空间中实际上存在同一函数的多个副本）。为了安全起见，请勿在任何`==`表达式中使用此函数的结果。仅将结果用作开始执行代码的地址是安全的。
* `lockedOSThread() bool`
* `allgadd(gp *g)`
* `cpuinit()`
* `schedinit()`
* `dumpgstatus(gp *g)`
print G的状态
* `checkmcount()`
核对m的数量
* `mReserveID() int64`
给m生成一个id，这个m立即被`checkdead`认为`running`，操作必须持有`sched.lock`
* `mcommoninit(mp *m, id int64)`
绑定`mp.id`为id，id是可选的预分配id，通过`-1`忽略，内部会调用`mReserveID()`生成一个新id，并将m添加到`allm`以便垃圾收集器仅在寄存器或线程本地存储中时不会释放`g->m`。
* `ready(gp *g, traceskip int, next bool)`
标记gp准备运行
* `freezetheworld()`
* `casgstatus(gp *g, oldval, newval uint32)`
CAS操作修改g的状态，如果`oldval`或`newval`是`_Gscan`或`oldval`和`newval`相同则会throw错误，可以使用`castogscanstatus`和`casfrom_Gscanstatus`代替。如果`g->atomicstatus`处于`_Gscan`状态，则casgstatus将循环运行，知道将其置于`_Gscan`状态的goroutine结束。
* `readgstatus(gp *g) uint32`
获取G的状态
* `stopTheWorld()`
* `startTheWorld()`
* `mstart()`
* `mstart1()`
* `mstartm0()`
* `mexit()`
* `allocm(_p_ *p, fn func(), id int64) *m`
分配与任何线程无关的新m，如果需要，可以将p用于分配上下文，`fn`被置为`m.mstartfn`，id是可选的预分配id，通过`-1`忽略。即使调用者没有借用`_p_`，他的函数也被允许有写障碍。
* `getm()`
* `newm(fn func(), _p_ *p, id int64)`
创建一个新的m，它将以调用fn或调度程序开始，fn必须是静态的，而不是堆分配的闭包。`m.p`可能为nil，因此不允许写入障碍。id是可选的预分配id，通过`-1`忽略。
* `newm1()`
* `stopm()`
* `startm(_p_ *p, spinning bool)`
调度一些M以运行p（必要时创建M），如果`_p_`为空则从`_Pidle`列表中获取，如果`_Pidle`也为空则什么也不做。由于m.p可能为空，所以不允许写入障碍。如果spinning为true，则调用者进入自旋状态，并且`startm`将减少旋转或在新启动的M中设置`m.spinning`。
* `wakep()`
* `stoplockedm()`
停止执行锁定到g的当前m，直到g可再次运行。
* `execute(gp *g, inheritTime bool)`
调度gp在当前M上运行。如果`InheritTime`为true，则gp继承当前时间片中的剩余时间，否则启动新的时间片。**该函数永远不会返回**。
* `schedule()`
找到一个可运行的goroutine并执行它。**该函数永远不会返回**。
* `dropg()`
取消与M关联的G，通常调用者将`gp`的状态设置为远离`Grunning`，并立即调用`dropg()`结束工作。调用者还负责在适当的时间调用`ready()`重新启动`gp`。调用`dropg()`并安排`gp`稍后准备好之后，调用者可以做其他的工作，但最终调用`schedule()`，重启M对G的调度。
* `park_m(gp *g)`，park到g0
* `goschedImpl(gp *g)`
切换gp状态到`_Grunnable`，解绑当前m，放入全局可执行列表中
* `gosched_m()`
切换当前`m.g`为g0
* `goexit1()`
* `goexit0()`
* `save()`
* `entersyscall()`
* `exitsyscall()`
* `malg(stacksize int32) *g`
分配一个新的g，该堆栈的大小足以容纳stacksize字节。
* `newproc()`
* `newproc1()`
* `LockOSThread()`
* `UnlockOSThread()`
* `acquirep(_p_ *p)`
关联`_p_`和当前的m，底层调用`wirep(_p_ *p)`。
* `wirep(_p_ *p)`
将当前M与`_p_`关联。
* `releasep() *p`
将M和p取消关联
* `sysmon()`
* `schedEnableUser(enable bool)`
启动或禁用调度goroutine，这不会停止已经在运行的goroutine，因此调用者想要禁用得先STW
* `schedEnabled(gp *g) bool`
返回是否可以调度gp
* `mput(mp *m)`
将mp存放到全局M空闲列表中，**操作时必须锁定Sched**，可能在STW期间运行，因此不允许写入障碍。
* `mget() *m`
从全局M空闲列表中获取M，**操作时必须锁定Sched**，可能在STW期间运行，因此不允许写入障碍。
* `globrunqput(gp *g)`
将gp追加到全局队列队尾
* `globrunqputhead(gp *g)`
将gp添加到全局队列的队首
* `globrunqputbatch(batch *gQueue, n int32)`
将一批goroutine追加到全局可执行队列队尾，这将清空batch，**操作时必须锁定Sched**
* `globrunqget(_p_ *p, max int32) *g`
从全局可执行队列中批量获取G并存于`_p_`的本地可执行队列中，**操作时必须锁定Sched**。返回偷取队列的队首。
偷取个数逻辑：
```go
n := sched.runqsize/gomaxprocs + 1
if n > sched.runqsize {
	n = sched.runqsize
}
if max > 0 && n > max {
	n = max
}
if n > int32(len(_p_.runq))/2 {
	n = int32(len(_p_.runq)) / 2
}
```

* `pidleput(_p_ *p)`
将`_p_`存放到`_Pidle`列表中，**操作时必须锁定Sched**。可能在STW期间运行，因此不允许写入障碍。如果`_p_`的可执行列表不为空则throw。
* `pidleget() *p`
尝试从`_Pidle`列表中获取p，**操作时必须锁定Sched**。可能在STW期间运行，因此不允许写入障碍。获取队首的P。
* `runqempty(_p_ *p) bool`
返回`_p_`在其本地运行队列中是否没有G且`_p_.runnext`也为nil，返回值一定是真实的。
* `runqput(_p_ *p, gp *g, next bool)`
尝试将`gp`放入`_p_`的本地可运行队列中。如果`next`是false，gp将会追加到队列尾；如果`next`是true，gp将会存于`_p_.runnext`中，原有`_p_.runnext`追加队尾。如果运行队列满了（超过256），将会存放于全局的可执行队列中。**只能由拥有者P执行**。
* `runqputslow(_p_ *p, gp *g, h, t uint32) bool`
将gp和`_p_`运行队列的部分移至全局运行队列中，**只能由拥有者P执行**。取`_p_`可执行队列的一半和gp组成新的队列（可能会随机排序），存放于全局可执行队列中。
* `runqget(_p_ *p) (gp *g, inheritTime bool)`
从本地队列中获取gp，如果inheritTime为true，则继承时间片，否则有用新的时间片。只能被P执行。如果`_p_.runnext`有值则直接返回，并将`_p_.runnext`置空，此时`inheritTime`为true；否则pop本地队列队首返回G，`inheritTime`为false。**只能由拥有者P执行**。
* `runqgrab(_p_ *p, batch *[256]guintptr, batchHead uint32, stealRunNextG bool) uint32`
从`_p_`的可运行队列中获取一批goroutines到`batch`中。`batch`是一个环，起始位置为`batchHead`。`stealRunNextG`表示如果`_p_`本地可执行队列为空时是否使用`_p_.runnext`，返回值是拿走的goroutines数。**可以由任何P执行**。如果`_p_`本地可执行队列不为空则偷走一般到`batch`中，如果为空则将`_p_.runnext`放入`batch`中。
* `runqsteal(_p_, p2 *p, stealRunNextG bool) *g`
从`p2`的本地可运行队列中窃取一半goroutine，并将其放入`_p_`的本地可运行队列中。stealRunNextG表示`p2`本地可执行队列为空时是否偷取`p2.runnext`。返回偷取队列的队尾goroutine，如果失败或没有返回nil。

## runtime1.go
* `acquirem() *m`
获取当前G的M，会增加`m.locks`的引用计数
* `releasem(mp *m)`
减少`m.locks`的引用计数
