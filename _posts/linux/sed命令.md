---
author: djaigo
title: linux-sed命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
---

sed（Stream Editor）是Linux中一个强大的流式文本编辑器，可以对文本进行非交互式的编辑。sed按行处理文本，支持正则表达式，可以进行查找、替换、删除、插入等操作。sed特别适合批量处理文本文件，是Linux系统中最常用的文本处理工具之一。
```sh
➜ sed --help
用法: sed [选项]... {脚本(如果没有其他脚本)} [输入文件]...

  -n, --quiet, --silent
                 取消自动打印模式空间
  -e 脚本, --expression=脚本
                 添加“脚本”到程序的运行列表
  -f 脚本文件, --file=脚本文件
                 添加“脚本文件”到程序的运行列表
  --follow-symlinks
                 直接修改文件时跟随软链接
  -i[SUFFIX], --in-place[=SUFFIX]
                 edit files in place (makes backup if SUFFIX supplied)
  -c, --copy
                 use copy instead of rename when shuffling files in -i mode
  -b, --binary
                 does nothing; for compatibility with WIN32/CYGWIN/MSDOS/EMX (
                 open files in binary mode (CR+LFs are not treated specially))
  -l N, --line-length=N
                 指定“l”命令的换行期望长度
  --posix
                 关闭所有 GNU 扩展
  -r, --regexp-extended
                 在脚本中使用扩展正则表达式
  -s, --separate
                 将输入文件视为各个独立的文件而不是一个长的连续输入
  -u, --unbuffered
                 从输入文件读取最少的数据，更频繁的刷新输出
  -z, --null-data
                 separate lines by NUL characters
  --help
                 display this help and exit
  --version
                 output version information and exit

如果没有 -e, --expression, -f 或 --file 选项，那么第一个非选项参数被视为
sed脚本。其他非选项参数被视为输入文件，如果没有输入文件，那么程序将从标准
输入读取数据。
```

# 基本语法

sed的基本语法格式为：
```sh
sed [选项] '脚本' [输入文件...]
sed [选项] -f 脚本文件 [输入文件...]
```

其中：
- `选项`：控制sed行为的参数
- `脚本`：sed命令和地址的组合
- `输入文件`：要处理的文件（可以是一个或多个文件，如果不指定则从标准输入读取）

# 常用选项

| 选项 | 说明 |
|------|------|
| `-n, --quiet, --silent` | 取消自动打印模式空间，只输出经过处理的行 |
| `-e 脚本, --expression=脚本` | 添加脚本到程序的运行列表，可以多次使用 |
| `-f 脚本文件, --file=脚本文件` | 从文件中读取sed脚本 |
| `-i[SUFFIX], --in-place[=SUFFIX]` | 直接修改文件，如果指定SUFFIX则创建备份 |
| `-r, --regexp-extended` | 使用扩展正则表达式（ERE），简化正则语法 |
| `-s, --separate` | 将输入文件视为独立的文件，而不是连续的输入 |
| `-u, --unbuffered` | 无缓冲模式，更频繁地刷新输出 |
| `-z, --null-data` | 使用NUL字符作为行分隔符 |

# sed 命令
## 行为命令
行为命令为sed匹配到指定的行后的操作，多个操作用`;`进行间隔：
* `!`，反向选取
* `:`，声明标签
* `a`，向下新增一行数据
* `b`，跳转标签，需要在标签前
* `c`，替换匹配行
* `d`，删除匹配行
* `g`，将保持空间复制到模式空间
* `G`，将保持空间追加到模式空间
* `h`，将模式空间的值复制到保持空间
* `H`，将模式空间的值追加到保持空间
* `i`，向上新增一行数据
* `n`，读取下一行到追加到模式空间，相当于模式空间有两行数据，但后续操作只会影响新读取的行
* `N`，读取下一行到追加到模式空间，与原有数据合并成一行，后续操作会影响新的一行
* `p`，打印匹配行
* `q`，退出
* `r`，从文件读取输入行
* `s`，替换，按照规则替换匹配行中的字符串，附加命令`g`表示行内全部替换
* `w`，将所选的行写入文件
* `x`，将模式空间和保持空间互换
* `y`，将字符替换为另一个字符
* '='，输出匹配行号

