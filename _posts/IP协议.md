---
author: djaigo
title: IP协议
date: 2019-12-10 16:08:53
update: 2019-12-12 16:08:53
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/net.png
categories: 
  - net
tags: 
  - IP
  - IPv4
  - IPv6
mathjax: true
enable html: true
---

# 简介
IP协议是TCP/IP协议族的动力，它为上层协议提供无状态、无连接、不可靠的服务。
* 无状态（stateless），是指IP通信双方不同步传输数据的状态信息，因此所有IP数据报的发送、传输和接收都是相互独立的
* 无连接（connectionless），是指IP通信双方都不长久地维持对方的任何信息，因此每个IP数据报都要带上对方的IP地址
* 不可靠（unreliable），是指IP协议不能保证IP数据报准确到达接收端，只是尽最大努力

# IPv4
## 头部结构
IPv4头部结构，固定长度为20字节，选项最多可有40字节
![IPv4 header](https://img-1251474779.cos.ap-beijing.myqcloud.com/IP协议/v4header.png)
* 4位版本号（version），指定IP协议的版本，IPv4的值是4，其他IPv4的扩展版本（SIP和PIP）拥有不同的版本和不同的头部结构
* 4位头部长度（header length），标识IP头部有多少个4字节，4位比特最大能表示15，所以IP头部长度最长为$4*15=60$字节
* 8位服务类型（type of service，TOS）
  * 3位优先权字段（现已被忽略）
  * 4位TOS分别表示，最小延迟、最大吞吐量、最高可靠性和最小费用，同时只能一个置1，应用程序根据实际情况来设置
  * 1位保留字段（必须置0）
* 16位总长度（total length），是指整个IP数据报的长度，以字节为单位，因此IP数据报的最大长度为$2^{16}-1=65535$，但是由于MTU（最大传输单元）限制，超过MTU的数据报将被分片传输
* 16位标识（identification）唯一的标识主机发送的每一个数据报，初始值由系统随机生成，每发送一个数据报其值加一，该值在数据报分片时复制到每个分片，因此同一个数据报的所有分片都具有相同的标识值
* 3位标志字段（flag）
  * 第一位保留
  * 第二位（Don't Fragment，DF）表示禁止分片，如果设置了这个值，IP模块将不对数据报进行分片，如果数据报超过MTU，IP模块将丢弃数据报并返回一个ICMP差错报文
  * 第三位（More Fragment，MF）表示更多分片，除了最后一个分片外其他分片都要把它置1
* 13位分片偏移（fragmentation offset）是分片相对原始IP数据报开始处（仅指数据部分）偏移，实际的偏移值是左移3位（$*8$）后得到的，因为这个原因，除了最后一个IP分片外，每个IP分片的数据部分的长度必须是8的整数倍（保证每个分片有一个合适偏移值）
* 8位生存时间（Time To Live，TTL）是数据报到达目的地址之前允许经过路由器的跳数，TTL由发送端设置（常见值64），每经过一个路由，该值就减一，当减为0时，路由器将丢弃数据报，并向发送源发送一个ICMP差错报文，TTL可以防止数据报陷入路由循环
* 8位协议（protocol）用来区分上层协议，`/etc/protocols`文件定义了所有上层协议对应的protocol字段的数值，也可以通过[IANA](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xml)获取
* 16位头部校验和（header checksum）由发送端填充，接收端对其使用CRC算法检验**IP数据报头部**在传输过程中是否损坏
* 32位源IP地址和目的端IP地址用来表示IP数据报的发送端和接收端，一般情况下这两个地址在整个数据报的传递过程中保持不变
* 选项字段（option）是一个可变长可选信息，这部分最多包含40字节，可选内容有
  * 记录路由（record route）告诉数据报途经的所有路由器都将自己的IP地址填入IP头部的选项部分，这样可以追踪数据报的传递路径
  * 时间戳（timestamp）告诉每个路由器都将数据报被转发的时间（或时间与IP地址对）填入IP头部的选项部分，这样可以测量途经路由之间数据报传输的时间
  * 松散源路由选择（loose source routing）指定一个路由器IP地址列表，数据报发送过程中必须经过其中所有路由器
  * 严格源路由选择（strict source routing）和松散源路由选择类似，不过数据报只能经过被指定的路由器

## IP分片
当IP数据报的长度超过帧的MTU时，它将被分片传输。分片可能发生在发送端，也有可能发生在中转路由器中，而且可能在传输的过程中多次分片，但只有再最终的目标机器上，这些分片才会被内核中的IP模块重新组装。
IP头部中提供数据报标识、标志和片偏移提供了足够的重组信息。一个IP数据报的每个分片都具有相同的标识值，但具有不同的片偏移。除了最后一个分片外，其他分片都将设置MF标志，每个分片的IP数据报总长度会被字段将会被设置为该分片的长度。
一般以太网帧的MTU是1500字节（可以通过ifconfig和netstat查看），IP数据报头部占用20字节，所以最大传输1480字节，这里利用ICMP可以产生IP数据报分片，ICMP头部信息占8字节，所以数据只用传输1473字节就能使IP数据报分片。
使用golang模拟这个情况
```go
type ICMP struct {
    Type        uint8
    Code        uint8
    CheckSum    uint16
    Identifier  uint16
    SequenceNum uint16
}

func Checksum(data []byte) uint16 {
    var (
        sum    uint32
        length = len(data)
        index  int
    )
    for length > 1 {
        sum += uint32(data[index])<<8 + uint32(data[index+1])
        index += 2
        length -= 2
    }
    if length > 0 {
        sum += uint32(data[index])
    }
    sum += sum >> 16
    return uint16(^sum)
}

func getICMP(seq uint16) ICMP {
    icmp := ICMP{
        Type:        8,
        Code:        0,
        CheckSum:    0,
        Identifier:  0,
        SequenceNum: seq,
    }
    var buffer bytes.Buffer
    binary.Write(&buffer, binary.BigEndian, icmp)
    icmp.CheckSum = Checksum(buffer.Bytes())
    buffer.Reset()
    return icmp
}

func main() {
    icmp := getICMP(1)
    conn, err := net.DialIP("ip4:icmp", nil, &net.IPAddr{IP: net.IP{220, 181, 38, 150}})
    if err != nil {
        fmt.Println(err.Error())
        return
    }
    defer conn.Close()
    arr := make([]byte, 1473)
    for i := range arr {
        arr[i] = byte(i)
    }
    // 将最后一个字节设置为0
    arr[1472] = 0
    var buffer bytes.Buffer
    binary.Write(&buffer, binary.BigEndian, icmp)
    binary.Write(&buffer, binary.BigEndian, arr)
    if _, err := conn.Write(buffer.Bytes()); err != nil {
        fmt.Println(err.Error())
        return
    }
    conn.SetReadDeadline(time.Now().Add(time.Second * 5))
    recv := make([]byte, 2048)
    n, err := conn.Read(recv)
    if err != nil {
        fmt.Println(err.Error())
    }
    fmt.Printf("%#v", recv[:n])
}
```

我们可以通过wireshark查看数据报具体信息

![第一分片IP数据报头部信息](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/20191211022407734.png)

上图可以看到Flags设置了MF标志

![第二分片IP数据报头部信息](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/20191211022558072.png)

上图可以看到设置了数据报偏移量$185*8=1480$

![第一分片IP数据报局部内容](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/20191211022814706.png)

上图蓝色区域表示IP数据报的数据部分，前8字节表示ICMP头部信息，后面是ICMP数据

![第二分片IP数据报内容](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/20191211022830044.png)

上图说明分片后的IP数据报数据是承接上一个数据报，内核收到这些数据后将其拼装成一个完整IP数据报

## IP路由
IP协议一个核心任务是数据报的路由，即决定发送数据报到目标机器的路径。

### 工作流程
![IP模块基本工作流程](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/IP%E6%A8%A1%E5%9D%97%E5%9F%BA%E6%9C%AC%E6%B5%81%E7%A8%8B.png)

当IP模块收到来自数据链路层的IP数据报时，先对数据报头部做CRC校验，确认无误后就分析其头部的具体信息。
如果IP数据报头部设置了源站路由选择（松散源路由选择或严格源路由选择），则IP模块调用数据报转发子模块来处理数据报。如果该IP数据报的头部中目标IP地址是本机的某个IP地址或者是广播地址（即该数据报是发给本机的），则IP模块就根据数据报头部中的协议来决定将它派发给那个上层协议处理。如果IP模块发现这个数据报不是发给本机的，则调用数据报转发子模块来处理数据报。
IP数据报转发子模块首先检查系统是否允许转发，如果不允许，IP模块就将数据报丢弃，如果允许则将会进行数据报转发。
IP数据报应该发送至哪一个路由（或目标机器），以及用哪张网卡发送，就是IP路由的过程，都是由计算下一跳路由子模块处理。数据报路由的核心结构是路由表，由目标IP进行分类，同一类型的IP数据报将被发往相同的下一跳路由。
IP输出队列中存放的是所有等待发送的IP数据报，其中除了需要转发的数据报外，还有本机封装的上层协议的IP数据报。
虚线箭头显示路由表更新过程，这个过程是指通过路由协议或者route命令调整路由表，是指更适应最新的网络拓扑结构，称之为IP路由策略。

### 路由机制
IP路由机制的核心就是IP路由表，可以使用route或者netstat查看路由表
路由表包含每项都有8个字段，字段含义如下：

| 字段      | 含义    | 
| :-----------: | :-------- |
| Destination    | 目标网络或主机  |
| Gateway     | 网关地址，`*`表示和本机在同一个网络 |
| Genmask     | 网络掩码 |
| Flags | 路由标志常见的标志有：<br/><ul><li>U，该路由项是活动的</li><li>H，该路由项的目标是一台主机</li><li>G，该路由项的目标是网关</li><li>D，该路由项是有重定向生成的</li><li>M，该路由项被重新修改过</li></ul>|
|Metric|路由距离，即到达指定网络所需的中转数|
|Ref|路由项被引用的次数（Linux未使用）|
|Use|该路由项被使用的次数 |
|Iface|该路由项对应的输出网卡接口|

我们可以执行route命令获取当前的路由表
```sh
# route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         gateway         0.0.0.0         UG    0      0        0 eth0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
```

目标地址表示default，即默认路由，在标志中有`G`表示下一跳是网关，网关地址是`gateway`，如果Gateway是`*`，则不需要中转，直接发送目标机器。
IP的路由机制分为以下3个步骤：
* 步骤1，查找路由表中和数据报的目标地址IP地址完全匹配的主机IP地址，如果找到就使用该路由项，如果没有找到则转到步骤2
* 步骤2，查找路由表中和数据报的目标IP地址具有相同网络ID的网络IP地址，如果找到就使用该路由项，没有找到则转到步骤3
* 步骤3，选择默认路由项，通常意味着下一跳路由是网关

有上面的路由表可知，发送到IP地址为`172.17.*.*`（`172.17.0.0/16`）的地址都可以将数据报直接发送到目标机器（路由表第二项），所有访问Internet的请求都将通过默认网关转发。

### 路由表更新
路由表必须能够更新，以适应网络连接的变化，这样IP模块才能准确、高效的转发数据报。可以通过route命令手动修改路由表，是属于静态的路由更新方式，对于大型路由器，一般通过BGP（Border Gateway Protocol，边际网关协议）、RIP（Routing Information Protocol，路由信息协议）、OSPF（Open Shortest Path First，开放式最短路径优先）等协议来发现路径，并动态更新自己的路由表。

## IP转发
IP模块把不是发送给本机的IP数据报将由数据报转发子模块来处理，路由器都能执行数据报的转发操作，而主机一般只发送和接收数据报，这是因为主机上的`/proc/sys/net/ipv4/ip_forward`内核参数默认设置为0，我们可以修改这个值来使主机的数据报转发功能。
IP数据报转发操作流程：
* 检查数据报头部的TTL值，如果TTL值是0，则丢弃该数据报
* 查看数据报头部的阉割路由选择选项，如果该选项被设置，则检测数据报的目标IP地址是否是本机的某个IP地址，如果不是，则发送一个ICMP源站选路失败报文给发送端
* 如果有必要，则给源端发送一个ICMP重定向报文，以告诉它一个更合理的下一跳路由器
* 将TTL减1
* 处理IP头部选项
* 如果有必要，则执行IP分片操作

## 重定向
### ICMP重定向报文
利用ICMP重定向报文可以告诉目标机器IP数据报应该使用哪个路由器转发，并且以此来更新路由表（通常是更新路由表缓冲，而不是直接更改路由表）。
`/proc/sys/net/ipv4/conf/all/send_redirects`内核参数指定是否允许发送ICMP重定向报文，`/proc/sys/net/ipv4/conf/all/accept_redirects`内核参数则指定是否允许接收ICMP重定向报文，一般来说主机只能接收ICMP从定向报文，而路由器只能发送ICMP重定向报文。
### 主机重定向
我们可以将目标主机设置开启转发功能，将本机网关设置为目标主机，这样就可以通过目标主机来访问Internet。
主机重定向流程：
* 主机向目标主机发送IP数据报
* 目标主机向路由器发送数据，发现主机可以直接发送给它的路由器是比较合理的路径
* 目标主机向主机发送一个ICMP重定向报文
* 后序的IP数据报，主机都会直接发送给路由器

# IPv6
随着网络技术的发展IPv4已经无法满足需求，而且目前IPv4的地址已经分配完毕。IPv6协议不仅解决了IPv4地址不够用的情况，还做了很多改进。比如：增加了多播和流功能，为网络上多媒体内容的质量提供精细的控制；引入自动配置功能，使局域网管理更方便；增加了专门的网络安全功能等。
## 头部结构
IPv6头部由40字节固定头部和可变长的扩展头部组成

![IPv6固定头部结构](http://img-1251474779.cos.ap-beijing.myqcloud.com/IP%E5%8D%8F%E8%AE%AE/IPv6header.png)

* 4位版本号（version）对于IPv6来说，其值是6
* 8位通信类型（traffic class）只是数据流通信类型或优先级，和IPv4的TOS类似
* 20位流标签（flow label）是IPv6新加字段，对于某些对连接的服务质量有特殊要求的通信，比如音频或视频等实时数据传输
* 16位荷载长度（payload length）指的是IPv6扩展头部和应用程序长度之和，不包括固定头部长度
* 8位下一个包头（next header）指出紧跟IPv6固定头部后的包头类型，如扩展头（如果有的话）或某个上层协议头（比如TCP，UPD和ICMP），它类似于IPv4头部中的协议字段，且取值相同含义相同
* 8位跳数限制（hop limit）和IPv4的TTL相同
* 128位表示源IP和目的IP地址，16字节使IP地址的总量达到了$2^{128}$个，号称IPv6能使地球上每一粒沙子都能分配一个IP地址

IPv4使用点分十进制表示IP地址，而IPv6地址则使用16进制字符串表示，比如`fe80:0000:0000:0000:0000:0000:0000:0001`。IPv6地址使用`:`分隔成8组，每组包含，使用16进制表示2个字节。由于0太多的话，这样表示过于麻烦，所以可以使用零压缩法将其简写，就是省略中间全是0的组，上面的例子就可以简写成`fe80::1`，零压缩法只能在IPv6地址中使用一次，不然无法知道中间的省略了多少个零。

## 扩展头
可变长的扩展头部使得IPv6能支持更多的选项，并且很便于将来的扩展需要。它的长度可以是零，表示数据报没有使用任何扩展头部，一个数据报可以包含多个扩展头部，每个扩展头部的类型由前一个头部（固定头部或扩展头部）中的下一个报头字段指定，目前使用的扩展头部有：

| 扩展头部      | 含义    | 
| :-----------: | -------- |
| Hop-by-Hop    | 逐跳选项头部，它包含每个路由器都必须检查和处理的特殊参数选项  |
| Destination option     | 目的选项头部，指定由最终目的节点处理的选项 |
| Routing     | 路由头部，指定数据报要经过哪些中转路由，功能类似于IPv4的松散源路由选择选项和记录路由选项 |
| Fragment | 分片头部，处理分片和重组的细节 |
|Authentication| 认证头部，提供数据源认证、数据完整性检查和反重播保护 |
|Encapsulation Security Payload| 加密头部，提供加密服务 |
|No next header| 没有后续扩展头部 |


# 参考文献
* 《Linux高性能服务器编程》

