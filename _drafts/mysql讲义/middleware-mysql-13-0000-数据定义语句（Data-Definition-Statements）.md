---
author: djaigo
title: middleware-mysql-14-0000-数据定义语句（Data-Definition-Statements）
categories:
  - null
date: 2023-03-29 19:52:40
tags:
---
Data Definition Statements 定义相关结构，包括：数据库（DATABASE）、事件（EVENT）、方法（FUNCTION）、索引（INDEX）、存储过程（PROCEDURE）、数据表（TABLE）、触发器（TRIGGER）、视图（VIEW）等。

* 数据库（DATABASE），
* 事件（EVENT）
* 方法（FUNCTION）
* 索引（INDEX），快速查找表数据的额外存储
* 存储过程（PROCEDURE），事务执行批量语句
* 数据表（TABLE），存储数据的基本单位
* 触发器（TRIGGER），在某些语句执行时的附加处理逻辑
* 视图（VIEW）

# CREATE
CREATE 用于创建相关结构。

```sql
CREATE DATABASE
CREATE EVENT
CREATE FUNCTION
CREATE INDEX
CREATE PROCEDURE
CREATE TABLE
CREATE TRIGGER
CREATE VIEW
```

## CREATE DATABASE
```sql
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [create_option] ...

create_option: [DEFAULT] {
    CHARACTER SET [=] charset_name
  | COLLATE [=] collation_name
}
```

CREATE DATABASE 创建一个具有给定名称的数据库。要使用此语句，您需要数据库的 CREATE 权限。 CREATE SCHEMA 是 CREATE DATABASE 的同义词。
MySQL 中的数据库被实现为包含与数据库中的表相对应的文件的目录。因为最初创建数据库时没有表，所以CREATE DATABASE语句只在MySQL数据目录和db.opt文件下创建一个目录。
如果您在数据目录下手动创建一个目录（例如，使用 mkdir），服务器会将其视为数据库目录并显示在 SHOW DATABASES 的输出中。
创建数据库时，让服务器管理目录和其中的文件。直接操作数据库目录和文件可能会导致不一致和意外结果。
MySQL 对数据库的数量没有限制。底层文件系统可能对目录数量有限制。

## CREATE EVENT
```sql
CREATE
    [DEFINER = user]
    EVENT
    [IF NOT EXISTS]
    event_name
    ON SCHEDULE schedule
    [ON COMPLETION [NOT] PRESERVE]
    [ENABLE | DISABLE | DISABLE ON SLAVE]
    [COMMENT 'string']
    DO event_body;

schedule: {
    AT timestamp [+ INTERVAL interval] ...
  | EVERY interval
    [STARTS timestamp [+ INTERVAL interval] ...]
    [ENDS timestamp [+ INTERVAL interval] ...]
}

interval:
    quantity {YEAR | QUARTER | MONTH | DAY | HOUR | MINUTE |
              WEEK | SECOND | YEAR_MONTH | DAY_HOUR | DAY_MINUTE |
              DAY_SECOND | HOUR_MINUTE | HOUR_SECOND | MINUTE_SECOND}
```

CREATE EVENT 语句创建并安排新事件。除非启用事件计划程序，否则事件不会运行。CREATE EVENT 需要在其中创建事件的模式的 EVENT 权限。如果存在 DEFINER 子句，所需的权限取决于用户值。
有效 CREATE EVENT 语句的最低要求如下：
* 关键字 CREATE EVENT 加上事件名称，它在数据库模式中唯一标识事件。
* ON SCHEDULE 子句，它确定事件执行的时间和频率。
* DO 子句，其中包含事件要执行的 SQL 语句。

