---
author: djaigo
title: linux-top和htop命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`top` 和 `htop` 是 Linux 中用于实时监控系统进程和资源使用情况的命令。它们提供了动态更新的系统状态信息。

# top 命令

`top` 是系统自带的进程监控工具，可以实时显示系统资源使用情况和进程信息。

## 基本语法

```sh
top [选项]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-d, --delay=SECS` | 刷新间隔（秒） |
| `-p PID` | 只显示指定进程 |
| `-u USER` | 只显示指定用户的进程 |
| `-n NUMBER` | 刷新次数后退出 |
| `-b` | 批处理模式 |
| `-H` | 显示线程 |

## 基本使用

```sh
# 启动 top
➜ top

# 指定刷新间隔
➜ top -d 2

# 只显示特定进程
➜ top -p 1234

# 只显示特定用户的进程
➜ top -u username

# 批处理模式（用于脚本）
➜ top -b -n 1
```

## top 界面说明

```
top - 10:30:00 up 10 days,  1:23,  3 users,  load average: 0.50, 0.45, 0.40
Tasks: 150 total,   1 running, 149 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.0 us,  2.0 sy,  0.0 ni, 93.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  8192.0 total,  2048.0 free,  4096.0 used,  2048.0 buff/cache
MiB Swap:  4096.0 total,  4096.0 free,     0.0 used,  6144.0 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1234 root      20   0  123456  12345   1234 R  10.0   0.1   0:10.00 process1
```

### 顶部信息

- **系统时间**：当前系统时间
- **运行时间**：系统运行时间
- **用户数**：登录用户数
- **负载平均**：1分钟、5分钟、15分钟的平均负载
- **任务**：总进程数、运行中、睡眠、停止、僵尸
- **CPU**：用户、系统、空闲、等待等
- **内存**：总内存、空闲、使用、缓存
- **交换空间**：总交换空间、使用情况

### 进程列表

- **PID**：进程 ID
- **USER**：进程所有者
- **PR**：优先级
- **NI**：nice 值
- **VIRT**：虚拟内存
- **RES**：物理内存
- **SHR**：共享内存
- **S**：进程状态
- **%CPU**：CPU 使用率
- **%MEM**：内存使用率
- **TIME+**：CPU 时间
- **COMMAND**：命令

## top 交互命令

| 按键 | 说明 |
|------|------|
| `空格` | 立即刷新 |
| `k` | 终止进程（输入 PID） |
| `r` | 修改进程优先级 |
| `M` | 按内存使用率排序 |
| `P` | 按 CPU 使用率排序 |
| `T` | 按运行时间排序 |
| `f` | 选择显示字段 |
| `o` | 设置排序字段 |
| `q` | 退出 |
| `h` | 显示帮助 |

# htop 命令

`htop` 是 `top` 的增强版，提供更友好的界面和更多功能（需要安装）。

## 安装

```sh
# Ubuntu/Debian
sudo apt-get install htop

# CentOS/RHEL
sudo yum install htop

# macOS
brew install htop
```

## 基本使用

```sh
# 启动 htop
➜ htop

# 指定刷新间隔
➜ htop -d 2
```

## htop 特点

1. **彩色界面**：使用颜色区分不同类型的进程
2. **鼠标支持**：可以使用鼠标操作
3. **树状显示**：可以显示进程树
4. **搜索功能**：可以搜索进程
5. **更直观**：界面更友好，信息更清晰

## htop 操作

| 按键 | 说明 |
|------|------|
| `F1` | 帮助 |
| `F2` | 设置 |
| `F3` | 搜索 |
| `F4` | 过滤 |
| `F5` | 树状显示 |
| `F6` | 排序 |
| `F7` | 降低优先级 |
| `F8` | 提高优先级 |
| `F9` | 终止进程 |
| `F10` | 退出 |
| `空格` | 标记进程 |
| `t` | 树状/列表切换 |
| `H` | 显示/隐藏线程 |
| `K` | 显示/隐藏内核线程 |

# 实际应用场景

## 系统监控

```sh
# 实时监控系统
➜ top

# 监控特定进程
➜ top -p $(pgrep nginx)

# 监控特定用户
➜ top -u www-data
```

## 性能分析

```sh
# 查看 CPU 使用率最高的进程
➜ top
# 按 P 键按 CPU 排序

# 查看内存使用率最高的进程
➜ top
# 按 M 键按内存排序
```

## 进程管理

```sh
# 在 top 中终止进程
➜ top
# 按 k 键，输入 PID，回车

# 修改进程优先级
➜ top
# 按 r 键，输入 PID，输入 nice 值
```

# 注意事项

1. **实时更新**：top 和 htop 会持续更新，按 `q` 退出
2. **资源消耗**：top 本身也会消耗一些系统资源
3. **权限**：某些操作（如修改优先级）可能需要权限
4. **htop 需安装**：htop 不是所有系统默认安装

# 参考文献
* [top 手册页](https://linux.die.net/man/1/top)
* [htop 官方文档](https://htop.dev/)

