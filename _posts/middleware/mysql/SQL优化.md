---
author: djaigo
title: SQL优化方法
categories:
  - mysql
date: 2024-01-01 18:00:00
tags:
  - mysql
  - sql
  - optimization
  - performance
---

SQL 优化是数据库性能调优的核心环节。合理的 SQL 优化可以显著提升查询性能，减少资源消耗，提高系统整体响应速度。本文总结了常见的 SQL 优化方法，涵盖索引优化、查询优化、系统调优等多个方面。

## 一、索引优化

### 1.1 为常用字段创建索引

为在 WHERE、JOIN、ORDER BY、GROUP BY 子句中频繁使用的列创建索引，可以避免全表扫描，大幅提升查询性能。

**示例**：
```sql
-- 为 WHERE 条件字段创建索引
CREATE INDEX idx_user_id ON orders(user_id);

-- 为 JOIN 字段创建索引
CREATE INDEX idx_order_id ON order_items(order_id);

-- 为 ORDER BY 字段创建索引
CREATE INDEX idx_created_at ON orders(created_at);
```

### 1.2 合理使用复合索引

当查询经常在多个列一起过滤、排序或分组时，创建复合索引。注意复合索引的列顺序：应将最具选择性的列放在前面。

**示例**：
```sql
-- 查询：WHERE status = 'active' AND user_id = 123 ORDER BY created_at
-- 复合索引列顺序：选择性高的在前
CREATE INDEX idx_status_user_created ON orders(status, user_id, created_at);

-- 遵循最左前缀原则
-- 可以使用索引的查询：
-- WHERE status = 'active'
-- WHERE status = 'active' AND user_id = 123
-- WHERE status = 'active' AND user_id = 123 ORDER BY created_at
```

**最左前缀原则**：
- 复合索引 `(a, b, c)` 可以用于查询 `a`、`a, b`、`a, b, c`
- 但不能用于查询 `b`、`c`、`b, c`

### 1.3 避免过度索引

索引虽然能加快读操作，但会拖慢写操作（INSERT/UPDATE/DELETE），增加存储和维护成本。

**优化建议**：
- 定期检查未使用的索引：`SELECT * FROM sys.schema_unused_indexes;`
- 删除冗余索引
- 使用 MySQL 8.0+ 的隐形索引（Invisible Index）功能测试移除索引的影响

**示例**：
```sql
-- 将索引设为隐形，测试性能影响
ALTER TABLE orders ALTER INDEX idx_old_index INVISIBLE;

-- 如果性能无影响，再删除
ALTER TABLE orders DROP INDEX idx_old_index;
```

### 1.4 选择合适的数据类型

使用尽量小、最合适的数据类型，避免索引大字段或含有很多 NULL 的字段。

**建议**：
- 整型（INT、BIGINT）比字符串快
- VARCHAR 比 TEXT 好
- 日期类型不要存成字符串
- 避免在 TEXT、BLOB 类型上创建索引

### 1.5 使用覆盖索引

覆盖索引是指查询所需的所有列都在索引中，无需回表查询，可以显著提升性能。

**示例**：
```sql
-- 查询只需要 id 和 name，索引包含这两列
CREATE INDEX idx_user_name ON users(id, name);

-- 查询可以使用覆盖索引
SELECT id, name FROM users WHERE name LIKE 'John%';
```

### 1.6 更新统计信息

定期使用 `ANALYZE TABLE` 更新表的统计信息，避免旧统计误导优化器。

```sql
ANALYZE TABLE orders;
```

## 二、查询优化

### 2.1 使用 EXPLAIN 分析执行计划

使用 `EXPLAIN` 或 `EXPLAIN ANALYZE`（MySQL 8.0+）分析 SQL 执行计划，找出性能瓶颈。

**关键字段**：
- `type`：访问类型，应避免 `ALL`（全表扫描）
- `key`：使用的索引
- `rows`：扫描的行数
- `Extra`：额外信息，如 `Using filesort`、`Using temporary`

**示例**：
```sql
EXPLAIN SELECT * FROM orders WHERE user_id = 123;

-- MySQL 8.0+
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;
```

**type 类型（性能从好到差，并说明性能差异）**：