## CREATE PROCEDURE and FUNCTION
```sql
CREATE
    [DEFINER = user]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body

CREATE
    [DEFINER = user]
    FUNCTION sp_name ([func_parameter[,...]])
    RETURNS type
    [characteristic ...] routine_body

proc_parameter:
    [ IN | OUT | INOUT ] param_name type

func_parameter:
    param_name type

type:
    Any valid MySQL data type

characteristic: {
    COMMENT 'string'
  | LANGUAGE SQL
  | [NOT] DETERMINISTIC
  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
  | SQL SECURITY { DEFINER | INVOKER }
}

routine_body:
    Valid SQL routine statement
```
这些语句用于创建存储例程（存储过程或函数）。也就是说，指定的例程对服务器来说是已知的。默认情况下，存储例程与默认数据库相关联。要将例程与给定数据库显式关联，请在创建时将名称指定为 db_name.sp_name。
CREATE FUNCTION 语句也用于 MySQL 以支持可加载函数。可加载函数可以被视为外部存储函数。存储函数与可加载函数共享它们的命名空间。
要调用存储过程，请使用 CALL 语句（请参阅第 13.2.1 节“CALL 语句”）。要调用存储函数，请在表达式中引用它。该函数在表达式计算期间返回一个值。
CREATE PROCEDURE 和 CREATE FUNCTION 需要 CREATE ROUTINE 权限。如果存在 DEFINER 子句，所需的权限取决于用户值。如果启用了二进制日志记录，则 CREATE FUNCTION 可能需要 SUPER 权限。
如果例程名称与内置 SQL 函数的名称相同，则会出现语法错误，除非您在定义例程或稍后调用例程时在名称和后面的括号之间使用空格。因此，请避免将现有 SQL 函数的名称用于您自己的存储例程。
括号内的参数列表必须始终存在。如果没有参数，则应使用 () 的空参数列表。参数名称不区分大小写。默认情况下，每个参数都是一个 IN 参数。要为参数指定其他方式，请在参数名称前使用关键字 OUT 或 INOUT。IN 参数将值传递到过程中。该过程可能会修改该值，但当过程返回时，调用者看不到该修改。 OUT 参数将过程中的值传递回调用者。它的初始值在过程中为 NULL，当过程返回时，它的值对调用者可见。 INOUT 参数由调用者初始化，可以由过程修改，并且过程返回时调用者可以看到过程所做的任何更改。
对于每个 OUT 或 INOUT 参数，在调用该过程的 CALL 语句中传递一个用户定义的变量，以便您可以在该过程返回时获取它的值。如果您从另一个存储过程或函数中调用该过程，您还可以将例程参数或局部例程变量作为 OUT 或 INOUT 参数传递。如果您从触发器中调用该过程，您还可以将 NEW.col_name 作为 OUT 或 INOUT 参数传递。
## CREATE INDEX
```sql
CREATE [UNIQUE | FULLTEXT | SPATIAL] INDEX index_name
    [index_type]
    ON tbl_name (key_part,...)
    [index_option]
    [algorithm_option | lock_option] ...

key_part:
    col_name [(length)] [ASC | DESC]

index_option: {
    KEY_BLOCK_SIZE [=] value
  | index_type
  | WITH PARSER parser_name
  | COMMENT 'string'
}

index_type:
    USING {BTREE | HASH}

algorithm_option:
    ALGORITHM [=] {DEFAULT | INPLACE | COPY}

lock_option:
    LOCK [=] {DEFAULT | NONE | SHARED | EXCLUSIVE}
```

CREATE INDEX 映射到 ALTER TABLE 语句以创建索引。 CREATE INDEX 不能用于创建 PRIMARY KEY；请改用 ALTER TABLE。InnoDB 支持虚拟列上的二级索引。启用 `innodb_stats_persistent` 设置后，在 InnoDB 表上创建索引后运行 ANALYZE TABLE 语句。
形式为 (`key_part1`, `key_part2`, ...) 的索引规范创建具有多个键部分的索引。索引键值是通过连接给定键部分的值形成的。例如 (col1, col2, col3) 指定一个多列索引，其索引键由 col1、col2 和 col3 的值组成。`key_part` 规范可以以 ASC 或 DESC 结尾。这些关键字允许用于未来的扩展，以指定升序或降序索引值存储。目前，它们被解析但被忽略；索引值始终按升序存储。

创建索引包括以下方面：
* Column Prefix Key Parts，允许列前缀部分作为索引
* Unique Indexes，创建一个约束，使得索引中的所有值都必须不同。如果您尝试添加具有与现有行匹配的键值的新行，则会发生错误。如果为 UNIQUE 索引中的列指定前缀值，则列值在前缀长度内必须是唯一的。 UNIQUE 索引允许可以包含 NULL 的列有多个 NULL 值。
* Full-Text Indexes，仅支持 InnoDB 和 MyISAM 表，并且只能包含 CHAR、VARCHAR 和 TEXT 列。索引总是发生在整个列上；不支持列前缀索引，如果指定，任何前缀长度都会被忽略。
* Spatial Indexes，MyISAM、InnoDB、NDB 和 ARCHIVE 存储引擎支持空间列，例如 POINT 和 GEOMETRY。 但是，对空间列索引的支持因引擎而异。
* Index Options，索引选项，设置索引类型、描述信息等
* Table Copying and Locking Options，可以给出 ALGORITHM 和 LOCK 子句来影响表复制方法和在修改其索引时读取和写入表的并发级别。它们与 ALTER TABLE 语句具有相同的含义。

InnoDB 存储引擎索引特征

| Index Class | Index Type | Stores NULL VALUES | Permits Multiple NULL Values | IS NULL Scan Type | IS NOT NULL Scan Type |
| --- | --- | --- | --- | --- | --- |
| Primary key | `BTREE` | No | No | N/A | N/A |
| Unique | `BTREE` | Yes | Yes | Index | Index |
| Key | `BTREE` | Yes | Yes | Index | Index |
| `FULLTEXT` | N/A | Yes | Yes | Table | Table |
| `SPATIAL` | N/A | No | No | N/A | N/A |

MyISAM 存储引擎索引特征

|Index Class | Index Type | Stores NULL VALUES | Permits Multiple NULL Values | IS NULL Scan Type | IS NOT NULL Scan Type |
| --- | --- | --- | --- | --- | --- |
| Primary key | `BTREE` | No | No | N/A | N/A |
| Unique | `BTREE` | Yes | Yes | Index | Index |
| Key | `BTREE` | Yes | Yes | Index | Index |
| `FULLTEXT` | N/A | Yes | Yes | Table | Table |
| `SPATIAL` | N/A | No | No | N/A | N/A |

Memory 存储引擎索引特征

