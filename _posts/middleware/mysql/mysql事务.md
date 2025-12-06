---
author: djaigo
title: MySQL事务
categories:
  - mysql
tags:
  - mysql
  - 事务
---

# MySQL 事务详解

## 1. 事务基本概念

事务（Transaction）是数据库管理系统执行过程中的一个逻辑单位，由一个有限的数据库操作序列构成。事务具有四个基本特性，通常称为 ACID 特性。

## 2. ACID 特性

### 2.1 原子性（Atomicity）
- **定义**：事务是一个不可分割的工作单位，事务中的操作要么全部成功，要么全部失败回滚。
- **实现**：通过 Undo Log 实现，记录事务执行前的数据状态，用于回滚。

### 2.2 一致性（Consistency）
- **定义**：事务执行前后，数据库从一个一致性状态转换到另一个一致性状态。
- **实现**：通过原子性、隔离性和持久性来保证。

### 2.3 隔离性（Isolation）
- **定义**：并发执行的事务之间相互隔离，一个事务的执行不应影响其他事务。
- **实现**：通过锁机制和 MVCC（多版本并发控制）实现。

### 2.4 持久性（Durability）
- **定义**：事务一旦提交，对数据库的修改就是永久性的。
- **实现**：通过 Redo Log 实现，确保已提交的事务能够恢复。

## 3. 并发事务问题

在并发环境下，多个事务同时执行时可能出现以下问题：

### 3.1 脏读（Dirty Read）
- **定义**：一个事务读取了另一个未提交事务修改的数据。
- **问题**：如果另一个事务回滚，读取到的数据就是无效的。
- **示例**：
  ```
  事务A：UPDATE account SET balance = balance - 100 WHERE id = 1;  -- 未提交
  事务B：SELECT balance FROM account WHERE id = 1;  -- 读取到未提交的数据
  事务A：ROLLBACK;  -- 回滚，事务B读取的数据无效
  ```

### 3.2 不可重复读（Non-Repeatable Read）
- **定义**：在同一个事务中，多次读取同一数据，结果不一致。
- **问题**：由于其他事务的修改或删除操作，导致同一事务内读取结果不同。
- **示例**：
  ```
  事务A：SELECT balance FROM account WHERE id = 1;  -- 读取到 1000
  事务B：UPDATE account SET balance = 2000 WHERE id = 1; COMMIT;
  事务A：SELECT balance FROM account WHERE id = 1;  -- 读取到 2000，结果不一致
  ```

### 3.3 幻读（Phantom Read）
- **定义**：在同一个事务中，多次执行相同的查询，返回的记录数不一致。
- **问题**：由于其他事务的插入或删除操作，导致同一事务内查询结果集发生变化。
- **示例**：
  ```
  事务A：SELECT COUNT(*) FROM account WHERE balance > 1000;  -- 返回 5 条
  事务B：INSERT INTO account VALUES (6, 1500); COMMIT;
  事务A：SELECT COUNT(*) FROM account WHERE balance > 1000;  -- 返回 6 条，出现幻读
  ```

### 3.4 丢失更新（Lost Update）
- **定义**：两个事务同时修改同一数据，后提交的事务覆盖了先提交事务的修改。
- **问题**：先提交的修改丢失。
- **示例**：
  ```
  事务A：UPDATE account SET balance = balance + 100 WHERE id = 1;  -- balance = 1100
  事务B：UPDATE account SET balance = balance + 200 WHERE id = 1;  -- balance = 1200
  事务A：COMMIT;
  事务B：COMMIT;  -- 最终 balance = 1200，事务A的 +100 丢失
  ```

## 4. 事务隔离级别

SQL 标准定义了四个事务隔离级别，MySQL InnoDB 引擎支持所有这些级别。

### 4.1 READ UNCOMMITTED（读未提交）

#### 特点
- **隔离程度**：最低
- **并发性能**：最高
- **锁机制**：不使用锁，直接读取最新数据

#### 解决的问题
- **无**：不解决任何并发问题

#### 存在的问题
- ✅ **脏读**：可能读取到未提交的数据
- ✅ **不可重复读**：可能发生
- ✅ **幻读**：可能发生
- ✅ **丢失更新**：可能发生

