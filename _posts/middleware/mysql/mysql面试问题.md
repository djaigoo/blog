---
author: djaigo
title: mysql面试问题
categories:
  - mysql
date: 2025-05-13 14:12:09
tags:
  - mysql
---

# 锁
MySQL 提供了多种锁机制，用于保证数据的一致性和并发操作的正确性。这些锁可以从不同维度进行分类，下面从锁的粒度、锁的类型、锁的使用方式等方面详细介绍。

### 按锁的粒度分类

#### 表级锁

表级锁是对整个表进行加锁，开销小、加锁快，但并发度低。MySQL 中常见的表级锁有以下几种：

*   **表共享读锁（`LOCK TABLES ... READ`）**：多个事务可以同时对同一表加读锁，加锁后，所有事务只能读该表，不能写。

```sql
-- 给表加共享读锁
LOCK TABLES table_name READ;
-- 执行读操作
SELECT * FROM table_name;
-- 释放锁
UNLOCK TABLES;

```

*   **表独占写锁（`LOCK TABLES ... WRITE`）**：一个事务对表加写锁后，其他事务不能对该表进行读写操作，直到锁释放。

```sql
-- 给表加独占写锁
LOCK TABLES table_name WRITE;
-- 执行写操作
INSERT INTO table_name (column1, column2) VALUES (value1, value2);
-- 释放锁
UNLOCK TABLES;

```

#### 行级锁

行级锁是对表中的某一行记录加锁，开销大、加锁慢，但并发度高。InnoDB 存储引擎支持行级锁，常见的行级锁有：

*   **记录锁（Record Lock）**：锁定单个行记录。

```sql
-- 在事务中使用 SELECT ... FOR UPDATE 加记录锁
START TRANSACTION;
SELECT * FROM table_name WHERE id = 1 FOR UPDATE;
-- 执行更新操作
UPDATE table_name SET column1 = 'new_value' WHERE id = 1;
COMMIT;

```

*   **间隙锁（Gap Lock）**：锁定一个范围，但不包含记录本身，用于防止幻读。
*   **临键锁（Next-Key Lock）**：记录锁和间隙锁的组合，锁定一个范围并包含记录本身。

#### 页级锁

页级锁是介于表级锁和行级锁之间的一种锁，锁定粒度为数据页。BDB 存储引擎支持页级锁，页级锁的开销和并发度也介于两者之间。

### 按锁的类型分类

#### 共享锁（S 锁）

共享锁又称读锁，多个事务可以对同一资源加共享锁，都能读取该资源，但任何事务都不能对加了共享锁的资源加排他锁。
```sql
-- 在事务中使用 SELECT ... LOCK IN SHARE MODE 加共享锁
START TRANSACTION;
SELECT * FROM table_name WHERE id = 1 LOCK IN SHARE MODE;
-- 可以继续读操作
COMMIT;

```

#### 排他锁（X 锁）

排他锁又称写锁，一个事务对资源加排他锁后，其他事务不能对该资源加任何类型的锁，直到锁释放。

```sql
-- 在事务中使用 SELECT ... FOR UPDATE 加排他锁
START TRANSACTION;
SELECT * FROM table_name WHERE id = 1 FOR UPDATE;
-- 执行更新操作
UPDATE table_name SET column1 = 'new_value' WHERE id = 1;
COMMIT;

```

### 按锁的使用方式分类

#### 自动锁

在执行 SQL 语句时，MySQL 会根据操作类型自动加锁。例如，执行 `INSERT`、`UPDATE`、`DELETE` 语句时，InnoDB 会自动对相关记录加排他锁。

#### 显式锁

用户通过 SQL 语句手动加锁，如前面提到的 `LOCK TABLES`、`SELECT ... LOCK IN SHARE MODE`、`SELECT ... FOR UPDATE` 等。

### 总结

*   **表级锁**：适合查询多、更新少的场景，如报表系统。
*   **行级锁**：适合高并发、更新频繁的场景，如在线交易系统。
*   **共享锁**：适用于多个事务需要同时读取同一资源的场景。
*   **排他锁**：适用于对资源进行更新操作的场景。


# 悲观锁和乐观锁
在 MySQL 里，乐观锁和悲观锁是两种不同的并发控制机制，用于处理多事务同时访问和修改数据时可能出现的数据不一致问题。下面详细介绍这两种锁。

### 悲观锁

#### 概念

悲观锁的核心思想是“悲观”地认为在并发环境下，其他事务很可能会修改自己正在访问的数据。所以在访问数据时，会先对数据进行加锁，防止其他事务对该数据进行修改，直到当前事务完成操作并释放锁。

#### 实现方式

在 MySQL 中，通常使用 `SELECT ... FOR UPDATE` 语句来实现悲观锁，该语句会对查询结果中的记录加排他锁。需要注意的是，悲观锁一般在事务中使用，并且要确保事务隔离级别不是 `READ UNCOMMITTED`。

