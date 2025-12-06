---
author: djaigo
title: linux-xargs命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
date: 2025-02-11 18:18:17
---
# xargs命令

xargs用于构造参数列表并运行命令。

## 常用选项
`-I`：标准输入的每一行作为 _Command_ 参数的自变量，将它插入每个发生 _ReplaceString_ 的 _Argument_ 中。
```sh
➜ seq 10 |xargs -I {} echo 'a{}b'                                               
a1b
a2b
a3b
a4b
a5b
a6b
a7b
a8b
a9b
a10b
```

`-L`：从标准输入读取的指定行数的非空参数运行 _Command_ 命令。指定行数变一行。
```sh
➜ seq 10 |xargs -L 2                                                              
1 2
3 4
5 6
7 8
9 10
```

`-n`：运行 _Command_ 参数，且使用尽可能多的标准输入自变量，直到 _Number_ 参数指定的最大值。指定最大列数。
```sh
➜ seq 10 |xargs -n 4                                                              
1 2 3 4
5 6 7 8
9 10
```


`-p`：询问是否运行 _Command_ 参数。 它显示构造的命令行，后跟?...提示。输入y表示执行，输入其他表示不执行。
```sh
➜ seq 2 | xargs -p -I {} echo 'a{}b'                                              
echo a1b?...y
a1b
echo a2b?...n
```


> **注意：** **-I**（大写 i）、**i**、**-L**（大写 l）、**l** 和 **-n** 标志是相互排斥的。 最后指定的标志生效。