---
author: djaigo
title: linux sort命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - cmd
  - command
date: 2019-12-23 17:17:47
---

# 简介
sort命令是将制定文件内容以行为单位进行ASCII码值排序，最后将他们按升序输出。
sort的帮助文档：
```text
sort --help
用法：sort [选项]... [文件]...
　或：sort [选项]... --files0-from=F
Write sorted concatenation of all FILE(s) to standard output.

Mandatory arguments to long options are mandatory for short options too.
排序选项：

  -b, --ignore-leading-blanks	忽略前导的空白区域
  -d, --dictionary-order	只考虑空白区域和字母字符
  -f, --ignore-case		忽略字母大小写
  -g, --general-numeric-sort  compare according to general numerical value
  -i, --ignore-nonprinting    consider only printable characters
  -M, --month-sort            compare (unknown) < 'JAN' < ... < 'DEC'
  -h, --human-numeric-sort    使用易读性数字(例如： 2K 1G)
  -n, --numeric-sort		根据字符串数值比较
  -R, --random-sort		根据随机hash 排序
      --random-source=文件	从指定文件中获得随机字节
  -r, --reverse			逆序输出排序结果
      --sort=WORD		按照WORD 指定的格式排序：
					一般数字-g，高可读性-h，月份-M，数字-n，
					随机-R，版本-V
  -V, --version-sort		在文本内进行自然版本排序

其他选项：

      --batch-size=NMERGE	一次最多合并NMERGE 个输入；如果输入更多
					则使用临时文件
  -c, --check, --check=diagnose-first	检查输入是否已排序，若已有序则不进行操作
  -C, --check=quiet, --check=silent	类似-c，但不报告第一个无序行
      --compress-program=程序	使用指定程序压缩临时文件；使用该程序
					的-d 参数解压缩文件
      --debug			为用于排序的行添加注释，并将有可能有问题的
					用法输出到标准错误输出
      --files0-from=文件	从指定文件读取以NUL 终止的名称，如果该文件被
					指定为"-"则从标准输入读文件名
  -k, --key=KEYDEF          sort via a key; KEYDEF gives location and type
  -m, --merge               merge already sorted files; do not sort
  -o, --output=文件		将结果写入到文件而非标准输出
  -s, --stable			禁用last-resort 比较以稳定比较算法
  -S, --buffer-size=大小	指定主内存缓存大小
  -t, --field-separator=分隔符	使用指定的分隔符代替非空格到空格的转换
  -T, --temporary-directory=目录	使用指定目录而非$TMPDIR 或/tmp 作为
					临时目录，可用多个选项指定多个目录
      --parallel=N		将同时运行的排序数改变为N
  -u, --unique		配合-c，严格校验排序；不配合-c，则只输出一次排序结果
  -z, --zero-terminated	以0 字节而非新行作为行尾标志
      --help		显示此帮助信息并退出
      --version		显示版本信息并退出

KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position, where F is a
field number and C a character position in the field; both are origin 1, and
the stop position defaults to the line's end.  If neither -t nor -b is in
effect, characters in a field are counted from the beginning of the preceding
whitespace.  OPTS is one or more single-letter ordering options [bdfgiMhnRrV],
which override global ordering options for that key.  If no key is given, use
the entire line as the key.

SIZE may be followed by the following multiplicative suffixes:
内存使用率% 1%，b 1、K 1024 (默认)，M、G、T、P、E、Z、Y 等依此类推。

如果不指定文件，或者文件为"-"，则从标准输入读取数据。

*** 警告 ***
本地环境变量会影响排序结果。
如果希望以字节的自然值获得最传统的排序结果，请设置LC_ALL=C。
```

# 常用命令
## -b 忽略前置空白字符

## -c 检查是否已排序

## -f 忽略大小写


## -M 按月份排序

## -n 数值排序
由于sort采用的是ASCII码值排序只会导致100在11之前，如果有需要将其数值排序可以使用-n选项，sort也只会比较最开始一直是数值的字符。
示例：
```sh
➜ seq 20 | sort
1
10
11
12
13
14
15
16
17
18
19
2
20
3
4
5
6
7
8
9

➜ seq 20 | sort -n
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
```

## -o 输出重定向
sort默认输出位置是标准输出，可以使用-o重定向输出位置。


## -t -k 列项排序
sort支持列项排序，即对相同列项进行排序，以当前列项值为排序的索引，排序所有行。
-t指定列项分隔符，默认是空白字符，-k指定按照分隔符划分出的第几列。
示例：
```sh
➜ netstat -an | grep tcp | awk '{print $1,$2,$3,$6}' | sort -k4
tcp 0 0 ESTABLISHED
tcp 0 0 ESTABLISHED
tcp 0 0 ESTABLISHED
tcp 0 0 ESTABLISHED
tcp 0 0 ESTABLISHED
tcp 0 140 ESTABLISHED
tcp6 0 0 ESTABLISHED
tcp6 0 0 ESTABLISHED
tcp 0 0 LISTEN
tcp 0 0 LISTEN
tcp 0 0 LISTEN
tcp6 0 0 LISTEN
tcp6 0 0 LISTEN
tcp6 0 0 LISTEN
tcp 0 0 TIME_WAIT
tcp 0 0 TIME_WAIT
tcp 0 0 TIME_WAIT
tcp 0 0 TIME_WAIT
```


## -r 逆序
sort默认输出是升序，如果我们需要降序就可以利用-r参数。
示例：
```sh
➜ seq 9 | sort -r
9
8
7
6
5
4
3
2
1
```


## -R 随机排序
乱序。
```sh
➜ seq 9 | sort -R
1
6
8
5
4
9
7
2
3
```


## -u 去重
sort排序内容如果有很多重复行，可以使用去重，排序后，在输出行中去除重复行。


