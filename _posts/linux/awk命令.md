---
author: djaigo
title: Linux awk命令
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png
categories: 
  - linux
tags: 
  - shell
mathjax: true
---

# 简介
awk是一个强大的文本处理和文本分析工具，不仅可以通过行为单位处理文本，还可以通过列为单位处理文本，默认行分隔符是换行符，默认列分隔符是连续空格和Tab，可以定义分隔符。awk提供了极其强大的功能：可以进行正则表达式的匹配，样式装入、流控制、数学运算符、进程控制语句甚至于内置的变量和函数。
获取帮助信息，gawk是awk的GNU版本
```sh
➜ awk --help
Usage: awk [POSIX or GNU style options] -f progfile [--] file ...
Usage: awk [POSIX or GNU style options] [--] 'program' file ...
POSIX options:		GNU long options: (standard)
	-f progfile		--file=progfile
	-F fs			--field-separator=fs
	-v var=val		--assign=var=val
Short options:		GNU long options: (extensions)
	-b			--characters-as-bytes
	-c			--traditional
	-C			--copyright
	-d[file]		--dump-variables[=file]
	-e 'program-text'	--source='program-text'
	-E file			--exec=file
	-g			--gen-pot
	-h			--help
	-L [fatal]		--lint[=fatal]
	-n			--non-decimal-data
	-N			--use-lc-numeric
	-O			--optimize
	-p[file]		--profile[=file]
	-P			--posix
	-r			--re-interval
	-S			--sandbox
	-t			--lint-old
	-V			--version

To report bugs, see node `Bugs' in `gawk.info', which is
section `Reporting Problems and Bugs' in the printed version.

gawk is a pattern scanning and processing language.
By default it reads standard input and writes standard output.

Examples:
	gawk '{ sum += $1 }; END { print sum }' file
	gawk -F: '{ print $1 }' /etc/passwd
```

# 执行方式
awk命令行的基本执行形式为：
```sh
awk option 'script' file1 file2 ...
awk option -f scriptfile file1 file2 ...
```

awk的操作对象既可以是文本文件，也可以是标准输入重定向得到，亦或是命令行参数传入。

## 命令行参数
常用命令行参数说明：

| 参数 | 说明 |
|---|---|
|-f|  执行awk脚本文件路径  |
|-F|输入域分隔符   |
|-v|传入shell变量   |
|-b|字符按照字节区分   |
|-h|帮助文档   |
|-V|显示版本   |

## 正则表达式
script一般格式为`/pattern/{actions}`，pattern表示正则表达式，actions表示一系列操作。awk利用正则表达式pattern匹配出需要执行actions的行，如果没有pattern表示每一行都执行actions。

示例：打印所有行
```sh
➜ seq 20 | awk '{print $1}'
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

示例：打印包含1的行
```
➜ seq 20 | awk '/1/{print $1}'
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
```

print表示打印；`$1`表示第一列，`$2`表示第二列，以此类推，`$0`表示当前行。

awk利用运算符`~`表示符合正则运算，`!~`表示不符合正则运算。
示例：
```sh
➜ seq 20 | awk '$1 !~ /1/{print $1}'            
2
3
4
5
6
7
8
9
20
```

## 数学运算
awk支持使用数学条件筛选，支持运算符表格：

| 运算符 | 描述 |
| --- | --- |
| `= += -= *= /= %= ^= **=` | 赋值 |
| `?:` | C条件表达式 |
| `\|\|` | 逻辑或 |
| `&&` | 逻辑与 |
| `~` 和 `!~` | 匹配正则表达式和不匹配正则表达式 |
| `< <= > >= != ==` | 关系运算符 |
| 空格 | 连接 |
| `+ -`| 加，减 |
| `* / %` | 乘，除与求余 |
| `+ - !` | 一元加，减和逻辑非 |
| `^ ***` | 求幂 |
| `++ --` | 增加或减少，作为前缀或后缀 |
| `$` | 字段引用 |
| `in` | 数组成员 |

示例：1-20中筛选大于10的偶数
```sh
➜ seq 20 | awk '$1%2==0&&$1>=10{print $1,"Y"}'
10 Y
12 Y
14 Y
16 Y
18 Y
20 Y
```


awk还支持算术函数

| 函数名 | 说明 |
| :-----: | --- |
| `atan2( y, x )` | 返回 y/x 的反正切。 |
| `cos( x )` | 返回 x 的余弦；x 是弧度。 |
| `sin( x )` | 返回 x 的正弦；x 是弧度。 |
| `exp( x )` | 返回 x 幂函数。 |
| `log( x )` | 返回 x 的自然对数。 |
| `sqrt( x )` | 返回 x 平方根。 |
| `int( x )` | 返回 x 的截断至整数的值。 |
| `rand()` | 返回任意数字 n，其中 0 <= n < 1。 |
| `srand([Expr])` | 将rand函数的种子值设置为Expr参数的值，或如果省略Expr参数则使用某天的时间。返回先前的种子值。|

示例：打印$e^{$1}$，上次随机数种子，随机数
```
➜ seq 20 | awk '{print exp($1), srand($1), rand()}'
2.71828 0 0.840188
7.38906 1 0.700976
20.0855 2 0.56138
54.5982 3 0.916458
148.413 4 0.274746
403.429 5 0.135439
1096.63 6 0.486904
2980.96 7 0.352761
8103.08 8 0.206965
22026.5 9 0.565811
59874.1 10 0.926345
162755 11 0.7856
442413 12 0.632643
1.2026e+06 13 0.999498
3.26902e+06 14 0.354973
8.88611e+06 15 0.215437
2.4155e+07 16 0.571794
6.566e+07 17 0.929073
1.78482e+08 18 0.290233
4.85165e+08 19 0.148812
```

## BEGIN-END
awk有两个特殊的条件，对待每个处理的文件，BEGIN后面的actions在执行整个文件**之前**执行一次，END后面的actions在执行整个文件**之后**执行一次。awk可以像c一样使用使用变量，但是不需要定义变量。
示例：
```sh
➜ seq 20 | awk  '/1/{x=x+1;}END{print x}'   
11

