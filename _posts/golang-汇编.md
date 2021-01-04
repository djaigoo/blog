---
author: djaigo
title: golang-汇编
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - asm
  - 汇编
date: 2021-01-04 16:21:47
---

`golang`汇编使用的是plan9汇编，这相当于是一个帮助文档，帮助理解`golang`底层汇编代码的实现。
由于汇编不具备跨平台，所以这里使用的是`linux amd64`平台。

# 寄存器
## 通用寄存器
## 伪寄存器

# 数据
## 变量声明
## 变量寻址
## 函数声明
## 标签声明


# 函数栈帧

# 常见指令
与数据相关的指令结尾会跟上`BWDQ`，分别表示操作字节数`1248`，常见的`MOVQ`、`ADDQ`等都是对8字节数进行操作。下面指令皆以`Q`结尾即8字节操作数。
```asm
MOVB $1, DI      // 1 byte
MOVW $0x10, BX   // 2 bytes
MOVD $1, DX      // 4 bytes
MOVQ $-10, AX    // 8 bytes
```

## 栈操作
由于golang栈帧是固定大小，没有提供压栈弹栈操作，但这些操作可以通过伪指针加偏移量来模拟。
## 移动操作
```asm
MOVQ BX, AX    // AX = BX
```

## 运算操作
### 数值运算
* ADDQ，加法运算
* SUBQ，减法运算
* IMULQ，乘法运算

示例：
```asm
ADDQ  AX, BX   // BX += AX
SUBQ  AX, BX   // BX -= AX
IMULQ AX, BX   // BX *= AX
```

### 逻辑运算
* ANDQ，
* ORQ，

### 移位运算

## 条件操作
条件操作即为处理当前操作并设置标志寄存器相关标志位的值，常见的标志位有：
* `CF (Carry Flag)`，进位标志位，运算过程是否产生进位或借位
* `PF (Parity Flag)`，奇偶标志位，运算结果中1的个数是奇数还是偶数
* `ZF (Zero Flag)`，零标志位，运算结果是否为0
* `SF (Sign Flag)`，符号标志位，运算结果的最高位
* `OF (Overflow Flag)`，溢出标志位，运算结果超过运算数表示范围

条件指令：
* TESTQ，源操作数和目标操作数按位逻辑与，目标操作数不置为结果，根据响应的结果设置`SF`、`ZF`、和`PF`标志位，并将`CF`和`OF`标志位清零。常见`TESTQ AX AX`配合`ZF`即可得出`AX`是否为0。
* CMP，前操作数减去后操作数，根据结果设置标志寄存器标志位。
  - 等于，ZF为1
  - 不等于，ZF为0
  - 小于，CF为1
  - 小于等于，CF为1或ZF为1
  - 大于等于，CF为0
  - 大于，CF为0并且ZF为0

## 跳转操作
跳转操作即为检测相关的标志位，进而处理逻辑。

* `JMP (JuMP)`，无条件跳转，可以跳转标签，跳转函数，跳过指定个数的指令。
例如，如果是`2(PC)`则是跳过下面两条指令，也可以为负数`-2(PC)`向上跳2个指令
```asm
JMP 2(PC)  // ---
NOP        //   |
NOP        // <--

NOP        // <--
NOP        //   |
JMP -2(PC) // ---
```

* `JA (Jump if Above)`，无符号大于就跳转
* `JAE (Jump if Above or Equal)`，无符号大于等于就跳转
* `JB (Jump if Below)`，无符号小于就跳转
* `JBE (Jump if Below or Equal)`，无符号小于等于就跳转
* `JC (Jump if Carry)`，如果有进位就跳转
* `JNC (Jump if No Carry)`，没有进位就跳转
* `JE (Jump if Equal)`，相等就跳转
* `JNE (Jump if Not Equal)`，不等就跳转
* `JL (Jump if Less)`，有符号小于就跳转
* `JLE (Jump if Less or Equal)`，有符号小于等于就跳转
* `JG (Jump if Greater)`，有符号大于就跳转
* `JGE (Jump if Greater or Equal)`，有符号大于等于就跳转
* `JHI (Jump if HIgher)`，无符号大于就跳转
* `JHS (Jump if Higher or Same)`，无符号大于就跳转或等于就跳转，同`JC`
* `JLO (Jump if LOwer)`，无符号小于就跳转，同`JNC`
* `JLS (Jump if Lower or Same)`，无符号小于或等于就跳转
* `JN (Jump if Negative)`，为负就跳转
* `JZ (Jump if equal to Zero)`，等于零值就跳转
* `JNZ (Jump if Not equal to Zero)`，不等于零值就跳转


## 其他操作
* LEAQ，解引用
* CALL，调用函数，也可以理解为跳转到函数
* RET，退出函数
* NOP，空操作

# 反汇编

# 参考文献
[Go 系列文章3 ：plan9 汇编入门](https://xargin.com/plan9-assembly/)
[状态标志寄存器](https://baike.baidu.com/item/FLAG/6050220)