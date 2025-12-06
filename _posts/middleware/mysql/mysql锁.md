---
author: djaigo
title: MySQL锁
categories:
  - mysql
tags:
  - mysql
  - 锁
---

# MySQL 锁详解

## 1. 锁的基本概念

### 1.1 什么是锁
锁（Lock）是数据库管理系统用于控制并发访问的机制，通过锁可以保证数据的一致性和完整性。当多个事务同时访问同一资源时，锁机制确保只有一个事务能够修改数据。

### 1.2 锁的作用
- **保证数据一致性**：防止并发修改导致的数据不一致
- **实现事务隔离**：不同隔离级别通过不同的锁机制实现
- **防止脏读、不可重复读、幻读**：通过锁机制解决并发问题
- **协调并发访问**：控制多个事务对共享资源的访问顺序

### 1.3 锁的分类
- **按锁的粒度**：表锁、行锁、页锁
- **按锁的类型**：共享锁（读锁）、排他锁（写锁）
- **按锁的兼容性**：兼容锁、不兼容锁
- **按锁的实现方式**：悲观锁、乐观锁

## 2. 锁的粒度

### 2.1 表锁（Table Lock）
- **粒度**：锁定整个表
- **开销**：小
- **并发度**：低
- **使用场景**：MyISAM 引擎、InnoDB 的某些操作

### 2.2 行锁（Row Lock）
- **粒度**：锁定表中的一行或多行
- **开销**：大
- **并发度**：高
- **使用场景**：InnoDB 引擎，支持高并发

### 2.3 页锁（Page Lock）
- **粒度**：锁定数据页
- **开销**：中等
- **并发度**：中等
- **使用场景**：BDB 引擎（已废弃）

## 3. 表锁

### 3.1 表共享读锁（Table Read Lock）

#### 定义
表共享读锁（LOCK TABLE ... READ）允许多个事务同时读取表，但不允许任何事务写入表。

#### 特点
- **共享性**：多个事务可以同时持有读锁
- **阻塞写操作**：持有读锁时，其他事务无法获取写锁
- **不阻塞读操作**：多个读锁可以同时存在
- **显式加锁**：需要手动使用 `LOCK TABLE` 语句

#### 加锁方式
```sql
-- 加表读锁
LOCK TABLE table_name READ;

-- 解锁
UNLOCK TABLES;
```

#### 锁的兼容性
| 当前锁 | 读锁请求 | 写锁请求 |
|--------|---------|---------|
| 无锁 | ✅ 允许 | ✅ 允许 |
| 读锁 | ✅ 允许 | ❌ 阻塞 |
| 写锁 | ❌ 阻塞 | ❌ 阻塞 |

#### 使用场景
- **数据备份**：备份时加读锁，保证数据一致性
- **数据迁移**：迁移过程中防止数据被修改
- **MyISAM 表**：MyISAM 引擎的表在查询时会自动加表读锁

#### 示例
```sql
-- 事务 A
LOCK TABLE user READ;
SELECT * FROM user WHERE id = 1;  -- 可以读取
UPDATE user SET name = 'John' WHERE id = 1;  -- 错误：表被锁定，无法写入
UNLOCK TABLES;

-- 事务 B（同时执行）
SELECT * FROM user WHERE id = 1;  -- 可以读取（读锁共享）
UPDATE user SET name = 'John' WHERE id = 1;  -- 阻塞，等待事务 A 释放锁
```

### 3.2 表独占写锁（Table Write Lock）

#### 定义
表独占写锁（LOCK TABLE ... WRITE）只允许一个事务读写表，其他事务无法进行任何操作。

#### 特点
- **独占性**：同一时间只有一个事务可以持有写锁
- **阻塞所有操作**：持有写锁时，其他事务无法获取读锁或写锁
- **读写都允许**：持有写锁的事务可以读写表
- **显式加锁**：需要手动使用 `LOCK TABLE` 语句

#### 加锁方式
```sql
-- 加表写锁
LOCK TABLE table_name WRITE;

-- 解锁
UNLOCK TABLES;
```

