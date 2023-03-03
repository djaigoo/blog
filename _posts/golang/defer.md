---
author: djaigo
title: golang-defer
tags:
categories:
  - golang
date: 2022-11-28 16:34:29
---

defer结构
defer池
defer注册
  需要来回拷贝参数
defer执行

单defer
多defer
  defer嵌套

循环defer无法优化
将部分defer信息存在栈帧
开放代码
  不创建defer结构体
  栈扫描 找到未注册的defer进行执行
