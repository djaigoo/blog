---
author: djaigo
title: linux-find命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
---

在linux中find是一个非常有用的命令，它可以快速查找指定目录下符合条件的文件。

```sh
➜ find --help
Usage: find [-H] [-L] [-P] [-Olevel] [-D help|tree|search|stat|rates|opt|exec] [path...] [expression]

default path is the current directory; default expression is -print
expression may consist of: operators, options, tests, and actions:

operators (decreasing precedence; -and is implicit where no others are given):
      ( EXPR )   ! EXPR   -not EXPR   EXPR1 -a EXPR2   EXPR1 -and EXPR2
      EXPR1 -o EXPR2   EXPR1 -or EXPR2   EXPR1 , EXPR2

positional options (always true): -daystart -follow -regextype

normal options (always true, specified before other expressions):
      -depth --help -maxdepth LEVELS -mindepth LEVELS -mount -noleaf
      --version -xautofs -xdev -ignore_readdir_race -noignore_readdir_race

tests (N can be +N or -N or N): -amin N -anewer FILE -atime N -cmin N
      -cnewer FILE -ctime N -empty -false -fstype TYPE -gid N -group NAME
      -ilname PATTERN -iname PATTERN -inum N -iwholename PATTERN -iregex PATTERN
      -links N -lname PATTERN -mmin N -mtime N -name PATTERN -newer FILE
      -nouser -nogroup -path PATTERN -perm [-/]MODE -regex PATTERN
      -readable -writable -executable
      -wholename PATTERN -size N[bcwkMG] -true -type [bcdpflsD] -uid N
      -used N -user NAME -xtype [bcdpfls]
      -context CONTEXT


actions: -delete -print0 -printf FORMAT -fprintf FILE FORMAT -print
      -fprint0 FILE -fprint FILE -ls -fls FILE -prune -quit
      -exec COMMAND ; -exec COMMAND {} + -ok COMMAND ;
      -execdir COMMAND ; -execdir COMMAND {} + -okdir COMMAND ;
```

find的语法：`find [option] [path ... ] [expression]`
默认`path`是当前路径，默认`expression`是`-print`。`expression`还可以是`operators`，`options`，`tests`，`actions`。

operators：优先级递减，默认是`-and`
* `()`，集合
* `!`，`-not`，非
* `-a`，`-and`，且
* `-o`，`-or`，或
* `,`，合并

positional options：总是true
* `-daystart`，从本日开始计算时间
* `-follow`，排除符号连接
* `-regextype`

normal options：总是true，在其他表达式之前指定
* `-depth`，限制递归深度
* `--help`，打印usage
* `-maxdepth LEVELS`，
* `-mindepth LEVELS`，
* `-mount`，同`-xdev`
* `-noleaf`，不去考虑目录至少需拥有两个硬连接存在
* `--version`，打印版本
* `-xautofs`，
* `-xdev`，将范围局限在先行的文件系统中
`-ignore_readdir_race`，`-noignore_readdir_race`

