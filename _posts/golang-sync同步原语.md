---
author: djaigo
title: golang-sync同步原语
categories:
  - golang
date: 2022-09-05 11:45:10
tags:
---

Go 语言作为一个原生支持用户态进程（Goroutine）的语言，当提到并发编程、多线程编程时，往往都离不开锁这一概念。锁是一种并发编程中的同步原语（Synchronization Primitives），它能保证多个 Goroutine 在访问同一片内存时不会出现竞争条件（Race condition）等问题。
Go 语言在 `sync` 包中提供了用于同步的一些基本原语，包括常见的 `sync.Mutex`、`sync.RWMutex`、`sync.WaitGroup`、`sync.Once` 和 `sync.Cond`。本文将会分析golang基于信号的底层实现逻辑，源码文件`runtime/sema.go`。

代码分为：
* 链接函数，声明对sync包的linkname
* 信号树堆，通过信号量管控阻塞协程
* 通知列表，用于条件变量的单播和广播

# 链接函数
连接函数重定向，将sync包中所用到的函数链接到底层runtime实现函数：
* 信号树堆用户锁、读写锁、文件锁的阻塞管理
* 通知列表用于条件变量的通知单个和通知所有

```go
//go:linkname poll_runtime_Semacquire internal/poll.runtime_Semacquire
func poll_runtime_Semacquire(addr *uint32) {}

//go:linkname poll_runtime_Semrelease internal/poll.runtime_Semrelease
func poll_runtime_Semrelease(addr *uint32) {}

//go:linkname sync_runtime_Semacquire sync.runtime_Semacquire
func sync_runtime_Semacquire(addr *uint32) {}

//go:linkname sync_runtime_Semrelease sync.runtime_Semrelease
func sync_runtime_Semrelease(addr *uint32, handoff bool, skipframes int) {}

//go:linkname sync_runtime_SemacquireMutex sync.runtime_SemacquireMutex
func sync_runtime_SemacquireMutex(addr *uint32, lifo bool, skipframes int) {}

//go:linkname sync_runtime_SemacquireRWMutexR sync.runtime_SemacquireRWMutexR
func sync_runtime_SemacquireRWMutexR(addr *uint32, lifo bool, skipframes int) {}

//go:linkname sync_runtime_SemacquireRWMutex sync.runtime_SemacquireRWMutex
func sync_runtime_SemacquireRWMutex(addr *uint32, lifo bool, skipframes int) {}

//go:linkname notifyListAdd sync.runtime_notifyListAdd
func notifyListAdd(l *notifyList) uint32 {}

//go:linkname notifyListWait sync.runtime_notifyListWait
func notifyListWait(l *notifyList, t uint32) {}

//go:linkname notifyListNotifyAll sync.runtime_notifyListNotifyAll
func notifyListNotifyAll(l *notifyList) {}

//go:linkname notifyListNotifyOne sync.runtime_notifyListNotifyOne
func notifyListNotifyOne(l *notifyList) {}

//go:linkname notifyListCheck sync.runtime_notifyListCheck
func notifyListCheck(sz uintptr) {}

//go:linkname sync_nanotime sync.runtime_nanotime
func sync_nanotime() int64 {}
```

# 信号树堆
树堆
![Treap.svg](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Treap.svg/1920px-Treap.svg.png)
横坐标表示值，纵坐标表示优先级，以优先级限制树的层高
查找时使用值为索引，插入删除时优先级控制树形状
```go
// 信号表
var semtable semTable

// Prime to not correlate with any user patterns.
const semTabSize = 251

// 信号表 固定大小
type semTable [semTabSize]struct {
	root semaRoot
	pad  [cpu.CacheLinePadSize - unsafe.Sizeof(semaRoot{})]byte
}

type semaRoot struct {
	// lock 锁
	// treap 树堆 存等待的g tree-heap
	// nwait 等待者的个数
	lock  mutex
	treap *sudog        // root of balanced tree of unique waiters.
	nwait atomic.Uint32 // Number of waiters. Read w/o the lock.
}
```