#### 锁的兼容性
| 当前锁 | 读锁请求 | 写锁请求 |
|--------|---------|---------|
| 无锁 | ✅ 允许 | ✅ 允许 |
| 读锁 | ❌ 阻塞 | ❌ 阻塞 |
| 写锁 | ❌ 阻塞 | ❌ 阻塞 |

#### 使用场景
- **批量数据修改**：需要大量修改数据时，加写锁保证一致性
- **表结构修改**：ALTER TABLE 时会自动加写锁
- **数据导入**：导入大量数据时使用

#### 示例
```sql
-- 事务 A
LOCK TABLE user WRITE;
SELECT * FROM user WHERE id = 1;  -- 可以读取
UPDATE user SET name = 'John' WHERE id = 1;  -- 可以写入
UNLOCK TABLES;

-- 事务 B（同时执行）
SELECT * FROM user WHERE id = 1;  -- 阻塞，等待事务 A 释放锁
UPDATE user SET name = 'John' WHERE id = 1;  -- 阻塞，等待事务 A 释放锁
```

### 3.3 元数据锁（Metadata Lock，MDL）

#### 定义
元数据锁（MDL）是 MySQL 5.5 引入的锁机制，用于保护表结构的一致性。当有活动事务时，不允许修改表结构。

#### 特点
- **自动加锁**：DML 操作自动加 MDL 读锁，DDL 操作自动加 MDL 写锁
- **表结构保护**：防止在查询时表结构被修改
- **隐式锁**：不需要手动加锁，由 MySQL 自动管理
- **阻塞 DDL**：有活动事务时，ALTER TABLE 等 DDL 操作会被阻塞

#### MDL 锁类型
- **MDL 读锁**：SELECT、INSERT、UPDATE、DELETE 等 DML 操作
- **MDL 写锁**：ALTER TABLE、DROP TABLE、CREATE INDEX 等 DDL 操作

#### 锁的兼容性
| 当前锁 | MDL 读锁请求 | MDL 写锁请求 |
|--------|-------------|-------------|
| 无锁 | ✅ 允许 | ✅ 允许 |
| MDL 读锁 | ✅ 允许 | ❌ 阻塞 |
| MDL 写锁 | ❌ 阻塞 | ❌ 阻塞 |

#### 使用场景
- **自动保护**：所有 DML 和 DDL 操作都会自动使用 MDL
- **防止表结构修改**：查询时防止表结构被修改

#### MDL 锁等待问题
长时间运行的查询会持有 MDL 读锁，导致 DDL 操作被阻塞。

```sql
-- 事务 A（长时间运行的查询）
BEGIN;
SELECT * FROM user WHERE ...;  -- 持有 MDL 读锁
-- 长时间运行...

-- 事务 B（DDL 操作）
ALTER TABLE user ADD COLUMN new_col INT;  -- 阻塞，等待事务 A 释放 MDL 读锁
```

#### 解决方案
- **优化查询**：减少长时间运行的查询
- **分批处理**：将大查询拆分为小查询
- **使用 pt-online-schema-change**：在线修改表结构，不阻塞 DML

#### 查看 MDL 锁
```sql
-- 查看当前 MDL 锁等待情况
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

## 4. 行锁

InnoDB 引擎支持行锁，这是实现高并发的关键。InnoDB 的行锁有多种类型，用于解决不同的并发问题。

### 4.1 记录锁（Record Lock）

#### 定义
记录锁（Record Lock）是锁定索引记录（不是数据行）的锁。当对某行记录加锁时，锁定的是该行记录对应的索引项。

#### 特点
- **锁定索引记录**：锁定的是索引项，不是数据行
- **精确锁定**：只锁定匹配条件的记录
- **解决脏读和不可重复读**：防止其他事务修改已锁定的记录
- **InnoDB 默认行锁**：InnoDB 使用记录锁作为基本的行锁

#### 加锁方式
```sql
-- 自动加锁（UPDATE、DELETE）
UPDATE user SET name = 'John' WHERE id = 1;  -- 自动对 id=1 的记录加排他锁

-- 显式加锁（SELECT ... FOR UPDATE）
SELECT * FROM user WHERE id = 1 FOR UPDATE;  -- 对 id=1 的记录加排他锁

