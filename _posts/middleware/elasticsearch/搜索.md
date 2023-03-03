---
title: elasticsearch搜索
tags:
  - elastic
  - search
categories:
  - tech
date: 2019-03-04 14:33:49
---

Elasticsearch强大之处在于可以从混乱的数据中找出有意义的信息——从大数据到全面的信息。Elasticsearch不只会**存储(store)**文档，也会**索引(indexes)**文档内容来使之可以被搜索。
**每个文档里的字段都会被索引并被查询**。而且不仅如此。在简单查询时，Elasticsearch可以使用**所有**的索引，以非常快的速度返回结果。这让你永远不必考虑传统数据库的一些东西。

**搜索(search)**可以：

*   在类似于`gender`或者`age`这样的字段上使用结构化查询，`join_date`这样的字段上使用排序，就像SQL的结构化查询一样。
*   全文检索，可以使用所有字段来匹配关键字，然后按照**关联性(relevance)**排序返回结果。
*   或者结合以上两条。

很多搜索都是开箱即用的，为了充分挖掘Elasticsearch的潜力，你需要理解以下三个概念：

| 概念 | 解释 |
| --- | --- |
| **映射(Mapping)** | 数据在每个字段中的解释说明，**映射(mapping)**机制用于进行字段类型确认，将每个字段匹配为一种确定的数据类型(`string`, `number`, `booleans`, `date`等)。 |
| **分析(Analysis)** | 全文是如何处理的可以被搜索的，**分析(analysis)**机制用于进行**全文文本(Full Text)**的分词，以建立供搜索用的反向索引。 |
| **领域特定语言查询(Query DSL)** | Elasticsearch使用的灵活的、强大的查询语言。 |

# 空搜索
```
GET /_search
```

返回结果：
```json
{
    "took": 4,
    "timed_out": false,
    "_shards": {
        "total": 0,
        "successful": 0,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": 0,
        "max_score": 0,
        "hits": []
    }
}
```

## hits
相应中最重要的就是`hits`，包括`total`表示匹配到的文档数，`hits`数组表示匹配到的前10条数据，数组里面表示匹配到的索引数据的详细内容，包括`_index`、`_type`、`_id`和`_source`。
## took
表示整个搜索请求所花费的毫秒数
## shards
`_shards`节点告诉我们参与查询的分片数（`total`字段），有多少是成功的（`successful`字段），有多少的是失败的（`failed`字段），多少跳过（`skipped`字段）。
## timeout
表示是否查询超时，可以通过在URL后面添加timeout参数设置超时时间支持单位毫秒（ms）、秒（s）。
例如：
```
GET /_search?timeout=10ms
```

# 多索引和多类别
搜索的时候可以搜索多个索引和多个类别的数据
## `/_search`

在所有索引的所有类型中搜索

## `/gb/_search`

在索引`gb`的所有类型中搜索

## `/gb,us/_search`

在索引`gb`和`us`的所有类型中搜索

## `/g*,u*/_search`

在以`g`或`u`开头的索引的所有类型中搜索

## `/gb/user/_search`

在索引`gb`的类型`user`中搜索

## `/gb,us/user,tweet/_search`

在索引`gb`和`us`的类型为`user`和`tweet`中搜索

## `/_all/user,tweet/_search`

在所有索引的`user`和`tweet`中搜索 search types `user` and `tweet` in all indices

当你搜索包含单一索引时，Elasticsearch转发搜索请求到这个索引的主分片或每个分片的复制分片上，然后聚集每个分片的结果。搜索包含多个索引也是同样的方式——只不过或有更多的分片被关联。即：搜索一个索引有5个主分片和5个索引各有一个分片**事实上是一样的**。

# 分页
通过分页可以分批获取数据，es接收两个参数from和size参数
* size，搜索结果数
* from，跳过开始的结果数

如果你想每页显示5个结果，页码从1到3，那请求如下：

