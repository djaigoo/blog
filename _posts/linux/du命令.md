---
author: djaigo
title: linux-du命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`du`（disk usage）是 Linux 中用于显示目录或文件磁盘使用情况的命令。它可以显示目录占用的磁盘空间。

```sh
➜ du --help
用法: du [选项]... [文件]...
 或: du [选项]... --files0-from=F
Summarize disk usage of the set of FILEs, recursively for directories.

  -0, --null            end each output line with NUL, not newline
  -a, --all             write counts for all files, not just directories
      --apparent-size   print apparent sizes, rather than disk usage; although
                        the apparent size is usually smaller, it may be
                        larger due to holes in ('sparse') files, internal
                        fragmentation, indirect blocks, and the like
  -B, --block-size=SIZE  scale sizes by SIZE before printing them; e.g.,
                           '-BM' prints sizes in units of 1,048,576 bytes;
                           see SIZE format below
  -b, --bytes           equivalent to '--apparent-size --block-size=1'
  -c, --total           produce a grand total
  -D, --dereference-args  dereference only symlinks that are listed on the
                        command line
  -d, --max-depth=N     print the total for a directory (or file, with --all)
                       only if it is N or fewer levels below the command
                       line argument
  -H                    equivalent to --dereference-args (-D)
  -h, --human-readable  print sizes in human readable format (e.g., 1K 234M 2G)
      --inodes          list inode usage information instead of block usage
  -k                    like --block-size=1K
  -L, --dereference     dereference all symbolic links
  -l, --count-links     count sizes many times if hard linked
  -m                    like --block-size=1M
  -P, --no-dereference  don't follow any symbolic links (this is the default)
  -S, --separate-dirs   for directories do not include size of subdirectories
  -s, --summarize       display only a total for each argument
  -t, --threshold=SIZE  exclude entries smaller than SIZE if positive,
                       or greater than SIZE if negative
  -X, --exclude-from=FILE  exclude files that match any pattern in FILE
      --exclude=PATTERN    exclude files that match PATTERN
  -x, --one-file-system    skip directories on different file systems
      --help             display this help and exit
      --version          output version information and exit
```

# 基本语法

```sh
du [选项] [文件或目录...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-h, --human-readable` | 人类可读格式 |
| `-s, --summarize` | 只显示总计 |
| `-d, --max-depth=N` | 限制显示深度 |
| `-a, --all` | 显示所有文件 |
| `-c, --total` | 显示总计 |
| `--exclude=PATTERN` | 排除匹配的文件 |
| `-x, --one-file-system` | 不跨越文件系统 |
| `-S, --separate-dirs` | 不包含子目录大小 |

# 基本使用

## 显示目录大小

```sh
# 显示当前目录大小
➜ du

# 人类可读格式
➜ du -h

# 只显示总计
➜ du -sh

# 显示指定目录
➜ du -h /path/to/dir
```

## 限制显示深度

```sh
# 只显示一级目录
➜ du -h --max-depth=1

# 显示两级目录
➜ du -h --max-depth=2
```

## 显示所有文件

```sh
# 显示所有文件（不只是目录）
➜ du -ah

# 显示总计
➜ du -ah --total
```

## 排序和过滤

```sh
# 按大小排序
➜ du -h | sort -h

# 只显示大文件/目录
➜ du -h | sort -h | tail -10

# 排除特定目录
➜ du -h --exclude='node_modules' .
```

# 实际应用场景

## 查找大文件/目录

```sh
# 查找最大的目录
➜ du -h --max-depth=1 | sort -h | tail -10

# 查找大于 100M 的目录
➜ du -h --max-depth=1 | awk '$1 ~ /[0-9]+G/ || ($1 ~ /[0-9]+M/ && $1+0 > 100)'

# 查找所有大文件
➜ find . -type f -exec du -h {} + | sort -h | tail -10
```

## 磁盘清理

```sh
# 检查各目录占用
➜ du -sh /*

# 检查用户目录占用
➜ du -sh /home/*

# 查找可以清理的大目录
➜ du -h --max-depth=2 | sort -h
```

## 监控目录大小

```sh
# 定期检查目录大小
➜ watch -n 5 'du -sh /path/to/dir'

# 在脚本中监控
#!/bin/bash
size=$(du -sh /path/to/dir | awk '{print $1}')
echo "Directory size: $size"
```

## 与其他命令组合

```sh
# 统计总大小
➜ du -ch dir/ | tail -1

# 查找并删除大文件
➜ find . -type f -size +100M -exec du -h {} + | sort -h

# 排除特定目录后统计
➜ du -sh --exclude='node_modules' --exclude='.git' .
```

# 注意事项

1. **计算时间**：对于大目录，du 可能需要一些时间
2. **符号链接**：默认不跟随符号链接，使用 `-L` 跟随
3. **跨文件系统**：默认会跨越文件系统，使用 `-x` 限制
4. **权限**：某些目录可能需要权限才能访问

# 参考文献
* [GNU Coreutils - du](https://www.gnu.org/software/coreutils/manual/html_node/du-invocation.html)

