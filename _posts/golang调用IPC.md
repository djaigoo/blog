---
author: djaigo
title: golang调用IPC
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - ipc
  - shmems
  - queues
  - semaphores
date: 2020-04-15 09:26:21
updated: 2020-04-15 09:26:21
---

# 简介
进程间通信（IPC，Inter-Process Communication）指至少两个进程或线程间传送数据或信号的一些技术或方法。最初Unix IPC包括：管道、FIFO、信号；System V IPC包括：System V消息队列、System V信号灯、System V共享内存区；Posix IPC包括： Posix消息队列、Posix信号灯、Posix共享内存区。
IPC的生命周期都与内核相同
# 管道
管道（Pipe）及有名管道（named pipe）：管道可用于具有亲缘关系进程间的通信，有名管道克服了管道没有名字的限制，因此，除具有管道所具有的功能外，它还允许无亲缘关系进程间的通信。
# 信号
# 消息队列
消息队列是消息的链接表，包括Posix消息队列system V消息队列。有足够权限的进程可以向队列中添加消息，被赋予读权限的进程则可以读走队列中的消息。消息队列克服了信号承载信息量少，管道只能承载无格式字节流以及缓冲区大小受限等缺点。

# 信号量
信号量的本质是一种数据操作锁、用来负责数据操作过程中的互斥、同步等功能。
信号量用来管理临界资源的。它本身只是一种外部资源的标识、不具有数据交换功能，而是通过控制其他的通信资源实现进程间通信。
信号量通过PV操作（P减少信号，V增加信号）来控制信号量，其本质上信号量允许多个进程同时执行，当超过预定的数量后再次执行P操作或阻塞等待。P操作也叫做wait操作，sleep操作或者down操作，而V操作也被叫做signal操作，wake-up以及up操作。


# 共享内存

# 套接字

# 参考文献
[深刻理解Linux进程间通信（IPC）](https://www.ibm.com/developerworks/cn/linux/l-ipc/)
[linux 信号量是什么怎么用？](https://www.zhihu.com/question/47411729)
[Golang直接操作共享内存](https://studygolang.com/articles/10203)