-- 显式加锁（SELECT ... LOCK IN SHARE MODE）
SELECT * FROM user WHERE id = 1 LOCK IN SHARE MODE;  -- 对 id=1 的记录加共享锁
```

#### 记录锁类型
- **排他锁（X Lock）**：UPDATE、DELETE、SELECT ... FOR UPDATE
- **共享锁（S Lock）**：SELECT ... LOCK IN SHARE MODE

#### 锁的兼容性
| 当前锁 | 共享锁请求 | 排他锁请求 |
|--------|-----------|-----------|
| 无锁 | ✅ 允许 | ✅ 允许 |
| 共享锁 | ✅ 允许 | ❌ 阻塞 |
| 排他锁 | ❌ 阻塞 | ❌ 阻塞 |

#### 示例
```sql
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id = 1 FOR UPDATE;  -- 对 id=1 的记录加排他锁
-- 持有锁...

-- 事务 B（同时执行）
SELECT * FROM user WHERE id = 1;  -- 可以读取（快照读，MVCC）
SELECT * FROM user WHERE id = 1 FOR UPDATE;  -- 阻塞，等待事务 A 释放锁
UPDATE user SET name = 'John' WHERE id = 1;  -- 阻塞，等待事务 A 释放锁
```

#### 注意事项
- **必须有索引**：记录锁需要索引，如果没有索引会锁表
- **锁定索引项**：锁定的是索引记录，不是数据行
- **主键索引**：如果 WHERE 条件使用主键，锁定主键索引
- **二级索引**：如果 WHERE 条件使用二级索引，锁定二级索引和主键索引

### 4.2 间隙锁（Gap Lock）

#### 定义
间隙锁（Gap Lock）是锁定索引记录之间间隙的锁，用于防止其他事务在间隙中插入数据。

#### 特点
- **锁定间隙**：锁定索引记录之间的间隙，不锁定记录本身
- **防止插入**：防止其他事务在间隙中插入数据
- **解决幻读**：在 REPEATABLE READ 隔离级别下防止幻读
- **仅用于 REPEATABLE READ**：只在 REPEATABLE READ 隔离级别下使用

#### 间隙锁的范围
间隙锁锁定的是索引记录之间的"间隙"，例如：
```
索引值：1, 3, 5, 7, 9
间隙：  (-∞, 1), (1, 3), (3, 5), (5, 7), (7, 9), (9, +∞)
```

#### 加锁方式
```sql
-- 自动加锁（REPEATABLE READ 隔离级别）
BEGIN;
SELECT * FROM user WHERE id > 5 AND id < 10 FOR UPDATE;
-- 锁定 id 在 (5, 10) 之间的间隙，防止插入 id=6,7,8,9 的记录
```

#### 间隙锁的作用
- **防止幻读**：防止其他事务在查询范围内插入新记录
- **保证可重复读**：保证同一事务内多次查询结果一致

#### 示例
```sql
-- 事务 A（REPEATABLE READ 隔离级别）
BEGIN;
SELECT * FROM user WHERE id > 5 AND id < 10 FOR UPDATE;
-- 锁定间隙 (5, 10)，防止插入 id=6,7,8,9 的记录

