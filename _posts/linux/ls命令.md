---
author: djaigo
title: linux-ls命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`ls`（list）是 Linux 中最常用的命令之一，用于列出目录内容。它是日常文件操作的基础命令。

```sh
➜ ls --help
用法: ls [选项]... [文件]...
List information about the FILEs (the current directory by default).
Sort entries alphabetically if none of -cftuvSUX nor --sort is specified.

  -a, --all                 不隐藏任何以 . 开始的项目
  -A, --almost-all          列出除 . 及 .. 以外的任何项目
      --author              与 -l 使用时，列出每个文件的作者
  -b, --escape              以 C 转义序列表示不可打印的字符
      --block-size=SIZE     scale sizes by SIZE before printing them.  E.g.,
                           '--block-size=M' prints sizes in units of
                           1,048,576 bytes.  See SIZE format below.
  -B, --ignore-backups      不列出任何以 ~ 结尾的项目
  -c                        与 -lt 一起使用：按 ctime 排序并显示 ctime
                           与 -l 一起使用：显示 ctime 并按名称排序
                           否则：按 ctime 排序，最新的优先
      --color[=WHEN]        控制是否使用颜色区分文件类型。WHEN 可以是
                           'never'、'always' 或 'auto'
  -C                        每栏由上至下列出项目
  -d, --directory           当遇到目录时列出目录本身而非目录内的文件
  -D, --dired               产生适合 Emacs 的 dired 模式使用的输出
  -f                        不进行排序，-aU 选项生效，-lst 选项失效
  -F, --classify            加上文件类型的指示符号 (*/=@|)
  -g                        类似 -l，但不列出所有者
      --group-directories-first
                           在文件之前分组目录
                           可以使用 --sort 选项来覆盖，但 --group-directories-first
                           会优先于 --sort=none (-U)
  -G, --no-group            在长列表中不输出组名
  -h, --human-readable      与 -l 一起使用，以人类可读的格式输出文件大小
                            (例如 1K 234M 2G)
      --si                  类似 -h，但使用 1000 为基数而不是 1024
  -H, --dereference-command-line
                           跟随命令行列出的符号链接
      --dereference-command-line-symlink-to-dir
                           跟随指向目录的命令行符号链接
  -i, --inode               显示每个文件的索引节点号（inode 号）
  -I, --ignore=PATTERN      不显示 shell 样式匹配的项目
  -k, --kibibytes           默认使用 1024 字节的块大小
  -l                        使用较长格式列出信息
  -L, --dereference         当显示符号链接的信息时，显示符号链接所指示的对象
                           而非符号链接本身的信息
  -m                        所有项目以逗号分隔，并填满整行行宽
  -n, --numeric-uid-gid     类似 -l，但列出 UID 及 GID 号
  -N, --literal             输出未经处理的项目名称
  -o                        类似 -l，但不列出组信息
  -p, --indicator-style=slash
                           对目录附加 / 指示符号
  -q, --hide-control-chars  以 ? 字符代替无法打印的字符
      --show-control-chars  直接显示无法打印的字符 (这是默认行为，除非
                           程序名称是 'ls' 且输出到终端)
  -Q, --quote-name          以双引号括起项目名称
  -r, --reverse             逆序排列
  -R, --recursive           递归显示子目录
  -s, --size                以块数形式显示每个文件分配的尺寸
  -S                        按文件大小排序
  -t                        按修改时间排序
  -T, --tabsize=COLS        指定制表符宽度为 COLS
  -u                        与 -lt 一起使用：按访问时间排序并显示访问时间
                           与 -l 一起使用：显示访问时间并按名称排序
                           否则：按访问时间排序，最新的优先
  -U                        不进行排序；按照目录顺序列出项目
  -v                        按版本进行自然排序
  -w, --width=COLS          指定屏幕宽度而不使用当前的数值
  -x                        逐行列出项目而不是逐栏列出
  -X                        按扩展名排序
  -Z, --context             显示每个文件的安全上下文
  -1                        每行只列出一个项目
      --help                显示此帮助信息并退出
      --version             输出版本信息并退出
```

# 基本语法

```sh
ls [选项] [文件或目录...]
```

如果不指定文件或目录，默认列出当前目录的内容。

# 常用选项

| 选项 | 说明 |
|------|------|
| `-a, --all` | 显示所有文件（包括隐藏文件） |
| `-l` | 详细列表格式 |
| `-h, --human-readable` | 人类可读的文件大小 |
| `-t` | 按修改时间排序 |
| `-S` | 按文件大小排序 |
| `-r, --reverse` | 逆序排列 |
| `-R, --recursive` | 递归列出子目录 |
| `-d, --directory` | 列出目录本身而非内容 |
| `-i, --inode` | 显示 inode 号 |
| `-F, --classify` | 添加文件类型指示符 |
| `-1` | 每行一个文件 |
| `--color` | 使用颜色区分文件类型 |

# 基本使用

## 列出文件

```sh
# 列出当前目录
➜ ls

# 列出指定目录
➜ ls /path/to/dir

# 列出多个目录
➜ ls dir1/ dir2/
```

## 显示详细信息

```sh
# 详细列表（最常用）
➜ ls -l

# 显示所有文件（包括隐藏文件）
➜ ls -la

# 人类可读的文件大小
➜ ls -lh

# 显示 inode 号
➜ ls -li
```

## 排序

```sh
# 按时间排序（最新的在前）
➜ ls -lt

# 按大小排序（最大的在前）
➜ ls -lS

# 逆序排列
➜ ls -lr
```

## 递归列出

```sh
# 递归列出所有子目录
➜ ls -R

# 递归并显示详细信息
➜ ls -lR
```

# 输出格式说明

## ls -l 输出格式

```
-rw-r--r-- 1 user group 1234 Jan 1 10:00 file.txt
drwxr-xr-x 2 user group 4096 Jan 1 10:00 dir/
```

- **第1列**：文件类型和权限
  - `-`：普通文件
  - `d`：目录
  - `l`：符号链接
  - `c`：字符设备
  - `b`：块设备
- **第2列**：硬链接数
- **第3列**：所有者
- **第4列**：所属组
- **第5列**：文件大小（字节）
- **第6-8列**：修改时间
- **第9列**：文件名

# 实际应用场景

## 查看文件

```sh
# 查看当前目录文件
➜ ls

# 查看隐藏文件
➜ ls -a

# 查看详细信息
➜ ls -lh
```

## 查找文件

```sh
# 查找特定类型的文件
➜ ls *.txt

# 查找大文件
➜ ls -lhS | head -10

# 查找最新文件
➜ ls -lt | head -10
```

## 文件管理

```sh
# 查看目录大小
➜ ls -lhS

# 查看文件权限
➜ ls -l

# 查看文件所有者
➜ ls -l
```

## 与其他命令组合

```sh
# 统计文件数量
➜ ls -1 | wc -l

# 查找特定文件
➜ ls -la | grep "pattern"

# 只显示目录
➜ ls -d */
```

# 注意事项

1. **颜色显示**：默认情况下，ls 会使用颜色区分文件类型
2. **排序**：默认按字母顺序排序
3. **权限**：某些文件可能需要权限才能查看
4. **性能**：对于包含大量文件的目录，ls 可能需要一些时间

# 参考文献
* [GNU Coreutils - ls](https://www.gnu.org/software/coreutils/manual/html_node/ls-invocation.html)