## 信号标志
标志事件类型：阻塞事件和锁事件，用于记录事件日志
```go
type semaProfileFlags int

const (
	semaBlockProfile semaProfileFlags = 1 << iota
	semaMutexProfile
)
```

信号树堆示意图

![信号树堆](https://blog-1251474779.cos.ap-beijing.myqcloud.com/statics/sema-队列.svg)

## 添加信号树堆
将当期协程存放入树堆中，等待被唤醒
```go
// 信号量处理 等待被唤醒
func semacquire1(addr *uint32, lifo bool, profile semaProfileFlags, skipframes int, reason waitReason) {
	gp := getg()
	if gp != gp.m.curg {
		throw("semacquire not on the G stack")
	}

	// Easy case.
	if cansemacquire(addr) {
		// 如果有正在执行 semrelease1 直接获取信号量 返回
		return
	}

	s := acquireSudog()
	root := semtable.rootFor(addr)
	t0 := int64(0)
	s.releasetime = 0
	s.acquiretime = 0
	s.ticket = 0
	if profile&semaBlockProfile != 0 && blockprofilerate > 0 {
		// 阻塞事件
		t0 = cputicks()
		// 阻塞没有释放时间
		s.releasetime = -1
	}
	if profile&semaMutexProfile != 0 && mutexprofilerate > 0 {
		// 锁事件
		if t0 == 0 {
			t0 = cputicks()
		}
		// 记录获取时间
		s.acquiretime = t0
	}
	for {
		// 锁住
		lockWithRank(&root.lock, lockRankRoot)
		// 添加root的等待者
		root.nwait.Add(1)
		if cansemacquire(addr) {
			// 再次检测是否有正在释放的信号量
			root.nwait.Add(-1)
			unlock(&root.lock)
			break
		}
		// 入队 休眠
		root.queue(addr, s, lifo)
		// 等待被唤醒
		goparkunlock(&root.lock, reason, traceEvGoBlockSync, 4+skipframes)
		if s.ticket != 0 || cansemacquire(addr) {
			// 已经获取过 或 addr 还可以获取 sema
			break
		}
	}
	// 被唤醒后是否记录阻塞事件
	if s.releasetime > 0 {
		// 尝试记录阻塞事件
		blockevent(s.releasetime-t0, 3+skipframes)
	}
	releaseSudog(s)
}
```

## 移除信号树堆
唤醒等待协程
```go
// 解锁单个 addr 的等待 g 并唤醒该 g
func semrelease1(addr *uint32, handoff bool, skipframes int) {
	// 取根结点
	root := semtable.rootFor(addr)
	// 增加信号量
	atomic.Xadd(addr, 1)

	// 检测操作必须在 xadd 后面
	// 避免错过唤醒
	// 这边加上 那边获取
	if root.nwait.Load() == 0 {
		// 没有等待的 g 直接返回
		return
	}

	lockWithRank(&root.lock, lockRankRoot)
	if root.nwait.Load() == 0 {
		// 二次检测
		unlock(&root.lock)
		return
	}
	// 从树中弹出一个 sudog
	s, t0 := root.dequeue(addr)
	if s != nil {
		// 弹出有效
		root.nwait.Add(-1)
	}
	unlock(&root.lock)
	if s != nil { // May be slow or even yield, so unlock first
		acquiretime := s.acquiretime
		if acquiretime != 0 {
			// 有 acquiretime 表示是锁事件 尝试记录锁事件
			mutexevent(t0-acquiretime, 3+skipframes)
		}
		if s.ticket != 0 {
			throw("corrupted semaphore ticket")
		}
		if handoff && cansemacquire(addr) {
			// 只有外部需要让出调度时才会获取信号量
			// 标记下次执行 并且 addr还可以被获取
			s.ticket = 1
		}
		// 唤醒s 加入就绪队列
		readyWithTime(s, 5+skipframes)
		if s.ticket == 1 && getg().m.locks == 0 {
			// 标记为1 并且 m 没有被其他 g 锁住
			// 让出 m 等待下次调度
			// 即直接调度 s 对应的 g
			// 请注意，继承了我们的时间片：这是可取的，以避免一个高度竞争的信号量无限期地占用 P
			// goyield 类似于 Gosched，但它会发出一个“抢占式”跟踪事件
			// 更重要的是，将当前 G 放在本地 runq 而不是全局 runq 上
			// 我们只在饥饿状态下执行此操作（handoff=true）
			// 因为在非饥饿情况下，在我们让出调度时，其他服务员可能会获取信号量，这将是一种浪费
			// 相反，我们等待进入饥饿状态，然后我们开始直接切换票和 P
			goyield()
		}
	}
}
```

## 信号入队
```go
// 将当前的 s 入队
// 只有新插入的 addr 才会生成 ticket
func (root *semaRoot) queue(addr *uint32, s *sudog, lifo bool) {
	s.g = getg()
	s.elem = unsafe.Pointer(addr)
	s.next = nil
	s.prev = nil

	// 先查找有没有相同锁地址 有就按规则插入后返回
	var last *sudog
	// var pt **sudog
	pt := &root.treap
	for t := *pt; t != nil; t = *pt {
		// 遍历所有节点 查找 addr 是否已经入 treap
		if t.elem == unsafe.Pointer(addr) {
			// Already have addr in list.
			if lifo {
				// 插入队首
				// Substitute s in t's place in treap.
				// 赋值pt
				*pt = s
				// 交接二叉树链接信息
				s.ticket = t.ticket
				// 使用最开始的获取时间
				s.acquiretime = t.acquiretime
				s.parent = t.parent
				s.prev = t.prev
				s.next = t.next
				if s.prev != nil {
					s.prev.parent = s
				}
				if s.next != nil {
					s.next.parent = s
				}
				// 修正队首尾
				// Add t first in s's wait list.
				s.waitlink = t
				s.waittail = t.waittail
				if s.waittail == nil {
					s.waittail = t
				}
				// 清空原树节点 树相关信息
				t.parent = nil
				t.prev = nil
				t.next = nil
				t.waittail = nil
			} else {
				// 直接插入队尾
				// Add s to end of t's wait list.
				if t.waittail == nil {
					t.waitlink = s
				} else {
					t.waittail.waitlink = s
				}
				t.waittail = s
				s.waitlink = nil
			}
			// 修改后 就返回
			return
		}
		// 向下个节点偏移 根据地址 决定向前向后
		last = t
		if uintptr(unsafe.Pointer(addr)) < uintptr(t.elem) {
			pt = &t.prev
		} else {
			pt = &t.next
		}
	}

	// 新的锁就新建一个二叉树节点
	// ticket 有与0作比较 所以必须大于0
	s.ticket = fastrand() | 1
	// last 作为新叶子节点的父节点
	s.parent = last
	// 将 s 置入 pt 插入新节点
	*pt = s

	// 插入新节点 需要保持优先级的平衡性
	// 利用 ticket 确定优先级
	for s.parent != nil && s.parent.ticket > s.ticket {
		if s.parent.prev == s {
			// s 是左子树 就右旋
			root.rotateRight(s.parent)
		} else {
			if s.parent.next != s {
				panic("semaRoot queue")
			}
			// s 是右子树 就左旋
			root.rotateLeft(s.parent)
		}
	}
}
```

## 信号出队
```go
// 出队单个sudog
// 如果正在分析 sudog 则 dequeue 将返回唤醒它的时间
// 否则返为0
// dequeue searches for and finds the first goroutine
// in semaRoot blocked on addr.
// If the sudog was being profiled, dequeue returns the time
// at which it was woken up as now. Otherwise now is 0.
func (root *semaRoot) dequeue(addr *uint32) (found *sudog, now int64) {
	ps := &root.treap
	s := *ps
	for ; s != nil; s = *ps {
		if s.elem == unsafe.Pointer(addr) {
			// 找到才执行出队操作
			goto Found
		}
		if uintptr(unsafe.Pointer(addr)) < uintptr(s.elem) {
			ps = &s.prev
		} else {
			ps = &s.next
		}
	}
	// 找不到直接返回
	return nil, 0

Found:
	now = int64(0)
	if s.acquiretime != 0 {
		now = cputicks()
	}
	if t := s.waitlink; t != nil {
		// 有链表元素 直接移除队首元素 不用删树节点
		*ps = t
		t.ticket = s.ticket
		t.parent = s.parent
		t.prev = s.prev
		if t.prev != nil {
			t.prev.parent = t
		}
		t.next = s.next
		if t.next != nil {
			t.next.parent = t
		}
		if t.waitlink != nil {
			t.waittail = s.waittail
		} else {
			t.waittail = nil
		}
		// 重置获取时间
		t.acquiretime = now
		s.waitlink = nil
		s.waittail = nil
	} else {
		// 没有后续链表元素 需要删除树节点 进行树的再平衡
		// 向下旋转为叶子节点 然后删除
		for s.next != nil || s.prev != nil {
			// 有非空子树 就进行旋转 将 s 旋转为叶子节点
			if s.next == nil || s.prev != nil && s.prev.ticket < s.next.ticket {
				// 左右子树皆不为空时 需要判断 左右节点的 ticket 保证优先级高度
				root.rotateRight(s)
			} else {
				// 否则 左旋
				root.rotateLeft(s)
			}
		}
		// 左右子树皆为空 即叶子节点 可以安全删除
		// Remove s, now a leaf.
		if s.parent != nil {
			// 有父节点 移除父节点指向
			if s.parent.prev == s {
				s.parent.prev = nil
			} else {
				s.parent.next = nil
			}
		} else {
			// 没有父节点 说明是最后一个节点
			root.treap = nil
		}
	}
	// 清理 s 无关数据
	s.parent = nil
	s.elem = nil
	s.next = nil
	s.prev = nil
	// 出队清空 ticket
	s.ticket = 0
	return s, now
}
```

## 树堆左旋
![左旋](https://blog-1251474779.cos.ap-beijing.myqcloud.com/statics/sema-左旋.svg)
```go
/*

  x                  y
 / \                / \
a   y      -->     x   c
   / \            / \
  b   c          a   b

*/

// rotateLeft rotates the tree rooted at node x.
// turning (x a (y b c)) into (y (x a b) c).
func (root *semaRoot) rotateLeft(x *sudog) {
	// p -> (x a (y b c))
	p := x.parent
	y := x.next
	b := y.prev

	y.prev = x
	x.parent = y
	x.next = b
	if b != nil {
		b.parent = x
	}

	y.parent = p
	if p == nil {
		root.treap = y
	} else if p.prev == x {
		p.prev = y
	} else {
		if p.next != x {
			throw("semaRoot rotateLeft")
		}
		p.next = y
	}
}
```

## 树堆右旋
![右旋](https://blog-1251474779.cos.ap-beijing.myqcloud.com/statics/sema-右旋.svg)
```go
/*

    y              x
   / \            / \
  x   c    -->   a   y
 / \                / \
a   b              b   c

*/
// rotateRight rotates the tree rooted at node y.
// turning (y (x a b) c) into (x a (y b c)).
func (root *semaRoot) rotateRight(y *sudog) {
	// p -> (y (x a b) c)
	p := y.parent
	x := y.prev
	b := x.next

	x.next = y
	y.parent = x
	y.prev = b
	if b != nil {
		b.parent = y
	}

	x.parent = p
	if p == nil {
		root.treap = x
	} else if p.prev == y {
		p.prev = x
	} else {
		if p.next != y {
			throw("semaRoot rotateRight")
		}
		p.next = x
	}
}
```

# 通知列表
```go
// 用于 sync.Cond 的通知列表
// wait 为下一个等待者序号
// notify 为已经通知过的等待者序号
type notifyList struct {
	// 下一个等待者的序号
	wait uint32

	// 下一个被通知的等待者序号 可以不用锁读但是必须锁写
	// wait 和 notify 可能会重复 但目前不太可能
	notify uint32

	// List of parked waiters.
	lock mutex
	head *sudog
	tail *sudog
}
```

## 生成id
```go
// 生成等待者id
//go:linkname notifyListAdd sync.runtime_notifyListAdd
func notifyListAdd(l *notifyList) uint32 {
	return atomic.Xadd(&l.wait, 1) - 1
}
```

## 加入等待列表
```go
// 添加进等待队列 l 中
//go:linkname notifyListWait sync.runtime_notifyListWait
func notifyListWait(l *notifyList, t uint32) {
	lockWithRank(&l.lock, lockRankNotifyList)

	// 如果 t 小于 notify 表示已经通知过了 直接返回
	if less(t, l.notify) {
		unlock(&l.lock)
		return
	}

	// 入队 插入队尾
	// Enqueue itself.
	s := acquireSudog()
	s.g = getg()
	s.ticket = t
	s.releasetime = 0
	t0 := int64(0)
	if blockprofilerate > 0 {
		t0 = cputicks()
		s.releasetime = -1
	}
	if l.tail == nil {
		l.head = s
	} else {
		l.tail.next = s
	}
	l.tail = s
	// 等待唤醒通知
	goparkunlock(&l.lock, waitReasonSyncCondWait, traceEvGoBlockCond, 3)
	if t0 != 0 {
		blockevent(s.releasetime-t0, 2)
	}
	releaseSudog(s)
}
```
## 唤醒所有等待者
```go
// 唤醒 l 中所有等待者
//go:linkname notifyListNotifyAll sync.runtime_notifyListNotifyAll
func notifyListNotifyAll(l *notifyList) {
	// 已经唤醒过 直接返回
	if atomic.Load(&l.wait) == atomic.Load(&l.notify) {
		return
	}

	// 获取锁 拷贝 l.head 减少占用锁时间 置处理标记 解锁
	lockWithRank(&l.lock, lockRankNotifyList)
	s := l.head
	l.head = nil
	l.tail = nil

	// 将notify置为wait
	atomic.Store(&l.notify, atomic.Load(&l.wait))
	unlock(&l.lock)

	// 唤醒所有的等待者
	// Go through the local list and ready all waiters.
	for s != nil {
		next := s.next
		s.next = nil
		readyWithTime(s, 4)
		s = next
	}
}
```
## 唤醒一个等待者
```go
// 唤醒 l 第一个等待者
//go:linkname notifyListNotifyOne sync.runtime_notifyListNotifyOne
func notifyListNotifyOne(l *notifyList) {
	// 已经唤醒过 直接返回
	if atomic.Load(&l.wait) == atomic.Load(&l.notify) {
		return
	}

	lockWithRank(&l.lock, lockRankNotifyList)

	// 二次校验是否已经唤醒过
	t := l.notify
	if t == atomic.Load(&l.wait) {
		unlock(&l.lock)
		return
	}

	// 增加唤醒标记
	atomic.Store(&l.notify, t+1)

	// 尝试查找需要唤醒的 sudog
	// 如果来不及插入此列表就被唤醒 则遍历 sudog 列表不会触发唤醒 但是在插入的时候会直接唤醒
	// 不存在表示被唤醒过
	for p, s := (*sudog)(nil), l.head; s != nil; p, s = s, s.next {
		if s.ticket == t {
			// 从队列中摘除 s
			n := s.next
			if p != nil {
				p.next = n
			} else {
				l.head = n
			}
			if n == nil {
				l.tail = p
			}
			unlock(&l.lock)
			s.next = nil
			// 找到了 唤醒s
			readyWithTime(s, 4)
			return
		}
	}
	unlock(&l.lock)
}
```


