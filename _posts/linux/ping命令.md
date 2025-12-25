---
author: djaigo
title: linux-ping命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
  - network
---

`ping` 是 Linux 中用于测试网络连通性和测量网络延迟的命令。它通过发送 ICMP 回显请求包来测试目标主机的可达性。

```sh
➜ ping --help
用法: ping [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
            [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
            [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
            [-w deadline] [-W timeout] [hop ...] destination
```

# 基本语法

```sh
ping [选项] 目标主机
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-c, --count=N` | 发送 N 个包后停止 |
| `-i, --interval=N` | 发送间隔（秒） |
| `-s, --size=N` | 数据包大小（字节） |
| `-t, --ttl=N` | 设置 TTL 值 |
| `-W, --timeout=N` | 等待响应的超时时间（秒） |
| `-q, --quiet` | 安静模式，只显示统计信息 |
| `-v, --verbose` | 详细输出 |
| `-f, --flood` | 洪水模式（快速发送，需 root） |
| `-I, --interface=IFACE` | 指定网络接口 |

# 基本使用

## 基本 ping

```sh
# 持续 ping（按 Ctrl+C 停止）
➜ ping example.com

# ping 指定次数后停止
➜ ping -c 4 example.com

# ping IP 地址
➜ ping 8.8.8.8
```

## 设置间隔

```sh
# 每2秒发送一次
➜ ping -i 2 example.com

# 快速 ping（间隔0.2秒）
➜ ping -i 0.2 example.com
```

## 设置数据包大小

```sh
# 发送1024字节的数据包
➜ ping -s 1024 example.com
```

## 设置超时

```sh
# 设置超时时间为5秒
➜ ping -W 5 example.com
```

## 安静模式

```sh
# 只显示统计信息
➜ ping -q -c 10 example.com
```

# 实际应用场景

## 网络连通性测试

```sh
# 测试本地网络
➜ ping 192.168.1.1

# 测试外网
➜ ping 8.8.8.8

# 测试域名解析
➜ ping example.com
```

## 网络质量测试

```sh
# 测试延迟和丢包率
➜ ping -c 100 example.com

# 输出示例：
# 100 packets transmitted, 98 received, 2% packet loss
# rtt min/avg/max/mdev = 10.123/15.456/25.789/3.456 ms
```

## 持续监控

```sh
# 持续监控网络连接
➜ ping -i 1 example.com

# 在脚本中监控
#!/bin/bash
while ping -c 1 example.com > /dev/null; do
    echo "Network is up"
    sleep 5
done
echo "Network is down"
```

# 注意事项

1. **权限**：某些选项（如 `-f`）需要 root 权限
2. **防火墙**：某些主机可能禁 ping（ICMP）
3. **频率限制**：不要过于频繁地 ping，避免被视为攻击

# 参考文献
* [ping 手册页](https://linux.die.net/man/8/ping)

