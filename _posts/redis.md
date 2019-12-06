---
title: redis
tags:
  - base
categories:
  - redis
date: 2018-09-03 10:49:44
---
了解一下redis
# redis 简介
## 介绍
redis是一个高性能key-value缓存数据库，具有如下特点：
* 数据支持持久化
* 支持很多数据类型
* 支持数据备份

## 优势
* 性能极高，读110k次每秒，写81k次每秒
* 丰富的数据类型
* 原子性，redis所有的操作都是原子性，多个操作也是支持事务
* 丰富特性，支持发布和订阅
<!--more-->

# redis 命令
## redis key
### DEL key
DEL 删除键
```shell
127.0.0.1:6379> del test
(integer) 1
127.0.0.1:6379> del tests
(integer) 0
```
### DUMP key
DUMP 序列化给定的key，并返回序列化的值
```shell
127.0.0.1:6379> dump test
"\x00\x04test\a\x00~\xa2zSd;e_"
127.0.0.1:6379> dump tests
(nil)
```
### EXISTS key
EXISTS 检查一个key是否存在
```shell
127.0.0.1:6379> exists test
(integer) 1
127.0.0.1:6379> exists tests
(integer) 0
```
### EXPIRE key seconds
EXPIRE 给指定的key设置过期时间，单位秒
```shell
127.0.0.1:6379> expire test 1000
(integer) 1
127.0.0.1:6379> expire tests 1000
(integer) 0
```
### EXPIREAT key timestamp
EXPIREAT 给指定的key设置过期时间，接收参数是UNIX时间戳
```shell
127.0.0.1:6379> expireat test 159999999999
(integer) 1
127.0.0.1:6379> expireat tests 159999999999
(integer) 0
```
### PEXPIRE key milliseconds
PEXPIRE 给指定的key设置过期时间，单位毫秒
### PEXPIREAT key milliseconds-timestamp
PEXPIREAT 给指定的key设置过期时间，单位为UNIX毫秒时间戳
### KEYS pattern
KEYS 查找多有符合给定模式的key
### MOVE key db
MOVE 将当前数据库的key移动到给定的数据库中
### PERSIST key
PERSIST 移除key的过期时间
### PTTL key
PTTL 以毫秒为单位返回key的剩余过期时间
### TTL key
TTL 以秒为单位返回给定key的生存时间
### RANDOMKEY
RANDOMKEY 从当前数据库中随机返回一个key
### RENAME key
RENAME 修改key的名称
### RENAMENX key newkey
RENAMENX 仅当newkey不存在时，将key改成newkey
### TYPE key
TYPE 返回key所存储的值的类型

## redis string
### SET key value
SET 设置指定key的值
### GET key
GET 获取指定key的值
### GETRANGE key start end
GETRANGE 返回key中字符串值的子字符串
### GETSET key value
GETSET 将给定key的值设为value，并返回key的旧值
### GETBIT key offset
GETBIT 对key所存储的字符串值，获取指定offset的位
### MGET key1 [key2...]
MGET 获取所有一个或多个给定key的值
### SETBIT key offset value
SETBIT 对key所存储的字符串值，设置或清除指定偏移量上的bit位
### SETEX key seconds value
SETEX 将value关联到key，并将key的过期时间设为seconds
### SETNX key value
SETNX 只有在key不存在时设置key的值
### SETRANGE key offset value
SETRANGE 用value参数复写给定key所存储的字符串值，从偏移量offset开始
### STRLEN key
STRLEN 返回key所存储的字符串值的长度
### MSET key value [key value...]
MSET 同时设置一个或多个key-value对
### MSETNX key value [key value...]
MSETNX 同时设置一个或多个key-value对，当且仅当所有给定key都不存在
### PSETEX key milliseconds value
PSETEX 以毫秒为单位设置key的生存时间
### INCR key
INCR 将key中存储的数字值增一
### INCRBY key increment
INCRBY 给key增加指定增量 
### INCRBYFLOAT key increment
INCRBYFLOAT 将key所存储的值奖赏给定的浮点增量值
### DECR key
DECR 将key中存储的数字值减一
### DECRBY key decrement
DECRBY 将所存储的值减去给定的减量值
### APPEND key value
APPEND 如果key已经存在并且是一个字符串，APPEND将指定的value追加到key原来值value的末尾