## 操作对象
操作对象表示sed匹配的行
* 数字，表示指定行，用`,`隔开表示连续的行
* `$`，表示最后一行
* `//{}`，之间的内容进行正则匹配，对匹配的行进行`{}`的操作，也可以不用`{}`，直接使用简化的行为命令也可以，还可以和数字一起使用，例如`/^s/,10p`，打印第一个以`s`开头的行到第10行

## sed正则表达式
正则操作符，用于匹配复杂的行
* `^`，行首匹配
* `$`，行尾匹配
* `.`，匹配除换行符外的任意字符
* `*`，贪心匹配，即匹配前一字符零次或多次，匹配直到最后出现的一次
* `?`，非贪心匹配，即匹配零次或一次
* `[]`，匹配任一字符
* `[^]`，不能匹配到任一字符
* `\(\)`，保存已匹配的字符，最多可匹配9次，编号为1到9，通过\1来引用
* `&`，表示已匹配的行
* `\<`，词首定位符
* `\>`，词尾定位符
* `\{n\}`，匹配前一字符出现n次
* `\{n,\}`，匹配前一字符至少出现n次
* `\{n,m\}`，匹配前一字符至少出现n次，但不超过m次


# 常见使用
## 输出偶数行
```sh
➜ seq 10 | sed -n '2~2p'
2
4
6
8
10
```

在这个命令中：
`-n` 选项表示只输出经过处理的行。
`2~2p` 表示从第 2 行开始，每隔 2 行输出一次（即输出偶数行），p 是打印命令。

# 常用功能
不输出第一行：`sed -n -e '1!p'`
不输出最后一行：`sed -n -e '$!p'`
输出十到二十行：`sed -n -e '10,20p'`
输出十行之后的行：`sed -e '1,10d'`或`sed -n -e '11,$p'`
行首加字符串abc：`sed  -e 's/^/abc/'`
行尾加字符串abc：`sed  -e 's/$/abc/'`
行首追加字符串abc但第一行不追加：`sed -e '1!s/^/abc/'`
替换行首第一个字符为d：`sed -e 's/^./d/'`
替换行尾最后一个字符为9：`sed -e 's/.$/9/'`
不输出空行：`sed -n '/^$/!p'`




# 模式空间与保持空间
上面的操作都是在默认的模式空间中进行的，sed为了能够同时处理多行数据，提供了保持空间。
模式空间是指，匹配到一行后执行相应的操作，然后模式空间清空，直到文件处理完毕。
保持空间是指，存储指定数据，可以通过行为命令将模式空间的数据覆盖、追加、互换操作。

## 实现tac
```sh
➜ seq 3 | sed -n '1!G;h;$p'
3
2
1
```

模式空间读入第一行，将模式空间复制到保持空间，删除模式空间
模式空间读入第二行，将保持空间追加到模式空间，将模式空间复制到保持空间，删除模式空间
其他行重复第二行的操作
模式空间读入最后一行，将保持空间追加到模式空间，将模式空间复制到保持空间，打印模式空间

## 实现xargs
```sh
➜ seq 3 | sed -n 'H;${x;s/\n/ /g;p}'
```

每一行都将模式空间追加到保持空间，最后一行将模式空间和保持空间数据对换，替换所有换行符为空格，打印模式空间。
正常情况下sed按行处理文本，是不会读到换行符，可以通过这种方式获取带换行符的多行数据。

# 标签
在sed脚本中`:`表示声明一个标签，b表示跳转标签。利用标签可以实现类似循环的操作。

## 实现xargs
```sh
➜ seq 3 | sed ':a;N;$!ba;${s/\n/ /g}'
```

设置标签a，读取下一行，与原有数据当做一行，不是最后一行跳转到标签a，直到最后一行，不跳转到标签a，替换所有的换行符为空格，sed自动打印模式空间内容

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


# 基本使用示例

## 文本替换

