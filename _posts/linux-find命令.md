---
author: djaigo
title: linux-find命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - cmd
  - command
date: 2020-09-16 18:18:17
updated: 2020-09-16 18:18:17
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

# 参考文献
* [Linux 命令之 find：查找文件](https://blog.csdn.net/qq_35246620/article/details/79104520)
