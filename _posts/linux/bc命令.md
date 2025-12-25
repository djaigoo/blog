---
author: djaigo
title: linux-bc命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - shell
---
# bc命令

## 简介

bc（Basic Calculator）是一个任意精度十进制算术语言和计算器。
可以交互式操作也可以使用标准输入。

## 命令语法

```bash
bc [选项] [文件...]
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-i, --interactive` | 强制交互模式 |
| `-l, --mathlib` | 使用标准数学库（启用扩展函数） |
| `-w, --warn` | 对POSIX bc的扩展给出警告 |
| `-s, --standard` | 严格遵循POSIX bc标准 |
| `-q, --quiet` | 不显示欢迎信息 |
| `-v, --version` | 显示版本信息 |

## 基本使用

### 交互式使用

```bash
bc
```

进入交互模式后，可以直接输入表达式进行计算：

```bc
1 + 1
2
2 * 3
6
10 / 3
3
scale=2
10 / 3
3.33
quit
```

### 非交互式使用

通过管道或文件输入：

```bash
# 通过管道
echo "1 + 1" | bc
# 输出: 2

# 通过文件
bc < calc.bc

# 一行计算
echo "scale=2; 10/3" | bc
# 输出: 3.33
```

### 使用数学库

```bash
bc -l
# 或
echo "s(1)" | bc -l  # 计算sin(1)
```

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

## 变量

### 全局变量

| 变量 | 说明 | 默认值 | 范围 |
|------|------|--------|------|
| `ibase` | 输入数进制 | 10 | 2 到 `maxibase()` |
| `obase` | 输出数进制 | 10 | 0 到 `maxobase()`，0表示科学计数法，1表示工程计数法 |
| `scale` | 小数点后的位数（小数精度） | 0 | 0 到 `maxscale()`，不能为负数 |
| `seed` | 随机数种子 | - | - |

### 使用示例

```bc
# 设置输入为16进制
ibase=16
FF
255

# 设置输出为2进制
obase=2
255
11111111

# 设置小数精度
scale=3
10/3
3.333

# 恢复默认
ibase=10
obase=10
```

### 普通变量

bc支持单字母变量（a-z，A-Z）：

```bc
a=10
b=20
a+b
30
a*b
200
```

### 数组

bc支持一维数组，使用方括号访问：

```bc
a[0]=10
a[1]=20
a[2]=30
a[0]+a[1]
30
```

## 常用函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `abs(x)` | 绝对值 | `abs(-5)` → `5` |
| `sqrt(x)` | 开平方根 | `sqrt(16)` → `4` |
| `length(x)` | 数字长度（包括整数和小数位数） | `length(123.45)` → `5` |
| `scale(x)` | 小数位数 | `scale(123.45)` → `2` |

### 使用示例

```bc
abs(-10)
10
sqrt(16)
4
length(12345)
5
scale(123.45)
2
```

## 扩展函数

使用扩展函数需要加参数 `-l`（加载数学库）

| 函数 | 说明 | 示例 |
|------|------|------|
| `s(x)` | sin(x)，x为弧度 | `s(1)` → `0.8414709848` |
| `c(x)` | cos(x)，x为弧度 | `c(0)` → `1.0000000000` |
| `a(x)` | arctan(x)，返回弧度 | `a(1)` → `0.7853981634` |
| `l(x)` | ln(x)，自然对数 | `l(2)` → `0.6931471806` |
| `e(x)` | e的x次方 | `e(1)` → `2.7182818285` |
| `j(n,x)` | 第一类贝塞尔函数 | - |
| `p(x,y)` | x的y次方，y可以是非整数 | `p(2,3)` → `8` |
| `ceil(x)` | 向上取整 | `ceil(3.2)` → `4` |
| `floor(x)` | 向下取整 | `floor(3.8)` → `3` |
| `ceil(x,y)` | 向上取舍到y位小数 | `ceil(3.256, 1)` → `3.3` |
| `f(x)` | x取整的阶乘 | `f(5)` → `120` |
| `gcd(x,y)` | x和y的最大公约数 | `gcd(12,18)` → `6` |
| `lcm(x,y)` | x和y的最小公倍数 | `lcm(12,18)` → `36` |
| `pi(x)` | 返回π到x个小数位 | `pi(5)` → `3.14159` |
| `output(x, b)` | 将x转为b进制 | `output(255,16)` → `FF` |

### 使用示例