| Index Class | Index Type | Stores NULL VALUES | Permits Multiple NULL Values | IS NULL Scan Type | IS NOT NULL Scan Type |
| --- | --- | --- | --- | --- | --- |
| Primary key | `BTREE` | No | No | N/A | N/A |
| Unique | `BTREE` | Yes | Yes | Index | Index |
| Key | `BTREE` | Yes | Yes | Index | Index |
| Primary key | `HASH` | No | No | N/A | N/A |
| Unique | `HASH` | Yes | Yes | Index | Index |
| Key | `HASH` | Yes | Yes | Index | Index |

## CREATE TABLE
```sql
CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    (create_definition,...)
    [table_options]
    [partition_options]

CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    [(create_definition,...)]
    [table_options]
    [partition_options]
    [IGNORE | REPLACE]
    [AS] query_expression

CREATE [TEMPORARY] TABLE [IF NOT EXISTS] tbl_name
    { LIKE old_tbl_name | (LIKE old_tbl_name) }

create_definition: {
    col_name column_definition
  | {INDEX | KEY} [index_name] [index_type] (key_part,...)
      [index_option] ...
  | {FULLTEXT | SPATIAL} [INDEX | KEY] [index_name] (key_part,...)
      [index_option] ...
  | [CONSTRAINT [symbol]] PRIMARY KEY
      [index_type] (key_part,...)
      [index_option] ...
  | [CONSTRAINT [symbol]] UNIQUE [INDEX | KEY]
      [index_name] [index_type] (key_part,...)
      [index_option] ...
  | [CONSTRAINT [symbol]] FOREIGN KEY
      [index_name] (col_name,...)
      reference_definition
  | CHECK (expr)
}

column_definition: {
    data_type [NOT NULL | NULL] [DEFAULT default_value]
      [AUTO_INCREMENT] [UNIQUE [KEY]] [[PRIMARY] KEY]
      [COMMENT 'string']
      [COLLATE collation_name]
      [COLUMN_FORMAT {FIXED | DYNAMIC | DEFAULT}]
      [STORAGE {DISK | MEMORY}]
      [reference_definition]
  | data_type
      [COLLATE collation_name]
      [GENERATED ALWAYS] AS (expr)
      [VIRTUAL | STORED] [NOT NULL | NULL]
      [UNIQUE [KEY]] [[PRIMARY] KEY]
      [COMMENT 'string']
      [reference_definition]
}

data_type:
    (see Chapter 11, Data Types)

key_part:
    col_name [(length)] [ASC | DESC]

index_type:
    USING {BTREE | HASH}

index_option: {
    KEY_BLOCK_SIZE [=] value
  | index_type
  | WITH PARSER parser_name
  | COMMENT 'string'
}

reference_definition:
    REFERENCES tbl_name (key_part,...)
      [MATCH FULL | MATCH PARTIAL | MATCH SIMPLE]
      [ON DELETE reference_option]
      [ON UPDATE reference_option]

reference_option:
    RESTRICT | CASCADE | SET NULL | NO ACTION | SET DEFAULT

table_options:
    table_option [[,] table_option] ...

table_option: {
    AUTO_INCREMENT [=] value
  | AVG_ROW_LENGTH [=] value
  | [DEFAULT] CHARACTER SET [=] charset_name
  | CHECKSUM [=] {0 | 1}
  | [DEFAULT] COLLATE [=] collation_name
  | COMMENT [=] 'string'
  | COMPRESSION [=] {'ZLIB' | 'LZ4' | 'NONE'}
  | CONNECTION [=] 'connect_string'
  | {DATA | INDEX} DIRECTORY [=] 'absolute path to directory'
  | DELAY_KEY_WRITE [=] {0 | 1}
  | ENCRYPTION [=] {'Y' | 'N'}
  | ENGINE [=] engine_name
  | INSERT_METHOD [=] { NO | FIRST | LAST }
  | KEY_BLOCK_SIZE [=] value
  | MAX_ROWS [=] value
  | MIN_ROWS [=] value
  | PACK_KEYS [=] {0 | 1 | DEFAULT}
  | PASSWORD [=] 'string'
  | ROW_FORMAT [=] {DEFAULT | DYNAMIC | FIXED | COMPRESSED | REDUNDANT | COMPACT}
  | STATS_AUTO_RECALC [=] {DEFAULT | 0 | 1}
  | STATS_PERSISTENT [=] {DEFAULT | 0 | 1}
  | STATS_SAMPLE_PAGES [=] value
  | tablespace_option
  | UNION [=] (tbl_name[,tbl_name]...)
}

partition_options:
    PARTITION BY
        { [LINEAR] HASH(expr)
        | [LINEAR] KEY [ALGORITHM={1 | 2}] (column_list)
        | RANGE{(expr) | COLUMNS(column_list)}
        | LIST{(expr) | COLUMNS(column_list)} }
    [PARTITIONS num]
    [SUBPARTITION BY
        { [LINEAR] HASH(expr)
        | [LINEAR] KEY [ALGORITHM={1 | 2}] (column_list) }
      [SUBPARTITIONS num]
    ]
    [(partition_definition [, partition_definition] ...)]

partition_definition:
    PARTITION partition_name
        [VALUES
            {LESS THAN {(expr | value_list) | MAXVALUE}
            |
            IN (value_list)}]
        [[STORAGE] ENGINE [=] engine_name]
        [COMMENT [=] 'string' ]
        [DATA DIRECTORY [=] 'data_dir']
        [INDEX DIRECTORY [=] 'index_dir']
        [MAX_ROWS [=] max_number_of_rows]
        [MIN_ROWS [=] min_number_of_rows]
        [TABLESPACE [=] tablespace_name]
        [(subpartition_definition [, subpartition_definition] ...)]

subpartition_definition:
    SUBPARTITION logical_name
        [[STORAGE] ENGINE [=] engine_name]
        [COMMENT [=] 'string' ]
        [DATA DIRECTORY [=] 'data_dir']
        [INDEX DIRECTORY [=] 'index_dir']
        [MAX_ROWS [=] max_number_of_rows]
        [MIN_ROWS [=] min_number_of_rows]
        [TABLESPACE [=] tablespace_name]

tablespace_option:
    TABLESPACE tablespace_name [STORAGE DISK]
  | [TABLESPACE tablespace_name] STORAGE MEMORY

query_expression:
    SELECT ...   (Some valid select or union statement)
```