tests：（N可以是+N -N N，+表示大于N，-表示小于N，不带符号表示等于N）
* `-amin N`，查找在指定时间曾被存取过的文件或目录，单位以分钟计算
* `-anewer FILE`，查找其存取时间较指定文件或目录的存取时间更接近现在的文件或目录
* `-atime N`，查找在指定时间曾被存取过的文件或目录，单位以 24 小时计算
* `-cmin N`，查找在指定时间之时被更改过的文件或目录
* `-cnewer FILE`，查找其更改时间较指定文件或目录的更改时间更接近现在的文件或目录
* `-ctime N`，查找在指定时间之时被更改的文件或目录，单位以 24 小时计算
* `-empty`，寻找文件大小为 0 Byte 的文件，或目录下没有任何子目录或文件的空目录
* `-false`，回传值都为false
* `-fstype TYPE`，只寻找该文件系统类型下的文件或目录
* `-gid N`，所属组id的文件
* `-group NAME`，所属组名称的文件
* `-ilname PATTERN`，类似`-lname`，忽略大小写
* `-iname PATTERN`，类似`-name`，忽略大小写
* `-inum N`，查找符合指定的`inode`编号的文件或目录
* `-iwholename PATTERN` 
* `-iregex PATTERN`，类似`-regex`，忽略大小写
* `-links N`，查找符合指定的硬连接数目的文件或目录
* `-lname PATTERN`，类似`-name`，只获取连接文件
* `-mmin N`，查找在指定时间曾被更改过的文件或目录，单位以分钟计算
* `-mtime N`，查找在指定时间曾被更改过的文件或目录，单位以 24 小时计算
* `-name PATTERN`，按照**文件名**查找，支持`*`通配符
* `-newer FILE`，查找其更改时间较指定文件或目录的更改时间更接近现在的文件或目录
* `-nouser`，找出不属于本地主机用户识别码的文件或目录
* `-nogroup`，找出不属于本地主机群组识别码的文件或目录
* `-path PATTERN`，类似`-name`，匹配的是整个相对路径
* `-perm [-/]MODE`，按照文件权限查找
* `-regex PATTERN`，正则
* `-readable`，可读文件
* `-writable`，可写文件
* `-executable`，可执行文件
* `-wholename PATTERN`，完全名字匹配
* `-size N[bcwkMG]`，按照文件大小查找
* `-true`，回传值都为true
* `-type [bcdpflsD]`，按照文件类型查找
* `-uid N`，按照文件拥有者ID查找
* `-used N`，查找文件或目录被更改之后在指定时间曾被存取过的文件或目录，单位以日计算
* `-user NAME`，按照文件拥有者查找
* `-xtype [bcdpfls]`，类似`-type`，针对符号连接检查
* `-context CONTEXT`

actions：
* `-delete`
* `-print0`，假设`find`指令的回传值为`ture`，就将文件或目录名称列出到标准输出，格式为全部的名称皆在同一行
* `-printf FORMAT`，假设`find`指令的回传值为`ture`，就将文件或目录名称列出到标准输出，格式由`FORMAT`指定
* `-fprintf FILE FORMAT`，类似`-printf`，格式化输出到文件
* `-print`，假设`find`指令的回传值为`ture`，就将文件或目录名称列出到标准输出，格式为每列一个名称
* `-fprint0 FILE`，类似`-print0`，将输出写入文件
* `-fprint FILE`，类似`-print`，将输出写入文件
* `-ls`，打印查找结果详细信息
* `-fls FILE`，类似`-ls`，将输出写入文件
* `-prune`，不寻找字符串作为寻找文件或目录的范本样式
* `-quit`，什么也不打印
* `-exec COMMAND`、`-exec COMMAND {} + -ok COMMAND`、`-execdir COMMAND`、`-execdir COMMAND {} + -okdir COMMAND`，将`find`出的结果执行其他命令，`{}`表示find后的集合，在`COMMAND`后面需要加上`\;`来标记`COMMAND`结束。`ok`类似`exec`，在执行`COMMAND`之前会询问是否执行。

文件类型：
* b，块设备
* c，字符设备
* d，目录
* p，管道
* f，普通文件
* l，链接文件
* s，套接字
* D，未知

大小单位：
* b，块（512 字节）
* c，字节
* w，字（2 字节）
* k，千字节
* M，兆字节
* G，吉字节

# 基本使用示例

## 按文件名查找

```sh
# 查找当前目录下所有.txt文件
➜ find . -name "*.txt"

# 查找指定目录下的文件
➜ find /home/user -name "*.log"

# 忽略大小写查找
➜ find . -iname "*.TXT"

# 查找多个文件名模式
➜ find . -name "*.txt" -o -name "*.log"
```

## 按文件类型查找

```sh
# 查找所有目录
➜ find . -type d

# 查找所有普通文件
➜ find . -type f

# 查找所有符号链接
➜ find . -type l

# 查找所有可执行文件
➜ find . -type f -executable
```

## 按文件大小查找

```sh
# 查找大于100MB的文件
➜ find . -size +100M

# 查找小于1KB的文件
➜ find . -size -1k

# 查找恰好为10字节的文件
➜ find . -size 10c

# 查找空文件
➜ find . -empty
```

## 按时间查找

```sh
# 查找最近7天内修改的文件
➜ find . -mtime -7

# 查找7天前修改的文件
➜ find . -mtime +7

# 查找恰好7天前修改的文件
➜ find . -mtime 7

# 查找最近30分钟内修改的文件
➜ find . -mmin -30

# 查找比指定文件更新的文件
➜ find . -newer reference_file.txt

# 查找今天修改的文件
➜ find . -daystart -mtime 0
```