➜ seq 20 | awk 'BEGIN{x=100}/1/{x=x+1;}END{print x}' 
111
```

## 内建变量

| 变量 | 描述 |
| --- | --- |
| `$n` | 当前记录的第n个字段，字段间由FS分隔 |
| `$0` | 完整的输入记录 |
| `ARGC` | 命令行参数的数目 |
| `ARGIND` | 命令行中当前文件的位置(从0开始算) |
| `ARGV` | 包含命令行参数的数组 |
| `CONVFMT` | 数字转换格式(默认值为%.6g)ENVIRON环境变量关联数组 |
| `ERRNO` | 最后一个系统错误的描述 |
| `FIELDWIDTHS` | 字段宽度列表(用空格键分隔) |
| `FILENAME` | 当前文件名 |
| `FNR` | 各文件分别计数的行号 |
| `FS` | 字段分隔符(默认是任何空格) |
| `IGNORECASE` | 如果为真，则进行忽略大小写的匹配 |
| `NF` | 一条记录的字段的数目 |
| `NR` | 已经读出的记录数，就是行号，从1开始 |
| `OFMT` | 数字的输出格式(默认值是%.6g) |
| `OFS` | print函数输出字段分隔符（输出空格），输出时用指定的符号代替分隔符 |
| `ORS` | 输出记录分隔符(默认值是一个换行符) |
| `RLENGTH` | 由match函数所匹配的字符串的长度 |
| `RS` | 记录分隔符(默认是一个换行符) |
| `RSTART` | 由match函数所匹配的字符串的第一个位置 |
| `SUBSEP` | 数组下标分隔符(默认值是/034) |

示例：打印最后一列，并打印当前行数
```sh
➜ seq 20 | sort | awk '{print $NF "\t" NR}'
1	1
10	2
11	3
12	4
13	5
14	6
15	7
16	8
17	9
18	10
19	11
2	12
20	13
3	14
4	15
5	16
6	17
7	18
8	19
9	20
```

示例：替换输出分隔符和换行符
```sh
➜ echo "this is a test\nthis is a test" | awk 'BEGIN{OFS="_";ORS="--"}{print $1,$2,$3,$4}'
this_is_a_test--this_is_a_test--
```

## 一般函数

| **函数** | **说明** |
| --- | --- |
| `close( Expression )` | 用同一个带字符串值的 Expression 参数来关闭由 print 或 printf 语句打开的或调用 getline 函数打开的文件或管道。如果文件或管道成功关闭，则返回 0；其它情况下返回非零值。如果打算写一个文件，并稍后在同一个程序中读取文件，则 close 语句是必需的。 |
| `system(Command )` | 执行 Command 参数指定的命令，并返回退出状态。 |
| `Expression \| getline [ Variable ]` | 从来自 Expression 参数指定的命令的输出中通过管道传送的流中读取一个输入记录，并将该记录的值指定给 Variable 参数指定的变量。如果当前未打开将 Expression 参数的值作为其命令名称的流，则创建流。此时 Command 参数取 Expression 参数的值且 Mode 参数设置为一个是 r 的值。只要流保留打开且 Expression 参数求得同一个字符串，则对 getline 函数的每次后续调用读取另一个记录。如果未指定 Variable 参数，则 $0 记录变量和 NF 特殊变量设置为从流读取的记录。 |
| `getline [ Variable ] < Expression` | 从 Expression 参数指定的文件读取输入的下一个记录，并将 Variable 参数指定的变量设置为该记录的值。只要流保留打开且 Expression 参数对同一个字符串求值，则对 getline 函数的每次后续调用读取另一个记录。如果未指定 Variable 参数，则 $0 记录变量和 NF 特殊变量设置为从流读取的记录。 |
| `getline [ Variable ]` | 将 Variable 参数指定的变量设置为从当前输入文件读取的下一个输入记录。如果未指定 Variable 参数，则 $0 记录变量设置为该记录的值，还将设置 NF、NR 和 FNR 特殊变量。 |

示例：通过system函数执行shell语句，最后0表示Errno
```sh
➜ awk 'BEGIN{print system("ps -ef | grep awk")}'
root      6490 10366  0 17:16 pts/0    00:00:00 awk BEGIN{print system("ps -ef | grep awk")}
root      6491  6490  0 17:16 pts/0    00:00:00 sh -c ps -ef | grep awk
root      6493  6491  0 17:16 pts/0    00:00:00 grep awk
0
```

## 字符串函数
awk还有内置字符串函数

| **函数** | **说明** |
| --- | --- |
| `gsub( Ere, Repl, [ In ] )` | 除了正则表达式所有具体值被替代这点，它和 sub 函数完全一样地执行。 |
| `sub( Ere, Repl, [ In ] )`| 用 Repl 参数指定的字符串替换 In 参数指定的字符串中的由 Ere 参数指定的扩展正则表达式的第一个具体值。sub 函数返回替换的数量。出现在 Repl 参数指定的字符串中的 &（和符号）由 In 参数指定的与 Ere 参数的指定的扩展正则表达式匹配的字符串替换。如果未指定 In 参数，缺省值是整个记录（$0 记录变量）。 |
| `index( String1, String2 )` | 在由 String1 参数指定的字符串（其中有出现 String2 指定的参数）中，返回位置，从 1 开始编号。如果 String2 参数不在 String1 参数中出现，则返回 0（零）。 |
| `length [(String)]` | 返回 String 参数指定的字符串的长度（字符形式）。如果未给出 String 参数，则返回整个记录的长度（$0 记录变量）。 |
| `substr( String, M, [ N ] )` | 返回具有 N 参数指定的字符数量子串。子串从 String 参数指定的字符串取得，其字符以 M 参数指定的位置开始。M 参数指定为将 String 参数中的第一个字符作为编号 1。如果未指定 N 参数，则子串的长度将是 M 参数指定的位置到 String 参数的末尾 的长度。 |
| `match( String, Ere )` | 在 String 参数指定的字符串（Ere 参数指定的扩展正则表达式出现在其中）中返回位置（字符形式），从 1 开始编号，或如果 Ere 参数不出现，则返回 0（零）。RSTART 特殊变量设置为返回值。RLENGTH 特殊变量设置为匹配的字符串的长度，或如果未找到任何匹配，则设置为 -1（负一）。 |
| `split( String, A, [Ere] )` | 将 String 参数指定的参数分割为数组元素 `A[1], A[2], . . ., A[n]`，并返回 n 变量的值。此分隔可以通过 Ere 参数指定的扩展正则表达式进行，或用当前字段分隔符（FS 特殊变量）来进行（如果没有给出 Ere 参数）。除非上下文指明特定的元素还应具有一个数字值，否则 A 数组中的元素用字符串值来创建。 |
| `tolower( String )` | 返回 String 参数指定的字符串，字符串中每个大写字符将更改为小写。大写和小写的映射由当前语言环境的 LC_CTYPE 范畴定义。 |
| `toupper( String )` | 返回 String 参数指定的字符串，字符串中每个小写字符将更改为大写。大写和小写的映射由当前语言环境的 LC_CTYPE 范畴定义。 |
| `printf(Format, Expr, Expr, . . . )` | 根据 Format 参数指定的格式字符串来格式化 Expr 参数指定的表达式并返回最后生成的字符串。 |

sprintf函数format格式化参数转换表

| **格式符** | **说明** |
| --- | --- |
| `%d` | 十进制有符号整数 |
| `%u` | 十进制无符号整数 |
| `%f` | 浮点数 |
| `%s` | 字符串 |
| `%c` | 单个字符 |
| `%p` | 指针的值 |
| `%e` | 指数形式的浮点数 |
| `%x` | %X 无符号以十六进制表示的整数 |
| `%o` | 无符号以八进制表示的整数 |
| `%g`| 自动选择合适的表示法 |


示例：打印字符串，转换大小写
```sh
➜ awk 'BEGIN{str="Hello World";print str "\n" tolower(str) "\n" toupper(str)}'
Hello World
hello world
HELLO WORLD
```

示例：打印字符串长度，查找指定字串并返回子串索引，匹配正则字串并返回子串索引
```sh
➜ awk 'BEGIN{str="Hello World";printf("len:%d, index:%d, match:%d\n",length(str),index(str,"world"),match(str,/[wW]orld/))}'
len:11, index:0, match:7
```

示例：利用split函数，打印字串数组
```sh
➜ awk 'BEGIN{str="this is a test";split(str,t," ");print length(t);for(k in t){print k,t[k];}}'
4
4 test
1 this
2 is
3 a
```

## 时间函数

| **函数名** | **说明** |
| --- | --- |
| `mktime( YYYY MM DD HH MM SS[ DST])` | 生成时间格式 |
| `strftime([format [, timestamp]])` | 格式化时间输出，将时间戳转为时间字符串具体格式，见下表. |
| `systime()` | 得到时间戳,返回从1970年1月1日开始到当前时间（不计闰年）的整秒数 |

strftime函数format格式化参数转换表

| 格式 | 描述 |
| --- | --- |
| `%a` | 星期几的缩写（Sun） |
| `%A` | 星期几的完整写法（Sunday） |
| `%b` | 月名的缩写（Oct） |
| `%B` | 月名的完整写法（October） |
| `%c` | 本地日期和时间 |
| `%d` | 十进制日期 |
| `%D` | 日期 08/20/99 |
| `%e` | 日期，如果只有一位会补上一个空格 |
| `%H` | 用十进制表示24小时格式的小时 |
| `%I` | 用十进制表示12小时格式的小时 |
| `%j` | 从1月1日起一年中的第几天 |
| `%m` | 十进制表示的月份 |
| `%M` | 十进制表示的分钟 |
| `%p` | 12小时表示法（AM/PM） |
| `%S` | 十进制表示的秒 |
| `%U` | 十进制表示的一年中的第几个星期（星期天作为一个星期的开始） |
| `%w` | 十进制表示的星期几（星期天是0） |
| `%W` | 十进制表示的一年中的第几个星期（星期一作为一个星期的开始） |
| `%x` | 重新设置本地日期（08/20/99） |
| `%X` | 重新设置本地时间（12:00:00） |
| `%y` | 两位数字表示的年（99） |
| `%Y` | 当前月份 |
| `%Z` | 时区（PDT） |
| `%%` | 百分号（%） |

示例：获取当前时间，并格式化输出
```sh
➜ awk 'BEGIN{st=systime();print st, strftime("%c %Z", st)}'
1576744487 2019年12月19日 星期四 16时34分47秒 CST
```

# 进阶
awk可以利用类c风格的代码进行简单的程序编写，使之能完成更多的事情。
## 编程语法
### 条件判断
awk的条件判断格式是类c风格的
```c
if (expression) 
{
    statement;
    ...
}

