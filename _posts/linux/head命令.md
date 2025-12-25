---
author: djaigo
title: linux-head和tail命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`head` 和 `tail` 是 Linux 中用于查看文件开头和结尾的命令。`head` 显示文件的前几行，`tail` 显示文件的后几行，常用于查看日志文件。

```sh
➜ head --help
用法: head [选项]... [文件]...
将每个指定文件的头10 行打印到标准输出。
如果指定了多于一个文件，在每一段输出前会输出文件名作为头。
如果指定文件为"-"或没有指定文件，则从标准输入读取。

  -c, --bytes=[-]K         显示前K字节；如果K前有"-"，则显示除最后K字节外的所有内容
  -n, --lines=[-]K         显示前K行；如果K前有"-"，则显示除最后K行外的所有内容
  -q, --quiet, --silent    不显示文件名
  -v, --verbose            总是显示文件名
      --help               显示此帮助信息并退出
      --version            输出版本信息并退出
```

# head 命令

## 基本语法

```sh
head [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-n, --lines=K` | 显示前 K 行（默认 10 行） |
| `-c, --bytes=K` | 显示前 K 字节 |
| `-q, --quiet` | 不显示文件名 |
| `-v, --verbose` | 总是显示文件名 |

## 基本使用

```sh
# 显示前10行（默认）
➜ head file.txt

# 显示前20行
➜ head -n 20 file.txt
# 或
➜ head -20 file.txt

# 显示前100个字符
➜ head -c 100 file.txt

# 显示除最后10行外的所有内容
➜ head -n -10 file.txt

# 显示多个文件
➜ head file1.txt file2.txt
```

# tail 命令

## 基本语法

```sh
tail [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-n, --lines=K` | 显示后 K 行（默认 10 行） |
| `-c, --bytes=K` | 显示后 K 字节 |
| `-f, --follow` | 实时跟踪文件（常用于日志） |
| `-F, --follow=name --retry` | 跟踪文件（文件被删除重建后继续跟踪） |
| `-q, --quiet` | 不显示文件名 |
| `-v, --verbose` | 总是显示文件名 |

## 基本使用

```sh
# 显示后10行（默认）
➜ tail file.txt

# 显示后20行
➜ tail -n 20 file.txt
# 或
➜ tail -20 file.txt

# 显示后100个字符
➜ tail -c 100 file.txt

# 显示除前10行外的所有内容
➜ tail -n +10 file.txt

# 实时跟踪文件（最常用）
➜ tail -f log.txt

# 跟踪文件（文件被删除重建后继续跟踪）
➜ tail -F log.txt
```

## 实时跟踪日志

```sh
# 实时查看日志文件
➜ tail -f /var/log/nginx/access.log

# 跟踪多个文件
➜ tail -f log1.txt log2.txt

# 跟踪并显示行号
➜ tail -f -n 100 log.txt

# 跟踪并高亮显示
➜ tail -f log.txt | grep --color=always "ERROR"
```

# 实际应用场景

## 查看文件头尾

```sh
# 查看配置文件的前几行
➜ head -n 20 /etc/nginx/nginx.conf

# 查看日志文件的最后几行
➜ tail -n 50 /var/log/syslog
```

## 日志监控

```sh
# 实时监控错误日志
➜ tail -f /var/log/nginx/error.log

# 监控多个日志文件
➜ tail -f /var/log/app/*.log

# 监控并过滤
➜ tail -f access.log | grep "404"
```

## 查看特定范围

```sh
# 查看第10-20行（使用head和tail组合）
➜ head -n 20 file.txt | tail -n 11

# 或使用sed
➜ sed -n '10,20p' file.txt
```

## 与其他命令组合

```sh
# 查看最新的错误日志
➜ tail -n 100 log.txt | grep "ERROR"

# 统计最后100行的错误数
➜ tail -n 100 log.txt | grep -c "ERROR"

# 查看最新的访问IP
➜ tail -n 1000 access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

# 注意事项

1. **实时跟踪**：`tail -f` 会持续监控文件，按 `Ctrl+C` 退出
2. **文件重建**：使用 `-F` 选项可以在文件被删除重建后继续跟踪
3. **性能**：对于大文件，`tail` 比 `head` 更高效（从文件末尾读取）
4. **多文件**：可以同时查看多个文件，每个文件会显示文件名

# 参考文献
* [GNU Coreutils - head](https://www.gnu.org/software/coreutils/manual/html_node/head-invocation.html)
* [GNU Coreutils - tail](https://www.gnu.org/software/coreutils/manual/html_node/tail-invocation.html)