- `system`：极快，仅适用于系统表（类似于只有一行的空表），这种类型几乎没有访问代价，耗时和资源消耗最小，MySQL 直接从表中获取结果并返回。
- `const`：非常快，表示通过主键或唯一索引可以直接定位到一行数据（常用于主键/唯一索引 + 常量条件），不需要扫描多行，通常只读一次磁盘或直接从内存缓存返回，性能和 system 接近。
- `eq_ref`：性能好，适用于多表连接中，对等连接唯一索引（如 join 时主表的某一行在从表中最多对应一行），MySQL 能高效用索引查到结果，扫描和返回的行很少。
- `ref`：性能较好，使用了非唯一索引或前缀索引，可能返回多行。扫描的行比 eq_ref 多，依然是基于索引做查找，但无法精确到唯一一行，随着匹配行数的增多，性能下降。
- `range`：性能一般，利用索引做范围扫描（如 BETWEEN、>、<、IN），只扫描满足范围条件的索引部分，相较于全表/全索引扫描性能高，但会随着范围的扩大扫描行数增多。
- `index`：性能较差，扫描整个索引树（全索引扫描），不会回表。虽然比全表扫描快（因为只读索引而不读全表数据行），但如果数据量大同样耗资源。常见于只用到索引字段，未用到表中其他字段的查询。
- `ALL`：最慢，表示全表扫描，即逐行遍历整张表，索引完全未被利用。数据量越大，性能损耗越明显，极易成为瓶颈，应尽量避免。

**小结**：`system` ≈ `const` > `eq_ref` > `ref` > `range` > `index` > `ALL`。后者性能依次递减，越靠后的类型扫描/处理的数据量越大，占用的 CPU、IO 资源越多。

### 2.2 避免 SELECT *

只选择必要的列，减少 I/O、网络传输和内存使用。

**示例**：
```sql
-- 不推荐
SELECT * FROM users WHERE id = 123;

-- 推荐
SELECT id, name, email FROM users WHERE id = 123;
```

### 2.3 避免在索引列上使用函数

在索引列上使用函数会导致索引失效，应尽量避免。

**示例**：
```sql
-- 不推荐：索引失效
SELECT * FROM users WHERE UPPER(name) = 'JOHN';
SELECT * FROM users WHERE DATE(created_at) = '2024-01-01';

-- 推荐：使用函数索引（MySQL 8.0+）
CREATE INDEX idx_upper_name ON users((UPPER(name)));
SELECT * FROM users WHERE UPPER(name) = 'JOHN';

-- 或者重写查询
SELECT * FROM users WHERE created_at >= '2024-01-01' AND created_at < '2024-01-02';
```

### 2.4 避免 LIKE '%abc' 前导通配符

前导通配符会导致索引失效，应尽量避免。

**示例**：
```sql
-- 不推荐：索引失效
SELECT * FROM users WHERE name LIKE '%john';

-- 推荐：可以使用索引
SELECT * FROM users WHERE name LIKE 'john%';

-- 如果必须使用前导通配符，考虑全文索引
CREATE FULLTEXT INDEX idx_name_fulltext ON users(name);
SELECT * FROM users WHERE MATCH(name) AGAINST('john' IN BOOLEAN MODE);
```

### 2.5 使用 JOIN 替代子查询

在大多数情况下，JOIN 比子查询性能更好。

**示例**：
```sql
-- 不推荐：使用子查询
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders WHERE status = 'completed');

-- 推荐：使用 JOIN
SELECT DISTINCT u.* FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status = 'completed';
```

### 2.6 优化 LIMIT 分页

对于大表的分页查询，使用基于排序键的分页（keyset pagination）替代 OFFSET。

**示例**：
```sql
-- 不推荐：OFFSET 越大性能越差
SELECT * FROM orders ORDER BY id LIMIT 10000, 20;

-- 推荐：使用 keyset pagination
SELECT * FROM orders 
WHERE id > 10000 
ORDER BY id 
LIMIT 20;
```

### 2.7 使用 UNION ALL 替代 UNION

如果不需要去重，使用 `UNION ALL` 比 `UNION` 性能更好。

**示例**：
```sql
-- 不推荐：会去重，性能较差
SELECT id FROM table1
UNION
SELECT id FROM table2;

-- 推荐：不去重，性能更好
SELECT id FROM table1
UNION ALL
SELECT id FROM table2;
```

### 2.8 避免使用 NOT IN 和 !=

`NOT IN` 和 `!=` 通常会导致全表扫描，应尽量避免。

