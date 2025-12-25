---
author: djaigo
title: linux-sar命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

# sar简介
centos安装sar命令
```sh
➜ yum install sysstat -y
```

安装后执行sar会报错找不到`/var/log/sa/sa14`文件，需要等几分钟就好了。

```sh
➜ sar -h
用法: sar [ 选项 ] [ <时间间隔> [ <次数> ] ]
主选项和报告：
	-b	I/O 和传输速率信息状况
	-B	分页状况
	-d	块设备状况
	-F [ MOUNT ]
		Filesystems statistics
	-H	交换空间利用率
	-I { <中断> | SUM | ALL | XALL }
		中断信息状况
	-m { <关键词> [,...] | ALL }
		电源管理统计信息
		关键字:
		CPU	CPU 频率
		FAN	风扇速度
\t\tFREQ\tCPU 平均时钟频率
		IN	输入电压
		TEMP	设备温度
\t\tUSB\t连接的USB 设备
	-n { <关键词> [,...] | ALL }
		网络统计信息
		关键词可以是：
		DEV	网卡
		EDEV	网卡 (错误)
		NFS	NFS 客户端
		NFSD	NFS 服务器
		SOCK	Sockets (套接字)	(v4)
		IP	IP 流	(v4)
		EIP	IP 流	(v4) (错误)
		ICMP	ICMP 流	(v4)
		EICMP	ICMP 流	(v4) (错误)
		TCP	TCP 流	(v4)
		ETCP	TCP 流	(v4) (错误)
		UDP	UDP 流	(v4)
		SOCK6	Sockets (套接字)	(v6)
		IP6	IP 流	(v6)
		EIP6	IP 流	(v6) (错误)
		ICMP6	ICMP 流	(v6)
		EICMP6	ICMP 流	(v6) (错误)
		UDP6	UDP 流	(v6)
	-q	队列长度和平均负载
	-r	内存利用率
	-R	内存状况
	-S	交换空间利用率
	-u [ ALL ]
		CPU 利用率
	-v	Kernel table 状况
	-w	任务创建与系统转换统计信息
	-W	交换信息
	-y	TTY 设备状况
```

# sar参数
## 查看CPU使用情况
当选项为空时则打印CPU使用情况，或使用`sar -u n m`每过n获取一次cpu指标，总共获取m次

指标说明
* `%user`：用户模式下消耗的CPU时间的比例
* `%nice`：通过nice改变了进程调度优先级的进程，在用户模式下消耗的CPU时间的比例
* `%system`：系统模式下消耗的CPU时间的比例
* `%iowait`：CPU等待磁盘I/O导致空闲状态消耗的时间比例
* `%steal`：利用Xen等操作系统虚拟化技术，等待其它虚拟CPU计算占用的时间比例
* `%idle`：CPU空闲时间比例

## 查看内存使用情况
使用`sar -r n m`可以每过n秒获取一次内存指标，总共获取m次

* `kbmemfree`：这个值和free命令中的free值基本一致,所以它不包括buffer和cache的空间.
* `kbmemused`：这个值和free命令中的used值基本一致,所以它包括buffer和cache的空间.
* `%memused`：物理内存使用率，这个值是kbmemused和内存总量(不包括swap)的一个百分比.
* `kbbuffers`和`kbcached`：这两个值就是free命令中的buffer和cache.
* `kbcommit`：保证当前系统所需要的内存,即为了确保不溢出而需要的内存(RAM+swap).
* `%commit`：这个值是kbcommit与内存总量(包括swap)的一个百分比.

## 查看网卡使用情况
使用`sar -n DEV n m`可以每过n秒获取一次网卡指标，总共获取m次

指标说明
* `IFACE`：网卡名
* `rxpck/s`：每秒钟接收的数据包
* `txpck/s`：每秒钟发送的数据包
* `rxbyt/s`：每秒钟接收的字节数
* `txbyt/s`：每秒钟发送的字节数
* `rxcmp/s`：每秒钟接收的压缩数据包
* `txcmp/s`：每秒钟发送的压缩数据包
* `rxmcst/s`：每秒钟接收的多播数据包

`-n`选项下面还有一些子选项，可以更细致的获取相关数据的指标

## 查看系统负载情况
使用`sar -r n m`可以每过n秒获取一次内存指标，总共获取m次

指标说明
* `runq-sz`：运行队列的长度（等待运行的进程数）
* `plist-sz`：进程列表中进程（processes）和线程（threads）的数量
* `ldavg-1`：最后1分钟的系统平均负载 
* `ldavg-5`：过去5分钟的系统平均负载
* `ldavg-15`：过去15分钟的系统平均负载

# 参考文献
* [12\. sar 找出系统瓶颈的利器](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/sar.html)