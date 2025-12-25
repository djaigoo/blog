---
author: djaigo
title: linux-free命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`free` 是 Linux 中用于显示系统内存使用情况的命令。它可以显示物理内存、交换空间的使用情况。

```sh
➜ free --help
用法: free [选项]

选项:
 -b, --bytes         以字节为单位显示
     --kilo          以千字节为单位显示
     --mega          以兆字节为单位显示
     --giga          以吉字节为单位显示
     --tera          以太字节为单位显示
 -h, --human         人类可读格式
     --si            使用 1000 为基数（而非 1024）
 -k, --kilo          以千字节为单位显示（默认）
 -m, --mega          以兆字节为单位显示
 -g, --giga          以吉字节为单位显示
      --tera         以太字节为单位显示
 -l, --lohi          显示详细的高低内存统计
 -o, --old           使用旧格式（不显示 -/+ buffers/cache 行）
 -t, --total         显示总计行
 -s N                每 N 秒刷新一次
 -c N                刷新 N 次后退出
 -w, --wide          宽格式输出
 -V, --version       显示版本信息
```

# 基本语法

```sh
free [选项]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-h, --human` | 人类可读格式（最常用） |
| `-m` | 以 MB 为单位 |
| `-g` | 以 GB 为单位 |
| `-s N` | 每 N 秒刷新一次 |
| `-c N` | 刷新 N 次后退出 |
| `-t, --total` | 显示总计行 |
| `-w, --wide` | 宽格式输出 |

# 基本使用

## 显示内存使用

```sh
# 显示内存使用情况
➜ free

# 人类可读格式（最常用）
➜ free -h

# 以 MB 为单位
➜ free -m

# 以 GB 为单位
➜ free -g
```

## 持续监控

```sh
# 每2秒刷新一次
➜ free -s 2

# 刷新10次后退出
➜ free -c 10 -s 1

# 持续监控（人类可读格式）
➜ watch -n 1 free -h
```

## 显示总计

```sh
# 显示总计行
➜ free -h -t
```

# 输出说明

## free -h 输出示例

```
              total        used        free      shared  buff/cache   available
Mem:           8.0Gi       2.0Gi       1.0Gi       100Mi       5.0Gi       5.0Gi
Swap:          2.0Gi          0B       2.0Gi
```

### 内存（Mem）字段

- **total**：总内存
- **used**：已使用内存
- **free**：空闲内存
- **shared**：共享内存
- **buff/cache**：缓冲区和缓存
- **available**：可用内存（可用于新进程）

### 交换空间（Swap）

- **total**：总交换空间
- **used**：已使用交换空间
- **free**：空闲交换空间

# 实际应用场景

## 检查内存使用

```sh
# 检查当前内存使用
➜ free -h

# 检查是否有足够内存
➜ free -h | awk 'NR==2 {if ($3/$2 > 0.9) print "Memory usage is high"}'
```

## 监控内存

```sh
# 持续监控内存
➜ free -s 1

# 在脚本中监控
#!/bin/bash
while true; do
    free -h
    sleep 5
done
```

## 内存分析

```sh
# 查看内存使用百分比
➜ free | awk 'NR==2 {printf "Memory Usage: %.2f%%\n", $3/$2*100}'

# 查看交换空间使用
➜ free -h | grep Swap
```

# 注意事项

1. **buff/cache**：这部分内存可以被释放，用于新进程
2. **available**：这是实际可用于新进程的内存
3. **交换空间**：当物理内存不足时，系统会使用交换空间
4. **单位**：`-h` 使用 1024 为基数，`--si` 使用 1000 为基数

# 参考文献
* [free 手册页](https://linux.die.net/man/1/free)