## redis hash
### HDEL key field1 [field2...]
HDEL 删除一个或多个哈希表字段
### HEXISTS key field
HEXISTS 查看哈希表key中，指定的字段是否存在
### HGET key field
HGET 获取存储在哈希表中指定字段的值
### HGETALL key
HGETALL 获取在哈希表中指定key的所有字段和值
### HINCRBY key field increment
HINCRBY 为哈希表中的指定字段的整数值增量加increment
### HINCRBYFLOAT key field increment
HINCRBYFLOAT 为哈希表key的指定字段的浮点数值加上增量increment
### HKEYS key
HKEYS 获取所有哈希表中的字段
### HLEN key
HLEN 获取哈希表中字段的数量
### HMGET key field1 [field2...]
HMGET 获取所有给定字段的值
### HMSET key field1 value1 [field2 value2...]
HMSET 同时将多个field-value对设置到哈希表key中
### HSET key field value
HSET 将哈希表key中的字段field的值设置为value
### HSETNX key field value
HSETNX 只有字段field不存在时，设置哈希表字段的值
### HVALS key
HVALS 获取哈希表中所有值
### HSCAN key cursor [MATCH pattern] [COUNT count]
HSCAN 迭代哈希表中的键值对

## redis list
### BLPOP key1 [key2] timeout
BLPOP 移除并获取列表的第一个元素，如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止
### BRPOP key1 [key2] timeout
BRPOP 移除并获取列表最后一个元素，如果列表没有元素会阻塞列表知道等待超时或发现可弹出元素为止
### BRPOPLPUSH source destination timeout
BRPOPLPUSH 从列表中弹出一个值，将弹出的元素插入到另一个列表中返回他，如果没有元素会阻塞列表知道等待超时或发现可弹出元素为止
### LINDEX key index
LINDEX 通过索引获取列表中的元素
### LINSERT key BEFORE|AFTER pivot value
LINSERT 往列表的前或者后插入元素
### LLEN key
LLEN 获取列表长度
### LPOP key
LPOP 移除并获取第一个元素
### LPUSH key value1 [value2...]
LPUSH 将一个值或多个值插入列表头部
### LPUSHX key value
LPUSHX 将一个值插入到已存在的列表头部
### LRANGE key start stop
LRANGE 获取列表指定范围内的元素
### LREM key count value
LREM 移除列表元素
### LSET key index value
LSET 通过索引设置列表元素的值
### LTRIM key start stop
LTRIM 对一个列表进行修剪，只保留start和stop区间内的元素，其他范围的元素都会被删除
### RPOP key
RPOP 移除并获取列表最后一个元素
### RPOPLPUSH source destination
RPOPLPUSH 移除列表最后一个元素，并将该元素添加到另一个列表中返回
### RPUSH key value1 [value2...]
RPUSH 在列表中添加一个或多个值
### RPUSHX key value
RPUSHX 唯一存在的列表添加值

## redis set
### SADD key member1 [member2...]
SADD 向集合里面添加一个或多个成员
### SCARD key
SCARD 获取集合的成员数
### SDIFF key1 [key2...]
SDIFF 返回所有给定集合的差集
### SDIFFSTORE destination key1 [key2...]
SDIFFSTORE 返回所有给定集合的差集，并存储在destination中
### SINTER key1 [key2...]
SINTER 返回给定集合的交集
### SINTERSTORE destination key1 [key2...]
SINTERSTORE 返回给定所有集合的交集并存储在destination中
### SISMEMBER key member
SISMEMBER 判断member是否是key的成员
### SMEMBERS key
SMEMBERS 返回集合中的所有成员
### SMOVE source destination member
SMOVE 将member元素从source集合移动到destination集合
### SPOP key
SPOP 移除并返回集合中的一个随机元素
### SRANDMEMBER key [count]
SRANDMEMBER 返回集合中一个或多个随机数
### SREM key member1 [member2]
SREM 移除集合中的成员
### SUNION key1 [key2...]
SUNION 返回所有给定集合的并集
### SUNIONSTORE destination key1 [key2...]
SUNIONSTORE 将所有集合的并集存储到destination集合中
### SSCAN key cursor [MATCH pattern] [COUNT count]
SSCAN 迭代集合中的元素

