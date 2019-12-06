---
title: redis主从复制
tags:
  - redis
categories:
  - redis
draft: true
date: 2018-09-03 16:22:59
---
# redis 主从复制
由于实际业务中存在有读写次数不均，消耗时间也不一致的情况，常常将读写两个操作分开，从而高效的利用redis。由于redis支持一个主库有多个从库，而一个从库只能有一个主库，采用主写从读的方案分离两个操作。之中最关键的就是数据一致性的问题，也就是主从复制，保证数据的一致性。
<!--more-->
## 主从复制过程
由slave redis 发送SYNC开始，master redis 保存内存快照，接着master redis将保存好的快照发送给slave redis，slave redis 存入内存，这个过程类似于TCP的握手。连接之后master redis就会往slave redis中写入相关数据，采用的是乐观复制。
可以通过info查看当前redis节点扮演的角色