CREATE TABLE 创建一个具有给定名称的表。您必须拥有该表的 CREATE 权限。
MySQL 对表的数量没有限制。底层文件系统可能对表示表的文件数量有限制。各个存储引擎可能会施加特定于引擎的约束。 InnoDB 允许多达 40 亿个表。
创建数据表语句包括下面几个方面：
* Table Name，表名可以指定为 `db_name.tbl_name` 以在特定数据库中创建表。无论是否有默认数据库，这都有效，假设数据库存在。如果您使用带引号的标识符，请分别引用数据库和表名。
* Temporary Tables，创建表时可以使用 TEMPORARY 关键字。 TEMPORARY 表仅在当前会话中可见，并在会话关闭时自动删除。
* Table Cloning and Copying，复制表相关操作，可选 LIKE 、 AS 、 IGNORE | REPLACE
* Column Data Types and Attributes，每个表有 4096 列的硬性限制，但给定表的有效最大值可能更少，每列都有相应的描述信息，包括：type、NOT NULL | NULL、DEFAULT、AUTO_INCREMENT、COMMENT、STORAGE等。
* Indexes and Foreign Keys，描述索引和外键的信息，包括：PRIMARY KEY、KEY | INDEX、UNIQUE、FULLTEXT、SPATIAL、FOREIGN KEY、索引类型、索引选项等
* Table Options，描述数据表的相关属性，包括：ENGINE、AUTO_INCREMENT（初始自增值）、CHARACTER SET、COMMENT等
* Table Partitioning，表分区属性，包括：
  * `PARTITION BY`、
  * `HASH(_expr_)`、
  * `KEY(_column_list_)`、
  * `RANGE(_expr_)`、
  * `RANGE COLUMNS(_column_list_)`、
  * `LIST(_expr_)`、
  * `LIST COLUMNS(_column_list_)`、
  * `PARTITIONS _num_`、
  * `SUBPARTITION BY`、
  * `_partition_definition_`，描述分区相关属性，包括：`PARTITION  _partition_name_`、`VALUES`、`[STORAGE] ENGINE`、`COMMENT`等

* 表名可以指定为 db_name.tbl_name 以在特定数据库中创建表。无论是否有默认数据库，这都有效，假设数据库存在。如果您使用带引号的标识符，请分别引用数据库和表名。例如，写 `mydb`.`mytbl`，而不是 `mydb.mytbl`。
* 创建表时可以使用 TEMPORARY 关键字。 TEMPORARY 表仅在当前会话中可见，并在会话关闭时自动删除。
* 使用 CREATE TABLE ... LIKE 根据另一个表的定义创建一个空表，包括原始表中定义的任何列属性和索引。
* 要从一个表创建另一个表，请在 CREATE TABLE 语句的末尾添加一个 SELECT 语句：
```sql
CREATE TABLE new_tbl AS SELECT * FROM orig_tbl;
```
* IGNORE 和 REPLACE 选项指示在使用 SELECT 语句复制表时如何处理重复唯一键值的行。
* 每个表有 4096 列的硬性限制，但给定表的有效最大值可能更小。
* data_type 表示列定义中的数据类型。
  * 一些属性并不适用于所有数据类型。 AUTO_INCREMENT 仅适用于整数和浮点类型。 DEFAULT 不适用于 BLOB、TEXT、GEOMETRY 和 JSON 类型。
  * 字符数据类型（CHAR、VARCHAR、TEXT 类型、ENUM、SET 和任何同义词）可以包括 CHARACTER SET 以指定列的字符集。 CHARSET 是 CHARACTER SET 的同义词。可以使用 COLLATE 属性以及任何其他属性指定字符集的排序规则。
  * 无法为 JSON 列编制索引。您可以通过在从 JSON 列中提取标量值的生成列上创建索引来解决此限制。
