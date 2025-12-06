---
author: djaigo
title: MySQL索引
categories:
  - mysql
tags:
  - mysql
  - 索引
---

# MySQL 索引详解

## 1. 索引基本概念

### 1.1 什么是索引
索引（Index）是数据库中用于快速定位数据的数据结构，类似于书籍的目录。通过索引可以大大提高查询效率，减少数据库的扫描量。

### 1.2 索引的作用
- **提高查询速度**：避免全表扫描，快速定位数据
- **加速排序**：索引本身就是有序的，可以避免排序操作
- **加速连接**：提高表连接（JOIN）的效率
- **保证唯一性**：唯一索引保证数据的唯一性
- **优化分组**：GROUP BY 操作可以利用索引

### 1.3 索引的代价
- **存储空间**：索引需要额外的存储空间
- **维护成本**：数据增删改时需要维护索引
- **更新性能**：索引过多会影响 INSERT、UPDATE、DELETE 的性能

## 2. 索引的数据结构

### 2.1 B+ 树索引（InnoDB 默认）

#### B+ 树特点
- **多路平衡查找树**：每个节点可以有多个子节点
- **所有数据在叶子节点**：非叶子节点只存储索引键值
- **叶子节点有序链表**：便于范围查询
- **树高度低**：通常 3-4 层即可存储大量数据

#### B+ 树结构
```
                    [根节点]
                  /    |    \
            [内部节点] [内部节点] [内部节点]
           /  |  \   /  |  \   /  |  \
    [叶子节点] [叶子节点] [叶子节点] [叶子节点]
      |  |  |   |  |  |   |  |  |   |  |  |
    数据 数据 数据 数据 数据 数据 数据 数据 数据
```

#### B+ 树优势
- **范围查询高效**：叶子节点有序链表，范围查询只需遍历链表
- **磁盘 I/O 少**：树高度低，减少磁盘访问次数
- **适合范围查询**：支持 `BETWEEN`、`>`、`<` 等范围查询
- **全表扫描友好**：叶子节点链表可以顺序扫描

### 2.2 哈希索引（Memory 引擎）

#### 哈希索引特点
- **等值查询快**：O(1) 时间复杂度
- **不支持范围查询**：哈希值无序
- **不支持排序**：哈希值无序
- **不支持部分索引匹配**：必须使用完整索引键

#### 使用场景
- 等值查询频繁的场景
- Memory 引擎表
- InnoDB 自适应哈希索引（内部优化）

### 2.3 全文索引（FULLTEXT）

#### 全文索引特点
- **文本搜索**：支持对文本内容进行全文搜索
- **分词机制**：对文本进行分词处理
- **相关性排序**：支持按相关性排序结果

#### 使用场景
- 文章搜索
- 商品描述搜索
- 日志内容搜索

## 3. 索引分类

### 3.1 按数据结构分类
- **B+ 树索引**：最常用，InnoDB 默认
- **哈希索引**：Memory 引擎
- **全文索引**：MyISAM、InnoDB（5.6+）
- **R-Tree 索引**：空间索引，用于地理数据

### 3.2 按物理存储分类
- **聚簇索引（Clustered Index）**：索引和数据存储在一起
- **非聚簇索引（Non-Clustered Index）**：索引和数据分离存储

### 3.3 按字段特性分类
- **主键索引（PRIMARY KEY）**
- **唯一索引（UNIQUE）**
- **普通索引（INDEX）**
- **全文索引（FULLTEXT）**

### 3.4 按字段数量分类
- **单列索引**：基于单个列
- **组合索引（联合索引）**：基于多个列

## 4. 聚簇索引（Clustered Index）

### 4.1 定义
聚簇索引是指索引和数据行存储在一起的索引结构。在 InnoDB 中，表数据本身就是按照聚簇索引组织的。

### 4.2 特点
- **数据即索引**：索引的叶子节点直接存储完整的数据行
- **一个表只有一个**：每个 InnoDB 表有且仅有一个聚簇索引
- **物理有序**：数据在磁盘上按照索引顺序存储
- **查询效率高**：通过索引可以直接获取数据，无需回表