**示例**：
```sql
-- 不推荐
SELECT * FROM users WHERE status != 'deleted';
SELECT * FROM users WHERE id NOT IN (1, 2, 3);

-- 推荐：使用 NOT EXISTS 或 LEFT JOIN
SELECT * FROM users u
WHERE NOT EXISTS (SELECT 1 FROM deleted_users d WHERE d.id = u.id);
```

### 2.9 合理使用 EXISTS

对于判断存在性的查询，`EXISTS` 通常比 `IN` 性能更好。

**示例**：
```sql
-- 推荐：使用 EXISTS
SELECT * FROM users u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- 而不是
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders);
```

### 2.10 批量操作优化

对于批量 INSERT、UPDATE、DELETE 操作，使用批量语句可以提升性能。

**示例**：
```sql
-- 不推荐：逐条插入
INSERT INTO users (name, email) VALUES ('John', 'john@example.com');
INSERT INTO users (name, email) VALUES ('Jane', 'jane@example.com');

-- 推荐：批量插入
INSERT INTO users (name, email) VALUES
('John', 'john@example.com'),
('Jane', 'jane@example.com');

-- 批量更新
UPDATE users SET status = 'active' WHERE id IN (1, 2, 3, 4, 5);
```

## 三、MySQL 优化器优化操作

MySQL 优化器是数据库执行查询前的核心组件，负责将 SQL 语句转换为高效的执行计划。优化器会在多个阶段对查询进行优化，包括常量折叠、查询重写、子查询优化等。了解优化器的工作机制有助于编写更高效的 SQL。

### 3.1 常量折叠（Constant Folding）

常量折叠是指优化器在编译阶段对表达式中的常量进行计算和简化，将常量比较转换为更简单的形式，甚至直接移除永远为真或永远为假的条件。

**优化示例**：

```sql
-- 原始查询
SELECT * FROM users WHERE age < 256 AND age > -1;

-- 如果 age 是 TINYINT UNSIGNED NOT NULL（范围 0-255）
-- 优化器会折叠为：
SELECT * FROM users WHERE 1;  -- 或者直接移除 WHERE 条件

-- 如果 age 是 INT，但条件永远为假
SELECT * FROM users WHERE 1 = 0;
-- 优化器可能直接返回空结果集，不执行表扫描
```

**常量传播**：

```sql
-- 原始查询
SELECT * FROM orders WHERE user_id = 123 AND status = 'active';

-- 如果优化器知道 user_id = 123 时 status 只能是 'pending'
-- 可能重写为更简单的条件
```

### 3.2 查询重写（Query Rewrite）

优化器会将 SQL 查询在逻辑上等价地重写为另一种结构，以简化执行路径或降低资源开销。

#### 3.2.1 IN 转换为 EXISTS

```sql
-- 原始查询
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders WHERE status = 'completed');

-- 优化器可能重写为
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.user_id = u.id AND o.status = 'completed'
);
```

#### 3.2.2 子查询转换为 JOIN（Semijoin）

对于 `IN`、`EXISTS` 类子查询，优化器会尝试转换为 semijoin，将子查询的表结构"拉出"到外层查询。

```sql
-- 原始查询
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders WHERE amount > 1000);

-- 优化器可能转换为 semijoin
SELECT DISTINCT u.* FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.amount > 1000;
```

**Semijoin 策略**：

- **Table Pullout（表拉出）**：将子查询中的表移到外层，充分利用连接顺序优化
- **Duplicate Weedout（去重）**：避免 semijoin 返回重复值
- **FirstMatch**：扫描子查询表时一旦找到匹配就停止
- **LooseScan**：使用索引挑选每组中的第一个值

#### 3.2.3 派生表合并（Derived Table Merge）

对于 FROM 子句中的子查询（派生表），优化器会尝试将其合并到外层查询。

```sql
-- 原始查询
SELECT * FROM (
    SELECT user_id, SUM(amount) as total 
    FROM orders 
    GROUP BY user_id
) AS t
WHERE t.total > 1000;

-- 优化器可能合并为
SELECT user_id, SUM(amount) as total 
FROM orders 
GROUP BY user_id
HAVING SUM(amount) > 1000;
```

**优势**：
- 可以将外层的 WHERE 条件"下推"到派生表中
- 减少中间结果集的大小
- 避免创建临时表

#### 3.2.4 视图合并（View Merge）