## 按权限查找

```sh
# 查找权限为755的文件
➜ find . -perm 755

# 查找至少包含这些权限的文件（任何用户可执行）
➜ find . -perm -111

# 查找权限完全匹配的文件
➜ find . -perm /111
```

## 按用户和组查找

```sh
# 查找属于特定用户的文件
➜ find . -user username

# 查找属于特定组的文件
➜ find . -group groupname

# 查找没有所有者的文件
➜ find . -nouser

# 查找没有所属组的文件
➜ find . -nogroup
```

## 限制搜索深度

```sh
# 只在当前目录查找，不递归
➜ find . -maxdepth 1 -name "*.txt"

# 查找深度不超过3层的文件
➜ find . -maxdepth 3 -name "*.txt"

# 从第2层开始查找
➜ find . -mindepth 2 -name "*.txt"
```

# 高级用法

## 组合条件

```sh
# 查找同时满足多个条件的文件（AND）
➜ find . -name "*.txt" -type f -size +1M

# 查找满足任一条件的文件（OR）
➜ find . -name "*.txt" -o -name "*.log"

# 查找不满足条件的文件（NOT）
➜ find . ! -name "*.txt"

# 使用括号组合复杂条件
➜ find . \( -name "*.txt" -o -name "*.log" \) -type f
```

## 排除目录

```sh
# 排除.git目录
➜ find . -name ".git" -prune -o -type f -print

# 排除多个目录
➜ find . \( -name ".git" -o -name "node_modules" \) -prune -o -type f -print

# 排除当前目录下的隐藏目录
➜ find . -name ".*" -prune -o -type f -print
```

## 使用正则表达式

```sh
# 使用正则表达式匹配文件名
➜ find . -regex ".*\.\(txt\|log\)$"

# 忽略大小写的正则匹配
➜ find . -iregex ".*\.\(txt\|log\)$"
```

## 执行命令

```sh
# 对找到的文件执行命令（每找到一个文件执行一次）
➜ find . -name "*.txt" -exec ls -lh {} \;

# 使用+代替\;，批量处理（更高效）
➜ find . -name "*.txt" -exec ls -lh {} +

# 删除找到的文件（谨慎使用）
➜ find . -name "*.tmp" -delete

# 交互式确认后删除
➜ find . -name "*.tmp" -ok rm {} \;

# 在文件所在目录执行命令
➜ find . -name "*.txt" -execdir pwd \;
```

## 格式化输出

```sh
# 使用printf格式化输出
➜ find . -name "*.txt" -printf "%p %s bytes\n"

# 输出文件信息
➜ find . -name "*.txt" -printf "%f\t%s\t%TY-%Tm-%Td\n"

# 使用print0（用于处理包含空格的文件名）
➜ find . -name "*.txt" -print0 | xargs -0 ls -l
```

# 实际应用场景

## 清理临时文件

```sh
# 查找并删除7天前的临时文件
➜ find /tmp -type f -mtime +7 -delete

# 查找并删除空文件
➜ find . -type f -empty -delete

# 查找并删除特定扩展名的文件
➜ find . -name "*.swp" -delete
```

## 查找大文件

```sh
# 查找大于100MB的文件
➜ find / -type f -size +100M 2>/dev/null

# 查找最大的10个文件
➜ find . -type f -exec ls -lh {} + | sort -k5 -hr | head -10

# 查找并显示文件大小
➜ find . -type f -size +10M -ls
```

## 查找特定内容的文件

```sh
# 查找包含特定文本的文件（结合grep）
➜ find . -type f -name "*.txt" -exec grep -l "keyword" {} \;

# 查找并统计包含关键字的文件数
➜ find . -type f -exec grep -l "error" {} \; | wc -l
```

## 备份文件

```sh
# 查找最近修改的文件并复制到备份目录
➜ find . -type f -mtime -1 -exec cp {} /backup/ \;

# 查找并打包
➜ find . -name "*.log" -mtime -7 | tar -czf logs.tar.gz -T -
```

## 权限管理