if (expression) 
{
    statement1;
} 
else 
{
    statement2;
}

if (expression1) 
{
    statement1;
}
else if (expression2) 
{
    statement2;
}
else 
{
    statement3;
}
```

### 循环
awk支持while、for和do-while循环，格式也是类c风格的
```sh
while (expression) 
{
    statement;
}

// for-in 输出的var顺序可能不一致
for (var in array) 
{
    statement;
}
for (var; condtion; expression) 
{
    statement;
}

do 
{
    statement;
} while (expression);
```

同时awk也支持退出循环

| 字段 | 说明 |
| --- | --- |
| break | 当 break 语句用于 while 或 for 语句时，导致退出程序循环。 |
| continue | 当 continue 语句用于 while 或 for 语句时，使程序循环移动到下一个迭代。 |
| next | 能能够导致读入下一个输入行，并返回到脚本的顶部。这可以避免对当前输入行执行其他的操作过程。|
| exit |语句使主输入循环退出并将控制转移到END,如果END存在的话。如果没有定义END规则，或在END中应用exit语句，则终止脚本的执行。|




## 数组
awk数组支持数字下标和字符串下标，底层是哈希表，所以每次遍历不能保证都是相同顺序。
示例：
```sh
array_name[key]=value
```

* array_name：数组的名称
* key：数组索引
* value：数组中元素所赋予的值

### 添加元素
awk可以直接声明元素key-value对
示例：
```sh
➜ awk 'BEGIN{keys[1]=2;keys["start"]="start";print keys[1], keys["start"]}'
2 start
```

### 删除元素
使用delete可以删除数组的元素
示例：删除key为1的值，最后打印keys[1]的值为空字符串
```sh
➜ awk 'BEGIN{keys[1]=2;keys["start"]="start";delete keys[1];print keys[1], keys["start"]}'
 start