-- 事务 B（同时执行）
INSERT INTO user (id, name) VALUES (7, 'John');  -- 阻塞，等待事务 A 释放间隙锁
INSERT INTO user (id, name) VALUES (11, 'Jane');  -- 不阻塞，不在锁定范围内
```

#### 间隙锁的兼容性
- **间隙锁之间兼容**：多个事务可以对同一个间隙加间隙锁
- **间隙锁不阻塞快照读**：间隙锁不阻塞普通的 SELECT 查询（快照读）
- **间隙锁阻塞插入**：间隙锁会阻塞在锁定间隙内的 INSERT 操作

#### 注意事项
- **仅 REPEATABLE READ**：只在 REPEATABLE READ 隔离级别下使用
- **唯一索引的特殊情况**：唯一索引的等值查询不使用间隙锁
- **外键约束**：外键检查时会使用间隙锁

### 4.3 Next-Key Lock

#### 定义
Next-Key Lock 是记录锁（Record Lock）和间隙锁（Gap Lock）的组合，锁定索引记录和索引记录之前的间隙。

#### 特点
- **组合锁**：记录锁 + 间隙锁
- **锁定范围**：锁定记录本身和记录之前的间隙
- **解决幻读**：InnoDB 在 REPEATABLE READ 级别使用 Next-Key Lock 解决幻读
- **默认行锁**：InnoDB 在 REPEATABLE READ 级别默认使用 Next-Key Lock

#### Next-Key Lock 的范围
```
索引值：1, 3, 5, 7, 9
Next-Key Lock 范围：
  (-∞, 1]  -- 锁定记录 1 和之前的间隙
  (1, 3]   -- 锁定记录 3 和之前的间隙
  (3, 5]   -- 锁定记录 5 和之前的间隙
  (5, 7]   -- 锁定记录 7 和之前的间隙
  (7, 9]   -- 锁定记录 9 和之前的间隙
  (9, +∞)  -- 锁定最后一个记录之后的间隙
```

#### 加锁方式
```sql
-- 自动加锁（REPEATABLE READ 隔离级别）
BEGIN;
SELECT * FROM user WHERE id = 5 FOR UPDATE;
-- 对 id=5 的记录加 Next-Key Lock，锁定 (3, 5] 范围
-- 防止其他事务插入 id=4 的记录，也防止修改 id=5 的记录
```

#### Next-Key Lock 的加锁规则
1. **等值查询（唯一索引）**：
   - 如果记录存在：只加记录锁
   - 如果记录不存在：加间隙锁

2. **等值查询（非唯一索引）**：
   - 加 Next-Key Lock
   - 如果记录存在，还会对下一个记录加间隙锁

3. **范围查询**：
   - 对范围内的所有记录加 Next-Key Lock
   - 对范围外的第一个记录加间隙锁

#### 示例
```sql
-- 示例 1：等值查询（唯一索引，记录存在）
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id = 5 FOR UPDATE;
-- 只对 id=5 的记录加记录锁（唯一索引等值查询，记录存在）

-- 事务 B
INSERT INTO user (id, name) VALUES (4, 'John');  -- 不阻塞（不在锁定范围）
UPDATE user SET name = 'John' WHERE id = 5;  -- 阻塞（记录被锁定）

-- 示例 2：等值查询（唯一索引，记录不存在）
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id = 6 FOR UPDATE;
-- 对 id=6 不存在的记录加间隙锁，锁定 (5, 7) 间隙

-- 事务 B
INSERT INTO user (id, name) VALUES (6, 'John');  -- 阻塞（在锁定间隙内）

-- 示例 3：范围查询
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id > 5 AND id < 10 FOR UPDATE;
-- 对 id=7, 9 的记录加 Next-Key Lock
-- 锁定范围 (5, 7], (7, 9], (9, 10)

-- 事务 B
INSERT INTO user (id, name) VALUES (6, 'John');  -- 阻塞
INSERT INTO user (id, name) VALUES (8, 'John');  -- 阻塞
UPDATE user SET name = 'John' WHERE id = 7;  -- 阻塞
```

#### Next-Key Lock 的优势
- **有效防止幻读**：通过锁定记录和间隙，防止插入新记录
- **保证可重复读**：保证同一事务内多次查询结果一致
- **性能平衡**：相比 SERIALIZABLE，性能更好

#### 注意事项
- **仅 REPEATABLE READ**：只在 REPEATABLE READ 隔离级别下使用
- **唯一索引优化**：唯一索引的等值查询可能只加记录锁
- **锁范围可能较大**：范围查询时锁定的范围可能比较大

### 4.4 插入意向锁（Insert Intention Lock）

#### 定义
插入意向锁（Insert Intention Lock）是一种特殊的间隙锁，表示事务想要在某个间隙中插入数据。

#### 特点
- **意向锁**：表示插入的意图，不是实际锁定
- **间隙锁的一种**：是间隙锁的特殊类型
- **兼容性**：多个插入意向锁之间可以兼容
- **阻塞 Next-Key Lock**：如果间隙被 Next-Key Lock 锁定，插入意向锁会被阻塞

#### 加锁方式
```sql
-- 自动加锁（INSERT 操作）
BEGIN;
INSERT INTO user (id, name) VALUES (6, 'John');
-- 对 id=6 所在的间隙加插入意向锁
-- 如果间隙被 Next-Key Lock 锁定，插入会被阻塞
```

#### 插入意向锁的作用
- **提高并发性**：多个事务可以在不同间隙插入，不会相互阻塞
- **与 Next-Key Lock 配合**：与 Next-Key Lock 配合防止幻读

#### 锁的兼容性
- **插入意向锁之间兼容**：多个事务可以对不同间隙加插入意向锁
- **插入意向锁与间隙锁兼容**：如果间隙没有被 Next-Key Lock 锁定，插入意向锁可以获取
- **插入意向锁与 Next-Key Lock 不兼容**：如果间隙被 Next-Key Lock 锁定，插入意向锁会被阻塞

#### 示例
```sql
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id > 5 AND id < 10 FOR UPDATE;
-- 对 id 在 (5, 10) 范围加 Next-Key Lock

