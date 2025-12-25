---
author: djaigo
title: linux-cat、less和more命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`cat`、`less` 和 `more` 是 Linux 中用于查看文件内容的命令。`cat` 显示整个文件，`less` 和 `more` 提供分页查看功能。

# cat 命令

`cat`（concatenate）用于显示文件内容或连接多个文件。

```sh
➜ cat --help
用法: cat [选项]... [文件]...
将[文件]或标准输入组合输出到标准输出。

  -A, --show-all           等于-vET
  -b, --number-nonblank    对非空输出行编号
  -e                       等于-vE
  -E, --show-ends          在每行结束处显示"$"
  -n, --number             对输出的所有行编号
  -s, --squeeze-blank      不输出多行空行
  -t                       等于-vT
  -T, --show-tabs          将跳格字符显示为^I
  -u                        (被忽略)
  -v, --show-nonprinting   使用^ 和M- 记号，除了LFD和 TAB 之外
      --help               显示此帮助信息并退出
      --version            输出版本信息并退出
```

## 基本语法

```sh
cat [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-n, --number` | 显示行号 |
| `-b, --number-nonblank` | 只对非空行显示行号 |
| `-A, --show-all` | 显示所有字符（包括控制字符） |
| `-E, --show-ends` | 在每行末尾显示 $ |
| `-T, --show-tabs` | 将制表符显示为 ^I |
| `-s, --squeeze-blank` | 压缩连续空行为一行 |

## 基本使用

```sh
# 显示文件内容
➜ cat file.txt

# 显示多个文件
➜ cat file1.txt file2.txt

# 显示行号
➜ cat -n file.txt

# 只对非空行显示行号
➜ cat -b file.txt

# 显示所有字符（包括控制字符）
➜ cat -A file.txt

# 从标准输入读取
➜ cat
hello
world
# 按 Ctrl+D 结束输入

# 创建文件
➜ cat > newfile.txt
content
# 按 Ctrl+D 保存

# 追加内容
➜ cat >> file.txt
new content
# 按 Ctrl+D 保存
```

## 实际应用

```sh
# 查看配置文件
➜ cat /etc/nginx/nginx.conf

# 连接多个文件
➜ cat file1.txt file2.txt > combined.txt

# 显示文件并添加行号
➜ cat -n script.sh

# 查看二进制文件（不推荐，可能乱码）
➜ cat binary_file
```

# less 命令

`less` 是一个强大的分页查看器，支持向前和向后浏览文件。

## 基本语法

```sh
less [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-N` | 显示行号 |
| `-S` | 不换行显示（截断长行） |
| `-i` | 搜索时忽略大小写 |
| `-F` | 如果文件可以在一屏显示完，自动退出 |
| `-X` | 退出时不清除屏幕 |
| `-R` | 显示原始控制字符 |

## 基本使用

```sh
# 查看文件
➜ less file.txt

# 显示行号
➜ less -N file.txt

# 查看多个文件
➜ less file1.txt file2.txt
# 在less中：:n 下一个文件，:p 上一个文件
```

## less 中的操作

| 按键 | 说明 |
|------|------|
| `空格` 或 `f` | 向下翻一页 |
| `b` | 向上翻一页 |
| `回车` 或 `j` | 向下移动一行 |
| `k` | 向上移动一行 |
| `g` | 跳到文件开头 |
| `G` | 跳到文件末尾 |
| `/pattern` | 向前搜索 |
| `?pattern` | 向后搜索 |
| `n` | 下一个匹配 |
| `N` | 上一个匹配 |
| `q` | 退出 |
| `h` | 显示帮助 |

## 实际应用

```sh
# 查看大文件
➜ less large_file.txt

# 查看日志文件
➜ less /var/log/syslog

# 查看并搜索
➜ less file.txt
# 在less中输入 /ERROR 搜索

# 查看压缩文件
➜ less file.txt.gz
```

# more 命令

`more` 是一个简单的分页查看器，只能向前浏览。

## 基本语法

```sh
more [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-d` | 显示提示信息 |
| `-f` | 不折叠长行 |
| `-l` | 不暂停在换页符 |
| `-p` | 先清屏再显示 |
| `-s` | 压缩连续空行 |
| `-u` | 不显示下划线 |

## 基本使用

```sh
# 查看文件
➜ more file.txt

# 显示提示信息
➜ more -d file.txt
```

## more 中的操作

| 按键 | 说明 |
|------|------|
| `空格` | 向下翻一页 |
| `回车` | 向下移动一行 |
| `q` | 退出 |
| `/pattern` | 搜索 |
| `=` | 显示当前行号 |

## 实际应用

```sh
# 查看文件（简单场景）
➜ more file.txt

# 查看命令输出
➜ ls -l | more
```

# 命令对比

| 特性 | cat | less | more |
|------|-----|------|------|
| 分页 | 否 | 是 | 是 |
| 向前浏览 | 否 | 是 | 否 |
| 向后浏览 | 否 | 是 | 否 |
| 搜索 | 否 | 是 | 是（有限） |
| 大文件 | 不适合 | 适合 | 适合 |
| 速度 | 快 | 中等 | 中等 |

# 实际应用场景

## 查看配置文件

```sh
# 使用 cat 查看小文件
➜ cat ~/.bashrc

# 使用 less 查看大文件
➜ less /etc/nginx/nginx.conf
```

## 查看日志

```sh
# 实时查看日志（使用 tail）
➜ tail -f log.txt

# 查看历史日志（使用 less）
➜ less log.txt
```

## 文件内容处理

```sh
# 连接文件
➜ cat file1.txt file2.txt > combined.txt

# 添加行号后查看
➜ cat -n file.txt | less

# 搜索并查看
➜ grep "pattern" file.txt | less
```

# 注意事项

1. **cat 适合小文件**：对于大文件，使用 less 或 more
2. **less 更强大**：推荐使用 less 而不是 more
3. **二进制文件**：不要用这些命令查看二进制文件
4. **性能**：对于超大文件，less 比 cat 更高效

# 参考文献
* [GNU Coreutils - cat](https://www.gnu.org/software/coreutils/manual/html_node/cat-invocation.html)
* [less 手册](https://www.gnu.org/software/less/manual/less.html)

