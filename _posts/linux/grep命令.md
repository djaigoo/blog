---
author: djaigo
title: linux-grep命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
date: 2021-01-27 11:29:11
---

grep（Global Regular Expression Print）是Linux中一个强大的文本搜索工具，它可以在一个或多个文件中搜索匹配指定模式的行，并将匹配的行打印出来。grep支持基本正则表达式（BRE）和扩展正则表达式（ERE），是Linux系统中最常用的文本处理工具之一。

```sh
➜ grep --help
用法: grep [选项]... PATTERN [FILE]...
在每个 FILE 或是标准输入中查找 PATTERN。
默认的 PATTERN 是一个基本正则表达式 (BRE)。
例如: grep -i 'hello world' menu.h main.c

正则表达式选择与解释:
  -E, --extended-regexp     PATTERN 是一个可扩展的正则表达式(ERE)
  -F, --fixed-strings       PATTERN 是一组由断行符分隔的固定字符串
  -G, --basic-regexp        PATTERN 是一个基本正则表达式(BRE)(默认)
  -P, --perl-regexp         PATTERN 是一个 Perl 正则表达式
  -e, --regexp=PATTERN      用 PATTERN 来进行匹配操作
  -f, --file=FILE           从 FILE 中取得 PATTERN
  -i, --ignore-case         忽略大小写
  -w, --word-regexp         强制 PATTERN 仅完全匹配字词
  -x, --line-regexp         强制 PATTERN 仅完全匹配一行
  -z, --null-data           一个 0 字节的数据行，但不是空行

杂项:
  -s, --no-messages         抑制错误消息
  -v, --invert-match        选中不匹配的行
  -V, --version             显示版本信息并退出
      --help                显示此帮助信息并退出

输出控制:
  -m, --max-count=NUM       NUM 次匹配后停止
  -b, --byte-offset         输出的同时打印字节偏移
  -n, --line-number         在输出的每一行前加上其所在文件中对应的行号
      --line-buffered       每行输出后刷新输出缓冲区
  -H, --with-filename       为每一匹配项打印文件名
  -h, --no-filename         输出时不显示文件名前缀
      --label=LABEL         将 LABEL 作为标准输入文件名前缀
  -o, --only-matching       只显示匹配 PATTERN 的部分
  -q, --quiet, --silent     不显示所有输出
      --binary-files=TYPE   设定二进制文件的 TYPE 类型:
                            TYPE 可以是 'binary', 'text', 或 'without-match'
  -a, --text                等同于 --binary-files=text
  -I                        等同于 --binary-files=without-match
  -d, --directories=ACTION  读取目录的方式;
                            ACTION 可以是 'read', 'recurse', 或 'skip'
  -D, --devices=ACTION      读取设备、先入先出队列、套接字的方式;
                            ACTION 可以是 'read' 或 'skip'
  -r, --recursive           等同于 --directories=recurse
  -R, --dereference-recursive
                            等同于 --directories=recurse --follow-symlinks
      --include=FILE_PATTERN
                            只查找匹配 FILE_PATTERN 的文件
      --exclude=FILE_PATTERN
                            跳过匹配 FILE_PATTERN 的文件和目录
      --exclude-from=FILE   跳过所有匹配给定文件内容中任意模式的文件
      --exclude-dir=PATTERN 跳过所有匹配 PATTERN 的目录
      --include-dir=PATTERN 只查找匹配 PATTERN 的目录
  -L, --files-without-match 只打印不匹配 FILE 的名称
  -l, --files-with-matches  只打印匹配 FILE 的名称
  -c, --count               只打印每个 FILE 中的匹配行数
  -T, --initial-tab         使标签对齐(如果需要)
  -Z, --null                在 FILE 名后输出一个 0 字节

上下文控制:
  -B, --before-context=NUM  打印文本及其前面 NUM 行
  -A, --after-context=NUM   打印文本及其后面 NUM 行
  -C, --context=NUM         打印匹配行及其前后各 NUM 行
  -NUM                      等同于 -C NUM
      --color[=WHEN],
      --colour[=WHEN]       使用标记高亮匹配字串;
                            WHEN 可以是 'always', 'never' 或 'auto'
  -U, --binary              不要清除行尾的 CR 字符(MSDOS/Windows)
      --mmap                如果可能，忽略向后兼容性

当 FILE 是 '-' 时，读取标准输入。没有 FILE，读取 '.' 目录，除非指定了 -r 选项。
如果少于两个 FILE，假设使用 -h。如果有任意行被匹配，则退出状态为 0，
否则为 1；如果有错误产生，且未指定 -q，则退出状态为 2。
```