```

### 二维数组
awk 多维数组在本质上是一维数组，因awk在存储上并不支持多维数组，awk提供了逻辑上模拟二维数组的访问方式。例如，array[2,3] = 1这样的访问是允许的。
awk使用一个特殊的字符串SUBSEP （`\034`）作为分割字段，在上面的例子 array[2,3] = 1 中，关联数组array存储的键值实际上是2`\034`3，2和3分别为下标（2，3），`\034`为SUBSEP分隔符。
示例：
```sh
➜ awk 'BEGIN{a[1,1]=1;a["1,1"]=2;a[11]=3;for(i in a){print i,a[i]}}'
1,1 2
11 3
11 1
```

### 数组排序
asort对数组array按照首字母进行排序，返回数组长度。如果要得到数组原本顺序，需要使用数组下标依次访问。
for-in 输出关联数组的顺序是无序的，所以通过for-in 得到是无序的数组。如果需要得到有序数组，需要通过下标获得。
示例：
```sh
➜ awk 'BEGIN{str="it is a test";l=split(str,array," ");for(i in array){print i,array[i];};asort(array);for(i in array){print i,array[i;}}'
4 test
1 it
2 is
3 a
4 test
1 a
2 is
3 it
```

## 函数
一个程序包含有多个功能，每个功能我们可以独立一个函数，函数可以提高代码的复用性。用户自定义函数的语法格式为：
```sh
function function_name(argument1, argument2,  ...)
{
  function body 
}
```

**解析：**
*   **function_name** 是用户自定义函数的名称。函数名称应该以字母开头，其后可以是数字、字母或下划线的自由组合。AWK 保留的关键字不能作为用户自定义函数的名称。
*   自定义函数可以接受多个输入参数，这些参数之间通过逗号分隔。参数并不是必须的。我们也可以定义没有任何输入参数的函数。
*   **function body** 是函数体部分，它包含 AWK 程序代码。

示例：写一个求和函数
```sh
➜ awk 'function sum(n1,n2){return n1+n2}BEGIN{print sum(1,2)}'
3
```

如果函数比较复杂，我们可以写成一个文件的形式来执行awk。

```sh
# 返回最小值
function find_min(num1, num2)
{
  if (num1 < num2)
    return num1
  return num2
}