#### 示例代码

```sql
-- 开启事务
START TRANSACTION;
-- 使用悲观锁查询商品库存
SELECT stock FROM products WHERE id = 1 FOR UPDATE;
-- 假设这里进行库存更新操作
UPDATE products SET stock = stock - 1 WHERE id = 1;
-- 提交事务，释放锁
COMMIT;

```

在上述示例中，`SELECT ... FOR UPDATE` 语句会对 `id` 为 1 的商品记录加排他锁，其他事务在当前事务提交或回滚之前，无法对该记录进行读写操作。

#### 适用场景

悲观锁适用于写操作频繁、对数据一致性要求高的场景，例如金融交易系统中的账户余额更新。

### 乐观锁

#### 概念

乐观锁的核心思想是“乐观”地认为在并发环境下，其他事务不太可能会修改自己正在访问的数据。所以在访问数据时，不会对数据加锁，而是在更新数据时，检查数据是否被其他事务修改过。如果数据未被修改，则进行更新操作；如果数据已被修改，则放弃更新或重试。

#### 实现方式

在 MySQL 中，乐观锁通常通过在表中添加一个版本号（`version`）字段或时间戳（`timestamp`）字段来实现。每次更新数据时，会比较版本号或时间戳，如果与之前读取的一致，则更新数据并将版本号加 1 或更新时间戳；如果不一致，则表示数据已被其他事务修改，更新失败。

#### 示例代码

```sql
-- 创建带有版本号字段的表
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    stock INT,
    version INT DEFAULT 0
);

-- 插入测试数据
INSERT INTO products (id, name, stock) VALUES (1, 'Apple', 10);

-- 事务 A：读取数据
SELECT id, stock, version FROM products WHERE id = 1;
-- 假设返回结果：id = 1, stock = 10, version = 0

-- 事务 B：读取数据
SELECT id, stock, version FROM products WHERE id = 1;
-- 假设返回结果：id = 1, stock = 10, version = 0

-- 事务 B：更新数据
UPDATE products 
SET stock = stock - 1, version = version + 1 
WHERE id = 1 AND version = 0;
-- 此时 version 变为 1

-- 事务 A：更新数据
UPDATE products 
SET stock = stock - 1, version = version + 1 
WHERE id = 1 AND version = 0;
-- 更新失败，因为 version 已经变为 1

```

#### 适用场景

乐观锁适用于读操作频繁、写操作较少的场景，例如商品信息展示页面的数据更新。

### 总结

*   **悲观锁**：通过加锁保证数据一致性，会降低并发性能，适合写操作频繁、对数据一致性要求高的场景。
*   **乐观锁**：不使用锁，通过版本号或时间戳检查数据是否被修改，并发性能较高，适合读操作频繁、写操作较少的场景。

# 幻读
### 概念

在 MySQL 中，幻读是指在一个事务里，多次执行相同的查询语句，却返回了不同的记录集，仿佛出现了“幻影”记录。具体来说，当一个事务按照某个条件查询数据时，在该事务还未结束时，另一个事务插入了符合相同查询条件的新记录，那么原事务再次执行相同查询时，就会发现多了一些原本不存在的记录，这就是幻读现象。

### 产生原因

幻读主要是由于并发事务对数据的插入操作引起的。在读取数据的事务还未结束时，另一个事务向表中插入了新的数据，并且这些新数据满足原事务的查询条件，从而导致原事务后续的查询结果发生变化。

### 示例场景

以下使用 InnoDB 存储引擎，通过一个具体示例展示幻读现象。

#### 1. 创建测试表

```sql
CREATE TABLE test_table (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO test_table (id, name) VALUES (1, 'Alice'), (2, 'Bob');

```

#### 2. 模拟幻读

开启两个会话（Session A 和 Session B）来模拟幻读场景。

**Session A**

```sql
-- 开启事务，设置隔离级别为可重复读（默认隔离级别，仍可能出现幻读）
START TRANSACTION;
-- 第一次查询
SELECT * FROM test_table WHERE id > 2;
-- 此时结果为空

```

**Session B**

```sql
-- 开启事务
START TRANSACTION;
-- 插入新记录
INSERT INTO test_table (id, name) VALUES (3, 'Charlie');
-- 提交事务
COMMIT;

```

**Session A**

```sql
-- 第二次查询
SELECT * FROM test_table WHERE id > 2;
-- 此时会看到新插入的记录 (3, 'Charlie')，出现幻读
-- 提交事务
COMMIT;

```

### 解决方案

MySQL 的 InnoDB 存储引擎提供了不同的事务隔离级别来解决幻读问题，主要是通过设置 `SERIALIZABLE` 隔离级别或者使用 `Next-Key Lock` 机制。