#### 使用场景
- 几乎不使用，因为数据一致性无法保证
- 仅用于对数据一致性要求极低的场景

#### 示例
```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN;
SELECT balance FROM account WHERE id = 1;  -- 可能读取到未提交的数据
COMMIT;
```

### 4.2 READ COMMITTED（读已提交）

#### 特点
- **隔离程度**：较低
- **并发性能**：较高
- **锁机制**：使用行锁，读取已提交的数据
- **MVCC**：每次读取都生成新的 ReadView

#### 解决的问题
- ✅ **脏读**：解决了脏读问题，只读取已提交的数据

#### 存在的问题
- ❌ **不可重复读**：可能发生（因为每次读取都生成新的 ReadView）
- ❌ **幻读**：可能发生
- ❌ **丢失更新**：可能发生

#### 使用场景
- Oracle 数据库的默认隔离级别
- 适合对数据一致性要求不高的读多写少场景

#### 示例
```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT balance FROM account WHERE id = 1;  -- 读取已提交的数据，不会脏读
-- 其他事务提交后
SELECT balance FROM account WHERE id = 1;  -- 可能读取到不同的值（不可重复读）
COMMIT;
```

### 4.3 REPEATABLE READ（可重复读）

#### 特点
- **隔离程度**：较高
- **并发性能**：中等
- **锁机制**：使用行锁和间隙锁（Gap Lock）
- **MVCC**：事务开始时生成 ReadView，整个事务期间复用同一个 ReadView
- **MySQL InnoDB 默认隔离级别**

#### 解决的问题
- ✅ **脏读**：解决了脏读问题
- ✅ **不可重复读**：解决了不可重复读问题，同一事务内多次读取结果一致

#### 存在的问题
- ❌ **幻读**：在标准 SQL 中可能发生，但 InnoDB 通过 Next-Key Lock 基本解决了幻读问题
- ❌ **丢失更新**：可能发生（需要通过锁机制避免）

#### 使用场景
- MySQL InnoDB 的默认隔离级别
- 适合大多数业务场景，平衡了数据一致性和并发性能

#### InnoDB 如何解决幻读
- **Next-Key Lock**：结合记录锁（Record Lock）和间隙锁（Gap Lock）
- **间隙锁**：锁定索引记录之间的间隙，防止其他事务插入
- **示例**：
  ```sql
  -- 事务A
  BEGIN;
  SELECT * FROM account WHERE balance > 1000 FOR UPDATE;  -- 使用 Next-Key Lock
  -- 锁定 balance > 1000 的记录和间隙，防止插入
  
  -- 事务B
  INSERT INTO account VALUES (6, 1500);  -- 被阻塞，直到事务A提交
  ```

#### 示例
```sql
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
SELECT balance FROM account WHERE id = 1;  -- 读取到 1000
-- 其他事务修改并提交
SELECT balance FROM account WHERE id = 1;  -- 仍然读取到 1000（可重复读）
COMMIT;
```

### 4.4 SERIALIZABLE（串行化）

#### 特点
- **隔离程度**：最高
- **并发性能**：最低
- **锁机制**：使用表级锁或严格的锁机制，事务串行执行
- **MVCC**：禁用，使用锁机制

#### 解决的问题
- ✅ **脏读**：完全解决
- ✅ **不可重复读**：完全解决
- ✅ **幻读**：完全解决
- ✅ **丢失更新**：完全解决

#### 存在的问题
- ❌ **性能问题**：并发性能最低，可能导致大量事务等待
- ❌ **死锁风险**：锁竞争激烈，容易产生死锁

#### 使用场景
- 对数据一致性要求极高的场景
- 可以接受低并发的业务场景
- 金融、支付等关键业务

#### 示例
```sql
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT * FROM account WHERE balance > 1000;  -- 自动加锁，其他事务无法修改
-- 所有相关操作串行执行
COMMIT;
```

## 5. 隔离级别对比总结

