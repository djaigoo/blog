---
author: djaigo
title: sync包
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - sync
  - mutex
  - condition variable
  - atomic
date: 2020-01-13 14:54:12
---

# atomic
## Add
Add族函数是原子的加值操作，第一个参数是被操作值的地址，第二参数是要加的值是多少，返回值是加之后的值。
如果要在无符号上减操作，建议的方法`delta=^uint32(delta-1)`，特别的如果要递减使用`delta=^uint32(0)`。

```go
func AddInt32(addr *int32, delta int32) (new int32)
func AddUint32(addr *uint32, delta uint32) (new uint32)
func AddInt64(addr *int64, delta int64) (new int64)
func AddUint64(addr *uint64, delta uint64) (new uint64)
func AddUintptr(addr *uintptr, delta uintptr) (new uintptr)
```

## CAS
CAS族函数是比较并替换操作，第一个参数被操作值的地址，第二个参数是被操作数的原值，第三个参数是被操作数的新值。
如果被操作数值不等于旧值则不进行替换，返回false，如果成功替换返回true。
```go
func CompareAndSwapInt32(addr *int32, old, new int32) (swapped bool)
func CompareAndSwapInt64(addr *int64, old, new int64) (swapped bool)
func CompareAndSwapUint32(addr *uint32, old, new uint32) (swapped bool)
func CompareAndSwapUint64(addr *uint64, old, new uint64) (swapped bool)
func CompareAndSwapUintptr(addr *uintptr, old, new uintptr) (swapped bool)
func CompareAndSwapPointer(addr *unsafe.Pointer, old, new unsafe.Pointer) (swapped bool)
```


## Load
Load族函数是原子的取出被操作数，第一个参数是被操作数的地址，返回值是地址执行的值。
```go
func LoadInt32(addr *int32) (val int32)
func LoadInt64(addr *int64) (val int64)
func LoadUint32(addr *uint32) (val uint32)
func LoadUint64(addr *uint64) (val uint64)
func LoadUintptr(addr *uintptr) (val uintptr)
func LoadPointer(addr *unsafe.Pointer) (val unsafe.Pointer)
```

## Store
Store族函数是原子的存储被操作数，第一个参数是操作数的地址，第二个参数是被设置的值。
```go
func StoreInt32(addr *int32, val int32)
func StoreInt64(addr *int64, val int64)
func StoreUint32(addr *uint32, val uint32)
func StoreUint64(addr *uint64, val uint64)
func StoreUintptr(addr *uintptr, val uintptr)
func StorePointer(addr *unsafe.Pointer, val unsafe.Pointer)
```

## Swap
Swap族函数是原子替换操作，第一个参数是操作数的地址，第二个参数是需要替换的新值，返回值是原来的旧值。
```go
func SwapInt32(addr *int32, new int32) (old int32)
func SwapInt64(addr *int64, new int64) (old int64)
func SwapUint32(addr *uint32, new uint32) (old uint32)
func SwapUint64(addr *uint64, new uint64) (old uint64)
func SwapUintptr(addr *uintptr, new uintptr) (old uintptr)
func SwapPointer(addr *unsafe.Pointer, new unsafe.Pointer) (old unsafe.Pointer)
```

# Mutex
Mutex实现了互斥锁，即锁住的代码同一时间只有一个协程在执行。
提供函数：
```go
func (m *Mutex) Lock()
func (m *Mutex) Unlock()
```

Mutex实现了Locker接口。
```go
// A Locker represents an object that can be locked and unlocked.
type Locker interface {
    Lock()
    Unlock()
}
```

# RWMutex
RWMutex是读写锁，适用于读多写少的场景。
提供函数：
```go
func (rw *RWMutex) RLock()
func (rw *RWMutex) RUnlock()
func (rw *RWMutex) Lock()
func (rw *RWMutex) Unlock()
func (rw *RWMutex) RLocker() Locker
```

RLocker()函数返回读锁的接口对象，用于传入NewCond返回一个读锁的条件变量。

# Cond
Cond是条件变量，条件变量的作用并不是保证在同一时刻仅有一个线程访问某一个共享数据，而是在对应的共享数据的状态发生变化时，通知其他因此而被阻塞的线程。
提供函数：
```go
func NewCond(l Locker) *Cond
func (c *Cond) Wait()
func (c *Cond) Signal()
func (c *Cond) Broadcast()
```

*   `cond.L.Lock()`和`cond.L.Unlock()`：也可以使用`lock.Lock()`和`lock.Unlock()`，完全一样，因为是指针转递
*   `cond.Wait()`：Unlock()->**_阻塞等待通知(即等待Signal()或Broadcast()的通知)->收到通知_**->Lock()
*   `cond.Signal()`：通知一个Wait()了的，若没有Wait()，也不会报错。**Signal()通知的顺序是根据原来加入通知列表(Wait())的先入先出**
*   `cond.Broadcast()`: 通知所有Wait()了的，若没有Wait()，也不会报错

示例：
```go
func main() {
    data := []int{2, 4, 5, 6, 8, 9}
    tmp := 0
    c := sync.NewCond(new(sync.Mutex))
    c.L.Lock()
    defer c.L.Unlock()
    
    ctx, cancel := context.WithCancel(context.Background())
    // 生产者
    go func() {
        for _, d := range data {
            tmp = d
            c.Signal()
            time.Sleep(1 * time.Second)
        }
        cancel()
        c.Signal() // 防止消费者进入wait死锁，但是会重复消费一次数据
    }()
    
    // 消费者
    for {
        select {
        case <-ctx.Done():
            return
        default:
            c.Wait()
            fmt.Println(tmp)
            if tmp%2 != 0 {
                fmt.Println(time.Now(), tmp)
                continue
            }
        }
    }
}
```