* 如果既未指定 NULL 也未指定 NOT NULL，则将该列视为已指定 NULL。
* 指定列的默认值。如果启用了 `NO_ZERO_DATE` 或 `NO_ZERO_IN_DATE` SQL 模式，并且日期值默认值根据该模式不正确，如果未启用严格 SQL 模式，则 CREATE TABLE 会产生警告，如果启用了严格模式，则会产生错误。例如，启用 `NO_ZERO_IN_DATE` 后，c1 DATE DEFAULT '2010-00-00' 会产生警告。
* 整数或浮点列可以具有附加属性 `AUTO_INCREMENT`。当您将 NULL（推荐）或 0 值插入索引 `AUTO_INCREMENT` 列时，该列将设置为下一个序列值。通常这是 value+1，其中 value 是表中当前列的最大值。 `AUTO_INCREMENT` 序列以 1 开头。要在插入行后检索 `AUTO_INCREMENT` 值，请使用 `LAST_INSERT_ID()` SQL 函数或 `mysql_insert_id()` C API 函数。如果启用了 `NO_AUTO_VALUE_ON_ZERO` SQL 模式，则可以将 `AUTO_INCREMENT` 列中的 0 存储为 0，而无需生成新的序列值。每个表只能有一个 `AUTO_INCREMENT` 列，它必须被索引，并且不能有 DEFAULT 值。 `AUTO_INCREMENT` 列只有在仅包含正值时才能正常工作。插入一个负数被认为是插入一个非常大的正数。这样做是为了避免当数字从正数“换行”到负数时出现精度问题，并确保您不会意外获得包含 0 的 `AUTO_INCREMENT` 列。
* 可以使用 COMMENT 选项指定列的注释，最长为 1024 个字符。注释由 SHOW CREATE TABLE 和 SHOW FULL COLUMNS 语句显示。它也显示在信息模式 COLUMNS 表的 COLUMN_COMMENT 列中。
* 在 NDB Cluster 中，还可以使用 `COLUMN_FORMAT` 为 NDB 表的各个列指定数据存储格式。允许的列格式为 FIXED、DYNAMIC 和 DEFAULT。 FIXED 用于指定固定宽度存储，DYNAMIC 允许列为可变宽度，DEFAULT 导致列使用由列的数据类型决定的固定宽度或可变宽度存储（可能被 `ROW_FORMAT` 说明符覆盖） 。`COLUMN_FORMAT` 目前对使用 NDB 以外的存储引擎的表的列没有影响。在 MySQL 5.7 及更高版本中，`COLUMN_FORMAT` 被静默忽略。
* 对于 NDB 表，可以使用 STORAGE 子句指定列是存储在磁盘上还是内存中。 STORAGE DISK 导致列存储在磁盘上，STORAGE MEMORY 导致使用内存存储。使用的 CREATE TABLE 语句必须仍然包含一个 TABLESPACE 子句。
```sql
mysql> CREATE TABLE t1 (
    ->     c1 INT STORAGE DISK,
    ->     c2 INT STORAGE MEMORY
    -> ) ENGINE NDB;
ERROR 1005 (HY000): Can't create table 'c.t1' (errno: 140)

mysql> CREATE TABLE t1 (
    ->     c1 INT STORAGE DISK,
    ->     c2 INT STORAGE MEMORY
    -> ) TABLESPACE ts_1 ENGINE NDB;
Query OK, 0 rows affected (1.06 sec)
```
* GENERATED ALWAYS 用于指定生成的列表达式。

## CREATE TRIGGER
```sql
CREATE
    [DEFINER = user]
    TRIGGER trigger_name
    trigger_time trigger_event
    ON tbl_name FOR EACH ROW
    [trigger_order]
    trigger_body

trigger_time: { BEFORE | AFTER }

trigger_event: { INSERT | UPDATE | DELETE }

trigger_order: { FOLLOWS | PRECEDES } other_trigger_name
```

CREATE TRIGGER 创建一个新触发器。触发器是与表关联的命名数据库对象，当表发生特定事件时激活。触发器与名为 tbl_name 的表相关联，该表必须引用永久表。您不能将触发器与 TEMPORARY 表或视图相关联。触发器名称存在于 DATABASE 命名空间中，这意味着所有触发器在 DATABASE 中必须具有唯一名称。不同 DATABASE 中的触发器可以具有相同的名称。
CREATE TRIGGER 需要与触发器关联的表的 TRIGGER 权限。如果存在 DEFINER 子句，所需的权限取决于用户值，如果启用了二进制日志记录，CREATE TRIGGER 可能需要 SUPER 权限。
DEFINER 子句确定在触发器激活时检查访问权限时要使用的安全上下文。
trigger_time 是触发器动作时间。它可以是 BEFORE 或 AFTER，表示触发器在要修改的每一行之前或之后激活。
基本列值检查发生在触发器激活之前，因此您不能使用 BEFORE 触发器将不适合列类型的值转换为有效值。
`trigger_event` 指示激活触发器的操作类型。这些 `trigger_event` 值是允许的：
* INSERT：只要有新行插入表中（例如，通过 INSERT、LOAD DATA 和 REPLACE 语句），触发器就会激活。
* UPDATE：只要一行被修改（例如，通过 UPDATE 语句），触发器就会激活。
* DELETE：只要从表中删除一行（例如，通过 DELETE 和 REPLACE 语句），触发器就会激活。表上的 DROP TABLE 和 TRUNCATE TABLE 语句不会激活此触发器，因为它们不使用 DELETE。删除分区也不会激活 DELETE 触发器。

