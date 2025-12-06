---
author: djaigo
title: linux-bc命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
date: 2025-02-11 18:18:17
---
# bc命令


bc任意精度十进制算术语言和计算器。
可以交互式操作也可以使用标准输入。

## 数字表达
数字是由数字、大写字母和最多 1 个小数点组成的字符串。 大写字母等于 9 加上它们在字母表中的位置，从 1 开始（即 A 等于 10 或 9+1）。

## 基础运算
```bc
#关系运算
||, &&, !, =, ==

#基础数学运算
+, -, *, /, %, ^,

#自增自减
++, --

#逻辑运算
<, >, <=, >=, !=
```

## 全局变量
ibase，表示输入数进制，最小为2，最大为`maxibase()`，默认是10
obase，表示输出数进制，最小为0，最大为`maxobase()`，默认是10，0表示使用科学计数法，1表示工程计数法
scale，表示小数点后的位数，即小数精度，默认是0，且不能为负数。最大为`maxscale()`。
seed，表示随机数种子。

## 常用函数
abs()：绝对值
sqrt()：开方
length()：数字长度，包括整数和小数位数
scale()：小数位数

## 扩展函数
使用扩展函数需要加参数 `-l`
p(x,y)：x的y次方，y可以是非整数
ceil(x,y)：向上取舍，y表示小数位数
f(x)：x取整的阶乘
gcd(x,y)：xy的最大公约数
lcm(x,y)：xy的最小公倍数
pi(x)：返回π到x个小数位
output(x, b)：将x转为 b 进制

## 自定义函数
### 语法类似于c语言。
E：数字或字符串
{ S ; ...  ; S }：多条语句
if ( E ) S：判断
if ( E ) S else S：判断否则
while ( E ) S：while循环
for ( E ; E ; E ) S：for循环

### 关键字
break：退出循环
continue：继续循环
quit：交互式退出bc
halt：脚本终止bc程序
limits：交互式中返回各类限制信息

### 输出字符串
print E , ...  , E
stream E , ...  , E

### 示例
```bc
# 比较传入传入参数大小
define cmp(a,b){
    if(a>b) return 1;
    if(a==b) return 0;
    return -1;
}

cmp(1,2)
-1
cmp(1,1)
0
cmp(2,1)
1
```