# 返回最大值
function find_max(num1, num2)
{
  if (num1 > num2)
    return num1
  return num2
}

# 主函数
function main(num1, num2)
{
  # 查找最小值
  result = find_min(10, 20)
  print "Minimum =", result

  # 查找最大值
  result = find_max(10, 20)
  print "Maximum =", result
}

# 脚本从这里开始执行
BEGIN {
  main(10, 20)
}
```

执行可以得到
```sh
Minimum = 10
Maximum = 20
```

# 格式化输出

## printf函数

`printf`函数提供了更强大的格式化输出功能，类似于C语言的printf函数。

### 基本格式

```sh
printf(format, expr1, expr2, ...)
```

### 格式化控制符

| 格式符 | 说明 | 示例 |
|--------|------|------|
| `%d` | 十进制有符号整数 | `printf("%d", 123)` → `123` |
| `%u` | 十进制无符号整数 | `printf("%u", 123)` → `123` |
| `%f` | 浮点数（默认6位小数） | `printf("%f", 3.14)` → `3.140000` |
| `%.2f` | 保留2位小数的浮点数 | `printf("%.2f", 3.14159)` → `3.14` |
| `%s` | 字符串 | `printf("%s", "hello")` → `hello` |
| `%c` | 单个字符 | `printf("%c", 65)` → `A` |
| `%e` | 指数形式的浮点数 | `printf("%e", 1000)` → `1.000000e+03` |
| `%x` | 十六进制（小写） | `printf("%x", 255)` → `ff` |
| `%X` | 十六进制（大写） | `printf("%X", 255)` → `FF` |
| `%o` | 八进制 | `printf("%o", 64)` → `100` |
| `%g` | 自动选择合适的表示法 | `printf("%g", 3.14)` → `3.14` |

### 宽度和对齐

```sh
# 指定宽度（右对齐）
➜ awk 'BEGIN{printf("|%10s|\n", "hello")}'
|     hello|

# 左对齐（使用-）
➜ awk 'BEGIN{printf("|%-10s|\n", "hello")}'
|hello     |

# 数字宽度和对齐
➜ awk 'BEGIN{printf("|%10d|\n|%-10d|\n", 123, 123)}'
|       123|
|123       |
```

### 实际示例

```sh
# 格式化输出表格
➜ echo -e "Alice 25 5000\nBob 30 8000\nCharlie 28 6000" | \
  awk '{printf("%-10s %5d %10.2f\n", $1, $2, $3)}'
Alice        25    5000.00
Bob          30    8000.00
Charlie      28    6000.00

