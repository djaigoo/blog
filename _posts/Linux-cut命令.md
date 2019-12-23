---
author: djaigo
title: Linux cut命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - cmd
  - command
date: 2019-12-20 16:22:37
---

在linux中，cut常用修剪出指定位置的数据，cut是按行为单位进行裁剪。
它有三个裁剪模式：
```text
用法：cut [选项]... [文件]...
  -b, --bytes=列表		只选中指定的这些字节
  -c, --characters=列表	只选中指定的这些字符
  -d, --delimiter=分界符	使用指定分界符代替制表符作为区域分界
  -f, --fields=LIST       select only these fields;  also print any line
                            that contains no delimiter character, unless
                            the -s option is specified
  -n                      with -b: don't split multibyte characters
      --complement		补全选中的字节、字符或域
  -s, --only-delimited		不打印没有包含分界符的行
      --output-delimiter=字符串	使用指定的字符串作为输出分界符，默认采用输入
				的分界符
      --help		显示此帮助信息并退出
      --version		显示版本信息并退出

仅使用 -b, -c 或-f 中的一个。每一个列表都是专门为一个类别作出的，或者您可以用逗号隔
开要同时显示的不同类别。您的输入顺序将作为读取顺序，每个仅能输入一次。
每种参数格式表示范围如下：
    N	第N 个字节、字符或域
    N-	从第N 个开始到所在行结束的所有字符、字节或域
    N-M	从第N 个开始到第M 个之间(包括第M 个)的所有字符、字节或域
    -M	从第1 个开始到第M 个之间(包括第M 个)的所有字符、字节或域

当没有文件参数，或者文件不存在时，从标准输入读取      
```

常用选项：
* b，按照字节长度裁剪，-n表示
* c，按照字符长度来裁剪
* d，表示自定义分隔符，默认为制表符
* f，按照域长度来裁剪，-s表示

示例：
```sh
➜ echo "你好:哈哈" | cut -b 1-3
你

➜ echo "你好:哈哈" | cut -c 1-2
你好

➜ echo "你好:哈哈" | cut -d: -f 1-1
你好
```

complement表示反选。
示例：
```sh
➜ echo "12 34 56 67" | cut -b 1,4
13

➜ echo "12 34 56 67" | cut -b 1,4 --complement
2 4 56 67

➜ echo "12 34 56 67" | cut -b 1-4 --complement
4 56 67
```

output-delimiter表示设置输出的分隔符。
示例：
```sh
➜ echo "你好:哈哈:hello" | cut -d: -f 1-2 --output-delimiter=!
你好!哈哈
```