类似于派生表合并，优化器会尝试将视图定义合并到查询中。

```sql
-- 定义视图
CREATE VIEW active_users AS 
SELECT * FROM users WHERE status = 'active';

-- 查询视图
SELECT * FROM active_users WHERE age > 18;

-- 优化器可能合并为
SELECT * FROM users WHERE status = 'active' AND age > 18;
```

### 3.3 子查询优化（Subquery Optimization）

#### 3.3.1 子查询物化（Materialization）

对于非相关子查询（不依赖外层查询），优化器可以将子查询先执行一次，将结果存入临时表，然后外层查询通过临时表进行 JOIN 或查找。

```sql
-- 原始查询
SELECT * FROM users 
WHERE id IN (
    SELECT user_id FROM orders 
    WHERE created_at > '2024-01-01'
);

-- 如果子查询是非相关的，优化器可能：
-- 1. 先执行子查询，创建临时表
-- 2. 在临时表上创建索引
-- 3. 外层查询通过索引查找
```

**适用条件**：
- 子查询是非相关的（不引用外层表的列）
- 子查询结果集不会太大
- 子查询执行成本低于多次执行

#### 3.3.2 标量子查询优化

对于返回单个值的标量子查询，优化器可以将其展开或提前计算。

```sql
-- 原始查询
SELECT id, name, 
    (SELECT COUNT(*) FROM orders WHERE user_id = users.id) as order_count
FROM users;

-- 优化器可能转换为 JOIN
SELECT u.id, u.name, COALESCE(o.order_count, 0) as order_count
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) as order_count 
    FROM orders 
    GROUP BY user_id
) o ON u.id = o.user_id;
```

#### 3.3.3 条件下推（Predicate Pushdown）

优化器会将条件推到最早执行的位置，减少中间结果集。

```sql
-- 原始查询
SELECT * FROM (
    SELECT * FROM orders WHERE status = 'pending'
) AS t
WHERE t.amount > 1000;

-- 优化器下推条件后
SELECT * FROM orders 
WHERE status = 'pending' AND amount > 1000;
```

### 3.4 JOIN 优化

#### 3.4.1 JOIN 顺序优化

优化器会根据表的统计信息、索引情况、表大小等因素，选择最优的 JOIN 顺序。

```sql
-- 原始查询
SELECT * FROM users u
JOIN orders o ON u.id = o.user_id
JOIN products p ON o.product_id = p.id
WHERE u.status = 'active';

-- 优化器可能调整 JOIN 顺序
-- 先过滤 users（使用索引），再 JOIN 其他表
```

#### 3.4.2 JOIN 算法选择

优化器会根据表大小、索引情况选择不同的 JOIN 算法：

- **Nested Loop Join**：适用于小表或索引良好的情况
- **Block Nested Loop Join**：适用于没有索引的情况
- **Hash Join**（MySQL 8.0.18+）：适用于大表 JOIN

### 3.5 索引优化选择

#### 3.5.1 索引选择

优化器会根据查询条件、表统计信息、索引选择性等因素，选择最优的索引。

```sql
-- 查询
SELECT * FROM orders 
WHERE user_id = 123 AND status = 'active' 
ORDER BY created_at DESC;

-- 优化器可能选择：
-- 1. idx_user_id（如果选择性高）
-- 2. idx_user_status（复合索引）
-- 3. idx_user_status_created（覆盖索引）
```

#### 3.5.2 索引合并（Index Merge）

当单个索引无法满足查询需求时，优化器可能使用多个索引，然后合并结果。

```sql
-- 查询
SELECT * FROM orders 
WHERE user_id = 123 OR status = 'active';

-- 优化器可能：
-- 1. 使用 idx_user_id 查找 user_id = 123 的行
-- 2. 使用 idx_status 查找 status = 'active' 的行
-- 3. 合并两个结果集（去重）
```

### 3.6 其他优化操作

#### 3.6.1 ORDER BY 优化

```sql
-- 如果 ORDER BY 的列有索引，可能直接使用索引排序
SELECT * FROM orders ORDER BY created_at DESC;

-- 如果 LIMIT 很小，可能使用 filesort 但只排序前 N 行
SELECT * FROM orders ORDER BY created_at DESC LIMIT 10;
```

#### 3.6.2 GROUP BY 优化