```
GET /_search?size=5
GET /_search?size=5&from=5
GET /_search?size=5&from=10
```

## 在集群系统中深度分页

为了理解为什么深度分页是有问题的，让我们假设在一个有5个主分片的索引中搜索。当我们请求结果的第一页（结果1到10）时，每个分片产生自己最顶端10个结果然后返回它们给**请求节点(requesting node)**，它再排序这所有的50个结果以选出顶端的10个结果。

现在假设我们请求第1000页——结果10001到10010。工作方式都相同，不同的是每个分片都必须产生顶端的10010个结果。然后请求节点排序这50050个结果并丢弃50040个！

你可以看到在分布式系统中，排序结果的花费随着分页的深入而成倍增长。这也是为什么网络搜索引擎中任何语句不能返回多于1000个结果的原因。

# 简易搜索
`search` API有两种表单：一种是“简易版”的**查询字符串(query string)**将所有参数通过查询字符串定义，另一种版本使用JSON完整的表示**请求体(request body)**，这种富搜索语言叫做结构化查询语句（DSL）。
通过查询字符串可以很快速的搜索到相应的数据，但是由于es搜索的复杂程度，查询字符串也只能适合简易搜索。
例如这个语句查询所有类型为`tweet`并在`tweet`字段中包含`elasticsearch`字符的文档：

```
GET /_all/tweet/_search?q=tweet:elasticsearch
```

下一个语句查找`name`字段中包含`"john"`和`tweet`字段包含`"mary"`的结果。实际的查询只需要：

```
+name:john +tweet:mary
```

但是**百分比编码(percent encoding)**（译者注：就是url编码）需要将查询字符串参数变得更加神秘：

```
GET /_search?q=%2Bname%3Ajohn+%2Btweet%3Amary
```

`"+"`前缀表示语句匹配条件**必须**被满足。类似的`"-"`前缀表示条件**必须不**被满足。所有条件如果没有`+`或`-`表示是可选的——匹配越多，相关的文档就越多。

## `_all`字段

返回包含`"mary"`字符的所有文档的简单搜索：

```
GET /_search?q=mary
```

在前一个例子中，我们搜索`tweet`或`name`字段中包含某个字符的结果。然而，这个语句返回的结果在三个不同的字段中包含`"mary"`：

*   用户的名字是“Mary”
*   “Mary”发的六个推文
*   针对“@mary”的一个推文

Elasticsearch是如何设法找到三个不同字段的结果的？

当你索引一个文档，Elasticsearch把所有字符串字段值连接起来放在一个大字符串中，它被索引为一个特殊的字段`_all`。例如，当索引这个文档：

```
{
    "tweet":    "However did I manage before Elasticsearch?",
    "date":     "2014-09-14",
    "name":     "Mary Jones",
    "user_id":  1
}
```

这好比我们增加了一个叫做`_all`的额外字段值：

```
"However did I manage before Elasticsearch? 2014-09-14 Mary Jones 1"
```

若没有指定字段，查询字符串搜索（即q=xxx）使用`_all`字段搜索。`_all`字段对于开始一个新应用时是一个有用的特性。之后，如果你定义字段来代替`_all`字段，你的搜索结果将更加可控。

指定`_all` field，让搜索结果更可控
*   `name`字段包含`"mary"`或`"john"`
*   `date`晚于`2014-09-10`
*   `_all`字段包含`"aggregations"`或`"geo"`

```
+name:(mary john) +date:>2014-09-10 +(aggregations geo)
```

编码后的查询字符串变得不太容易阅读：

```
?q=%2Bname%3A(mary+john)+%2Bdate%3A%3E2014-09-10+%2B(aggregations+geo)
```

就像你上面看到的例子，**简单(lite)**查询字符串搜索惊人的强大。参考文档允许我们简洁明快的表示复杂的查询。这对于命令行下一次性查询或者开发模式下非常有用。