trigger_event 与其说是一种文字类型的激活触发器的 SQL 语句，不如说是一种表操作类型。例如，INSERT 触发器不仅对 INSERT 语句激活，而且对 LOAD DATA 语句激活，因为这两个语句都将行插入表中。
一个可能令人困惑的示例是 INSERT INTO ... ON DUPLICATE KEY UPDATE ... 语法：对每一行激活 BEFORE INSERT 触发器，然后是 AFTER INSERT 触发器或 BEFORE UPDATE 和 AFTER UPDATE 触发器，具体取决于该行是否有重复键。

> 级联的外键操作不会激活触发器。

可以为具有相同触发事件和动作时间的给定表定义多个触发器。例如，您可以为一个表设置两个 BEFORE UPDATE 触发器。默认情况下，具有相同触发事件和动作时间的触发器按创建顺序激活。要影响触发器顺序，请指定指示 FOLLOWS 或 PRECEDES 的 trigger_order 子句以及也具有相同触发器事件和操作时间的现有触发器的名称。使用 FOLLOWS，新触发器在现有触发器之后激活。使用 PRECEDES，新触发器在现有触发器之前激活。

trigger_body 是触发器激活时要执行的语句。要执行多条语句，请使用 BEGIN ... END 复合语句结构。这也使您能够使用存储例程中允许的相同语句。

在触发器主体中，您可以使用别名 OLD 和 NEW 来引用主题表（与触发器关联的表）中的列。 `OLD.col_name` 指的是现有行在更新或删除之前的列。 `NEW.col_name` 是指要插入的新行或更新后的现有行的列。触发器不能使用 `NEW.col_name` 或使用 `OLD.col_name` 来引用生成的列。

MySQL 在创建触发器时存储有效的 sql_mode 系统变量设置，并且始终使用此设置执行触发器主体，而不管触发器开始执行时当前服务器 SQL 模式如何。

DEFINER 子句指定在触发器激活时检查访问权限时要使用的 MySQL 帐户。如果存在 DEFINER 子句，则用户值应该是指定为 `'user_name'@'host_name'`、`CURRENT_USER` 或 `CURRENT_USER() `的 MySQL 帐户。允许的用户值取决于拥有的权限。如果省略 DEFINER 子句，则默认定义者是执行 `CREATE TRIGGER` 语句的用户。这与明确指定 `DEFINER = CURRENT_USER` 相同。
MySQL 在检查触发器权限时会考虑 DEFINER 用户，如下所示：
* 在 CREATE TRIGGER 时，发出该语句的用户必须具有 TRIGGER 权限。
* 在触发器激活时，将针对 DEFINER 用户检查权限。此用户必须具有以下权限：
  * 主题表的 TRIGGER 权限。
  * 如果在触发器主体中使用 `OLD.col_name` 或 `NEW.col_name` 引用表列，则主题表的 SELECT 权限。
  * 如果表列是触发器主体中 `SET NEW.col_name = value` 赋值的目标，则主题表的更新权限。
  * 触发器执行的语句通常需要任何其他权限。

在触发器体内，CURRENT_USER 函数返回用于在触发器激活时检查权限的帐户。这是 DEFINER 用户，而不是其操作导致触发器被激活的用户。

如果您使用 LOCK TABLES 锁定具有触发器的表，则触发器中使用的表也会被锁定。

## CREATE VIEW
```sql
CREATE
    [OR REPLACE]
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = user]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION]
```

CREATE VIEW 语句创建一个新视图，或者如果给出了 OR REPLACE 子句则替换现有视图。如果视图不存在，CREATE OR REPLACE VIEW 与 CREATE VIEW 相同。如果视图确实存在，则 CREATE OR REPLACE VIEW 将替换它。
`select_statement` 是提供视图定义的 SELECT 语句。 （从视图中选择实际上是使用 SELECT 语句。）`select_statement` 可以从基表或其他视图中选择。

视图定义在创建时“冻结”，不受后续对基础表定义的更改的影响。例如，如果视图在表上定义为 SELECT *，则以后添加到表中的新列不会成为视图的一部分，并且从表中删除的列会导致从视图中进行选择时出错。

ALGORITHM 子句影响 MySQL 处理视图的方式。 DEFINER 和 SQL SECURITY 子句指定在视图调用时检查访问权限时要使用的安全上下文。可以给出 WITH CHECK OPTION 子句来限制对视图引用的表中的行的插入或更新。这些子句将在本节后面描述。

CREATE VIEW 语句需要视图的 CREATE VIEW 权限，以及 SELECT 语句选择的每个列的一些权限。对于 SELECT 语句中别处使用的列，您必须具有 SELECT 权限。如果存在 OR REPLACE 子句，您还必须具有该视图的 DROP 权限。如果存在 DEFINER 子句，所需的权限取决于用户值。

引用视图时，将进行权限检查。