#### 1. 设置 `SERIALIZABLE` 隔离级别

`SERIALIZABLE` 是最高的事务隔离级别，它会对事务中的所有读操作加共享锁，写操作加排他锁，并且在事务结束前不释放锁，从而避免并发事务的干扰，防止幻读。

```sql
-- 设置事务隔离级别为 SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
-- 执行查询或其他操作
SELECT * FROM test_table WHERE id > 2;
COMMIT;

```

不过，该隔离级别会降低并发性能，因为它会导致事务串行执行。

#### 2. 使用 `Next-Key Lock` 机制

InnoDB 在可重复读隔离级别下，默认使用 `Next-Key Lock` 机制，它是记录锁（Record Lock）和间隙锁（Gap Lock）的组合。记录锁锁定单个行记录，间隙锁锁定一个范围（不包含记录本身），两者结合可以防止其他事务在锁定的范围插入新记录，从而避免幻读。

```sql
START TRANSACTION;
-- 使用 SELECT ... FOR UPDATE 加 Next-Key Lock
SELECT * FROM test_table WHERE id > 2 FOR UPDATE;
-- 执行其他操作
COMMIT;

```

# 事务隔离级别

InnoDB 存储引擎是 MySQL 中常用的存储引擎，它支持四种事务隔离级别，不同的隔离级别在并发控制、数据一致性和性能方面有不同的表现。下面从隔离级别、问题及示例三个维度详细介绍。

### 读未提交（Read Uncommitted）

*   **隔离级别描述**：这是最低的隔离级别，事务在执行过程中可以读取其他事务尚未提交的数据。
*   **可能出现的问题**：会产生脏读、不可重复读和幻读问题。脏读指一个事务读取到另一个事务未提交的数据。
*   **示例**：



```sql
-- Session A
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- 假设返回 balance 为 1000

-- Session B
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE accounts SET balance = 2000 WHERE id = 1;
-- 未提交事务

-- Session A
SELECT balance FROM accounts WHERE id = 1;
-- 可能读到 2000，出现脏读

```

### 读已提交（Read Committed）

*   **隔离级别描述**：事务只能读取其他事务已经提交的数据。
*   **可能出现的问题**：解决了脏读问题，但仍可能出现不可重复读和幻读问题。不可重复读指在一个事务内多次读取同一数据，结果不一致。
*   **示例**：


```sql
-- Session A
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT balance FROM accounts WHERE id = 1;
-- 假设返回 balance 为 1000

-- Session B
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE accounts SET balance = 2000 WHERE id = 1;
COMMIT;

-- Session A
SELECT balance FROM accounts WHERE id = 1;
-- 读到 2000，出现不可重复读

```

### 可重复读（Repeatable Read）

*   **隔离级别描述**：这是 InnoDB 的默认隔离级别，保证在同一个事务中多次读取同一数据的结果是一致的。
*   **可能出现的问题**：解决了脏读和不可重复读问题，在一定程度上减少了幻读的发生。幻读指在一个事务内，多次执行相同的查询，返回的结果集不同。不过 InnoDB 通过 Next-Key Lock 机制基本解决了幻读问题。
*   **示例**：

```sql
-- Session A
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM orders WHERE amount > 1000;
-- 假设返回 3 条记录

-- Session B
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
INSERT INTO orders (amount) VALUES (1500);
COMMIT;

-- Session A
SELECT * FROM orders WHERE amount > 1000;
-- 仍返回 3 条记录，避免了幻读（得益于 Next-Key Lock）

```

### 串行化（Serializable）

*   **隔离级别描述**：最高的隔离级别，事务串行执行，一个事务执行时会对涉及的数据加锁，其他事务必须等待该事务结束才能执行。
*   **可能出现的问题**：解决了脏读、不可重复读和幻读问题，但会严重降低并发性能，可能导致大量的锁等待。
*   **示例**：

```sql
-- Session A
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM products;

-- Session B
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
INSERT INTO products (name) VALUES ('New Product');
-- 会被阻塞，直到 Session A 提交或回滚事务

```

### 总结

| 隔离级别 | 脏读 | 不可重复读 | 幻读 | 并发性能 |
| ------- | --- | --------- | --- | ------- |
| 读未提交 | 可能 | 可能 | 可能 | 高 |
| 读已提交 | 不可能 | 可能 | 可能 | 较高 |
| 可重复读 | 不可能 | 不可能 | 基本不可能 | 一般 |
| 串行化 | 不可能 | 不可能 | 不可能 | 低 |


在实际应用中，需要根据业务场景和对数据一致性、并发性能的要求来选择合适的事务隔离级别。

# 脏读、不可重复读和幻读
脏读、不可重复读和幻读是数据库并发控制中出现的三类数据不一致问题，它们在产生原因、表现形式和影响方面存在差异，下面详细介绍。

