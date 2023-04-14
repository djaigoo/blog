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
文档数据库：MongoDB
缓存数据库：Redis
时序数据库：InfluxDB
搜索数据库：Elasticsearch

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

## workbench

## InnoDB简介


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
表示时间值的日期和时间数据类型有 DATE、TIME、DATETIME、TIMESTAMP 和 YEAR。每个时间类型都有一系列有效值，以及一个“零”值，当您指定 MySQL 无法表示的无效值时可能会使用该值。 TIMESTAMP 和 DATETIME 类型具有特殊的自动更新行为。

使用日期和时间类型时，请记住以下一般注意事项：

MySQL 以标准输出格式检索给定日期或时间类型的值，但它会尝试为您提供的输入值解释各种格式（例如，当您指定要分配给日期或与日期或时间类型）。有关日期和时间类型的允许格式的说明，请参阅第 9.1.3 节“日期和时间文字”。期望您提供有效值。如果您使用其他格式的值，可能会出现不可预测的结果。

尽管 MySQL 尝试以多种格式解释值，但日期部分必须始终以年-月-日的顺序给出（例如，'98-09-04'），而不是月-日-年或日-月-别处常用的年份订单（例如，“09-04-98”、“04-09-98”）。要将其他顺序的字符串转换为年-月-日顺序，STR_TO_DATE() 函数可能会有用。

包含两位数年份值的日期是不明确的，因为世纪是未知的。 MySQL 使用以下规则解释 2 位数年份值：

70-99 范围内的年份值变为 1970-1999。

00-69 范围内的年份值变为 2000-2069。

另见第 11.2.9 节，“日期中的两位数年份”。

根据第 11.2.8 节“日期和时间类型之间的转换”中的规则，将值从一种时间类型转换为另一种时间类型。

如果值用于数字上下文，MySQL 会自动将日期或时间值转换为数字，反之亦然。

默认情况下，当 MySQL 遇到日期或时间类型的值超出范围或对该类型无效时，它将将该值转换为该类型的“零”值。例外情况是超出范围的 TIME 值被裁剪到 TIME 范围的适当端点。

通过将 SQL 模式设置为适当的值，您可以更准确地指定您希望 MySQL 支持的日期类型。 （请参阅第 5.1.10 节，“服务器 SQL 模式”。）您可以通过启用 ALLOW_INVALID_DATES SQL 模式让 MySQL 接受某些日期，例如“2009-11-31”。当您想要在数据库中存储用户指定的“可能错误”值（例如，在 Web 表单中）以供将来处理时，这很有用。在这种模式下，MySQL只校验月份在1~12范围内，日在1~31范围内。

MySQL 允许您在 DATE 或 DATETIME 列中存储日或月日为零的日期。这对于需要存储您可能不知道确切日期的生日的应用程序很有用。在这种情况下，您只需将日期存储为“2009-00-00”或“2009-01-00”。但是，对于诸如此类的日期，您不应期望获得需要完整日期的 DATE_SUB() 或 DATE_ADD() 等函数的正确结果。要禁止日期中的零月或日部分，请启用 NO_ZERO_IN_DATE 模式。

MySQL 允许您将“0000-00-00”的“零”值存储为“虚拟日期”。在某些情况下，这比使用 NULL 值更方便，并且使用更少的数据和索引空间。要禁止 '0000-00-00'，请启用 NO_ZERO_DATE 模式。

通过连接器/ODBC 使用的“零”日期或时间值会自动转换为 NULL，因为 ODBC 无法处理此类值。

下表显示了每种类型的“零”值的格式。 “零”值很特殊，但您可以使用表中显示的值显式存储或引用它们。您也可以使用更易于编写的值“0”或 0 来执行此操作。对于包含日期部分（DATE、DATETIME 和 TIMESTAMP）的时间类型，使用这些值可能会产生警告或错误。精确的行为取决于启用了严格和 NO_ZERO_DATE SQL 模式中的哪一个（如果有的话）；参见第 5.1.10 节，“服务器 SQL 模式”。


时间日期字段零值

|Data Type| “Zero” Value|
|---|---|
|DATE |'0000-00-00'|
|TIME |'00:00:00'|
|DATETIME |'0000-00-00 00:00:00'|
|TIMESTAMP  |'0000-00-00 00:00:00'|
|YEAR |0000|

|类型名称    |日期格式    | 日期范围                                                      |存储需求|
|-|-|-|-|
|YEAR       |YYYY       | 1901 ~ 2155                                                  |1 个字节|
|TIME       |HH:MM:SS   | -838:59:59 ~ 838:59:59                                       |3 个字节|
|DATE       |YYYY-MM-DD | 1000-01-01 ~ 9999-12-3                                       |3 个字节|
|DATETIME   |YYYY-MM-DD | HH:MM:SS 1000-01-01 00:00:00 ~ 9999-12-31 23:59:59           |8 个字节|
|TIMESTAMP  |YYYY-MM-DD | HH:MM:SS 1970-01-01 00:00:01 UTC ~ 2038-01-19 03:14:07 UTC   |4 个字节|

### 字符串
字符串数据类型为 CHAR、VARCHAR、BINARY、VARBINARY、BLOB、TEXT、ENUM 和 SET。

对于字符串列（CHAR、VARCHAR 和 TEXT 类型）的定义，MySQL 以字符单位解释长度规范。对于二进制字符串列（BINARY、VARBINARY 和 BLOB 类型）的定义，MySQL 以字节为单位解释长度规范。
字符列比较和排序基于分配给该列的排序规则。对于 CHAR、VARCHAR、TEXT、ENUM 和 SET 数据类型，您可以声明具有二进制 (bin) 归类或 BINARY 属性的列，以使用基础字符代码值而不是词法排序进行比较和排序。

* [NATIONAL] CHAR[(M)] [CHARACTER SET charset_name] [COLLATE collation_name]
一个固定长度的字符串，在存储时总是用空格向右填充到指定的长度。 M 表示以字符为单位的列长度。 M的取值范围为0～255，省略M则长度为1。CHAR 是 CHARACTER 的简写。 NATIONAL CHAR（或其等效的缩写形式 NCHAR）是定义 CHAR 列应使用某些预定义字符集的标准 SQL 方法。MySQL 允许您创建类型为 CHAR(0) 的列。这主要在您必须与依赖于列的存在但实际上不使用其值的旧应用程序兼容时有用。当您需要一个只能取两个值的列时，CHAR(0) 也非常好：定义为 CHAR(0) NULL 的列只占用一位并且只能取值 NULL 和 ''（空字符串） .

* [NATIONAL] VARCHAR(M) [CHARACTER SET charset_name] [COLLATE collation_name]
可变长度字符串。 M 表示以字符为单位的最大列长度。 M 的范围是 0 到 65,535。 VARCHAR 的有效最大长度取决于最大行大小（65,535 字节，由所有列共享）和使用的字符集。例如，utf8 字符可能需要每个字符最多三个字节，因此使用 utf8 字符集的 VARCHAR 列可以声明为最多 21,844 个字符。MySQL 将 VARCHAR 值存储为 1 字节或 2 字节长度的前缀加上数据。长度前缀指示值中的字节数。如果值需要不超过 255 个字节，则 VARCHAR 列使用一个长度字节，如果值可能需要超过 255 个字节，则使用两个长度字节。VARCHAR 是 CHARACTER VARYING 的简写。 NATIONAL VARCHAR 是定义 VARCHAR 列应使用某些预定义字符集的标准 SQL 方法。 MySQL 使用 utf8 作为这个预定义的字符集。 NVARCHAR 是 NATIONAL VARCHAR 的简写。

* BINARY[(M)]
BINARY 类型类似于 CHAR 类型，但存储二进制字节字符串而不是非二进制字符串。可选长度 M 表示以字节为单位的列长度。如果省略，M 默认为 1。

* VARBINARY(M)
VARBINARY 类型类似于 VARCHAR 类型，但存储二进制字节字符串而不是非二进制字符串。 M 表示以字节为单位的最大列长度。

* TINYBLOB
最大长度为 255 ($2^8 − 1$) 字节的 BLOB 列。每个 TINYBLOB 值都使用 1 字节长度的前缀存储，该前缀指示值中的字节数。

* TINYTEXT [CHARACTER SET charset_name] [COLLATE collation_name]
最大长度为 255 ($2^8 − 1$) 个字符的 TEXT 列。如果值包含多字节字符，则有效最大长度会更短。每个 TINYTEXT 值都使用 1 字节长度的前缀存储，该前缀指示值中的字节数。

* BLOB[(M)]
最大长度为 65,535 ($2^{16} − 1$) 字节的 BLOB 列。每个 BLOB 值都使用 2 字节长度的前缀存储，该前缀指示值中的字节数。
可以为这种类型给出一个可选的长度 M。如果这样做，MySQL 将创建该列作为最小的 BLOB 类型，其大小足以容纳 M 字节长的值。

* TEXT[(M)] [CHARACTER SET charset_name] [COLLATE collation_name]
最大长度为 65,535 ($2^{16} − 1$) 个字符的 TEXT 列。如果值包含多字节字符，则有效最大长度会更短。每个 TEXT 值都使用 2 字节长度的前缀存储，该前缀指示值中的字节数。可以为这种类型给出一个可选的长度 M。如果这样做了，MySQL 将创建该列作为最小的 TEXT 类型，其大小足以容纳 M 个字符长的值。

* MEDIUMBLOB
最大长度为 16,777,215 ($2^{24} − 1$) 字节的 BLOB 列。每个 MEDIUMBLOB 值都使用 3 字节长度的前缀存储，该前缀指示值中的字节数。

* MEDIUMTEXT [CHARACTER SET charset_name] [COLLATE collation_name]
最大长度为 16,777,215 ($2^{24} − 1$) 个字符的 TEXT 列。如果值包含多字节字符，则有效最大长度会更短。每个 MEDIUMTEXT 值都使用 3 字节长度的前缀存储，该前缀指示值中的字节数。

* LONGBLOB
最大长度为 4,294,967,295 或 4GB ($2^{32} − 1$) 字节的 BLOB 列。 LONGBLOB 列的有效最大长度取决于客户端/服务器协议中配置的最大数据包大小和可用内存。每个 LONGBLOB 值都使用 4 字节长度前缀存储，该前缀指示值中的字节数。

* LONGTEXT [CHARACTER SET charset_name] [COLLATE collation_name]
最大长度为 4,294,967,295 或 4GB ($2^{32} − 1$) 个字符的 TEXT 列。如果值包含多字节字符，则有效最大长度会更短。 LONGTEXT 列的有效最大长度还取决于客户端/服务器协议中配置的最大数据包大小和可用内存。每个 LONGTEXT 值都使用 4 字节长度前缀存储，该前缀指示值中的字节数。

* ENUM('value1','value2',...) [CHARACTER SET charset_name] [COLLATE collation_name]
一个只能有一个值的字符串对象，从值列表“value1”、“value2”、...、NULL 或特殊的“”错误值中选择。 ENUM 值在内部表示为整数。一个 ENUM 列最多可以有 65,535 个不同的元素。 （实际限制小于 3000。）一个表在其被视为一个组的 ENUM 和 SET 列中可以有不超过 255 个唯一元素列表定义。有关这些限制的更多信息，请参阅 .frm 文件结构施加的限制。

* SET('value1','value2',...) [CHARACTER SET charset_name] [COLLATE collation_name]
一个可以有零个或多个值的字符串对象，每个值都必须从值列表“value1”、“value2”...中选择 SET 值在内部表示为整数。一个 SET 列最多可以有 64 个不同的成员。一个表在其被视为一个组的 ENUM 和 SET 列中可以有不超过 255 个唯一元素列表定义。有关此限制的更多信息，请参阅 .frm 文件结构施加的限制。


