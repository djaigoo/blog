---
author: djaigo
title: linux-uniq命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`uniq` 是 Linux 中用于去除相邻重复行的命令。它通常与 `sort` 命令配合使用，因为 `uniq` 只能去除相邻的重复行。

```sh
➜ uniq --help
用法: uniq [选项]... [输入文件 [输出文件]]
从输入文件（或标准输入）中过滤相邻的匹配行，写入输出文件（或标准输出）。

不附加任何选项时，将去除相邻的重复行。

  -c, --count           在每行前显示该行重复出现的次数
  -d, --repeated        只输出重复的行
  -D, --all-repeated    输出所有重复的行
  -f, --skip-fields=N   忽略前N个字段
  -i, --ignore-case     忽略大小写
  -s, --skip-chars=N    忽略前N个字符
  -u, --unique          只输出不重复的行
  -w, --check-chars=N   只比较每行的前N个字符
  -z, --zero-terminated  行终止符为NUL而不是换行符
      --help            显示此帮助信息并退出
      --version         输出版本信息并退出
```

# 基本语法

```sh
uniq [选项] [输入文件] [输出文件]
```

如果不指定文件，从标准输入读取，输出到标准输出。

# 常用选项

| 选项 | 说明 |
|------|------|
| `-c, --count` | 在每行前显示重复次数 |
| `-d, --repeated` | 只显示重复的行 |
| `-D, --all-repeated` | 显示所有重复的行 |
| `-u, --unique` | 只显示不重复的行 |
| `-i, --ignore-case` | 忽略大小写 |
| `-f, --skip-fields=N` | 忽略前 N 个字段 |
| `-s, --skip-chars=N` | 忽略前 N 个字符 |
| `-w, --check-chars=N` | 只比较前 N 个字符 |
| `-z, --zero-terminated` | 使用 NUL 作为行终止符 |

# 基本使用

## 去除重复行

```sh
# 去除相邻的重复行
➜ uniq file.txt

# 注意：uniq 只能去除相邻的重复行
# 如果重复行不相邻，需要先排序
➜ sort file.txt | uniq
```

## 统计重复次数

```sh
# 显示每行重复的次数
➜ uniq -c file.txt
      3 apple
      2 banana
      1 cherry
```

## 只显示重复的行

```sh
# 只显示重复的行（至少出现2次）
➜ uniq -d file.txt

# 显示所有重复的行（包括第一次出现）
➜ uniq -D file.txt
```

## 只显示不重复的行

```sh
# 只显示不重复的行（只出现一次）
➜ uniq -u file.txt
```

## 忽略大小写

```sh
# 忽略大小写比较
➜ uniq -i file.txt
```

# 实际应用场景

## 统计词频

```sh
# 统计文件中每个单词出现的次数
➜ cat file.txt | tr ' ' '\n' | sort | uniq -c | sort -rn

# 统计访问日志中的IP出现次数
➜ awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

## 查找重复内容

```sh
# 查找重复的行
➜ sort file.txt | uniq -d

# 查找重复的文件名
➜ ls | sort | uniq -d
```

## 去重处理

```sh
# 去除重复的行（保留一个）
➜ sort file.txt | uniq > unique.txt

# 去除重复的IP地址
➜ awk '{print $1}' access.log | sort -u
```

## 与其他命令组合

```sh
# 统计错误日志中的错误类型
➜ grep "ERROR" log.txt | awk '{print $5}' | sort | uniq -c

# 查找重复的进程
➜ ps aux | awk '{print $11}' | sort | uniq -d

# 统计不同用户的数量
➜ cut -d: -f1 /etc/passwd | sort | uniq | wc -l
```

## 忽略字段比较

```sh
# 忽略前2个字段后比较
➜ uniq -f 2 file.txt

# 忽略前10个字符后比较
➜ uniq -s 10 file.txt

# 只比较前5个字符
➜ uniq -w 5 file.txt
```

# 注意事项

1. **相邻重复**：uniq 只能去除相邻的重复行，不相邻的重复行需要先排序
2. **排序配合**：通常与 sort 命令配合使用：`sort file.txt | uniq`
3. **字段分隔**：默认使用空格和制表符作为字段分隔符
4. **性能**：对于大文件，先排序再去重可能较慢

# 参考文献
* [GNU Coreutils - uniq](https://www.gnu.org/software/coreutils/manual/html_node/uniq-invocation.html)

