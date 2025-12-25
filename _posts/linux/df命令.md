---
author: djaigo
title: linux-df命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`df`（disk free）是 Linux 中用于显示文件系统磁盘空间使用情况的命令。它可以显示已用空间、可用空间、使用率等信息。

```sh
➜ df --help
用法: df [选项]... [文件]...
显示每个文件所在的文件系统的信息，默认是显示所有文件系统。

  -a, --all             包含虚拟文件系统
  -B, --block-size=SIZE  使用 SIZE 字节的块
  -h, --human-readable   使用人类可读的格式(默认值：使用 1024 的幂次方)
  -H, --si               使用人类可读的格式(默认值：使用 1000 的幂次方)
  -i, --inodes           显示 inode 信息而非块使用情况
  -k                      以 1024 字节为单位显示
  -l, --local            只显示本地文件系统
  -P, --portability      使用 POSIX 输出格式
  -t, --type=TYPE        只显示类型为 TYPE 的文件系统
  -T, --print-type       显示文件系统类型
  -x, --exclude-type=TYPE  排除类型为 TYPE 的文件系统
      --total            产生总计
      --sync             在取得使用信息前调用 sync
      --no-sync          在取得使用信息前不调用 sync(默认)
      --help             显示此帮助信息并退出
      --version          输出版本信息并退出
```

# 基本语法

```sh
df [选项] [文件或目录...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-h, --human-readable` | 人类可读格式（KB、MB、GB） |
| `-H, --si` | 使用 1000 为基数（而非 1024） |
| `-T, --print-type` | 显示文件系统类型 |
| `-i, --inodes` | 显示 inode 使用情况 |
| `-a, --all` | 显示所有文件系统（包括虚拟文件系统） |
| `-l, --local` | 只显示本地文件系统 |
| `-t TYPE` | 只显示指定类型的文件系统 |
| `-x TYPE` | 排除指定类型的文件系统 |
| `--total` | 显示总计 |

# 基本使用

## 显示磁盘使用情况

```sh
# 显示所有文件系统
➜ df

# 人类可读格式（最常用）
➜ df -h

# 显示文件系统类型
➜ df -hT

# 显示特定文件系统
➜ df -h /dev/sda1
```

## 显示 inode 使用情况

```sh
# 显示 inode 使用情况
➜ df -i

# 人类可读格式
➜ df -ih
```

## 过滤文件系统

```sh
# 只显示 ext4 文件系统
➜ df -hT -t ext4

# 排除 tmpfs
➜ df -h -x tmpfs

# 只显示本地文件系统
➜ df -hl
```

## 显示总计

```sh
# 显示总计
➜ df -h --total
```

# 输出说明

## df -h 输出示例

```
文件系统        容量  已用  可用 使用% 挂载点
/dev/sda1        20G  10G  8.0G  56% /
/dev/sda2       100G  50G   45G  51% /home
tmpfs           2.0G     0  2.0G   0% /dev/shm
```

- **文件系统**：设备或文件系统名称
- **容量**：文件系统总大小
- **已用**：已使用的空间
- **可用**：可用的空间
- **使用%**：使用百分比
- **挂载点**：文件系统挂载的目录

# 实际应用场景

## 检查磁盘空间

```sh
# 检查根分区空间
➜ df -h /

# 检查所有分区
➜ df -h

# 查找使用率超过 80% 的分区
➜ df -h | awk '$5+0 > 80 {print}'
```

## 监控磁盘使用

```sh
# 定期检查磁盘使用
➜ watch -n 5 'df -h'

# 在脚本中检查
#!/bin/bash
usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $usage -gt 80 ]; then
    echo "Disk usage is above 80%"
fi
```

## 检查 inode 使用

```sh
# 检查 inode 使用情况
➜ df -ih

# 查找 inode 使用率高的分区
➜ df -ih | awk '$5+0 > 80 {print}'
```

## 与其他命令组合

```sh
# 按使用率排序
➜ df -h | sort -k5 -rn

# 只显示使用率
➜ df -h | awk 'NR>1 {print $1, $5}'

# 统计总空间
➜ df -h --total
```

# 注意事项

1. **单位**：`-h` 使用 1024 为基数，`-H` 使用 1000 为基数
2. **虚拟文件系统**：默认不显示虚拟文件系统（如 proc、sysfs），使用 `-a` 显示
3. **inode**：即使有空间，inode 用尽也无法创建新文件
4. **挂载点**：显示的是文件系统挂载的目录

# 参考文献
* [GNU Coreutils - df](https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html)