视图属于数据库。默认情况下，在默认数据库中创建一个新视图。要在给定数据库中显式创建视图，请使用 `db_name.view_name` 语法用数据库名称限定视图名称。
SELECT 语句中未限定的表或视图名称也相对于默认数据库进行解释。通过使用适当的数据库名称限定表或视图名称，视图可以引用其他数据库中的表或视图。
在数据库中，数据表和视图共享相同的命名空间，因此基表和视图不能重名。
SELECT 语句检索的列可以是对表列的简单引用，也可以是使用函数、常量值、运算符等的表达式。

视图必须具有唯一的列名且不能重复，就像基表一样。默认情况下，SELECT 语句检索的列名用于视图列名。要为视图列定义显式名称，请将可选的 `column_list` 子句指定为逗号分隔的标识符列表。 `column_list` 中的名称数必须与 SELECT 语句检索的列数相同。

可以从多种 SELECT 语句创建视图。它可以引用基表或其他视图。它可以使用连接、UNION 和子查询。 SELECT 甚至不需要引用任何表。

视图定义受以下限制：
* SELECT 语句不能引用系统变量或用户定义的变量。
* 在存储程序中，SELECT 语句不能引用程序参数或局部变量。
* SELECT 语句不能引用准备好的语句参数。
* 定义中引用的任何表或视图都必须存在。如果在创建视图后删除定义引用的表或视图，则使用该视图会导致错误。要检查此类问题的视图定义，请使用 CHECK TABLE 语句。
* 该定义不能引用 TEMPORARY 表，并且您不能创建 TEMPORARY 视图。
* 您不能将触发器与视图相关联。
* 根据 64 个字符的最大列长度（而不是 256 个字符的最大别名长度）检查 SELECT 语句中列名的别名。

视图定义中允许使用 ORDER BY，但如果您使用具有自己的 ORDER BY 的语句从视图中进行选择，则会忽略它。
对于定义中的其他选项或子句，将它们添加到引用视图的语句的选项或子句中，但效果未定义。例如，如果视图定义包含 LIMIT 子句，并且您使用具有自己的 LIMIT 子句的语句从视图中进行选择，则未定义应用哪个限制。同样的原则适用于 SELECT 关键字后的 ALL、DISTINCT 或 `SQL_SMALL_RESULT` 等选项，以及 INTO、FOR UPDATE、LOCK IN SHARE MODE 和 PROCEDURE 等子句。
如果您通过更改系统变量来更改查询处理环境，则可能会影响从视图获得的结果。

当执行引用视图的语句时，DEFINER 和 SQL SECURITY 子句确定在检查视图的访问权限时使用哪个 MySQL 帐户。有效的 SQL SECURITY 特征值为 DEFINER（默认值）和 INVOKER。这些表明所需的权限必须分别由定义或调用视图的用户持有。

如果存在 DEFINER 子句，则用户值应该是指定为 `'user_name'@'host_name'`、`CURRENT_USER` 或 `CURRENT_USER()` 的 MySQL 帐户。允许的用户值取决于您拥有的权限。
如果省略 DEFINER 子句，则默认定义者是执行 CREATE VIEW 语句的用户。这与明确指定 `DEFINER = CURRENT_USER` 相同。

MySQL 像这样检查视图权限：
* 在视图定义时，视图创建者必须具有使用视图访问的顶级对象所需的权限。例如，如果视图定义引用表列，则创建者必须对定义的选择列表中的每一列具有某些特权，并且对定义中其他地方使用的每一列具有 SELECT 特权。如果定义引用存储函数，则只能检查调用该函数所需的权限。函数调用时所需的权限只能在函数执行时进行检查：对于不同的调用，可能会采用函数内的不同执行路径。
* 引用视图的用户必须具有访问它的适当权限（SELECT 从中选择，INSERT 插入其中，等等。）
* 当一个视图被引用时，根据 SQL SECURITY 特征是 DEFINER 还是 INVOKER，检查视图访问的对象的权限是否与视图 DEFINER 帐户或调用者拥有的权限。
* 如果对视图的引用导致存储函数的执行，则对函数内执行的语句进行特权检查取决于函数 SQL SECURITY 特征是 DEFINER 还是 INVOKER。如果安全特征是 DEFINER，则函数以 DEFINER 帐户的权限运行。如果该特征是 INVOKER，则该函数以视图的 SQL SECURITY 特征确定的权限运行。

视图的 DEFINER 和 SQL SECURITY 子句是标准 SQL 的扩展。在标准 SQL 中，视图是使用 SQL SECURITY DEFINER 的规则处理的。该标准规定视图的定义者（与视图架构的所有者相同）获得视图的适用权限（例如，SELECT）并可以授予它们。 MySQL 没有模式“所有者”的概念，因此 MySQL 添加了一个子句来标识定义者。 DEFINER 子句是一个扩展，其目的是拥有标准所具有的内容；也就是说，谁定义了视图的永久记录。这就是默认 DEFINER 值是视图创建者的帐户的原因。

选的 ALGORITHM 子句是 MySQL 对标准 SQL 的扩展。它会影响 MySQL 处理视图的方式。 ALGORITHM 采用三个值：MERGE、TEMPTABLE 或 UNDEFINED。
一些视图是可更新的。也就是说，您可以在 UPDATE、DELETE 或 INSERT 等语句中使用它们来更新基础表的内容。对于可更新的视图，视图中的行与基础表中的行之间必须存在一对一的关系。还有某些其他构造使视图不可更新。
视图中生成的列被认为是可更新的，因为它可以分配给它。但是，如果显式更新此类列，则唯一允许的值为 DEFAULT。