```sql
-- 如果 GROUP BY 的列有索引，可能使用索引进行分组
SELECT user_id, COUNT(*) FROM orders GROUP BY user_id;

-- 优化器可能使用临时表或文件排序
-- 如果结果集很大，可能使用松散索引扫描（Loose Index Scan）
```

#### 3.6.3 DISTINCT 优化

```sql
-- 如果 DISTINCT 的列有唯一索引，优化器知道结果必然唯一
SELECT DISTINCT user_id FROM orders;

-- 可能转换为 GROUP BY
SELECT user_id FROM orders GROUP BY user_id;
```

#### 3.6.4 LIMIT 优化

```sql
-- 如果 ORDER BY 和 WHERE 条件都有索引，可能提前停止扫描
SELECT * FROM orders 
WHERE status = 'active' 
ORDER BY created_at DESC 
LIMIT 10;
```

### 3.7 优化器控制开关

MySQL 提供了 `optimizer_switch` 变量来控制优化器的行为：

```sql
-- 查看当前优化器开关
SHOW VARIABLES LIKE 'optimizer_switch';

-- 常用开关：
-- semijoin: 控制 semijoin 转换
-- materialization: 控制子查询物化
-- subquery_to_derived: 控制标量子查询转派生表（MySQL 8.0.16+）
-- index_merge: 控制索引合并
-- use_index_extensions: 使用索引扩展

-- 修改优化器开关
SET SESSION optimizer_switch = 'semijoin=on,materialization=on';
```

### 3.8 查看优化器优化过程

#### 3.8.1 使用 EXPLAIN

```sql
-- 查看执行计划
EXPLAIN SELECT * FROM users WHERE id IN (
    SELECT user_id FROM orders WHERE status = 'active'
);

-- 查看优化器重写后的查询（MySQL 8.0.18+）
EXPLAIN FORMAT=JSON SELECT ...;
```

#### 3.8.2 使用 Optimizer Trace

```sql
-- 启用优化器跟踪
SET optimizer_trace = 'enabled=on';
SET optimizer_trace_max_mem_size = 1000000;

-- 执行查询
SELECT * FROM users WHERE id IN (
    SELECT user_id FROM orders WHERE status = 'active'
);

-- 查看优化器跟踪信息
SELECT * FROM information_schema.optimizer_trace;
```

### 3.9 优化器限制与注意事项

1. **统计信息准确性**：优化器依赖表的统计信息，需要定期执行 `ANALYZE TABLE` 更新统计信息

2. **优化器可能选择错误**：在某些情况下，优化器可能选择非最优的执行计划，可以使用优化器提示（hints）强制指定

3. **复杂查询优化限制**：对于非常复杂的查询（如多表 JOIN、复杂子查询），优化器可能无法找到最优计划

4. **版本差异**：不同 MySQL 版本的优化器能力不同，新版本通常有更好的优化能力

### 3.10 优化器提示（Optimizer Hints）

当优化器选择非最优计划时，可以使用优化器提示：

```sql
-- 强制使用特定索引
SELECT * FROM orders USE INDEX (idx_user_id) WHERE user_id = 123;

-- 强制 JOIN 顺序
SELECT * FROM users u 
STRAIGHT_JOIN orders o ON u.id = o.user_id;

-- 禁用索引合并
SELECT * FROM orders 
IGNORE INDEX FOR JOIN (idx_status) 
WHERE user_id = 123 OR status = 'active';
```

## 四、系统级优化

### 3.1 InnoDB Buffer Pool 调优

`innodb_buffer_pool_size` 是 InnoDB 最重要的参数，通常应设置为系统内存的 70-80%。

```sql
-- 查看当前配置
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

-- 建议配置（在 my.cnf 中）
-- innodb_buffer_pool_size = 8G
```

### 3.2 慢查询日志

启用慢查询日志，定期分析慢 SQL。

```sql
-- 启用慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1;  -- 记录超过 1 秒的查询

-- 查看慢查询日志位置
SHOW VARIABLES LIKE 'slow_query_log_file';
```

### 3.3 使用 Performance Schema

使用 Performance Schema 监控查询性能、锁等待、I/O 等情况。

```sql
-- 查看最耗时的查询
SELECT * FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 10;
```

### 3.4 事务优化

保持事务尽可能短，避免长时间占用锁资源。

**建议**：
- 事务中只包含必要的操作
- 避免在事务中进行耗时操作（如网络请求、文件操作）
- 合理设置事务隔离级别