# 格式化日期和时间
➜ awk 'BEGIN{printf("日期: %04d-%02d-%02d\n", 2024, 1, 15)}'
日期: 2024-01-15
```

# 常见使用示例

## 文本处理

### 提取特定列

```sh
# 提取第1列和第3列
➜ echo -e "a b c d\ne f g h" | awk '{print $1, $3}'
a c
e g

# 提取最后一列
➜ echo -e "a b c d\ne f g h" | awk '{print $NF}'
d
h

# 提取倒数第二列
➜ echo -e "a b c d\ne f g h" | awk '{print $(NF-1)}'
c
g
```

### 条件筛选

```sh
# 筛选第2列大于10的行
➜ echo -e "a 5 b\na 15 b\na 8 b" | awk '$2 > 10'
a 15 b

# 筛选包含特定字符串的行
➜ echo -e "hello world\ngoodbye world\nhello again" | awk '/hello/'
hello world
hello again

# 多条件筛选
➜ echo -e "a 5 b\na 15 b\na 8 b" | awk '$2 > 10 && $1 == "a"'
a 15 b
```

### 统计计算

```sh
# 计算总和
➜ seq 10 | awk '{sum += $1} END {print sum}'
55

# 计算平均值
➜ seq 10 | awk '{sum += $1; count++} END {print sum/count}'
5.5

# 计算最大值和最小值
➜ seq 10 | awk 'BEGIN{max=0} {if($1>max) max=$1} END{print max}'
10

➜ seq 10 | awk 'BEGIN{min=999} {if($1<min) min=$1} END{print min}'
1
```

## 文件处理

### 处理/etc/passwd

```sh
# 提取用户名（第1列，以:分隔）
➜ awk -F: '{print $1}' /etc/passwd

# 提取UID大于1000的用户
➜ awk -F: '$3 > 1000 {print $1, $3}' /etc/passwd

# 统计用户数量
➜ awk -F: 'END {print NR}' /etc/passwd
```

### 处理日志文件

```sh
# 统计访问次数最多的IP
➜ awk '{ip[$1]++} END {for(i in ip) print ip[i], i}' access.log | sort -rn | head -10

# 统计HTTP状态码
➜ awk '{status[$9]++} END {for(s in status) print s, status[s]}' access.log

# 提取特定时间段的日志
➜ awk '/2024-01-15 10:/ && /2024-01-15 11:/' access.log
```

### 处理CSV文件

```sh
# 处理逗号分隔的文件
➜ awk -F, '{print $1, $3}' data.csv

# 处理包含引号的CSV
➜ awk -F'","' '{gsub(/"/, ""); print $1, $2}' data.csv
```

## 数据转换

### 字符串替换

```sh
# 替换字符串
➜ echo "hello world" | awk '{gsub(/world/, "awk"); print}'
hello awk

# 替换第一个匹配
➜ echo "hello world world" | awk '{sub(/world/, "awk"); print}'
hello awk world

# 替换特定列
➜ echo "a b c" | awk '{gsub(/b/, "B", $2); print}'
a B c
```

### 大小写转换

```sh
# 转换为小写
➜ echo "HELLO WORLD" | awk '{print tolower($0)}'
hello world

# 转换为大写
➜ echo "hello world" | awk '{print toupper($0)}'
HELLO WORLD

# 首字母大写
➜ echo "hello world" | awk '{print toupper(substr($1,1,1)) substr($1,2)}'
Hello
```

## 数组应用

### 统计词频

```sh
# 统计每列出现的次数
➜ echo -e "a b a c b a" | awk '{for(i=1;i<=NF;i++) count[$i]++} END {for(word in count) print word, count[word]}'
a 3
b 2
c 1
```

### 去重

```sh
# 基于第一列去重
➜ echo -e "a 1\na 2\nb 3\nb 4" | awk '!seen[$1]++'
a 1
b 3
```

### 分组统计

```sh
# 按第一列分组求和
➜ echo -e "a 10\na 20\nb 30\nb 40" | awk '{sum[$1] += $2} END {for(k in sum) print k, sum[k]}'
a 30
b 70
```

# 实际应用场景

## 系统监控

### 进程监控

```sh
# 统计各用户进程数
➜ ps aux | awk 'NR>1 {user[$1]++} END {for(u in user) print u, user[u]}'

# 统计进程CPU使用率
➜ ps aux | awk 'NR>1 {cpu += $3} END {print "Total CPU:", cpu"%"}'

# 查找占用内存最多的进程
➜ ps aux | sort -k4 -rn | awk 'NR==2 {print $11, $4"%"}'
```

### 磁盘使用

```sh
# 统计磁盘使用情况
➜ df -h | awk 'NR>1 {gsub(/%/, "", $5); if($5 > 80) print $1, $5"%"}'

