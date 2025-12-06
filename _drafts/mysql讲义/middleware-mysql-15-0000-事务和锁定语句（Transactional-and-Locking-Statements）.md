---
author: djaigo
title: middleware-mysql-16-0000-事务和锁定语句（Transactional-and-Locking-Statements）
categories:
  - null
date: 2023-03-29 19:52:43
tags:
---
# transaction
```sql
START TRANSACTION
    [transaction_characteristic [, transaction_characteristic] ...]

transaction_characteristic: {
    WITH CONSISTENT SNAPSHOT
  | READ WRITE
  | READ ONLY
}

BEGIN [WORK]
COMMIT [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
ROLLBACK [WORK] [AND [NO] CHAIN] [[NO] RELEASE]
SET autocommit = {0 | 1}
```

这些语句提供对事务使用的控制：
* START TRANSACTION 或 BEGIN 开始一个新的交易。
* COMMIT 提交当前事务，使其更改永久化。
* ROLLBACK 回滚当前事务，取消其更改。
* SET 自动提交禁用或启用当前会话的默认自动提交模式。

## 隐式提交（Implicit Commit）

# SAVEPOINT
SAVEPOINT 语句设置一个名为标识符的命名事务保存点。如果当前事务有一个同名的保存点，则删除旧的保存点并设置一个新的保存点。
ROLLBACK TO SAVEPOINT 语句将事务回滚到指定的保存点而不终止事务。当前事务在设置保存点之后对行所做的修改在回滚中被撤消，但 InnoDB 不会释放在保存点之后存储在内存中的行锁。 （对于新插入的行，锁信息由该行存储的事务ID携带，锁不单独存储在内存中，此时在undo中释放行锁。）晚于指定保存点的时间将被删除。

```sql
SAVEPOINT identifier
ROLLBACK [WORK] TO [SAVEPOINT] identifier
RELEASE SAVEPOINT identifier
```
# LOCK TABLES
LOCK TABLES 显式获取当前客户端会话的表锁。可以为基表或视图获取表锁。对于要锁定的每个对象，您必须具有 LOCK TABLES 权限和 SELECT 权限。


```sql
LOCK TABLES
    tbl_name [[AS] alias] lock_type
    [, tbl_name [[AS] alias] lock_type] ...

lock_type: {
    READ [LOCAL]
  | [LOW_PRIORITY] WRITE
}

UNLOCK TABLES
```