### 脏读（Dirty Read）

#### 定义

一个事务读取到另一个事务未提交的数据。由于未提交的数据可能会被回滚，所以读取到这些“脏数据”可能会导致当前事务做出错误决策。

#### 示例场景

假设有一个 `accounts` 表，记录用户账户余额。

```sql
-- 创建表
CREATE TABLE accounts (
    id INT PRIMARY KEY,
    balance DECIMAL(10, 2)
);
-- 插入数据
INSERT INTO accounts (id, balance) VALUES (1, 1000.00);

```

**事务 A**
```sql
START TRANSACTION;
-- 更新余额
UPDATE accounts SET balance = 2000.00 WHERE id = 1;

```

**事务 B**

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
-- 读取未提交的数据
SELECT balance FROM accounts WHERE id = 1; -- 返回 2000.00

```

**事务 A**

```sql
-- 回滚事务
ROLLBACK;

```

**事务 B** 之前读取到的 2000.00 就是脏数据，因为事务 A 回滚后，实际余额还是 1000.00。

#### 影响

脏读可能会让事务基于错误的数据进行后续操作，导致数据逻辑混乱，严重影响数据的一致性。

### 不可重复读（Non-Repeatable Read）

#### 定义

在同一个事务中，多次读取同一行数据，得到不同的结果。通常是由于其他事务对该数据进行了更新或删除操作并提交，导致当前事务后续读取时数据发生变化。

#### 示例场景

还是使用 `accounts` 表。

**事务 A**

```sql
START TRANSACTION;
-- 第一次读取
SELECT balance FROM accounts WHERE id = 1; -- 返回 1000.00

```

**事务 B**

```sql
START TRANSACTION;
-- 更新余额
UPDATE accounts SET balance = 1500.00 WHERE id = 1;
COMMIT;

```

**事务 A**

```sql
-- 第二次读取
SELECT balance FROM accounts WHERE id = 1; -- 返回 1500.00，出现不可重复读
COMMIT;

```

#### 影响

不可重复读会使事务在执行过程中对同一数据的认知发生改变，可能导致业务逻辑出现错误，影响数据的一致性。

### 幻读（Phantom Read）

#### 定义

在同一个事务中，多次执行相同的查询语句，返回的结果集不同。一般是因为其他事务插入了符合当前事务查询条件的新记录，使得当前事务后续查询时发现多了一些原本不存在的记录。

#### 示例场景

假设有一个 `orders` 表，记录订单信息。

```sql
-- 创建表
CREATE TABLE orders (
    id INT PRIMARY KEY,
    amount DECIMAL(10, 2)
);
-- 插入数据
INSERT INTO orders (id, amount) VALUES (1, 500.00);

```

**事务 A**

```sql
START TRANSACTION;
-- 第一次查询
SELECT * FROM orders WHERE amount > 300.00; -- 返回 1 条记录

```

**事务 B**


```sql
START TRANSACTION;
-- 插入新记录
INSERT INTO orders (id, amount) VALUES (2, 400.00);
COMMIT;

```

**事务 A**

```sql
-- 第二次查询
SELECT * FROM orders WHERE amount > 300.00; -- 返回 2 条记录，出现幻读
COMMIT;

```

#### 影响

幻读会让事务在执行过程中对数据集合的认知发生变化，可能导致事务执行结果与预期不符，影响数据的完整性和业务逻辑的正确性。

### 区别总结

| 问题类型 | 产生原因 | 关注重点 | 其他事务操作 | 影响 |
| --- | --- | --- | --- | --- | 
| 脏读 | 读取未提交的数据 | 数据是否为未提交状态 | 更新未提交 | 基于错误数据操作，影响数据一致性 | 
| 不可重复读 | 读取已提交的更新或删除数据 | 同一行数据内容变化 | 更新或删除并提交 | 同一事务内数据认知改变，影响业务逻辑 | 
| 幻读 | 读取已提交的插入数据 | 查询结果集行数变化 | 插入并提交 | 事务内数据集合认知改变，影响业务结果 |

在实际应用中，可通过调整数据库的事务隔离级别来避免这些问题，不同的隔离级别对这三种问题的解决能力不同。


# 索引
MySQL 索引是一种数据结构，用于快速定位和访问数据库表中的特定数据，能够显著提高查询效率。下面从索引类型、创建和使用、优缺点等方面详细介绍。

### 索引类型

#### 1\. 普通索引

最基本的索引类型，没有任何限制，主要用于提高查询效率。创建语法如下：

```sql
-- 创建表时创建普通索引
CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    INDEX index_name (column1)
);

-- 在已存在的表上创建普通索引
CREATE INDEX index_name ON table_name (column1);

-- 使用 ALTER TABLE 创建普通索引
ALTER TABLE table_name ADD INDEX index_name (column1);