-- 事务 B（同时执行）
BEGIN;
INSERT INTO user (id, name) VALUES (6, 'John');
-- 尝试在间隙 (5, 7) 中插入，需要获取插入意向锁
-- 但间隙被事务 A 的 Next-Key Lock 锁定，插入被阻塞

-- 事务 C（同时执行）
BEGIN;
INSERT INTO user (id, name) VALUES (11, 'Jane');
-- 在间隙 (10, +∞) 中插入，不在事务 A 的锁定范围内
-- 可以成功插入，不阻塞
```

#### 插入意向锁的优化
- **减少锁冲突**：只在需要插入的间隙加锁，不影响其他间隙
- **提高插入性能**：多个事务可以在不同间隙并发插入

## 5. 意向锁（Intention Lock）

### 5.1 定义
意向锁（Intention Lock）是表级锁，表示事务想要对表中的某些行加锁。意向锁用于提高锁冲突检测的效率。

### 5.2 意向锁类型
- **意向共享锁（IS Lock）**：表示事务想要对某些行加共享锁
- **意向排他锁（IX Lock）**：表示事务想要对某些行加排他锁

### 5.3 意向锁的作用
- **提高效率**：在加行锁之前，先加意向锁，可以快速判断表级锁冲突
- **表级锁冲突检测**：如果表上有表级锁，意向锁会被阻塞

### 5.4 锁的兼容性
| 当前锁 | IS 请求 | IX 请求 | S 请求 | X 请求 |
|--------|---------|---------|--------|--------|
| 无锁 | ✅ | ✅ | ✅ | ✅ |
| IS | ✅ | ✅ | ✅ | ❌ |
| IX | ✅ | ✅ | ❌ | ❌ |
| S | ✅ | ❌ | ✅ | ❌ |
| X | ❌ | ❌ | ❌ | ❌ |

### 5.5 示例
```sql
-- 事务 A
BEGIN;
SELECT * FROM user WHERE id = 1 FOR UPDATE;
-- 自动加 IX 锁（表级），然后对 id=1 的行加 X 锁

-- 事务 B（同时执行）
LOCK TABLE user WRITE;
-- 尝试加表写锁，但表上有事务 A 的 IX 锁，被阻塞
```

## 6. 锁的监控

### 6.1 查看当前锁信息
```sql
-- 查看 InnoDB 锁信息
SELECT * FROM information_schema.innodb_locks;

-- 查看锁等待情况
SELECT * FROM information_schema.innodb_lock_waits;

-- 查看事务信息
SELECT * FROM information_schema.innodb_trx;
```

### 6.2 查看锁等待详情
```sql
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query,
    w.requested_lock_id,
    w.blocking_lock_id
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

### 6.3 查看表锁信息
```sql
-- 查看表锁状态
SHOW OPEN TABLES WHERE In_use > 0;

-- 查看进程列表
SHOW PROCESSLIST;
```

## 7. 死锁（Deadlock）

### 7.1 定义
死锁是指两个或多个事务相互等待对方释放锁，导致所有事务都无法继续执行的情况。