### 4.3 聚簇索引的选择规则
1. **有主键**：使用主键作为聚簇索引
2. **无主键，有唯一非空索引**：使用第一个唯一非空索引作为聚簇索引
3. **都没有**：InnoDB 自动生成一个隐藏的 6 字节 ROWID 作为聚簇索引

### 4.4 聚簇索引结构
```
聚簇索引 B+ 树：
                    [根节点: 主键值范围]
                  /         |         \
        [内部节点: 主键值] [内部节点] [内部节点]
           /    |    \    /    |    \   /    |    \
    [叶子节点: 完整数据行] [叶子节点] [叶子节点] [叶子节点]
      |完整行| |完整行| |完整行| |完整行| |完整行| |完整行|
```

### 4.5 优势
- **查询速度快**：通过索引直接获取数据，无需回表
- **范围查询高效**：数据物理有序，范围查询效率高
- **排序优化**：数据本身有序，ORDER BY 无需额外排序

### 4.6 劣势
- **插入速度依赖插入顺序**：按主键顺序插入最快，随机插入可能导致页分裂
- **更新主键代价高**：需要移动数据行
- **二级索引需要回表**：二级索引存储主键值，需要回表查询

### 4.7 示例
```sql
-- 创建表，id 作为主键（聚簇索引）
CREATE TABLE user (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100)
) ENGINE=InnoDB;

-- 查询时，通过主键可以直接获取数据
SELECT * FROM user WHERE id = 1;  -- 直接通过聚簇索引获取，无需回表
```

## 5. 二级索引（Secondary Index / Non-Clustered Index）

### 5.1 定义
二级索引（非聚簇索引）是指索引和数据行分离存储的索引结构。索引的叶子节点存储的是主键值，而不是完整的数据行。

### 5.2 特点
- **索引与数据分离**：索引叶子节点存储主键值
- **需要回表**：通过索引找到主键后，需要回表查询完整数据
- **可以有多个**：一个表可以有多个二级索引
- **覆盖索引优化**：如果索引包含查询所需的所有字段，可以避免回表

### 5.3 二级索引结构
```
二级索引 B+ 树：
                    [根节点: 索引列值范围]
                  /         |         \
        [内部节点: 索引列值] [内部节点] [内部节点]
           /    |    \    /    |    \   /    |    \
    [叶子节点: 主键值] [叶子节点] [叶子节点] [叶子节点]
      |PK| |PK| |PK| |PK| |PK| |PK| |PK| |PK| |PK|
      
查询流程：
1. 通过二级索引找到主键值
2. 通过主键值回表查询聚簇索引获取完整数据行
```

### 5.4 回表（Bookmark Lookup）
- **定义**：通过二级索引找到主键值后，再通过主键值查询聚簇索引获取完整数据的过程
- **性能影响**：回表会增加额外的磁盘 I/O，影响查询性能
- **优化方法**：使用覆盖索引，避免回表

### 5.5 覆盖索引（Covering Index）
- **定义**：索引包含了查询所需的所有字段，查询可以直接从索引获取数据，无需回表
- **优势**：避免回表，提高查询效率
- **示例**：
  ```sql
  -- 创建索引
  CREATE INDEX idx_name_email ON user(name, email);
  
  -- 查询只使用索引字段，无需回表
  SELECT name, email FROM user WHERE name = 'John';  -- 覆盖索引，无需回表
  
  -- 查询包含非索引字段，需要回表
  SELECT * FROM user WHERE name = 'John';  -- 需要回表获取其他字段
  ```

### 5.6 示例
```sql
-- 在 name 列上创建二级索引
CREATE INDEX idx_name ON user(name);

-- 查询流程：
-- 1. 通过 idx_name 索引找到 name='John' 对应的主键值（如 id=1）
-- 2. 通过主键值回表查询聚簇索引，获取完整数据行
SELECT * FROM user WHERE name = 'John';
```

## 6. 主键索引（PRIMARY KEY）

### 6.1 定义
主键索引是用于唯一标识表中每一行记录的索引。在 InnoDB 中，主键索引就是聚簇索引。