## redis sorted set
### ZADD key score1 member1 [score2 member2...]
ZADD 向有序集合添加一个或多个成员数，或更新已存在成员的分数
### ZCARD key
ZCARD 获取有序集合的成员数
### ZCOUNT key min max
ZCOUNT 计算有序集合指定区间分数的成员数
### ZINCRBY key increment member
ZINCRBY 有序集合中对指定成员的分数加上增量increment
### ZINTERSTORE destination numkeys key [key ...]
ZINTERSTORE 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合key中
### ZLEXCOUNT key min max
ZLEXCOUNT 在有序集合中计算指定字典区间内成员数量
### ZRANGE key start stop [WITHSCORES]
ZRANGE 通过索引区间返回有序集和成指定区间内的成员
### ZRANGEBYLEX key min max [LIMIT offset count]
ZRANGEBYLEX 通过字典区间返回有序集合的成员
### ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT]
ZRANGEBYSCORE 通过分数返回有序集合指定区间内的成员
### ZRANK key member
ZRANK 返回有序集合中指定成员的索引
### ZREM key member [member...]
ZREM 移除有序集合中的一个或多个成员
### ZREMRANGEBYLEX key min max
ZREMRANGEBYLEX 移除有序集合中给定的字典区间的所有成员
### ZREMRANGEBYRANK key start stop
ZREMRANGEBYRANK 移除有序集合中给定的字典区间和所有成员
### ZREMRANGEBYSCORE key min max
ZREMRANGEBYSCORE 移除有序集合给定分数区间的所有成员
### ZREVRANGE key start stop [WITHSCORES]
ZREVRANGE 返回有序集合指定区间的成员，通过索引，分数从高到低
### ZREVRANGEBYSCORE key max min [WITHSCORES]
ZREVRANGEBYSCORE 返回有序集合中制定分数区间内的成员，分数从高到低排序
### ZREVRANK key member
ZREVRANK 返回有序集合中指定成员的排名，有序集合成员按分数值递减排序
### ZSCORE key member
ZSCORE 返回有序集中，成员的分数值
### ZUNIONSTORE destination numkeys key [key...]
ZUNIONSTORE 计算给定的一个或多个有序集的并集，并存储在新的key中
### ZSCAN key cursor [MATCH pattern] [COUNT count]
ZSCAN 迭代有序结合中的元素，包括元素成员和元素分值
## redis HyperLogLog
### PFADD key element [element...]
PFADD 添加指定元素到HyperLogLog中
### FPCOUNT key [key...]
FPCOUNT 返回给定HyperLogLog的基数估算值
### PFMERGE destkey sourcekey [sourcekey...]
PFMERGE 将多个HyperLogLog合并为一个HyperLogLog
## redis SUB/PUB
### PSUBSCRIBE pattern [pattern...]
PSUBSCRIBE 订阅一个或多个符合给定模式的频道
### PUBSUB subcommand [argument [argument...]]
PUBSUB 查看订阅与发布系统状态
### PUBLISH channel message
PUBLISH 将信息发送到指定的频道
### PUNSUBSCRIBE [pattern [pattern...]]
 PUNSUBSCRIBE 退订所有给定模式的频道
### SUBSCRIBE channel [channel...]
SUBSCRIBE 订阅给定的一个或多个频道的信息
### UNSUBSCRIBE [channel [channel...]]
UNSUBSCRIBE 退订指定的频道

