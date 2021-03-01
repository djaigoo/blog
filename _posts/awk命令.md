---
title: awk命令
tags:
  - linux
  - command
categories:
  - tech
date: 2019-03-13 17:32:00
---

sed以行为单位处理⽂件，awk比sed强的地方在于不仅能以行为单位还能以列为单位处理文件。awk缺省的⾏分隔符是换⾏行，缺省的列分隔符是连续的空格和Tab，但是行分隔符和列分隔符都可以自定义，⽐如/etc/passwd文件的每⼀行有若干个字段，字段之间以`:`分隔，就可以重新定义awk的列分隔符为`:`并以列为单位处理这个⽂件。awk实际上是⼀门很复杂的脚本语言，还有像C语言⼀样的分支和循环结构，但是基本⽤法和sed类似，awk命令⾏的基本形式为:

```bash
awk option 'script' file1 file2 ... awk option -f scriptfile file1 file2 ...
```

和sed一样，awk处理的文件既可以由标准输⼊重定向得到，也可以当命令行参数传入，编辑命令可以直接当命令行参数传入，也可以⽤用-f参数指定一个脚本⽂文件，编辑命令的格式为:

```bash
/pattern/{actions} 
```

和sed类似，pattern是正则表达式，actions是一系列操作。awk程序一⾏一⾏读出待处理文件，如果某⼀行与pattern匹配，或者满足condition条件，则执行相应的actions，如果⼀条awk命令只有actions部分，则actions作⽤于待处理⽂件的每⼀行。

# 参数
## -f
指明awk脚本文件
## -F
指明域分隔符

# 语法
## 列
通过`$`可以获取到列元素，`$0`表示当前行，`$1`表示第一列，以次类推，`$N`F表示最后一列。
```bash
$ awk '$1>1{print $0, "Y"} $1<=1{print $0, "N"}' test.txt
1 a , N
2 b . Y
```

## 输出
### print
### printf

## 条件
awk支持类似C语言风格的条件判断语句，支持`if(){}else if(){}else{}`
除了普通的条件外，awk还支持两个特殊的条件`BEGIN`和`END`
* BEGIN，后面的action在处理整个文件之前执行一次
* END，后面的action在处理整个文件之后执行一次

一般是在BEGIN中初始化操作，在END中进行收尾工作
例如统计以1开头的行数，甚至可以在x初始化的时候设置为100
```bash
$ seq 30 | awk '/^1/{x=x+1}END{print x}'  
11

$ seq 30 | awk 'BEGIN{x = 100}/^1/{x=x+1}END{print x}' 
111
```

## 循环
awk中的循环语句同样借鉴于C语⾔，支持while、do/while、for、break、continue， 这些关键字的语义和C语言中的语义完全相同。

# 调用方式
## 命令⾏方式
awk [-F  field-separator]  'commands'  input-file(s) 
其中，commands 是真正awk命令，[-F域分隔符]是可选的。 input-file(s) 是待处理的文件。
在awk中，文件的每⼀行中，由域分隔符分开的每⼀项称为⼀个域。通常，在不指名`-F`域分隔符的情况下，默认的域分隔符是空格。 

## shell脚本方式
将所有的awk命令插⼊一个⽂件，并使awk程序可执⾏，然后awk命令解释器作为脚本的⾸行，⼀遍通过键入脚本名称来调用。 
相当于shell脚本⾸首⾏行的:#!/bin/sh，可以换成:#!/bin/awk。

# 正则表达式
awk支持通过`//`引用的正则匹配字符串匹配整行文本，也可以通过（`~`，`!~`）判断某个域是否满足正则匹配，还可以通过内置的函数进行匹配
* gsub( Ere, Repl, [ In ] ) 
* sub( Ere, Repl, [ In ] ) 
* match( String, Ere ) 
* split( String, A, [Ere] )

# 内置变量
内置变量包括：
* ARGC 命令⾏行参数个数
* ENVIRON ⽀支持队列中系统环境变量的使⽤用
* FILENAME awk浏览的⽂文件名
* FNR 浏览⽂文件的记录数
* FS 设置输⼊入域分隔符，等价于命令⾏行 -F选项
* NF 浏览记录的域的个数
* NR 已读的记录数 OFS 输出域分隔符
* ORS 输出记录分隔符 RS 控制记录分隔符