### 简单替换
```sh
# 替换每行第一个匹配的字符串
➜ echo "hello world hello" | sed 's/hello/HI/'
HI world hello

# 替换所有匹配的字符串（使用g标志）
➜ echo "hello world hello" | sed 's/hello/HI/g'
HI world HI

# 替换第N个匹配（使用数字标志）
➜ echo "a a a a" | sed 's/a/b/2'
a b a a
```

### 替换特定行
```sh
# 替换第一行
➜ seq 5 | sed '1s/1/ONE/'
ONE
2
3
4
5

# 替换最后一行
➜ seq 5 | sed '$s/5/FIVE/'
1
2
3
4
FIVE

# 替换第2到第4行
➜ seq 5 | sed '2,4s/[0-9]/X/'
1
X
X
X
5
```

### 条件替换
```sh
# 只替换包含特定模式的行
➜ echo -e "apple\nbanana\napple" | sed '/apple/s/a/A/g'
Apple
banana
Apple

# 替换不包含特定模式的行
➜ echo -e "apple\nbanana\napple" | sed '/apple/!s/a/A/g'
apple
bAnAnA
apple
```

## 删除操作

### 删除特定行
```sh
# 删除第一行
➜ seq 5 | sed '1d'
2
3
4
5

# 删除最后一行
➜ seq 5 | sed '$d'
1
2
3
4

# 删除第2到第4行
➜ seq 5 | sed '2,4d'
1
5

# 删除空行
➜ echo -e "a\n\nb\n\nc" | sed '/^$/d'
a
b
c

# 删除包含特定模式的行
➜ echo -e "apple\nbanana\napple" | sed '/apple/d'
banana
```

### 删除匹配内容
```sh
# 删除行首空格
➜ echo "   hello" | sed 's/^ *//'
hello

# 删除行尾空格
➜ echo "hello   " | sed 's/ *$//'
hello

# 删除行首和行尾空格
➜ echo "   hello   " | sed 's/^ *//;s/ *$//'
hello
```

## 插入和追加

### 插入文本
```sh
# 在第一行前插入
➜ seq 3 | sed '1i\Header:'
Header:
1
2
3

# 在匹配行前插入
➜ echo -e "apple\nbanana" | sed '/banana/i\---'
apple
---
banana

# 在最后一行前插入
➜ seq 3 | sed '$i\---'
1
2
---
3
```

### 追加文本
```sh
# 在第一行后追加
➜ seq 3 | sed '1a\---'
1
---
2
3

# 在匹配行后追加
➜ echo -e "apple\nbanana" | sed '/apple/a\---'
apple
---
banana

# 在最后一行后追加
➜ seq 3 | sed '$a\---'
1
2
3
---
```

## 修改行

```sh
# 替换整行
➜ seq 3 | sed '2c\REPLACED'
1
REPLACED
3

# 替换匹配的行
➜ echo -e "apple\nbanana\napple" | sed '/banana/c\REPLACED'
apple
REPLACED
apple
```

## 打印操作

```sh
# 打印特定行（使用-n抑制默认输出）
➜ seq 5 | sed -n '3p'
3

# 打印第2到第4行
➜ seq 5 | sed -n '2,4p'
2
3
4

# 打印匹配的行
➜ seq 10 | sed -n '/[2468]/p'
2
4
6
8

# 打印行号
➜ seq 3 | sed '='
1
1
2
2
3
3

# 打印行号和内容（在同一行）
➜ seq 3 | sed -n '=' | sed 'N;s/\n/ /'
1 1
2 2
3 3
```

## 文件操作

### 直接修改文件
```sh
# 直接修改文件（不创建备份）
➜ sed -i 's/old/new/g' file.txt

# 修改文件并创建备份
➜ sed -i.bak 's/old/new/g' file.txt

# macOS系统需要指定备份后缀（可以为空）
➜ sed -i '' 's/old/new/g' file.txt
```

### 写入文件
```sh
# 将匹配的行写入文件
➜ seq 10 | sed -n '/[2468]/w even.txt'
➜ cat even.txt
2
4
6
8

# 将处理结果写入文件
➜ seq 5 | sed 's/[0-9]/X/' > output.txt
```

### 从文件读取
```sh
# 在匹配行后插入文件内容
➜ echo -e "line1\nline2" | sed '/line1/r header.txt'
line1
(header.txt的内容)
line2
```