```

#### 2\. 唯一索引

索引列的值必须唯一，但允许有空值。如果是组合索引，则列值的组合必须唯一。创建语法如下：


```sql
-- 创建表时创建唯一索引
CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    UNIQUE INDEX index_name (column1)
);

-- 在已存在的表上创建唯一索引
CREATE UNIQUE INDEX index_name ON table_name (column1);

-- 使用 ALTER TABLE 创建唯一索引
ALTER TABLE table_name ADD UNIQUE INDEX index_name (column1);

```

#### 3\. 主键索引

一种特殊的唯一索引，不允许有空值。每个表只能有一个主键索引。创建语法如下：

```sql
-- 创建表时创建主键索引
CREATE TABLE table_name (
    column1 datatype PRIMARY KEY,
    column2 datatype
);

-- 使用 ALTER TABLE 创建主键索引
ALTER TABLE table_name ADD PRIMARY KEY (column1);

```

#### 4\. 全文索引

用于在文本数据类型的列上进行全文搜索。MySQL 支持 `CHAR`、`VARCHAR` 和 `TEXT` 类型的列创建全文索引。创建语法如下：

```sql
-- 创建表时创建全文索引
CREATE TABLE table_name (
    column1 TEXT,
    FULLTEXT INDEX index_name (column1)
);

-- 在已存在的表上创建全文索引
CREATE FULLTEXT INDEX index_name ON table_name (column1);

-- 使用 ALTER TABLE 创建全文索引
ALTER TABLE table_name ADD FULLTEXT INDEX index_name (column1);

```

#### 5\. 组合索引

在多个列上创建的索引，遵循最左前缀原则。创建语法如下：

```sql
-- 创建表时创建组合索引
CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    INDEX index_name (column1, column2)
);

-- 在已存在的表上创建组合索引
CREATE INDEX index_name ON table_name (column1, column2);

-- 使用 ALTER TABLE 创建组合索引
ALTER TABLE table_name ADD INDEX index_name (column1, column2);

```

### 索引的创建和使用建议

*   **选择合适的列创建索引**：经常用于 `WHERE` 子句、`JOIN` 子句和 `ORDER BY` 子句的列适合创建索引。
*   **避免在小表上创建索引**：小表数据量少，全表扫描的效率可能比使用索引更高。
*   **注意索引的维护成本**：插入、更新和删除操作会导致索引的更新，过多的索引会影响这些操作的性能。

### 索引的优缺点

#### 优点

*   **提高查询效率**：通过索引可以快速定位到符合条件的数据，减少全表扫描的开销。
*   **加速排序**：对于 `ORDER BY` 子句，索引可以直接按照索引顺序返回数据，避免额外的排序操作。

#### 缺点

*   **占用额外的存储空间**：索引需要存储在磁盘上，会占用一定的磁盘空间。
*   **降低写操作性能**：插入、更新和删除操作需要同时更新索引，会增加操作的时间开销。

### 查看和删除索引

#### 查看索引

```sql
SHOW INDEX FROM table_name;

```

#### 删除索引


```sql
-- 删除普通索引、唯一索引和全文索引
DROP INDEX index_name ON table_name;

-- 删除主键索引
ALTER TABLE table_name DROP PRIMARY KEY;
```


## 索引优化
MySQL 索引优化对提升数据库查询性能至关重要，以下从不同方面介绍优化策略：

### 合理选择索引列

*   **在高频查询条件列创建索引**：把经常用于 `WHERE`、`JOIN` 和 `ORDER BY` 子句的列作为索引列。例如，在用户表中，若经常按用户 `email` 查询信息，可在 `email` 列创建索引。


```sql
CREATE INDEX idx_email ON users(email);

```

*   **避免在低选择性列创建索引**：像性别列这种只有几个固定值的低选择性列，创建索引效果有限，全表扫描可能更快。

### 组合索引优化

*   **遵循最左前缀原则**：组合索引按创建顺序使用，查询条件需从索引最左列开始，且中间不能跳过。例如，创建组合索引 `(col1, col2, col3)`，查询条件为 `WHERE col1 = 'value1' AND col2 = 'value2'` 能用到该索引，而 `WHERE col2 = 'value2'` 则无法使用。

```sql
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    INDEX idx_customer_order (customer_id, order_date)
);
-- 可使用组合索引
SELECT * FROM orders WHERE customer_id = 1 AND order_date = '2024-01-01';
-- 无法使用组合索引
SELECT * FROM orders WHERE order_date = '2024-01-01';

```

*   **根据查询频率调整列顺序**：将查询中最常出现的列放在组合索引最左侧。

### 索引类型选择

*   **普通索引**：用于一般查询加速，无特殊限制。
*   **唯一索引**：适合要求列值唯一的场景，如用户表的 `username` 列。


```sql
CREATE UNIQUE INDEX idx_username ON users(username);