```bash
# 计算sin(1)
echo "s(1)" | bc -l
# 输出: .8414709848

# 计算2的3次方
echo "p(2,3)" | bc -l
# 输出: 8

# 计算5的阶乘
echo "f(5)" | bc -l
# 输出: 120

# 计算最大公约数
echo "gcd(12,18)" | bc -l
# 输出: 6

# 计算最小公倍数
echo "lcm(12,18)" | bc -l
# 输出: 36

# 获取π的值（5位小数）
echo "scale=5; pi(5)" | bc -l
# 输出: 3.14159
```

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

#### 比较两个数的大小

```bc
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

#### 计算斐波那契数列

```bc
define fib(n){
    if(n<=1) return n;
    return fib(n-1) + fib(n-2);
}

fib(10)
55
```

#### 计算阶乘

```bc
define fact(n){
    if(n<=1) return 1;
    return n * fact(n-1);
}

fact(5)
120
```

#### 计算平方和

```bc
define sum_squares(n){
    auto sum, i;
    sum = 0;
    for(i=1; i<=n; i++){
        sum = sum + i*i;
    }
    return sum;
}

sum_squares(5)
55
```

## 实际应用场景

### 1. Shell脚本中的数值计算

```bash
#!/bin/bash
# 计算两个数的和
result=$(echo "10 + 20" | bc)
echo "结果: $result"

# 计算带小数的除法
result=$(echo "scale=2; 10/3" | bc)
echo "结果: $result"
```

### 2. 进制转换

```bash
# 十进制转二进制
echo "obase=2; 255" | bc
# 输出: 11111111

# 十进制转十六进制
echo "obase=16; 255" | bc
# 输出: FF

# 十六进制转十进制
echo "ibase=16; FF" | bc
# 输出: 255

# 十六进制转二进制
echo "ibase=16; obase=2; FF" | bc
# 输出: 11111111
```

### 3. 文件大小计算

```bash
# 计算文件总大小（MB）
total=$(du -sm * | awk '{sum+=$1} END {print sum}')
echo "总大小: ${total}MB"

# 转换为GB
gb=$(echo "scale=2; $total/1024" | bc)
echo "总大小: ${gb}GB"
```

### 4. 百分比计算

```bash
# 计算百分比
used=75
total=100
percent=$(echo "scale=2; $used*100/$total" | bc)
echo "使用率: ${percent}%"
```

### 5. 数学运算

```bash
# 计算圆的面积
radius=5
area=$(echo "scale=2; 3.14159 * $radius * $radius" | bc)
echo "圆的面积: $area"

# 使用数学库计算sin值
angle=1
sin_value=$(echo "s($angle)" | bc -l)
echo "sin($angle) = $sin_value"
```

### 6. 批量计算

创建计算文件 `calc.bc`：

```bc
scale=2
a=10
b=20
c=30
sum=a+b+c
avg=sum/3
print "总和: ", sum, "\n"
print "平均值: ", avg, "\n"
```

执行：

```bash
bc calc.bc
```

### 7. 条件计算

```bash
# 在脚本中使用条件判断
value=15
result=$(echo "
if ($value > 10) {
    100
} else {
    50
}
" | bc)
echo "结果: $result"
```

### 8. 循环计算

```bash
# 计算1到10的和
echo "
sum=0
for(i=1; i<=10; i++){
    sum=sum+i
}
sum
" | bc
# 输出: 55
```

## 注意事项

1. **ibase和obase的设置顺序**：设置`ibase`和`obase`时要注意顺序，因为`ibase`改变后，后续的数字会被按新进制解析。

```bc
# 错误示例
ibase=16
obase=10  # 这里的10会被解析为16进制的10，即十进制的16
255
# 输出: FF（错误）

# 正确示例
obase=10
ibase=16
FF
# 输出: 255（正确）
```

2. **scale的影响**：`scale`只影响除法和某些函数的结果，不影响加、减、乘。

```bc
scale=2
10/3
3.33
10*3
30  # 不是30.00
```

3. **变量作用域**：函数内的`auto`变量是局部变量，函数外的变量是全局变量。

```bc
x=10
define test(){
    auto x;
    x=20;
    return x;
}
test()
20
x
10  # 全局变量x未改变
```

4. **精度限制**：虽然bc支持任意精度，但实际精度受系统资源限制，可通过`limits`命令查看。

```bc
limits
BC_BASE_MAX     = 2147483647
BC_DIM_MAX      = 65535
BC_SCALE_MAX    = 2147483647
BC_STRING_MAX   = 2147483647
MAX_EXP         = 2147483647
MIN_EXP         = -2147483648
NUMBER_BASE     = 10
```
