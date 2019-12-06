---
title: yaml教程
tags:
  - 基础
categories:
  - yaml
draft: true
date: 2018-08-07 14:27:55
---
本文介绍yaml基础教程
<!--more-->
# yaml简介
yaml方便人们读写的数据串行化格式语言。
基本语法：
* 大小写敏感
* 使用缩进表示层级关系
* 缩进不允许使用tab，只允许空格
* 缩进的空格数不重要，只要相同层级的元素左对齐即可
* ‘#’表示注释

yaml支持的数据类型：
* 对象，键值对的集合，
* 数组，一组按次序排列的值
* 纯量，单个不可再分的值

## yaml对象
对象键值对使用冒号结构表示`key:value`，也可以使用`key:{key1: value1, key2: value2, ...}`
## yaml数组
以‘-’开头的行表示构成一个数组
```yaml
- A
- B
- C
```
yaml支持多为数组，可以使用行内表示：`key: [value1, value2, ...]`
## 复合结构
数组和对象可以构成复合结构，例：
```yaml
languages:
  - Ruby
  - Perl
  - Python 
websites:
  YAML: yaml.org 
  Ruby: ruby-lang.org 
  Python: python.org 
  Perl: use.perl.org 
```
转换为json为：
```json
{ 
  languages: [ 'Ruby', 'Perl', 'Python'],
  websites: {
    YAML: 'yaml.org',
    Ruby: 'ruby-lang.org',
    Python: 'python.org',
    Perl: 'use.perl.org' 
  } 
}
```
## 纯量
纯量是最基本的，不可再分的值，包括：
*   字符串
*   布尔值
*   整数
*   浮点数
*   Null
*   时间
*   日期

## 引用
&锚点和*别名，可以用来引用
```yaml
defaults: &defaults
  adapter:  postgres
  host:     localhost

development:
  database: myapp_development
  <<: *defaults

test:
  database: myapp_test
  <<: *defaults
```
相当于
```yaml
defaults:
  adapter:  postgres
  host:     localhost

development:
  database: myapp_development
  adapter:  postgres
  host:     localhost

test:
  database: myapp_test
  adapter:  postgres
  host:     localhost
```