### 3.5 连接池配置

合理配置连接池大小，避免连接数过多或过少。

```sql
-- 查看最大连接数
SHOW VARIABLES LIKE 'max_connections';

-- 查看当前连接数
SHOW STATUS LIKE 'Threads_connected';
```

## 五、表结构优化

### 4.1 规范化与反规范化

- **规范化**：减少数据冗余，对写操作有利
- **反规范化**：适当冗余，对读操作有利，但需要控制一致性成本

根据业务场景选择合适的策略。

### 4.2 使用分区表

对于大表，使用分区可以缩小扫描范围，提升查询性能。

**示例**：
```sql
-- 按时间范围分区
CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,
    created_at DATETIME
) PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);
```

### 4.3 垂直分割

将不常用的列拆分到单独的表中，减少主表大小。

**示例**：
```sql
-- 主表：常用字段
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- 扩展表：不常用字段
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    bio TEXT,
    avatar_url VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 六、优化实践流程

### 5.1 诊断阶段

1. 启用慢查询日志，收集慢 SQL
2. 使用 `EXPLAIN` 分析执行计划
3. 使用 Performance Schema 分析资源消耗

### 5.2 索引优化

1. 确保主键存在
2. 为常用 WHERE、JOIN、ORDER BY、GROUP BY 字段创建索引
3. 创建合适的复合索引
4. 删除未使用的索引

### 5.3 SQL 重写

1. 避免 SELECT *
2. 避免在索引列上使用函数
3. 使用 JOIN 替代子查询
4. 优化分页查询
5. 使用批量操作

### 5.4 系统调优

1. 调整 InnoDB Buffer Pool 大小
2. 优化连接池配置
3. 调整其他系统参数

### 5.5 架构优化

1. 读写分离
2. 使用缓存（Redis、Memcached）
3. 分库分表
4. 使用 CDN 加速静态资源

## 七、常见优化场景

### 6.1 大表查询优化

```sql
-- 场景：查询最近 30 天的订单
-- 优化前：全表扫描
SELECT * FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);

-- 优化后：使用索引 + 限制返回列
CREATE INDEX idx_created_at ON orders(created_at);
SELECT id, user_id, amount, created_at 
FROM orders 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
LIMIT 1000;
```

### 6.2 JOIN 优化

```sql
-- 场景：查询用户及其订单信息
-- 优化：确保 JOIN 字段有索引
CREATE INDEX idx_user_id ON orders(user_id);

SELECT u.name, o.amount, o.created_at
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
ORDER BY o.created_at DESC
LIMIT 100;
```

### 6.3 GROUP BY 优化

```sql
-- 场景：统计每个用户的订单数量
-- 优化：为 GROUP BY 字段创建索引
CREATE INDEX idx_user_created ON orders(user_id, created_at);

SELECT user_id, COUNT(*) as order_count
FROM orders
WHERE created_at >= '2024-01-01'
GROUP BY user_id
HAVING order_count > 10;
```

## 八、监控与维护

### 7.1 定期检查索引使用情况

```sql
-- 查看未使用的索引（MySQL 8.0+）
SELECT * FROM sys.schema_unused_indexes;

-- 查看索引统计信息
SHOW INDEX FROM orders;
```

### 7.2 定期更新统计信息

```sql
-- 更新表统计信息
ANALYZE TABLE orders;

-- 优化表（重建索引、整理碎片）
OPTIMIZE TABLE orders;
```

### 7.3 监控慢查询

定期分析慢查询日志，找出需要优化的 SQL。

```bash
# 使用 pt-query-digest 分析慢查询日志
pt-query-digest slow-query.log
```

## 九、总结

SQL 优化是一个持续的过程，需要：

1. **诊断**：使用工具找出性能瓶颈
2. **优化**：从索引、SQL、系统配置等多方面优化
3. **测试**：验证优化效果
4. **监控**：持续监控性能指标
5. **迭代**：根据业务变化不断调整

记住：**过早优化是万恶之源**。应该先找出真正的性能瓶颈，再进行有针对性的优化。同时，优化时要考虑业务场景，不能为了性能而牺牲数据一致性和业务逻辑的正确性。

## 参考文献

- [MySQL 官方文档 - 优化索引](https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html)
- [MySQL 官方文档 - 查询优化](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
- [MySQL Performance Schema](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html)
