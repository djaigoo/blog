---
author: djaigo
title: redis大key处理
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/redis.png'
categories:
  - redis
tags:
  - redis
  - key
date: 2020-04-02 18:14:10
updated: 2020-04-02 18:14:10
---

Redis是一个高性能的key-value数据库。性能的关键点在于使用内存存储和单进程操作，如果Redis中存储了一个大key在内存使用和操作上都会有很大的风险。

# 大key的风险：

1.  读写大key会导致超时严重，甚至阻塞服务。
2.  如果删除大key，`DEL`命令可能阻塞Redis进程数十秒，使得其他请求阻塞，对应用程序和Redis集群可用性造成严重的影响。
3.  建议每个key不要超过M级别。

# 处理方式
## valve数据多但单条数据不大
可以按照一定的方法，聚合一些key
## valve数据少但单条数据量大
## valve数据多且单条数据量大
处理方式的核心思想就是将一个大key进行某种程度的拆分，常见的有：
* 分段，将数据按照规则递增的插入，超过阈值则插入新键，以此类推，key的数量不可控，但从根本上解决了大key的问题
* 哈希，将数据计算出对应的哈希值，分别存储到对应的key上，key的数量可控，但依旧会产生大key问题

# 淘汰策略
当内存到达maxmemory的限制时，可以采用以下选项清理内存：
*   volatile-lru，在具有过期集的密钥中使用近似的LRU逐出。
*   allkeys-lru，使用近似的LRU逐出任何密钥。
*   volatile-lfu，在具有过期集的键中使用近似的逐出。
*   allkeys-lfu，使用近似的LFU逐出任何键。
*   volatile-random，在有过期集的密钥中删除一个随机密钥。
*   allkeys-random，随机删除任意键。
*   volatile-ttl，删除最接近过期时间的密钥（次要TTL）。
*   noeviction，不要逐出任何内容，只返回写操作错误。

在不同的场景使用不同的淘汰策略，也可以充分利用redis的缓存作用。

# 优雅的删除大key
Redis数据类型除了字符串，都支持key的部分删除，运用多次少量的删除可以减少redis单次执行操作时间。
* hash，提供了`HDEL`方法进行批量删除，如果不清楚该`hash key`有哪些`field`，可以使用`HSCAN`先迭代部分`field`然后`HDEL`批量删除
* list，提供了`LTRIM`方法进行删除非指定list区间的value，可以先通过`LLEN`获取当前list的长度，再根据实际情况进行`LTRIM`
* set，提供了`SREM`方法进行批量删除，可以先通过`SSCAN`进行迭代出部分member，再通过`SREM`进行删除
* zset，提供`ZREM`方法进行批量删除，可以先通过`ZSCAN`进行迭代出部分member，再通过`ZREM`进行删除。除此之外zset还支持`ZREMRANGEBYLEX`、`ZREMRANGEBYRANK`和`ZREMRANGEBYSCORE`，分别通过member区间，score排名和score区间进行批量删除

# 参考文献
[Redis大Key优化](https://blog.csdn.net/u013474436/article/details/88808914)