# 计算总使用空间
➜ df | awk 'NR>1 {sum += $3} END {print sum/1024/1024 "GB"}'
```

## 日志分析

### Web服务器日志

```sh
# 统计访问量前10的页面
➜ awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -10

# 统计每小时访问量
➜ awk '{split($4, a, ":"); hour=a[2]; count[hour]++} END {for(h in count) print h":00", count[h]}' access.log

# 统计响应时间分布
➜ awk '{time=int($NF/1000); if(time<1) range="<1s"; else if(time<5) range="1-5s"; else range=">5s"; count[range]++} END {for(r in count) print r, count[r]}' access.log
```

### 系统日志

```sh
# 统计错误日志
➜ awk '/ERROR/ {error++} /WARN/ {warn++} END {print "ERROR:", error, "WARN:", warn}' system.log

# 提取特定时间段的日志
➜ awk '/2024-01-15 10:/, /2024-01-15 11:/' system.log
```

## 数据处理

### 数据清洗

```sh
# 删除空行
➜ awk 'NF > 0' file.txt

# 删除重复行
➜ awk '!seen[$0]++' file.txt

# 删除包含特定字符串的行
➜ awk '!/pattern/' file.txt
```

### 数据转换

```sh
# 将空格分隔转换为逗号分隔
➜ echo "a b c d" | awk '{for(i=1;i<=NF;i++) {if(i>1) printf ","; printf $i} print ""}'
a,b,c,d

# 添加行号
➜ awk '{print NR, $0}' file.txt

# 添加文件名
➜ awk '{print FILENAME, $0}' file.txt
```

## 报表生成

```sh
# 生成简单报表
➜ cat data.txt | awk '
BEGIN {
    print "=== 销售报表 ==="
    print "产品\t数量\t金额"
    print "-------------------"
}
{
    product[$1] += $2
    amount[$1] += $3
}
END {
    for(p in product) {
        printf "%-10s %5d %10.2f\n", p, product[p], amount[p]
    }
    print "-------------------"
}'
```

# 与其他命令的组合

## awk + grep

```sh
# 先grep过滤，再awk处理
➜ grep "ERROR" log.txt | awk '{print $1, $NF}'

# awk处理后再grep
➜ awk '{print $1, $3}' data.txt | grep "pattern"
```

## awk + sort

```sh
# awk处理后排序
➜ awk '{print $2, $1}' data.txt | sort -k1

# 统计后排序
➜ awk '{count[$1]++} END {for(k in count) print count[k], k}' | sort -rn
```

## awk + sed

```sh
# 先用sed替换，再用awk处理
➜ sed 's/old/new/g' file.txt | awk '{print $1}'

# awk处理后再sed替换
➜ awk '{print $1}' file.txt | sed 's/pattern/replacement/'
```

## awk + xargs

```sh
# awk提取文件名，xargs执行命令
➜ awk '{print $NF}' filelist.txt | xargs ls -l

# 处理包含空格的文件名
➜ awk '{print $NF}' filelist.txt | xargs -I {} ls -l {}
```

## awk + find

```sh
# find查找文件，awk处理文件名
➜ find . -name "*.log" | awk -F/ '{print $NF}'

# find查找并awk统计
➜ find . -type f | awk -F. '{ext[$NF]++} END {for(e in ext) print e, ext[e]}'
```

# 高级技巧

## 多文件处理

```sh
# 处理多个文件，分别统计
➜ awk '{count[FILENAME]++} END {for(f in count) print f, count[f]}' file1.txt file2.txt

# 处理多个文件，统一统计
➜ awk '{total++} END {print total}' file1.txt file2.txt
```

## 自定义分隔符

```sh
# 使用多个字符作为分隔符
➜ echo "a::b::c" | awk -F'::' '{print $1, $2, $3}'
a b c

# 使用正则表达式作为分隔符
➜ echo "a123b456c" | awk -F'[0-9]+' '{print $1, $2, $3}'
a b c
```

## 处理特殊字符

```sh
# 处理包含特殊字符的字段
➜ echo 'a "b c" d' | awk -F'"' '{print $1, $2, $3}'
a  b c  d

# 处理制表符分隔的文件
➜ awk -F'\t' '{print $1, $2}' file.tsv
```

## 性能优化

```sh
# 使用next跳过不需要处理的行
➜ awk '/^#/ {next} {print}' file.txt

# 使用exit提前退出
➜ awk '/pattern/ {print; exit}' file.txt

# 使用数组索引优化查找
➜ awk 'BEGIN {arr["key"]=1} $1 in arr {print}' file.txt
```

## 错误处理

```sh
# 检查文件是否存在
➜ awk 'BEGIN {
    if ((getline < "file.txt") < 0) {
        print "File not found" > "/dev/stderr"
        exit 1
    }
    close("file.txt")
}'