上例可以看到Cond的使用并没有channel方便，所以一般还是使用channel进行顺序调用。Cond一般使用场景是唤起一个Wait协程，或者唤起所有Wait协程。

# WaitGroup
WaitGroup是等待一组进程运行完成。
提供函数：
```go
func (wg *WaitGroup) Add(delta int)
func (wg *WaitGroup) Done()
func (wg *WaitGroup) Wait()
```

Add函数delta类型是int，所以支持参数为负数的值，但是不能让计数器为负数，否则会panic。
Done函数是递减1，也不能使计数器为负数，否则会panic。
Wait函数阻塞等待计数器为0。

WaitGroup一个计数周期，即计数器从0转到正数开始，到计数器从正数到0结束，即为一个周期。当计数器为0时，Wait函数停止阻塞返回，在后面仍可以调用Add函数进行加计数器，即开启下一个周期，可以调用Wait函数等待下一次周期的结束。

# Once
Once提供一个只执行一次的保护罩。
提供函数：
```go
func (o *Once) Do(f func())
```

重复的调用同一Once对象的Do函数f只会执行一次，不管f是否相同。常用于init函数不能执行的执行一次操作，例如创建单例对象，初始化连接池，全局变量赋值等等。

# Pool
Pool表示一个临时对象池，常用于同类型对象重复利用的场景。
提供函数：
```go
func (p *Pool) Put(x interface{})
func (p *Pool) Get()
```

Pool有个成员`New func() interface{}`表示如果Get的时候没有对象则使用New新建一个对象。
Get函数取到的值是随机的，不应该对Get函数取出的对象抱有任何假设，即在获取Get函数返回对象之后应该做一次重新赋值成默认值状态。

> 摘自参考文献[1]
这样一个临时对象池在功能上与一个通用的缓存池有几分相似。但是实际上，临时对象池本身的特性决定了它是一个很独特的同步工具。下面讲一下它的两个非常突出的特性。
第一个特性，临时对象池可以把由其中的对象值产生的存储压力进行分摊。更进一步说，它会专门为每一个与操作它的goroutine相关联的P建立本地池。在临时对象池的Get方法被调用时，它一般会先尝试从与本地P对应的那个本地私有池和本地共享池中获取一个对象值。如果获取失败，它就会试图从其他P的本地共享池中偷一个对象值并直接返回给调用方。如果依然未果，它就只能把希望寄托于当前临时对象池的对象值生成函数了。注意，这个对象值生成函数产生的对象值永远不会被放置到池中，而是会被直接返回给调用方。另一方面，临时对象池的Put方法会把它的参数值存放到本地P的本地池中。每个相关P的本地共享池中的所有对象值，都是在当前临时对象池的范围内共享的。也就是说，它们随时可能会被偷走。
临时对象池的第二个突出特性是对垃圾回收友好。垃圾回收的执行一般会使临时对象池中的对象值全部被移除。也就是说，即使我们永远不会显式地从临时对象池取走某个对象值，该对象值也不会永远待在临时对象池中，它的生命周期取决于垃圾回收任务下一次的执行时间。

示例：垃圾回收清空临时对象池中的数据
```go
func main() {
    // 禁用GC，并保证在main函数执行结束前恢复GC
    defer debug.SetGCPercent(debug.SetGCPercent(-1))
    var count int32
    newFunc := func() interface{} {
        return atomic.AddInt32(&count, 1)
    }
    pool := sync.Pool{New: newFunc}

    // New字段值的作用
    v1 := pool.Get()
    fmt.Printf("Value 1: %v\n", v1)

    // 临时对象池的存取
    pool.Put(10)
    pool.Put(11)
    pool.Put(12)
    v2 := pool.Get()
    fmt.Printf("Value 2: %v\n", v2)

    // 垃圾回收对临时对象池的影响
    debug.SetGCPercent(100)
    runtime.GC()
    v3 := pool.Get()
    fmt.Printf("Value 3: %v\n", v3)
    pool.New = nil
    v4 := pool.Get()
    fmt.Printf("Value 4: %v\n", v4)
}
```

# Map
Map提供一个并发安全的map，由于golang的map并发操作会panic。
提供函数：
```go
func (m *Map) Load(key interface{}) (value interface{}, ok bool)
func (m *Map) Store(key, value interface{})
func (m *Map) LoadOrStore(key, value interface{}) (actual interface{}, loaded bool)
func (m *Map) Delete(key interface{})
func (m *Map) Range(f func(key, value interface{}) bool)
```

由于Map的性能并没有`map+mutex`的性能好，所以一般用的比较少。

# 参考文献
1. [Go并发编程实战（第2版）](https://www.ituring.com.cn/book/tupubarticle/13514)
2. [Golang中如何正确使用条件变量sync.Cond](https://ieevee.com/tech/2019/06/15/cond.html)
3. [Go语言学习 - cyent笔记](https://cyent.github.io/golang/goroutine/sync_cond/)
4. [由浅入深聊聊Golang的sync.Map](https://juejin.im/post/5d36a7cbf265da1bb47da444)