### 6.2 特点
- **唯一性**：主键值必须唯一，不能为 NULL
- **聚簇索引**：InnoDB 中主键索引就是聚簇索引
- **一个表一个**：每个表只能有一个主键
- **自动创建索引**：定义主键时自动创建主键索引

### 6.3 主键设计原则
- **简短**：主键值应该尽可能短，因为二级索引会存储主键值
- **自增**：使用自增整数作为主键，插入性能好
- **不可变**：主键值不应该被修改
- **业务无关**：尽量使用代理主键，避免使用业务字段

### 6.4 自增主键 vs UUID
| 特性 | 自增主增 | UUID |
|------|---------|------|
| 存储空间 | 4/8 字节 | 36 字节（字符串）或 16 字节（二进制） |
| 插入性能 | 高（顺序插入） | 低（随机插入，页分裂） |
| 二级索引影响 | 小（主键值小） | 大（主键值大） |
| 分布式场景 | 需要额外处理 | 天然支持 |
| 可读性 | 低 | 高 |

### 6.5 示例
```sql
-- 创建表时定义主键
CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(100)
);

-- 或者使用 ALTER TABLE
ALTER TABLE user ADD PRIMARY KEY (id);

-- 查看主键索引
SHOW INDEX FROM user;
```

## 7. 唯一索引（UNIQUE）

### 7.1 定义
唯一索引确保索引列的值唯一，不允许重复值（NULL 值可以有多个）。

### 7.2 特点
- **唯一性约束**：保证索引列的值唯一
- **允许 NULL**：唯一索引允许 NULL 值，可以有多个 NULL
- **二级索引**：唯一索引是二级索引（除非是主键）
- **自动创建索引**：定义唯一约束时自动创建唯一索引

### 7.3 唯一索引 vs 主键索引
| 特性 | 主键索引 | 唯一索引 |
|------|---------|---------|
| 数量限制 | 一个表一个 | 一个表可以有多个 |
| NULL 值 | 不允许 | 允许（可以有多个） |
| 聚簇索引 | 是（InnoDB） | 否（二级索引） |
| 用途 | 唯一标识行 | 保证字段唯一性 |

### 7.4 使用场景
- **邮箱唯一**：用户邮箱必须唯一
- **手机号唯一**：用户手机号必须唯一
- **业务唯一标识**：如订单号、商品编码等

### 7.5 示例
```sql
-- 创建表时定义唯一索引
CREATE TABLE user (
    id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE
);

-- 或者使用 CREATE INDEX
CREATE UNIQUE INDEX idx_email ON user(email);

-- 或者使用 ALTER TABLE
ALTER TABLE user ADD UNIQUE INDEX idx_email (email);

-- 插入重复值会报错
INSERT INTO user (id, email) VALUES (1, 'test@example.com');
INSERT INTO user (id, email) VALUES (2, 'test@example.com');  -- 错误：Duplicate entry
```

## 8. 普通索引（INDEX）

### 8.1 定义
普通索引（非唯一索引）是最基本的索引类型，不强制唯一性约束，主要用于提高查询性能。

### 8.2 特点
- **无唯一性约束**：允许重复值
- **提高查询性能**：加速 WHERE、ORDER BY、GROUP BY 等操作
- **二级索引**：普通索引是二级索引
- **可以有多个**：一个表可以有多个普通索引

### 8.3 使用场景
- **频繁查询字段**：经常在 WHERE 子句中使用的字段
- **排序字段**：经常用于 ORDER BY 的字段
- **连接字段**：经常用于 JOIN 的字段
- **分组字段**：经常用于 GROUP BY 的字段

### 8.4 示例
```sql
-- 创建普通索引
CREATE INDEX idx_name ON user(name);

-- 或者使用 ALTER TABLE
ALTER TABLE user ADD INDEX idx_name (name);

-- 创建组合索引
CREATE INDEX idx_name_email ON user(name, email);

-- 查看索引
SHOW INDEX FROM user;

-- 删除索引
DROP INDEX idx_name ON user;
```

## 9. 组合索引（联合索引）

### 9.1 定义
组合索引（联合索引）是基于多个列创建的索引，按照列的顺序组织。

### 9.2 最左前缀原则（Leftmost Prefix Rule）
组合索引遵循最左前缀原则，即查询条件必须包含索引的最左边的列，才能使用索引。

