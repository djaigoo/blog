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
头部结构字段：
```text
0                   1                   2                   3 
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Source Port          |       Destination Port        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Sequence Number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Acknowledgment Number                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Data |           |U|A|P|R|S|F|                               |
| Offset| Reserved  |R|C|S|S|Y|I|            Window             |
|       |           |G|K|H|T|N|N|                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           Checksum            |         Urgent Pointer        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             data                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

* Source Port:  16 bits
* Destination Port:  16 bits
* Sequence Number:  32 bits
* Acknowledgment Number:  32 bits
* Data Offset:  4 bits
* Reserved:  6 bits
* Control Bits:  6 bits
* Window:  16 bits
* Checksum:  16 bits
* Urgent Pointer:  16 bits
* Options:  variable
* Padding:  variable

## Sequence Number
## Acknowledgment Number
## Data Offset
## Control Bits
## Window
## Checksum
检验和是填充一个伪包头加上TCP报文求和算出。
伪包头结构字段：
```text
+--------+--------+--------+--------+
|           Source Address          |
+--------+--------+--------+--------+
|         Destination Address       |
+--------+--------+--------+--------+
|  zero  |  PTCL  |    TCP Length   |
+--------+--------+--------+--------+
```
  - Source Address: 32 bits
  - Destination Address: 32 bits
  - zero: 8 bits
  - PTCL: 8 bits
  - TCP Length: 16 bits

## Urgent Pointer
## Options
  当前定义的选项字段
  
| Kind | Length | Meaning |
| ---- | ------ | ------- |
|  0   |   -  |   End of option list. |
|  1   |   -  |   No-Operation. |
|  2   |   4  |  Maximum Segment Size. |



# 连接
## TCP 连接状态机
```text
                              +---------+ ---------\      active OPEN
                              |  CLOSED |            \    -----------
                              +---------+<---------\   \   create TCB
                                |     ^              \   \  snd SYN
                   passive OPEN |     |   CLOSE        \   \
                   ------------ |     | ----------       \   \
                    create TCB  |     | delete TCB         \   \
                                V     |                      \   \
                              +---------+            CLOSE    |    \
                              |  LISTEN |          ---------- |     |
                              +---------+          delete TCB |     |
                   rcv SYN      |     |     SEND              |     |
                  -----------   |     |    -------            |     V
 +---------+      snd SYN,ACK  /       \   snd SYN          +---------+
 |         |<-----------------           ------------------>|         |
 |   SYN   |                    rcv SYN                     |   SYN   |
 |   RCVD  |<-----------------------------------------------|   SENT  |
 |         |                    snd ACK                     |         |
 |         |------------------           -------------------|         |
 +---------+   rcv ACK of SYN  \       /  rcv SYN,ACK       +---------+
   |           --------------   |     |   -----------
   |                  x         |     |     snd ACK
   |                            V     V
   |  CLOSE                   +---------+
   | -------                  |  ESTAB  |
   | snd FIN                  +---------+
   |                   CLOSE    |     |    rcv FIN
   V                  -------   |     |    -------
 +---------+          snd FIN  /       \   snd ACK          +---------+
 |  FIN    |<-----------------           ------------------>|  CLOSE  |
 | WAIT-1  |------------------                              |   WAIT  |
 +---------+          rcv FIN  \                            +---------+
   | rcv ACK of FIN   -------   |                            CLOSE  |
   | --------------   snd ACK   |                           ------- |
   V        x                   V                           snd FIN V
 +---------+                  +---------+                   +---------+
 |FINWAIT-2|                  | CLOSING |                   | LAST-ACK|
 +---------+                  +---------+                   +---------+
   |                rcv ACK of FIN |                 rcv ACK of FIN |
   |  rcv FIN       -------------- |    Timeout=2MSL -------------- |
   |  -------              x       V    ------------        x       V
    \ snd ACK                 +---------+delete TCB         +---------+
     ------------------------>|TIME WAIT|------------------>| CLOSED  |
                              +---------+                   +---------+
```

### 各个状态意义
* LISTEN - represents waiting for a connection request from any remote
    TCP and port.
* SYN-SENT - represents waiting for a matching connection request
    after having sent a connection request.
* SYN-RECEIVED - represents waiting for a confirming connection
    request acknowledgment after having both received and sent a
    connection request.
* ESTABLISHED - represents an open connection, data received can be
    delivered to the user.  The normal state for the data transfer phase
    of the connection.
* FIN-WAIT-1 - represents waiting for a connection termination request
    from the remote TCP, or an acknowledgment of the connection
    termination request previously sent.
* FIN-WAIT-2 - represents waiting for a connection termination request
    from the remote TCP.
* CLOSE-WAIT - represents waiting for a connection termination request
    from the local user.
* CLOSING - represents waiting for a connection termination request
    acknowledgment from the remote TCP.
* LAST-ACK - represents waiting for an acknowledgment of the
    connection termination request previously sent to the remote TCP
    (which includes an acknowledgment of its connection termination
    request).
* TIME-WAIT - represents waiting for enough time to pass to be sure
    the remote TCP received the acknowledgment of its connection
    termination request.
* CLOSED - represents no connection state at all.

## 建立连接
## Establishing
## 断开连接
# 超时重传
# 拥塞控制

# 参考文献
* [TRANSMISSION CONTROL PROTOCOL](https://tools.ietf.org/html/rfc793)
* [Requirements for Internet Hosts -- Communication Layers](https://tools.ietf.org/html/rfc1122)
* 《Linux高性能服务器编程》
* [传输控制协议](https://zh.wikipedia.org/wiki/%E4%BC%A0%E8%BE%93%E6%8E%A7%E5%88%B6%E5%8D%8F%E8%AE%AE)
