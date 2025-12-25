---
author: djaigo
title: linux-paste命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`paste` 是 Linux 中用于按列合并文件的命令。它可以将多个文件的内容按列合并在一起，类似于表格的列合并。

```sh
➜ paste --help
用法: paste [选项]... [文件]...
Write lines consisting of the sequentially corresponding lines from
each FILE, separated by TABs, to standard output.

  -d, --delimiters=LIST    reuse characters from LIST instead of TABs
  -s, --serial            paste one file at a time instead of in parallel
      --help              显示此帮助信息并退出
      --version           输出版本信息并退出
```

# 基本语法

```sh
paste [选项] [文件...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-d, --delimiters=LIST` | 指定分隔符（默认是 TAB） |
| `-s, --serial` | 串行合并（一个文件接一个文件） |

# 基本使用

## 按列合并文件

```sh
# 基本合并（使用 TAB 分隔）
➜ paste file1.txt file2.txt
col1_from_file1    col1_from_file2
col2_from_file1    col2_from_file2

# 合并三个文件
➜ paste file1.txt file2.txt file3.txt
```

## 指定分隔符

```sh
# 使用冒号分隔
➜ paste -d: file1.txt file2.txt
col1_from_file1:col1_from_file2
col2_from_file1:col2_from_file2

# 使用逗号分隔
➜ paste -d, file1.txt file2.txt

# 使用多个分隔符（循环使用）
➜ paste -d':;' file1.txt file2.txt file3.txt
```

## 串行合并

```sh
# 串行合并（将文件内容合并为一行）
➜ paste -s file1.txt
col1_from_file1    col2_from_file1    col3_from_file1

# 串行合并多个文件
➜ paste -s file1.txt file2.txt
```

## 从标准输入

```sh
# 从标准输入读取
➜ echo -e "a\nb\nc" | paste - file2.txt
```

# 实际应用场景

## 合并数据文件

```sh
# 合并两列数据
➜ paste names.txt ages.txt
Alice    25
Bob      30
Charlie  35

# 创建 CSV 格式
➜ paste -d, names.txt ages.txt > data.csv
```

## 创建表格

```sh
# 创建简单的表格
➜ paste -d'|' header.txt data1.txt data2.txt
```

## 与其他命令组合

```sh
# 将命令输出合并
➜ paste <(seq 1 5) <(seq 10 14)
1    10
2    11
3    12
4    13
5    14

# 合并多个命令的输出
➜ paste <(ls) <(ls -l | awk '{print $5}')
```

# 注意事项

1. **文件行数不同**：如果文件行数不同，较短的文件会用空行补齐
2. **分隔符**：默认使用 TAB，可以用 `-d` 指定其他分隔符
3. **串行模式**：`-s` 选项会将每个文件的内容合并为一行

# 参考文献
* [GNU Coreutils - paste](https://www.gnu.org/software/coreutils/manual/html_node/paste-invocation.html)