# 基本语法

grep的基本语法格式为：
```sh
grep [选项] PATTERN [FILE...]
```

其中：
- `PATTERN`：要搜索的模式（可以是字符串或正则表达式）
- `FILE`：要搜索的文件（可以是一个或多个文件，如果不指定则从标准输入读取）

# 常用选项

## 正则表达式选择

| 选项 | 说明 |
|------|------|
| `-E, --extended-regexp` | 使用扩展正则表达式（ERE） |
| `-F, --fixed-strings` | 将PATTERN视为固定字符串，不使用正则表达式 |
| `-G, --basic-regexp` | 使用基本正则表达式（BRE），这是默认选项 |
| `-P, --perl-regexp` | 使用Perl正则表达式 |
| `-e, --regexp=PATTERN` | 指定匹配模式，可以多次使用来指定多个模式 |
| `-f, --file=FILE` | 从文件中读取模式，每行一个模式 |

## 匹配控制

| 选项 | 说明 |
|------|------|
| `-i, --ignore-case` | 忽略大小写 |
| `-v, --invert-match` | 反向匹配，显示不匹配的行 |
| `-w, --word-regexp` | 只匹配完整的单词 |
| `-x, --line-regexp` | 只匹配整行 |
| `-m, --max-count=NUM` | 最多匹配NUM行后停止 |

## 输出控制

| 选项 | 说明 |
|------|------|
| `-n, --line-number` | 显示匹配行的行号 |
| `-H, --with-filename` | 显示文件名（当搜索多个文件时默认启用） |
| `-h, --no-filename` | 不显示文件名 |
| `-o, --only-matching` | 只显示匹配的部分，而不是整行 |
| `-c, --count` | 只显示匹配的行数，而不是匹配的行 |
| `-l, --files-with-matches` | 只显示包含匹配的文件名 |
| `-L, --files-without-match` | 只显示不包含匹配的文件名 |
| `-q, --quiet, --silent` | 静默模式，不输出任何内容，只返回退出状态码 |

## 上下文控制

| 选项 | 说明 |
|------|------|
| `-A, --after-context=NUM` | 显示匹配行及其后NUM行 |
| `-B, --before-context=NUM` | 显示匹配行及其前NUM行 |
| `-C, --context=NUM` | 显示匹配行及其前后各NUM行 |
| `-NUM` | 等同于 `-C NUM` |

## 目录搜索

| 选项 | 说明 |
|------|------|
| `-r, --recursive` | 递归搜索目录 |
| `-R, --dereference-recursive` | 递归搜索目录，并跟随符号链接 |
| `--include=FILE_PATTERN` | 只搜索匹配FILE_PATTERN的文件 |
| `--exclude=FILE_PATTERN` | 跳过匹配FILE_PATTERN的文件 |
| `--exclude-dir=PATTERN` | 跳过匹配PATTERN的目录 |

# 基本使用示例

## 简单文本搜索

```sh
# 在文件中搜索包含"error"的行
➜ grep "error" log.txt

# 搜索多个文件
➜ grep "error" log1.txt log2.txt log3.txt

# 忽略大小写搜索
➜ grep -i "error" log.txt

# 显示行号
➜ grep -n "error" log.txt
```

## 反向匹配

```sh
# 显示不包含"error"的行
➜ grep -v "error" log.txt

# 显示不包含"error"和"warning"的行
➜ grep -v -e "error" -e "warning" log.txt
```

## 单词匹配

