---
title: redis数据结构
tags:
  - redis
categories:
  - tech
date: 2019-03-14 15:17:26
---

Redis数据结构：
* `string`
* `list`
* `hash`
* `set`
* `zset`

Redis底层数据结构：
* `REDIS_ENCODING_RAW`，字符串
* `REDIS_ENCODING_INT`，整数
* `REDIS_ENCODING_HT`，哈希表
* `REDIS_ENCODING_ZIPMAP`，zipmap
* `REDIS_ENCODING_LINKEDLIST`，双端链表
* `REDIS_ENCODING_ZIPLIST`，压缩列表
* `REDIS_ENCODING_INTSET`，整数集合
* `REDIS_ENCODING_SKIPLIST`， 跳跃表

他们的对应关系是：
|数据结构|底层数据结构|
|-|-|
|`string`| `REDIS_ENCODING_INT`，`REDIS_ENCODING_RAW`|
|`list`| `REDIS_ENCODING_LINKEDLIST`，`REDIS_ENCODING_ZIPLIST`|
|`hash`| `REDIS_ENCODING_ZIPLIST`，`REDIS_ENCODING_HT`|
|`set`| `REDIS_ENCODING_HT`，`REDIS_ENCODING_INTSET`|
|`zset`| `REDIS_ENCODING_SKIPLIST`，`REDIS_ENCODING_ZIPLIST`|

当执行一个处理数据类型的命令时，Redis 执行以下步骤：
1. 根据给定key ，在数据库字典中查找和它像对应的redisObject ，如果没找到，就返回NULL 。
2. 检查redisObject 的type 属性和执行命令所需的类型是否相符，如果不相符，返回类型错误。
3. 根据redisObject 的encoding 属性所指定的编码，选择合适的操作函数来处理底层的数据结构。
4. 返回数据结构的操作结果作为命令的返回值。

