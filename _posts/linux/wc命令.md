---
author: djaigo
title: linux-wc命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`wc`（word count）是 Linux 中用于统计文件的行数、单词数和字符数的命令。它是文本处理中常用的统计工具。

```sh
➜ wc --help
用法: wc [选项]... [文件]...
 或: wc [选项]... --files0-from=F
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  With no FILE, or when FILE is -, read
standard input.

  -c, --bytes            print the byte counts
  -m, --chars            print the character counts
  -l, --lines            print the newline counts
  -w, --words            print the word counts
      --files0-from=F    read input from the files specified by
                           NUL-terminated names in file F;
                           If F is - then read names from standard input
      --help             display this help and exit
      --version          output version information and exit
```

# 基本语法

```sh
wc [选项] [文件...]
```

如果不指定文件，wc 会从标准输入读取数据。

# 常用选项

| 选项 | 说明 |
|------|------|
| `-l, --lines` | 统计行数 |
| `-w, --words` | 统计单词数 |
| `-c, --bytes` | 统计字节数 |
| `-m, --chars` | 统计字符数（多字节字符） |
| `--files0-from=F` | 从文件 F 中读取文件列表（NUL 分隔） |

# 基本使用

## 统计文件

```sh
# 统计文件的行数、单词数、字节数
➜ wc file.txt
  10   50  300 file.txt
# 输出格式：行数 单词数 字节数 文件名
```

## 只统计行数

```sh
# 统计文件行数
➜ wc -l file.txt
10 file.txt

# 统计多个文件的行数
➜ wc -l file1.txt file2.txt
  10 file1.txt
  20 file2.txt
  30 total
```

## 只统计单词数

```sh
# 统计文件单词数
➜ wc -w file.txt
50 file.txt
```

## 只统计字节数

```sh
# 统计文件字节数
➜ wc -c file.txt
300 file.txt
```

## 只统计字符数

```sh
# 统计文件字符数（支持多字节字符）
➜ wc -m file.txt
300 file.txt
```

## 从标准输入读取

```sh
# 从标准输入读取
➜ echo "hello world" | wc
       1       2      12

# 统计管道输出
➜ cat file.txt | wc -l
10
```

# 实际应用场景

## 统计代码行数

```sh
# 统计所有 .c 文件的总行数
➜ find . -name "*.c" | xargs wc -l

# 统计所有 .py 文件的总行数
➜ find . -name "*.py" -exec wc -l {} + | tail -1

# 统计项目总代码行数
➜ find . -name "*.py" -o -name "*.js" | xargs wc -l | tail -1
```

## 统计日志文件

```sh
# 统计日志文件行数
➜ wc -l access.log
1000000 access.log

# 统计多个日志文件
➜ wc -l *.log
```

## 统计文本内容

```sh
# 统计文档字数
➜ wc -w document.txt

# 统计文件大小
➜ wc -c file.txt
```

## 与其他命令组合

```sh
# 统计匹配的行数
➜ grep "ERROR" log.txt | wc -l

# 统计不重复的行数
➜ sort file.txt | uniq | wc -l

# 统计目录下文件数量
➜ ls -1 | wc -l
```

# 注意事项

1. **行数统计**：`-l` 统计的是换行符的数量，不是实际行数
2. **单词定义**：单词是由空格、制表符或换行符分隔的字符串
3. **字节 vs 字符**：`-c` 统计字节数，`-m` 统计字符数（对多字节字符有区别）
4. **多个文件**：统计多个文件时会显示总计

# 参考文献
* [GNU Coreutils - wc](https://www.gnu.org/software/coreutils/manual/html_node/wc-invocation.html)