#### 示例
```sql
-- 创建组合索引 (name, age, email)
CREATE INDEX idx_name_age_email ON user(name, age, email);

-- 可以使用索引的查询
SELECT * FROM user WHERE name = 'John';  -- ✅ 使用索引
SELECT * FROM user WHERE name = 'John' AND age = 25;  -- ✅ 使用索引
SELECT * FROM user WHERE name = 'John' AND age = 25 AND email = 'john@example.com';  -- ✅ 使用索引
SELECT * FROM user WHERE name = 'John' AND email = 'john@example.com';  -- ✅ 使用索引（部分使用）

-- 不能使用索引的查询
SELECT * FROM user WHERE age = 25;  -- ❌ 不包含最左列 name
SELECT * FROM user WHERE email = 'john@example.com';  -- ❌ 不包含最左列 name
SELECT * FROM user WHERE age = 25 AND email = 'john@example.com';  -- ❌ 不包含最左列 name
```

### 9.3 索引列顺序选择
组合索引的列顺序很重要，应该遵循以下原则：
1. **区分度高的列在前**：选择性高的列放在前面
2. **等值查询在前**：等值查询的列放在范围查询的列前面
3. **查询频率高的列在前**：经常使用的列放在前面
4. **排序字段考虑**：如果经常需要排序，考虑将排序字段加入索引

### 9.4 示例
```sql
-- 好的组合索引设计
-- 假设 name 区分度高，age 用于范围查询，email 用于等值查询
CREATE INDEX idx_name_email_age ON user(name, email, age);

-- 查询示例
SELECT * FROM user 
WHERE name = 'John' 
  AND email = 'john@example.com' 
  AND age > 25;  -- 可以使用索引
```

## 10. 索引优化

### 10.1 索引设计原则
1. **选择性高的列**：区分度高的列适合建索引
2. **频繁查询的列**：WHERE、JOIN、ORDER BY 中经常使用的列
3. **避免过多索引**：索引过多会影响写性能
4. **小字段优先**：索引字段应该尽可能小
5. **NOT NULL 优先**：NULL 值会增加索引复杂度

### 10.2 不适合建索引的场景
- **区分度低的列**：如性别、状态等只有几个值的列
- **频繁更新的列**：更新会触发索引维护
- **很少查询的列**：不经常使用的列不需要索引
- **大文本字段**：TEXT、BLOB 等大字段不适合建索引（可以使用前缀索引）

### 10.3 索引失效场景
1. **函数操作**：对索引列使用函数
   ```sql
   SELECT * FROM user WHERE UPPER(name) = 'JOHN';  -- 索引失效
   SELECT * FROM user WHERE name = UPPER('john');  -- 可以使用索引
   ```

2. **类型转换**：隐式类型转换
   ```sql
   -- name 是 VARCHAR 类型
   SELECT * FROM user WHERE name = 123;  -- 索引失效（类型转换）
   SELECT * FROM user WHERE name = '123';  -- 可以使用索引
   ```

3. **前导模糊查询**：LIKE 以 % 开头
   ```sql
   SELECT * FROM user WHERE name LIKE '%John';  -- 索引失效
   SELECT * FROM user WHERE name LIKE 'John%';  -- 可以使用索引
   ```

4. **OR 条件**：OR 连接的条件如果有一个没有索引
   ```sql
   -- name 有索引，age 没有索引
   SELECT * FROM user WHERE name = 'John' OR age = 25;  -- 索引失效
   ```

5. **NOT、!=、<>**：不等于操作
   ```sql
   SELECT * FROM user WHERE name != 'John';  -- 索引失效
   ```

6. **IS NULL / IS NOT NULL**：在某些情况下可能失效
   ```sql
   SELECT * FROM user WHERE name IS NULL;  -- 可能失效
   ```

### 10.4 索引使用分析
```sql
-- 使用 EXPLAIN 分析查询计划
EXPLAIN SELECT * FROM user WHERE name = 'John';

-- 关键字段说明：
-- type: 访问类型（const > eq_ref > ref > range > index > ALL）
-- key: 使用的索引
-- rows: 扫描的行数
-- Extra: 额外信息（Using index 表示覆盖索引）
```

