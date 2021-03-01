---
title: sed命令
tags:
  - linux
  - command
categories:
  - tech
date: 2019-03-13 09:43:26
---

**sed**是一种流编辑器，它是文本处理中非常中的工具，能够完美的配合正则表达式使用，功能不同凡响。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”（pattern space），接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。文件内容并没有 改变，除非你使用重定向存储输出。Sed主要用来自动编辑一个或多个文件；简化对文件的反复操作；编写转换程序等。

sed处理的⽂文件既可以由标准输⼊入重定向得到,也可以当命令⾏行参数传⼊入,命令⾏行参数可以⼀次传入多个⽂件，sed会依次处理。sed的编辑命令可以直接当命令⾏行参数传⼊，也可以写成一个脚本⽂件，然后用-f参数指定，编辑命令的格式为`/pattern/action`，其中pattern是正则表达式，action是编辑操作。sed程序⼀行⼀行读出待处理文件，如果某一行与pattern匹配，则执⾏行相应的action，如果一条命令没有pattern⽽只有 action,这个action将作用于待处理⽂件的每⼀行。


# 参数
## -e
允许在同一行里执行多条命令
## -i
修改作用于原文件
## -n
只输出处理后的行
## -r
使用扩展正则匹配

# 指令
## /pattern/p
sed会把文件内容和处理结果一起输出，所以`p`表示除了原有输出还会多打印正则匹配到的行，如果只想获取处理后的结果需要加上参数`-n`
```bash
$ cat test.txt | sed "/1/p"
1 a ,
1 a ,
2 b .

$ cat test.txt | sed -n "/1/p"
1 a ,
```

## /pattern/d
`d`表示在原有输出中删除匹配行
```bash
$ cat test.txt | sed "/1/d"    
2 b .
```

## /parttern/s/parttern1/parttern2
`s`表示匹配parttern的行，替换parttern1的为parttern2，
* 如果在parttern2后面加上`/g`表示全部替换
* 在parttern2中`&`表示当前匹配的parttern1
* `\1`、`\2`...，表示匹配的parttern1中的第1，2...个括号的内容。sed默认使用Basic正则表达式规范，如果指定了`-r`选项则使用Extended规范,那么`()`括号就不必转义了。

```bash
$ cat test.txt | sed "/1/s/ /-/"  
1-a ,
2 b .

$ cat test.txt | sed "/1/s/ /-/g"
1-a-,
2 b .

$ cat test.txt | sed "/1/s/ /-&-/g" 
1- -a- -,
2 b .

$ cat test.txt | sed "/1/s/\([0-9]\) \([a-z]\)/-\1- -\2-/g" 
-1- -a- ,
2 b .
```

## 定址
定址⽤于决定对哪些行进行编辑，地址的形式可以是数字、正则表达式、或二者的结合。
如果没有指定地址，sed将处理输入文件的所有行。
```bash
$ cat test.txt | sed -n "1p"       # 打印第一行
1 a ,

$ cat test.txt | sed -n "1,2p"     # 打印1到2行，包括这两行
1 a ,
2 b .

$ cat test.txt | sed -n "/1/,2p"   # 打印匹配/1/到第二行
1 a ,
2 b .

$ cat test.txt | sed -n "/1/,/2/p" # 打印匹配/1/到匹配/2/行
1 a ,
2 b .
```

# 正则表达式
sed的正则表达式是括在`//`里面，来进行查找和替换的。
## 特殊符号
* `^`，行首定位符
* `$`，行尾定位符
* `.`，匹配除换行符之外的任意字符
* `*`，匹配0个或多个前导字符，`/test*/`匹配包含字符串tes，后跟零个或多个t字母的行
* `[]`，匹配在字符数组内的任一字符
* `[^]`，匹配不在字符数组内的任一字符
* `\(\)`，保存匹配的字符，可以在后面通过数字进行引用
* `&`，保存查找串
* `\<`，词首定位符
* `\>`，词尾定位符
* `x\{m\}`，匹配m个x
* `x\{m,\}`，匹配至少m个x
* `x\{m,n\}`，匹配至少m个x，至多n个x