字符类型

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


 二进制类型

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
|2 | `\|\|`、`OR`|
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
限制查询结果条数
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
[详细文档](https://dev.mysql.com/doc/refman/5.7/en/functions.html)

### 数值函数

[文档](https://dev.mysql.com/doc/refman/5.7/en/mathematical-functions.html)

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

[文档](https://dev.mysql.com/doc/refman/5.7/en/string-functions.html)

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

[文档](https://dev.mysql.com/doc/refman/5.7/en/date-and-time-functions.html)

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
|`%a` | 缩写星期名 |
|`%b` | 缩写月名 |
|`%c` | 月，数值 |
|`%D` | 带有英文前缀的月中的天 |
|`%d` | 月的天，数值(00-31) |
|`%e` | 月的天，数值(0-31) |
|`%f` | 微秒 |
|`%H` | 小时 (00-23) |
|`%h` | 小时 (01-12) |
|`%I` | 小时 (01-12) |
|`%i` | 分钟，数值(00-59) |
|`%j` | 年的天 (001-366) |
|`%k` | 小时 (0-23) |
|`%l` | 小时 (1-12) |
|`%M` | 月名 |
|`%m` | 月，数值(00-12) |
|`%p` | AM 或 PM |
|`%r` | 时间，12-小时（hh:mm:ss AM 或 PM） |
|`%S` | 秒(00-59) |
|`%s` | 秒(00-59) |
|`%T` | 时间, 24-小时 (hh:mm:ss) |
|`%U` | 周 (00-53) 星期日是一周的第一天 |
|`%u` | 周 (00-53) 星期一是一周的第一天 |
|`%V` | 周 (01-53) 星期日是一周的第一天，与 %X 使用 |
|`%v` | 周 (01-53) 星期一是一周的第一天，与 %x 使用 |
|`%W` | 星期名 |
|`%w` | 周的天 （0=星期日, 6=星期六） |
|`%X` | 年，其中的星期日是周的第一天，4 位，与 %V 使用 |
|`%x` | 年，其中的星期一是周的第一天，4 位，与 %v 使用 |
|`%Y` | 年，4 位 |
|`%y` | 年，2 位 |

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
聚合函数是指将查询到的所有结果进行相应的操作
[文档](https://dev.mysql.com/doc/refman/5.7/en/aggregate-functions.html)

| 函数      | 含义    |
| --------- | -------- |
|`avg(x)` |           返回指定列的平均值|
|`count(x)` |         返回指定列中非null值的个数|
|`min(x)` |           返回指定列的最小值|
|`max(x)` |           返回指定列的最大值|
|`sum(x)` |           返回指定列的所有值之和|
|`group_concat(x)` |  返回由属于一组的列值连接组合而成的结果，非常有用|


### 流程控制函数
流程控制函数是指语句按指定条件进行执行

[文档](https://dev.mysql.com/doc/refman/5.7/en/flow-control-functions.html)

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


### 其他函数
* [全文本搜索](https://dev.mysql.com/doc/refman/5.7/en/fulltext-search.html)
* [加密和压缩](https://dev.mysql.com/doc/refman/5.7/en/encryption-functions.html)
* [锁函数](https://dev.mysql.com/doc/refman/5.7/en/locking-functions.html)
* [数据库信息](https://dev.mysql.com/doc/refman/5.7/en/information-functions.html)
* [JSON操作](https://dev.mysql.com/doc/refman/5.7/en/json-function-reference.html)
* [杂项](https://dev.mysql.com/doc/refman/5.7/en/miscellaneous-functions.html)

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
* 采用聚簇索引插入新值比采用非聚簇索引插入新值的速度要慢很多，因为插入要保证主键不能重复，判断主键不能重复，采用的方式在不同的索引下面会有很大的性能差距，
* 聚簇索引遍历所有的叶子节点，非聚簇索引也判断所有的叶子节点，但是聚簇索引的叶子节点除了带有主键还有记录值，记录的大小往往比主键要大的多。
* 这样就会导致聚簇索引在判定新记录携带的主键是否重复时进行昂贵的I/O代价。


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
叶节点包含了完整的数据记录。这种索引叫做聚集索引。因为InnoDB的数据文件本身要按主键聚集，所以InnoDB要求表必须有主键（MyISAM可以没有），
如果没有显式指定，则MySQL系统会自动选择一个可以唯一标识数据记录的列作为主键，
如果不存在这种列，则MySQL自动为InnoDB表生成一个隐含字段作为主键，这个字段长度为6个字节，类型为长整形。
InnoDB的辅助索引
   InnoDB的所有辅助索引都引用主键作为data域。
InnoDB 表是基于聚簇索引建立的。因此InnoDB 的索引能提供一种非常快速的主键查找性能。不过，它的辅助索引（Secondary Index， 也就是非主键索引）也会包含主键列，
所以，如果主键定义的比较大，其他索引也将很大。如果想在表上定义 、很多索引，则争取尽量把主键定义得小一些。InnoDB 不会压缩索引。
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
BEFORE 和 AFTER，触发器被触发的时刻，表示触发器是在激活它的语句之前或之后触发。若希望验证新数据是否满足条件，则使用 BEFORE 选项；
若希望在激活触发器的语句执行之后完成几个或更多的改变，则通常使用 AFTER 选项。

表名
与触发器相关联的表名，此表必须是永久性表，不能将触发器与临时表或视图关联起来。在该表上触发事件发生时才会激活触发器。
同一个表不能拥有两个具有相同触发时刻和事件的触发器。
例如，对于一张数据表，不能同时有两个 BEFORE UPDATE 触发器，但可以有一个 BEFORE UPDATE 触发器和一个 BEFORE INSERT 触发器，或一个 BEFORE UPDATE 触发器和一个 AFTER UPDATE 触发器。

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
局部变量一般用在sql语句块中，比如存储过程的begin/end。其作用域仅限于该语句块，在该语句块执行完毕后，局部变量就消失了。declare语句专门用于定义局部变量，可以使用default来说明默认值。set语句是设置不同类型的变量，包括会话变量和全局变量。 
局部变量定义语法形式
```sql
declare var_name [, var_name]... data_type [ DEFAULT value ];
```
例如在begin/end语句块中添加如下一段语句，接受函数传进来的a/b变量然后相加，通过set语句赋值给c变量。 

set语句语法形式set var_name=expr [, var_name=expr]...; set语句既可以用于局部变量的赋值，也可以用于用户变量的申明并赋值。
```sql
declare c int default 0;
set c=a+b;
select c as C;
```
或者用select …. into…形式赋值
```sql
select col_name[,...] into var_name[,...] table_expr [where...];
```
### 用户变量

MySQL中用户变量不用事前申明，在用的时候直接用“@变量名”使用就可以了。 
第一种用法：set @num=1; 或set @num:=1; //这里要使用set语句创建并初始化变量，直接使用@num变量 
第二种用法：select @num:=1; 或 select @num:=字段名 from 表名 where ……， 

select语句一般用来输出用户变量，比如select @变量名，用于输出数据源不是表格的数据。
注意上面两种赋值符号，使用set时可以用“=”或“:=”，但是使用select时必须用“:=赋值”
用户变量与数据库连接有关，在连接中声明的变量，在存储过程中创建了用户变量后一直到数据库实例接断开的时候，变量就会消失。
在此连接中声明的变量无法在另一连接中使用。

用户变量的变量名的形式为@varname的形式。
名字必须以@开头。
声明变量的时候需要使用set语句，比如下面的语句声明了一个名为@a的变量。
```sql
set @a = 1;
```

声明一个名为@a的变量，并将它赋值为1，MySQL里面的变量是不严格限制数据类型的，它的数据类型根据你赋给它的值而随时变化 。（SQL SERVER中使用declare语句声明变量，且严格限制数据类型。） 

我们还可以使用select语句为变量赋值 。 

比如：
```sql
set @name = '';
select @name:=password from user limit 0,1;
```

从数据表中获取一条记录password字段的值给@name变量。在执行后输出到查询结果集上面。（注意等于号前面有一个冒号，后面的limit 0,1是用来限制返回结果的，表示可以是0或1个。相当于SQL SERVER里面的top 1） 

如果直接写：`select @name:=password from user;`

如果这个查询返回多个值的话，那@name变量的值就是最后一条记录的password字段的值 。 

用户变量可以作用于当前整个连接，但当当前连接断开后，其所定义的用户变量都会消失。 

用户变量使用如下（我们无须使用declare关键字对用户变量进行定义，可以直接这样使用）定义，变量名必须以@开始：
```sql
-- 定义
select @变量名  或者 select @变量名:= 字段名 from 表名 where 过滤语句;
set @变量名;
-- 赋值 @num为变量名，value为值
set @num=value;或select @num:=value;
```

对用户变量赋值有两种方式，一种是直接用”=”号，另一种是用”:=”号。其区别在于使用set命令对用户变量进行赋值时，两种方式都可以使用；当使用select语句对用户变量进行赋值时，只能使用”:=”方式，因为在select语句中，”=”号declare语句专门用于定义局部变量。set语句是设置不同类型的变量，包括会话变量和全局变量。

例如：
```sql
begin
    declare c int default 0;
    set @var1=143;  #定义一个用户变量，并初始化为143
    set @var2=34;
    set c=a+b;
    set @d=c;
    select @sum:=(@var1+@var2) as sum, @dif:=(@var1-@var2) as dif, @d as C;#使用用户变量。@var1表示变量名

    set c=100;
    select c as CA;
end
```

#在查询中执行下面语句段
call `order`(12,13);  #执行上面定义的存储过程
select @var1;  #看定义的用户变量在存储过程执行完后，是否还可以输出，结果是可以输出用户变量@var1,@var2两个变量的。
select @var2;
复制代码
在执行完order存储过程后，在存储过程中新建的var1，var2用户变量还是可以用select语句输出的，但是存储过程里面定义的局部变量c不能识别。

### 系统变量
系统变量又分为全局变量与会话变量。

全局变量在MySQL启动的时候由服务器自动将它们初始化为默认值，这些默认值可以通过更改my.ini这个文件来更改。

会话变量在每次建立一个新的连接的时候，由MySQL来初始化。MySQL会将当前所有全局变量的值复制一份。来做为会话变量。

（也就是说，如果在建立会话以后，没有手动更改过会话变量与全局变量的值，那所有这些变量的值都是一样的。）

全局变量与会话变量的区别就在于，对全局变量的修改会影响到整个服务器，但是对会话变量的修改，只会影响到当前的会话（也就是当前的数据库连接）。

我们可以利用

show session variables;
语句将所有的会话变量输出（可以简写为show variables，没有指定是输出全局变量还是会话变量的话，默认就输出会话变量。）如果想输出所有全局变量：

show global variables
有些系统变量的值是可以利用语句来动态进行更改的，但是有些系统变量的值却是只读的。

对于那些可以更改的系统变量，我们可以利用set语句进行更改。

系统变量在变量名前面有两个@； 

如果想要更改会话变量的值，利用语句：
`set session varname = value;`或者`set @@session.varname = value;`


#### 会话变量

服务器为每个连接的客户端维护一系列会话变量。在客户端连接数据库实例时，使用相应全局变量的当前值对客户端的会话变量进行初始化。设置会话变量不需要特殊权限，但客户端只能更改自己的会话变量，而不能更改其它客户端的会话变量。会话变量的作用域与用户变量一样，仅限于当前连接。当当前连接断开后，其设置的所有会话变量均失效。

设置会话变量有如下三种方式更改会话变量的值：

```sql
set session var_name = value;
set @@session.var_name = value;
set var_name = value;  -- 缺省session关键字默认认为是session
```


查看所有的会话变量
```sql
show session variables;
```
查看一个会话变量也有如下三种方式：
```sql
select @@var_name;
select @@session.var_name;
show session variables like "%var%";
```

凡是上面提到的session，都可以用local这个关键字来代替。 
```sql
select @@local.sort_buffer_size 
```

无论是在设置系统变量还是查询系统变量值的时候，只要没有指定到底是全局变量还是会话变量。都当做会话变量来处理。 


#### 全局变量

全局变量影响服务器整体操作。当服务器启动时，它将所有全局变量初始化为默认值。这些默认值可以在选项文件中或在命令行中指定的选项进行更改。要想更改全局变量，必须具有super权限。全局变量作用于server的整个生命周期，但是不能跨重启。即重启后所有设置的全局变量均失效。要想让全局变量重启后继续生效，需要更改相应的配置文件。

要设置一个全局变量，有如下两种方式：
```sql
set global var_name = value; -- 注意：此处的global不能省略。根据手册，set命令设置变量时若不指定GLOBAL、SESSION或者LOCAL，默认使用SESSION
set @@global.var_name = value; -- 同上
```

查看所有的全局变量 
```sql
show global variables; 
```

要想查看一个全局变量，有如下两种方式：
```sql
select @@global.var_name;
show global variables like “%var%”;
```


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

自动提交事务
```sql
mysql> show variables like 'autocommit';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| autocommit    | ON    |
+---------------+-------+

mysql> select @@autocommit;
+--------------+
| @@autocommit |
+--------------+
|            1 |
+--------------+
```

### 事务隔离
隔离性和隔离级别

ACID
* 原子性（Atomicity），事务是一个完整的操作。事务的各元素是不可分的（原子的）。事务中的所有元素必须作为一个整体提交或回滚。如果事务中的任何元素失败，则整个事务将失败。
* 一致性（Consistency），当事务完成时，数据必须处于一致状态。也就是说，在事务开始之前，数据库中存储的数据处于一致状态。在正在进行的事务中. 数据可能处于不一致的状态，如数据可能有部分被修改。然而，当事务成功完成时，数据必须再次回到已知的一致状态。通过事务对数据所做的修改不能损坏数据，或者说事务不能使数据存储处于不稳定的状态。
* 隔离性（Isolation），对数据进行修改的所有并发事务是彼此隔离的，这表明事务必须是独立的，它不应以任何方式依赖于或影响其他事务。修改数据的事务可以在另一个使用相同数据的事务开始之前访问这些数据，或者在另一个使用相同数据的事务结束之后访问这些数据。
* 持久性（Durability），事务的持久性指不管系统是否发生了故障，事务处理的结果都是永久的。

InnoDB 存储引擎事务主要通过 UNDO 日志和 REDO 日志实现：
* UNDO 日志：复制事务执行前的数据，用于在事务发生异常时回滚数据。
* REDO 日志：记录在事务执行中，每条对数据进行更新的操作，当事务提交时，该内容将被刷新到磁盘。

默认设置下，每条 SQL 语句就是一个事务，即执行 SQL 语句后自动提交。为了达到将几个操作做为一个整体的目的，需要使用 BEGIN 或 START TRANSACTION 开启一个事务，或者禁止当前会话的自动提交。

事务控制语句：
* BEGIN 或 START TRANSACTION 显式地开启一个事务；
* COMMIT 也可以使用 COMMIT WORK，不过二者是等价的。COMMIT 会提交事务，并使已对数据库进行的所有修改成为永久性的；
* ROLLBACK 也可以使用 ROLLBACK WORK，不过二者是等价的。回滚会结束用户的事务，并撤销正在进行的所有未提交的修改；
* SAVEPOINT identifier，SAVEPOINT 允许在事务中创建一个保存点，一个事务中可以有多个 SAVEPOINT；
* RELEASE SAVEPOINT identifier 删除一个事务的保存点，当没有指定的保存点时，执行该语句会抛出一个异常；
* ROLLBACK TO identifier 把事务回滚到标记点；
* SET TRANSACTION 用来设置事务的隔离级别。InnoDB 存储引擎提供事务的隔离级别有READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ 和 SERIALIZABLE。

MYSQL 事务处理主要有两种方法：
* 用 BEGIN, ROLLBACK, COMMIT来实现
  - BEGIN 开始一个事务
  - ROLLBACK 事务回滚
  - COMMIT 事务确认
* 直接用 SET 来改变 MySQL 的自动提交模式:
  - SET AUTOCOMMIT=0 禁止自动提交
  - SET AUTOCOMMIT=1 开启自动提交
  
### 事务隔离级别
数据库事务的隔离级别有4个，由低到高依次为`Read uncommitted`、`Read committed`、`Repeatable read`、`Serializable` ，这四个级别可以逐个解决脏读 、不可重复读 、幻读 这几类问题。

不同事务隔离级别引发的问题：

| 事务隔离级别 | 脏读 | 不可重复读 | 幻读 |
|--|--|--|--|
| `Read uncommitted` | ✅  | ✅ | ✅ |
| `Read committed` | ❎ | ✅ | ✅ |
| `Repeatable read` | ❎ | ❎ | ✅ |
| `Serializable` | ❎ | ❎ | ❎ |


* `Read uncommitted (RU)` 读未提交，就是一个事务可以读取另一个未提交事务的数据。MySQL 事务隔离其实是依靠锁来实现的，加锁自然会带来性能的损失。而读未提交隔离级别是不加锁的，所以它的性能是最好的，没有加锁、解锁带来的性能开销。但有利就有弊，这基本上就相当于裸奔啊，所以它连脏读的问题都没办法解决。
* `Read committed (RC)` 读提交，就是一个事务要等另一个事务提交后才能读取数据。
* `Repeatable read (RR)` 重复读，就是在开始读取数据（事务开启）时，不再允许修改操作。可重复是对比不可重复而言的，上面说不可重复读是指同一事物不同时刻读到的数据值可能不一致。而可重复读是指，事务不会读到其他事务对已有数据的修改，及时其他事务已提交，也就是说，事务开始时读到的已有数据是什么，在事务提交前的任意时刻，这些数据的值都是一样的。但是，对于其他事务新插入的数据是可以读到的，这也就引发了幻读问题。
* `Serializable` 串行化，是最高的事务隔离级别，在该级别下，事务串行化顺序执行，可以避免脏读、不可重复读与幻读。但是这种事务隔离级别效率低下，比较耗数据库性能，一般不使用。

Mysql的默认隔离级别就是`Repeatable read`，查看事务隔离级别：`select @@tx_isolation;`或`show variables like '%tx_isolation%';`；，设置事务隔离级别`set global transaction isolation level repeatable read;`。

* 脏读，读取了未提交的事务修改的数据
* 不可重复读，一个事务范围内两个相同的查询却返回了不同数据，一般是另一个事务在进行update操作
* 幻读，一个事务范围内两个相同的查询却返回了不同数据，一般是另一个事务在进行insert操作。假设事务A对某些行的内容作了更改，但是还未提交，此时事务B插入了与事务A更改前的记录相同的记录行，并且在事务A提交之前先提交了，而这时，在事务A中查询，会发现好像刚刚的更改对于某些数据未起作用，但其实是事务B刚插入进来的，让用户感觉很魔幻，感觉出现了幻觉，这就叫幻读。



### MySQL 中是如何实现事务隔离的
首先说读未提交，它是性能最好，也可以说它是最野蛮的方式，因为它压根儿就不加锁，所以根本谈不上什么隔离效果，可以理解为没有隔离。MySQL 事务隔离其实是依靠锁来实现的，加锁自然会带来性能的损失。而读未提交隔离级别是不加锁的，所以它的性能是最好的，没有加锁、解锁带来的性能开销。但有利就有弊，这基本上就相当于裸奔啊，所以它连脏读的问题都没办法解决。


再来说串行化。读的时候加共享锁，也就是其他事务可以并发读，但是不能写。写的时候加排它锁，其他事务不能并发写也不能并发读。

#### 实现可重复读
为了解决不可重复读，或者为了实现可重复读，MySQL 采用了 MVVC (多版本并发控制) 的方式。
我们在数据库表中看到的一行记录可能实际上有多个版本，每个版本的记录除了有数据本身外，还要有一个表示版本的字段，记为 row trx_id，而这个字段就是使其产生的事务的 id，事务 ID 记为 transaction id，它在事务开始的时候向事务系统申请，按时间先后顺序递增。
可重复读是在事务开始的时候生成一个当前事务全局性的快照，而读提交则是每次执行语句的时候都重新生成一次快照。

对于一个快照来说，它能够读到那些版本数据，要遵循以下规则：

* 当前事务内的更新，可以读到；
* 版本未提交，不能读到；
* 版本已提交，但是却在快照创建后提交的，不能读到；
* 版本已提交，且是在快照创建前提交的，可以读到；

利用上面的规则，再返回去套用到读提交和可重复读的那两张图上就很清晰了。还是要强调，两者主要的区别就是在快照的创建上，可重复读仅在事务开始是创建一次，而读提交每次执行语句的时候都要重新创建一次。

并发写问题

存在这的情况，两个事务，对同一条数据做修改。最后结果应该是哪个事务的结果呢，肯定要是时间靠后的那个对不对。并且更新之前要先读数据，这里所说的读和上面说到的读不一样，更新之前的读叫做“当前读”，总是当前版本的数据，也就是多版本中最新一次提交的那版。

#### 解决幻读
前面刚说了并发写问题的解决方式就是行锁，而解决幻读用的也是锁，叫做间隙锁，MySQL 把行锁和间隙锁合并在一起，解决了并发写和幻读的问题，这个锁叫做 Next-Key锁。在数据库中会为索引维护一套B+树，用来快速定位行记录。B+索引树是有序的，所以会把这张表的索引分割成几个区间。





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
MVCC


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
在 MySQL 中，日志可以分为二进制日志、错误日志、通用查询日志和慢查询日志。对于 MySQL 的管理工作而言，这些日志文件是不可缺少的。分析这些日志，可以帮助我们了解 MySQL 数据库的运行情况、日常操作、错误信息和哪些地方需要进行优化。

下面简单介绍 MySQL 中 4 种日志文件的作用。
二进制日志：该日志文件会以二进制的形式记录数据库的各种操作，但不记录查询语句。
错误日志：该日志文件会记录 MySQL 服务器的启动、关闭和运行错误等信息。
通用查询日志：该日志记录 MySQL 服务器的启动和关闭信息、客户端的连接信息、更新、查询数据记录的 SQL 语句等。
慢查询日志：记录执行事件超过指定时间的操作，通过工具分析慢查询日志可以定位 MySQL 服务器性能瓶颈所在。


WAL(Write Ahead Logging)
日志模块
* redo log
* binlog
* undo log

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

锁机制
根据不同机制可以将锁分为共享锁与排他锁
* 共享锁（读锁）：其他事务可以读，但不能写。
* 排他锁（写锁） ：其他事务不能读取，也不能写。

粒度锁
MySQL 不同的存储引擎支持不同的锁机制，所有的存储引擎都以自己的方式显现了锁机制，服务器层完全不了解存储引擎中的锁实现：

* MyISAM 和 MEMORY 存储引擎采用的是表级锁（table-level locking）
* BDB 存储引擎采用的是页面锁（page-level locking），但也支持表级锁
* InnoDB 存储引擎既支持行级锁（row-level locking），也支持表级锁，但默认情况下是采用行级锁。

默认情况下，表锁和行锁都是自动获得的， 不需要额外的命令。
但是在有的情况下， 用户需要明确地进行锁表或者进行事务的控制， 以便确保整个事务的完整性，这样就需要使用事务控制和锁定语句来完成。

不同粒度锁的比较：
* 表级锁：开销小，加锁快；不会出现死锁；锁定粒度大，发生锁冲突的概率最高，并发度最低。 
  - 这些存储引擎通过总是一次性同时获取所有需要的锁以及总是按相同的顺序获取表锁来避免死锁。
  - 表级锁更适合于以查询为主，并发用户少，只有少量按索引条件更新数据的应用，如Web 应用
* 行级锁：开销大，加锁慢；会出现死锁；锁定粒度最小，发生锁冲突的概率最低，并发度也最高。
  - 最大程度的支持并发，同时也带来了最大的锁开销。
  - 在 InnoDB 中，除单个 SQL 组成的事务外，锁是逐步获得的，这就决定了在 InnoDB 中发生死锁是可能的。
  - 行级锁只在存储引擎层实现，而Mysql服务器层没有实现。行级锁更适合于有大量按索引条件并发更新少量不同数据，同时又有并发查询的应用，如一些在线事务处理（OLTP）系统
* 页面锁：开销和加锁时间界于表锁和行锁之间；会出现死锁；锁定粒度界于表锁和行锁之间，并发度一般。


MyISAM 表锁
MyISAM表级锁模式：
* 表共享读锁 （Table Read Lock）：不会阻塞其他用户对同一表的读请求，但会阻塞对同一表的写请求；
* 表独占写锁 （Table Write Lock）：会阻塞其他用户对同一表的读和写操作；

MyISAM 表的读操作与写操作之间，以及写操作之间是串行的。当一个线程获得对一个表的写锁后， 只有持有锁的线程可以对表进行更新操作。 其他线程的读、 写操作都会等待，直到锁被释放为止。

可以设置改变读锁和写锁的优先级：

* 通过指定启动参数low-priority-updates，使MyISAM引擎默认给予读请求以优先的权利。
* 通过执行命令SET LOW_PRIORITY_UPDATES=1，使该连接发出的更新请求优先级降低。
* 通过指定INSERT、UPDATE、DELETE语句的LOW_PRIORITY属性，降低该语句的优先级。
* 给系统参数max_write_lock_count设置一个合适的值，当一个表的读锁达到这个值后，MySQL就暂时将写请求的优先级降低，给读进程一定获得锁的机会。


InnoDB行级锁和表级锁
InnoDB锁模式：
InnoDB 实现了以下两种类型的行锁：

共享锁（S）：允许一个事务去读一行，阻止其他事务获得相同数据集的排他锁。
排他锁（X）：允许获得排他锁的事务更新数据，阻止其他事务取得相同数据集的共享读锁和排他写锁。
为了允许行锁和表锁共存，实现多粒度锁机制，InnoDB 还有两种内部使用的意向锁（Intention Locks），这两种意向锁都是表锁：

意向共享锁（IS）：事务打算给数据行加行共享锁，事务在给一个数据行加共享锁前必须先取得该表的 IS 锁。
意向排他锁（IX）：事务打算给数据行加行排他锁，事务在给一个数据行加排他锁前必须先取得该表的 IX 锁。

InnoDB加锁方法：
意向锁是 InnoDB 自动加的， 不需用户干预。
对于 UPDATE、 DELETE 和 INSERT 语句， InnoDB
会自动给涉及数据集加排他锁（X)；
对于普通 SELECT 语句，InnoDB 不会加任何锁；
事务可以通过以下语句显式给记录集加共享锁或排他锁：
共享锁（S）：SELECT * FROM table_name WHERE ... LOCK IN SHARE MODE。 其他 session 仍然可以查询记录，并也可以对该记录加 share mode 的共享锁。但是如果当前事务需要对该记录进行更新操作，则很有可能造成死锁。
排他锁（X)：SELECT * FROM table_name WHERE ... FOR UPDATE。其他 session 可以查询该记录，但是不能对该记录加共享锁或排他锁，而是等待获得锁


隐式锁定：
InnoDB在事务执行过程中，使用两阶段锁协议：

随时都可以执行锁定，InnoDB会根据隔离级别在需要的时候自动加锁；

锁只有在执行commit或者rollback的时候才会释放，并且所有的锁都是在同一时刻被释放。

显式锁定 ：
```sql
select ... lock in share mode //共享锁 
select ... for update //排他锁 
```
select for update：

在执行这个 select 查询语句的时候，会将对应的索引访问条目进行上排他锁（X 锁），也就是说这个语句对应的锁就相当于update带来的效果。

`select *** for update` 的使用场景：为了让自己查到的数据确保是最新数据，并且查到后的数据只允许自己来修改的时候，需要用到 for update 子句。

select lock in share mode ：in share mode 子句的作用就是将查找到的数据加上一个 share 锁，这个就是表示其他的事务只能对这些数据进行简单的select 操作，并不能够进行 DML 操作。select *** lock in share mode 使用场景：为了确保自己查到的数据没有被其他的事务正在修改，也就是说确保查到的数据是最新的数据，并且不允许其他人来修改数据。但是自己不一定能够修改数据，因为有可能其他的事务也对这些数据 使用了 in share mode 的方式上了 S 锁。

性能影响：
select for update 语句，相当于一个 update 语句。在业务繁忙的情况下，如果事务没有及时的commit或者rollback 可能会造成其他事务长时间的等待，从而影响数据库的并发使用效率。
select lock in share mode 语句是一个给查找的数据上一个共享锁（S 锁）的功能，它允许其他的事务也对该数据上S锁，但是不能够允许对该数据进行修改。如果不及时的commit 或者rollback 也可能会造成大量的事务等待。

for update 和 lock in share mode 的区别：

前一个上的是排他锁（X 锁），一旦一个事务获取了这个锁，其他的事务是没法在这些数据上执行 for update ；后一个是共享锁，多个事务可以同时的对相同数据执行 lock in share mode。

InnoDB 行锁实现方式：
InnoDB 行锁是通过给索引上的索引项加锁来实现的，这一点 MySQL 与 Oracle 不同，后者是通过在数据块中对相应数据行加锁来实现的。InnoDB 这种行锁实现特点意味着：只有通过索引条件检索数据，InnoDB 才使用行级锁，否则，InnoDB 将使用表锁！
不论是使用主键索引、唯一索引或普通索引，InnoDB 都会使用行锁来对数据加锁。
只有执行计划真正使用了索引，才能使用行锁：即便在条件中使用了索引字段，但是否使用索引来检索数据是由 MySQL 通过判断不同执行计划的代价来决定的，如果 MySQL 认为全表扫描效率更高，比如对一些很小的表，它就不会使用索引，这种情况下 InnoDB 将使用表锁，而不是行锁。因此，在分析锁冲突时，
别忘了检查 SQL 的执行计划（可以通过 explain 检查 SQL 的执行计划），以确认是否真正使用了索引。（更多阅读：MySQL索引总结）
由于 MySQL 的行锁是针对索引加的锁，不是针对记录加的锁，所以虽然多个session是访问不同行的记录， 但是如果是使用相同的索引键， 是会出现锁冲突的（后使用这些索引的session需要等待先使用索引的session释放锁后，才能获取锁）。 应用设计的时候要注意这一点。
InnoDB的间隙锁：
当我们用范围条件而不是相等条件检索数据，并请求共享或排他锁时，InnoDB会给符合条件的已有数据记录的索引项加锁；对于键值在条件范围内但并不存在的记录，叫做“间隙（GAP)”，InnoDB也会对这个“间隙”加锁，这种锁机制就是所谓的间隙锁（Next-Key锁）。

很显然，在使用范围条件检索并锁定记录时，InnoDB这种加锁机制会阻塞符合条件范围内键值的并发插入，这往往会造成严重的锁等待。因此，在实际应用开发中，尤其是并发插入比较多的应用，我们要尽量优化业务逻辑，尽量使用相等条件来访问更新数据，避免使用范围条件。

InnoDB使用间隙锁的目的：

防止幻读，以满足相关隔离级别的要求；
满足恢复和复制的需要：
MySQL 通过 BINLOG 录入执行成功的 INSERT、UPDATE、DELETE 等更新数据的 SQL 语句，并由此实现 MySQL 数据库的恢复和主从复制。MySQL 的恢复机制（复制其实就是在 Slave Mysql 不断做基于 BINLOG 的恢复）有以下特点：

一是 MySQL 的恢复是 SQL 语句级的，也就是重新执行 BINLOG 中的 SQL 语句。

二是 MySQL 的 Binlog 是按照事务提交的先后顺序记录的， 恢复也是按这个顺序进行的。

由此可见，MySQL 的恢复机制要求：在一个事务未提交前，其他并发事务不能插入满足其锁定条件的任何记录，也就是不允许出现幻读。

InnoDB 在不同隔离级别下的一致性读及锁的差异：
锁和多版本数据（MVCC）是 InnoDB 实现一致性读和 ISO/ANSI SQL92 隔离级别的手段。

因此，在不同的隔离级别下，InnoDB 处理 SQL 时采用的一致性读策略和需要的锁是不同的：


对于许多 SQL，隔离级别越高，InnoDB 给记录集加的锁就越严格（尤其是使用范围条件的时候），产生锁冲突的可能性也就越高，从而对并发性事务处理性能的 影响也就越大。

因此， 我们在应用中， 应该尽量使用较低的隔离级别， 以减少锁争用的机率。实际上，通过优化事务逻辑，大部分应用使用 Read Commited 隔离级别就足够了。对于一些确实需要更高隔离级别的事务， 可以通过在程序中执行 SET SESSION TRANSACTION ISOLATION

LEVEL REPEATABLE READ 或 SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE 动态改变隔离级别的方式满足需求。

获取 InnoDB 行锁争用情况：
可以通过检查 InnoDB_row_lock 状态变量来分析系统上的行锁的争夺情况：

```sql
mysql> show status like 'innodb_row_lock%';
+-------------------------------+-------+
| Variable_name                 | Value |
+-------------------------------+-------+
| Innodb_row_lock_current_waits | 0     |
| Innodb_row_lock_time          | 0     |
| Innodb_row_lock_time_avg      | 0     |
| Innodb_row_lock_time_max      | 0     |
| Innodb_row_lock_waits         | 0     |
+-------------------------------+-------+
```

LOCK TABLES 和 UNLOCK TABLES
Mysql也支持lock tables和unlock tables，这都是在服务器层（MySQL Server层）实现的，和存储引擎无关，它们有自己的用途，并不能替代事务处理。 （除了禁用了autocommint后可以使用，其他情况不建议使用）：

LOCK TABLES 可以锁定用于当前线程的表。如果表被其他线程锁定，则当前线程会等待，直到可以获取所有锁定为止。
UNLOCK TABLES 可以释放当前线程获得的任何锁定。当前线程执行另一个 LOCK TABLES 时，
或当与服务器的连接被关闭时，所有由当前线程锁定的表被隐含地解锁
LOCK TABLES语法：
在用 LOCK TABLES 对 InnoDB 表加锁时要注意，要将 AUTOCOMMIT 设为 0，否则MySQL 不会给表加锁；
事务结束前，不要用 UNLOCK TABLES 释放表锁，因为 UNLOCK TABLES会隐含地提交事务；
COMMIT 或 ROLLBACK 并不能释放用 LOCK TABLES 加的表级锁，必须用UNLOCK TABLES 释放表锁。
正确的方式见如下语句：
例如，如果需要写表 t1 并从表 t 读，可以按如下做：
```sql
SET AUTOCOMMIT=0; 
LOCK TABLES t1 WRITE, t2 READ, ...; 
[do something with tables t1 and t2 here]; 
COMMIT; 
UNLOCK TABLES;
```

使用LOCK TABLES的场景：
给表显示加表级锁（InnoDB表和MyISAM都可以），一般是为了在一定程度模拟事务操作，实现对某一时间点多个表的一致性读取。（与MyISAM默认的表锁行为类似）

在用 LOCK TABLES 给表显式加表锁时，必须同时取得所有涉及到表的锁，并且 MySQL 不支持锁升级。也就是说，在执行 LOCK TABLES 后，只能访问显式加锁的这些表，不能访问未加锁的表；同时，如果加的是读锁，那么只能执行查询操作，而不能执行更新操作。

其实，在MyISAM自动加锁（表锁）的情况下也大致如此，MyISAM 总是一次获得 SQL 语句所需要的全部锁，这也正是 MyISAM 表不会出现死锁（Deadlock Free）的原因。

例如，有一个订单表 orders，其中记录有各订单的总金额 total，同时还有一个 订单明细表 order_detail，其中记录有各订单每一产品的金额小计 subtotal，假设我们需要检 查这两个表的金额合计是否相符，可能就需要执行如下两条 SQL：

Select sum(total) from orders; 
Select sum(subtotal) from order_detail; 
这时，如果不先给两个表加锁，就可能产生错误的结果，因为第一条语句执行过程中，
order_detail 表可能已经发生了改变。因此，正确的方法应该是：

Lock tables orders read local, order_detail read local; 
Select sum(total) from orders; 
Select sum(subtotal) from order_detail; 
Unlock tables;
（在 LOCK TABLES 时加了“local”选项，其作用就是允许当你持有表的读锁时，其他用户可以在满足 MyISAM 表并发插入条件的情况下，在表尾并发插入记录（MyISAM 存储引擎支持“并发插入”））

死锁（Deadlock Free）
死锁产生：
死锁是指两个或多个事务在同一资源上相互占用，并请求锁定对方占用的资源，从而导致恶性循环。
当事务试图以不同的顺序锁定资源时，就可能产生死锁。多个事务同时锁定同一个资源时也可能会产生死锁。
锁的行为和顺序和存储引擎相关。以同样的顺序执行语句，有些存储引擎会产生死锁有些不会——死锁有双重原因：真正的数据冲突；存储引擎的实现方式。
检测死锁：数据库系统实现了各种死锁检测和死锁超时的机制。InnoDB存储引擎能检测到死锁的循环依赖并立即返回一个错误。
死锁恢复：死锁发生以后，只有部分或完全回滚其中一个事务，才能打破死锁，InnoDB目前处理死锁的方法是，将持有最少行级排他锁的事务进行回滚。所以事务型应用程序在设计时必须考虑如何处理死锁，多数情况下只需要重新执行因死锁回滚的事务即可。
外部锁的死锁检测：发生死锁后，InnoDB 一般都能自动检测到，并使一个事务释放锁并回退，另一个事务获得锁，继续完成事务。但在涉及外部锁，或涉及表锁的情况下，InnoDB 并不能完全自动检测到死锁， 这需要通过设置锁等待超时参数 innodb_lock_wait_timeout 来解决
死锁影响性能：死锁会影响性能而不是会产生严重错误，因为InnoDB会自动检测死锁状况并回滚其中一个受影响的事务。在高并发系统上，当许多线程等待同一个锁时，死锁检测可能导致速度变慢。 有时当发生死锁时，禁用死锁检测（使用innodb_deadlock_detect配置选项）可能会更有效，这时可以依赖innodb_lock_wait_timeout设置进行事务回滚。
MyISAM避免死锁：
在自动加锁的情况下，MyISAM 总是一次获得 SQL 语句所需要的全部锁，所以 MyISAM 表不会出现死锁。
InnoDB避免死锁：
为了在单个InnoDB表上执行多个并发写入操作时避免死锁，可以在事务开始时通过为预期要修改的每个元祖（行）使用SELECT ... FOR UPDATE语句来获取必要的锁，即使这些行的更改语句是在之后才执行的。
在事务中，如果要更新记录，应该直接申请足够级别的锁，即排他锁，而不应先申请共享锁、更新时再申请排他锁，因为这时候当用户再申请排他锁时，其他事务可能又已经获得了相同记录的共享锁，从而造成锁冲突，甚至死锁
如果事务需要修改或锁定多个表，则应在每个事务中以相同的顺序使用加锁语句。 在应用中，如果不同的程序会并发存取多个表，应尽量约定以相同的顺序来访问表，这样可以大大降低产生死锁的机会
通过SELECT ... LOCK IN SHARE MODE获取行的读锁后，如果当前事务再需要对该记录进行更新操作，则很有可能造成死锁。
改变事务隔离级别
如果出现死锁，可以用 SHOW INNODB STATUS 命令来确定最后一个死锁产生的原因。返回结果中包括死锁相关事务的详细信息，如引发死锁的 SQL 语句，事务已经获得的锁，正在等待什么锁，以及被回滚的事务等。据此可以分析死锁产生的原因和改进措施。

一些优化锁性能的建议
尽量使用较低的隔离级别；
精心设计索引， 并尽量使用索引访问数据， 使加锁更精确， 从而减少锁冲突的机会
选择合理的事务大小，小事务发生锁冲突的几率也更小
给记录集显示加锁时，最好一次性请求足够级别的锁。比如要修改数据的话，最好直接申请排他锁，而不是先申请共享锁，修改时再请求排他锁，这样容易产生死锁
不同的程序访问一组表时，应尽量约定以相同的顺序访问各表，对一个表而言，尽可能以固定的顺序存取表中的行。这样可以大大减少死锁的机会
尽量用相等条件访问数据，这样可以避免间隙锁对并发插入的影响
不要申请超过实际需要的锁级别
除非必须，查询时不要显示加锁。 MySQL的MVCC可以实现事务中的查询不用加锁，优化事务性能；MVCC只在COMMITTED READ（读提交）和REPEATABLE READ（可重复读）两种隔离级别下工作
对于一些特定的事务，可以使用表锁来提高处理速度或减少死锁的可能
乐观锁、悲观锁
乐观锁(Optimistic Lock)：假设不会发生并发冲突，只在提交操作时检查是否违反数据完整性。 乐观锁不能解决脏读的问题。
乐观锁, 顾名思义，就是很乐观，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号等机制。乐观锁适用于多读的应用类型，这样可以提高吞吐量，像数据库如果提供类似于write_condition机制的其实都是提供的乐观锁。

悲观锁(Pessimistic Lock)：假定会发生并发冲突，屏蔽一切可能违反数据完整性的操作。
悲观锁，顾名思义，就是很悲观，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会block直到它拿到锁。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。




全局锁
表级锁
表级锁的优点：
* 所需内存相对较少（行锁定需要每行或每组行锁定的内存）
* 在表的大部分上使用时速度很快，因为只涉及一个锁。
* 如果您经常对大部分数据进行 GROUP BY 操作或者必须经常扫描整个表，则速度很快。

行锁
行级锁的优点：
* 当不同的会话访问不同的行时，锁冲突更少。
* 回滚的更改更少。
* 可能长时间锁定单行。

MySQL 授予表写锁如下：
如果表上没有锁，则在其上放置一个写锁。
否则，将锁请求放入写锁队列。
MySQL 授予表读锁如下：
如果表上没有写锁，则在其上放置读锁。
否则，将锁请求放入读锁队列。

表更新的优先级高于表检索。因此，当锁被释放时，该锁可用于写锁队列中的请求，然后可用于读锁队列中的请求。这确保即使表有大量 SELECT 活动，表的更新也不会“匮乏”。但是，如果表有很多更新，SELECT 语句会等到没有更多更新为止。

如果您使用 LOCK TABLES 显式获取表锁，则可以请求 READ LOCAL 锁而不是 READ 锁，以允许其他会话在您锁定表时执行并发插入。

通常，表锁在以下情况下优于行级锁：
* 该表的大多数语句都是读取的。
* 该表的语句是读取和写入的混合，其中写入是对单个行的更新或删除，可以通过读取一个键来获取：
```sql
UPDATE tbl_name SET column=value WHERE unique_key_col=key_value;
DELETE FROM tbl_name WHERE unique_key_col=key_value;
```
* SELECT 结合了并发的 INSERT 语句，以及很少的 UPDATE 或 DELETE 语句。
* 在没有任何编写器的情况下对整个表进行多次扫描或 GROUP BY 操作。

使用更高级别的锁，您可以通过支持不同类型的锁来更轻松地调整应用程序，因为锁开销小于行级锁。

行级锁定以外的选项：
版本控制（例如 MySQL 中用于并发插入的版本控制），其中可以同时拥有一个写入器和多个读取器。这意味着数据库或表根据访问开始的时间支持不同的数据视图。其他常用术语是“时间旅行”、“写时复制”或“按需复制”。
在许多情况下，按需复制优于行级锁定。然而，在最坏的情况下，它可以使用比使用普通锁更多的内存。
您可以使用应用程序级锁来代替行级锁，例如 MySQL 中由 GET_LOCK() 和 RELEASE_LOCK() 提供的锁。这些是咨询锁，因此它们仅适用于相互协作的应用程序。


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
MySQL中的两种临时表
外部临时表
通过CREATE TEMPORARY TABLE 创建的临时表，这种临时表称为外部临时表。这种临时表只对当前用户可见，当前会话结束的时候，该临时表会自动关闭。这种临时表的命名与非临时表可以同名（同名后非临时表将对当前会话不可见，直到临时表被删除）。

内部临时表
　　　　内部临时表是一种特殊轻量级的临时表，用来进行性能优化。这种临时表会被MySQL自动创建并用来存储某些操作的中间结果。这些操作可能包括在优化阶段或者执行阶段。这种内部表对用户来说是不可见的，但是通过EXPLAIN或者SHOW 　　STATUS可以查看MYSQL是否使用了内部临时表用来帮助完成某个操作。内部临时表在SQL语句的优化过程中扮演着非常重要的角色， MySQL中的很多操作都要依赖于内部临时表来进行优化。但是使用内部临时表需要创建表以及中间数据的存取代价，所以用户在写SQL语句的时候应该尽量的去避免使用临时表。

　　内部临时表有两种类型：一种是HEAP临时表，这种临时表的所有数据都会存在内存中，对于这种表的操作不需要IO操作。另一种是OnDisk临时表，顾名思义，这种临时表会将数据存储在磁盘上。OnDisk临时表用来处理中间结果比较大的操作。如果HEAP临时表存储的数据大于MAX_HEAP_TABLE_SIZE（详情请参考MySQL手册中系统变量部分），HEAP临时表将会被自动转换成OnDisk临时表。OnDisk临时表在5.7中可以通过INTERNAL_TMP_DISK_STORAGE_ENGINE系统变量选择使用MyISAM引擎或者InnoDB引擎。


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


## 预读
InnoDB在I/O的优化上有个比较重要的特性为预读，预读请求是一个i/o请求，它会异步地在缓冲池中预先回迁多个页面，预计很快就会需要这些页面，这些请求在一个范围内引入所有页面。InnoDB以64个page为一个extent，那么InnoDB的预读是以page为单位还是以extent？
数据库请求数据的时候，会将读请求交给文件系统，放入请求队列中；相关进程从请求队列中将读请求取出，根据需求到相关数据区(内存、磁盘)读取数据；取出的数据，放入响应队列中，最后数据库就会从响应队列中将数据取走，完成一次数据读操作过程。
接着进程继续处理请求队列，(如果数据库是全表扫描的话，数据读请求将会占满请求队列)，判断后面几个数据读请求的数据是否相邻，再根据自身系统IO带宽处理量，进行预读，进行读请求的合并处理，一次性读取多块数据放入响应队列中，再被数据库取走。(如此，一次物理读操作，实现多页数据读取，rrqm>0（# iostat -x），假设是4个读请求合并，则rrqm参数显示的就是4)

InnoDB使用两种预读算法来提高I/O性能：线性预读（`linear read-ahead`）和随机预读（`randomread-ahead`）
为了区分这两种预读的方式，我们可以把线性预读放到以extent为单位，而随机预读放到以extent中的page为单位。线性预读着眼于将下一个extent提前读取到buffer pool中，而随机预读着眼于将当前extent中的剩余的page提前读取到buffer pool中。

### 线性预读（linear read-ahead）
线性预读方式有一个很重要的变量控制是否将下一个extent预读到buffer pool中，通过使用配置参数`innodb_read_ahead_threshold`，控制触发innodb执行预读操作的时间。

如果一个extent中的被顺序读取的page超过或者等于该参数变量时，Innodb将会异步的将下一个extent读取到buffer pool中，`innodb_read_ahead_threshold`可以设置为0-64的任何值(因为一个extent中也就只有64页)，默认值为56，值越高，访问模式检查越严格。

```sql
mysql> show variables like 'innodb_read_ahead_threshold';
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| innodb_read_ahead_threshold | 56    |
+-----------------------------+-------+
```

例如，如果将值设置为48，则InnoDB只有在顺序访问当前extent中的48个pages时才触发线性预读请求，将下一个extent读到内存中。如果值为8，InnoDB触发异步预读，即使程序段中只有8页被顺序访问。
可以在MySQL配置文件中设置此参数的值，或者使用SET GLOBAL需要该SUPER权限的命令动态更改该参数。
在没有该变量之前，当访问到extent的最后一个page的时候，innodb会决定是否将下一个extent放入到buffer pool中。

### 随机预读（randomread-ahead）
随机预读方式则是表示当同一个extent中的一些page在buffer pool中发现时，Innodb会将该extent中的剩余page一并读到buffer pool中。
```sql
mysql> show variables like 'innodb_random_read_ahead';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_random_read_ahead | OFF   |
+--------------------------+-------+
```

由于随机预读方式给`innodb code`带来了一些不必要的复杂性，同时在性能也存在不稳定性，在5.5中已经将这种预读方式废弃，默认是OFF。若要启用此功能，即将配置变量设置`innodb_random_read_ahead`为ON。

### 查看预读信息
可以通过`show engine innodb status\G`显示统计信息
```sql
mysql> show engine innodb status\G
----------------------
BUFFER POOL AND MEMORY
----------------------
……
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
……
```

* Pages read ahead：表示每秒读入的pages；
* evicted without access：表示每秒读出的pages；
* 一般随机预读都是关闭的，也就是0。

通过两个状态值，评估预读算法的有效性
```sql
mysql> show global status like '%read_ahead%';
+---------------------------------------+-------+
| Variable_name                         | Value |
+---------------------------------------+-------+
| Innodb_buffer_pool_read_ahead_rnd     | 0     |
| Innodb_buffer_pool_read_ahead         | 2303  |
| Innodb_buffer_pool_read_ahead_evicted | 0     |
+---------------------------------------+-------+
3 rows in set (0.01 sec)
```

* Innodb_buffer_pool_read_ahead：通过预读(后台线程)读入innodb buffer pool中数据页数
* Innodb_buffer_pool_read_ahead_evicted：通过预读来的数据页没有被查询访问就被清理的pages，无效预读页数

## 内存引擎
使用memory引擎
内存表数据组织结构
hash索引和B-Tree索引
内存表的锁
数据持久性问题


## 主从架构

搭建主从服务
建立主从专用用户
开启binlog日志

启动主从节点

主节点配置从节点信息

获取当前master节点状态
```sql
show master status \G;
```

从节点注册
```sql
change master to master_user='root', master_password='123456', master_host='172.17.0.2', master_log_file='mysql-bin.000003', master_log_pos=2067;
```

向主节点注册后使用`start slave`和`stop slave`进行开关副本的拷贝

一旦执行binlog某一条语句出错则后面的语句则从库会卡在出错的binlog位置，一般由主库压力大、有无数据库、用户权限、MySQL版本不同等因素导致，具体原因可以通过`show slave status;`获取。
一般通用解决方案，关闭主从同步，跳过当前出错的语句，再开启主从同步：
```sql
mysql> stop slave;
mysql> set sql_slave_skip_counter=1;
mysql> start slave;
```


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


qps突增

### 优化数据库服务器
升级硬件配置
通过不同策略使用不同配置的数据库，合理使用低性能库

修改服务器配置


## 慢查询
慢查询性能
查看慢日志
log_output 参数是指定日志的存储方式。log_output='FILE'表示将日志存入文件，默认值是'FILE'。
log_output='TABLE'表示将日志存入数据库，这样日志信息就会被写入到mysql.slow_log表中。
MySQL数据库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如：log_output='FILE,TABLE'。
日志记录到系统的专用日志表中，要比记录到文件耗费更多的系统资源，因此对于需要启用慢查询日志，又需要能够获得更高的系统性能，那么建议优先记录到文件。


分析语句
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

DESCRIBE 和 EXPLAIN 语句是同义词。
在实践中，DESCRIBE 关键字更多地用于获取表结构信息，而 EXPLAIN 用于获取查询执行计划（即 MySQL 将如何执行查询的解释）。DESCRIBE 是 SHOW COLUMNS 的快捷方式，所以支持显示表中的单列数据.

* EXPLAIN 适用于 SELECT、DELETE、INSERT、REPLACE 和 UPDATE 语句。
* 当 EXPLAIN 与可解释的语句一起使用时，MySQL 会显示来自优化器的有关语句执行计划的信息。也就是说，MySQL 解释了它将如何处理该语句，包括有关表如何连接以及连接顺序的信息。
* EXPLAIN 对于检查涉及分区表的查询很有用。
* FORMAT 选项可用于选择输出格式。 TRADITIONAL 以表格格式显示输出。如果没有 FORMAT 选项，这是默认值。 JSON 格式以 JSON 格式显示信息。
* EXPLAIN 需要执行解释语句所需的相同特权。此外，EXPLAIN 还需要所有需要 EXPLAIN 视图的 SHOW VIEW 权限。

在 EXPLAIN 的帮助下，您可以看到应该在表的何处添加索引，以便通过使用索引查找行来更快地执行语句。您还可以使用 EXPLAIN 检查优化器是否以最佳顺序连接表。要提示优化器使用与表在 SELECT 语句中的命名顺序相对应的连接顺序，请以 SELECT STRAIGHT_JOIN 而不是只是 SELECT 开始该语句。


EXPLAIN 为 SELECT 语句中使用的每个表返回一行信息。它按照 MySQL 在处理语句时读取它们的顺序列出输出中的表。 MySQL 使用嵌套循环连接方法解析所有连接。这意味着 MySQL 从第一个表中读取一行，然后在第二个表、第三个表等中找到匹配的行。当所有的表都被处理完后，MySQL 将选择的列输出，并在表列表中回溯，直到找到一个有更多匹配行的表。从此表中读取下一行，然后继续处理下一个表。

EXPLAIN 输出列

| Column | JSON Name | Meaning |
| --- | --- | --- |
| [`id`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_id) | `select_id` | The `SELECT` identifier |
| [`select_type`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_select_type) | None | The `SELECT` type |
| [`table`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_table) | `table_name` | The table for the output row |
| [`partitions`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_partitions) | `partitions` | The matching partitions |
| [`type`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_type) | `access_type` | The join type |
| [`possible_keys`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_possible_keys) | `possible_keys` | The possible indexes to choose |
| [`key`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_key) | `key` | The index actually chosen |
| [`key_len`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_key_len) | `key_length` | The length of the chosen key |
| [`ref`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_ref) | `ref` | The columns compared to the index |
| [`rows`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_rows) | `rows` | Estimate of rows to be examined |
| [`filtered`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_filtered) | `filtered` | Percentage of rows filtered by table condition |
| [`Extra`](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html#explain_extra) | None | Additional information |

* id 选择标识符。这是查询中 SELECT 的序号。如果该行引用其他行的联合结果，则该值可以为 NULL。在这种情况下，表列显示一个类似 `<unionM,N>` 的值，表示该行引用 id 值为 M 和 N 的行的并集。
* select_type SELECT 的类型，可以是下表中显示的任何一种。 JSON 格式的 EXPLAIN 将 SELECT 类型公开为 query_block 的属性，除非它是 SIMPLE 或 PRIMARY。 JSON 名称（如果适用）也显示在表中。
| `select_type` Value | JSON Name | Meaning |
| --- | --- | --- |
| `SIMPLE` | None | Simple [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") (not using [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause") or subqueries) |
| `PRIMARY` | None | Outermost [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") |
| [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause") | None | Second or later [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") statement in a [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause") |
| `DEPENDENT UNION` | `dependent` (`true`) | Second or later [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") statement in a [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause"), dependent on outer query |
| `UNION RESULT` | `union_result` | Result of a [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause"). |
| [`SUBQUERY`](https://dev.mysql.com/doc/refman/5.7/en/optimizer-hints.html#optimizer-hints-subquery "Subquery Optimizer Hints") | None | First [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") in subquery |
| `DEPENDENT SUBQUERY` | `dependent` (`true`) | First [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") in subquery, dependent on outer query |
| `DERIVED` | None | Derived table |
| `MATERIALIZED` | `materialized_from_subquery` | Materialized subquery |
| `UNCACHEABLE SUBQUERY` | `cacheable` (`false`) | A subquery for which the result cannot be cached and must be re-evaluated for each row of the outer query |
| `UNCACHEABLE UNION` | `cacheable` (`false`) | The second or later select in a [`UNION`](https://dev.mysql.com/doc/refman/5.7/en/union.html "13.2.9.3 UNION Clause") that belongs to an uncacheable subquery (see `UNCACHEABLE SUBQUERY`) |

* `table` 输出行所引用的表的名称。这也可以是以下值之一：
  - `<unionM,N>`：该行是指id值为M和N的行的并集。
  - `<derivedN>`：该行引用 id 值为 N 的行的派生表结果。例如，派生表可能来自 FROM 子句中的子查询。
  - `<subqueryN>`：该行引用 id 值为 N 的行的具体化子查询的结果。
* `partitions` 查询将匹配记录的分区。对于非分区表，该值为 NULL。
* `type` join的类型。在 JSON 格式的输出中，这些作为 access_type 属性的值被发现。下面的列表描述了连接类型，从最好的类型到最差的排序：
  - `system` 该表只有一行（=系统表）。这是 const 连接类型的特例。
  - `const` 该表最多有一个匹配行，在查询开始时读取。因为只有一行，所以优化器的其余部分可以将这一行中列的值视为常量。 const 表非常快，因为它们只读一次。
  - `eq_ref` 对于先前表中行的每个组合，从该表中读取一行。除了 system 和 const 类型，这是最好的连接类型。当连接使用索引的所有部分并且索引是 PRIMARY KEY 或 UNIQUE NOT NULL 索引时使用它。eq_ref 可用于使用 = 运算符进行比较的索引列。比较值可以是常量或表达式，它使用在此表之前读取的表中的列。
  - `ref` 对于先前表中行的每个组合，从该表中读取具有匹配索引值的所有行。如果连接仅使用键的最左边前缀，或者如果键不是 PRIMARY KEY 或 UNIQUE 索引（换句话说，如果连接不能根据键值选择单个行），则使用 ref。如果使用的键只匹配几行，这是一个很好的连接类型。ref 可用于使用 = 或 <=> 运算符进行比较的索引列。
  - `fulltext` 使用 FULLTEXT 索引执行的。
  - `ref_or_null` 这种连接类型类似于 ref，但 MySQL 会额外搜索包含 NULL 值的行。这种连接类型优化最常用于解析子查询。
  - `index_merge` 此连接类型表示使用索引合并优化。在这种情况下，输出行中的键列包含使用的索引列表，key_len 包含使用的索引的最长键部分列表。
  - `unique_subquery` 只是一个索引查找函数，它完全取代了子查询以提高效率。
  - `index_subquery` 这种连接类型类似于 unique_subquery。它取代了 IN 子查询，但它适用于以下形式的子查询中的非唯一索引。
  - `range` 仅检索给定范围内的行，使用索引来选择行。输出行中的键列指示使用了哪个索引。 key_len 包含使用过的最长密钥部分。此类型的 ref 列为 NULL。range 被用于 =、<>、>、>=、<、<=、IS NULL、<=>、BETWEEN、LIKE 或 IN() 运算符将键列与常量进行比较时。
  - `index` 索引连接类型与ALL相同，只是扫描索引树。当查询仅使用属于单个索引的列时，MySQL 可以使用此连接类型。这有两种情况：
    + 如果索引是查询的覆盖索引，可以用来满足表中所有需要的数据，则只扫描索引树。在这种情况下，额外列显示使用索引。仅索引扫描通常比 ALL 更快，因为索引的大小通常小于表数据。
    + 使用从索引读取以按索引顺序查找数据行来执行全表扫描。使用索引不会出现在 Extra 列中。
  - `ALL` 对先前表中的每个行组合进行全表扫描。如果表是第一个未标记为 const 的表，这通常是不好的，并且在所有其他情况下通常非常糟糕。通常，您可以通过添加索引来避免 ALL，这些索引允许根据先前表中的常量值或列值从表中检索行。
* `possible_keys` 列指示 MySQL 可以从中选择的索引来查找该表中的行。请注意，此列完全独立于 EXPLAIN 输出中显示的表的顺序。这意味着 possible_keys 中的某些键在实践中可能无法用于生成的表顺序。如果此列为 NULL（或在 JSON 格式的输出中未定义），则没有相关索引。在这种情况下，您可以通过检查 WHERE 子句来检查它是否引用适合索引的某个或多个列来提高查询的性能。如果是这样，请创建一个适当的索引并再次使用 EXPLAIN 检查查询。
* `key` 列表示 MySQL 实际决定使用的键（索引）。如果 MySQL 决定使用 possible_keys 索引之一来查找行，则该索引被列为键值。key 可以命名一个在 possible_keys 值中不存在的索引。如果 possible_keys 索引都不适合查找行，但查询选择的所有列都是某个其他索引的列，则可能会发生这种情况。也就是说，命名索引覆盖了选定的列，因此虽然它不用于确定检索哪些行，但索引扫描比数据行扫描更有效。对于 InnoDB，即使查询还选择了主键，二级索引也可能覆盖选定的列，因为 InnoDB 将主键值与每个二级索引一起存储。如果 key 为 NULL，则 MySQL 找不到可用于更有效地执行查询的索引。要强制 MySQL 使用或忽略 possible_keys 列中列出的索引，请在查询中使用 FORCE INDEX、USE INDEX 或 IGNORE INDEX。
* `key_len` key_len 列指示 MySQL 决定使用的 key 的长度。 key_len 的值使您能够确定 MySQL 实际使用多部分键的多少部分。如果 key 列为 NULL，则 key_len 列也为 NULL。由于 key 存储格式的原因，可以为 NULL 的列的密钥长度比 NOT NULL 列的密钥长度长一倍。
* `ref` 显示将哪些列或常量与键列中指定的索引进行比较以从表中选择行。如果值为 func，则使用的值是某个函数的结果。要查看哪个函数，请在 EXPLAIN 之后使用 SHOW WARNINGS 来查看扩展的 EXPLAIN 输出。该函数实际上可能是一个运算符，例如算术运算符。
* `rows` 表示 MySQL 认为它必须检查以执行查询的行数。对于 InnoDB 表，这个数字是一个估计值，可能并不总是准确的。
* `filtered` 过滤列表示按表条件过滤的表行的估计百分比。最大值为 100，这意味着没有发生行过滤。值从 100 开始减少表示过滤量增加。 rows 显示检查的估计行数，rows × filtered 显示与下表连接的行数。例如rows为1000，filtered为50.00（50%），则下表join的行数为1000×50%=500。
* `Extra` 此列包含有关 MySQL 如何解析查询的附加信息。以下列表解释了可以出现在该列中的值。每个项目还为 JSON 格式的输出指示哪个属性显示 Extra 值。对于其中一些，有一个特定的属性。其他显示为消息属性的文本。
  - `Child of 'table' pushed join@1 (JSON: message text)`，该表被引用为连接中表的子表，可以向下推送到 NDB 内核。仅在启用下推连接时适用于 NDB Cluster。
  - `const row not found (JSON property: const_row_not_found)`，对于诸如 SELECT ... FROM tbl_name 之类的查询，表是空的。
  - `Deleting all rows (JSON property: message)`，对于 DELETE，某些存储引擎（如 MyISAM）支持一种处理程序方法，该方法可以简单快速地删除所有表行。如果引擎使用此优化，则会显示此额外值。
  - `Distinct (JSON property: distinct)`，MySQL 正在寻找不同的值，因此它在找到第一个匹配行后停止为当前行组合搜索更多行。
  - `FirstMatch(tbl_name) (JSON property: first_match)`，semijoin FirstMatch 连接快捷策略用于 tbl_name。
  - `Full scan on NULL key (JSON property: message)`，当优化器不能使用索引查找访问方法时，子查询优化会作为后备策略发生这种情况。
  - `Impossible HAVING (JSON property: message)`，HAVING 子句始终为 false，并且不能选择任何行。
  - `Impossible WHERE (JSON property: message)`，WHERE 子句始终为 false，并且不能选择任何行。
  - `Impossible WHERE noticed after reading const tables (JSON property: message)`，MySQL 已读取所有常量（和系统）表并注意到 WHERE 子句始终为假。
  - `LooseScan(m..n) (JSON property: message)`，使用半连接 LooseScan 策略。 m 和 n 是关键部件号。
  - `No matching min/max row (JSON property: message)`，没有行满足查询条件，例如 SELECT MIN(...) FROM ... WHERE 条件。
  - `no matching row in const table (JSON property: message)`，对于带有连接的查询，有一个空表或没有满足唯一索引条件的行的表。
  - `No matching rows after partition pruning (JSON property: message)`，对于 DELETE 或 UPDATE，优化器在分区修剪后没有发现要删除或更新的内容。它的含义类似于 SELECT 语句的 Impossible WHERE。
  - `No tables used (JSON property: message)`，查询没有 FROM 子句，或者有 FROM DUAL 子句。对于 INSERT 或 REPLACE 语句，EXPLAIN 在没有 SELECT 部分时显示此值。例如，它出现在 EXPLAIN INSERT INTO t VALUES(10) 中，因为它等同于 EXPLAIN INSERT INTO t SELECT 10 FROM DUAL。
  - `Not exists (JSON property: message)`，MySQL 能够对查询执行 LEFT JOIN 优化，并且在找到与 LEFT JOIN 条件匹配的行后，不会检查此表中的更多行以查找前一个行组合。以下是可以通过这种方式优化的查询类型的示例：假设 t2.id 被定义为 NOT NULL。在这种情况下，MySQL 扫描 t1 并使用 t1.id 的值查找 t2 中的行。如果 MySQL 在 t2 中找到匹配的行，它知道 t2.id 永远不能为 NULL，并且不会扫描 t2 中具有相同 id 值的其余行。换句话说，对于 t1 中的每一行，MySQL 只需要在 t2 中执行一次查找，而不管在 t2 中实际匹配了多少行。
  - `Plan isn't ready yet (JSON property: none)`，当优化器尚未完成为在命名连接中执行的语句创建执行计划时，此值与 EXPLAIN FOR CONNECTION 一起出现。如果执行计划输出包含多行，则其中任何一行或所有行都可能具有此 Extra 值，具体取决于优化程序确定完整执行计划的进度。
  - `Range checked for each record (index map: N) (JSON property: message)`，MySQL 没有找到好的索引可以使用，但发现在知道前面表的列值后，可能会使用某些索引。对于前面表中的每个行组合，MySQL 检查是否可以使用范围或索引合并访问方法来检索行。这不是很快，但比执行完全没有索引的连接要快。适用性标准如第 8.2.1.2 节“范围优化”和第 8.2.1.3 节“索引合并优化”中所述，除了上表的所有列值都是已知的并被视为常量。索引从 1 开始编号，顺序与表的 SHOW INDEX 所示顺序相同。索引映射值 N 是一个位掩码值，指示哪些索引是候选索引。例如，值 0x19（二进制 11001）表示考虑索引 1、4 和 5。
  - `Scanned N databases (JSON property: message)`，这表示服务器在处理 INFORMATION_SCHEMA 表查询时执行的目录扫描次数，如第 8.2.3 节“优化 INFORMATION_SCHEMA 查询”中所述。 N 的值可以是 0、1 或全部。
  - `Select tables optimized away (JSON property: message)`，优化器确定 1) 最多应返回一行，以及 2) 要生成该行，必须读取一组确定的行。当要读取的行可以在优化阶段读取时（例如，通过读取索引行），在查询执行期间不需要读取任何表。当查询被隐式分组（包含聚合函数但没有 GROUP BY 子句）时，第一个条件得到满足。当对每个使用的索引执行一行查找时，第二个条件就满足了。读取的索引数决定了要读取的行数。对于每个表维护精确行数的存储引擎（例如 MyISAM，但不是 InnoDB），对于缺少 WHERE 子句或始终为真且没有 GROUP BY 子句的 `COUNT(*) `查询，可能会出现此额外值。 （这是一个隐式分组查询的实例，其中存储引擎会影响是否可以读取确定数量的行。）
  - `Skip_open_table, Open_frm_only, Open_full_table (JSON property: message)`，这些值表示适用于 INFORMATION_SCHEMA 表查询的文件打开优化：
    + `skip_open_table`：表文件不需要打开。通过扫描数据库目录，该信息已在查询中变得可用。
    + `Open_frm_only`：只需要打开表的.frm 文件。
    + `open_full_table`：未优化的信息查找。必须打开 .frm、.MYD 和 .MYI 文件。
  - `Start temporary, End temporary (JSON property: message)`，这表明临时表用于 semijoin Duplicate Weedout 策略。
  - `unique row not found (JSON property: message)`，对于诸如 SELECT ... FROM tbl_name 之类的查询，没有行满足表上 UNIQUE 索引或 PRIMARY KEY 的条件。
  - `Using filesort (JSON property: using_filesort)`，MySQL 必须执行额外的传递以找出如何按排序顺序检索行。排序是通过根据连接类型遍历所有行并存储排序键和指向与 WHERE 子句匹配的所有行的行的指针来完成的。然后对键进行排序，并按排序顺序检索行。
  - `Using index (JSON property: using_index)`，仅使用索引树中的信息从表中检索列信息，而无需执行额外的查找操作来读取实际行。当查询仅使用属于单个索引的列时，可以使用此策略。对于具有用户定义聚集索引的 InnoDB 表，即使在 Extra 列中没有使用索引时也可以使用该索引。如果 type 是 index 并且 key 是 PRIMARY，就会出现这种情况。
  - `Using index condition (JSON property: using_index_condition)`，通过访问索引元组并首先测试它们以确定是否读取完整的表行来读取表。以这种方式，索引信息用于延迟（“下推”）读取全表行，除非有必要。
  - `Using index for group-by (JSON property: using_index_for_group_by)`，与 Using index table access 方法类似，Using index for group-by 表示 MySQL 找到了一个索引，该索引可用于检索 GROUP BY 或 DISTINCT 查询的所有列，而无需对实际表进行任何额外的磁盘访问。此外，索引以最有效的方式使用，因此对于每个组，只读取几个索引条目。
  - `Using join buffer (Block Nested Loop), Using join buffer (Batched Key Access) (JSON property: using_join_buffer)`，来自早期连接的表被部分读入连接缓冲区，然后使用缓冲区中的行来执行与当前表的连接。 (Block Nested Loop) 表示使用 Block Nested-Loop 算法，(Batched Key Access) 表示使用 Batched Key Access 算法。也就是说，EXPLAIN 输出的前一行表中的键被缓冲，匹配的行从出现 Using join buffer 的行所代表的表中批量提取。在 JSON 格式的输出中，using_join_buffer 的值始终是 Block Nested Loop 或 Batched Key Access 之一。有关这些算法的更多信息，请参阅块嵌套循环连接算法和批量密钥访问连接。
  - `Using MRR (JSON property: message)`，使用多范围读取优化策略读取表。
  - `Using sort_union(...), Using union(...), Using intersect(...) (JSON property: message)`，这些指示特定算法，显示如何为 index_merge 连接类型合并索引扫描。
  - `Using temporary (JSON property: using_temporary_table)`，为了解析查询，MySQL 需要创建一个临时表来保存结果。如果查询包含以不同方式列出列的 GROUP BY 和 ORDER BY 子句，通常会发生这种情况。
  - `Using where (JSON property: attached_condition)`，WHERE 子句用于限制哪些行与下一个表匹配或发送给客户端。除非您特别打算从表中获取或检查所有行，否则如果 Extra 值不是 Using where 并且表连接类型是 ALL 或索引，则您的查询可能有问题。在 JSON 格式的输出中使用 where 没有直接的对应物； attached_condition 属性包含使用的任何 WHERE 条件。
  - `Using where with pushed condition (JSON property: message)`，此项仅适用于 NDB 表。这意味着 NDB Cluster 正在使用条件下推优化来提高非索引列和常量之间直接比较的效率。在这种情况下，条件被“下推”到集群的数据节点，并同时在所有数据节点上进行评估。这消除了通过网络发送不匹配行的需要，并且可以将此类查询的速度提高 5 到 10 倍，这比可以使用但未使用条件下推的情况要快。
  - `Zero limit (JSON property: message)`，查询有一个 LIMIT 0 子句，不能选择任何行。


常见Extra：`NULL`、`Using where`、`Using index`、`Using temporary`、`Using filesort`


## sql mode
通过命令`select @@sql_mode;`可以获取当前的sql_mode。

MySQL的sql_mode合理设置
sql_mode是个很容易被忽视的变量,默认值是空值,在这种设置下是可以允许一些非法操作的,比如允许一些非法数据的插入。在生产环境必须将这个值设置为严格模式,所以开发、测试环境的数据库也必须要设置,这样在开发测试阶段就可以发现问题.
sql model 常用来解决下面几类问题
* 通过设置sql mode, 可以完成不同严格程度的数据校验，有效地保障数据准备性。
* 通过设置sql model 为宽松模式，来保证大多数sql符合标准的sql语法，这样应用在不同数据库之间进行迁移时，则不需要对业务sql 进行较大的修改。
* 在不同数据库之间进行数据迁移之前，通过设置SQL Mode 可以使MySQL 上的数据更方便地迁移到目标数据库中。

sql_mode常用值如下: 
* ONLY_FULL_GROUP_BY：对于GROUP BY聚合操作,如果在SELECT中的列,没有在GROUP BY中出现,那么这个SQL是不合法的,因为列不在GROUP BY从句中
* NO_AUTO_VALUE_ON_ZERO：该值影响自增长列的插入。默认设置下,插入0或NULL代表生成下一个自增长值。如果用户 希望插入的值为0,而该列又是自增长的,那么这个选项就有用了。
* STRICT_TRANS_TABLES：在该模式下,如果一个值不能插入到一个事务表中,则中断当前的操作,对非事务表不做* NO_ZERO_IN_DATE：在严格模式下,不允许日期和月份为零
* NO_ZERO_DATE：设置该值,mysql数据库不允许插入零日期,插入零日期会抛出错误而不是警告。
* ERROR_FOR_DIVISION_BY_ZERO：在INSERT或UPDATE过程中,如果数据被零除,则产生错误而非警告。如 果未给出该模式,那么数据被零除时MySQL返回NULL
* NO_AUTO_CREATE_USER：禁止GRANT创建密码为空的用户
* NO_ENGINE_SUBSTITUTION：如果需要的存储引擎被禁用或未编译,那么抛出错误。不设置此值时,用默认的存储引擎替代,并抛出一个异常
* PIPES_AS_CONCAT：将"||"视为字符串的连接操作符而非或运算符,这和Oracle数据库是一样的,也和字符串的拼接函数Concat相类似
* ANSI_QUOTES：启用ANSI_QUOTES后,不能用双引号来引用字符串,因为它被解释为识别符

如果使用mysql，为了继续保留大家使用oracle的习惯，可以对mysql的sql_mode设置如下:
在my.cnf添加如下配置
```conf
[mysqld]
sql_mode='ONLY_FULL_GROUP_BY,NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,PIPES_AS_CONCAT,ANSI_QUOTES'
```

MySQL5.6和MySQL5.7默认的sql_mode模式参数是不一样的,5.6的mode是`NO_ENGINE_SUBSTITUTION`，其实表示的是一个空值，相当于没有什么模式设置，可以理解为宽松模式。5.7的mode是STRICT_TRANS_TABLES，也就是严格模式。
如果设置的是宽松模式，那么我们在插入数据的时候，即便是给了一个错误的数据，也可能会被接受，并且不报错，例如：我在创建一个表时，该表中有一个字段为name，给name设置的字段类型时char(10)，如果我在插入数据的时候，其中name这个字段对应的有一条数据的长度超过了10，例如'1234567890abc'，超过了设定的字段长度10，那么不会报错，并且取前十个字符存上，也就是说你这个数据被存为了'1234567890',而'abc'就没有了，但是我们知道，我们给的这条数据是错误的，因为超过了字段长度，但是并没有报错，并且mysql自行处理并接受了，这就是宽松模式的效果，其实在开发、测试、生产等环境中，我们应该采用的是严格模式，出现这种错误，应该报错才对，所以MySQL5.7版本就将sql_mode默认值改为了严格模式，并且我们即便是用的MySQL5.6，也应该自行将其改为严格模式，而你记着，MySQL等等的这些数据库，都是想把关于数据的所有操作都自己包揽下来，包括数据的校验，其实好多时候，我们应该在自己开发的项目程序级别将这些校验给做了，虽然写项目的时候麻烦了一些步骤，但是这样做之后，我们在进行数据库迁移或者在项目的迁移时，就会方便很多，这个看你们自行来衡量。mysql除了数据校验之外，你慢慢的学习过程中会发现，它能够做的事情还有很多很多，将你程序中做的好多事情都包揽了。
改为严格模式后可能会存在的问题：若设置模式中包含了NO_ZERO_DATE，那么MySQL数据库不允许插入零日期，插入零日期会抛出错误而不是警告。例如表中含字段TIMESTAMP列（如果未声明为NULL或显示DEFAULT子句）将自动分配DEFAULT '0000-00-00 00:00:00'（零时间戳），也或者是本测试的表day列默认允许插入零日期 '0000-00-00' COMMENT '日期'；这些显然是不满足sql_mode中的NO_ZERO_DATE而报错。

### [官方文档](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html)
MySQL 服务器可以在不同的 SQL 模式下运行，并且可以根据 sql_mode 系统变量的值对不同的客户端应用这些模式。 DBA 可以设置全局 SQL 模式以匹配站点服务器操作要求，每个应用程序可以根据自己的要求设置其会话 SQL 模式。
模式会影响 MySQL 支持的 SQL 语法及其执行的数据验证检查。这使得在不同环境中使用 MySQL 以及与其他数据库服务器一起使用 MySQL 变得更加容易。

### 设置 SQL 模式
MySQL 5.7 中默认的 SQL 模式包括这些模式：ONLY_FULL_GROUP_BY、STRICT_TRANS_TABLES、NO_ZERO_IN_DATE、NO_ZERO_DATE、ERROR_FOR_DIVISION_BY_ZERO、NO_AUTO_CREATE_USER 和 NO_ENGINE_SUBSTITUTION。

这些模式被添加到 MySQL 5.7 中的默认 SQL 模式： ONLY_FULL_GROUP_BY 和 STRICT_TRANS_TABLES 模式被添加到 MySQL 5.7.5 中。在 MySQL 5.7.7 中添加了 NO_AUTO_CREATE_USER 模式。 MySQL 5.7.8 中添加了 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 模式。有关对默认 SQL 模式值的这些更改的其他讨论，请参阅 MySQL 5.7 中的 SQL 模式更改。

要在运行时更改 SQL 模式，请使用 SET 语句设置全局或会话 sql_mode 系统变量：
```sql
SET GLOBAL sql_mode = 'modes';
SET SESSION sql_mode = 'modes';
```

设置 GLOBAL 变量需要 SUPER 权限，并影响从那时起连接的所有客户端的操作。设置 SESSION 变量只影响当前客户端。每个客户端都可以随时更改其会话 sql_mode 值。

查看sql_mode
```sql
SELECT @@GLOBAL.sql_mode;
SELECT @@SESSION.sql_mode;
```

> SQL 模式和用户定义的分区。在创建分区表并将数据插入分区表后更改服务器 SQL 模式可能会导致此类表的行为发生重大变化，并可能导致数据丢失或损坏。强烈建议您在使用用户定义的分区创建表后永远不要更改 SQL 模式。
复制分区表时，源和副本上的不同 SQL 模式也会导致问题。为获得最佳结果，您应该始终在源和副本上使用相同的服务器 SQL 模式。


### 最重要的 SQL 模式
  - ANSI
  此模式更改语法和行为以更符合标准 SQL。它是本节末尾列出的特殊组合模式之一。

  - STRICT_TRANS_TABLES
  如果无法将给定的值插入到事务表中，则中止该语句。对于非事务表，如果值出现在单行语句或多行语句的第一行中，则中止语句。本节稍后将提供更多详细信息。从 MySQL 5.7.5 开始，默认的 SQL 模式包括 STRICT_TRANS_TABLES。

  - TRADITIONAL
  使 MySQL 表现得像一个“传统的”SQL 数据库系统。这种模式的简单描述是在向列中插入不正确的值时“给出错误而不是警告”。它是本节末尾列出的特殊组合模式之一。
  > 启用 TRADITIONAL 模式后，一旦发生错误，INSERT 或 UPDATE 就会中止。如果您使用非事务性存储引擎，这可能不是您想要的，因为在错误之前所做的数据更改可能无法回滚，从而导致“部分完成”更新。


### SQL 模式的完整列表
  - ALLOW_INVALID_DATES
  不要执行完整的日期检查。只检查月份在 1 到 12 的范围内，日期在 1 到 31 的范围内。这可能对 Web 应用程序有用，这些应用程序在三个不同的字段中获取年月日并准确存储用户的内容已插入，没有日期验证。此模式适用于 DATE 和 DATETIME 列。它不适用于始终需要有效日期的 TIMESTAMP 列。
  禁用 ALLOW_INVALID_DATES 后，服务器要求月份和日期值是合法的，而不仅仅是分别在 1 到 12 和 1 到 31 的范围内。禁用严格模式后，“2004-04-31”等无效日期将转换为“0000-00-00”并生成警告。启用严格模式后，无效日期会产生错误。要允许此类日期，请启用 ALLOW_INVALID_DATES。

  - ANSI_QUOTES
  将 " 视为标识符引号字符（如 \` 引号字符）而不是字符串引号字符。在启用此模式的情况下，您仍然可以使用 \` 来引用标识符。启用 ANSI_QUOTES 后，您不能使用双引号来引用文字字符串，因为它们被解释为标识符。

  - ERROR_FOR_DIVISION_BY_ZERO
  ERROR_FOR_DIVISION_BY_ZERO 模式影响除以零的处理，包括 MOD(N,0)。对于数据更改操作（INSERT、UPDATE），其效果还取决于是否启用了严格的 SQL 模式。
    - 如果未启用此模式，除以零将插入 NULL 并且不会产生警告。
    - 如果启用此模式，除以零将插入 NULL 并产生警告。
    - 如果启用此模式和严格模式，除以零会产生错误，除非同时给出 IGNORE。对于 INSERT IGNORE 和 UPDATE IGNORE，除以零插入 NULL 并产生警告。
  对于 SELECT，除以零返回 NULL。启用 ERROR_FOR_DIVISION_BY_ZERO 也会导致产生警告，无论是否启用严格模式。
  ERROR_FOR_DIVISION_BY_ZERO 已弃用。 ERROR_FOR_DIVISION_BY_ZERO 不是严格模式的一部分，但应与严格模式结合使用，默认情况下启用。如果启用 ERROR_FOR_DIVISION_BY_ZERO 而未同时启用严格模式，则会出现警告，反之亦然。因为不推荐使用 ERROR_FOR_DIVISION_BY_ZERO；期望在未来的 MySQL 版本中将其作为单独的模式名称删除，其效果包括在严格 SQL 模式的效果中。
  - HIGH_NOT_PRECEDENCE
  NOT 运算符的优先级使得诸如 NOT a BETWEEN b AND c 之类的表达式被解析为 NOT (a BETWEEN b AND c)。在一些旧版本的 MySQL 中，表达式被解析为 (NOT a) BETWEEN b AND c。可以通过启用 HIGH_NOT_PRECEDENCE SQL 模式来获得旧的更高优先级行为。
  - IGNORE_SPACE
  函数名称和 ( 字符之间允许有空格。这会导致内置函数名称被视为保留字。例如，因为有一个 COUNT() 函数，所以在下面的语句中使用 count 作为表名会导致错误。IGNORE_SPACE SQL 模式适用于内置函数，不适用于可加载函数或存储函数。无论是否启用 IGNORE_SPACE，始终允许在可加载函数或存储函数名称后有空格。
  - NO_AUTO_CREATE_USER
  防止 GRANT 语句自动创建新的用户帐户，除非指定了身份验证信息。该语句必须使用 IDENTIFIED BY 指定非空密码或使用 IDENTIFIED WITH 指定身份验证插件。最好使用 CREATE USER 而不是 GRANT 创建 MySQL 帐户。 NO_AUTO_CREATE_USER 已弃用，默认 SQL 模式包括 NO_AUTO_CREATE_USER。更改 NO_AUTO_CREATE_USER 模式状态的 sql_mode 分配会产生警告，但将 sql_mode 设置为 DEFAULT 的分配除外。预计 NO_AUTO_CREATE_USER 将在 MySQL 的未来版本中被删除，并且其效果将始终启用（并且 GRANT 不再创建帐户）。
  以前，在弃用 NO_AUTO_CREATE_USER 之前，不启用它的原因之一是它不是复制安全的。现在可以启用它并使用 CREATE USER IF NOT EXISTS、DROP USER IF EXISTS 和 ALTER USER IF EXISTS 而不是 GRANT 来执行复制安全的用户管理。当副本可能具有与源上的授权不同的授权时，这些语句可以实现安全复制。

  - NO_AUTO_VALUE_ON_ZERO
  NO_AUTO_VALUE_ON_ZERO 影响 AUTO_INCREMENT 列的处理。通常，您通过向其中插入 NULL 或 0 来生成列的下一个序列号。 NO_AUTO_VALUE_ON_ZERO 抑制 0 的这种行为，以便只有 NULL 生成下一个序列号。如果 0 已存储在表的 AUTO_INCREMENT 列中，则此模式很有用。 （顺便说一下，不建议存储 0。）例如，如果您使用 mysqldump 转储表然后重新加载它，MySQL 通常会在遇到 0 值时生成新的序列号，从而导致表的内容不同于被丢弃的那个。在重新加载转储文件之前启用 NO_AUTO_VALUE_ON_ZERO 可以解决此问题。为此，mysqldump 在其输出中自动包含一个启用 NO_AUTO_VALUE_ON_ZERO 的语句。

  - NO_BACKSLASH_ESCAPES
  启用此模式将禁止使用反斜杠字符 (\) 作为字符串和标识符中的转义字符。启用此模式后，反斜杠像其他任何字符一样变成普通字符，并且更改了 LIKE 表达式的默认转义序列，因此不使用转义字符。

  - NO_DIR_IN_CREATE
  创建表时，忽略所有 INDEX DIRECTORY 和 DATA DIRECTORY 指令。此选项在副本复制服务器上很有用。

  - NO_ENGINE_SUBSTITUTION
  当诸如 CREATE TABLE 或 ALTER TABLE 之类的语句指定禁用或未编译的存储引擎时，控制默认存储引擎的自动替换。默认情况下，启用 NO_ENGINE_SUBSTITUTION。因为存储引擎可以在运行时插入，所以不可用的引擎以相同的方式处理：在禁用 NO_ENGINE_SUBSTITUTION 的情况下，对于 CREATE TABLE，将使用默认引擎，如果所需引擎不可用，则会出现警告。对于 ALTER TABLE，会出现警告并且不会更改表。启用 NO_ENGINE_SUBSTITUTION 后，如果所需的引擎不可用，则会发生错误并且不会创建或更改表。
  
  - NO_UNSIGNED_SUBTRACTION
  默认情况下，整数值之间的减法，其中一个是 UNSIGNED 类型，会产生一个无符号的结果。如果结果为负，则会产生错误，如果启用了 NO_UNSIGNED_SUBTRACTION SQL 模式，则结果为负。如果此类操作的结果用于更新 UNSIGNED 整数列，则结果将被裁剪为列类型的最大值，或者如果启用 NO_UNSIGNED_SUBTRACTION 则裁剪为 0。在启用严格 SQL 模式的情况下，发生错误并且该列保持不变。

  - ONLY_FULL_GROUP_BY
  拒绝选择列表、HAVING 条件或 ORDER BY 列表引用非聚合列的查询，这些列既没有在 GROUP BY 子句中命名，也没有在功能上依赖于（唯一确定）GROUP BY 列。从 MySQL 5.7.5 开始，默认的 SQL 模式包括 ONLY_FULL_GROUP_BY。 （5.7.5之前，MySQL不检测函数依赖，默认不开启ONLY_FULL_GROUP_BY。）MySQL 对标准 SQL 的扩展允许在 HAVING 子句中引用选择列表中的别名表达式。在 MySQL 5.7.5 之前，启用 ONLY_FULL_GROUP_BY 会禁用此扩展，因此需要使用无别名表达式编写 HAVING 子句。从 MySQL 5.7.5 开始，此限制被取消，因此无论是否启用 ONLY_FULL_GROUP_BY，HAVING 子句都可以引用别名。

  - PAD_CHAR_TO_FULL_LENGTH
  默认情况下，检索时会从 CHAR 列值中删除尾随空格。如果启用 PAD_CHAR_TO_FULL_LENGTH，则不会进行修剪，并且检索到的 CHAR 值将填充到它们的全长。此模式不适用于 VARCHAR 列，其尾随空格在检索时保留。

  - PIPES_AS_CONCAT
  对待||作为字符串连接运算符（与 CONCAT() 相同）而不是作为 OR 的同义词。

  - REAL_AS_FLOAT
  将 REAL 视为 FLOAT 的同义词。默认情况下，MySQL 将 REAL 视为 DOUBLE 的同义词。

  - STRICT_ALL_TABLES
  为所有存储引擎启用严格的 SQL 模式。拒绝无效的数据值。有关详细信息，请参阅严格 SQL 模式。
  从 MySQL 5.7.4 到 5.7.7，STRICT_ALL_TABLES 包括 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 模式的影响。有关其他讨论，请参阅 MySQL 5.7 中的 SQL 模式更改。

  - STRICT_TRANS_TABLES
  为事务存储引擎启用严格的 SQL 模式，并在可能的情况下为非事务存储引擎启用严格的 SQL 模式。有关详细信息，请参阅严格 SQL 模式。
  从 MySQL 5.7.4 到 5.7.7，STRICT_TRANS_TABLES 包括 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 模式的效果。

* 组合 SQL 模式
  - ANSI
  相当于 REAL_AS_FLOAT、PIPES_AS_CONCAT、ANSI_QUOTES、IGNORE_SPACE 和（从 MySQL 5.7.5 开始）ONLY_FULL_GROUP_BY。ANSI 模式还会导致服务器为查询返回错误，其中无法在已解析外部引用的外部查询中聚合具有外部引用 S(outer_ref) 的集合函数 S。
  - TRADITIONAL
  在 MySQL 5.7.4 之前和 MySQL 5.7.8 及更高版本中，TRADITIONAL 等同于 STRICT_TRANS_TABLES、STRICT_ALL_TABLES、NO_ZERO_IN_DATE、NO_ZERO_DATE、ERROR_FOR_DIVISION_BY_ZERO、NO_AUTO_CREATE_USER 和 NO_ENGINE_SUBSTITUTION。
  从 MySQL 5.7.4 到 5.7.7，TRADITIONAL 相当于 STRICT_TRANS_TABLES、STRICT_ALL_TABLES、NO_AUTO_CREATE_USER 和 NO_ENGINE_SUBSTITUTION。 NO_ZERO_IN_DATE、NO_ZERO_DATE 和 ERROR_FOR_DIVISION_BY_ZERO 模式未命名，因为在这些版本中，它们的效果包含在严格 SQL 模式（STRICT_ALL_TABLES 或 STRICT_TRANS_TABLES）的效果中。因此，TRADITIONAL 的效果在所有 MySQL 5.7 版本中都是相同的（并且与 MySQL 5.6 中的相同）。
### 严格 SQL 模式
严格模式控制 MySQL 如何处理数据更改语句（如 INSERT 或 UPDATE）中的无效或缺失值。一个值可能由于多种原因而无效。例如，列的数据类型可能有误，或者可能超出范围。当要插入的新行不包含在其定义中没有显式 DEFAULT 子句的非 NULL 列的值时，将缺少一个值。 （对于 NULL 列，如果值缺失，则插入 NULL。）严格模式还会影响 DDL 语句，例如 CREATE TABLE。
如果严格模式未生效，MySQL 会为无效或缺失值插入调整后的值并产生警告。在严格模式下，您可以使用 INSERT IGNORE 或 UPDATE IGNORE 产生此行为。
对于不更改数据的 SELECT 等语句，无效值会在严格模式下生成警告，而不是错误。
严格模式会在尝试创建超过最大密钥长度的密钥时产生错误。当未启用严格模式时，这会导致警告并将密钥截断为最大密钥长度。
严格模式不影响是否检查外键约束。 foreign_key_checks 可用于此目的。 

如果启用了 STRICT_ALL_TABLES 或 STRICT_TRANS_TABLES，则严格 SQL 模式生效，尽管这些模式的效果有所不同：

* 对于事务表，当启用 STRICT_ALL_TABLES 或 STRICT_TRANS_TABLES 时，数据更改语句中的无效值或缺失值会发生错误。该语句被中止并回滚。

* 对于非事务表，如果错误值出现在要插入或更新的第一行中，两种模式的行为都是相同的：语句被中止，表保持不变。如果语句插入或修改多行并且错误值出现在第二行或后面的行中，则结果取决于启用的严格模式：

  - 对于 STRICT_ALL_TABLES，MySQL 返回错误并忽略其余行。但是，因为前面的行已被插入或更新，所以结果是部分更新。为避免这种情况，请使用单行语句，它可以在不更改表的情况下中止。

  - 对于 STRICT_TRANS_TABLES，MySQL 将无效值转换为最接近列的有效值并插入调整后的值。如果缺少值，MySQL 将插入列数据类型的隐式默认值。在任何一种情况下，MySQL 都会生成警告而不是错误并继续处理该语句。隐式默认值在第 11.6 节“数据类型默认值”中进行了描述。

严格模式影响除以零、零日期和日期中的零的处理，如下所示：

* 严格模式影响除以零的处理，包括 MOD(N,0)：
  对于数据更改操作（INSERT、UPDATE）：

  - 如果未启用严格模式，除以零将插入 NULL 并且不会产生警告。

  - 如果启用了严格模式，除以零会产生错误，除非同时给出 IGNORE。对于 INSERT IGNORE 和 UPDATE IGNORE，除以零插入 NULL 并产生警告。

  对于 SELECT，除以零返回 NULL。启用严格模式也会导致产生警告。

* 严格模式影响服务器是否允许 '0000-00-00' 作为有效日期：

  - 如果未启用严格模式，则允许 '0000-00-00' 并且插入不会产生警告。

  - 如果启用了严格模式，则不允许使用 '0000-00-00' 并且插入会产生错误，除非同时给出 IGNORE。对于 INSERT IGNORE 和 UPDATE IGNORE，允许使用 '0000-00-00' 并且插入会产生警告。

* 严格模式会影响服务器是否允许年部分为非零但月或日部分为 0 的日期（日期如“2010-00-01”或“2010-01-00”）：

  - 如果未启用严格模式，则允许包含零部分的日期并且插入不会产生警告。

  - 如果启用了严格模式，则不允许包含零部分的日期并且插入会产生错误，除非同时给出 IGNORE。对于 INSERT IGNORE 和 UPDATE IGNORE，零部分的日期被插入为“0000-00-00”（这被认为对 IGNORE 有效）并产生警告。

在 MySQL 5.7.4 之前和 MySQL 5.7.8 及更高版本中，严格模式会影响除以零、零日期和日期中的零以及 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 模式的处理。从 MySQL 5.7.4 到 5.7.7，ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 模式在显式命名时什么都不做，它们的效果包含在严格模式的效果中。有关其他讨论，请参阅 MySQL 5.7 中的 SQL 模式更改。

### IGNORE 关键字和严格 SQL 模式的比较
本节比较了 IGNORE 关键字（将错误降级为警告）和严格 SQL 模式（将警告升级为错误）对语句执行的影响。它描述了它们影响哪些语句，以及它们适用于哪些错误。

下表提供了默认情况下产生错误与警告时语句行为的总结比较。默认情况下会产生错误的示例是将 NULL 插入到 NOT NULL 列中。默认情况下产生警告的一个示例是将错误数据类型的值插入到列中（例如将字符串“abc”插入到整数列中）。

|Operational Mode  |When Statement Default is Error |When Statement Default is Warning|
|---|---|---|
|Without IGNORE or strict SQL mode |Error |Warning|
|With IGNORE |Warning |Warning (same as without IGNORE or strict SQL mode)|
|With strict SQL mode  |Error (same as without IGNORE or strict SQL mode) |Error|
|With IGNORE and strict SQL mode |Warning| Warning|


从表中得出的一个结论是，当 IGNORE 关键字和严格 SQL 模式同时生效时，IGNORE 优先。这意味着，尽管 IGNORE 和严格的 SQL 模式可以被认为对错误处理有相反的效果，但它们在一起使用时不会取消。

MySQL 中的几个语句支持可选的 IGNORE 关键字。此关键字导致服务器降级某些类型的错误并生成警告。对于多行语句，将错误降级为警告可能会启用要处理的行。否则，IGNORE 会导致语句跳到下一行而不是中止。 （对于不可忽略的错误，无论 IGNORE 关键字如何都会发生错误。）
示例：如果表 t 的主键列 i 包含唯一值，尝试将 i 的相同值插入多行通常会产生重复键错误：
```sql
mysql> CREATE TABLE t (i INT NOT NULL PRIMARY KEY);
mysql> INSERT INTO t (i) VALUES(1),(1);
ERROR 1062 (23000): Duplicate entry '1' for key 'PRIMARY'
```

With IGNORE, the row containing the duplicate key still is not inserted, but a warning occurs instead of an error:
```sql
mysql> INSERT IGNORE INTO t (i) VALUES(1),(1);
Query OK, 1 row affected, 1 warning (0.01 sec)
Records: 2  Duplicates: 1  Warnings: 1

mysql> SHOW WARNINGS;
+---------+------+---------------------------------------+
| Level   | Code | Message                               |
+---------+------+---------------------------------------+
| Warning | 1062 | Duplicate entry '1' for key 'PRIMARY' |
+---------+------+---------------------------------------+
1 row in set (0.00 sec)
```

这些语句支持 IGNORE 关键字：
* CREATE TABLE ... SELECT：IGNORE 不适用于语句的 CREATE TABLE 或 SELECT 部分，但适用于将 SELECT 生成的行插入到表中。与唯一键值上的现有行重复的行将被丢弃。
* DELETE: IGNORE 使 MySQL 在删除行的过程中忽略错误。
* INSERT：使用 IGNORE，将丢弃在唯一键值上重复现有行的行。设置为会导致数据转换错误的值的行将改为设置为最接近的有效值。对于未找到与给定值匹配的分区的分区表，IGNORE 会导致插入操作对包含不匹配值的行静默失败。
* LOAD DATA，LOAD XML：使用 IGNORE，将丢弃在唯一键值上重复现有行的行。
* UPDATE：使用 IGNORE，不会更新在唯一键值上发生重复键冲突的行。更新为会导致数据转换错误的值的行将更新为最接近的有效值。

IGNORE 关键字适用于以下可忽略的错误：

```sql
ER_BAD_NULL_ERROR
ER_DUP_ENTRY
ER_DUP_ENTRY_WITH_KEY_NAME
ER_DUP_KEY
ER_NO_PARTITION_FOR_GIVEN_VALUE
ER_NO_PARTITION_FOR_GIVEN_VALUE_SILENT
ER_NO_REFERENCED_ROW_2
ER_ROW_DOES_NOT_MATCH_GIVEN_PARTITION_SET
ER_ROW_IS_REFERENCED_2
ER_SUBQUERY_NO_1_ROW
ER_VIEW_CHECK_FAILED
```

MySQL 服务器可以在不同的 SQL 模式下运行，并且可以根据 sql_mode 系统变量的值对不同的客户端应用这些模式。在“严格”SQL 模式下，服务器将某些警告升级为错误。

例如，在非严格 SQL 模式下，将字符串 'abc' 插入整数列会导致值转换为 0 并出现警告：
```sql
mysql> SET sql_mode = '';
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO t (i) VALUES('abc');
Query OK, 1 row affected, 1 warning (0.01 sec)

mysql> SHOW WARNINGS;
+---------+------+--------------------------------------------------------+
| Level   | Code | Message                                                |
+---------+------+--------------------------------------------------------+
| Warning | 1366 | Incorrect integer value: 'abc' for column 'i' at row 1 |
+---------+------+--------------------------------------------------------+
1 row in set (0.00 sec)
```

严格 SQL 模式适用于以下语句，在某些值可能超出范围或向表中插入或删除无效行的情况下：
* ALTER TABLE
* CREATE TABLE
* CREATE TABLE ... SELECT
* DELETE (both single table and multiple table)
* INSERT
* LOAD DATA
* LOAD XML
* SELECT SLEEP()
* UPDATE (both single table and multiple table)

在存储过程中，如果程序是在严格模式生效时定义的，那么刚刚列出的类型的单个语句将以严格 SQL 模式执行。

严格 SQL 模式适用于以下错误，这些错误表示输入值无效或缺失的一类错误。如果列的数据类型错误或可能超出范围，则值无效。如果要插入的新行不包含在其定义中没有显式 DEFAULT 子句的 NOT NULL 列的值，则值丢失。

```sql
ER_BAD_NULL_ERROR
ER_CUT_VALUE_GROUP_CONCAT
ER_DATA_TOO_LONG
ER_DATETIME_FUNCTION_OVERFLOW
ER_DIVISION_BY_ZERO
ER_INVALID_ARGUMENT_FOR_LOGARITHM
ER_NO_DEFAULT_FOR_FIELD
ER_NO_DEFAULT_FOR_VIEW_FIELD
ER_TOO_LONG_KEY
ER_TRUNCATED_WRONG_VALUE
ER_TRUNCATED_WRONG_VALUE_FOR_FIELD
ER_WARN_DATA_OUT_OF_RANGE
ER_WARN_NULL_TO_NOTNULL
ER_WARN_TOO_FEW_RECORDS
ER_WRONG_ARGUMENTS
ER_WRONG_VALUE_FOR_TYPE
WARN_DATA_TRUNCATED
```


### MySQL 5.7 中 SQL 模式的变化
在 MySQL 5.7.22 中，这些 SQL 模式已弃用并在 MySQL 8.0 中被删除：DB2、MAXDB、MSSQL、MYSQL323、MYSQL40、ORACLE、POSTGRESQL、NO_FIELD_OPTIONS、NO_KEY_OPTIONS、NO_TABLE_OPTIONS。
在 MySQL 5.7 中，默认启用 ONLY_FULL_GROUP_BY SQL 模式，因为 GROUP BY 处理变得更加复杂，包括检测功能依赖性。但是，如果您发现启用 ONLY_FULL_GROUP_BY 会导致对现有应用程序的查询被拒绝，则这些操作中的任何一个都应该恢复操作：
如果可以修改有问题的查询，请这样做，或者使非聚合列在功能上依赖于 GROUP BY 列，或者通过使用 ANY_VALUE() 引用非聚合列。
如果无法修改有问题的查询（例如，如果它是由第三方应用程序生成的），请在服务器启动时将 sql_mode 系统变量设置为不启用 ONLY_FULL_GROUP_BY。
在 MySQL 5.7 中，不推荐使用 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE SQL 模式。长期计划是将这三种模式包含在严格的 SQL 模式中，并在未来的 MySQL 版本中将它们作为显式模式删除。为了在 MySQL 5.7 中与 MySQL 5.6 严格模式兼容，并为受影响的应用程序修改提供额外的时间，以下行为适用：
ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE 不是严格 SQL 模式的一部分，但它们旨在与严格模式一起使用。提醒一下，如果在没有启用严格模式的情况下启用它们，则会出现警告，反之亦然。
默认情况下启用 ERROR_FOR_DIVISION_BY_ZERO、NO_ZERO_DATE 和 NO_ZERO_IN_DATE。
通过上述更改，默认情况下仍会启用更严格的数据检查，但可以在当前需要或需要这样做的环境中禁用各个模式。

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


## 用户管理

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
* 《高性能MySQL》