```

*   **全文索引**：对文本数据进行全文搜索时使用，支持 `CHAR`、`VARCHAR` 和 `TEXT` 类型。


```sql
CREATE FULLTEXT INDEX idx_content ON articles(content);

```

### 索引维护

*   **定期重建索引**：频繁的增删改操作会使索引碎片化，影响性能。可定期重建索引。


```sql
ALTER TABLE table_name ENGINE=InnoDB;

```

*   **分析索引使用情况**：使用 `EXPLAIN` 关键字分析查询语句，查看是否使用了预期索引。

```sql
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

```

### 避免索引失效

*   **避免在索引列使用函数**：对索引列使用函数会使索引失效。

```sql
-- 索引失效
SELECT * FROM users WHERE YEAR(register_date) = 2024;
-- 可优化为
SELECT * FROM users WHERE register_date >= '2024-01-01' AND register_date < '2025-01-01';

```

*   **避免使用 `OR` 连接条件**：若 `OR` 前后条件列不全有索引，会导致索引失效，可拆分成 `UNION` 查询。


```sql
-- 索引可能失效
SELECT * FROM users WHERE id = 1 OR email = 'test@example.com';
-- 优化为
SELECT * FROM users WHERE id = 1
UNION
SELECT * FROM users WHERE email = 'test@example.com';

```

### 覆盖索引

让查询的列都包含在索引中，这样查询时只需扫描索引，无需回表查询数据行，提升查询性能。例如，查询用户 `id` 和 `email`，可创建包含这两列的组合索引。

```sql
CREATE INDEX idx_id_email ON users(id, email);
SELECT id, email FROM users WHERE email = 'test@example.com';

```

### 索引数量控制

索引虽能提高查询性能，但会增加写操作开销和占用存储空间。根据实际业务需求，合理控制索引数量。

## 索引碎片化
在 MySQL 里，索引碎片化指的是索引数据在磁盘上未连续存储，而是分散在不同的磁盘块中，这会影响索引的查询效率。下面从索引碎片化产生的原因、影响以及解决办法几个方面详细介绍。

### 产生原因

*   **频繁的插入、更新和删除操作**：
    *   **插入操作**：新数据插入时，若原索引存储空间已满，数据库会开辟新的磁盘块来存储数据，导致索引数据分散。
    *   **更新操作**：当更新索引列的值时，可能会使数据在索引中的位置发生变化，若新位置没有足够空间，就会导致数据分散存储。
    *   **删除操作**：删除数据后，被删除数据所占用的磁盘空间不会立即被回收，而是处于空闲状态，后续插入新数据时可能会利用这些分散的空闲空间，造成索引碎片化。
*   **表的自增主键特性**： 自增主键按顺序插入数据，看似不会导致碎片化，但在高并发插入场景下，可能会出现页分裂，新的数据页与原数据页不连续，进而引发索引碎片化。
*   **磁盘空间不足**：当磁盘空间紧张时，数据库为新数据分配的存储空间可能不连续，导致索引数据分散存储。

### 影响

*   **查询性能下降**：索引碎片化后，数据库查询时需要在多个分散的磁盘块中读取数据，增加了磁盘 I/O 次数，从而降低查询效率。
*   **存储空间浪费**：碎片化会产生许多空闲的磁盘空间，无法被有效利用，造成存储空间的浪费。
*   **索引维护成本增加**：数据库对碎片化的索引进行维护（如重建、统计信息更新）时，需要处理更多分散的数据，增加了维护的时间和资源消耗。

### 解决办法

#### 重建索引

*   **InnoDB 表**：可以通过 `ALTER TABLE` 语句重建表，从而重建索引。


```sql
ALTER TABLE table_name ENGINE=InnoDB;

```

该语句会重新创建表结构，将数据重新组织存储，消除索引碎片化。

*   **MyISAM 表**：使用 `REPAIR TABLE` 语句来修复并重建索引。


```sql
REPAIR TABLE table_name QUICK;

```

`QUICK` 选项只修复索引树，不检查数据文件。

#### 优化表

使用 `OPTIMIZE TABLE` 语句对表进行优化，该语句会重建表并更新索引统计信息，适用于 InnoDB 和 MyISAM 引擎。


```sql
OPTIMIZE TABLE table_name;

```

不过，`OPTIMIZE TABLE` 对 InnoDB 表的作用与 `ALTER TABLE` 类似，且在执行过程中会锁表，影响业务正常运行，需要在业务低峰期执行。

#### 定期维护

制定合理的数据库维护计划，定期检查和处理索引碎片化问题。可以使用 `SHOW TABLE STATUS` 查看表的碎片化程度，根据结果决定是否进行重建索引或优化表操作。


```sql
SHOW TABLE STATUS LIKE 'table_name';

