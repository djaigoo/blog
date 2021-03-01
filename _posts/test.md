---
title: test
tags:
  - null
categories:
  - null
mathjax: true
date: 2019-01-31 15:49:44
---

# 计算垃圾弹幕比例

```flow
st=>start: 开始
e=>end: 结束
date=>inputoutput: 输入日期
proportion=>inputoutput: 输出比例
normal=>subroutine: 计算正常弹幕数
garbage=>subroutine: 计算垃圾弹幕数
op=>subroutine: 计算比例

st->date
date->normal->garbage->op->e
```

# 子任务
## 计算正常弹幕数
```flow
st=>start: 开始
e=>end: 结束
date=>inputoutput: 输入日期
get=>operation: 通过数据库获取指定日期数据条数
out=>inputoutput: 输出指定日期弹幕条数

st->date->get->out->e
```

## 计算垃圾弹幕数
```flow
st=>start: 开始
e=>end: 结束
date=>inputoutput: 输入日期
get=>operation: 通过数据库获取指定日期数据条数
out=>inputoutput: 输出指定日期弹幕条数

st->date->get->out->e
```

## 计算比例
```flow
st=>start: 开始
e=>end: 结束
nor=>inputoutput: 输入正常弹幕条数
gar=>inputoutput: 输入垃圾弹幕条数
cul=>operation: 使用计算公式计算比例

st->nor->gar->cul->e
```

其中计算公式为：$比例 = \frac{垃圾弹幕}{垃圾弹幕+正常弹幕}$