可以为可更新视图提供 WITH CHECK OPTION 子句，以防止插入或更新行，但 select_statement 中 WHERE 子句为真的行除外。
在可更新视图的 WITH CHECK OPTION 子句中，当根据另一个视图定义视图时，LOCAL 和 CASCADED 关键字确定检查测试的范围。 LOCAL 关键字将 CHECK OPTION 限制为仅用于正在定义的视图。 CASCADED 也会导致对基础视图的检查进行评估。当两个关键字都没有给出时，默认为 CASCADED。
# ALTER
ALTER 用于修改相关结构。
```sql
ALTER DATABASE
ALTER EVENT
ALTER FUNCTION
ALTER PROCEDURE
ALTER TABLE
ALTER TABLESPACE
ALTER VIEW
```

## ALTER DATABASE
```sql
ALTER {DATABASE | SCHEMA} [db_name]
    alter_option ...
ALTER {DATABASE | SCHEMA} db_name
    UPGRADE DATA DIRECTORY NAME

alter_option: {
    [DEFAULT] CHARACTER SET [=] charset_name
  | [DEFAULT] COLLATE [=] collation_name
}
```

ALTER DATABASE 使您能够更改数据库的整体特征。这些特征存储在数据库目录中的 db.opt 文件中。此语句需要对数据库的 ALTER 权限。 ALTER SCHEMA 是 ALTER DATABASE 的同义词。
数据库名称可以从第一个语法中省略，在这种情况下，该语句适用于默认数据库。如果没有默认数据库，则会发生错误。

CHARACTER SET 子句更改默认数据库字符集。 COLLATE 子句更改默认的数据库排序规则。
要查看可用的字符集和排序规则，请分别使用 SHOW CHARACTER SET 和 SHOW COLLATION 语句。
创建例程时使用数据库默认值的存储例程包括这些默认值作为其定义的一部分。 （在存储例程中，如果未明确指定字符集或排序规则，则具有字符数据类型的变量使用数据库默认值）如果更改默认字符集或对于数据库的排序规则，必须删除并重新创建任何要使用新默认值的存储例程。

## ALTER EVENT
```sql
ALTER
    [DEFINER = user]
    EVENT event_name
    [ON SCHEDULE schedule]
    [ON COMPLETION [NOT] PRESERVE]
    [RENAME TO new_event_name]
    [ENABLE | DISABLE | DISABLE ON SLAVE]
    [COMMENT 'string']
    [DO event_body]
```

ALTER EVENT 语句更改现有事件的一个或多个特征，而无需删除并重新创建它。每个 DEFINER、ON SCHEDULE、ON COMPLETION、COMMENT、ENABLE / DISABLE 和 DO 子句的语法与用于 CREATE EVENT 时完全相同。 

任何用户都可以更改在该用户具有 EVENT 权限的数据库上定义的事件。当用户执行成功的 ALTER EVENT 语句时，该用户将成为受影响事件的定义者。
可以在单个语句中更改事件的多个特征。
ON SCHEDULE 子句可以使用涉及内置 MySQL 函数和用户变量的表达式来获取它包含的任何时间戳或间隔值。您不能在此类表达式中使用存储例程或可加载函数，也不能使用任何表引用；但是，您可以使用 SELECT FROM DUAL。对于 ALTER EVENT 和 CREATE EVENT 语句都是如此。在这种情况下，对存储例程、可加载函数和表的引用是明确不允许的，并且会因错误而失败（参见错误 #22830）。
尽管在其 DO 子句中包含另一个 ALTER EVENT 语句的 ALTER EVENT 语句看似成功，但当服务器尝试执行生成的计划事件时，执行会失败并出现错误。
要重命名事件，请使用 ALTER EVENT 语句的 RENAME TO 子句。还可以使用 ALTER EVENT ... RENAME TO ... 和 `db_name.event_name` 表示法将事件移动到不同的数据库

## ALTER FUNCTION
```sql
```

## ALTER INSTANCE
```sql
```

## ALTER LOGFILE GROUP
```sql
```

## ALTER PROCEDURE
```sql
```

## ALTER SERVER
```sql
```

## ALTER TABLE
```sql
```

## ALTER TABLESPACE
```sql
```


# DROP
DROP 用于删除相关结构。
```sql
DROP DATABASE
DROP EVENT
DROP FUNCTION
DROP INDEX
DROP PROCEDURE
DROP TABLE
DROP TRIGGER
DROP VIEW
```

## DROP DATABASE
```sql
```

## DROP EVENT
```sql
```

## DROP FUNCTION
```sql
```

## DROP INDEX
```sql
```

## DROP LOGFILE GROUP
```sql
```

## DROP PROCEDURE
```sql
```

## DROP FUNCTION
```sql
```

## DROP SERVER
```sql
```

## DROP TABLE
```sql
```

## DROP TABLESPACE
```sql
```

## DROP TRIGGER
```sql
```

## DROP VIEW
```sql
```

