---
author: djaigo
title: linux-ps命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`ps`（process status）是 Linux 中用于显示进程信息的命令。它可以显示当前运行的进程及其详细信息。

```sh
➜ ps --help
用法:
 ps [选项]

基本选项:
 -A, -e              所有进程
 -a                  带有 tty 的进程，除了会话领导者
  a                  带有 tty 的进程，包括其他用户
  d                  除会话领导者外的所有进程
 -N, --deselect      否定选择
  r                  只显示运行中的进程
  T                  当前终端的所有进程
  x                  无控制终端的进程

选择进程的选项:
 -C <命令>           按命令名称选择
 -G, --Group <GID>   按真实组 ID (RGID) 选择
 -g, --group <group> 按会话或组名称选择
 -p, p, --pid <PID>  按进程 ID 选择
     --ppid <PID>    按父进程 ID 选择
 -q, q, --quick-pid <PID>
                     按进程 ID 选择(快速模式)
 -s, --sid <会话>    按会话 ID 选择
 -t, t, --tty <tty>  按终端选择
 -u, U, --user <UID> 按有效用户 ID (EUID) 选择
  U                  按真实用户 ID (RUID) 选择
 -U, --User <UID>    按真实用户 ID (RUID) 选择

输出格式:
 -F                  额外完整格式
 -f                  完整格式
  f, --forest        树状格式
 -H                  显示进程层次结构
 -j                  作业格式
  j                  任务格式
 -l                  长格式
  l                  长格式(BSD)
 -M, Z               添加安全数据
 -O <格式>           预加载的默认列
 -o, o, --format <格式>
                     用户定义的格式
  s                  信号格式
  u                  用户格式
  v                  虚拟内存格式
  X                  注册格式
  y                  不显示标志; 显示 rss 代替 addr
 -Z, --context       显示安全上下文(仅限SELinux)

杂项:
 -c                  显示调度程序信息
  c                  显示真实的命令名称
  e                  显示环境变量
  k,    --sort       指定排序顺序，如: [ - ]key[,[ - ]key[,...]]
  L                  显示格式说明符
  V, V, --version    显示版本信息
  w, w               宽输出
     --help <simple|list|output|threads|misc|all>
                     显示帮助信息
```

# 基本语法

```sh
ps [选项]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `aux` | 显示所有进程（BSD 风格） |
| `-ef` | 显示所有进程（Unix 风格） |
| `-e, -A` | 显示所有进程 |
| `-f` | 完整格式输出 |
| `-l` | 长格式输出 |
| `-u USER` | 显示特定用户的进程 |
| `-p PID` | 显示特定进程 |
| `--sort` | 按指定字段排序 |
| `-o` | 自定义输出格式 |

# 基本使用

## 显示进程

```sh
# 显示当前终端的进程
➜ ps

# 显示所有进程（BSD 风格，常用）
➜ ps aux

# 显示所有进程（Unix 风格）
➜ ps -ef

# 显示进程树
➜ ps auxf
```

## 查找特定进程

```sh
# 查找 nginx 进程
➜ ps aux | grep nginx

# 查找特定 PID
➜ ps -p 1234

# 查找特定用户的进程
➜ ps -u username

# 查找特定命令的进程
➜ ps -C nginx
```

## 自定义输出格式

```sh
# 只显示 PID 和命令
➜ ps -eo pid,cmd

# 显示特定字段
➜ ps -eo pid,ppid,user,cmd

# 显示进程树
➜ ps -ejH
```

## 排序

```sh
# 按 CPU 使用率排序
➜ ps aux --sort=-%cpu

# 按内存使用率排序
➜ ps aux --sort=-%mem

# 按 PID 排序
➜ ps aux --sort=pid
```

# 输出字段说明

## ps aux 输出字段

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  12345  1234 ?        Ss   Jan01   0:01 /sbin/init
```

- **USER**：进程所有者
- **PID**：进程 ID
- **%CPU**：CPU 使用率
- **%MEM**：内存使用率
- **VSZ**：虚拟内存大小（KB）
- **RSS**：物理内存大小（KB）
- **TTY**：终端
- **STAT**：进程状态
- **START**：启动时间
- **TIME**：CPU 时间
- **COMMAND**：命令

## 进程状态（STAT）

| 状态 | 说明 |
|------|------|
| `R` | 运行中（Running） |
| `S` | 睡眠（Sleeping，可中断） |
| `D` | 不可中断睡眠（通常等待 I/O） |
| `T` | 停止（Stopped） |
| `Z` | 僵尸进程（Zombie） |
| `<` | 高优先级 |
| `N` | 低优先级 |
| `L` | 有锁定的内存页 |
| `s` | 会话领导者 |
| `l` | 多线程 |
| `+` | 前台进程组 |

# 实际应用场景

## 查找进程

```sh
# 查找 nginx 进程
➜ ps aux | grep nginx | grep -v grep

# 查找并显示进程树
➜ ps auxf | grep nginx
```

## 监控进程

```sh
# 查看 CPU 使用率最高的进程
➜ ps aux --sort=-%cpu | head -10

# 查看内存使用率最高的进程
➜ ps aux --sort=-%mem | head -10

# 查看特定用户的进程
➜ ps -u root
```

## 进程信息

```sh
# 查看进程的完整命令行
➜ ps -fp 1234

# 查看进程的环境变量
➜ ps e -p 1234

# 查看进程树
➜ ps -ejH | grep nginx
```

## 与其他命令组合

```sh
# 统计进程数量
➜ ps aux | wc -l

# 查找并终止进程
➜ ps aux | grep nginx | awk '{print $2}' | xargs kill

# 监控进程变化
➜ watch -n 1 'ps aux | grep nginx'
```

# 注意事项

1. **输出格式**：`ps aux` 和 `ps -ef` 的输出格式不同
2. **实时性**：ps 显示的是执行瞬间的进程快照，不是实时监控
3. **权限**：某些进程信息可能需要 root 权限才能查看
4. **性能**：对于大量进程，ps 可能需要一些时间

# 参考文献
* [ps 手册页](https://linux.die.net/man/1/ps)

