---
author: djaigo
title: TCP协议
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/net.png'
categories:
  - net
tags:
  - tcp
date: 2019-12-20 17:32:14
---

# 简介
TCP协议是传输层重要的协议，TCP是面向连接、字节流和提供可靠传输。要使用TCP连接的双方必须先建立连接，然后才能开始数据的读写。TCP是全双工的，所以双发的内核都需要一定的资源保存TCP连接的状态和连接上的数据。在完成数据交换之后，通信双方都必须断开连接已释放系统资源。
# 头部结构
# 连接
# 超时重传
# 拥塞控制

# 参考文献
* 《Linux高性能服务器编程》
* [传输控制协议](https://zh.wikipedia.org/wiki/%E4%BC%A0%E8%BE%93%E6%8E%A7%E5%88%B6%E5%8D%8F%E8%AE%AE)