| 隔离级别 | 脏读 | 不可重复读 | 幻读 | 并发性能 | 使用场景 |
|---------|------|-----------|------|---------|---------|
| READ UNCOMMITTED | ❌ | ❌ | ❌ | 最高 | 几乎不使用 |
| READ COMMITTED | ✅ | ❌ | ❌ | 较高 | Oracle 默认，读多写少 |
| REPEATABLE READ | ✅ | ✅ | ✅* | 中等 | MySQL 默认，大多数场景 |
| SERIALIZABLE | ✅ | ✅ | ✅ | 最低 | 高一致性要求场景 |

*注：InnoDB 通过 Next-Key Lock 基本解决了幻读问题

## 6. MySQL 查看和设置隔离级别

### 6.1 查看当前隔离级别
```sql
-- 查看全局隔离级别
SELECT @@global.transaction_isolation;

-- 查看会话隔离级别
SELECT @@session.transaction_isolation;
SELECT @@transaction_isolation;  -- 默认查看会话级别

-- 查看系统变量
SHOW VARIABLES LIKE 'transaction_isolation';
```

### 6.2 设置隔离级别
```sql
-- 设置全局隔离级别（需要 SUPER 权限）
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 设置会话隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 设置下一个事务的隔离级别
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### 6.3 在配置文件中设置
```ini
[mysqld]
transaction-isolation = REPEATABLE-READ
```

## 7. MVCC 机制

### 7.1 什么是 MVCC
MVCC（Multi-Version Concurrency Control，多版本并发控制）是 InnoDB 实现事务隔离的重要机制。

### 7.2 MVCC 工作原理
1. **版本链**：每行数据都有多个版本，通过 undo log 链连接
2. **ReadView**：事务在读取数据时创建 ReadView，决定能看到哪些版本
3. **可见性判断**：根据事务 ID 和 ReadView 判断数据版本是否可见

### 7.3 ReadView 的生成时机
- **READ COMMITTED**：每次 SELECT 都生成新的 ReadView
- **REPEATABLE READ**：事务第一次 SELECT 时生成 ReadView，后续复用

### 7.4 MVCC 的优势
- 读操作不加锁，提高并发性能
- 读写不冲突，读操作不会被写操作阻塞
- 通过版本控制实现一致性读

## 8. 锁机制补充

### 8.1 记录锁（Record Lock）
- 锁定索引记录
- 解决脏读和不可重复读

### 8.2 间隙锁（Gap Lock）
- 锁定索引记录之间的间隙
- 防止其他事务在间隙中插入数据
- 解决幻读问题

### 8.3 Next-Key Lock
- 记录锁 + 间隙锁的组合
- InnoDB 在 REPEATABLE READ 级别使用
- 有效防止幻读

### 8.4 意向锁（Intention Lock）
- 表级锁，表示事务想要获取行锁
- 提高锁冲突检测效率

## 9. 最佳实践

### 9.1 隔离级别选择
- **默认使用 REPEATABLE READ**：MySQL 默认级别，适合大多数场景
- **高并发读场景**：可考虑 READ COMMITTED，但要注意不可重复读问题
- **关键业务**：使用 SERIALIZABLE，但要注意性能影响

### 9.2 事务设计原则
- **事务尽量短小**：减少锁持有时间
- **避免长事务**：长事务会持有锁较长时间，影响并发
- **合理使用锁**：必要时使用 SELECT ... FOR UPDATE 显式加锁
- **避免死锁**：按相同顺序访问资源，减少锁范围

### 9.3 性能优化
- **使用合适的索引**：减少锁范围
- **批量操作优化**：减少事务数量
- **读写分离**：读操作使用从库，减轻主库压力

## 10. 总结

MySQL 事务隔离级别从低到高依次为：
1. **READ UNCOMMITTED**：不解决任何问题，几乎不使用
2. **READ COMMITTED**：解决脏读，适合读多写少场景
3. **REPEATABLE READ**：解决脏读和不可重复读，InnoDB 通过 Next-Key Lock 基本解决幻读，MySQL 默认级别
4. **SERIALIZABLE**：解决所有问题，但性能最低

选择合适的隔离级别需要在**数据一致性**和**并发性能**之间找到平衡。大多数情况下，使用 MySQL 默认的 REPEATABLE READ 级别即可满足需求。