# 高级用法

## 多命令组合

```sh
# 使用分号分隔多个命令
➜ echo "hello world" | sed 's/hello/HI/; s/world/WORLD/'
HI WORLD

# 使用-e选项指定多个命令
➜ echo "hello world" | sed -e 's/hello/HI/' -e 's/world/WORLD/'
HI WORLD

# 从文件读取多个命令
➜ cat script.sed
s/hello/HI/
s/world/WORLD/
➜ echo "hello world" | sed -f script.sed
HI WORLD
```

## 使用扩展正则表达式

```sh
# 使用-r选项启用扩展正则表达式
➜ echo "abc123def" | sed -r 's/[0-9]+/NUM/'
abcNUMdef

# 扩展正则中()不需要转义
➜ echo "hello world" | sed -r 's/(hello) (world)/\2 \1/'
world hello
```

## 分组和反向引用

```sh
# 使用分组交换单词
➜ echo "hello world" | sed 's/\(hello\) \(world\)/\2 \1/'
world hello

# 使用扩展正则（更简洁）
➜ echo "hello world" | sed -r 's/(hello) (world)/\2 \1/'
world hello

# 重复使用分组
➜ echo "123-456" | sed -r 's/([0-9]+)-([0-9]+)/\2-\1/'
456-123
```

## 使用&引用匹配内容

```sh
# 在匹配内容前后添加字符
➜ echo "hello" | sed 's/hello/[&]/'
[hello]

# 重复匹配内容
➜ echo "test" | sed 's/test/& &/'
test test
```

# 实际应用场景

## 配置文件修改

```sh
# 注释掉包含特定配置的行
➜ sed -i 's/^\(.*server.*\)$/#\1/' config.conf

# 取消注释
➜ sed -i 's/^#\(.*server.*\)$/\1/' config.conf

# 修改配置值
➜ sed -i 's/^port=.*/port=8080/' config.conf

# 在配置块后添加新配置
➜ sed -i '/\[server\]/a\port=8080' config.conf
```

## 日志处理

```sh
# 删除日志中的时间戳
➜ sed 's/^\[.*\] //' log.txt

# 提取错误日志
➜ sed -n '/ERROR/p' log.txt

# 删除空行和注释行
➜ sed '/^$/d; /^#/d' config.txt

# 格式化日志（添加时间戳）
➜ sed "s/^/$(date '+%Y-%m-%d %H:%M:%S') /" log.txt
```

## 数据处理

```sh
# 将空格分隔转换为逗号分隔
➜ echo "a b c d" | sed 's/ /,/g'
a,b,c,d

# 删除重复的空格
➜ echo "a    b   c" | sed 's/  */ /g'
a b c

# 在每行前添加行号
➜ seq 3 | sed '=' | sed 'N;s/\n/ /'
1 1
2 2
3 3

# 或者使用更简单的方法
➜ seq 3 | sed = | sed 'N;s/^\([0-9]*\)\n\(.*\)/\1 \2/'
1 1
2 2
3 3
```

## 文本格式化

```sh
# 在每行后添加空行
➜ seq 3 | sed G
1

2

3

# 删除连续空行（只保留一个）
➜ echo -e "a\n\n\nb" | sed '/^$/N;/^\n$/d'
a

b

# 在段落之间添加分隔线
➜ sed '/^$/a\---' text.txt
```

## 批量重命名和替换

```sh
# 批量替换文件中的字符串
➜ find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# 批量添加文件头
➜ for file in *.txt; do
    sed -i "1i\# Header\n" "$file"
  done
```

# 与其他命令的组合

## sed + grep

```sh
# 先grep过滤，再sed处理
➜ grep "ERROR" log.txt | sed 's/ERROR/CRITICAL/'

# sed处理后再grep
➜ sed 's/old/new/g' file.txt | grep "pattern"
```

## sed + awk

```sh
# sed预处理，awk处理
➜ sed 's/,/ /g' data.csv | awk '{print $1, $3}'

# awk处理，sed后处理
➜ awk '{print $1}' file.txt | sed 's/^/prefix_/'
```

## sed + find

