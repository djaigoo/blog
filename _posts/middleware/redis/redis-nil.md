---
author: djaigo
title: Redis 返回 nil 的操作汇总
categories:
  - middleware
  - redis
date: 2025-01-01 00:00:00
tags:
  - redis
  - nil
---

# Redis 返回 nil 的操作汇总

Redis 中 `nil` 表示“无结果”或“键/成员不存在”，不是错误。以下按类型罗列**会返回 nil** 的常见操作及触发条件。

## String（字符串）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **GET** key | key 不存在 |
| **GETRANGE** key start end | key 不存在 |
| **GETSET** key value | key 不存在（旧版返回 nil，新版本行为以官方文档为准） |
| **SUBSTR** key start end | key 不存在 |
| **MGET** key [key ...] | 对**不存在的 key**，在结果数组里对应位置为 nil |

## Hash（哈希）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **HGET** key field | key 不存在，或 field 不存在 |
| **HMGET** key field [field ...] | 对**不存在的 field**，在结果数组里对应位置为 nil；key 不存在时所有位置为 nil |

## List（列表）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **LINDEX** key index | key 不存在，或 index 超出范围 |
| **LPOP** key | key 不存在，或列表为空 |
| **RPOP** key | key 不存在，或列表为空 |
| **BLPOP** key [key ...] timeout | 在 timeout 内没有任何 key 有可弹出元素时返回 nil |
| **BRPOP** key [key ...] timeout | 同上 |
| **LMOVE** source dest LEFT\|RIGHT LEFT\|RIGHT | source 不存在或为空时返回 nil（依版本/语义） |

## Set（集合）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **SPOP** key [count] | key 不存在，或集合为空（无元素可弹出时） |
| **SRANDMEMBER** key [count] | key 不存在，或集合为空（count 缺省时为单元素，无则 nil） |

## Sorted Set（有序集合）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **ZSCORE** key member | key 不存在，或 member 不存在 |
| **ZRANK** key member | key 不存在，或 member 不存在 |
| **ZREVRANK** key member | key 不存在，或 member 不存在 |
| **ZPOPMIN** / **ZPOPMAX** key [count] | key 不存在或有序集为空时，无元素可弹出则返回空列表（无“分数”可返回时语义上类似 nil） |

## Stream（流）

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **XREAD** [COUNT count] [BLOCK ms] STREAMS key [key ...] id [id ...] | 使用 BLOCK 且超时前没有新数据时返回 nil（空结果） |

## 键与通用

| 命令 | 返回 nil 的条件 |
|------|------------------|
| **DUMP** key | key 不存在 |
| **RESTORE** 等迁移/恢复场景 | 当源 key 不存在时，依赖具体命令语义可能得到 nil 或错误 |

---

## 使用 Go 客户端时的注意点

go-redis 会把 Redis 的 nil 转成 **`redis.Nil`** 错误，需要单独判断：

```go
val, err := rdb.Get(ctx, "key").Result()
if err == redis.Nil {
    // key 不存在
    return
}
if err != nil {
    // 其它错误（网络、超时等）
    return err
}
// val 为实际值
```

**建议**：对上述会返回 nil 的“读”类命令，统一用 `err == redis.Nil` 区分“键/成员不存在”与“真实错误”，再做降级或默认值处理。