## redis Transaction
### DISCARD
DISCARD 取消事务，放弃执行事务块内所有命令
### EXEC
EXEC 执行所有事务块内的命令
### MULTI
MULTI 标记一个事务块的开始
### UNWATCH
UNWATCH 取消WATCH命令对所有key的监视
### WATCH key [key...]
监视一个或多个key，如果在事务执行之前这个key被其他命令所改动，那么事务将被打断
## redis script
### EVAL script numkeys key [key ...] arg [arg ...] 
EVAL 执行 Lua 脚本。
### EVALSHA sha1 numkeys key [key ...] arg [arg ...] 
EVALSHA 执行 Lua 脚本。
### SCRIPT EXISTS script [script ...] 
SCRIPT EXISTS 查看指定的脚本是否已经被保存在缓存当中。
### SCRIPT FLUSH 
SCRIPT FLUSH从脚本缓存中移除所有脚本。
### SCRIPT KILL 
SCRIPT KILL 杀死当前正在运行的 Lua 脚本。
### SCRIPT LOAD script 
SCRIPT LOAD 将脚本 script 添加到脚本缓存中，但并不立即执行这个脚本。
## redis connection
### AUTH password
AUTH 验证用户
### ECHO message
ECHO 打印字符串
### PING
PING 查看服务是否运行
### QUIT
QUIT 关闭当前连接
### SELECT index
SELECT 切换到指定的数据库

## redis server command
### BGREWRITEAOF 
BGREWRITEAOF 异步执行一个 AOF（AppendOnly File） 文件重写操作
### BGSAVE 
BGSAVE 在后台异步保存当前数据库的数据到磁盘
### CLIENT KILL [ip:port] [ID client-id] 
CLIENT KILL 关闭客户端连接
### CLIENT LIST 
CLIENT LIST 获取连接到服务器的客户端连接列表
### CLIENT GETNAME 
CLIENT GETNAME 获取连接的名称
### CLIENT PAUSE timeout 
CLIENT PAUSE 在指定时间内终止运行来自客户端的命令
### CLIENT SETNAME connection-name 
CLIENT SETNAME 设置当前连接的名称
### CLUSTER SLOTS 
CLUSTER SLOTS 获取集群节点的映射数组
### COMMAND 
COMMAND 获取 Redis 命令详情数组
### COMMAND COUNT 
COMMAND COUNT 获取 Redis 命令总数
### COMMAND GETKEYS 
COMMAND GETKEYS 获取给定命令的所有键
### TIME 
TIME 返回当前服务器时间
### COMMAND INFO command-name [command-name ...] 
COMMAND INFO 获取指定 Redis 命令描述的数组
### CONFIG GET parameter 
CONFIG GET 获取指定配置参数的值
### CONFIG REWRITE 
CONFIG REWRITE 对启动 Redis 服务器时所指定的 redis.conf 配置文件进行改写
### CONFIG SET parameter value 
CONFIG SET 修改 redis 配置参数，无需重启
### CONFIG RESETSTAT 
 CONFIG RESETSTAT 重置 INFO 命令中的某些统计数据
### DBSIZE 
DBSIZE 返回当前数据库的 key 的数量
### DEBUG OBJECT key 
DEBUG OBJECT 获取 key 的调试信息
### DEBUG SEGFAULT 
DEBUG SEGFAULT 让 Redis 服务崩溃
### FLUSHALL 
FLUSHALL 删除所有数据库的所有key
### FLUSHDB 
FLUSHDB 删除当前数据库的所有key
### INFO [section] 
INFO 获取 Redis 服务器的各种信息和统计数值
### LASTSAVE 
LASTSAVE 返回最近一次 Redis 成功将数据保存到磁盘上的时间，以 UNIX 时间戳格式表示
### MONITOR 
MONITOR 实时打印出 Redis 服务器接收到的命令，调试用
### ROLE 
ROLE 返回主从实例所属的角色
### SAVE 
SAVE 同步保存数据到硬盘
### SHUTDOWN [NOSAVE] [SAVE] 
SHUTDOWN 异步保存数据到硬盘，并关闭服务器
### SLAVEOF host port 
SLAVEOF 将当前服务器转变为指定服务器的从属服务器(slave server)
### SLOWLOG subcommand [argument] 
SLOWLOG 管理 redis 的慢日志
### SYNC 
SYNC 用于复制功能(replication)的内部命令