```sh
# find查找文件，sed批量处理
➜ find . -name "*.conf" -exec sed -i 's/old/new/g' {} \;

# 查找并替换特定文件类型
➜ find . -type f -name "*.txt" | xargs sed -i 's/old/new/g'
```

## sed + xargs

```sh
# 处理多个文件
➜ ls *.txt | xargs sed -i 's/old/new/g'

# 处理包含空格的文件名
➜ find . -name "*.txt" -print0 | xargs -0 sed -i 's/old/new/g'
```

# 常见问题与技巧

## 处理特殊字符

```sh
# 替换包含斜杠的字符串（需要转义）
➜ echo "path/to/file" | sed 's|path/to|/usr/local|'
/usr/local/file

# 或者使用不同的分隔符
➜ echo "path/to/file" | sed 's#path/to#/usr/local#'
/usr/local/file

# 替换包含点的字符串
➜ echo "192.168.1.1" | sed 's/\./-/g'
192-168-1-1
```

## 处理多行

```sh
# 删除空行后的下一行
➜ sed '/^$/{N;/\n.*$/d}' file.txt

# 合并连续空行为一个
➜ sed '/^$/{N;/^\n$/d}' file.txt

# 在每两行之间插入分隔符
➜ seq 6 | sed 'N;s/\n/---\n/'
1
---
2
3
---
4
5
---
6
```

## 性能优化

```sh
# 使用-n选项减少输出（当只需要特定行时）
➜ sed -n '10,20p' large_file.txt

# 使用q命令提前退出
➜ sed '/pattern/q' file.txt

# 处理大文件时使用流式处理
➜ cat large_file.txt | sed 's/old/new/g' > output.txt
```

## 调试技巧

```sh
# 使用l命令查看不可见字符
➜ echo -e "hello\tworld" | sed 'l'
hello\tworld$

# 逐步测试sed命令
➜ echo "test" | sed 's/t/T/'
Test

# 使用=查看行号
➜ sed -n '10,20=' file.txt
```

## 常见陷阱

### 1. 默认打印行为
```sh
# sed默认会打印所有行，即使没有匹配
➜ echo "test" | sed 's/old/new/'
test

# 使用-n只打印处理的行
➜ echo "test" | sed -n 's/old/new/p'
# 无输出（因为没有匹配）
```

### 2. 替换范围
```sh
# 默认只替换第一个匹配
➜ echo "a a a" | sed 's/a/b/'
b a a

# 使用g替换所有
➜ echo "a a a" | sed 's/a/b/g'
b b b
```

### 3. 行号引用
```sh
# $表示最后一行
➜ seq 5 | sed '$d'
1
2
3
4

# 不能使用变量作为行号（需要使用其他方法）
```

## 实用脚本示例

### 清理配置文件
```sh
#!/bin/bash
# 清理配置文件：删除注释和空行
sed '/^#/d; /^$/d' config.conf > config_clean.conf
```

### 提取日志
```sh
#!/bin/bash
# 提取特定时间段的日志
sed -n '/2024-01-15 10:/,/2024-01-15 11:/p' log.txt
```

### 格式化输出
```sh
#!/bin/bash
# 格式化CSV为表格
sed 's/,/ | /g' data.csv | sed '1s/^/| /; 1s/$/ |/'
```

# 注意事项

1. **备份文件**：使用`-i`选项修改文件前，建议先备份
2. **测试命令**：在生产环境使用前，先用测试数据验证
3. **特殊字符**：处理包含特殊字符的字符串时，注意转义或使用不同的分隔符
4. **大文件处理**：处理大文件时，考虑使用流式处理，避免内存问题
5. **跨平台兼容**：macOS和Linux的sed实现可能有差异，注意测试
6. **正则表达式**：基本正则和扩展正则的语法不同，注意区分
7. **默认行为**：sed默认会打印所有行，使用`-n`选项可以抑制默认输出

# 参考文献
* [菜鸟教程-Linux sed 命令](https://www.runoob.com/linux/linux-comm-sed.html)
* [GNU sed Manual](https://www.gnu.org/software/sed/manual/)
* [sed - An Introduction and Tutorial](https://www.grymoire.com/Unix/Sed.html)
