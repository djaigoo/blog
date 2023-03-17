---
author: djaigo
title: mysql
categories:
  - mysql
date: 2023-03-13 10:39:20
tags:
---

# 简介
## 关系型数据库
对比非关系型数据库
对比其他关系型数据库
## 非关系型数据库

## MySQL
[官网](https://www.mysql.com/)

客户端操作
查看帮助文档
```sql
mysql> help

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.

For server side help, type 'help contents'
```

workbench

# 基本知识
## 数据类型
如果使用错误的数据类型可能会严重影响应用程序的功能和性能，所以在设计表时，应该特别重视数据列所用的数据类型。更改包含数据的列不是一件小事，这样做可能会导致数据丢失。因此，在创建表时必须为每个列设置正确的数据类型和长度。定义字段的数据类型对数据库的优化是十分重要的。
* 整数类型包括 TINYINT、SMALLINT、MEDIUMINT、INT、BIGINT
* 浮点数类型包括 FLOAT 和 DOUBLE，定点数类型为 DECIMAL
* 日期/时间类型包括 YEAR、TIME、DATE、DATETIME 和 TIMESTAMP
* 字符串类型包括 CHAR、VARCHAR、BINARY、VARBINARY、BLOB、TEXT、ENUM 和 SET 等
* 二进制类型包括 BIT、BINARY、VARBINARY、TINYBLOB、BLOB、MEDIUMBLOB 和 LONGBLOB

### 整数
MySQL提供了多种数值型数据类型，不同的数据类型提供不同的取值范围，可以存储的值范围越大，所需的存储空间也会越大。
不同的整数类型有不同的取值范围，并且需要不同的存储空间，因此应根据实际需要选择最合适的类型，这样有利于提高查询的效率和节省存储空间。

|类型名称       |说明         |存储需求|有符号范围|无符号范围|
|--|--|--|--|--|
|TINYINT       |很小的整数    |1个字节|-128〜127    0| 〜255|
|SMALLINT      |小的整数     | 2个宇节|-32768〜32767   | 0〜65535|
|MEDIUMINT     |中等大小的整数| 3个字节|-8388608〜8388607   | 0〜16777215|
|INT (INTEGHR) |普通大小的整数| 4个字节|-2147483648〜2147483647 | 0〜4294967295|
|BIGINT        |大整数       | 8个字节|-9223372036854775808〜9223372036854775807   | 0〜18446744073709551615|

### 小数
MySQL中可以使用浮点小数和定点小数：浮点类型有两种，分别是单精度浮点数（**FLOAT**）和双精度浮点数（**DOUBLE**）；定点类型只有一种，就是 **DECIMAL**。
浮点类型和定点类型都可以用`(M, D)`来表示，其中`M`称为精度，表示总共的位数；`D`称为标度，表示小数的位数。
浮点数类型的取值范围为 M（1～255）和 D（1～30，且不能大于 M-2），分别表示显示宽度和小数位数。M 和 D 在 FLOAT 和DOUBLE 中是可选的，FLOAT 和 DOUBLE 类型将被保存为硬件所支持的最大精度。DECIMAL 的默认 D 值为 0、M 值为 10。
不论是定点还是浮点类型，如果用户指定的精度超出精度范围，则会四舍五入进行处理。

|类型名称       |说明         |存储需求|有符号范围|无符号范围|
|--|--|--|--|--|
|FLOAT       |单精度浮点数        |4个字节|(-3.402823466E+38，-1.175494351E-38)，0，(1.175494351E-38，3.402823466351E+38)   | 0，(1.175494351E-38，3.402823466E+38)|
|DOUBLE      |双精度浮点数     | 8个宇节|(-1.7976931348623157E+308，-2.2250738585072014E-308)，0，(2.2250738585072014E-308，1.7976931348623157E+308)  | 0，(2.2250738585072014E-308，1.7976931348623157E+308)|
|DECIMAL (M, D)，DEC     |压缩的“严格”定点数|如果M>D，为M+2否则为D+2|依赖于M和D的值  | 依赖于M和D的值|


### 日期


|类型名称    |日期格式    | 日期范围                                                      |存储需求|
|-|-|-|-|
|YEAR       |YYYY       | 1901 ~ 2155                                                  |1 个字节|
|TIME       |HH:MM:SS   | -838:59:59 ~ 838:59:59                                       |3 个字节|
|DATE       |YYYY-MM-DD | 1000-01-01 ~ 9999-12-3                                       |3 个字节|
|DATETIME   |YYYY-MM-DD | HH:MM:SS 1000-01-01 00:00:00 ~ 9999-12-31 23:59:59           |8 个字节|
|TIMESTAMP  |YYYY-MM-DD | HH:MM:SS 1970-01-01 00:00:01 UTC ~ 2038-01-19 03:14:07 UTC   |4 个字节|

### 字符串

|类型名称     |说明                                     |  存储需求|
|-|-|-|
|CHAR(M)     |固定长度非二进制字符串                      |  M 字节，1<=M<=255|
|VARCHAR(M)  |变长非二进制字符串                         |     L+1字节，在此，L< = M和 1<=M<=255|
|TINYTEXT    |非常小的非二进制字符串                      |    L+1字节，在此，L<2^8|
|TEXT        |小的非二进制字符串                         |     L+2字节，在此，L<2^16|
|MEDIUMTEXT  |中等大小的非二进制字符串                    |   L+3字节，在此，L<2^24|
|LONGTEXT    |大的非二进制字符串                         |      L+4字节，在此，L<2^32|
|ENUM        |枚举类型，只能有一个枚举字符串值             |  1或2个字节，取决于枚举值的数目 (最大值为65535)|
|SET         |一个设置，字符串对象可以有零个或 多个SET成员  |  1、2、3、4或8个字节，取决于集合 成员的数量（最多64个成员）|


### 二进制

|类型名称     |说明                                     |  存储需求|
|-|-|-|
|BIT(M)          |位字段类型          |大约 (M+7)/8 字节|
|BINARY(M)       |固定长度二进制字符串 | M 字节|
|VARBINARY (M)   |可变长度二进制字符串 | M+1 字节|
|TINYBLOB (M)    |非常小的BLOB        | L+1 字节，在此，L<2^8|
|BLOB (M)        |小 BLOB            | L+2 字节，在此，L<2^16|
|MEDIUMBLOB (M)  |中等大小的BLOB      | L+3 字节，在此，L<2^24|
|LONGBLOB (M)    |非常大的BLOB        | L+4 字节，在此，L<2^32|

## sql语法

SQL（Structured Query Language，结构化查询语言），SQL 是一种数据库查询和程序设计语言，用于存取数据以及查询、更新和管理关系数据库系统。

### 数据定义语言（Data Definition Language，DDL）
用来创建或删除数据库以及表等对象，主要包含以下几种命令：
*   DROP：删除数据库和表等对象
*   CREATE：创建数据库和表等对象
*   ALTER：修改数据库和表等对象的结构

### 数据操作语言（Data Manipulation Language，DML）
用来变更表中的记录，主要包含以下几种命令：
*   SELECT：查询表中的数据
*   INSERT：向表中插入新数据
*   UPDATE：更新表中的数据
*   DELETE：删除表中的数据

### 数据查询语言（Data Query Language，DQL）
用来查询表中的记录，主要包含 SELECT 命令，来查询表中的数据。

### 数据控制语言（Data Control Language，DCL）
用来确认或者取消对数据库中的数据进行的变更。除此之外，还可以对数据库中的用户设定权限。主要包含以下几种命令：
*   GRANT：赋予用户操作权限
*   REVOKE：取消用户的操作权限
*   COMMIT：确认对数据库中的数据进行的变更
*   ROLLBACK：取消对数据库中的数据进行的变更

### 语法
不区分大小写
分号结尾
注释
命名规则
查看帮助文档
设计理念

### 运算符
* MySQL 支持 4 种运算符，分别是：
* 算术运算符 执行算术运算，例如：加、减、乘、除等。
* 比较运算符 包括大于、小于、等于或不等于、等等。主要用于数值的比较、字符串的匹配等方面。
* 逻辑运算符 包括与、或、非和异或、等逻辑运算符。其返回值为布尔型，真值（1 或 true）和假值（0 或 false）。
* 位运算符 包括按位与、按位或、按位取反、按位异或、按位左移和按位右移等位运算符。位运算必须先将数据转换为补码，然后在根据数据的补码进行操作。运算完成后，将得到的值转换为原来的类型（十进制数），返回给用户。


运算符优先级

|优先级由低到高排列 |运算符|
|-|-|
|1 | `=`(赋值运算）、`:=`|
|2 | `||`、`OR`|
|3 | `XOR`|
|4 | `&&`、`AND`|
|5 | `NOT`|
|6 | `BETWEEN`、`CASE`、`WHEN`、`THEN`、`ELSE`|
|7 | `=`(比较运算）、`<=>`、`>=`、`>`、`<=`、`<`、`<>`、`!=`、 `IS`、`LIKE`、`REGEXP`、`IN`|
|8 | `|`|
|9 | `&`|
|10 |  `<<`、`>>`|
|11 |  `-`(减号）、`+`|
|12 |  `*`、`/`、`%`|
|13 |  `^`|
|14 |  `-`(负号）、`〜`（位反转）|
|15 |  `!`|

可以看出，不同运算符的优先级是不同的。一般情况下，级别高的运算符优先进行计算，如果级别相同，MySQL 按表达式的顺序从左到右依次计算。
另外，在无法确定优先级的情况下，可以使用圆括号“()”来改变优先级，并且这样会使计算过程更加清晰。


## 约束
在 MySQL 中，主要支持以下 6 种约束：
* 主键约束 主键约束是使用最频繁的约束。在设计数据表时，一般情况下，都会要求表中设置一个主键。主键是表的一个特殊字段，该字段能唯一标识该表中的每条信息。主键不能包含空值
* 外键约束 外键约束经常和主键约束一起使用，用来确保数据的一致性。
* 唯一约束 唯一约束与主键约束有一个相似的地方，就是它们都能够确保列的唯一性。与主键约束不同的是，唯一约束在一个表中可以有多个，并且设置唯一约束的列是允许有空值的，虽然只能有一个空值。
* 检查约束 检查约束是用来检查数据表中，字段值是否有效的一个手段。
* 非空约束 非空约束用来约束表中的字段不能为空。例如，在学生信息表中，如果不添加学生姓名，那么这条记录是没有用的。
* 默认值约束 默认值约束用来约束当数据表中某个字段不输入值时，自动为其添加一个已经设置好的值。

以上 6 种约束中，一个数据表中只能有一个主键约束，其它约束可以有多个。

使用`SHOW CREATE TABLE table`可以查看表中字段使用的约束

### 主键约束
* 单字段主键
* 联合主键

新建主键约束
修改主键约束
删除主键约束

主键自增
使用 AUTO_INCREMENT 定义自增
* 默认情况下，AUTO_INCREMENT 的初始值是 1，每新增一条记录，字段值自动加 1。
* 一个表中只能有一个字段使用 AUTO_INCREMENT 约束，且该字段必须有唯一索引，以避免序号重复（即为主键或主键的一部分）。
* AUTO_INCREMENT 约束的字段必须具备 NOT NULL 属性。
* AUTO_INCREMENT 约束的字段只能是整数类型（TINYINT、SMALLINT、INT、BIGINT 等）。
* AUTO_INCREMENT 约束字段的最大值受该字段的数据类型约束，如果达到上限，AUTO_INCREMENT 就会失效。

指定自增字段初始值

### 外键约束
MySQL 外键约束（FOREIGN KEY）是表的一个特殊字段，经常与主键约束一起使用。
对于两个具有关联关系的表而言，相关联字段中主键所在的表就是主表（父表），外键所在的表就是从表（子表）。
外键用来建立主表与从表的关联关系，为两个表的数据建立连接，约束两个表中数据的一致性和完整性。

主表删除某条记录时，从表中与之对应的记录也必须有相应的改变。一个表可以有一个或多个外键，外键可以为空值，若不为空值，则每一个外键的值必须等于主表中主键的某个值。

定义外键时，需要遵守下列规则：
* 主表必须已经存在于数据库中，或者是当前正在创建的表。如果是后一种情况，则主表与从表是同一个表，这样的表称为自参照表，这种结构称为自参照完整性。
* 必须为主表定义主键。
* 主键不能包含空值，但允许在外键中出现空值。也就是说，只要外键的每个非空值出现在指定的主键中，这个外键的内容就是正确的。
* 在主表的表名后面指定列名或列名的组合。这个列或列的组合必须是主表的主键或候选键。
* 外键中列的数目必须和主表的主键中列的数目相同。
* 外键中列的数据类型必须和主表主键中对应列的数据类型相同。

创建外键
修改外键
删除外键

### 唯一约束
MySQL 唯一约束（Unique Key）是指所有记录中字段的值不能重复出现。
唯一约束与主键约束相似的是它们都可以确保列的唯一性。不同的是，唯一约束在一个表中可有多个，并且设置唯一约束的列允许有空值，但是只能有一个空值。

创建唯一约束
修改唯一约束
删除唯一约束

### 检查约束
MySQL 检查约束（CHECK）是用来检查数据表中字段值有效性的一种手段，可以通过 CREATE TABLE 或 ALTER TABLE 语句实现。设置检查约束时要根据实际情况进行设置，这样能够减少无效数据的输入。

创建检查约束
修改检查约束
删除检查约束

### 默认值约束
默认值约束（Default Constraint），用来指定某列的默认值。在表中插入一条新记录时，如果没有为某个字段赋值，系统就会自动为这个字段插入默认值。
创建默认值约束
修改默认值约束
删除默认值约束

### 非空约束
非空约束（NOT NULL）指字段的值不能为空。对于使用了非空约束的字段，如果用户在添加数据时没有指定值，数据库系统就会报错。
可以通过 CREATE TABLE 或 ALTER TABLE 语句实现。在表中某个列的定义后加上关键字 NOT NULL 作为限定词，来约束该列的取值不能为空。
创建非空约束
修改非空约束
删除非空约束



## 库操作

查看
创建
修改
删除
选择

## 表操作

创建

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

* `TEMPORARY` 是否是临时表
* `tbl_name` 创建表名
* `IF NOT EXISTS` 存在则不创建
* `create_definition` 创建定义字段
* `table_options` 表选项
* `partition_options` 分区选项
* `query_expression` 查询表达式
* `old_tbl_name` 用已存在的表创建当前表

[详细文档](https://dev.mysql.com/doc/refman/5.7/en/create-table.html)

MySQL 对表的数量没有限制。底层文件系统可能对表示表的文件数量有限制。各个存储引擎可能会施加特定于引擎的约束。 InnoDB 允许多达 40 亿个表。
创建表时可以使用 TEMPORARY 关键字。 TEMPORARY 表仅在当前会话中可见，并在会话关闭时自动删除


修改

```sql
ALTER TABLE tbl_name
    [alter_specification [, alter_specification] ...]
    [partition_options]

alter_specification:
    table_options
  | ADD [COLUMN] col_name column_definition
        [FIRST | AFTER col_name ]
  | ADD [COLUMN] (col_name column_definition,...)
  | ADD {INDEX|KEY} [index_name]
        [index_type] (index_col_name,...) [index_option] ...
  | ADD [CONSTRAINT [symbol]] PRIMARY KEY
        [index_type] (index_col_name,...) [index_option] ...
  | ADD [CONSTRAINT [symbol]]
        UNIQUE [INDEX|KEY] [index_name]
        [index_type] (index_col_name,...) [index_option] ...
  | ADD FULLTEXT [INDEX|KEY] [index_name]
        (index_col_name,...) [index_option] ...
  | ADD SPATIAL [INDEX|KEY] [index_name]
        (index_col_name,...) [index_option] ...
  | ADD [CONSTRAINT [symbol]]
        FOREIGN KEY [index_name] (index_col_name,...)
        reference_definition
  | ALGORITHM [=] {DEFAULT|INPLACE|COPY}
  | ALTER [COLUMN] col_name {SET DEFAULT literal | DROP DEFAULT}
  | CHANGE [COLUMN] old_col_name new_col_name column_definition
        [FIRST|AFTER col_name]
  | LOCK [=] {DEFAULT|NONE|SHARED|EXCLUSIVE}
  | MODIFY [COLUMN] col_name column_definition
        [FIRST | AFTER col_name]
  | DROP [COLUMN] col_name
  | DROP PRIMARY KEY
  | DROP {INDEX|KEY} index_name
  | DROP FOREIGN KEY fk_symbol
  | DISABLE KEYS
  | ENABLE KEYS
  | RENAME [TO|AS] new_tbl_name
  | RENAME {INDEX|KEY} old_index_name TO new_index_name
  | ORDER BY col_name [, col_name] ...
  | CONVERT TO CHARACTER SET charset_name [COLLATE collation_name]
  | [DEFAULT] CHARACTER SET [=] charset_name [COLLATE [=] collation_name]
  | DISCARD TABLESPACE
  | IMPORT TABLESPACE
  | FORCE
  | {WITHOUT|WITH} VALIDATION
  | ADD PARTITION (partition_definition)
  | DROP PARTITION partition_names
  | DISCARD PARTITION {partition_names | ALL} TABLESPACE
  | IMPORT PARTITION {partition_names | ALL} TABLESPACE
  | TRUNCATE PARTITION {partition_names | ALL}
  | COALESCE PARTITION number
  | REORGANIZE PARTITION partition_names INTO (partition_definitions)
  | EXCHANGE PARTITION partition_name WITH TABLE tbl_name [{WITH|WITHOUT} VALIDATION]
  | ANALYZE PARTITION {partition_names | ALL}
  | CHECK PARTITION {partition_names | ALL}
  | OPTIMIZE PARTITION {partition_names | ALL}
  | REBUILD PARTITION {partition_names | ALL}
  | REPAIR PARTITION {partition_names | ALL}
  | REMOVE PARTITIONING
  | UPGRADE PARTITIONING

index_col_name:
    col_name [(length)] [ASC | DESC]

index_type:
    USING {BTREE | HASH}

index_option:
    KEY_BLOCK_SIZE [=] value
  | index_type
  | WITH PARSER parser_name
  | COMMENT 'string'

table_options:
    table_option [[,] table_option] ...  (see CREATE TABLE options)

partition_options:
    (see CREATE TABLE options)
```

删除

```sql
DROP [TEMPORARY] TABLE [IF EXISTS]
    tbl_name [, tbl_name] ...
    [RESTRICT | CASCADE]
```


查看表结构

```sql
{EXPLAIN | DESCRIBE | DESC}
    tbl_name [col_name | wild]

{EXPLAIN | DESCRIBE | DESC}
    [explain_type]
    {explainable_stmt | FOR CONNECTION connection_id}

explain_type: {
    EXTENDED
  | PARTITIONS
  | FORMAT = format_name
}

format_name: {
    TRADITIONAL
  | JSON
}

explainable_stmt: {
    SELECT statement
  | DELETE statement
  | INSERT statement
  | REPLACE statement
  | UPDATE statement
}
```

## 展示数据
```sql
SHOW {BINARY | MASTER} LOGS
SHOW BINLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
SHOW {CHARACTER SET | CHARSET} [like_or_where]
SHOW COLLATION [like_or_where]
SHOW [FULL] COLUMNS FROM tbl_name [FROM db_name] [like_or_where]
SHOW CREATE DATABASE db_name
SHOW CREATE EVENT event_name
SHOW CREATE FUNCTION func_name
SHOW CREATE PROCEDURE proc_name
SHOW CREATE TABLE tbl_name
SHOW CREATE TRIGGER trigger_name
SHOW CREATE VIEW view_name
SHOW DATABASES [like_or_where]
SHOW ENGINE engine_name {STATUS | MUTEX}
SHOW [STORAGE] ENGINES
SHOW ERRORS [LIMIT [offset,] row_count]
SHOW EVENTS
SHOW FUNCTION CODE func_name
SHOW FUNCTION STATUS [like_or_where]
SHOW GRANTS FOR user
SHOW INDEX FROM tbl_name [FROM db_name]
SHOW MASTER STATUS
SHOW OPEN TABLES [FROM db_name] [like_or_where]
SHOW PLUGINS
SHOW PROCEDURE CODE proc_name
SHOW PROCEDURE STATUS [like_or_where]
SHOW PRIVILEGES
SHOW [FULL] PROCESSLIST
SHOW PROFILE [types] [FOR QUERY n] [OFFSET n] [LIMIT n]
SHOW PROFILES
SHOW RELAYLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
SHOW SLAVE HOSTS
SHOW SLAVE STATUS [FOR CHANNEL channel]
SHOW [GLOBAL | SESSION] STATUS [like_or_where]
SHOW TABLE STATUS [FROM db_name] [like_or_where]
SHOW [FULL] TABLES [FROM db_name] [like_or_where]
SHOW TRIGGERS [FROM db_name] [like_or_where]
SHOW [GLOBAL | SESSION] VARIABLES [like_or_where]
SHOW WARNINGS [LIMIT [offset,] row_count]

like_or_where: {
    LIKE 'pattern'
  | WHERE expr
}
```

[详细文档](https://dev.mysql.com/doc/refman/5.7/en/show.html)

## 表数据操作

增
语法
```sql
INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name,...)]
    [(col_name,...)]
    {VALUES | VALUE} ({expr | DEFAULT},...),(...),...
    [ ON DUPLICATE KEY UPDATE
      col_name=expr
        [, col_name=expr] ... ]

Or:

INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name,...)]
    SET col_name={expr | DEFAULT}, ...
    [ ON DUPLICATE KEY UPDATE
      col_name=expr
        [, col_name=expr] ... ]

Or:

INSERT [LOW_PRIORITY | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name,...)]
    [(col_name,...)]
    SELECT ...
    [ ON DUPLICATE KEY UPDATE
      col_name=expr
        [, col_name=expr] ... ]

value:
    {expr | DEFAULT}

value_list:
    value [, value] ...

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
```

* `tbl_name` 新建表名
* `partition_name` 分区名
* `col_name` 列名
* `expr` 值表达式

INSERT 将新行插入到现有表中。 
INSERT ... VALUES 和 INSERT ... SET 语句的形式根据明确指定的值插入行。 
INSERT ... SELECT 形式插入从另一个表或多个表中选择的行。
如果要插入的行会导致 UNIQUE 索引或 PRIMARY KEY 中出现重复值，则带有 ON DUPLICATE KEY UPDATE 子句的 INSERT 可以更新现有行。



删
语法
```sql
Single-Table Syntax

DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name
    [PARTITION (partition_name,...)]
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]

Multiple-Table Syntax

DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    tbl_name[.*] [, tbl_name[.*]] ...
    FROM table_references
    [WHERE where_condition]

Or:

DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    FROM tbl_name[.*] [, tbl_name[.*]] ...
    USING table_references
    [WHERE where_condition]
```

* `tbl_name` 表名
* `partition_name` 分区名
* `where_condition` 条件查询语句
* `row_count` 限制条数
* `table_references` 数据join表名

DELETE 语句从 tbl_name 中删除行并返回删除的行数。
可选 WHERE 子句中的条件标识要删除的行。如果没有 WHERE 子句，所有行都将被删除。
如果指定了 ORDER BY 子句，则按照指定的顺序删除行。 LIMIT 子句限制了可以删除的行数。这些子句适用于单表删除，但不适用于多表删除。
您需要表的 DELETE 权限才能从中删除行。对于任何只读的列，例如在 WHERE 子句中命名的列，您只需要 SELECT 特权。
当您不需要知道删除的行数时，TRUNCATE TABLE 语句是一种比不带 WHERE 子句的 DELETE 语句更快的清空表的方法。与 DELETE 不同，TRUNCATE TABLE 不能在事务中使用，也不能在表上有锁的情况下使用。请参阅第 13.1.34 节，“TRUNCATE TABLE 语句”和第 13.3.5 节，“LOCK TABLES 和 UNLOCK TABLES 语句”。
不能删除子查询选中的列


改
语法
```sql
Single-table syntax:

UPDATE [LOW_PRIORITY] [IGNORE] table_reference
    SET col_name1={expr1|DEFAULT} [, col_name2={expr2|DEFAULT}] ...
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]

value:
    {expr | DEFAULT}

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...

Multiple-table syntax:

UPDATE [LOW_PRIORITY] [IGNORE] table_references
    SET col_name1={expr1|DEFAULT} [, col_name2={expr2|DEFAULT}] ...
    [WHERE where_condition]
```

* `table_reference` 表名
* `col_name` 列名
* `expr` 值表达式
* `where_condition` 条件查询语句
* `row_count` 限制行数

对于单表语法，UPDATE 语句用新值更新命名表中现有行的列。 
SET 子句指示要修改哪些列以及应赋予它们的值。每个值都可以作为表达式或关键字 DEFAULT 给出，以将列显式设置为其默认值。 
WHERE 子句（如果给定）指定标识要更新的行的条件。如果没有 WHERE 子句，所有行都会更新。
如果指定了 ORDER BY 子句，则按照指定的顺序更新行。 
LIMIT 子句限制了可以更新的行数。

对于多表语法，UPDATE 更新 table_references 中命名的每个表中满足条件的行。
每个匹配行都会更新一次，即使它多次匹配条件也是如此。
对于多表语法，不能使用 ORDER BY 和 LIMIT。



## 表数据查询
查
语法
```sql
SELECT
    [ALL | DISTINCT | DISTINCTROW ]
    [HIGH_PRIORITY]
    [STRAIGHT_JOIN]
    [SQL_SMALL_RESULT] [SQL_BIG_RESULT] [SQL_BUFFER_RESULT]
    [SQL_CACHE | SQL_NO_CACHE] [SQL_CALC_FOUND_ROWS]
    select_expr [, select_expr] ...
    [into_option]
    [FROM table_references
      [PARTITION partition_list]]
    [WHERE where_condition]
    [GROUP BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [HAVING where_condition]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]
    [LIMIT {[offset,] row_count | row_count OFFSET offset}]
    [PROCEDURE procedure_name(argument_list)]
    [into_option]
    [FOR UPDATE | LOCK IN SHARE MODE]

into_option: {
    INTO OUTFILE 'file_name'
        [CHARACTER SET charset_name]
        export_options
  | INTO DUMPFILE 'file_name'
  | INTO var_name [, var_name] ...
}
```

* `select_expr` 查询字段表达式
* `table_references` 查询表名
* `partition_list` 表分区
* `where_condition` 查询条件表达式
* `col_name` 操作列名
* `expr` 操作表达式
* `position` 列位置，不推荐使用，因为该语法已从 SQL 标准中删除
* `offset` 偏移量
* `row_count` 行数
* `procedure_name` 存储过程名
* `argument_list` 存储过程参数列表
* `file_name` 输出文件名
* `charset_name` 输出字符集
* `export_options` 导出选项
* `var_name` 变量名

SELECT 用于检索从一个或多个表中选择的行，并且可以包括 UNION 语句和子查询。
WHERE 子句（如果给定）指示要选择行必须满足的一个或多个条件。 where_condition 是一个表达式，对于要选择的每一行计算结果为真。如果没有 WHERE 子句，该语句将选择所有行。在 WHERE 表达式中，您可以使用 MySQL 支持的任何函数和运算符，但聚合（组）函数除外


GROUP BY 子句（如果给定）将选定的列分组，MySQL 扩展了 GROUP BY 子句，因此您还可以在子句中命名的列之后指定 ASC 和 DESC。但是，此语法已弃用。要生成给定的排序顺序，请提供 ORDER BY 子句。
如果您使用 GROUP BY，输出行将根据 GROUP BY 列排序，就好像您对相同的列有一个 ORDER BY。为了避免 GROUP BY 产生的排序开销，添加 ORDER BY NULL：

当您使用 ORDER BY 或 GROUP BY 对 SELECT 中的列进行排序时，服务器仅使用 max_sort_length 系统变量指示的初始字节数对值进行排序。

HAVING 子句与 WHERE 子句一样，指定选择条件。 WHERE 子句指定选择列表中列的条件，但不能引用聚合函数。 HAVING 子句指定组的条件，通常由 GROUP BY 子句构成。查询结果只包含满足HAVING条件的组。 （如果不存在 GROUP BY，则所有行隐式构成一个聚合组。）
SQL 标准要求 HAVING 必须仅引用 GROUP BY 子句中的列或聚合函数中使用的列。但是，MySQL 支持对此行为的扩展，并允许 HAVING 引用 SELECT 列表中的列以及外部子查询中的列。
不要对应该在 WHERE 子句中的项目使用 HAVING
HAVING 子句可以引用聚合函数，而 WHERE 子句不能
ORDER BY 子句（如果给定）将按照指定列值进行排序

LIMIT 子句可用于限制 SELECT 语句返回的行数。 LIMIT 接受一个或两个数字参数，它们必须都是非负整数常量，但以下情况除外：

* 在函数中，LIMIT 参数可以使用 ?占位符标记。
* 在存储过程中，可以使用整数值例程参数或局部变量指定 LIMIT 参数。

```sql
SET @a=1;
PREPARE STMT FROM 'SELECT * FROM tbl LIMIT ?';
EXECUTE STMT USING @a;

SET @skip=1; SET @numrows=5;
PREPARE STMT FROM 'SELECT * FROM tbl LIMIT ?, ?';
EXECUTE STMT USING @skip, @numrows;
```


有两个参数，第一个参数指定要返回的第一行的偏移量，第二个参数指定要返回的最大行数。初始行的偏移量为 0（不是 1）
要检索从某个偏移量到结果集末尾的所有行，您可以为第二个参数使用一些较大的数字。
使用一个参数，该值指定从结果集开头返回的行数，也就是说，LIMIT row_count 相当于 LIMIT 0, row_count。
为了与 PostgreSQL 兼容，MySQL 还支持 LIMIT row_count OFFSET 偏移语法。









通常，使用的子句必须完全按照语法描述中显示的顺序给出。
例如，HAVING 子句必须位于任何 GROUP BY 子句之后和任何 ORDER BY 子句之前。 
INTO 子句（如果存在）可以出现在语法描述指示的任何位置，但在给定语句中只能出现一次，不能出现在多个位置。



去重
设置别名
限制查询
条件查询
模糊查询
范围查询
空值查询
分组查询
连接查询
子查询
合并查询
正则查询
in和not in
as
exist
between
like
order by
group by
having

## 常用函数
### 数值函数

| 函数      | 含义    |
| --------- | -------- |
|`round(x,y)`| 四舍五入,y表示保留小数位(y非必填)  |
|`ceil(x)`|   向上取整，返回>=该参数的最小整数       |
|`floor(x)`|    向下取整，返回<=该参数的最大整数      |
|`mod(x,y)`|      返回x/y的模（余数）    |
|`greatest(x1,x2,...,xn)`|    返回集合中最大的值      |
|`least(x1,x2,...,xn)`|   返回集合中最小的值       |
|`rand()`|     返回０到１内的随机值,可以通过提供一个参数(种子)使rand()随机数生成器生成一个指定的值     |
|`truncate(x,y)`|    返回数字x截短为y位小数的结果      |

### 字符串函数

| 函数      | 含义    |
| --------- | -------- |
|`concat(s1,s2...,sn)`|将s1,s2...,sn连接成字符串，如果该函数中的任何参数为 null，返回结果为 null |
|`concat_ws(sep,s1,s2...,sn)` | 将s1,s2...,sn连接成字符串,并用sep字符间隔|
|`substr(str,start,len)` |从start位置开始截取字符串，len表示要截取的长度 |
|`lcase(str)` | 将字符串str转换为小写形式|
|`lower(str)` |将字符串str转换为小写形式 |
|`upper(str)` |将字符串转换为大写形式 |
|`ucase(str)` | 将字符串转换为大写形式|
|`length(str)`| 返回字符串str中的字符数|
|`trim(str)`| 去除字符串首部和尾部的所有空格|
|`left(str,x)` | 返回字符串str中最左边的x个字符|
|`right(str,x)` | 返回字符串str中最右边的x个字符|
|`strcmp(s1,s2)` |比较字符串s1和s2是否相同 相同返回0，否则-1 |


### 日期函数

| 函数      | 含义    |
| --------- | -------- |
|`now()`| 返回当前的日期和时间|
|`curdate()`|返回当前的日期 |
|`current_date()`|返回当前的日期 |
|`curtime()`| 返回当前的时间|
|`current_time()`| 返回当前的时间|
|`year(date)`| 获取年份|
|`month(date)`|获取月份 |
|`day(date)`| 获取天|
|`hour(date)`| 获取小时|
|`minute(date)`| 获取分钟|
|`second(date)`| 获取秒|
|`str_to_date(str,format)`|将日期格式的字符串，转换成指定格式的日期 |
|`date_format(date,format)`| 将日期转换为对应的字符串格式|
|`date_add(date,interval expr unit)`| 增加日期时间|
|`date_sub(date,interval expr unit)`| 减少日期时间|
|`dayofweek()`|返回date所代表的一星期中的第几天(1~7) |
|`dayofmonth(datedate)`| 返回date是一个月的第几天(1~31)|
|`dayofyear(date)`| 返回date是一年的第几天(1~366)|
|`quarter(date)`|返回date在一年中的季度(1~4) |
|`unix_timestamp(date)`| 将当前时间转为时间戳|
|`from_unixtime(str)`| 将时间戳转为时间 |

时间格式化

|格式 | 描述|
|--|--|
|`%a` | 缩写星期名
|`%b` | 缩写月名
|`%c` | 月，数值
|`%D` | 带有英文前缀的月中的天
|`%d` | 月的天，数值(00-31)
|`%e` | 月的天，数值(0-31)
|`%f` | 微秒
|`%H` | 小时 (00-23)
|`%h` | 小时 (01-12)
|`%I` | 小时 (01-12)
|`%i` | 分钟，数值(00-59)
|`%j` | 年的天 (001-366)
|`%k` | 小时 (0-23)
|`%l` | 小时 (1-12)
|`%M` | 月名
|`%m` | 月，数值(00-12)
|`%p` | AM 或 PM
|`%r` | 时间，12-小时（hh:mm:ss AM 或 PM）
|`%S` | 秒(00-59)
|`%s` | 秒(00-59)
|`%T` | 时间, 24-小时 (hh:mm:ss)
|`%U` | 周 (00-53) 星期日是一周的第一天
|`%u` | 周 (00-53) 星期一是一周的第一天
|`%V` | 周 (01-53) 星期日是一周的第一天，与 %X 使用
|`%v` | 周 (01-53) 星期一是一周的第一天，与 %x 使用
|`%W` | 星期名
|`%w` | 周的天 （0=星期日, 6=星期六）
|`%X` | 年，其中的星期日是周的第一天，4 位，与 %V 使用
|`%x` | 年，其中的星期一是周的第一天，4 位，与 %v 使用
|`%Y` | 年，4 位
|`%y` | 年，2 位

```sql
select date_format(now(), '%Y-%m-%d %H:%i:%s');
```

时间加减
* `date_add(date,interval expr unit)`
* `date_sub(date,interval expr unit)`

expr：表示数量
unit：表示单位，支持毫秒(microsecond)，秒(second)，小时(hour)，天(day)，周(week)，月(month),年(year)等

```sql
select date_add(now(), interval 1 day);

-- 以下结果等同
select date_add(now(), interval -1 day);
select date_sub(now(), interval 1 day);
```


时间戳转换
```sql
select unix_timestamp(now());
select from_unixtime('1234567890');
```



### 聚合函数

| 函数      | 含义    |
| --------- | -------- |
|`avg(x)` |           返回指定列的平均值|
|`count(x)` |         返回指定列中非null值的个数|
|`min(x)` |           返回指定列的最小值|
|`max(x)` |           返回指定列的最大值|
|`sum(x)` |           返回指定列的所有值之和|
|`group_concat(x)` |  返回由属于一组的列值连接组合而成的结果，非常有用|


### 流程控制函数

| 函数      | 含义    |
| --------- | -------- |
|`if(test,t,f)`        |如果test是真，返回t；否则返回f|
|`ifnull(arg1,arg2)`   |如果arg1不是空，返回arg1，否则返回arg2|
|`nullif(arg1,arg2)`   |如果arg1=arg2返回null；否则返回arg1|
|`case...when`         |分支控制|

```sql
case 
when <求值表达式> then <表达式1>
when <求值表达式> then <表达式2>
else <表达式>
end
```

*   else 可以不写，默认返回null
*   end 不可以忘记
*   当一个case子句中有多个判断逻辑时、字段类型需要一致
*   当一个case子句中有多个判断逻辑时、第一个为真的结果会被输出

```sql
select if(second(now())>30,true, false);

select ifnull(1, 2), ifnull(null, 2), nullif(1,1), nullif(1, null);

select s, case when s>=40 then 'big' when s>=20 then 'middle' else 'small' end slot from (select second(now()) s) tmp;
```


## 视图
视图并不同于数据表，它们的区别在于以下几点：

* 视图不是数据库中真实的表，而是一张虚拟表，其结构和数据是建立在对数据中真实表的查询基础上的。
* 存储在数据库中的查询操作 SQL 语句定义了视图的内容，列数据和行数据来自于视图查询所引用的实际表，引用视图时动态生成这些数据。
* 视图没有实际的物理记录，不是以数据集的形式存储在数据库中的，它所对应的数据实际上是存储在视图所引用的真实表中的。
* 视图是数据的窗口，而表是内容。表是实际数据的存放单位，而视图只是以不同的显示方式展示数据，其数据来源还是实际表。
* 视图是查看数据表的一种方法，可以查询数据表中某些字段构成的数据，只是一些 SQL 语句的集合。从安全的角度来看，视图的数据安全性更高，使用视图的用户不接触数据表，不知道表结构。
* 视图的建立和删除只影响视图本身，不影响对应的基本表。

视图优点
* 定制用户数据，聚焦特定的数据，在实际的应用过程中，不同的用户可能对不同的数据有不同的要求。
* 简化数据操作，在使用查询时，很多时候要使用聚合函数，同时还要显示其他字段的信息，可能还需要关联到其他表，语句可能会很长，如果这个动作频繁发生的话，可以创建视图来简化操作。
* 提高数据的安全性，视图是虚拟的，物理上是不存在的。可以只授予用户视图的权限，而不具体指定使用表的权限，来保护基础数据的安全。
* 共享所需数据，通过使用视图，每个用户不必都定义和存储自己所需的数据，可以共享数据库中的数据，同样的数据只需要存储一次。
* 更改数据格式，通过使用视图，可以重新格式化检索出的数据，并组织输出到其他应用程序中。
* 重用 SQL 语句，视图提供的是对查询操作的封装，本身不包含数据，所呈现的数据是根据视图定义从基础表中检索出来的，如果基础表的数据新增或删除，视图呈现的也是更新后的数据。视图定义后，编写完所需的查询，可以方便地重用该视图。

使用视图的时候，还应该注意以下几点：

*   创建视图需要足够的访问权限。
*   创建视图的数目没有限制。
*   视图可以嵌套，即从其他视图中检索数据的查询来创建视图。
*   视图不能索引，也不能有关联的触发器、默认值或规则。
*   视图可以和表一起使用。
*   视图不包含数据，所以每次使用视图时，都必须执行查询中所需的任何一个检索操作。如果用多个连接和过滤条件创建了复杂的视图或嵌套了视图，可能会发现系统运行性能下降得十分严重。因此，在部署大量视图应用时，应该进行系统测试。

### 创建视图
可以使用 CREATE VIEW 语句来创建视图。

语法格式如下：
```sql
CREATE VIEW <视图名> AS <SELECT语句>
```

语法说明如下。

*   `<视图名>`：指定视图的名称。该名称在数据库中必须是唯一的，不能与其他表或视图同名。
*   `<SELECT语句>`：指定创建视图的 SELECT 语句，可用于查询多个基础表或源视图。

对于创建视图中的 SELECT 语句的指定存在以下限制：

*   用户除了拥有 CREATE VIEW 权限外，还具有操作中涉及的基础表和其他视图的相关权限。
*   SELECT 语句不能引用系统或用户变量。
*   SELECT 语句不能包含 FROM 子句中的子查询。
*   SELECT 语句不能引用预处理语句参数。

增删查改

## 索引

索引是一种特殊的数据库结构，由数据表中的一列或多列组合而成，可以用来快速查询数据表中有某一特定值的记录。本节将详细讲解索引的含义、作用和优缺点。

通过索引，查询数据时不用读完记录的所有信息，而只是查询索引列。否则，数据库系统将读取每条记录的所有信息进行匹配。
因此，使用索引可以很大程度上提高数据库的查询速度，还有效的提高了数据库系统的性能。

索引有其明显的优势，也有其不可避免的缺点。
优点
索引的优点如下：
*   通过创建唯一索引可以保证数据库表中每一行数据的唯一性。
*   可以给所有的 MySQL 列类型设置索引。
*   可以大大加快数据的查询速度，这是使用索引最主要的原因。
*   在实现数据的参考完整性方面可以加速表与表之间的连接。
*   在使用分组和排序子句进行数据查询时也可以显著减少查询中分组和排序的时间

缺点
增加索引也有许多不利的方面，主要如下：
*   创建和维护索引组要耗费时间，并且随着数据量的增加所耗费的时间也会增加。
*   索引需要占磁盘空间，除了数据表占数据空间以外，每一个索引还要占一定的物理空间。如果有大量的索引，索引文件可能比数据文件更快达到最大文件尺寸。
*   当对表中的数据进行增加、删除和修改的时候，索引也要动态维护，这样就降低了数据的维护速度。

使用索引时，需要综合考虑索引的优点和缺点。
索引可以提高查询速度，但是会影响插入记录的速度。因为，向有索引的表中插入记录时，数据库系统会按照索引进行排序，这样就降低了插入记录的速度，插入大量记录时的速度影响会更加明显。这种情况下，最好的办法是先删除表中的索引，然后插入数据，插入完成后，再创建索引。

聚簇索引：索引和数据在一起，即叶子节点拥有完整数据，找到了索引就相当于找到了数据
辅助索引（非聚簇索引）：索引和数据分开，即叶子节点拥有部分数据，需要先找到索引在通过聚簇索引才能获取完整数据，这个过程也称做回表

优点
* 如果需要取出一段数据，用聚簇索引也比用非聚簇索引好
* 当通过聚簇索引查找目标数据时理论上比非聚簇索引要快，因为非聚簇索引定位到对应主键时还要多一次目标记录寻址，即多一次I/O
* 使用覆盖索引扫描的查询可以直接使用页节点中的主键值

缺点
* 插入速度严重依赖于插入顺序，按照主键的顺序插入是最快的方式，否则将会出现页分裂，严重影响性能。因此，对于InnoDB表，我们一般都会定义一个自增的ID列为主键。
* 更新主键的代价很高，因为将会导致被更新的行移动。因此，对于InnoDB表，我们一般定义主键为不可更新
* 二级索引访问需要两次索引查找，第一次找到主键值，第二次根据主键值找到行数据。
  二级索引的叶节点存储的是主键值，而不是行指针（非聚簇索引存储的是指针或者说是地址），这是为了减少当出现行移动或数据页分裂时二级索引的维护工作，但会让二级索引占用更多的空间。
* 采用聚簇索引插入新值比采用非聚簇索引插入新值的速度要慢很多，因为插入要保证主键不能重复，判断主键不能重复，采用的方式在不同的索引下面会有很大的性能差距，聚簇索引遍历所有的叶子节点，非聚簇索引也判断所有的叶子节点，但是聚簇索引的叶子节点除了带有主键还有记录值，记录的大小往往比主键要大的多。这样就会导致聚簇索引在判定新记录携带的主键是否重复时进行昂贵的I/O代价。


由于聚簇索引是将数据跟索引结构放到一块，因此一个表仅有一个聚簇索引
聚簇索引默认是主键，如果表中没有定义主键，InnoDB 会选择一个唯一的非空索引代替。
如果没有这样的索引，InnoDB 会隐式定义一个主键来作为聚簇索引。
InnoDB 只聚集在同一个页面中的记录。包含相邻键值的页面可能相距甚远。
如果你已经设置了主键为聚簇索引，必须先删除主键，然后添加我们想要的聚簇索引，最后恢复设置主键即可。

InnoDB也使用B+Tree作为索引结构，但具体实现方式却与MyISAM截然不同.

主键索引：
MyISAM索引文件和数据文件是分离的，索引文件仅保存数据记录的地址。
而在InnoDB中，表数据文件本身就是按B+Tree组织的一个索引结构，这棵树的叶节点data域保存了完整的数据记录。
这个索引的key是数据表的主键，因此InnoDB表数据文件本身就是主索引。
叶节点包含了完整的数据记录。这种索引叫做聚集索引。因为InnoDB的数据文件本身要按主键聚集，所以InnoDB要求表必须有主键（MyISAM可以没有），如果没有显式指定，则MySQL系统会自动选择一个可以唯一标识数据记录的列作为主键，如果不存在这种列，则MySQL自动为InnoDB表生成一个隐含字段作为主键，这个字段长度为6个字节，类型为长整形。
InnoDB的辅助索引
   InnoDB的所有辅助索引都引用主键作为data域。
InnoDB 表是基于聚簇索引建立的。因此InnoDB 的索引能提供一种非常快速的主键查找性能。不过，它的辅助索引（Secondary Index， 也就是非主键索引）也会包含主键列，所以，如果主键定义的比较大，其他索引也将很大。如果想在表上定义 、很多索引，则争取尽量把主键定义得小一些。InnoDB 不会压缩索引。
文字符的ASCII码作为比较准则。聚集索引这种实现方式使得按主键的搜索十分高效，但是辅助索引搜索需要检索两遍索引：首先检索辅助索引获得主键，然后用主键到主索引中检索获得记录。
不同存储引擎的索引实现方式对于正确使用和优化索引都非常有帮助，例如知道了InnoDB的索引实现后，就很容易明白：
1. 为什么不建议使用过长的字段作为主键，因为所有辅助索引都引用主索引，过长的主索引会令辅助索引变得过大。再例如，
2. 用非单调的字段作为主键在InnoDB中不是个好主意，因为InnoDB数据文件本身是一颗B+Tree，非单调的主键会造成在插入新记录时数据文件为了维持B+Tree的特性而频繁的分裂调整，十分低效，而使用自增字段作为主键则是一个很好的选择。

InnoDB使用的是聚簇索引，将主键组织到一棵B+树中，而行数据就储存在叶子节点上，若使用"where id = 14"这样的条件查找主键，则按照B+树的检索算法即可查找到对应的叶节点，之后获得行数据。若对Name列进行条件搜索，则需要两个步骤：第一步在辅助索引B+树中检索Name，到达其叶子节点获取对应的主键。第二步使用主键在主索引B+树种再执行一次B+树检索操作，最终到达叶子节点即可获取整行数据。

MyISAM索引实现
MyISAM索引文件和数据文件是分离的，索引文件仅保存数据记录的地址
主键索引
MyISAM引擎使用B+Tree作为索引结构，叶节点的data域存放的是数据记录的地址。可以看出MyISAM的索引文件仅仅保存数据记录的地址。

辅助索引（Secondary key）
在MyISAM中，主索引和辅助索引（Secondary key）在结构上没有任何区别，只是主索引要求key是唯一的，而辅助索引的key可以重复。
同样也是一颗B+Tree，data域保存数据记录的地址。因此，MyISAM中索引检索的算法为首先按照B+Tree搜索算法搜索索引，如果指定的Key存在，则取出其data域的值，然后以data域的值为地址，读取相应数据记录。
MyISAM的索引方式也叫做“非聚集”的，之所以这么称呼是为了与InnoDB的聚集索引区分。
MyISM使用的是非聚簇索引，非聚簇索引的两棵B+树看上去没什么不同，节点的结构完全一致只是存储的内容不同而已，主键索引B+树的节点存储了主键，辅助键索引B+树存储了辅助键。表数据存储在独立的地方，这两颗B+树的叶子节点都使用一个地址指向真正的表数据，对于表数据来说，这两个键没有任何差别。由于索引树是独立的，通过辅助键检索无需访问主键的索引树。
为了更形象说明这两种索引的区别，我们假想一个表如下图存储了4行数据。其中Id作为主索引，Name作为辅助索引。图示清晰的显示了聚簇索引和非聚簇索引的差异。
在Innodb下主键索引是聚集索引，在Myisam下主键索引是非聚集索引

聚簇索引和非聚簇索引的区别
聚簇索引的叶子节点存放的是主键值和数据行，支持覆盖索引；二级索引的叶子节点存放的是主键值或指向数据行的指针。
由于节子节点(数据页)只能按照一颗B+树排序，故一张表只能有一个聚簇索引。辅助索引的存在不影响聚簇索引中数据的组织，所以一张表可以有多个辅助索引

覆盖索引（covering index）指一个查询语句的执行只用从索引中就能够取得，不必从数据表中读取，也可以称之为实现了索引覆盖。 
当一条查询语句符合覆盖索引条件时，MySQL 只需要通过索引就可以返回查询所需要的数据，这样避免了查到索引后再返回表操作，减少 I/O 提高效率。 

创建索引
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


* index_name 索引名
* index_type 索引类型
* tbl_name 表名
* key_part 索引组成成员
* index_option 索引选项
* algorithm_option 算法选项
  - DEFAULT 默认算法
  - INPLACE
  - COPY
* lock_option 锁选项
  - DEFAULT 默认锁
  - NONE 无锁
  - SHARED 共享锁
  - EXCLUSIVE 排他锁
* index_type 索引底层数据结构，InnoDB 只支持 BTREE 索引
  - BTREE
  - HASH

InnoDB 存储引擎索引特征

|索引类别 | 索引存储类型 | 允许空值 | 允许多个空值 | `IS NULL` 扫描类型 | `IS NOT NULL` 扫描类型|
|-|-|-|-|-|-|
|`Primary key` |`BTREE` |`No`|  `No`|  `N/A` | `N/A`|
|`Unique`  |`BTREE` |`Yes`| `Yes`| `Index` | `Index`|
|`Key` |`BTREE` |`Yes`| `Yes`| `Index`| `Index`|
|`FULLTEXT` | `N/A` |`Yes`| `Yes`| `Table`| `Table`|
|`SPATIAL`| `N/A` |`No`|  `No`|  `N/A` |`N/A`|


索引分类
* UNIQUE 唯一索引，UNIQUE 索引创建一个约束，使得索引中的所有值都必须不同。如果您尝试添加具有与现有行匹配的键值的新行，则会发生错误。如果为 UNIQUE 索引中的列指定前缀值，则列值在前缀长度内必须是唯一的。 UNIQUE 索引允许可以包含 NULL 的列有多个 NULL 值。
* FULLTEXT 全文索引，只能包含 CHAR、VARCHAR 和 TEXT 列。索引总是发生在整个列上；不支持列前缀索引，如果指定，任何前缀长度都会被忽略。
* SPATIAL 空间索引，
  - 空间列上的空间索引（使用 SPATIAL INDEX 创建）具有以下特征：列值必须非空，列前缀长
    + 仅适用于 MyISAM 和 InnoDB 表。为其他存储引擎指定 SPATIAL INDEX 会导致错误
    + 度是被禁止的
    + 每列的全宽都被索引
  - 空间列上的非空间索引（使用 INDEX、UNIQUE 或 PRIMARY KEY 创建）具有以下特征：
    + 允许用于支持除 ARCHIVE 之外的空间列的任何存储引擎。
    + 除非索引是主键，否则列可以为 NULL。
    + 对于除 POINT 列之外的非 SPATIAL 索引中的每个空间列，必须指定列前缀长度。 （这与索引 BLOB 列的要求相同。）前缀长度以字节为单位给出。
    + 非空间索引的索引类型取决于存储引擎。目前使用的是B-tree。
    + 允许仅对 InnoDB、MyISAM 和 MEMORY 表具有 NULL 值的列。



索引不支持修改，只能通过删除在重建索引





增删查改

## 存储过程和存储函数

存储过程是一组为了完成特定功能的 SQL 语句集合。使用存储过程的目的是将常用或复杂的工作预先用 SQL 语句写好并用一个指定名称存储起来，这个过程经编译和优化后存储在数据库服务器中，因此称为存储过程。当以后需要数据库提供与已定义好的存储过程的功能相同的服务时，只需调用“CALL存储过程名字”即可自动完成。

优点：
* 封装性，通常完成一个逻辑功能需要多条 SQL 语句，而且各个语句之间很可能传递参数，所以，编写逻辑功能相对来说稍微复杂些，而存储过程可以把这些 SQL 语句包含到一个独立的单元中，使外界看不到复杂的 SQL 语句，只需要简单调用即可达到目的。并且数据库专业人员可以随时对存储过程进行修改，而不会影响到调用它的应用程序源代码。
* 可增强 SQL 语句的功能和灵活性，存储过程可以用流程控制语句编写，有很强的灵活性，可以完成复杂的判断和较复杂的运算。
* 可减少网络流量，由于存储过程是在服务器端运行的，且执行速度快，因此当客户计算机上调用该存储过程时，网络中传送的只是该调用语句，从而可降低网络负载。
* 高性能，当存储过程被成功编译后，就存储在数据库服务器里了，以后客户端可以直接调用，这样所有的 SQL 语句将从服务器执行，从而提高性能。但需要说明的是，存储过程不是越多越好，过多的使用存储过程反而影响系统性能。
* 提高数据库的安全性和数据的完整性，存储过程提高安全性的一个方案就是把它作为中间组件，存储过程里可以对某些表做相关操作，然后存储过程作为接口提供给外部程序。这样，外部程序无法直接操作数据库表，只能通过存储过程来操作对应的表，因此在一定程度上，安全性是可以得到提高的。
* 使数据独立，数据的独立可以达到解耦的效果，也就是说，程序可以调用存储过程，来替代执行多条的 SQL 语句


```sql
CREATE
    [DEFINER = { user | CURRENT_USER }]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body

CREATE
    [DEFINER = { user | CURRENT_USER }]
    FUNCTION sp_name ([func_parameter[,...]])
    RETURNS type
    [characteristic ...] routine_body

proc_parameter:
    [ IN | OUT | INOUT ] param_name type

func_parameter:
    param_name type

type:
    Any valid MySQL data type

characteristic:
    COMMENT 'string'
  | LANGUAGE SQL
  | [NOT] DETERMINISTIC
  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
  | SQL SECURITY { DEFINER | INVOKER }

routine_body:
    Valid SQL routine statement
```

* `sp_name` 存储过程或函数名
* `proc_parameter` 参数，param_name 表示参数名，type 参数类型
  - `IN` 输入参数
  - `OUT` 输出参数
  - `INOUT` 输入输出参数
* `func_parameter` 参数，param_name 表示参数名，type 参数类型
* `type` 返回类型，合法的MySQL类型
* `characteristic` 函数特征
  - `COMMENT` 描述信息
  - `LANGUAGE SQL` SQL语法
  - `[NOT] DETERMINISTIC` 是否是确定性的，输入参数一样返回结果一样即为确定性函数，默认不确定性
  - `CONTAINS SQL` 不包含读写数据的语句
  - `NO SQL` 不包含 SQL 语句
  - `READS SQL DATA` 包含读取语句不包含写入语句
  - `MODIFIES SQL DATA` 包含可能写入语句
  - `SQL SECURITY` 指定安全的上下文
    + `DEFINER` 使用指定的用户权限
    + `INVOKER` 使用调用者的用户权限
* `routine_body` SQL 代码内容，可以用 BEGIN 和 END 标识代码块

增删查改

存储函数和存储过程一样，都是在数据库中定义一些 SQL 语句的集合。存储函数可以通过 return 语句返回函数值，主要用于计算并返回一个值。而存储过程没有直接返回值，主要用于执行操作。

## 条件
定义条件是指事先定义程序执行过程中遇到的问题，处理程序定义了在遇到这些问题时应当采取的处理方式和解决办法，保证存储过程和函数在遇到警告或错误时能继续执行，从而增强程序处理问题的能力，避免程序出现异常被停止执行。
MySQL 中可以使用 **DECLARE** 关键字来定义条件。其基本语法如下：

```sql
DECLARE condition_name CONDITION FOR condition_value

condition_value:
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
```

* `condition_name` 参数表示条件的名称
* `condition_value` 参数表示条件的类型，表示 MySQL 的错误
  - `sqlstate_value` 表示长度为 5 的字符串类型错误代码
  - `mysql_error_code` 表示数值类型错误代码
  
例如 `ERROR 1146(42S02) `中，`sqlstate_value` 值是 `42S02`，`mysql_error_code` 值是 `1146`

## 处理程序

MySQL 中可以使用 **DECLARE** 关键字来定义处理程序。其基本语法如下：
```sql
DECLARE handler_action HANDLER
    FOR condition_value [, condition_value] ...
    statement

handler_action:
    CONTINUE
  | EXIT
  | UNDO

condition_value:
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
  | condition_name
  | SQLWARNING
  | NOT FOUND
  | SQLEXCEPTION
```

* `handler_type` 参数指明错误的处理方式
  - `CONTINUE` 表示遇到错误不进行处理，继续向下执行
  - `EXIT` 表示遇到错误后马上退出
  - `UNDO` 表示遇到错误后撤回之前的操作，MySQL 中暂时还不支持这种处理方式

* `condition_value` 参数指明错误类型
  - `mysql_error_code`：表示MySQL错误码的整型字面值，如1051表示“未知表”
  - `sqlstate_value`：一个 5 个字符的字符串文字，表示 SQLSTATE 值，例如“42S01”以指定“未知表”
  - `condition_name`：表示 DECLARE 定义的错误条件名称
  - `SQLWARNING`：匹配所有以 01 开头的 `sqlstate_value` 值
  - `NOT FOUND`：匹配所有以 02 开头的 `sqlstate_value` 值
  - `SQLEXCEPTION`：匹配所有没有被 `SQLWARNING` 或 `NOT FOUND` 捕获的 `sqlstate_value` 值

## 游标
个人理解游标就是一个标识，用来标识数据取到了什么地方，如果你了解编程语言，可以把他理解成数组中的下标。游标只能用于存储过程和函数

MySQL 中使用 **DECLARE** 关键字来声明游标，并定义相应的 SELECT 语句，根据需要添加 WHERE 和其它子句。其语法的基本形式如下：
```sql
DECLARE cursor_name CURSOR FOR select_statement
```

* `cursor_name` 表示游标的名称
* `select_statement` 表示 SELECT 语句，可以返回一行或多行数据。

## 触发器
在 MySQL 中，只有执行 INSERT、UPDATE 和 DELETE 操作时才能激活触发器，其它 SQL 语句则不会激活触发器。
触发器的优点如下：

*   触发器的执行是自动的，当对触发器相关表的数据做出相应的修改后立即执行。
*   触发器可以实施比 FOREIGN KEY 约束、CHECK 约束更为复杂的检查和操作。
*   触发器可以实现表数据的级联更改，在一定程度上保证了数据的完整性。

触发器的缺点如下：

*   使用触发器实现的业务逻辑在出现问题时很难进行定位，特别是涉及到多个触发器的情况下，会使后期维护变得困难。
*   大量使用触发器容易导致代码结构被打乱，增加了程序的复杂性，
*   如果需要变动的数据量较大时，触发器的执行效率会非常低。

在实际使用中，MySQL 所支持的触发器有三种：INSERT 触发器、UPDATE 触发器和 DELETE 触发器。

对于事务性表，如果触发程序失败，以及由此导致的整个语句失败，那么该语句所执行的所有更改将回滚；对于非事务性表，则不能执行此类回滚，即使语句失败，失败之前所做的任何更改依然有效。
* 若 BEFORE 触发程序失败，则 MySQL 将不执行相应行上的操作。
* 若在 BEFORE 或 AFTER 触发程序的执行过程中出现错误，则将导致调用触发程序的整个语句失败。
* 仅当 BEFORE 触发程序和行操作均已被成功执行，MySQL 才会执行 AFTER 触发程序。

### INSERT 触发器

在 INSERT 语句执行之前或之后响应的触发器。

使用 INSERT 触发器需要注意以下几点：

*   在 INSERT 触发器代码内，可引用一个名为 NEW（不区分大小写）的虚拟表来访问被插入的行。
*   在 BEFORE INSERT 触发器中，NEW 中的值也可以被更新，即允许更改被插入的值（只要具有对应的操作权限）。
*   对于 AUTO_INCREMENT 列，NEW 在 INSERT 执行之前包含的值是 0，在 INSERT 执行之后将包含新的自动生成值。

### UPDATE 触发器

在 UPDATE 语句执行之前或之后响应的触发器。

使用 UPDATE 触发器需要注意以下几点：

*   在 UPDATE 触发器代码内，可引用一个名为 NEW（不区分大小写）的虚拟表来访问更新的值。
*   在 UPDATE 触发器代码内，可引用一个名为 OLD（不区分大小写）的虚拟表来访问 UPDATE 语句执行前的值。
*   在 BEFORE UPDATE 触发器中，NEW 中的值可能也被更新，即允许更改将要用于 UPDATE 语句中的值（只要具有对应的操作权限）。
*   OLD 中的值全部是只读的，不能被更新。

注意：当触发器设计对触发表自身的更新操作时，只能使用 BEFORE 类型的触发器，AFTER 类型的触发器将不被允许。

### DELETE 触发器

在 DELETE 语句执行之前或之后响应的触发器。

使用 DELETE 触发器需要注意以下几点：

*   在 DELETE 触发器代码内，可以引用一个名为 OLD（不区分大小写）的虚拟表来访问被删除的行。
*   OLD 中的值全部是只读的，不能被更新。

### 添加触发器
在 MySQL 5.7 中，可以使用 CREATE TRIGGER 语句创建触发器。

语法格式如下：
```sql
CREATE
    [DEFINER = { user | CURRENT_USER }]
    TRIGGER trigger_name
    trigger_time trigger_event
    ON tbl_name FOR EACH ROW
    [trigger_order]
    trigger_body

trigger_time: { BEFORE | AFTER }

trigger_event: { INSERT | UPDATE | DELETE }

trigger_order: { FOLLOWS | PRECEDES } other_trigger_name
```

* `trigger_name` 触发器名称
* `trigger_time` 触发器被触发的时刻
  - `BEFORE` 在语句执行前触发，一般用于检测数据是否满足条件
  - `AFTER` 在语句执行后触发，一般用于语句执行之后完成几个或更多的改变
* `trigger_event` 触发事件，用于指定激活触发器的语句的种类
  - `INSERT` 将新行插入表时激活触发器。例如，INSERT 的 BEFORE 触发器不仅能被 MySQL 的 INSERT 语句激活，也能被 LOAD DATA 语句激活。
  - `DELETE` 从表中删除某一行数据时激活触发器，例如 DELETE 和 REPLACE 语句。
  - `UPDATE` 更改表中某一行数据时激活触发器，例如 UPDATE 语句。
* `tbl_name` 触发器关联表名
* `[trigger_order]` 控制触发器执行顺序
  - `PRECEDES` 当前触发器在`other_trigger_name`触发器之前执行
  - `FOLLOWS` 当前触发器在`other_trigger_name`触发器之后执行
* `trigger_body` 触发器执行语句，如果要执行多个语句，支持存储过程

触发器名
触发器的名称，触发器在当前数据库中必须具有唯一的名称。如果要在某个特定数据库中创建，名称前面应该加上数据库的名称。

`INSERT | UPDATE | DELETE`，触发事件，用于指定激活触发器的语句的种类。

注意：三种触发器的执行时间如下。


BEFORE | AFTER
BEFORE 和 AFTER，触发器被触发的时刻，表示触发器是在激活它的语句之前或之后触发。若希望验证新数据是否满足条件，则使用 BEFORE 选项；若希望在激活触发器的语句执行之后完成几个或更多的改变，则通常使用 AFTER 选项。

表名
与触发器相关联的表名，此表必须是永久性表，不能将触发器与临时表或视图关联起来。在该表上触发事件发生时才会激活触发器。同一个表不能拥有两个具有相同触发时刻和事件的触发器。例如，对于一张数据表，不能同时有两个 BEFORE UPDATE 触发器，但可以有一个 BEFORE UPDATE 触发器和一个 BEFORE INSERT 触发器，或一个 BEFORE UPDATE 触发器和一个 AFTER UPDATE 触发器。

触发器主体
触发器动作主体，包含触发器激活时将要执行的 MySQL 语句。如果要执行多个语句，可使用 BEGIN…END 复合语句结构。

FOR EACH ROW
一般是指行级触发，对于受触发事件影响的每一行都要激活触发器的动作。例如，使用 INSERT 语句向某个表中插入多行数据时，触发器会对每一行数据的插入都执行相应的触发器动作。

### 查看触发器
### 修改触发器
触发器不能更新或覆盖，为了修改一个触发器，必须先删除它，再重新创建。

## 事件
 
事件（event）是MySQL在相应的时刻调用的过程式数据库对象。一个事件可调用一次，也可周期性的启动，它由一个特定的线程来管理的，也就是所谓的“事件调度器”。
优点
* 一些对数据定时性操作不再依赖外部程序，而直接使用数据库本身提供的功能。
* 可以实现每秒钟执行一个任务，这在一些对实时性要求较高的环境下就非常实用了。

缺点
* 定时触发，不可以调用。

语法格式如下：
```sql
CREATE
    [DEFINER = { user | CURRENT_USER }]
    EVENT
    [IF NOT EXISTS]
    event_name
    ON SCHEDULE schedule
    [ON COMPLETION [NOT] PRESERVE]
    [ENABLE | DISABLE | DISABLE ON SLAVE]
    [COMMENT 'comment']
    DO event_body;

schedule:
    AT timestamp [+ INTERVAL interval] ...
  | EVERY interval
    [STARTS timestamp [+ INTERVAL interval] ...]
    [ENDS timestamp [+ INTERVAL interval] ...]

interval:
    quantity {YEAR | QUARTER | MONTH | DAY | HOUR | MINUTE |
              WEEK | SECOND | YEAR_MONTH | DAY_HOUR | DAY_MINUTE |
              DAY_SECOND | HOUR_MINUTE | HOUR_SECOND | MINUTE_SECOND}
```

* event_name，事件名称
* schedule，事件执行时间和频率，事件必须是将来时间，存在两种形式（`AT|EVERY`）
  - `AT`，在之后多久执行
  - `EVERY`，开始于`STARTS`结束于`ENDS`
* `[ON COMPLETION [NOT] PRESERVE]`，执行完毕后是否删除，默认是自动drop
* `[ENABLE | DISABLE | DISABLE ON SLAVE]`，设定事件状态
  - `ENABLE`，启用
  - `DISABLE`，关闭
  - `DISABLE ON SLAVE`，副本禁用
* comment，事件描述
* event_body，需要执行的sql语句（可以是复合语句），支持存储过程



## 事务
开始事务
提交事务
回滚事务

## 用户管理
权限表
增删改查用户
增删用户权限
修改密码

## 变量
### 局部变量
### 用户变量
### 系统变量
会话变量
全局变量


# 进阶知识
## 执行流程

* 连接器
* 查询缓存
* 分析器
* 优化器
* 执行器
* 存储引擎

## 约束
### 主键
联合主键
## 视图
## 索引
常见模型
* 哈希表
* 有序数组
* 搜索树

### InnoDB索引模型
主键索引和普通索引
索引维护
命中索引
不命中索引称作回表
覆盖索引
最左前缀原则
索引下推

普通索引和唯一索引
查询过程
更新过程
change buffer使用场景
索引选择
change buffer和redo log

mysql为啥会选错索引
优化器逻辑
索引选择异常和处理

给字符串加索引
前缀索引对覆盖索引的影响
其他方式
## 事务
### 事务隔离
隔离性和隔离级别

ACID
原子性
一致性
隔离性
持久性

多事务执行问题
脏读
不可重复读
幻读

隔离级别
读未提交
度提交
可重复读
串行化

事务隔离的实现
事务启动方式

事务是否隔离
快照在MVCC里面是怎么工作的
更新逻辑
事务怎么实现可重复读


## 锁
用动态的观点看加锁
不等号条件的等值查询
等值查询过程
怎么看死锁
怎么看锁等待
update例子

mysql存储机制
binlog写入机制
redo log写入机制


## 日志系统
日志模块
* redo log
* binlog

两阶段提交

日志相关问题
* mysql怎么知道binlog是完整的
* redo log和binlog是怎么关联起来的
* 处于prepare阶段的redo log加上完整binlog，重启恢复
* 两阶段提交和redo log+binlog
* 只要redo log不要binlog
* redo log一般设置多大
* 所如磁盘的是redo log还是buffer pool
* redo log buffer是什么
业务设计问题

## order by
order by工作方式
全字段排序
rowid排序
对比
## group by

## count
count(*)的实现方式
用缓存系统保存计数
在数据库保存计数
不同的count用法
* count(主键)
* count(1)
* count(字段)
* count(*)

## join

join写法
simple nested loop join的性能问题
distinct和group by的性能
备库自增主键问题

到底用不用join
index nested-loop join
simple nested-loop join
block nested-loop join

join语句优化
multi-range read优化
batched key access
BNL算法性能问题
BNL转BKA
扩展 -hash join



## mysql锁
全局锁
表级锁
行锁

两阶段锁 行锁需要的时候获取，但不是立即释放是等到事务结束时释放
死锁和死锁检测


insert语句锁
insert ... select
insert循环写入
insert唯一键冲突
insert into ... on duplicate key update

幻读
幻读有什么问题
如何解决幻读，间隙锁和next-key lock

修改一行数据锁
原则：
* 加锁基本单位
* 访问对象加锁
优化：
* 等值查询，给唯一索引加锁时，next-key lock退化为行锁
* 等值查询，向右遍历时且最后一个值不满足等值条件时，next-key lock退化为间隙锁
bug
* 唯一索引上的范围查询会访问到不满足条件的第一个值为止

案例
* 等值查询间隙锁
* 非唯一索引等值锁
* 主键索引范围锁
* 非唯一索引范围锁
* 唯一索引范围锁 bug
* 非唯一索引上存在等值的例子
* limit语句加锁
* 死锁例子


## 临时表
临时表重名
临时表特性
临时表应用
为什么临时表key重名
临时表和主备复制

内部临时表
union执行流程
group by执行流程
group by优化方法——索引
group by优化方法——直接排序

正确显示随机消息
内存临时表
磁盘临时表
随机排序方法


## 内存引擎
使用memory引擎
内存表数据组织结构
hash索引和B-Tree索引
内存表的锁
数据持久性问题


## 主从架构

最快的复制一张表
mysqldump方法
导出csv文件
物理拷贝方法

mysql主备一致
原理
binlog三种格式对比
mixed格式的binlog
循环复制问题

mysql高可用
主备延迟
主备延迟来源
可靠性优先策略
可用性优先策略

备库延迟
不同版本msyql策略不一样
并行复制策略
* 按表分发策略
* 按行分发策略

主库出问题从库怎么办
基于位点的主备切换
GTID
基于GTID的主备切换
GTID和在线DDL

读写分离的坑
会出现过期读
强制走主库方案，请求分类
sleep方案
判断主备无延迟方案
配合semi-sync
等主库位点方案
GTID方案

如何判断数据库是否出问题
select1判断
查表判断
更新判断
内部统计

## 拆分数据
### 分库分表
分库垂直拆分，过代理，代理获取分库后的数据
分表水平拆分，主动计算表名，获取数据
连接数，数据量

缺点
相关功能可能需要再服务代码中实现

迁移流程
双写读旧
双写读新
单写读新

### 分区
range
list
hash
key
columns

分区表
什么事分区表
分区表引擎层行为
分区策略
分区表的server层行为
分区表应用场景

## 自增id
自增ID用完了怎么办
表定义自增值id
innoDB系统自增row_id
Xid
innoDB trx_id
thread_id

自增组件为啥不是连续的
自增值保存在哪
自增值修改机制
自增值的修改时机
自增锁的优化

## 性能优化
### 优化查询
mysql 为啥会抖一下
sql为啥会变慢
innoDB刷脏页的控制策略


查大量数据会不会把内存打爆
全表扫描对server层的影响
全表扫描对innoDB的影响

### 优化数据库结构
饮鸩止渴提高性能方法
短连接风暴
慢查询性能
qps突增

### 优化数据库服务器
升级硬件配置
通过不同策略使用不同配置的数据库，合理使用低性能库

修改服务器配置


## 备份与恢复
删除数据流程
重建表
online 和 inplace

误删数据处理
误删行
误删库表
延迟复制备库
预防误删库表方法
rm删除数据

kill不掉的情况
mysql收到kill信号处理方式


## 权限管理
grant之后要跟着flush privileges
全局权限
db权限
表权限和列权限
flush privileges场景

# 参考文献
* [MySQL 5.7 Reference Manual](https://dev.mysql.com/doc/refman/5.7/en/)
* [MySQL教程](http://c.biancheng.net/mysql/)
* [菜鸟教程](https://www.runoob.com/sql/sql-tutorial.html)
* [MySQL常用函数](https://www.cnblogs.com/qdhxhz/p/16500580.html)
* 《MySQL5.7从入门到精通》