```sh
# 只匹配完整的单词"test"，不会匹配"testing"或"contest"
➜ grep -w "test" file.txt
```

## 行匹配

```sh
# 只匹配整行都是"test"的行
➜ grep -x "test" file.txt
```

## 只显示匹配部分

```sh
# 只显示匹配的IP地址部分
➜ echo "IP: 192.168.1.1" | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
192.168.1.1
```

## 统计匹配行数

```sh
# 统计包含"error"的行数
➜ grep -c "error" log.txt
```

## 显示文件名

```sh
# 在多个文件中搜索，显示文件名
➜ grep -H "error" *.log

# 只显示包含匹配的文件名
➜ grep -l "error" *.log

# 只显示不包含匹配的文件名
➜ grep -L "error" *.log
```

# 正则表达式

grep支持基本正则表达式（BRE）和扩展正则表达式（ERE）。使用`-E`选项启用扩展正则表达式。

## 基本正则表达式（BRE）

| 符号 | 说明 |
|------|------|
| `.` | 匹配任意单个字符 |
| `*` | 匹配前一个字符0次或多次 |
| `^` | 匹配行首 |
| `$` | 匹配行尾 |
| `[]` | 匹配字符集中的任意一个字符 |
| `[^]` | 匹配不在字符集中的任意一个字符 |
| `\(\)` | 分组，保存匹配的内容 |
| `\{n\}` | 匹配前一个字符n次 |
| `\{n,\}` | 匹配前一个字符至少n次 |
| `\{n,m\}` | 匹配前一个字符n到m次 |

示例：
```sh
# 匹配以"test"开头的行
➜ grep "^test" file.txt

# 匹配以"test"结尾的行
➜ grep "test$" file.txt

# 匹配包含"test"或"Test"的行
➜ grep "[Tt]est" file.txt

# 匹配包含数字的行
➜ grep "[0-9]" file.txt

# 匹配包含3个连续数字的行
➜ grep "[0-9]\{3\}" file.txt
```

## 扩展正则表达式（ERE）

使用`-E`选项启用扩展正则表达式，语法更接近现代正则表达式：

| 符号 | 说明 |
|------|------|
| `+` | 匹配前一个字符1次或多次 |
| `?` | 匹配前一个字符0次或1次 |
| `\|` | 或运算符 |
| `()` | 分组（不需要转义） |
| `{}` | 量词（不需要转义） |

示例：
```sh
# 匹配"test"或"Test"
➜ grep -E "(T|t)est" file.txt

# 匹配一个或多个数字
➜ grep -E "[0-9]+" file.txt

# 匹配"color"或"colour"
➜ grep -E "colou?r" file.txt

# 匹配IP地址
➜ grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" file.txt
```

# 上下文显示

## 显示匹配行的上下文

```sh
# 显示匹配行及其后3行
➜ grep -A 3 "error" log.txt

# 显示匹配行及其前3行
➜ grep -B 3 "error" log.txt

# 显示匹配行及其前后各3行
➜ grep -C 3 "error" log.txt
# 或者
➜ grep -3 "error" log.txt
```

示例输出：
```sh
➜ grep -C 2 "error" log.txt
line 10: some info
line 11: some info
line 12: error occurred
line 13: some info
line 14: some info
```

# 递归搜索

## 在目录中递归搜索

```sh
# 在当前目录及子目录中搜索
➜ grep -r "error" .

# 递归搜索并显示行号
➜ grep -rn "error" .

# 递归搜索并跟随符号链接
➜ grep -R "error" .
```

## 排除特定文件或目录

```sh
# 排除特定文件类型
➜ grep -r --exclude="*.log" "error" .

# 排除多个文件类型
➜ grep -r --exclude="*.log" --exclude="*.tmp" "error" .

# 排除特定目录
➜ grep -r --exclude-dir=".git" "error" .

# 只搜索特定文件类型
➜ grep -r --include="*.txt" "error" .
```

# 高级用法

## 多个模式匹配

```sh
# 使用-e选项指定多个模式（或关系）
➜ grep -e "error" -e "warning" log.txt

# 使用扩展正则表达式的或运算符
➜ grep -E "error|warning" log.txt
```