```sh
# 查找权限不安全的文件（所有人可写）
➜ find . -type f -perm -002

# 查找没有执行权限的脚本文件
➜ find . -name "*.sh" ! -perm -111

# 批量修改文件权限
➜ find . -type f -name "*.sh" -exec chmod +x {} \;
```

## 日志分析

```sh
# 查找今天的日志文件
➜ find /var/log -type f -daystart -mtime 0

# 查找并查看最近的日志
➜ find /var/log -name "*.log" -mtime -1 -exec tail -n 100 {} \;
```

# 与其他命令的组合

## find + xargs

```sh
# 查找文件并传递给其他命令
➜ find . -name "*.txt" | xargs grep "keyword"

# 处理包含空格的文件名
➜ find . -name "*.txt" -print0 | xargs -0 rm

# 批量重命名
➜ find . -name "*.old" | xargs -I {} mv {} {}.bak
```

## find + grep

```sh
# 在找到的文件中搜索内容
➜ find . -type f -name "*.py" -exec grep -l "import os" {} \;

# 查找并显示匹配的行
➜ find . -type f -name "*.log" -exec grep -H "error" {} \;
```

## find + tar

```sh
# 查找文件并打包
➜ find . -name "*.conf" -print0 | tar -czf configs.tar.gz --null -T -

# 查找并排除某些文件后打包
➜ find . -type f ! -name "*.tmp" | tar -czf backup.tar.gz -T -
```

## find + chmod/chown

```sh
# 批量修改权限
➜ find . -type d -exec chmod 755 {} \;
➜ find . -type f -exec chmod 644 {} \;

# 批量修改所有者
➜ find . -type f -user olduser -exec chown newuser:newgroup {} \;
```

# 常见问题与技巧

## 处理特殊字符

```sh
# 使用-print0和xargs -0处理包含空格的文件名
➜ find . -name "*.txt" -print0 | xargs -0 ls -l

# 使用-execdir在文件所在目录执行命令（更安全）
➜ find . -name "*.sh" -execdir chmod +x {} \;
```

## 性能优化

```sh
# 限制搜索深度提高性能
➜ find . -maxdepth 3 -name "*.txt"

# 只在当前文件系统搜索（避免搜索挂载点）
➜ find . -xdev -name "*.txt"

# 使用+代替\;批量处理（更高效）
➜ find . -name "*.txt" -exec command {} +
```

## 避免权限错误

```sh
# 忽略权限错误
➜ find / -name "*.txt" 2>/dev/null

# 只搜索有权限的目录
➜ find . -readable -name "*.txt"
```

## 查找并统计

```sh
# 统计找到的文件数量
➜ find . -name "*.txt" | wc -l

# 统计文件总大小
➜ find . -type f -name "*.log" -exec du -ch {} + | tail -1
```

## 查找重复文件

```sh
# 查找相同大小的文件（可能是重复文件）
➜ find . -type f -exec ls -l {} \; | sort -k5 -n | uniq -d -f4
```

## 时间范围查找

```sh
# 查找最近1小时到24小时之间修改的文件
➜ find . -mmin +60 -mmin -1440

# 查找特定日期范围的文件（需要结合其他工具）
➜ find . -type f -newermt "2024-01-01" ! -newermt "2024-01-31"
```

# 注意事项

1. **使用-delete要谨慎**：`-delete`会直接删除文件，建议先用`-print`确认要删除的文件
2. **-exec和-execdir的区别**：`-exec`在find的起始目录执行命令，`-execdir`在文件所在目录执行
3. **时间参数的含义**：
   - `-mtime +7`：7天前
   - `-mtime 7`：恰好7天前
   - `-mtime -7`：最近7天内
4. **权限参数的含义**：
   - `-perm 755`：精确匹配
   - `-perm -755`：至少包含这些权限
   - `-perm /755`：任意位匹配
5. **性能考虑**：在大型文件系统中，使用`-maxdepth`限制搜索深度可以显著提高性能

# 参考文献
* [Linux 命令之 find：查找文件](https://blog.csdn.net/qq_35246620/article/details/79104520)
* [GNU Findutils Manual](https://www.gnu.org/software/findutils/manual/html_node/find_html/index.html)
* [菜鸟教程 - Linux find 命令](https://www.runoob.com/linux/linux-comm-find.html)