示例：
```bash
$ seq 50 | sed -n "/21*/p"
2
12
20
21
22
23
24
25
26
27
28
29
32
42
```

# 模式空间与保持空间
sed在正常情况下，将处理的行读入模式空间(pattern space)，脚本中的“sed- command(sed命令)”就一条接着⼀条进⾏处理，直到脚本执行完毕。然后该⾏被输出，模式(pattern space)被清空；接着，在重复执行刚才的动作，文件中的新的一行被读入，直到⽂件处理完毕。
整体流程：
```flow
st=>start: 开始
e=>end: 结束
file=>inputoutput: 输入文件
cond=>condition: 是否到文件尾
readline=>operation: 读取一行到pattern space
exec=>operation: 在pattern space中执行sed
print=>operation: 打印pattern space中的内容，然后清空

st->file->cond
cond(yes, right)->e
cond(no)->readline->exec->print(left)->cond
```

但是光有模式空间是不行的，还需要保持空间(hold space)来完成某些任务
* g，[address[,address]]g 将hold space中的内容拷⻉贝到pattern space中， 原来pattern space⾥里的内容清除
* G，[address[,address]]G 将hold space中的内容append到pattern space\n后
* h，[address[,address]]h 将pattern space中的内容拷⻉贝到hold space中， 原来的hold space⾥里的内容被清除
* H，[address[,address]]H 将pattern space中的内容append到hold space\n后
* d，[address[,address]]d 删除pattern中的所有⾏行，并读⼊入下⼀一新⾏行到 pattern中
* D，[address[,address]]D 删除multiline pattern中的第⼀一⾏行，不读⼊入下⼀一⾏行
* x，交换保持空间和模式空间的内容

示例：
在每行后面加上换行符   
```bash
$ seq 5 | sed 'G      
1

2

3

4

5

```

逆序，`1!G`表示第一行不执行G，`$!d`表示最后一行不执行d
```bash
$ seq 5 | sed '1!G;h;$!d'
5
4
3
2
1
```

求1~100的和，H把模式空间append到保持空间，最后一行先交换空间，将换行符匹配成加号，替换第一个加号，打印结果，bc计算
```bash
$ seq 100 | sed -n 'H;$x;$s/\n/+/g;$s/^+//;$p' | bc
5050
```


## 命令列表
**a\** 在当前行下面插入文本。
**i\** 在当前行上面插入文本。
**c\** 把选定的行改为新的文本。
**d** 删除，删除选择的行。
**D** 删除模式空间的第一行。
**s** 替换指定字符
**h** 拷贝模式空间的内容到内存中的缓冲区。
**H** 追加模式空间的内容到内存中的缓冲区。
**g** 获得保持空间的内容，并替代当前模式空间中的文本。
**G** 获得保持空间的内容，并追加到当前模式空间文本的后面。
**l** 列表不能打印字符的清单。
**n** 读取下一个输入行，用下一个命令处理新的行而不是用第一个命令。
**N** 追加下一个输入行到模式空间后面并在二者间嵌入一个新行，改变当前行号码。
**p** 打印模式空间的行。
**P**(大写) 打印模式空间的第一行。
**q** 退出Sed。
**b lable** 分支到脚本中带有标记的地方，如果分支不存在则分支到脚本的末尾。
**r file** 从file中读行。
**t label** if分支，从最后一行开始，条件一旦满足或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
**T label** 错误分支，从最后一行开始，一旦发生错误或者T，t命令，将导致分支到带有标号的命令处，或者到脚本的末尾。
**[w](http://man.linuxde.net/w "w命令") file** 写并追加模式空间到file末尾。  
**W file** 写并追加模式空间的第一行到file末尾。  
**!** 表示后面的命令对所有没有被选定的行发生作用。  
**=** 打印当前行号码。  
**#** 把注释扩展到下一个换行符以前。

