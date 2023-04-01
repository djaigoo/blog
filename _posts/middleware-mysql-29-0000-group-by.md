---
author: djaigo
title: middleware-mysql-28-0000-group-by
categories:
  - null
date: 2023-03-29 19:50:32
tags:
---

# distinct 和 group by 的性能

在第 37 篇文章[《什么时候会使用内部临时表？》](https://time.geekbang.org/column/article/80477)中，@老杨同志 提了一个好问题：如果只需要去重，不需要执行聚合函数，distinct 和 group by 哪种效率高一些呢？

我来展开一下他的问题：如果表 t 的字段 a 上没有索引，那么下面这两条语句：

```
select a from t group by a order by null;select distinct a from t;
```

的性能是不是相同的?

首先需要说明的是，这种 group by 的写法，并不是 SQL 标准的写法。标准的 group by 语句，是需要在 select 部分加一个聚合函数，比如：

```
select a,count(*) from t group by a order by null;
```

这条语句的逻辑是：按照字段 a 分组，计算每组的 a 出现的次数。在这个结果里，由于做的是聚合计算，相同的 a 只出现一次。

> 备注：这里你可以顺便复习一下[第 37 篇文章](https://time.geekbang.org/column/article/80477)中关于 group by 的相关内容。

没有了 count(*) 以后，也就是不再需要执行“计算总数”的逻辑时，第一条语句的逻辑就变成是：按照字段 a 做分组，相同的 a 的值只返回一行。而这就是 distinct 的语义，所以不需要执行聚合函数时，distinct 和 group by 这两条语句的语义和执行流程是相同的，因此执行性能也相同。

这两条语句的执行流程是下面这样的。

1.  创建一个临时表，临时表有一个字段 a，并且在这个字段 a 上创建一个唯一索引；

2.  遍历表 t，依次取数据插入临时表中：

    *   如果发现唯一键冲突，就跳过；
    *   否则插入成功；
3.  遍历完成后，将临时表作为结果集返回给客户端。