```

通过观察 `Data_free` 字段的值，若该值较大，说明表存在较多碎片化。


## 字符串索引
在 MySQL 中，字符串类型的列（如 `CHAR`、`VARCHAR`、`TEXT` 等）上创建索引可以显著提升涉及这些列的查询性能。下面从创建、使用、注意事项等方面详细介绍 MySQL 字符串索引。

### 创建字符串索引

#### 普通索引

对于 `CHAR` 和 `VARCHAR` 类型的列，可直接创建普通索引。

```sql
-- 创建表时创建普通索引
CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(50),
    INDEX idx_username (username)
);

-- 在已存在的表上创建普通索引
CREATE INDEX idx_username ON users (username);

-- 使用 ALTER TABLE 创建普通索引
ALTER TABLE users ADD INDEX idx_username (username);

```

#### 前缀索引

当字符串列较长时，创建完整索引会占用大量空间，且影响写入性能。这时可以使用前缀索引，只对字符串的前几个字符创建索引。

```sql
-- 创建表时创建前缀索引
CREATE TABLE articles (
    id INT PRIMARY KEY,
    content TEXT,
    INDEX idx_content (content(100))
);

-- 在已存在的表上创建前缀索引
CREATE INDEX idx_content ON articles (content(100));

-- 使用 ALTER TABLE 创建前缀索引
ALTER TABLE articles ADD INDEX idx_content (content(100));

```

上述示例中，`content(100)` 表示只对 `content` 列的前 100 个字符创建索引。

#### 唯一索引

若要保证字符串列的值唯一，可创建唯一索引。

```sql
-- 创建表时创建唯一索引
CREATE TABLE emails (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    UNIQUE INDEX idx_email (email)
);

-- 在已存在的表上创建唯一索引
CREATE UNIQUE INDEX idx_email ON emails (email);

-- 使用 ALTER TABLE 创建唯一索引
ALTER TABLE emails ADD UNIQUE INDEX idx_email (email);

```

### 使用字符串索引

在查询语句中，合理使用索引列作为查询条件，能让 MySQL 使用索引加速查询。


```sql
-- 使用 username 索引查询用户
SELECT * FROM users WHERE username = 'john_doe';

-- 使用 content 前缀索引查询文章
SELECT * FROM articles WHERE content LIKE 'MySQL%';

```

### 注意事项

#### 索引失效情况

*   **模糊查询以通配符开头**：若 `LIKE` 查询以通配符 `%` 开头，索引将失效。


```sql
-- 索引失效
SELECT * FROM users WHERE username LIKE '%doe';

```

*   **对索引列使用函数**：对索引列使用函数会导致索引失效。

```sql
-- 索引失效
SELECT * FROM users WHERE UPPER(username) = 'JOHN_DOE';

```

#### 前缀索引长度选择

前缀索引长度需要根据实际数据情况进行选择。长度过短，可能导致索引区分度不够，无法有效过滤数据；长度过长，则失去了前缀索引节省空间的优势。可以通过以下步骤选择合适的长度：

1.  计算不同前缀长度下的唯一值数量。


```sql
SELECT COUNT(DISTINCT LEFT(username, 5)) FROM users;
SELECT COUNT(DISTINCT LEFT(username, 10)) FROM users;
-- 以此类推，测试不同长度

```

1.  对比不同长度下的唯一值数量与全量唯一值数量，选择能接近全量唯一值数量的最短前缀长度。

#### 字符集和排序规则

不同的字符集和排序规则会影响索引的存储和查询性能。尽量使用统一的字符集和排序规则，避免在查询时进行字符集转换，影响索引使用效率。

#### 组合索引

在多个字符串列上创建组合索引时，要遵循最左前缀原则。例如，创建组合索引 `(col1, col2)`，查询条件中必须包含 `col1` 才能使用该索引。


```sql
-- 创建组合索引
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    product_name VARCHAR(50),
    INDEX idx_customer_product (customer_name, product_name)
);

-- 可使用组合索引
SELECT * FROM orders WHERE customer_name = 'Alice' AND product_name = 'Laptop';

-- 无法使用组合索引
SELECT * FROM orders WHERE product_name = 'Laptop';

```

## 左前缀原则
MySQL 左前缀原则主要应用于组合索引（联合索引），它是指在使用组合索引进行查询时，MySQL 会从索引的最左列开始依次向右匹配，直到遇到不满足条件的列就停止匹配。下面从概念、原理、应用场景、注意事项几个方面详细介绍。

### 概念

组合索引是在多个列上创建的索引，例如在表 `users` 中对 `(col1, col2, col3)` 三列创建组合索引。左前缀原则规定，查询条件必须从 `col1` 开始，并且按照 `col1`、`col2`、`col3` 的顺序连续使用，索引才会生效。

### 原理

MySQL 组合索引的存储结构类似于 B+ 树，其数据是按照组合索引中列的顺序进行排序的。先根据第一列排序，第一列相同的情况下再按第二列排序，以此类推。因此，只有从最左列开始查询，才能利用这种有序性快速定位数据。

### 应用场景

#### 示例表结构


```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    INDEX idx_name_age (first_name, last_name, age)
);