## 11. 前缀索引

### 11.1 定义
前缀索引是指只对字符串的前几个字符建立索引，而不是整个字符串。

### 11.2 使用场景
- **长字符串字段**：如 URL、邮箱、地址等
- **节省存储空间**：减少索引大小
- **提高查询效率**：在某些场景下前缀索引已经足够

### 11.3 前缀长度选择
- **区分度**：前缀长度应该保证足够的区分度
- **平衡**：在区分度和索引大小之间平衡

### 11.4 示例
```sql
-- 创建前缀索引，只索引前 10 个字符
CREATE INDEX idx_email_prefix ON user(email(10));

-- 计算不同前缀长度的区分度
SELECT 
    COUNT(DISTINCT LEFT(email, 5)) / COUNT(*) AS prefix5,
    COUNT(DISTINCT LEFT(email, 10)) / COUNT(*) AS prefix10,
    COUNT(DISTINCT LEFT(email, 20)) / COUNT(*) AS prefix20
FROM user;
```

## 12. 索引维护

### 12.1 查看索引
```sql
-- 查看表的所有索引
SHOW INDEX FROM user;

-- 查看索引统计信息
SHOW INDEX FROM user WHERE Key_name = 'idx_name';

-- 查看索引使用情况
SELECT * FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'database_name' 
  AND TABLE_NAME = 'user';
```

### 12.2 重建索引
```sql
-- 重建索引（InnoDB）
ALTER TABLE user DROP INDEX idx_name;
ALTER TABLE user ADD INDEX idx_name (name);

-- 或者使用 OPTIMIZE TABLE（会重建所有索引）
OPTIMIZE TABLE user;
```

### 12.3 索引统计信息
```sql
-- 更新索引统计信息
ANALYZE TABLE user;

-- 查看索引基数（Cardinality）
SHOW INDEX FROM user;
```

## 13. 索引监控

### 13.1 查看索引使用情况
```sql
-- 查看索引使用统计（需要开启 performance_schema）
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'database_name'
  AND OBJECT_NAME = 'user';
```

### 13.2 识别未使用的索引
```sql
-- 查找可能未使用的索引
SELECT 
    s.TABLE_SCHEMA,
    s.TABLE_NAME,
    s.INDEX_NAME,
    s.CARDINALITY
FROM information_schema.STATISTICS s
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage p
    ON s.TABLE_SCHEMA = p.OBJECT_SCHEMA
    AND s.TABLE_NAME = p.OBJECT_NAME
    AND s.INDEX_NAME = p.INDEX_NAME
WHERE s.TABLE_SCHEMA = 'database_name'
  AND p.INDEX_NAME IS NULL
  AND s.INDEX_NAME != 'PRIMARY';
```

## 14. 总结

### 14.1 索引类型对比
| 索引类型 | 唯一性 | 聚簇/非聚簇 | 数量限制 | NULL 值 |
|---------|--------|------------|---------|---------|
| 主键索引 | ✅ | 聚簇 | 1个 | 不允许 |
| 唯一索引 | ✅ | 非聚簇 | 多个 | 允许 |
| 普通索引 | ❌ | 非聚簇 | 多个 | 允许 |

### 14.2 最佳实践
1. **合理设计主键**：使用自增整数，简短且有序
2. **为频繁查询的列建索引**：WHERE、JOIN、ORDER BY 中的列
3. **使用组合索引**：遵循最左前缀原则，合理设计列顺序
4. **避免过多索引**：索引过多会影响写性能
5. **定期监控索引**：识别未使用的索引并删除
6. **使用覆盖索引**：减少回表操作
7. **注意索引失效场景**：避免函数、类型转换等操作

### 14.3 索引选择建议
- **主键**：自增整数，简短
- **唯一字段**：使用唯一索引
- **频繁查询字段**：使用普通索引
- **多字段查询**：使用组合索引，注意最左前缀原则
- **长字符串**：考虑前缀索引
- **文本搜索**：使用全文索引

索引是数据库性能优化的关键，合理使用索引可以大大提高查询性能，但也要注意索引的维护成本和写性能的影响。