# 处理除零错误
➜ awk '{if($2 != 0) print $1/$2; else print "Division by zero"}' data.txt
```

# 常见问题与技巧

## 字段引用

```sh
# 动态引用字段
➜ awk '{n=2; print $n}' file.txt  # 打印第2列

# 使用变量作为字段索引
➜ awk '{col=NF; print $col}' file.txt  # 打印最后一列
```

## 字符串连接

```sh
# 字符串连接（空格或直接连接）
➜ awk '{print $1 $2}' file.txt      # 直接连接
➜ awk '{print $1, $2}' file.txt     # 用OFS分隔（默认空格）
➜ awk '{print $1 "_" $2}' file.txt  # 自定义分隔符
```

## 数值比较陷阱

```sh
# 字符串比较 vs 数值比较
➜ echo "10" | awk '{if($1 > 9) print "OK"}'      # 字符串比较，可能出错
➜ echo "10" | awk '{if($1+0 > 9) print "OK"}'    # 数值比较，正确
➜ echo "10" | awk '{if(int($1) > 9) print "OK"}' # 数值比较，正确
```

## 数组遍历顺序

```sh
# for...in 遍历顺序不确定
➜ awk 'BEGIN{a[1]=1;a[2]=2;a[3]=3; for(i in a) print i, a[i]}'
# 输出顺序可能不是 1,2,3

# 使用数字索引保证顺序
➜ awk 'BEGIN{a[1]=1;a[2]=2;a[3]=3; for(i=1;i<=3;i++) print i, a[i]}'
1 1
2 2
3 3
```

## 处理大文件

```sh
# 使用next跳过不需要的行
➜ awk '/^#/ {next} {process}' large_file.txt

# 使用exit提前退出
➜ awk '/pattern/ {print; exit}' large_file.txt

# 分批处理
➜ awk 'NR%1000==0 {print NR " lines processed"}' large_file.txt
```

## 调试技巧

```sh
# 打印调试信息
➜ awk '{print "DEBUG: processing line", NR, $0}' file.txt

# 使用-v传入调试标志
➜ awk -v debug=1 '{if(debug) print "Processing:", $0}' file.txt

# 检查字段数量
➜ awk 'NF != 3 {print "Line", NR, "has", NF, "fields:", $0}' file.txt
```

# 实用脚本示例

## 统计脚本

```sh
#!/usr/bin/awk -f
# 统计脚本：计算总和、平均值、最大值、最小值

BEGIN {
    sum = 0
    count = 0
    max = -999999
    min = 999999
}

{
    if ($1+0 == $1) {  # 检查是否为数字
        sum += $1
        count++
        if ($1 > max) max = $1
        if ($1 < min) min = $1
    }
}

END {
    if (count > 0) {
        printf "统计结果:\n"
        printf "  总和: %d\n", sum
        printf "  平均值: %.2f\n", sum/count
        printf "  最大值: %d\n", max
        printf "  最小值: %d\n", min
        printf "  数量: %d\n", count
    }
}
```

## 日志分析脚本

```sh
#!/usr/bin/awk -f
# 分析访问日志，统计IP访问次数

{
    ip = $1
    ip_count[ip]++
}

END {
    print "IP访问统计:"
    print "============"
    for (ip in ip_count) {
        printf "%-15s %d次\n", ip, ip_count[ip]
    }
}
```

## 数据转换脚本

```sh
#!/usr/bin/awk -f
# 将空格分隔转换为CSV格式

BEGIN {
    OFS = ","
}

{
    # 处理包含逗号的字段
    for (i = 1; i <= NF; i++) {
        if ($i ~ /,/) {
            $i = "\"" $i "\""
        }
    }
    print
}
```

# 注意事项

1. **字段分隔符**：默认FS是空格和Tab，使用`-F`可以自定义分隔符
2. **数值比较**：字符串"10"可能小于"9"（字符串比较），使用`$1+0`或`int($1)`转换为数值
3. **数组遍历**：`for...in`遍历关联数组的顺序是不确定的，需要顺序时使用数字索引
4. **变量作用域**：在BEGIN中定义的变量在整个脚本中可用
5. **性能考虑**：处理大文件时，使用`next`跳过不需要的行可以提高性能
6. **正则表达式**：awk使用扩展正则表达式，某些特殊字符需要转义
7. **多行记录**：默认RS是换行符，可以通过修改RS处理多行记录

# 参考文献
* [维基百科](https://zh.wikipedia.org/wiki/AWK)
* [菜鸟教程](https://www.runoob.com/linux/linux-comm-awk.html)
* [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/)
* [AWK程序设计语言](https://book.douban.com/subject/1236994/)
