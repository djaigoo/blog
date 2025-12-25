---
author: djaigo
title: linux-tr命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`tr`（translate）是 Linux 中用于字符转换和删除的命令。它从标准输入读取数据，进行字符转换或删除操作，然后输出到标准输出。

```sh
➜ tr --help
用法: tr [选项]... SET1 [SET2]
Translate, squeeze, and/or delete characters from standard input,
writing to standard output.

  -c, -C, --complement    使用SET1的补集
  -d, --delete            删除SET1中的字符，不转换
  -s, --squeeze-repeats   将SET1中重复的字符压缩为一个
  -t, --truncate-set1     先将SET1截断为SET2的长度
      --help              显示此帮助信息并退出
      --version           输出版本信息并退出
```

# 基本语法

```sh
tr [选项] SET1 [SET2]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-d, --delete` | 删除 SET1 中的字符 |
| `-s, --squeeze-repeats` | 压缩 SET1 中重复的字符 |
| `-c, --complement` | 使用 SET1 的补集 |
| `-t, --truncate-set1` | 将 SET1 截断为 SET2 的长度 |

# 基本使用

## 字符转换

```sh
# 小写转大写
➜ echo "hello world" | tr 'a-z' 'A-Z'
HELLO WORLD

# 大写转小写
➜ echo "HELLO WORLD" | tr 'A-Z' 'a-z'
hello world

# 数字转换
➜ echo "12345" | tr '0-9' '9876543210'
87654

# 字符替换
➜ echo "hello" | tr 'el' 'EL'
hELLo
```

## 删除字符

```sh
# 删除数字
➜ echo "abc123def" | tr -d '0-9'
abcdef

# 删除空格
➜ echo "hello world" | tr -d ' '
helloworld

# 删除换行符
➜ tr -d '\n' < file.txt
```

## 压缩字符

```sh
# 压缩连续空格为一个
➜ echo "hello    world" | tr -s ' '
hello world

# 压缩连续换行符
➜ tr -s '\n' < file.txt

# 压缩连续相同字符
➜ echo "aaabbbccc" | tr -s 'abc'
abc
```

## 使用字符类

```sh
# 使用预定义字符类
➜ echo "Hello123" | tr '[:lower:]' '[:upper:]'
HELLO123

➜ echo "Hello123" | tr '[:upper:]' '[:lower:]'
hello123

➜ echo "Hello123" | tr '[:digit:]' 'X'
HelloXXX
```

# 实际应用场景

## 文本格式化

```sh
# 删除文件中的空行
➜ tr -d '\n' < file.txt | tr -s ' '

# 将空格转换为换行
➜ echo "a b c d" | tr ' ' '\n'
a
b
c
d

# 将制表符转换为空格
➜ tr '\t' ' ' < file.txt
```

## 数据处理

```sh
# 删除文件中的特殊字符
➜ tr -d '!@#$%^&*' < file.txt

# 只保留字母和数字
➜ echo "Hello123!@#" | tr -d -c '[:alnum:]'
Hello123

# 将多个空格转换为单个空格
➜ tr -s ' ' < file.txt
```

## 与其他命令组合

```sh
# 统计单词数（将空格转换为换行后统计行数）
➜ echo "hello world test" | tr ' ' '\n' | wc -l

# 提取数字
➜ echo "abc123def456" | tr -d -c '[:digit:]'
123456

# 提取字母
➜ echo "abc123def456" | tr -d -c '[:alpha:]'
abcdef
```

# 注意事项

1. **SET1 和 SET2**：如果 SET2 比 SET1 短，SET2 会重复最后一个字符
2. **字符类**：可以使用 `[:alnum:]`、`[:alpha:]`、`[:digit:]` 等字符类
3. **转义字符**：特殊字符需要转义，如 `\n`、`\t` 等
4. **性能**：tr 处理速度很快，适合处理大量数据

# 参考文献
* [GNU Coreutils - tr](https://www.gnu.org/software/coreutils/manual/html_node/tr-invocation.html)