```

#### 能使用索引的情况

*   **使用最左列查询**

```sql
-- 只使用 first_name 列，能使用组合索引
SELECT * FROM users WHERE first_name = 'John';

```

*   **使用前两列查询**

```sql
-- 使用 first_name 和 last_name 列，能使用组合索引
SELECT * FROM users WHERE first_name = 'John' AND last_name = 'Doe';

```

*   **使用全部列查询**


```sql
-- 使用 first_name、last_name 和 age 列，能使用组合索引
SELECT * FROM users WHERE first_name = 'John' AND last_name = 'Doe' AND age = 30;

```

#### 不能使用索引的情况

*   **跳过最左列**

```sql
-- 跳过 first_name 列，不能使用组合索引
SELECT * FROM users WHERE last_name = 'Doe' AND age = 30;

```

*   **不连续使用列**


```sql
-- 中间跳过 last_name 列，不能使用组合索引
SELECT * FROM users WHERE first_name = 'John' AND age = 30;

```

### 注意事项

#### 模糊查询与左前缀原则

使用 `LIKE` 进行模糊查询时，若通配符 `%` 不在开头，组合索引可以正常使用。

```sql
-- 能使用组合索引
SELECT * FROM users WHERE first_name LIKE 'Jo%';

-- 不能使用组合索引
SELECT * FROM users WHERE first_name LIKE '%oh';

```

#### 索引列使用函数

对索引列使用函数会导致索引失效，即使符合左前缀原则也无法使用索引。


```sql
-- 不能使用组合索引
SELECT * FROM users WHERE UPPER(first_name) = 'JOHN';

```

#### 合理设计组合索引

在设计组合索引时，要根据实际查询需求，将查询中最常出现的列放在最左边，以提高索引的使用效率。同时，避免创建过多的组合索引，因为这会增加写操作的开销和存储空间的占用。


## 回表查询
在 MySQL 里，回表查询是一种常见的查询现象，理解它有助于优化查询性能。下面详细介绍回表查询的概念、产生原因、示例以及优化方法。

### 概念

回表查询指的是在使用非主键索引（辅助索引）进行查询时，通过辅助索引找到满足条件的记录的主键值后，还需要根据这些主键值回到主键索引树中获取完整的记录数据。简单来说，就是先通过辅助索引定位到数据的主键，再依据主键去主键索引里获取完整数据行。

### 产生原因

MySQL 中，表数据通常按照主键顺序以 B+ 树的形式存储，这个 B+ 树被称为聚簇索引（对于 InnoDB 引擎）。而辅助索引的叶子节点存储的是索引列的值和对应的主键值，并非完整的记录数据。当查询的列不在辅助索引中时，就需要根据辅助索引找到的主键值，回到聚簇索引中获取完整的数据，从而产生回表查询。

### 示例

假设有如下表结构：


```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT,
    INDEX idx_name (name)
);

```

执行以下查询语句：


```sql
SELECT * FROM users WHERE name = 'Alice';

```

查询过程如下：

1.  MySQL 先在辅助索引 `idx_name` 上查找 `name = 'Alice'` 的记录，由于辅助索引的叶子节点存储的是 `name` 列的值和对应的 `id`（主键）。
2.  通过 `idx_name` 找到所有 `name = 'Alice'` 记录对应的 `id`。
3.  根据这些 `id` 值，回到聚簇索引（主键索引）中查找完整的记录数据，这个过程就是回表查询。

### 优化方法

#### 使用覆盖索引

覆盖索引指的是查询的列刚好是索引包含的列，这样就无需回表查询。可以通过创建组合索引，让查询的列都包含在索引里。例如，若经常根据 `name` 查询 `age`，可以创建组合索引：


```sql
CREATE INDEX idx_name_age ON users (name, age);

```

执行如下查询：

```sql
SELECT name, age FROM users WHERE name = 'Alice';

```

此时，查询的列 `name` 和 `age` 都在组合索引 `idx_name_age` 中，MySQL 直接从该索引中获取数据，无需回表。

#### 减少查询列

在编写查询语句时，尽量只查询需要的列，避免使用 `SELECT *`。若只需要部分列的数据，可明确列出这些列，减少可能的回表操作。例如：


```sql
-- 只查询 name 列，避免回表
SELECT name FROM users WHERE name = 'Alice';

```

#### 合理设计索引

根据业务查询需求，合理设计索引，将常用的查询条件列和查询结果列组合成索引，提高索引的覆盖度，减少回表的可能性。