## 从文件读取模式

```sh
# 从文件patterns.txt中读取多个模式
➜ grep -f patterns.txt log.txt
```

patterns.txt内容示例：
```
error
warning
critical
```

## 限制匹配次数

```sh
# 每个文件最多显示5个匹配
➜ grep -m 5 "error" *.log
```

## 彩色输出

```sh
# 启用彩色输出（默认auto，在终端中自动启用）
➜ grep --color=always "error" log.txt

# 禁用彩色输出
➜ grep --color=never "error" log.txt
```

## 处理二进制文件

```sh
# 将二进制文件当作文本处理
➜ grep -a "pattern" binary_file

# 跳过二进制文件
➜ grep -I "pattern" *
```

## 管道组合

grep经常与其他命令组合使用：

```sh
# 查找进程
➜ ps aux | grep "nginx"

# 查找并统计
➜ ps aux | grep "nginx" | grep -v "grep" | wc -l

# 查找并排序
➜ grep "error" log.txt | sort | uniq

# 查找并提取
➜ ifconfig | grep -oE "inet [0-9.]+" | grep -oE "[0-9.]+"
```

# 实际应用场景

## 日志分析

```sh
# 查找错误日志
➜ grep -i "error" /var/log/app.log

# 查找特定时间段的日志
➜ grep "2024-01-27" /var/log/app.log | grep "error"

# 统计错误数量
➜ grep -c "error" /var/log/app.log

# 查找错误并显示上下文
➜ grep -C 5 "error" /var/log/app.log
```

## 代码搜索

```sh
# 在代码中查找函数定义
➜ grep -r "function_name" src/

# 查找TODO注释
➜ grep -rn "TODO" src/

# 查找包含特定头文件的代码
➜ grep -r "#include.*stdio.h" src/
```

## 配置文件查找

```sh
# 查找配置文件中的配置项
➜ grep -E "^[^#]*key" config.conf

# 查找非注释行
➜ grep -v "^#" config.conf | grep -v "^$"
```

## 系统管理

```sh
# 查找特定用户的所有进程
➜ ps aux | grep "^username"

# 查找监听特定端口的进程
➜ netstat -tuln | grep ":80 "

# 查找特定文件的所有引用
➜ grep -r "filename" /path/to/search
```

# 常见问题与技巧

## 排除grep自身

当使用`ps`等命令时，grep会匹配到自己：

```sh
# 错误的方式（会包含grep进程）
➜ ps aux | grep "nginx"

# 正确的方式（排除grep）
➜ ps aux | grep "nginx" | grep -v "grep"

# 或者使用正则表达式
➜ ps aux | grep "[n]ginx"
```

## 处理特殊字符

当搜索包含特殊正则表达式字符的字符串时，需要使用`-F`选项或转义：

```sh
# 搜索包含点号的字符串
➜ grep -F "192.168.1.1" file.txt

# 或者转义
➜ grep "192\.168\.1\.1" file.txt
```

## 性能优化

```sh
# 使用固定字符串搜索（比正则表达式快）
➜ grep -F "pattern" large_file.txt

# 限制搜索深度
➜ grep -r --max-depth=2 "pattern" .

# 只搜索文本文件
➜ grep -r --include="*.txt" "pattern" .
```

# 与其他工具的组合

## grep + awk

```sh
# 查找并提取特定列
➜ grep "error" log.txt | awk '{print $1, $3}'
```

## grep + sed

```sh
# 查找并替换
➜ grep "error" log.txt | sed 's/error/ERROR/g'
```

## grep + xargs

```sh
# 查找文件并对每个文件执行命令
➜ grep -l "pattern" *.txt | xargs rm
```

# 参考文献
* [GNU Grep Manual](https://www.gnu.org/software/grep/manual/)
* [菜鸟教程 - Linux grep 命令](https://www.runoob.com/linux/linux-comm-grep.html)
* [Linux grep命令详解](https://www.cnblogs.com/ggjucheng/archive/2013/01/13/2856896.html)
