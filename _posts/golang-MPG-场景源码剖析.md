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

* G创建G
p拥有g1，m绑定p后，执行g1，g1创建g2，g2优先加入g1。
调用链：
```text
newproc() --> systemstack(newproc1() --> runqput())
```

* G执行完毕
当g1执行完毕后，m切换到g0，负责goroutine的切换，从p中获取g2，在从g0切换到g2，并执行g2。
调用链：
```text
goexit() --> goexit1() --> mcall(goexit0) --> schedule()
```

* G本地队列满再创建G
g1创建g2，但p的本地G空闲队列已满，则会p的空闲队列的前一半随机排序后和g2存放到全局空闲G队列中。
调用链：
```text
newproc() --> systemstack(newproc1() --> runqput() --> runqputslow() --> globrunqputbatch())
```

* 唤醒M
在创建 G 时，运行的 G 会尝试唤醒其他空闲的P和M组合去执行。如果g1唤醒了m2，m2且与p2绑定，但p2没有可执行的G，m2会执行g0，进入自旋状态（一直获取可以执行的G）。
调用链：
```text
newproc() --> systemstack(wakep() --> startm() --> pidleget() --> mget() --> notewakeup())
```

* 唤醒的M向全局空闲G队列获取
自旋的M会向全局空闲G队列获取可执行的G，获取公式：`n=min(len(GQ)/GOMAXPROCS+1,len(GQ)/2+1)`，其中GQ是全局空闲G队列，最少获取一个。
调用链：
```text
schedule() --> findrunnable() --> globrunqget()
```

* M向M偷取G
当m1进入自旋状态，且全局空闲G队列也为空，则会向m2队尾偷取一般的G放入与m1绑定的p1的本地空闲G队列中。
调用链：
```text
schedule() --> findrunnable() --> runqsteal()
```

* 自旋最大限制
M必须绑定了P才会自旋，所以最多有`GOMAXPROCS`个M自旋，其他的M会存入全局休眠M队列。
调用链：
```text
stopm() --> mput()
```

* G调用系统调用
`m1`执行的`g1`调用了系统调用，那么会保存`g1`的状态，并将`g1`标记为可抢占，解绑`p`，将`p`的状态设置为`_Psyscall`，但不会做其他事，方便很快的系统调用返回时可以立即拥有`p`执行。当`sysmon`检测当前p处于系统调用时间超时后再去绑定m，做其他事情。退出系统调用时，`g1`会被标记可执行状态存放到全局空闲G队列，`m1`则会存放到全局休眠M队列。
调用链：
```text
进入系统调用
entersyscall() --> reentersyscall()
sysmon() --> retake() --> handoffp() --> startm() --> pidleput()

退出系统调用
exitsyscall() --> exitsyscallfast() --> mcall(exitsyscall0() --> pidleget() --> globrunqput() --> stopm())
```


# 参考文献

* [[典藏版] Golang 调度器 GMP 原理与调度全分析](https://learnku.com/articles/41728)