### 7.2 死锁产生条件
1. **互斥条件**：资源不能被多个事务同时使用
2. **请求与保持**：事务持有锁的同时请求其他锁
3. **不剥夺条件**：已获得的锁不能被强制释放
4. **循环等待**：事务之间形成循环等待

### 7.3 死锁示例
```sql
-- 事务 A
BEGIN;
UPDATE user SET name = 'A' WHERE id = 1;  -- 获取 id=1 的锁
-- 等待 id=2 的锁...

-- 事务 B（同时执行）
BEGIN;
UPDATE user SET name = 'B' WHERE id = 2;  -- 获取 id=2 的锁
UPDATE user SET name = 'B' WHERE id = 1;  -- 等待 id=1 的锁（被事务 A 持有）
-- 死锁！事务 A 等待 id=2，事务 B 等待 id=1
```

### 7.4 InnoDB 死锁检测
- **自动检测**：InnoDB 会自动检测死锁
- **自动回滚**：检测到死锁后，自动回滚其中一个事务
- **选择回滚**：选择回滚代价最小的事务（影响行数最少）

### 7.5 死锁预防
1. **相同顺序访问**：多个事务按相同顺序访问资源
2. **减少锁持有时间**：尽快提交或回滚事务
3. **使用较低的隔离级别**：减少锁的范围
4. **避免长事务**：减少事务执行时间
5. **合理设计索引**：减少锁的范围

### 7.6 查看死锁信息
```sql
-- 查看最近的死锁信息
SHOW ENGINE INNODB STATUS;

-- 或者查看死锁日志（如果开启了）
-- 在错误日志中查看死锁信息
```

## 8. 锁优化建议

### 8.1 减少锁的持有时间
- **尽快提交事务**：减少锁的持有时间
- **避免长事务**：将大事务拆分为小事务
- **避免在事务中执行耗时操作**：如网络请求、文件操作等

### 8.2 减少锁的粒度
- **使用行锁**：尽量使用行锁而不是表锁
- **合理设计索引**：确保 WHERE 条件能够使用索引
- **避免全表扫描**：全表扫描会导致表锁

### 8.3 减少锁冲突
- **按相同顺序访问资源**：避免死锁
- **使用较低的隔离级别**：在满足业务需求的前提下使用较低的隔离级别
- **批量操作优化**：减少锁的获取次数

### 8.4 使用乐观锁
- **版本号机制**：使用版本号实现乐观锁
- **CAS 操作**：使用 Compare-And-Swap 实现乐观锁
- **适合读多写少场景**：减少锁竞争

## 9. 总结

### 9.1 锁类型对比
| 锁类型 | 粒度 | 使用场景 | 并发度 |
|--------|------|---------|--------|
| 表锁 | 表 | MyISAM、DDL 操作 | 低 |
| 行锁 | 行 | InnoDB 高并发场景 | 高 |
| 记录锁 | 索引记录 | 精确锁定单行 | 高 |
| 间隙锁 | 索引间隙 | 防止幻读 | 中 |
| Next-Key Lock | 记录+间隙 | REPEATABLE READ 防幻读 | 中 |
| 插入意向锁 | 间隙 | 插入操作 | 高 |

### 9.2 锁的兼容性总结
- **共享锁（S）**：多个事务可以同时持有，阻塞排他锁
- **排他锁（X）**：独占锁，阻塞所有其他锁
- **间隙锁**：多个事务可以对同一间隙加锁，阻塞插入
- **Next-Key Lock**：阻塞插入和修改
- **插入意向锁**：多个事务可以在不同间隙插入

### 9.3 最佳实践
1. **合理使用索引**：确保查询能够使用索引，避免表锁
2. **控制事务长度**：尽快提交事务，减少锁持有时间
3. **按相同顺序访问**：避免死锁
4. **监控锁等待**：定期检查锁等待情况
5. **选择合适的隔离级别**：在一致性和性能之间平衡
6. **避免长事务**：减少锁冲突和死锁风险

锁是数据库并发控制的核心机制，理解各种锁的特点和使用场景，对于优化数据库性能和保证数据一致性至关重要。
