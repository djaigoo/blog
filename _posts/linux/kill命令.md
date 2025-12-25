---
author: djaigo
title: linux-kill命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`kill` 是 Linux 中用于向进程发送信号的命令。虽然名字是"kill"，但它不仅可以终止进程，还可以发送各种信号来控制进程行为。

```sh
➜ kill --help
kill: kill [-s sigspec | -n signum | -sigspec] pid | jobspec ... or kill -l [sigspec]
    Send a signal to a job.
    
    Send the processes identified by PID or JOBSPEC the signal named by
    SIGSPEC or SIGNUM.  If neither SIGSPEC nor SIGNUM is present, then
    SIGTERM is assumed.
    
    Options:
      -s sig    SIG is a signal name
      -n sig    SIG is a signal number
      -l        list signal names
      -L        list signal names in a nice table format
    
    Exit Status:
    Returns success unless an invalid option is given or an error occurs.
```

# 基本语法

```sh
kill [选项] [信号] PID...
kill -l [信号]
```

# 常用信号

| 信号编号 | 信号名 | 说明 |
|---------|--------|------|
| 1 | SIGHUP | 挂起信号，通常用于重新加载配置 |
| 2 | SIGINT | 中断信号（Ctrl+C） |
| 9 | SIGKILL | 强制终止，无法被捕获或忽略 |
| 15 | SIGTERM | 终止信号（默认），可以捕获处理 |
| 18 | SIGCONT | 继续执行（恢复暂停的进程） |
| 19 | SIGSTOP | 停止信号，无法被捕获或忽略 |

# 基本使用

## 终止进程

```sh
# 发送默认信号（SIGTERM）
➜ kill 1234

# 强制终止（SIGKILL）
➜ kill -9 1234
# 或
➜ kill -KILL 1234

# 使用信号编号
➜ kill -15 1234
```

## 发送其他信号

```sh
# 发送 HUP 信号（常用于重新加载配置）
➜ kill -HUP 1234
# 或
➜ kill -1 1234

# 暂停进程
➜ kill -STOP 1234

# 恢复进程
➜ kill -CONT 1234
```

## 查看信号列表

```sh
# 列出所有信号
➜ kill -l

# 查看特定信号的编号
➜ kill -l TERM
15
```

## 终止多个进程

```sh
# 终止多个进程
➜ kill 1234 5678 9012

# 终止进程组
➜ kill -TERM -1234
```

# 相关命令

## killall

按进程名终止进程。

```sh
# 终止所有同名进程
➜ killall nginx

# 强制终止
➜ killall -9 nginx

# 发送特定信号
➜ killall -HUP nginx
```

## pkill

按模式匹配终止进程。

```sh
# 按名称模式终止
➜ pkill nginx

# 按完整命令行匹配
➜ pkill -f "nginx.*worker"

# 发送特定信号
➜ pkill -HUP nginx
```

## killpg

终止进程组。

```sh
# 终止进程组
➜ killpg 1234
```

# 实际应用场景

## 终止进程

```sh
# 查找并终止进程
➜ ps aux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill

# 使用 pkill
➜ pkill nginx

# 使用 killall
➜ killall nginx
```

## 重新加载配置

```sh
# 重新加载 Nginx 配置
➜ kill -HUP $(cat /var/run/nginx.pid)
# 或
➜ nginx -s reload

# 重新加载其他服务
➜ kill -HUP $(pgrep service_name)
```

## 优雅终止

```sh
# 先发送 TERM 信号（优雅终止）
➜ kill -TERM 1234

# 等待一段时间后，如果还没终止，强制终止
➜ sleep 5
➜ kill -KILL 1234
```

## 批量终止

```sh
# 终止所有 Python 进程
➜ pkill python

# 终止特定用户的进程
➜ pkill -u username process_name
```

# 注意事项

1. **SIGKILL 无法捕获**：SIGKILL（-9）信号无法被进程捕获或忽略，会立即终止
2. **优雅终止**：优先使用 SIGTERM，给进程机会清理资源
3. **权限**：只能终止自己的进程，root 可以终止任何进程
4. **僵尸进程**：SIGKILL 无法终止僵尸进程，需要终止其父进程

# 参考文献
* [kill 手册页](https://linux.die.net/man/1/kill)

