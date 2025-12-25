---
author: djaigo
title: linux-join命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`join` 是 Linux 中用于基于共同字段连接两个文件的命令，类似于 SQL 的 JOIN 操作。它要求输入文件必须已排序。

```sh
➜ join --help
用法: join [选项]... 文件1 文件2
对于每一对具有相同连接字段的输入行进行合并，写入标准输出。

  -a FILENUM            also print unpairable lines from file FILENUM
  -e EMPTY              replace missing input fields with EMPTY
  -i, --ignore-case     ignore differences in case when comparing fields
  -j FIELD              equivalent to '-1 FIELD -2 FIELD'
  -o FORMAT             obey FORMAT while constructing output line
  -t CHAR               use CHAR as input and output field separator
  -v FILENUM            like -a FILENUM, but suppress joined output lines
  -1 FIELD              join on this FIELD of file 1
  -2 FIELD              join on this FIELD of file 2
      --help            显示此帮助信息并退出
      --version         输出版本信息并退出
```

# 基本语法

```sh
join [选项] 文件1 文件2
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-1 FIELD` | 指定文件1的连接字段 |
| `-2 FIELD` | 指定文件2的连接字段 |
| `-j FIELD` | 同时指定两个文件的连接字段 |
| `-t CHAR` | 指定字段分隔符（默认是空格） |
| `-a FILENUM` | 显示未匹配的行（1或2） |
| `-v FILENUM` | 只显示未匹配的行 |
| `-i, --ignore-case` | 忽略大小写 |
| `-o FORMAT` | 指定输出格式 |

# 基本使用

## 基本连接

```sh
# 基于第一列连接（两个文件必须已排序）
➜ join file1.txt file2.txt

# 示例：
# file1.txt:
# alice 25
# bob 30
# 
# file2.txt:
# alice engineer
# bob manager
# 
# 输出：
# alice 25 engineer
# bob 30 manager
```

## 指定连接字段

```sh
# 文件1的第2列连接文件2的第1列
➜ join -1 2 -2 1 file1.txt file2.txt

# 两个文件都使用第2列连接
➜ join -j 2 file1.txt file2.txt
```

## 指定分隔符

```sh
# 使用冒号作为分隔符
➜ join -t: file1.txt file2.txt

# 使用制表符
➜ join -t$'\t' file1.txt file2.txt
```

## 显示未匹配的行

```sh
# 显示文件1中未匹配的行
➜ join -a 1 file1.txt file2.txt

# 显示文件2中未匹配的行
➜ join -a 2 file1.txt file2.txt

# 显示两个文件中未匹配的行
➜ join -a 1 -a 2 file1.txt file2.txt

# 只显示未匹配的行
➜ join -v 1 file1.txt file2.txt
```

## 指定输出格式

```sh
# 指定输出哪些字段
➜ join -o 1.1,2.2 file1.txt file2.txt
# 输出文件1的第1列和文件2的第2列
```

# 实际应用场景

## 数据关联

```sh
# 关联用户信息和订单信息
➜ join -t: users.txt orders.txt

# users.txt:
# user1:Alice:25
# user2:Bob:30
# 
# orders.txt:
# user1:order1:100
# user2:order2:200
```

## 数据库式操作

```sh
# 内连接（默认）
➜ join file1.txt file2.txt

# 左连接
➜ join -a 1 file1.txt file2.txt

# 右连接
➜ join -a 2 file1.txt file2.txt

# 全外连接
➜ join -a 1 -a 2 file1.txt file2.txt
```

## 与其他命令组合

```sh
# 先排序再连接
➜ sort file1.txt > file1_sorted.txt
➜ sort file2.txt > file2_sorted.txt
➜ join file1_sorted.txt file2_sorted.txt

# 或者使用进程替换
➜ join <(sort file1.txt) <(sort file2.txt)
```

# 注意事项

1. **文件必须排序**：join 要求输入文件必须按连接字段排序
2. **字段分隔符**：默认使用空格，可以用 `-t` 指定
3. **连接字段**：默认使用第一列，可以用 `-1` 和 `-2` 指定
4. **匹配规则**：只有完全匹配的行才会连接

# 参考文献
* [GNU Coreutils - join](https://www.gnu.org/software/coreutils/manual/html_node/join-invocation.html)

