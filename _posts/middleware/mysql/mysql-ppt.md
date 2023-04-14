name: mysql-ppt
---

# 简介篇
什么是数据库？
简单来说，数据库就是一个存储数据的仓库，它将数据按照特定的规律存储在磁盘上。为了方便用户组织和管理数据，其专门提供了数据库管理系统。通过数据库管理系统，用户可以有效的组织和管理存储在数据库中的数据。
## MySQL
什么是MySQL？
The world's most popular open source database.
MySQL 软件提供了一个非常快速、多线程、多用户和强大的 SQL（结构化查询语言）数据库服务器。 MySQL Server 旨在用于关键任务、重负载生产系统以及嵌入到大规模部署的软件中。
refman文档：[https://dev.mysql.com/doc/refman/5.7/en/introduction.html](https://dev.mysql.com/doc/refman/5.7/en/introduction.html)

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

## 其他数据库

* 文档数据库：MongoDB
* 缓存数据库：Redis
* 时序数据库：InfluxDB
* 搜索数据库：Elasticsearch

每种数据库都有自己的使用场景
## WorkBench
MySQL Workbench 提供了一个用于处理 MySQL 服务器和数据库的图形工具。 MySQL Workbench 完全支持 MySQL 5.5 及更高版本。
* SQL 开发：使您能够创建和管理与数据库服务器的连接。除了使您能够配置连接参数外，MySQL Workbench 还提供了使用内置 SQL 编辑器对数据库连接执行 SQL 查询的功能。此功能取代了以前由查询浏览器独立应用程序提供的功能。
* 数据建模：使您能够以图形方式创建数据库模式模型，在模式和实时数据库之间进行反向和正向工程，并使用综合表编辑器编辑数据库的所有方面。表编辑器提供易于使用的工具，用于编辑表、列、索引、触发器、分区、选项、插入和权限、例程和视图。
* 服务器管理：使您能够创建和管理服务器实例。
* 数据迁移：允许您从 Microsoft SQL Server、Sybase ASE、SQLite、SQL Anywhere、PostreSQL 和其他 RDBMS 表、对象和数据迁移到 MySQL。迁移还支持从早期版本的 MySQL 迁移到最新版本。
* MySQL Enterprise Support：支持 MySQL Enterprise Backup 和 MySQL Audit 等企业产品。

MySQL Workbench 有两个版本，社区版和商业版。社区版是免费提供的。商业版以低成本提供额外的企业功能，例如数据库文档生成。

## MyISAM

MyISAM 表具有以下特点：
* 所有数据值都以低字节在前存储。这使得数据机和操作系统独立。二进制可移植性的唯一要求是机器使用二进制补码符号整数和 IEEE 浮点格式。这些要求在主流机器中被广泛使用。二进制兼容性可能不适用于嵌入式系统，嵌入式系统有时具有特殊的处理器。
* 先存储数据低字节没有显着的速度损失；表行中的字节通常是未对齐的，按顺序读取未对齐的字节比按相反顺序读取需要更多的处理。此外，与其他代码相比，服务器中获取列值的代码对时间的要求不高。
* 所有数字键值都先存储高字节，以允许更好的索引压缩。
* 支持大文件的文件系统和操作系统支持大文件（最大 63 位文件长度）。
* MyISAM 表中有 $(2^{32})^2$ (1.844E+19) 行的限制。
* 每个 MyISAM 表的最大索引数是 64。
* 每个索引的最大列数为 16。
* 最大密钥长度为 1000 字节。这也可以通过更改源代码和重新编译来更改。对于长于 250 字节的密钥，使用比默认值 1024 字节更大的密钥块大小。
* 当按排序顺序插入行时（如使用 AUTO_INCREMENT 列时），索引树将被拆分，以便高节点仅包含一个键。这提高了索引树中的空间利用率。
* 支持对每个表的一个 AUTO_INCREMENT 列进行内部处理。 MyISAM 为 INSERT 和 UPDATE 操作自动更新此列。这使得 AUTO_INCREMENT 列更快（至少 10%）。序列顶部的值在删除后不会重复使用。 （当 AUTO_INCREMENT 列被定义为多列索引的最后一列时，会重复使用从序列顶部删除的值。）可以使用 ALTER TABLE 或 myisamchk 重置 AUTO_INCREMENT 值。
* 将删除与更新和插入混合使用时，动态大小的行的碎片要少得多。这是通过自动组合相邻的已删除块并在下一个块被删除时扩展块来完成的。
* MyISAM 支持并发插入：如果一个表在数据文件中间没有空闲块，您可以在其他线程从表中读取的同时向其中插入新行。删除行或更新动态长度行的数据多于其当前内容时，可能会出现空闲块。当所有空闲块都用完（填充）时，未来的插入将再次变为并发。请参阅第 8.11.3 节，“并发插入”。
* 您可以将数据文件和索引文件放在不同物理设备上的不同目录中，以使用 DATA DIRECTORY 和 INDEX DIRECTORY 表选项来更快地创建表。请参阅第 13.1.18 节，“CREATE TABLE 语句”。
* BLOB 和 TEXT 列可以被索引。
* 索引列中允许 NULL 值。每个密钥需要 0 到 1 个字节。
* 每个字符列可以有不同的字符集。请参阅第 10 章，字符集、排序规则、Unicode。
* MyISAM 索引文件中有一个标志指示表是否正确关闭。如果 mysqld 启动时设置了 myisam_recover_options 系统变量，则 MyISAM 表在打开时会自动检查，如果表未正确关闭则进行修复。
* 如果您使用 --update-state 选项运行 myisamchk，它会将表标记为已检查。 myisamchk --fast 只检查那些没有这个标记的表。
* myisamchk --analyze 存储部分密钥以及整个密钥的统计信息。
* myisampack 可以打包 BLOB 和 VARCHAR 列。

MyISAM 还支持以下功能：
* 支持真正的 VARCHAR 类型； VARCHAR 列以存储在一个或两个字节中的长度开始。
* 具有 VARCHAR 列的表可能具有固定或动态的行长度。
* 表中 VARCHAR 和 CHAR 列的长度总和可能高达 64KB。
* 任意长度的 UNIQUE 约束。


## InnoDB
InnoDB 是一个兼顾高可靠性和高性能的通用存储引擎。

优势
* 它的 DML 操作遵循 ACID 模型，事务具有提交、回滚和崩溃恢复功能以保护用户数据。
* 行级锁定和 Oracle 风格的一致性读取提高了多用户并发性和性能。
* InnoDB 表在磁盘上安排您的数据以优化基于主键的查询。每个 InnoDB 表都有一个称为聚簇索引的主键索引，它组织数据以最小化主键查找的 I/O。
* 为了保持数据完整性，InnoDB 支持 FOREIGN KEY 约束。对于外键，检查插入、更新和删除以确保它们不会导致相关表之间的不一致。


# 基础篇-数据
## 数据类型（Data Types）
### 数字类型（Numeric Data Types）
MySQL 支持所有标准的 SQL 数字数据类型。这些类型包括精确数值数据类型（INTEGER、SMALLINT、DECIMAL 和 NUMERIC）以及近似数值数据类型（FLOAT、REAL 和 DOUBLE PRECISION）。关键字 INT 是 INTEGER 的同义词，关键字 DEC 和 FIXED 是 DECIMAL 的同义词。 MySQL 将 DOUBLE 视为 DOUBLE PRECISION 的同义词（非标准扩展）。 MySQL 还将 REAL 视为 DOUBLE PRECISION 的同义词（非标准变体），除非启用了 REAL_AS_FLOAT SQL 模式。

BIT 数据类型存储位值，支持 MyISAM、MEMORY、InnoDB 和 NDB 表。

数字数据类型语法
对于整数数据类型，M 表示最大显示宽度。最大显示宽度为 255。
对于浮点和定点数据类型，M 是可以存储的总位数。
如果为数字列指定 ZEROFILL，MySQL 会自动将 UNSIGNED 属性添加到该列。
允许 UNSIGNED 属性的数字数据类型也允许 SIGNED。但是，默认情况下这些数据类型是有符号的，因此 SIGNED 属性无效。
SERIAL 是 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE 的别名。
SERIAL DEFAULT VALUE 在整数列的定义中是 NOT NULL AUTO_INCREMENT UNIQUE 的别名。

MySQL提供了多种数值型数据类型，不同的数据类型提供不同的取值范围，可以存储的值范围越大，所需的存储空间也会越大。
不同的整数类型有不同的取值范围，并且需要不同的存储空间，因此应根据实际需要选择最合适的类型，这样有利于提高查询的效率和节省存储空间。

|类型名称       |说明         |存储需求|有符号范围|无符号范围|
|--|--|--|--|--|
|BIT(M)        |bit位值     |M/8个字节| 依赖M的值 | 依赖M的值|
|TINYINT       |很小的整数    |1个字节|-128〜127    0| 〜255|
|SMALLINT      |小的整数     | 2个宇节|-32768〜32767   | 0〜65535|
|MEDIUMINT     |中等大小的整数| 3个字节|-8388608〜8388607   | 0〜16777215|
|INT, INTEGER  |普通大小的整数| 4个字节|-2147483648〜2147483647 | 0〜4294967295|
|BIGINT        |大整数       | 8个字节|-9223372036854775808〜9223372036854775807   | 0〜18446744073709551615|

特殊的数字类型`BOOL,BOOLEAN`，占用1字节，表示true或false


MySQL中可以使用浮点小数和定点小数：浮点类型有两种，分别是单精度浮点数（**FLOAT**）和双精度浮点数（**DOUBLE**）；定点类型只有一种，就是 **DECIMAL**。
浮点类型和定点类型都可以用`(M, D)`来表示，其中`M`称为精度，表示总共的位数；`D`称为标度，表示小数的位数。
浮点数类型的取值范围为 M（1～255）和 D（1～30，且不能大于 M-2），分别表示显示宽度和小数位数。M 和 D 在 FLOAT 和DOUBLE 中是可选的，FLOAT 和 DOUBLE 类型将被保存为硬件所支持的最大精度。DECIMAL 的默认 D 值为 0、M 值为 10。
不论是定点还是浮点类型，如果用户指定的精度超出精度范围，则会四舍五入进行处理。

|类型名称       |说明         |存储需求|有符号范围|无符号范围|
|--|--|--|--|--|
|FLOAT       |单精度浮点数        |4个字节|(-3.402823466E+38，-1.175494351E-38)，0，(1.175494351E-38，3.402823466351E+38)   | 0，(1.175494351E-38，3.402823466E+38)|
|DOUBLE      |双精度浮点数     | 8个宇节|(-1.7976931348623157E+308，-2.2250738585072014E-308)，0，(2.2250738585072014E-308，1.7976931348623157E+308)  | 0，(2.2250738585072014E-308，1.7976931348623157E+308)|
|DECIMAL (M, D)，DEC     |压缩的“严格”定点数|如果M>D，为M+2否则为D+2|依赖于M和D的值  | 依赖于M和D的值|


### 日期和时间类型（Date and Time Data Types）

表示时间值的日期和时间数据类型有 DATE、TIME、DATETIME、TIMESTAMP 和 YEAR。每个时间类型都有一系列有效值，以及一个“零”值，当您指定 MySQL 无法表示的无效值时可能会使用该值。 TIMESTAMP 和 DATETIME 类型具有特殊的自动更新行为。

时间日期字段零值

|Data Type| “Zero” Value|
|---|---|
|DATE |'0000-00-00'|
|TIME |'00:00:00'|
|DATETIME |'0000-00-00 00:00:00'|
|TIMESTAMP  |'0000-00-00 00:00:00'|
|YEAR |0000|

时间日志字段表示范围

|类型名称    |日期格式    | 日期范围                                                      |存储需求|
|---|---|---|---|
|YEAR       |YYYY       | 1901 ~ 2155                                                  |1 个字节|
|TIME       |HH:MM:SS   | -838:59:59 ~ 838:59:59                                       |3 个字节|
|DATE       |YYYY-MM-DD | 1000-01-01 ~ 9999-12-3                                       |3 个字节|
|DATETIME   |YYYY-MM-DD | HH:MM:SS 1000-01-01 00:00:00 ~ 9999-12-31 23:59:59           |8 个字节|
|TIMESTAMP  |YYYY-MM-DD | HH:MM:SS 1970-01-01 00:00:01 UTC ~ 2038-01-19 03:14:07 UTC   |4 个字节|

### 字符串类型（String Data Types）
对于字符串列（CHAR、VARCHAR 和 TEXT 类型）的定义，MySQL 以字符单位解释长度规范。对于二进制字符串列（BINARY、VARBINARY 和 BLOB 类型）的定义，MySQL 以字节为单位解释长度规范。

字符类型存储

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

二进制类型存储

|类型名称     |说明                                     |  存储需求|
|-|-|-|
|BIT(M)          |位字段类型          |大约 (M+7)/8 字节|
|BINARY(M)       |固定长度二进制字符串 | M 字节|
|VARBINARY (M)   |可变长度二进制字符串 | M+1 字节|
|TINYBLOB (M)    |非常小的BLOB        | L+1 字节，在此，L<2^8|
|BLOB (M)        |小 BLOB            | L+2 字节，在此，L<2^16|
|MEDIUMBLOB (M)  |中等大小的BLOB      | L+3 字节，在此，L<2^24|
|LONGBLOB (M)    |非常大的BLOB        | L+4 字节，在此，L<2^32|

## 函数和运算符（Functions and Operators）
函数可以在 SQL 语句中的多个位置使用，例如在 SELECT 语句的 ORDER BY 或 HAVING 子句中，在 SELECT、DELETE 或 UPDATE 语句的 WHERE 子句中，或在 SET 语句中。可以使用来自多个来源的值来编写表达式，例如文字值、列值、NULL、变量、内置函数和运算符、可加载函数和存储函数（一种存储对象）。

[内建函数和操作符总览](https://dev.mysql.com/doc/refman/5.7/en/built-in-function-reference.html)

### 运算符
MySQL 支持 4 种运算符，分别是：
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
|6 | `BETWEEN`（左闭右闭）、`CASE`、`WHEN`、`THEN`、`ELSE`|
|7 | `=`(比较运算）、`<=>`（都否都为NULL）、`>=`、`>`、`<=`、`<`、`<>`（不等）、`!=`、 `IS`、`LIKE`、`REGEXP`、`IN`|
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


### 数值函数
[数字函数和运算符](https://dev.mysql.com/doc/refman/5.7/en/numeric-functions.html)

对数字进行相关操作：符号运算和数字相关的函数

常用函数

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

如果结果的长度大于 max_allowed_packet 系统变量的值，则字符串值函数返回 NULL。
对于对字符串位置进行操作的函数，第一个位置编号为 1。
对于采用长度参数的函数，非整数参数四舍五入为最接近的整数。

如果给字符串函数一个二进制字符串作为参数，则生成的字符串也是一个二进制字符串。转换为字符串的数字被视为二进制字符串。这仅影响比较。
通常，如果字符串比较中的任何表达式区分大小写，则比较以区分大小写的方式执行。
如果从 mysql 客户端中调用字符串函数，二进制字符串将使用十六进制表示法显示，具体取决于 --binary-as-hex 的值。

常用操作
* expr LIKE pat [ESCAPE 'escape_char']
使用 SQL 模式的模式匹配。返回 1 (TRUE) 或 0 (FALSE)。如果 expr 或 pat 为 NULL，则结果为 NULL。
模式不必是文字字符串。例如，它可以指定为字符串表达式或表列。在后一种情况下，该列必须定义为 MySQL 字符串类型之一。根据 SQL 标准，LIKE 在每个字符的基础上执行匹配，因此它可以产生不同于 = 比较运算符的结果。特别是，尾随空格很重要，这对于使用 = 运算符执行的非二进制字符串（CHAR、VARCHAR 和 TEXT 值）的比较而言并非如此。
使用 LIKE，您可以在模式中使用以下两个通配符：
	- `%` 匹配任意数量的字符，甚至零个字符。
	- `_` 正好匹配一个字符。
要测试通配符的文字实例，请在其前面加上转义字符。如果不指定 ESCAPE 字符，则假定为 \，除非启用了 NO_BACKSLASH_ESCAPES SQL 模式。在这种情况下，不使用转义字符。
	- `\%` 匹配一个 `%` 字符。
	- `\_` 匹配一个 `_` 字符。
* expr NOT LIKE pat [ESCAPE 'escape_char']
与 NOT (expr LIKE pat [ESCAPE 'escape_char']) 相同
* expr REGEXP pat, expr RLIKE pat
如果字符串 expr 与模式 pat 指定的正则表达式匹配，则返回 1，否则返回 0。如果 expr 或 pat 为 NULL，则返回值为 NULL。RLIKE 是 REGEXP 的同义词。
该模式可以是扩展的正则表达式。模式不必是文字字符串。例如，它可以指定为字符串表达式或表列。
> MySQL 在字符串中使用 C 转义语法（例如，\n 表示换行符）。如果您希望 expr 或 pat 参数包含文字 \，则必须将其加倍。 （除非启用了 NO_BACKSLASH_ESCAPES SQL 模式，在这种情况下不使用转义字符。）
在确定字符类型和执行比较时，正则表达式操作使用字符串表达式和模式参数的字符集和排序规则。如果参数具有不同的字符集或归类，则适用强制性规则。如果任一参数是二进制字符串，则这些参数将以区分大小写的方式作为二进制字符串进行处理。
> REGEXP 和 RLIKE 运算符以字节方式工作，因此它们不是多字节安全的，并且可能会产生多字节字符集的意外结果。此外，这些运算符通过字符的字节值和重音字符比较字符可能不相等，即使给定的排序规则将它们视为相等。

* expr NOT REGEXP pat, expr NOT RLIKE pat
与 NOT (expr REGEXP pat) 相同

[正则表达式](https://dev.mysql.com/doc/refman/5.7/en/regexp.html)
正则表达式描述一组字符串。最简单的正则表达式是其中没有特殊字符的正则表达式。例如，正则表达式 hello 只匹配 hello 而不是其他任何内容。
非平凡的正则表达式使用某些特殊的结构，以便它们可以匹配多个字符串。例如，正则表达式 `hello|world` 包含 `|`交替运算符并匹配 hello 或 world。
作为一个更复杂的示例，正则表达式 `B[an]*s` 匹配任何字符串 Bananas、Baaaaas、Bs 以及任何其他以 B 开头、以 s 结尾并包含任意数量的 a 或 n 个字符的字符串之间。

REGEXP 运算符的正则表达式可以使用以下任何特殊字符和结构：
* `^`，匹配字符串开头
* `$`，匹配字符串结尾
* `.`，匹配任何字符（包括回车和换行）
* `*`，匹配0个或多个
* `+`，匹配1个或多个
* `?`，匹配0个或1个
* `|`，交替
* `()`，将内容看成一个整体
* `{}`，表示重复，支持范围，必须在 0 到 RE_DUP_MAX（默认 255）的范围，例：`{1}`，`{2,}`，`{3,4}`
* `[]`, `[^]`，匹配字符集（`[^]`表示不匹配字符集），支持使用`-`表示范围，例：`[0-9]`，`[^a-z]`
* `[..]`，匹配该整理元素的字符序列。 characters 是单个字符或字符名称，如换行符。下表列出了允许的字符名称。
* `[==]`，它匹配具有相同排序规则值的所有字符，包括它自己。例如，如果 o 和 (+) 是等价类的成员，则 `[[=o=]]`、`[[=(+)=]]` 和 `[o(+)]` 都是同义词。等价类不能用作范围的端点。
* `[::]`，表示匹配属于该类的所有字符的字符类
* `[[:<:]]`, `[[:>:]]`，表示单词词首词尾

对于接受字符串输入并返回字符串结果作为输出的简单函数，输出的字符集和排序规则与主要输入值的字符集和排序规则相同。例如，UPPER(X) 返回与 X 具有相同字符串和排序规则的字符串。这同样适用于 INSTR()、LCASE()、LOWER()、LTRIM()、MID()、REPEAT()、REPLACE( )、REVERSE()、RIGHT()、RPAD()、RTRIM()、SOUNDEX()、SUBSTRING()、TRIM()、UCASE() 和 UPPER()。
如果字符串输入或函数结果是二进制字符串，则该字符串具有二进制字符集和排序规则。这可以通过使用 CHARSET() 和 COLLATION() 函数来检查，这两个函数都为二进制字符串参数返回二进制。


常用函数

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

全文本搜索
MATCH (col1,col2,...) AGAINST (expr [search_modifier])
```sql
search_modifier:
  {
       IN NATURAL LANGUAGE MODE
     | IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION
     | IN BOOLEAN MODE
     | WITH QUERY EXPANSION
  }
```

MySQL 支持全文索引和搜索：

* MySQL 中的全文索引是 FULLTEXT 类型的索引。
* 全文索引只能用于 InnoDB 或 MyISAM 表，并且只能为 CHAR、VARCHAR 或 TEXT 列创建。
* MySQL 提供了一个内置的支持中文、日语和韩语 (CJK) 的全文 ngram 解析器，以及一个可安装的用于日语的 MeCab 全文解析器插件。
* 创建表时，可以在 CREATE TABLE 语句中给出 FULLTEXT 索引定义，或者稍后使用 ALTER TABLE 或 CREATE INDEX 添加。
* 对于大型数据集，将数据加载到没有 FULLTEXT 索引的表中然后创建索引比将数据加载到具有现有 FULLTEXT 索引的表中要快得多。

全文搜索是使用 MATCH() AGAINST() 语法执行的。 MATCH() 采用逗号分隔的列表来命名要搜索的列。 AGAINST 接受一个要搜索的字符串，以及一个可选的修饰符，指示要执行的搜索类型。搜索字符串必须是在查询评估期间保持不变的字符串值。例如，这排除了表列，因为每行可能不同。

全文搜索分为三种类型：
* 自然语言搜索将搜索字符串解释为自然人类语言中的短语（自由文本中的短语）。没有特殊的运算符，双引号 (") 字符除外。停用词列表适用。
如果给出了 IN NATURAL LANGUAGE MODE 修饰符或没有给出修饰符，则全文搜索是自然语言搜索。
* 布尔搜索使用特殊查询语言的规则解释搜索字符串。该字符串包含要搜索的词。它还可以包含指定要求的运算符，例如匹配行中必须存在或不存在单词，或者它的权重应该比平常高或低。某些常用词（停用词）从搜索索引中省略，如果出现在搜索字符串中则不匹配。 IN BOOLEAN MODE 修饰符指定布尔搜索。
* 查询扩展搜索是自然语言搜索的修改。搜索字符串用于执行自然语言搜索。然后将搜索返回的最相关行中的词添加到搜索字符串中，然后再次进行搜索。查询返回来自第二次搜索的行。 IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION 或 WITH QUERY EXPANSION 修饰符指定查询扩展搜索。



### 日期函数
注意事项：
* 在查询执行开始时，每个返回当前日期或时间的函数只对每个查询求值一次。这意味着在单个查询中对函数（例如 NOW()）的多次引用始终会产生相同的结果。 （单个查询还包括对存储程序（存储例程、触发器或事件）的调用以及该程序调用的所有子程序。）此原则也适用于 CURDATE()、CURTIME()、UTC_DATE() 、UTC_TIME()、UTC_TIMESTAMP() 以及它们的任何同义词。
* CURRENT_TIMESTAMP()、CURRENT_TIME()、CURRENT_DATE() 和 FROM_UNIXTIME() 函数返回当前会话时区中的值，该时区可用作 time_zone 系统变量的会话值。此外，UNIX_TIMESTAMP() 假定其参数是会话时区中的日期时间值。
* 几个函数在传递 DATE() 函数值作为参数时是严格的，并拒绝日部分为零的不完整日期：CONVERT_TZ()、DATE_ADD()、DATE_SUB()、DAYOFYEAR()、TIMESTAMPDIFF()、TO_DAYS()、 TO_SECONDS()、WEEK()、WEEKDAY()、WEEKOFYEAR()、YEARWEEK()。
* 支持 TIME、DATETIME 和 TIMESTAMP 值的小数秒，精度可达微秒。采用时间参数的函数接受带有小数秒的值。时间函数的返回值包括适当的小数秒。
由于 MySQL 允许存储不完整的日期，例如“2014-00-00”，因此月份和日期说明符的范围从零开始。


常用函数

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

时间格式化，使用于函数date_format()

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
|`%%` | %字符 |
|`%x` | x, 对应上面未列出的x |

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
聚合函数对值集进行操作。它们通常与 GROUP BY 子句一起使用以将值分组到子集中。
[聚合函数列表](https://dev.mysql.com/doc/refman/5.7/en/aggregate-functions.html)

常用聚合函数

| 函数      | 含义    |
| --------- | -------- |
|`avg(x)` |           返回指定列的平均值|
|`count(x)` |         返回指定列中非null值的个数|
|`min(x)` |           返回指定列的最小值|
|`max(x)` |           返回指定列的最大值|
|`sum(x)` |           返回指定列的所有值之和|
|`group_concat(x)` |  返回由属于一组的列值连接组合而成的结果|


除非另有说明，聚合函数忽略 NULL 值。
如果在不包含 GROUP BY 子句的语句中使用聚合函数，则相当于对所有行进行分组。
对于数字参数，方差和标准差函数返回 DOUBLE 值。 SUM() 和 AVG() 函数为精确值参数（整数或 DECIMAL）返回 DECIMAL 值，为近似值参数（FLOAT 或 DOUBLE）返回 DOUBLE 值。
SUM() 和 AVG() 聚合函数不适用于时间值。 （他们将值转换为数字，在第一个非数字字符之后丢失所有内容。）要解决此问题，请转换为数字单位，执行聚合操作，然后转换回时间值。
SUM() 或 AVG() 等需要数字参数的函数在必要时将参数转换为数字。对于 SET 或 ENUM 值，转换操作会导致使用基础数值。

BIT_AND()、BIT_OR() 和 BIT_XOR() 聚合函数执行位运算。它们需要 BIGINT（64 位整数）参数并返回 BIGINT 值。其他类型的参数将转换为 BIGINT 并且可能会发生截断。

### 流程控制函数（Flow Control Functions）

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

## 变量

[局部变量文档](https://dev.mysql.com/doc/refman/5.7/en/local-variable-scope.html)
[用户定义变量文档](https://dev.mysql.com/doc/refman/5.7/en/user-variables.html)
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


# 基础篇-SQL
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

## 数据定义语句（Data Definition Statements）
Data Definition Statements 定义相关结构，包括：数据库（DATABASE）、数据表（TABLE）、索引（INDEX）、存储过程（PROCEDURE）、方法（FUNCTION）、视图（VIEW）、事件（EVENT）、触发器（TRIGGER）等。

### 数据库（DATABASE）

相关操作语法
```sql
-- 创建
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [create_specification] ...

create_specification:
    [DEFAULT] CHARACTER SET [=] charset_name
  | [DEFAULT] COLLATE [=] collation_name

-- 修改
ALTER {DATABASE | SCHEMA} [db_name]
    alter_option ...
ALTER {DATABASE | SCHEMA} db_name
    UPGRADE DATA DIRECTORY NAME

alter_option: {
    [DEFAULT] CHARACTER SET [=] charset_name
  | [DEFAULT] COLLATE [=] collation_name
}

-- 删除
DROP {DATABASE | SCHEMA} [IF EXISTS] db_name

-- 查看
SHOW CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
```


### 数据表（TABLE）
相关操作语法
```sql
-- 创建
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

-- 修改
ALTER TABLE tbl_name
    [alter_option [, alter_option] ...]
    [partition_options]

RENAME TABLE
    tbl_name TO new_tbl_name
    [, tbl_name2 TO new_tbl_name2] ...

-- 删除
DROP [TEMPORARY] TABLE [IF EXISTS]
    tbl_name [, tbl_name] ...
    [RESTRICT | CASCADE]

-- 查看
SHOW CREATE TABLE tbl_name
```

[创建数据表文档](https://dev.mysql.com/doc/refman/5.7/en/create-table.html)

#### 约束（CONSTRAINT）
在 MySQL 中，主要支持以下 6 种约束：
* 主键约束 主键约束是使用最频繁的约束。在设计数据表时，一般情况下，都会要求表中设置一个主键。主键是表的一个特殊字段，该字段能唯一标识该表中的每条信息。主键不能包含空值
* 外键约束 外键约束经常和主键约束一起使用，用来确保数据的一致性。
* 唯一约束 唯一约束与主键约束有一个相似的地方，就是它们都能够确保列的唯一性。与主键约束不同的是，唯一约束在一个表中可以有多个，并且设置唯一约束的列是允许有空值的，虽然只能有一个空值。
* 检查约束 检查约束是用来检查数据表中，字段值是否有效的一个手段。
* 非空约束 非空约束用来约束表中的字段不能为空。例如，在学生信息表中，如果不添加学生姓名，那么这条记录是没有用的。
* 默认值约束 默认值约束用来约束当数据表中某个字段不输入值时，自动为其添加一个已经设置好的值。

以上 6 种约束中，一个数据表中只能有一个主键约束，其它约束可以有多个。

### 索引（INDEX）
通常，在使用 CREATE TABLE 创建表本身时，您会在表上创建所有索引。该准则对于 InnoDB 表尤其重要，其中主键决定了数据文件中行的物理布局。 CREATE INDEX 使您能够向现有表添加索引。CREATE INDEX 映射到 ALTER TABLE 语句以创建索引。 CREATE INDEX 不能用于创建 PRIMARY KEY；请改用 ALTER TABLE。InnoDB 支持虚拟列上的二级索引。启用 innodb_stats_persistent 设置后，在 InnoDB 表上创建索引后运行 ANALYZE TABLE 语句。


相关操作语法
```sql
-- 创建
CREATE [UNIQUE | FULLTEXT | SPATIAL] INDEX index_name
    [index_type]
    ON tbl_name (key_part,...)
    [index_option]
    [algorithm_option | lock_option] ...

-- 修改
-- 索引不支持修改只能删除重建

-- 删除
DROP INDEX index_name ON tbl_name
    [algorithm_option | lock_option] ...

algorithm_option:
    ALGORITHM [=] {DEFAULT | INPLACE | COPY}

lock_option:
    LOCK [=] {DEFAULT | NONE | SHARED | EXCLUSIVE}

-- 查看
SHOW {INDEX | INDEXES | KEYS}
    {FROM | IN} tbl_name
    [{FROM | IN} db_name]
    [WHERE expr]
```

### 存储过程和函数（PROCEDURE AND FUNCTION）
[存储过程文档](https://dev.mysql.com/doc/refman/5.7/en/stored-routines.html)
MySQL 支持存储例程（stored routines，过程和函数（procedures and functions））。存储例程是一组可以存储在服务器中的 SQL 语句。完成此操作后，客户无需继续重新发出单独的语句，而是可以参考存储的例程。

相关操作语法
```sql
-- 创建
CREATE
    [DEFINER = user]
    PROCEDURE sp_name ([proc_parameter[,...]])
    [characteristic ...] routine_body

CREATE
    [DEFINER = user]
    FUNCTION sp_name ([func_parameter[,...]])
    RETURNS type
    [characteristic ...] routine_body

-- 修改
ALTER PROCEDURE proc_name [characteristic ...]

ALTER FUNCTION func_name [characteristic ...]

characteristic: {
    COMMENT 'string'
  | LANGUAGE SQL
  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
  | SQL SECURITY { DEFINER | INVOKER }
}

-- 删除
DROP {PROCEDURE | FUNCTION} [IF EXISTS] sp_name

-- 查看
SHOW {PROCEDURE | FUNCTION} STATUS
    [LIKE 'pattern' | WHERE expr]
```

### 视图（VIEW）
[视图文档](https://dev.mysql.com/doc/refman/5.7/en/views.html)
视图是存储的查询，调用时会产生结果集。视图充当虚拟表，相当于预查询。

相关操作语法
```sql
-- 创建
CREATE
    [OR REPLACE]
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = user]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION]

-- 修改
ALTER
    [ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
    [DEFINER = user]
    [SQL SECURITY { DEFINER | INVOKER }]
    VIEW view_name [(column_list)]
    AS select_statement
    [WITH [CASCADED | LOCAL] CHECK OPTION]

-- 删除
DROP VIEW [IF EXISTS]
    view_name [, view_name] ...
    [RESTRICT | CASCADE]

-- 查看
SHOW CREATE VIEW view_name
```

### 事件（EVENT）
[事件文档](https://dev.mysql.com/doc/refman/5.7/en/event-scheduler.html)
事件用于定时触发sql语句

相关操作语法
```sql
-- 创建
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

-- 修改
ALTER
    [DEFINER = user]
    EVENT event_name
    [ON SCHEDULE schedule]
    [ON COMPLETION [NOT] PRESERVE]
    [RENAME TO new_event_name]
    [ENABLE | DISABLE | DISABLE ON SLAVE]
    [COMMENT 'string']
    [DO event_body]

-- 删除
DROP EVENT [IF EXISTS] event_name

-- 查看
SHOW CREATE EVENT event_name
```

### 触发器（TRIGGER）
[触发器文档](https://dev.mysql.com/doc/refman/5.7/en/trigger-syntax.html)
触发器是与表关联的命名数据库对象，当表发生特定事件时激活。触发器与名为 tbl_name 的表相关联，该表必须引用永久表。您不能将触发器与 TEMPORARY 表或视图相关联。
触发器名称存在于schema命名空间中，这意味着所有触发器在模式中必须具有唯一名称。不同模式中的触发器可以具有相同的名称。

trigger_event 指示激活触发器的操作类型。这些 trigger_event 值是允许的：
* INSERT：只要有新行插入表中（例如，通过 INSERT、LOAD DATA 和 REPLACE 语句），触发器就会激活。
* UPDATE：只要一行被修改（例如，通过 UPDATE 语句），触发器就会激活。
* DELETE：只要从表中删除一行（例如，通过 DELETE 和 REPLACE 语句），触发器就会激活。表上的 DROP TABLE 和 TRUNCATE TABLE 语句不会激活此触发器，因为它们不使用 DELETE。删除分区也不会激活 DELETE 触发器。


相关操作语法
```sql
-- 创建
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

-- 修改
-- 触发器不支持修改

-- 删除
DROP TRIGGER [IF EXISTS] [schema_name.]trigger_name

-- 查看
SHOW CREATE TRIGGER trigger_name
```


## 数据操作语句（Data Manipulation Statements）
### 插入（INSERT）
```sql
INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    {VALUES | VALUE} (value_list) [, (value_list)] ...
    [ON DUPLICATE KEY UPDATE assignment_list]

INSERT [LOW_PRIORITY | DELAYED | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    SET assignment_list
    [ON DUPLICATE KEY UPDATE assignment_list]

INSERT [LOW_PRIORITY | HIGH_PRIORITY] [IGNORE]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    SELECT ...
    [ON DUPLICATE KEY UPDATE assignment_list]
```

INSERT 将新行插入到现有表中。 INSERT ... VALUES 和 INSERT ... SET 语句的形式根据明确指定的值插入行。 INSERT ... SELECT 形式插入从另一个表或多个表中选择的行。如果要插入的行会导致 UNIQUE 索引或 PRIMARY KEY 中出现重复值，则带有 ON DUPLICATE KEY UPDATE 子句的 INSERT 可以更新现有行。
插入表需要表的 INSERT 权限。
如果使用 ON DUPLICATE KEY UPDATE 子句并且重复键导致执行更新，则该语句需要更新列的更新权限。对于读取但未修改的列，您只需要 SELECT 特权（例如，对于仅在 ON DUPLICATE KEY UPDATE 子句中的 col_name=expr 赋值右侧引用的列）。
插入分区表时，您可以控制哪些分区和子分区接受新行。 PARTITION 子句采用表的一个或多个分区或子分区（或两者）的逗号分隔名称列表。如果给定 INSERT 语句要插入的任何行与列出的分区之一不匹配，INSERT 语句将失败并显示错误 Found a row not matching the given partition set。

### 替换（REPLACE）
```sql
REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    {VALUES | VALUE} (value_list) [, (value_list)] ...

REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    SET assignment_list

REPLACE [LOW_PRIORITY | DELAYED]
    [INTO] tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [(col_name [, col_name] ...)]
    SELECT ...
```

REPLACE 的工作方式与 INSERT 完全相同，只是如果表中的旧行与 PRIMARY KEY 或 UNIQUE 索引的新行具有相同的值，则在插入新行之前删除旧行。
仅当表具有 PRIMARY KEY 或 UNIQUE 索引时，REPLACE 才有意义。否则，它等同于 INSERT，因为没有索引可用于确定新行是否与另一行重复。

所有列的值都取自 REPLACE 语句中指定的值。任何缺失的列都设置为其默认值，就像 INSERT 一样。您不能引用当前行中的值并在新行中使用它们。如果您使用诸如 SET col_name = col_name + 1 之类的赋值，对右侧列名的引用将被视为 DEFAULT(col_name)，因此该赋值等同于 SET col_name = DEFAULT(col_name) + 1。

REPLACE 语句返回一个计数以指示受影响的行数。这是删除和插入的行的总和。如果单行 REPLACE 的计数为 1，则表示插入了一行并且没有删除任何行。如果计数大于 1，则在插入新行之前删除了一个或多个旧行。如果表包含多个唯一索引并且新行重复不同唯一索引中不同旧行的值，则单个行可能会替换多个旧行。

您不能替换为表并从子查询中的同一个表中进行选择。

MySQL 使用以下算法进行 REPLACE（和 LOAD DATA ... REPLACE）：
* 尝试将新行插入表中
* 当主键或唯一索引发生重复键错误导致插入失败时：
	- 从表中删除具有重复键值的冲突行
	- 再次尝试将新行插入表中

因为 REPLACE ... SELECT 语句的结果取决于 SELECT 中的行的顺序，并且不能始终保证此顺序，所以在记录这些语句时，源和副本可能会出现分歧。因此，REPLACE ... SELECT 语句被标记为对基于语句的复制不安全。此类语句在使用基于语句的模式时会在错误日志中产生警告，而在使用 MIXED 模式时会使用基于行的格式写入二进制日志。


### 修改（UPDATE）
```sql
Single-table syntax:
UPDATE [LOW_PRIORITY] [IGNORE] table_reference
    SET assignment_list
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
    SET assignment_list
    [WHERE where_condition]
```

UPDATE 是修改表中行的 DML 语句。
对于单表语法，UPDATE 语句用新值更新命名表中现有行的列。 SET 子句指示要修改哪些列以及应赋予它们的值。每个值都可以作为表达式或关键字 DEFAULT 给出，以将列显式设置为其默认值。 WHERE 子句（如果给定）指定标识要更新的行的条件。如果没有 WHERE 子句，所有行都会更新。如果指定了 ORDER BY 子句，则按照指定的顺序更新行。 LIMIT 子句限制了可以更新的行数。
对于多表语法，UPDATE 更新 table_references 中命名的每个表中满足条件的行。每个匹配行都会更新一次，即使它多次匹配条件也是如此。对于多表语法，不能使用 ORDER BY 和 LIMIT。
对于分区表，此语句的单表和多表形式都支持使用 PARTITION 子句作为表引用的一部分。此选项采用一个或多个分区或子分区（或两者）的列表。仅检查列出的分区（或子分区）是否匹配，并且不更新不在任何这些分区或子分区中的行，无论它是否满足 where_condition。

### 删除（DELETE）
```sql
Single-Table Syntax:
DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]


Multiple-Table Syntax:
DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    tbl_name[.*] [, tbl_name[.*]] ...
    FROM table_references
    [WHERE where_condition]

DELETE [LOW_PRIORITY] [QUICK] [IGNORE]
    FROM tbl_name[.*] [, tbl_name[.*]] ...
    USING table_references
    [WHERE where_condition]


TRUNCATE [TABLE] tbl_name
```

DELETE 是从表中删除行的 DML 语句。
DELETE 语句从 tbl_name 中删除行并返回删除的行数。
可选 WHERE 子句中的条件标识要删除的行。如果没有 WHERE 子句，所有行都将被删除。
where_condition 是一个表达式，对于要删除的每一行计算结果为真。
如果指定了 ORDER BY 子句，则按照指定的顺序删除行。 LIMIT 子句限制了可以删除的行数。这些子句适用于单表删除，但不适用于多表删除。


TRUNCATE TABLE 语句是一种比不带 WHERE 子句的 DELETE 语句更快的清空表的方法。与 DELETE 不同，TRUNCATE TABLE 不能在事务中使用，也不能在表上有锁的情况下使用。


### 查找（SELECT）
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
```

SELECT 用于检索从一个或多个表中选择的行，并且可以包括 UNION 语句和子查询，还可用于检索未引用任何表而计算的行。
SELECT 语句中最常用的子句是：
* 每个 select_expr 表示您要检索的列。必须至少有一个 select_expr。
* table_references 指示要从中检索行的一个或多个表。
* SELECT 支持使用 PARTITION 子句和 table_reference 中表名后面的分区或子分区（或两者）列表的显式分区选择。在这种情况下，仅从列出的分区中选择行，而忽略表的任何其他分区。SELECT ... PARTITION 从使用存储引擎（例如执行表级锁（因此分区锁）的 MyISAM）的表中，仅锁定由 PARTITION 选项命名的分区或子分区。
* WHERE 子句（如果给定）指示要选择行必须满足的一个或多个条件。 where_condition 是一个表达式，对于要选择的每一行计算结果为真。如果没有 WHERE 子句，该语句将选择所有行。在 WHERE 表达式中，您可以使用 MySQL 支持的任何函数和运算符，但聚合（组）函数除外。

子句的顺序必须是上述所列，子句含义如下：
* FROM，指示要从中检索行的一个或多个表
* WHERE，子句指定选择列表中列的条件，但不能引用聚合函数。
* GROUP BY，将查询结果分组
* HAVING，HAVING 子句与 WHERE 子句一样，指定选择条件。HAVING 子句指定组的条件，通常由 GROUP BY 子句构成。查询结果只包含满足HAVING条件的组。（如果不存在 GROUP BY，则所有行隐式构成一个聚合组。）
* ORDER BY，将查询结果排序
* LIMIT，设置最大返回行数


修饰符：
* ALL 和 DISTINCT 修饰符指定是否应返回重复行。 ALL（默认值）指定应返回所有匹配行，包括重复行。 DISTINCT 指定从结果集中删除重复行。同时指定两个修饰符是错误的。 DISTINCTROW 是 DISTINCT 的同义词。
* 可以使用 AS alias_name 为 select_expr 指定一个别名。别名用作表达式的列名，可用于 GROUP BY、ORDER BY 或 HAVING 子句中。
* 如果将 FOR UPDATE 与使用页锁或行锁的存储引擎一起使用，则查询检查的行将被写锁定，直到当前事务结束。
使用 LOCK IN SHARE MODE 设置共享锁，允许其他事务读取检查的行但不能更新或删除它们。
* HIGH_PRIORITY 赋予 SELECT 比更新表的语句更高的优先级。您应该仅将此用于非常快且必须立即完成的查询。在表被锁定以供读取时发出的 SELECT HIGH_PRIORITY 查询会运行，即使有更新语句正在等待表空闲也是如此。这只会影响仅使用表级锁定的存储引擎（例如 MyISAM、MEMORY 和 MERGE）。HIGH_PRIORITY 不能与作为 UNION 一部分的 SELECT 语句一起使用。
* STRAIGHT_JOIN 强制优化器按照它们在 FROM 子句中列出的顺序连接表。如果优化器以非最佳顺序连接表，您可以使用它来加速查询。 STRAIGHT_JOIN 也可以用在 table_references 列表中。
* SQL_BUFFER_RESULT 强制将结果放入临时表中。这有助于 MySQL 尽早释放表锁，并在需要很长时间才能将结果集发送到客户端的情况下提供帮助。此修饰符只能用于顶级 SELECT 语句，不能用于子查询或 UNION 之后。
* SQL_CALC_FOUND_ROWS 告诉 MySQL 计算结果集中有多少行，忽略任何 LIMIT 子句。然后可以使用 SELECT FOUND_ROWS() 检索行数。


#### 查询输出（SELECT INTO）
SELECT ... INTO 形式的 SELECT 使查询结果可以存储在变量中或写入文件：
* SELECT ... INTO var_list 选择列值并将它们存储到变量中。
* SELECT ... INTO OUTFILE 将选定的行写入文件。可以指定列和行终止符以生成特定的输出格式。
* SELECT ... INTO DUMPFILE 将一行不带任何格式地写入文件。


#### 连接查询（JOIN）
MySQL 支持 SELECT 语句和多表 DELETE 和 UPDATE 语句的 table_references 部分的以下 JOIN 语法：

```sql
table_reference: {
    table_factor
  | joined_table
}

table_factor: {
    tbl_name [PARTITION (partition_names)]
        [[AS] alias] [index_hint_list]
  | table_subquery [AS] alias
  | ( table_references )
}

joined_table: {
    table_reference [INNER | CROSS] JOIN table_factor [join_specification]
  | table_reference STRAIGHT_JOIN table_factor
  | table_reference STRAIGHT_JOIN table_factor ON search_condition
  | table_reference {LEFT|RIGHT} [OUTER] JOIN table_reference join_specification
  | table_reference NATURAL [{LEFT|RIGHT} [OUTER]] JOIN table_factor
}

join_specification: {
    ON search_condition
  | USING (join_column_list)
}

index_hint_list:
    index_hint [, index_hint] ...

index_hint: {
    USE {INDEX|KEY}
      [FOR {JOIN|ORDER BY|GROUP BY}] ([index_list])
  | {IGNORE|FORCE} {INDEX|KEY}
      [FOR {JOIN|ORDER BY|GROUP BY}] (index_list)
}
```

在 MySQL 中，JOIN、CROSS JOIN 和 INNER JOIN 是句法等价物（它们可以相互替换）。在标准 SQL 中，它们是不等价的。 INNER JOIN 与 ON 子句一起使用，否则使用 CROSS JOIN。可以指定索引提示来影响 MySQL 优化器如何使用索引。优化器提示和 optimizer_switch 系统变量是影响优化器使用索引的其他方法。
以下列表描述了编写JOIN时要考虑的一般因素：
* 可以使用 tbl_name AS alias_name 或 tbl_name alias_name 为表引用起别名
* table_subquery 在 FROM 子句中也称为派生表或子查询。这样的子查询必须包含一个别名来给子查询结果一个表名。
* 单个连接中可以引用的最大表数为 61。这包括通过将 FROM 子句中的派生表和视图合并到外部查询块中处理的连接。
* INNER JOIN 和逗号在没有连接条件的情况下在语义上是等效的：两者都在指定的表之间产生笛卡尔积（即，第一个表中的每一行都连接到第二个表中的每一行)。但是逗号运算符的优先级低于INNER JOIN、CROSS JOIN、LEFT JOIN等。如果在存在连接条件时将逗号连接与其他连接类型混合使用，则可能会出现“on 子句”中未知列“col_name”形式的错误。
* 与 ON 一起使用的 search_condition 是可以在 WHERE 子句中使用的任何形式的条件表达式。通常，ON 子句用于指定如何连接表的条件，而 WHERE 子句限制要包含在结果集中的行。
* 如果在 LEFT JOIN 的 ON 或 USING 部分中没有右表的匹配行，则将所有列都设置为 NULL 的行用于右表。您可以使用此事实在一个表中查找在另一个表中没有对应项的行。
* USING(join_column_list) 子句命名必须存在于两个表中的列列表。如果表 a 和 b 都包含列 c1、c2 和 c3，则以下连接比较两个表中的相应列。
* 两个表的 NATURAL [LEFT] JOIN 被定义为在语义上等同于 INNER JOIN 或 LEFT JOIN，其中 USING 子句命名存在于两个表中的所有列。
* RIGHT JOIN 的工作方式类似于 LEFT JOIN。为了保持代码在数据库之间的可移植性，建议您使用 LEFT JOIN 而不是 RIGHT JOIN。
* STRAIGHT_JOIN 与 JOIN 类似，只是左表总是先于右表读取。这可用于连接优化器以次优顺序处理表的那些（少数）情况。

#### 联合查询（UNION）
```sql
SELECT ...
UNION [ALL | DISTINCT] SELECT ...
[UNION [ALL | DISTINCT] SELECT ...]
```

UNION 将多个 SELECT 语句的结果组合成一个结果集。

特性：
* UNION 结果集的列名取自第一个 SELECT 语句的列名。
* 每个 SELECT 语句相应位置列出的选定列应具有相同的数据类型。例如，第一个语句选择的第一列应该与其他语句选择的第一列具有相同的类型。如果相应 SELECT 列的数据类型不匹配，则 UNION 结果中列的类型和长度会考虑所有 SELECT 语句检索的值。
* 默认情况下，从 UNION 结果中删除重复的行。可选的 DISTINCT 关键字具有相同的效果，但使其显式化。使用可选的 ALL 关键字，不会发生重复行删除，结果包括来自所有 SELECT 语句的所有匹配行。您可以在同一个查询中混合使用 UNION ALL 和 UNION DISTINCT。处理混合 UNION 类型时，DISTINCT 联合会覆盖其左侧的任何 ALL 联合。可以使用 UNION DISTINCT 显式生成 DISTINCT 联合，也可以使用不带后续 DISTINCT 或 ALL 关键字的 UNION 隐式生成 DISTINCT 联合。
* 要将 ORDER BY 或 LIMIT 子句应用于单个 SELECT，请将 SELECT 括起来并将子句放在括号内。
* 对单个 SELECT 语句使用 ORDER BY 并不意味着行在最终结果中出现的顺序，因为默认情况下 UNION 会生成一组无序的行。因此，此上下文中的 ORDER BY 通常与 LIMIT 结合使用，以确定要为 SELECT 检索的所选行的子集，即使它不一定会影响最终 UNION 结果中这些行的顺序。如果在 SELECT 中出现没有 LIMIT 的 ORDER BY，它会被优化掉，因为它没有效果。
* 要使用 ORDER BY 或 LIMIT 子句对整个 UNION 结果进行排序或限制，请将各个 SELECT 语句括起来并将 ORDER BY 或 LIMIT 放在最后一个语句之后。


在 UNION 中，SELECT 语句是普通的 select 语句，但有以下限制：
* 第一个 SELECT 中的 HIGH_PRIORITY 无效。任何后续 SELECT 中的 HIGH_PRIORITY 都会产生语法错误。
* 只有最后一个 SELECT 语句可以使用 INTO 子句。但是，整个 UNION 结果将写入 INTO 输出目标。

#### 子查询（Subqueries）
子查询是另一个语句中的 SELECT 语句。
语法示例：
```sql
SELECT * FROM t1 WHERE column1 = (SELECT column1 FROM t2);
```
在此示例中，SELECT * FROM t1 ... 是外部查询（或外部语句），而 (SELECT column1 FROM t2) 是子查询。我们说子查询嵌套在外层查询中，实际上可以将子查询嵌套在其他子查询中，嵌套到相当深的深度。子查询必须始终出现在括号内。

子查询的主要优点是：
* 它们允许结构化的查询，以便可以隔离语句的每个部分。
* 它们提供了执行操作的替代方法，否则这些操作将需要复杂的连接和联合。
* 许多人发现子查询比复杂的连接或联合更具可读性。事实上，正是子查询的创新让人们产生了将早期的 SQL 称为“结构化查询语言”的最初想法。

子查询可以返回标量（单个值）、单行、单列或表（一列或多列的一行或多行）。这些称为标量、列、行和表子查询。返回特定类型结果的子查询通常只能在特定上下文中使用。
* 对可以使用子查询的语句类型几乎没有限制。子查询可以包含普通 SELECT 可以包含的许多关键字或子句：DISTINCT、GROUP BY、ORDER BY、LIMIT、连接、索引提示、UNION 结构、注释、函数等。
* 子查询的外部语句可以是以下任何一种：SELECT、INSERT、UPDATE、DELETE、SET 或 DO。
* 在 MySQL 中，您不能修改表并从子查询中的同一个表中进行选择。这适用于 DELETE、INSERT、REPLACE、UPDATE 和（因为可以在 SET 子句中使用子查询）LOAD DATA 等语句。


##### 子查询比较（COMPLARE）
```sql
non_subquery_operand comparison_operator (subquery)
non_subquery_operand LIKE (subquery)

comparison_operator:
=  >  <  >=  <=  <>  !=  <=>
```

为了将子查询与标量进行比较，子查询必须返回一个标量。对于子查询与行构造函数的比较，子查询必须是行子查询，它返回具有与行构造函数相同数量的值的行。


##### 子查询批量比较(COMPLARE ROW)
```sql
operand comparison_operator ANY (subquery)
operand IN (subquery)
operand comparison_operator SOME (subquery)
operand comparison_operator ALL (subquery)

comparison_operator:
=  >  <  >=  <=  <>  !=
```

ANY 关键字必须跟在比较运算符之后，表示“如果子查询返回的列中的任何值的比较结果为真，则返回真”。
当与子查询一起使用时，单词 IN 是 = ANY 的别名。因此，这两个语句是相同的。
IN 和 = ANY 在与表达式列表一起使用时不是同义词。 IN 可以采用表达式列表，但 = ANY 不能。
NOT IN 不是<> ANY 的别名，而是<> ALL 的别名。
SOME 这个词是 ANY 的别名。因此，这两个语句是相同的。
ALL 一词必须跟在比较运算符之后，表示“如果子查询返回的列中的所有值的比较结果为 TRUE，则返回 TRUE”。

##### 行子查询（ROW）
标量或列子查询返回单个值或一列值。行子查询是一种子查询变体，它返回单行，因此可以返回多个列值。行子查询最多只能返回一行。
行子查询比较的合法运算符是：
```sql
=  >  <  >=  <=  <>  !=  <=>
```

行子查询返回的结果可以用ROW修饰，ROW不能修饰单列返回，例如：
```sql
SELECT * FROM t1
  WHERE (col1,col2) = (SELECT col3, col4 FROM t2 WHERE id = 10);
SELECT * FROM t1
  WHERE ROW(col1,col2) = (SELECT col3, col4 FROM t2 WHERE id = 10);

SELECT * FROM t1 WHERE ROW(1) = (SELECT column1 FROM t2); -- 错误
```

##### 存在子查询（EXIST）
如果子查询返回任何行，则 EXISTS 子查询为 TRUE，NOT EXISTS 子查询为 FALSE。例如：
传统上，EXISTS 子查询以 SELECT * 开头，但它可以以 SELECT 5 或 SELECT column1 或任何其他内容开头。 MySQL 忽略此类子查询中的 SELECT 列表，因此没有区别。
对于前面的示例，如果 t2 包含任何行，甚至只有 NULL 值的行，则 EXISTS 条件为 TRUE。这实际上是一个不太可能的例子，因为 [NOT] EXISTS 子查询几乎总是包含相关性。

##### 相关子查询（Correlated Subqueries）
相关子查询是包含对也出现在外部查询中的表的引用的子查询。例如：
```sql
SELECT * FROM t1
  WHERE column1 = ANY (SELECT column1 FROM t2
                       WHERE t2.column2 = t1.column2);
```

请注意，子查询包含对 t1 列的引用，即使子查询的 FROM 子句未提及表 t1。因此，MySQL 在子查询之外查找，并在外部查询中找到 t1。

作用域规则：MySQL 从内到外计算。例如：
```sql
SELECT column1 FROM t1 AS x
  WHERE x.column1 = (SELECT column1 FROM t2 AS x
    WHERE x.column1 = (SELECT column1 FROM t3
      WHERE x.column2 = t3.column1));
```

内部x重命名外部x，在子查询中x表示t2的列，在主查询中x表示t1的列。
对于 HAVING 或 ORDER BY 子句中的子查询，MySQL 还会在外部选择列表中查找列名。
相关子查询中的聚合函数可能包含外部引用，前提是该函数只包含外部引用，并且该函数不包含在另一个函数或表达式中。

##### 派生表（Derived Tables）
派生表是在查询 FROM 子句的范围内生成表的表达式。例如，SELECT 语句 FROM 子句中的子查询是派生表：
```sql
SELECT ... FROM (subquery) [AS] tbl_name ...
```

[AS] tbl_name 子句是必需的，因为 FROM 子句中的每个表都必须有一个名称。派生表中的任何列都必须具有唯一的名称。
子查询中使用的列名在外部查询中可以访问。
派生表可以返回标量、列、行或表。

派生表受以下限制：
* 派生表不能是相关子查询。
* 派生表不能包含对同一 SELECT 的其他表的引用。
* 派生表不能包含外部引用。这是 MySQL 的限制，而不是 SQL 标准的限制。


##### 子查询错误（Subquery Errors）
有一些错误仅适用于子查询：
* Unsupported subquery syntax，不支持的子查询语法
* Incorrect number of columns from subquery，子查询列数不对
* Incorrect number of rows from subquery，子查询行数不对
* Incorrectly used table in subquery，子查询使用错误的表

对于事务性存储引擎，子查询失败会导致整个语句失败。对于非事务性存储引擎，会保留在遇到错误之前所做的数据修改。


##### 优化子查询（Optimizing Subqueries）

* 使用影响子查询中行的数量或顺序的子查询子句。
* 使用子查询替换JOIN
* 一些子查询可以转换为连接，以与不支持子查询的旧版本 MySQL 兼容。但是，在某些情况下，将子查询转换为连接可能会提高性能。
* 将子句从外部移动到子查询内部。
* 使用行子查询而不是相关子查询。
* 使用 NOT (a = ANY (...)) 而不是 <> ALL (...)。
* 使用 x = ANY（包含 (1,2) 的表）而不是 x=1 OR x=2。
* 使用 = ANY 而不是 EXISTS。
* 对于总是返回一行的不相关子查询，IN 总是比 = 慢。

MySQL本身做的一些优化是：
* MySQL 只执行一次不相关的子查询。使用 EXPLAIN 来确保给定的子查询确实是不相关的。
* MySQL 重写 IN、ALL、ANY 和 SOME 子查询，试图利用子查询中的选择列表列被索引的可能性。
* MySQL 将以下形式的子查询替换为索引查找函数，EXPLAIN 将其描述为特殊的连接类型（unique_subquery 或 index_subquery）：
```sql
... IN (SELECT indexed_column FROM single_table ...)
```
* MySQL 使用涉及 MIN() 或 MAX() 的表达式增强以下形式的表达式，除非涉及 NULL 值或空集：
```sql
value {ALL|ANY|SOME} {> | < | >= | <=} (uncorrelated subquery)
```


有时除了使用子查询之外，还有其他方法可以测试一组值中的成员资格。此外，在某些情况下，不仅可以在没有子查询的情况下重写查询，而且使用其中一些技术比使用子查询更有效。其中之一是 IN() 构造：

例如：
```sql
SELECT * FROM t1 WHERE id IN (SELECT id FROM t2);
```

可以修改为：
```sql
SELECT DISTINCT t1.* FROM t1, t2 WHERE t1.id=t2.id;
```

例如：
```sql
SELECT * FROM t1 WHERE id NOT IN (SELECT id FROM t2);
SELECT * FROM t1 WHERE NOT EXISTS (SELECT id FROM t2 WHERE t1.id=t2.id);
```

可以修改为：
```sql
SELECT table1.*
  FROM table1 LEFT JOIN table2 ON table1.id=table2.id
  WHERE table2.id IS NULL;
```

LEFT [OUTER] JOIN 可以比等效的子查询更快，因为服务器可能能够更好地优化它——这一事实并非仅针对 MySQL 服务器。在 SQL-92 之前，外部连接不存在，因此子查询是做某些事情的唯一方法。今天，MySQL 服务器和许多其他现代数据库系统提供了广泛的外部连接类型。

MySQL Server 支持多表 DELETE 语句，可用于根据来自一张表甚至同时来自多张表的信息高效地删除行。还支持多表 UPDATE 语句。

##### 子查询限制（Restrictions on Subqueries）
* 通常，您不能修改表并从子查询中的同一个表中进行选择。例如，此限制适用于以下形式的语句：
```sql
DELETE FROM t WHERE ... (SELECT ... FROM t ...);
UPDATE t ... WHERE col = (SELECT ... FROM t ...);
{INSERT|REPLACE} INTO t (SELECT ... FROM t ...);
```

例外：如果您正在使用派生表修改表并且该派生表是物化的而不是合并到外部查询中，则上述禁令不适用。例：
```sql
UPDATE t ... WHERE col = (SELECT * FROM (SELECT ... FROM t...) AS dt ...);
```

这里派生表的结果被具体化为临时表，因此在对 t 进行更新时已经选择了 t 中的相关行。

* 仅部分支持行比较操作：
	- 对于 expr [NOT] IN 子查询，expr 可以是一个 n 元组（使用行构造函数语法指定）并且子查询可以返回 n 元组的行。因此，允许的语法更具体地表示为 row_constructor [NOT] IN table_subquery
	- 对于 expr op {ALL|ANY|SOME} 子查询，expr 必须是标量值，子查询必须是列子查询；它不能返回多列行。

换句话说，对于返回 n 元组行的子查询，这是受支持的：
```sql
(expr_1, ..., expr_n) [NOT] IN table_subquery
```
但这不受支持：
```sql
(expr_1, ..., expr_n) op {ALL|ANY|SOME} subquery
```

支持 IN 而不是其他行比较的原因是 IN 是通过将其重写为一系列 = 比较和 AND 操作来实现的。此方法不能用于 ALL、ANY 或 SOME。

* FROM 子句中的子查询不能是关联子查询。它们在查询执行期间被整体具体化（评估以产生结果集），因此不能对外部查询的每一行进行评估。优化器延迟具体化，直到需要结果为止，这可能允许避免具体化。
* MySQL 不支持某些子查询运算符的子查询中的 LIMIT
* MySQL 允许子查询引用具有数据修改副作用的存储函数，例如将行插入表中。例如，如果 f() 插入行，则以下查询可以修改数据：
```sql
SELECT ... WHERE x IN (SELECT f() ...);
```

此行为是对 SQL 标准的扩展。在 MySQL 中，它会产生不确定的结果，因为 f() 可能会针对给定查询的不同执行执行不同的次数，具体取决于优化器选择如何处理它。
对于基于语句或混合格式的复制，这种不确定性的一个含义是这样的查询可以在源及其副本上产生不同的结果。

### 调用（CALL and DO）
```sql
CALL sp_name([parameter[,...]])
CALL sp_name[()]

DO expr [, expr] ...
```

CALL 语句调用先前使用 CREATE PROCEDURE 定义的存储过程。
可以在没有括号的情况下调用不带参数的存储过程。也就是说，CALL p() 和 CALL p 是等价的。
CALL 可以使用声明为 OUT 或 INOUT 参数的参数将值传回其调用者。当函数返回时，客户端程序还可以获得在函数中执行的最终语句受影响的行数： 在 SQL 级别，调用 ROW_COUNT() 函数；从 C API 调用 mysql_affected_rows() 函数。


DO 执行表达式但不返回任何结果。在大多数情况下，DO 是 SELECT expr, ... 的简写，但它的优点是当您不关心结果时速度稍快。
DO 主要用于具有副作用的函数，例如 RELEASE_LOCK()。这可能很有用，例如在存储函数或触发器中，它们禁止生成结果集的语句。
DO 只执行表达式。它不能用于所有可以使用 SELECT 的情况。例如，DO id FROM t1 是无效的，因为它引用了一个表。


## 事务和锁定语句（Transactional and Locking Statements）
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
* START TRANSACTION 或 BEGIN 开始一个新的事务。
* COMMIT 提交当前事务，使其更改永久化。
* ROLLBACK 回滚当前事务，取消其更改。
* SET autocommit 禁用或启用当前会话的默认自动提交模式。

默认情况下，MySQL 在启用自动提交模式的情况下运行。这意味着，当不在事务内部时，每个语句都是原子的，就好像它被 START TRANSACTION 和 COMMIT 包围一样。您不能使用 ROLLBACK 撤消效果；但是，如果在语句执行期间发生错误，则回滚该语句。

START TRANSACTION 允许几个控制事务特性的修饰符。要指定多个修饰符，请用逗号分隔它们。
* WITH CONSISTENT SNAPSHOT 修饰符为支持它的存储引擎启动一致读取。这仅适用于 InnoDB。效果与从任何 InnoDB 表发出 START TRANSACTION 后跟 SELECT 相同。WITH CONSISTENT SNAPSHOT 修饰符不会更改当前的事务隔离级别，因此仅当当前隔离级别是允许一致读取的隔离级别时，它才会提供一致的快照。唯一允许一致读取的隔离级别是可重复读取。对于所有其他隔离级别，忽略 WITH CONSISTENT SNAPSHOT 子句。从 MySQL 5.7.2 开始，忽略 WITH CONSISTENT SNAPSHOT 子句时会生成警告。
* READ WRITE 和 READ ONLY 修饰符设置事务访问模式。它们允许或禁止更改事务中使用的表。 READ ONLY 限制防止事务修改或锁定对其他事务可见的事务和非事务表；事务仍然可以修改或锁定临时表。
当已知事务是只读的时，MySQL 可以对 InnoDB 表的查询进行额外的优化。指定 READ ONLY 可确保在无法自动确定只读状态的情况下应用这些优化。
如果未指定访问模式，则应用默认模式。除非更改了默认值，否则它是可读/可写的。不允许在同一语句中同时指定 READ WRITE 和 READ ONLY。
在只读模式下，仍然可以使用 DML 语句更改使用 TEMPORARY 关键字创建的表。不允许使用 DDL 语句进行更改，就像永久表一样。


autocommit 是一个会话变量，必须为每个会话设置。要为每个新连接禁用自动提交模式。
通过将自动提交变量设置为零来禁用自动提交模式后，对事务安全表（例如 InnoDB 或 NDB 的表）的更改不会立即永久化。您必须使用 COMMIT 将更改存储到磁盘或使用 ROLLBACK 忽略更改。

支持 BEGIN 和 BEGIN WORK 作为 START TRANSACTION 的别名来发起交易。 START TRANSACTION 是标准的 SQL 语法，是启动临时事务的推荐方式，并且允许 BEGIN 不允许的修饰符。

BEGIN 语句不同于使用 BEGIN 关键字启动 BEGIN ... END 复合语句。后者不开始事务。
COMMIT 和 ROLLBACK 支持可选的 WORK 关键字，CHAIN 和 RELEASE 子句也是如此。 CHAIN 和 RELEASE 可用于对事务完成的额外控制。 completion_type 系统变量的值决定了默认的完成行为。
AND CHAIN 子句导致新事务在当前事务结束后立即开始，并且新事务与刚刚终止的事务具有相同的隔离级别。新事务也使用与刚刚终止的事务相同的访问模式（READ WRITE 或 READ ONLY）。 RELEASE 子句使服务器在终止当前事务后断开当前客户端会话。包括 NO 关键字会抑制 CHAIN 或 RELEASE 完成，如果 completion_type 系统变量设置为默认情况下导致链接或释放完成，这将很有用。

开始一个事务会导致任何待处理的事务被提交。开始一个事务也会导致使用 LOCK TABLES 获取的表锁被释放，就好像你已经执行了 UNLOCK TABLES 一样。开始事务不会释放使用带读锁的 FLUSH TABLES 获取的全局读锁。

您可以使用 SET TRANSACTION 语句更改事务的隔离级别或访问模式。

回滚可能是一个缓慢的操作，可能在用户没有明确要求的情况下隐式发生（例如，当发生错误时）。因此，SHOW PROCESSLIST 在会话的状态列中显示回滚，不仅用于使用 ROLLBACK 语句执行的显式回滚，还用于隐式回滚。
当 InnoDB 执行一个事务的完整回滚时，该事务设置的所有锁都会被释放。如果事务中的单个 SQL 语句由于错误（例如重复键错误）而回滚，则在事务保持活动状态时保留由该语句设置的锁。发生这种情况是因为 InnoDB 以一种格式存储行锁，这样它以后就不知道哪个锁是由哪个语句设置的。
如果事务中的 SELECT 语句调用存储函数，而存储函数中的语句失败，则该语句回滚。如果后续对该事务执行ROLLBACK，则整个事务回滚。
有些语句不能回滚。通常，这些包括数据定义语言 (DDL) 语句，例如创建或删除数据库的语句，创建、删除或更改表或存储例程的语句。
你应该设计你的事务不包括这样的声明。如果您在无法回滚的事务早期发出语句，然后另一个语句稍后失败，则在这种情况下无法通过发出 ROLLBACK 语句来回滚事务的全部效果。

### 隐式提交（Implicit Commit）
大多数这些语句在执行后也会导致隐式提交。目的是在其自己的特殊事务中处理每个此类语句，因为它无论如何都无法回滚。事务控制和锁定语句是例外：如果隐式提交发生在执行之前，则另一个不会发生在执行之后。

* 定义或修改数据库对象的数据定义语言 (DDL) 语句：ALTER DATABASE ... UPGRADE DATA DIRECTORY NAME, ALTER EVENT, ALTER PROCEDURE, ALTER SERVER, ALTER TABLE, ALTER TABLESPACE, ALTER VIEW, CREATE DATABASE, CREATE EVENT, CREATE INDEX, CREATE PROCEDURE, CREATE SERVER, CREATE TABLE, CREATE TABLESPACE, CREATE TRIGGER, CREATE VIEW, DROP DATABASE, DROP EVENT, DROP INDEX, DROP PROCEDURE, DROP SERVER, DROP TABLE, DROP TABLESPACE, DROP TRIGGER, DROP VIEW, INSTALL PLUGIN, RENAME TABLE, TRUNCATE TABLE, UNINSTALL PLUGIN.
ALTER FUNCTION、CREATE FUNCTION 和 DROP FUNCTION 在与存储函数一起使用时也会导致隐式提交，但不会与可加载函数一起使用。 （ALTER FUNCTION 只能与存储函数一起使用。）
如果使用 TEMPORARY 关键字，CREATE TABLE 和 DROP TABLE 语句不会提交事务。 （这不适用于对临时表的其他操作，例如 ALTER TABLE 和 CREATE INDEX，它们确实会导致提交。）但是，虽然没有发生隐式提交，但语句也不能回滚，这意味着使用此类语句导致违反事务原子性。例如，如果您使用 CREATE TEMPORARY TABLE 然后回滚事务，该表仍然存在。
InnoDB 中的 CREATE TABLE 语句作为单个事务处理。这意味着来自用户的 ROLLBACK 不会撤消用户在该事务期间所做的 CREATE TABLE 语句。
CREATE TABLE ... SELECT 在创建非临时表时会在语句执行前后导致隐式提交。 （CREATE TEMPORARY TABLE ... SELECT 没有提交。）

* 隐式使用或修改 mysql 数据库中表的语句： ALTER USER, CREATE USER, DROP USER, GRANT, RENAME USER, REVOKE, SET PASSWORD.
* 事务控制和锁定语句： BEGIN, LOCK TABLES, SET autocommit = 1 (if the value is not already 1), START TRANSACTION, UNLOCK TABLES.
UNLOCK TABLES 仅在当前已使用 LOCK TABLES 锁定任何表以获取非事务性表锁时才提交事务。 FLUSH TABLES WITH READ LOCK 之后的 UNLOCK TABLES 不会发生提交，因为后一条语句不获取表级锁。
事务不能嵌套。这是在您发出 START TRANSACTION 语句或其同义词之一时对任何当前事务执行隐式提交的结果。
当事务处于 ACTIVE 状态时，不能在 XA 事务中使用导致隐式提交的语句。
BEGIN 语句不同于使用 BEGIN 关键字启动 BEGIN ... END 复合语句。后者不会导致隐式提交。

* 数据加载语句： LOAD DATA. 
* 管理语句： ANALYZE TABLE, CACHE INDEX, CHECK TABLE, FLUSH, LOAD INDEX INTO CACHE, OPTIMIZE TABLE, REPAIR TABLE, RESET.
* 副本控制语句：START SLAVE, STOP SLAVE, RESET SLAVE, CHANGE MASTER TO.

### 保存点（SAVEPOINT）
```sql
SAVEPOINT identifier
ROLLBACK [WORK] TO [SAVEPOINT] identifier
RELEASE SAVEPOINT identifier
```

ROLLBACK TO SAVEPOINT 语句将事务回滚到指定的保存点而不终止事务。当前事务在设置保存点之后对行所做的修改在回滚中被撤消，但 InnoDB 不会释放在保存点之后存储在内存中的行锁。 （对于新插入的行，锁信息由该行存储的事务ID携带，锁不单独存储在内存中，此时在undo中释放行锁。）晚于指定保存点的时间将被删除。

SAVEPOINT 语句设置一个名为标识符的命名事务保存点。如果当前事务有一个同名的保存点，则删除旧的保存点并设置一个新的保存点。
如果执行 COMMIT 或未命名保存点的 ROLLBACK，则删除当前事务的所有保存点。

当调用存储函数或激活触发器时，将创建一个新的保存点级别。先前级别上的保存点变得不可用，因此不会与新级别上的保存点冲突。当函数或触发器终止时，它创建的任何保存点都会被释放，并且会恢复之前的保存点级别。


### 锁表（LOCK TABLES）
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

MySQL允许客户端会话显式获取表锁，目的是为了与其他会话协作访问表，或者防止其他会话在会话需要独占访问表时修改表。会话只能为自己获取或释放锁。一个会话不能为另一个会话获取锁或释放另一个会话持有的锁。
锁可用于模拟事务或在更新表时获得更快的速度。
LOCK TABLES 显式获取当前客户端会话的表锁。可以为基表或视图获取表锁。对于要锁定的每个对象，您必须具有 LOCK TABLES 权限和 SELECT 权限。
对于视图锁定，LOCK TABLES 将视图中使用的所有基表添加到要锁定的表集中并自动锁定它们。从 MySQL 5.7.32 开始，LOCK TABLES 检查视图定义者是否对视图下的表具有适当的权限。
UNLOCK TABLES 显式释放当前会话持有的任何表锁。 LOCK TABLES 在获取新锁之前隐式释放当前会话持有的任何表锁。
UNLOCK TABLES 的另一个用途是释放使用 FLUSH TABLES WITH READ LOCK 语句获取的全局读锁，这使您能够锁定所有数据库中的所有表。

表锁仅防止其他会话进行不适当的读取或写入。持有 WRITE 锁的会话可以执行表级操作，例如 DROP TABLE 或 TRUNCATE TABLE。对于持有 READ 锁的会话，不允许执行 DROP TABLE 和 TRUNCATE TABLE 操作。


### 设置事务（SET TRANSACTION）
```sql
SET [GLOBAL | SESSION] TRANSACTION
    transaction_characteristic [, transaction_characteristic] ...

transaction_characteristic: {
    ISOLATION LEVEL level
  | access_mode
}

level: {
     REPEATABLE READ
   | READ COMMITTED
   | READ UNCOMMITTED
   | SERIALIZABLE
}

access_mode: {
     READ WRITE
   | READ ONLY
}
```

该语句指定事务特征。它采用以逗号分隔的一个或多个特征值的列表。每个特征值设置事务隔离级别或访问模式。隔离级别用于对 InnoDB 表的操作。访问模式指定事务是在读/写模式还是只读模式下运行。
此外，SET TRANSACTION 可以包括一个可选的 GLOBAL 或 SESSION 关键字来指示语句的范围。

* 事务隔离级别
要设置事务隔离级别，请使用 ISOLATION LEVEL 级别子句。不允许在同一 SET TRANSACTION 语句中指定多个 ISOLATION LEVEL 子句。
默认隔离级别是可重复读。其他允许的值是 READ COMMITTED、READ UNCOMMITTED 和 SERIALIZABLE。

* 事务访问模式
要设置事务访问模式，请使用 READ WRITE 或 READ ONLY 子句。不允许在同一 SET TRANSACTION 语句中指定多个访问模式子句。
默认情况下，事务以读/写模式进行，允许对事务中使用的表进行读取和写入。可以使用 READ WRITE 访问模式的 SET TRANSACTION 显式指定此模式。
如果事务访问模式设置为 READ ONLY，则禁止更改表。这可能使存储引擎能够在不允许写入时进行性能改进。
在只读模式下，仍然可以使用 DML 语句更改使用 TEMPORARY 关键字创建的表。不允许使用 DDL 语句进行更改，就像永久表一样。
还可以使用 START TRANSACTION 语句为单个事务指定 READ WRITE 和 READ ONLY 访问模式。

* 事务特征范围
您可以为当前会话或仅为下一个事务全局设置事务特征：
	- GLOBAL，该声明在全局范围内适用于所有后续事务，现有会话不受影响。
	- SESSION，该语句适用于当前会话中执行的所有后续事务，该语句在事务中是允许的，但不影响当前正在进行的事务，如果在事务之间执行，该语句将覆盖任何前面设置命名特征的下一个事务值的语句。
	- 不写，该语句仅适用于会话中执行的下一个事务，后续事务恢复使用指定特征的会话值。



## 复合语句（Compound Statements）
```sql
[begin_label:] BEGIN
    [statement_list]
END [end_label]
```

BEGIN ... END 语法用于编写复合语句，这些语句可以出现在存储程序（存储过程和函数、触发器和事件）中。复合语句可以包含多个语句，由 BEGIN 和 END 关键字括起来。 statement_list 表示一个或多个语句的列表，每个语句以分号 (;) 语句定界符终止。 statement_list 本身是可选的，所以空复合语句（BEGIN END）是合法的。
BEGIN ... END 块可以嵌套。

使用多个语句要求客户端能够发送包含 ; 的语句字符串。语句分隔符。在 mysql 命令行客户端中，这是用 delimiter 命令处理的。改变;语句结束分隔符（例如，to//）允许。

可以标记 BEGIN ... END 块。

不支持可选的 [NOT] ATOMIC 子句。这意味着在指令块的开始处没有设置事务保存点，并且在此上下文中使用的 BEGIN 子句对当前事务没有影响。

### 标签（Labels）
```sql
[begin_label:] BEGIN
    [statement_list]
END [end_label]

[begin_label:] LOOP
    statement_list
END LOOP [end_label]

[begin_label:] REPEAT
    statement_list
UNTIL search_condition
END REPEAT [end_label]

[begin_label:] WHILE search_condition DO
    statement_list
END WHILE [end_label]
```

BEGIN ... END 块以及 LOOP、REPEAT 和 WHILE 语句允许使用标签。这些语句的标签使用遵循以下规则：
* begin_label 后面必须跟一个冒号。
* begin_label 可以在没有 end_label 的情况下给出。如果存在 end_label，则它必须与 begin_label 相同。
* end_label 不能在没有 begin_label 的情况下给出。
* 同一嵌套级别的标签必须不同。
* 标签最长可达 16 个字符。

要在带标签的构造中引用标签，请使用 ITERATE 或 LEAVE 语句。

### 声明（DECLARE）
DECLARE 语句用于定义程序本地的各种项目：
* 局部变量
* 条件和处理程序
* 游标

DECLARE 仅允许在 BEGIN ... END 复合语句内使用，并且必须位于其开头，在任何其他语句之前。
声明必须遵循一定的顺序。游标声明必须出现在处理程序声明之前。变量和条件声明必须出现在游标或处理程序声明之前。

系统变量和用户定义变量可以在存储程序中使用，就像它们可以在存储程序上下文之外使用一样。此外，存储程序可以使用 DECLARE 来定义局部变量，并且可以声明存储例程（过程和函数）以获取在例程与其调用者之间传递值的参数。
* 要声明局部变量，请使用 DECLARE 语句。
* 可以直接使用 SET 语句设置变量。
* 可以使用 SELECT ... INTO var_list 或通过打开游标并使用 FETCH ... INTO var_list 将查询结果检索到局部变量中。

不允许将值 DEFAULT 分配给存储过程或函数参数或存储程序局部变量（例如使用 SET var_name = DEFAULT 语句）。在 MySQL 5.7 中，这会导致语法错误。

```sql
DECLARE var_name [, var_name] ... type [DEFAULT value]
```

此语句声明存储程序中的局部变量。要为变量提供默认值，请包含 DEFAULT 子句。该值可以指定为表达式；它不必是常数。如果缺少 DEFAULT 子句，则初始值为 NULL。

* 变量声明必须出现在游标或处理程序声明之前。
* 局部变量名称不区分大小写。允许的字符和引用规则与其他标识符相同。
* 局部变量的范围是声明它的 BEGIN ... END 块。可以在声明块内嵌套的块中引用变量，但声明同名变量的块除外。

### 流程控制语句（Flow Control Statements）
MySQL 支持 IF、CASE、ITERATE、LEAVE LOOP、WHILE 和 REPEAT 结构，用于存储程序中的流控制。它还支持存储函数中的 RETURN。MySQL 不支持 FOR 循环。

```sql
CASE case_value
    WHEN when_value THEN statement_list
    [WHEN when_value THEN statement_list] ...
    [ELSE statement_list]
END CASE

CASE
    WHEN search_condition THEN statement_list
    [WHEN search_condition THEN statement_list] ...
    [ELSE statement_list]
END CASE
```

> 这个 CASE 不同于 CASE 运算符，当前 CASE 语句只能用于 BEGIN ... END 中，且 CASE 语句不能有 ELSE NULL 子句，它以 END CASE 而不是 END 终止。

对于第一种语法，case_value 是一个表达式。该值与每个 WHEN 子句中的 when_value 表达式进行比较，直到其中一个相等。当找到相等的 when_value 时，相应的 THEN 子句 statement_list 就会执行。如果没有 when_value 相等，则执行 ELSE 子句 statement_list（如果有的话）。
此语法不能用于测试是否与 NULL 相等，因为 NULL = NULL 为假。

对于第二种语法，对每个 WHEN 子句 search_condition 表达式求值，直到有一个为真，此时执行其对应的 THEN 子句 statement_list。如果没有 search_condition 相等，则执行 ELSE 子句 statement_list（如果有的话）。
如果没有 when_value 或 search_condition 与测试的值匹配，并且 CASE 语句不包含 ELSE 子句，则 Case not found for CASE statement 错误结果。
每个statement_list由一条或多条SQL语句组成；空的 statement_list 是不允许的。


```sql
IF search_condition THEN statement_list
    [ELSEIF search_condition THEN statement_list] ...
    [ELSE statement_list]
END IF
```

> 还有一个 IF() 函数，它与此处描述的 IF 语句不同。 IF 语句可以有 THEN、ELSE 和 ELSEIF 子句，并以 END IF 结束。

存储程序的 IF 语句实现了一个基本的条件结构。
如果给定的 search_condition 评估为真，则执行相应的 THEN 或 ELSEIF 子句 statement_list。如果没有 search_condition 匹配，则执行 ELSE 子句 statement_list。

每个statement_list由一条或多条SQL语句组成；空的 statement_list 是不允许的。

```sql
ITERATE label
```

ITERATE 只能出现在 LOOP、REPEAT 和 WHILE 语句中。 ITERATE 的意思是“再次开始循环”。


```sql
LEAVE label
```

此语句用于退出具有给定标签的流程控制构造。如果标签用于最外层存储的程序块，则 LEAVE 退出程序。

LEAVE 可以在 BEGIN ... END 或循环结构（LOOP、REPEAT、WHILE）中使用。


```sql
[begin_label:] LOOP
    statement_list
END LOOP [end_label]
```

LOOP 实现了一个简单的循环结构，允许重复执行语句列表，该语句列表由一个或多个语句组成，每个语句以分号 (;) 语句分隔符结束。重复循环内的语句，直到循环终止。通常，这是通过 LEAVE 语句完成的。在存储函数中，也可以使用 RETURN，它会完全退出函数。
忽略包含循环终止语句会导致无限循环。
可以标记 LOOP 语句。

示例：
```sql
CREATE PROCEDURE doiterate(p1 INT)
BEGIN
  label1: LOOP
    SET p1 = p1 + 1;
    IF p1 < 10 THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
  SET @x = p1;
END;
```

```sql
[begin_label:] REPEAT
    statement_list
UNTIL search_condition
END REPEAT [end_label]
```

重复 REPEAT 语句中的语句列表，直到 search_condition 表达式为真。因此，REPEAT 总是至少进入循环一次。 statement_list 由一个或多个语句组成，每个语句以分号 (;) 语句定界符终止。

可以标记 REPEAT 语句。

```sql
RETURN expr
```

RETURN 语句终止存储函数的执行并将值 expr 返回给函数调用者。存储函数中必须至少有一个 RETURN 语句。如果函数有多个出口点，则可能不止一个。
此语句不用于存储过程、触发器或事件。 LEAVE 语句可用于退出这些类型的存储程序。


```sql
[begin_label:] WHILE search_condition DO
    statement_list
END WHILE [end_label]
```

只要 search_condition 表达式为真，就会重复 WHILE 语句中的语句列表。 statement_list 由一个或多个 SQL 语句组成，每个语句以分号 (;) 语句分隔符结束。

可以标记 WHILE 语句。有关标签使用的规则，请参阅第 13.6.2 节，“声明标签”。

## 数据库管理语句（Database Administration Statements）
### 用户管理（USER）

[用户名定义规则](https://dev.mysql.com/doc/refman/5.7/en/account-names.html)

[创建](https://dev.mysql.com/doc/refman/5.7/en/create-user.html)
```sql
CREATE USER [IF NOT EXISTS]
    user [auth_option] [, user [auth_option]] ...
    [REQUIRE {NONE | tls_option [[AND] tls_option] ...}]
    [WITH resource_option [resource_option] ...]
    [password_option | lock_option] ...

auth_option: {
    IDENTIFIED BY 'auth_string'
  | IDENTIFIED WITH auth_plugin
  | IDENTIFIED WITH auth_plugin BY 'auth_string'
  | IDENTIFIED WITH auth_plugin AS 'auth_string'
  | IDENTIFIED BY PASSWORD 'auth_string'
}
```

CREATE USER 语句创建新的 MySQL 帐户。它支持为新帐户建立身份验证、SSL/TLS、资源限制和密码管理属性，并控制帐户最初是锁定还是解锁。

要使用CREATE USER，您必须具有全局CREATE USER 权限，或mysql 系统数据库的INSERT 权限。当启用 read_only 系统变量时，CREATE USER 还需要 SUPER 权限。

如果您尝试创建一个已经存在的帐户，则会发生错误。如果给出了 IF NOT EXISTS 子句，该语句会为每个已存在的命名帐户生成警告，而不是错误。



修改
```sql
ALTER USER [IF EXISTS]
    user [auth_option] [, user [auth_option]] ...
    [REQUIRE {NONE | tls_option [[AND] tls_option] ...}]
    [WITH resource_option [resource_option] ...]
    [password_option | lock_option] ...

ALTER USER [IF EXISTS]
    USER() IDENTIFIED BY 'auth_string'
```

ALTER USER 语句修改 MySQL 帐户。它支持为现有帐户修改身份验证、SSL/TLS、资源限制和密码管理属性。它还可用于锁定和解锁帐户。
要使用 ALTER USER，您必须具有 mysql 系统数据库的全局 CREATE USER 权限或 UPDATE 权限。当启用 read_only 系统变量时，ALTER USER 还需要 SUPER 权限。
默认情况下，如果您尝试修改不存在的用户，则会发生错误。如果给出了 IF EXISTS 子句，该语句会为每个不存在的指定用户生成警告，而不是错误。


删除
```sql
DROP USER [IF EXISTS] user [, user] ...
```

DROP USER 语句删除一个或多个 MySQL 帐户及其权限。它从所有授权表中删除帐户的权限行。
要使用 DROP USER，您必须具有全局 CREATE USER 权限，或 mysql 系统数据库的 DELETE 权限。当启用 read_only 系统变量时，DROP USER 还需要 SUPER 权限。
如果您尝试删除不存在的帐户，则会发生错误。如果给出了 IF EXISTS 子句，该语句会为每个不存在的指定用户生成警告，而不是错误。


重命名
```sql
RENAME USER old_user TO new_user
    [, old_user TO new_user] ...
```

RENAME USER 语句重命名现有的 MySQL 帐户。对于不存在的旧帐户或已存在的新帐户，会发生错误。
要使用 RENAME USER，您必须具有全局 CREATE USER 权限，或 mysql 系统数据库的 UPDATE 权限。当启用 read_only 系统变量时，RENAME USER 还需要 SUPER 权限。
帐户名的主机名部分（如果省略）默认为“%”。
RENAME USER 使旧用户拥有的特权成为新用户拥有的特权。但是，RENAME USER 不会自动删除或使旧用户创建的数据库或其中的对象失效。这包括 DEFINER 属性为旧用户命名的存储程序或视图。如果它们在定义者安全上下文中执行，则尝试访问此类对象可能会产生错误。


授权
```sql
GRANT
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    TO user [auth_option] [, user [auth_option]] ...
    [REQUIRE {NONE | tls_option [[AND] tls_option] ...}]
    [WITH {GRANT OPTION | resource_option} ...]

GRANT PROXY ON user
    TO user [, user] ...
    [WITH GRANT OPTION]
```

GRANT 语句将权限授予 MySQL 用户帐户。 GRANT 语句有几个方面，在以下主题下进行了描述：
GRANT 语句将权限授予 MySQL 用户帐户。

要使用 GRANT 授予权限，您必须具有 GRANT OPTION 权限，并且必须具有您要授予的权限。 （或者，如果您对 mysql 系统数据库中的授权表具有 UPDATE 权限，则可以授予任何帐户任何权限。）启用 read_only 系统变量时，GRANT 还需要 SUPER 权限。

REVOKE 语句与 GRANT 相关，使管理员能够删除帐户权限。

GRANT 和 REVOKE 允许的权限:

| Privilege | Meaning and Grantable Levels |
| --- | --- |
| [`ALL [PRIVILEGES]`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_all) | Grant all privileges at specified access level except [`GRANT OPTION`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_grant-option) and [`PROXY`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_proxy). |
| [`ALTER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_alter) | Enable use of [`ALTER TABLE`](https://dev.mysql.com/doc/refman/5.7/en/alter-table.html "13.1.8 ALTER TABLE Statement"). Levels: Global, database, table. |
| [`ALTER ROUTINE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_alter-routine) | Enable stored routines to be altered or dropped. Levels: Global, database, routine. |
| [`CREATE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create) | Enable database and table creation. Levels: Global, database, table. |
| [`CREATE ROUTINE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-routine) | Enable stored routine creation. Levels: Global, database. |
| [`CREATE TABLESPACE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-tablespace) | Enable tablespaces and log file groups to be created, altered, or dropped. Level: Global. |
| [`CREATE TEMPORARY TABLES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-temporary-tables) | Enable use of [`CREATE TEMPORARY TABLE`](https://dev.mysql.com/doc/refman/5.7/en/create-table.html "13.1.18 CREATE TABLE Statement"). Levels: Global, database. |
| [`CREATE USER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-user) | Enable use of [`CREATE USER`](https://dev.mysql.com/doc/refman/5.7/en/create-user.html "13.7.1.2 CREATE USER Statement"), [`DROP USER`](https://dev.mysql.com/doc/refman/5.7/en/drop-user.html "13.7.1.3 DROP USER Statement"), [`RENAME USER`](https://dev.mysql.com/doc/refman/5.7/en/rename-user.html "13.7.1.5 RENAME USER Statement"), and [`REVOKE ALL PRIVILEGES`](https://dev.mysql.com/doc/refman/5.7/en/revoke.html "13.7.1.6 REVOKE Statement"). Level: Global. |
| [`CREATE VIEW`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-view) | Enable views to be created or altered. Levels: Global, database, table. |
| [`DELETE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_delete) | Enable use of [`DELETE`](https://dev.mysql.com/doc/refman/5.7/en/delete.html "13.2.2 DELETE Statement"). Level: Global, database, table. |
| [`DROP`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_drop) | Enable databases, tables, and views to be dropped. Levels: Global, database, table. |
| [`EVENT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_event) | Enable use of events for the Event Scheduler. Levels: Global, database. |
| [`EXECUTE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_execute) | Enable the user to execute stored routines. Levels: Global, database, routine. |
| [`FILE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_file) | Enable the user to cause the server to read or write files. Level: Global. |
| [`GRANT OPTION`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_grant-option) | Enable privileges to be granted to or removed from other accounts. Levels: Global, database, table, routine, proxy. |
| [`INDEX`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_index) | Enable indexes to be created or dropped. Levels: Global, database, table. |
| [`INSERT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_insert) | Enable use of [`INSERT`](https://dev.mysql.com/doc/refman/5.7/en/insert.html "13.2.5 INSERT Statement"). Levels: Global, database, table, column. |
| [`LOCK TABLES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_lock-tables) | Enable use of [`LOCK TABLES`](https://dev.mysql.com/doc/refman/5.7/en/lock-tables.html "13.3.5 LOCK TABLES and UNLOCK TABLES Statements") on tables for which you have the [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement") privilege. Levels: Global, database. |
| [`PROCESS`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_process) | Enable the user to see all processes with [`SHOW PROCESSLIST`](https://dev.mysql.com/doc/refman/5.7/en/show-processlist.html "13.7.5.29 SHOW PROCESSLIST Statement"). Level: Global. |
| [`PROXY`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_proxy) | Enable user proxying. Level: From user to user. |
| [`REFERENCES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_references) | Enable foreign key creation. Levels: Global, database, table, column. |
| [`RELOAD`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_reload) | Enable use of [`FLUSH`](https://dev.mysql.com/doc/refman/5.7/en/flush.html "13.7.6.3 FLUSH Statement") operations. Level: Global. |
| [`REPLICATION CLIENT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_replication-client) | Enable the user to ask where source or replica servers are. Level: Global. |
| [`REPLICATION SLAVE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_replication-slave) | Enable replicas to read binary log events from the source. Level: Global. |
| [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_select) | Enable use of [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/select.html "13.2.9 SELECT Statement"). Levels: Global, database, table, column. |
| [`SHOW DATABASES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_show-databases) | Enable [`SHOW DATABASES`](https://dev.mysql.com/doc/refman/5.7/en/show-databases.html "13.7.5.14 SHOW DATABASES Statement") to show all databases. Level: Global. |
| [`SHOW VIEW`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_show-view) | Enable use of [`SHOW CREATE VIEW`](https://dev.mysql.com/doc/refman/5.7/en/show-create-view.html "13.7.5.13 SHOW CREATE VIEW Statement"). Levels: Global, database, table. |
| [`SHUTDOWN`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_shutdown) | Enable use of [**mysqladmin shutdown**](https://dev.mysql.com/doc/refman/5.7/en/mysqladmin.html "4.5.2 mysqladmin — A MySQL Server Administration Program"). Level: Global. |
| [`SUPER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_super) | Enable use of other administrative operations such as [`CHANGE MASTER TO`](https://dev.mysql.com/doc/refman/5.7/en/change-master-to.html "13.4.2.1 CHANGE MASTER TO Statement"), [`KILL`](https://dev.mysql.com/doc/refman/5.7/en/kill.html "13.7.6.4 KILL Statement"), [`PURGE BINARY LOGS`](https://dev.mysql.com/doc/refman/5.7/en/purge-binary-logs.html "13.4.1.1 PURGE BINARY LOGS Statement"), [`SET GLOBAL`](https://dev.mysql.com/doc/refman/5.7/en/set-variable.html "13.7.4.1 SET Syntax for Variable Assignment"), and [**mysqladmin debug**](https://dev.mysql.com/doc/refman/5.7/en/mysqladmin.html "4.5.2 mysqladmin — A MySQL Server Administration Program") command. Level: Global. |
| [`TRIGGER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_trigger) | Enable trigger operations. Levels: Global, database, table. |
| [`UPDATE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_update) | Enable use of [`UPDATE`](https://dev.mysql.com/doc/refman/5.7/en/update.html "13.2.11 UPDATE Statement"). Levels: Global, database, table, column. |
| [`USAGE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_usage) | Synonym for “no privileges” |



取消授权
```sql
REVOKE
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    FROM user [, user] ...

REVOKE ALL [PRIVILEGES], GRANT OPTION
    FROM user [, user] ...

REVOKE PROXY ON user
    FROM user [, user] ...
```

REVOKE 语句使系统管理员能够撤销 MySQL 帐户的权限。

有关权限级别、允许的 priv_type、priv_level 和 object_type 值以及指定用户和密码的语法的详细信息，请参阅第 13.7.1.4 节“GRANT 语句”。

当启用 read_only 系统变量时，除了以下讨论中描述的任何其他所需特权之外，REVOKE 还需要 SUPER 特权。


### 显示（SHOW）
[SHOW文档](https://dev.mysql.com/doc/refman/5.7/en/show.html)
SHOW 有许多形式，提供有关数据库、表、列或服务器状态信息的信息。
如果给定 SHOW 语句的语法包含 LIKE 'pattern' 部分，则 'pattern' 是一个可以包含 SQL % 和 _ 通配符的字符串。该模式对于将语句输出限制为匹配值很有用。
多个 SHOW 语句还接受 WHERE 子句，该子句在指定要显示的行方面提供了更大的灵活性。

### 刷新（FLUSH）
```sql
FLUSH [NO_WRITE_TO_BINLOG | LOCAL] {
    flush_option [, flush_option] ...
  | tables_option
}

flush_option: {
    BINARY LOGS
  | DES_KEY_FILE
  | ENGINE LOGS
  | ERROR LOGS
  | GENERAL LOGS
  | HOSTS
  | LOGS
  | PRIVILEGES
  | OPTIMIZER_COSTS
  | QUERY CACHE
  | RELAY LOGS [FOR CHANNEL channel]
  | SLOW LOGS
  | STATUS
  | USER_RESOURCES
}

tables_option: {
    TABLES
  | TABLES tbl_name [, tbl_name] ...
  | TABLES WITH READ LOCK
  | TABLES tbl_name [, tbl_name] ... WITH READ LOCK
  | TABLES tbl_name [, tbl_name] ... FOR EXPORT
}
```

FLUSH 语句有几种变体形式，可以清除或重新加载各种内部缓存、刷新表或获取锁。要执行 FLUSH，您必须具有 RELOAD 权限。特定的刷新选项可能需要额外的权限，如选项描述中所示。

默认情况下，服务器将 FLUSH 语句写入二进制日志，以便它们复制到副本。要禁止记录日志，请指定可选的 NO_WRITE_TO_BINLOG 关键字或其别名 LOCAL。

FLUSH 子句
* FLUSH BINARY LOGS
关闭并重新打开服务器正在写入的任何二进制日志文件。如果启用了二进制日志记录，则二进制日志文件的序列号相对于前一个文件递增 1。
此操作对用于二进制和中继日志的表没有影响（由 master_info_repository 和 relay_log_info_repository 系统变量控制）。

* FLUSH DES_KEY_FILE
在服务器启动时从使用 --des-key-file 选项指定的文件重新加载 DES 密钥。

* FLUSH ENGINE LOGS
关闭并重新打开已安装存储引擎的任何可刷新日志。这会导致 InnoDB 将其日志刷新到磁盘。

* FLUSH ERROR LOGS
关闭并重新打开服务器正在写入的任何错误日志文件。

* FLUSH GENERAL LOGS
关闭并重新打开服务器正在写入的任何常规查询日志文件。

* FLUSH HOSTS
清空主机缓存和暴露缓存内容的性能模式 host_cache 表，并取消阻止任何被阻止的主机。

* FLUSH LOGS
关闭并重新打开服务器正在写入的任何日志文件。
此操作的效果等同于这些操作的组合效果：

```sql
FLUSH BINARY LOGS
FLUSH ENGINE LOGS
FLUSH ERROR LOGS
FLUSH GENERAL LOGS
FLUSH RELAY LOGS
FLUSH SLOW LOGS
```

* FLUSH OPTIMIZER_COSTS
重新读取成本模型表，以便优化器开始使用存储在其中的当前成本估算。

* FLUSH PRIVILEGES
从 mysql 系统数据库中的授权表中重新读取权限。

* FLUSH RELAY LOGS [FOR CHANNEL channel]
关闭并重新打开服务器正在写入的任何中继日志文件。如果启用中继日志记录，则中继日志文件的序列号相对于前一个文件递增 1。

* FLUSH SLOW LOGS
关闭并重新打开服务器正在写入的任何慢速查询日志文件。

* FLUSH STATUS
刷新状态指示器。

* FLUSH USER_RESOURCES
将所有每小时用户资源指标重置为零。

FLUSH TABLES 语法

* FLUSH TABLES

* FLUSH TABLES tbl_name [, tbl_name] ...

* FLUSH TABLES WITH READ LOCK

* FLUSH TABLES tbl_name [, tbl_name] ... WITH READ LOCK

* FLUSH TABLES tbl_name [, tbl_name] ... FOR EXPORT


### 杀死（KILL）

```sql
KILL [CONNECTION | QUERY] processlist_id
```

每个与 mysqld 的连接都在一个单独的线程中运行。您可以使用 KILL processlist_id 语句终止线程。

线程进程列表标识符可以根据 INFORMATION_SCHEMA PROCESSLIST 表的 ID 列、SHOW PROCESSLIST 输出的 Id 列和性能模式线程表的 PROCESSLIST_ID 列来确定。当前线程的值由 CONNECTION_ID() 函数返回。

KILL 允许可选的 CONNECTION 或 QUERY 修饰符：
* KILL CONNECTION 与没有修饰符的 KILL 相同：它在终止连接正在执行的任何语句后终止与给定 processlist_id 关联的连接。
* KILL QUERY 终止连接当前正在执行的语句，但保持连接本身不变。

查看哪些线程可以被杀死的能力取决于 PROCESS 权限：
* 没有 PROCESS，您只能看到自己的线程。
* 使用 PROCESS，您可以看到所有线程。

杀死线程和语句的能力取决于 SUPER 特权：
* 没有 SUPER，你只能杀死你自己的线程和语句。
* 使用 SUPER，您可以终止所有线程和语句。

使用 KILL 时，会为线程设置线程特定的终止标志。在大多数情况下，线程可能需要一些时间才能结束，因为 kill 标志仅在特定时间间隔检查：
* 在 SELECT 操作期间，对于 ORDER BY 和 GROUP BY 循环，在读取一个行块后检查标志。如果设置了 kill 标志，语句将中止。
* 制作表副本的 ALTER TABLE 操作会定期检查从原始表中读取的每几行复制的 kill 标志。如果设置了 kill 标志，语句将中止并删除临时表。
* KILL 语句不等待确认就返回，但是 kill 标志检查会在相当短的时间内中止操作。中止操作以执行任何必要的清理也需要一些时间。
* 在 UPDATE 或 DELETE 操作期间，kill 标志在每个块读取之后以及每个更新或删除的行之后被检查。如果设置了 kill 标志，语句将中止。如果您不使用事务，则不会回滚更改。
* GET_LOCK() 中止并返回 NULL。
* 如果线程在表锁处理程序中（状态：Locked），表锁会很快中止。
* 如果线程正在等待写入调用中的可用磁盘空间，写入将中止并显示“磁盘已满”错误消息。

# 进阶篇

## 执行流程

### InnoDB架构

![InnoDB 架构图](https://dev.mysql.com/doc/refman/5.7/en/images/innodb-architecture-5-7.png)

## 日志

### error log

### binary log

### query log

### slow log

### 重做日志（Redo Log）
重做日志是一种基于磁盘的数据结构，在崩溃恢复期间使用它来纠正由不完整的事务写入的数据。在正常操作期间，重做日志对 SQL 语句或低级 API 调用产生的更改表数据的请求进行编码。在意外关闭之前未完成更新数据文件的修改将在初始化期间和接受连接之前自动重播。
默认情况下，重做日志在磁盘上由两个名为 ib_logfile0 和 ib_logfile1 的文件物理表示。 MySQL 以循环方式写入重做日志文件。重做日志中的数据根据受影响的记录进行编码；这些数据统称为重做。通过重做日志的数据通道由不断增加的 LSN 值表示。


### 撤消日志（Undo Log）
撤消日志是与单个读写事务关联的撤消日志记录的集合。撤消日志记录包含有关如何撤消事务对聚集索引记录的最新更改的信息。如果另一个事务需要将原始数据视为一致读取操作的一部分，则未修改的数据将从撤消日志记录中检索。撤消日志存在于撤消日志段中，而撤消日志段包含在回滚段中。回滚段位于系统表空间、撤消表空间和临时表空间中。
驻留在临时表空间中的撤消日志用于修改用户定义的临时表中数据的事务。这些撤消日志不会重做日志，因为它们不是崩溃恢复所必需的。它们仅用于服务器运行时的回滚。这种类型的撤消日志通过避免重做日志 I/O 来提高性能。
InnoDB 最多支持 128 个回滚段，其中 32 个分配给临时表空间。这留下了 96 个回滚段，可以分配给修改常规表中数据的事务。 innodb_rollback_segments 变量定义了 InnoDB 使用的回滚段数。
一个回滚段支持的事务数取决于回滚段中的undo槽数和每个事务需要的undo日志数。回滚段中的撤消槽数根据 InnoDB 页面大小而不同。

| InnoDB Page Size | 回滚段中的撤消槽数 (InnoDB Page Size / 16) |
| --- | --- |
| `4096 (4KB)` | `256` |
| `8192 (8KB)` | `512` |
| `16384 (16KB)` | `1024` |
| `32768 (32KB)` | `2048` |
| `65536 (64KB)` | `4096` |

事务最多分配四个撤消日志，一个用于以下操作类型：
* 对用户定义的表执行 INSERT 操作
* 对用户定义表的更新和删除操作
* 对用户定义的临时表执行 INSERT 操作
* 对用户定义的临时表进行 UPDATE 和 DELETE 操作

根据需要分配撤消日志。例如，对常规表和临时表执行 INSERT、UPDATE 和 DELETE 操作的事务需要完整分配四个撤消日志。仅对常规表执行 INSERT 操作的事务需要单个撤消日志。
对常规表执行操作的事务从分配的系统表空间或撤消表空间回滚段中分配撤消日志。对临时表执行操作的事务从分配的临时表空间回滚段分配撤消日志。
分配给事务的撤消日志在其持续时间内保持附加到事务。例如，为常规表上的 INSERT 操作分配给事务的撤消日志用于该事务对常规表执行的所有 INSERT 操作。
鉴于上述因素，可以使用以下公式来估计 InnoDB 能够支持的并发读写事务数。

> 在达到 InnoDB 能够支持的并发读写事务数之前，可能会遇到并发事务限制错误。当分配给事务的回滚段用完撤消槽时会发生这种情况。在这种情况下，请尝试重新运行事务。
当事务对临时表进行操作时，InnoDB 能够支持的并发读写事务数受分配给临时表空间的回滚段数限制，即 32。

* 如果每个事务执行 INSERT 或 UPDATE 或 DELETE 操作，则 InnoDB 能够支持的并发读写事务数为：$(innodb_page_size / 16) * (innodb_rollback_segments - 32)$
* 如果每个事务执行一个INSERT和一个UPDATE或DELETE操作，InnoDB能够支持的并发读写事务数为：$(innodb_page_size / 16 / 2) * (innodb_rollback_segments - 32)$
* 如果每个事务对临时表执行INSERT操作，则InnoDB能够支持的并发读写事务数为：$(innodb_page_size / 16) * 32$
* 如果每个事务对临时表执行INSERT和UPDATE或DELETE操作，InnoDB能够支持的并发读写事务数为：$(innodb_page_size / 16 / 2) * 32$


## 缓存

### sort buffer

### join buffer

### redo log buffer



### 日志缓冲区（Log Buffer）

日志缓冲区是存储要写入磁盘上日志文件的数据的内存区域。日志缓冲区大小由 innodb_log_buffer_size 变量定义。默认大小为 16MB。日志缓冲区的内容会定期刷新到磁盘。大型日志缓冲区使大型事务无需在事务提交之前将重做日志数据写入磁盘即可运行。因此，如果您有更新、插入或删除许多行的事务，增加日志缓冲区的大小可以节省磁盘 I/O。

innodb_flush_log_at_trx_commit 变量控制日志缓冲区的内容如何写入和刷新到磁盘。 innodb_flush_log_at_timeout 变量控制日志刷新频率。


### 更改缓冲区（Change Buffer）
更改缓冲区也叫插入缓冲区（Insert Buffer）是一种特殊的数据结构，当这些页面不在缓冲池中时，它会缓存对二级索引页面的更改。可能由 INSERT、UPDATE 或 DELETE 操作 (DML) 产生的缓冲更改稍后会在其他读取操作将页面加载到缓冲池中时合并。

![Change Buffer](https://dev.mysql.com/doc/refman/5.7/en/images/innodb-change-buffer.png)

与聚集索引不同，二级索引通常是非唯一的，并且以相对随机的顺序插入二级索引。同样，删除和更新可能会影响索引树中不相邻的二级索引页。当其他操作将受影响的页面读入缓冲池时，稍后合并缓存的更改可避免将二级索引页面从磁盘读入缓冲池所需的大量随机访问 I/O。
在系统大部分空闲时或缓慢关闭期间运行的清除操作会定期将更新的索引页写入磁盘。与立即将每个值写入磁盘相比，清除操作可以更有效地为一系列索引值写入磁盘块。
当有许多受影响的行和许多二级索引要更新时，更改缓冲区合并可能需要几个小时。在此期间，磁盘 I/O 增加，这可能会导致磁盘绑定查询显着减慢。更改缓冲区合并也可能在提交事务后继续发生，甚至在服务器关闭并重新启动后。
在内存中，变化缓冲区占据缓冲池的一部分。在磁盘上，更改缓冲区是系统表空间的一部分，当数据库服务器关闭时，索引更改将被缓冲。
更改缓冲区中缓存的数据类型由 innodb_change_buffering 变量控制。有关详细信息，请参阅配置更改缓冲。您还可以配置最大更改缓冲区大小。有关详细信息，请参阅配置更改缓冲区的最大大小。
如果索引包含降序索引列或主键包含降序索引列，则二级索引不支持更改缓冲。

但是，更改缓冲区占用了缓冲池的一部分，减少了可用于缓存数据页的内存。如果工作集几乎适合缓冲池，或者如果您的表的二级索引相对较少，则禁用更改缓冲可能会有用。如果工作数据集完全适合缓冲池，则更改缓冲不会造成额外开销，因为它仅适用于不在缓冲池中的页面。


innodb_change_buffering 变量控制 InnoDB 执行更改缓冲的程度。您可以为插入、删除操作（当索引记录最初被标记为删除时）和清除操作（当索引记录被物理删除时）启用或禁用缓冲。更新操作是插入和删除的组合。默认的 innodb_change_buffering 值为 all。

允许的 innodb_change_buffering 值包括：
* all，默认值：缓冲区插入、删除标记操作和清除。
* none，不要缓冲任何操作。
* inserts，缓冲区插入操作。
* deletes，缓冲区删除标记操作。
* changes，缓冲插入和删除标记操作。
* purges，缓冲在后台发生的物理删除操作。

innodb_change_buffer_max_size 变量允许将更改缓冲区的最大大小配置为缓冲池总大小的百分比。默认情况下，innodb_change_buffer_max_size 设置为 25。最大设置为 50。
考虑在具有大量插入、更新和删除活动的 MySQL 服务器上增加 innodb_change_buffer_max_size，其中更改缓冲区合并跟不上新的更改缓冲区条目，导致更改缓冲区达到其最大大小限制。
考虑在具有用于报告的静态数据的 MySQL 服务器上减少 innodb_change_buffer_max_size，或者如果更改缓冲区消耗过多与缓冲池共享的内存空间，导致页面比预期更快地从缓冲池中老化。
使用具有代表性的工作负载测试不同的设置以确定最佳配置。 innodb_change_buffer_max_size 变量是动态的，它允许在不重新启动服务器的情况下修改设置。

```sql
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
 insert 0, delete mark 0, delete 0
discarded operations:
 insert 0, delete mark 0, delete 0
Hash table size 4425293, used cells 32, node heap has 1 buffer(s)
13577.57 hash searches/s, 202.47 non-hash searches/s
```

### 缓存池（Buffer Pool）
缓冲池是主内存中的一个区域，InnoDB 在访问时缓存表和索引数据。缓冲池允许直接从内存访问频繁使用的数据，从而加快处理速度。在专用服务器上，通常会将高达 80% 的物理内存分配给缓冲池。
为了提高大容量读取操作的效率，缓冲池被分成可能包含多行的页面。为了缓存管理的效率，缓冲池被实现为页面链表；很少使用的数据使用最近最少使用 (LRU) 算法的变体从缓存中老化。

缓冲池使用 LRU 算法的变体作为列表进行管理。当需要空间将新页面添加到缓冲池时，最近最少使用的页面将被逐出，并将新页面添加到列表的中间。这种中点插入策略将列表视为两个子列表：
* 在头部，最近访问的新（“年轻”）页面的子列表
* 在尾部，最近较少访问的旧页面的子列表

![Buffer Pool List](https://dev.mysql.com/doc/refman/5.7/en/images/innodb-buffer-pool-list.png)

默认情况下，算法运行如下：
* 缓冲池的 3/8 专门用于旧子列表。
* 列表的中点是新子列表的尾部与旧子列表的头部相交的边界。
* 当 InnoDB 将一个页面读入缓冲池时，它最初将其插入到中点（旧子列表的头部）。可以读取页面，因为它是用户启动的操作（例如 SQL 查询）所必需的，或者作为 InnoDB 自动执行的预读操作的一部分。
* 访问旧子列表中的页面使其“年轻”，将其移动到新子列表的头部。如果页面是因为用户启动的操作需要它而被读取的，则第一次访问会立即发生并且该页面成为新页面。如果页面是由于预读操作而被读取的，则第一次访问不会立即发生，并且在页面被逐出之前可能根本不会发生。
* 随着数据库的运行，缓冲池中未访问的页面通过向列表的尾部移动而“老化”。随着其他页面的更新，新旧子列表中的页面都会老化。随着在中点插入页面，旧子列表中的页面也会老化。最终，未使用的页面到达旧子列表的尾部并被逐出。

您可以配置缓冲池的各个方面以提高性能：
* 理想情况下，您将缓冲池的大小设置为尽可能大的值，为服务器上的其他进程留出足够的内存来运行而无需过多的分页。缓冲池越大，InnoDB 就越像一个内存数据库，一次从磁盘读取数据，然后在后续读取期间从内存访问数据。
* 在具有足够内存的 64 位系统上，您可以将缓冲池拆分为多个部分，以最大程度地减少并发操作之间对内存结构的争用。
* 您可以将经常访问的数据保留在内存中，而不管来自将大量不经常访问的数据带入缓冲池的操作的活动突然激增。
* 您可以控制如何以及何时执行预读请求以异步将页面预取到缓冲池中，以预期很快需要这些页面。
* 您可以控制何时发生后台刷新以及是否根据工作负载动态调整刷新率。
* 您可以配置 InnoDB 如何保留当前缓冲池状态，以避免在服务器重启后出现漫长的预热期。

可以使用 SHOW ENGINE INNODB STATUS 访问的 InnoDB 标准监视器输出提供有关缓冲池操作的指标。缓冲池指标位于 InnoDB 标准监视器输出的 BUFFER POOL AND MEMORY 部分：
```sql
----------------------
BUFFER POOL AND MEMORY
----------------------
Total large memory allocated 2198863872
Dictionary memory allocated 776332
Buffer pool size   131072
Free buffers       124908
Database pages     5720
Old database pages 2071
Modified db pages  910
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 4, not young 0
0.10 youngs/s, 0.00 non-youngs/s
Pages read 197, created 5523, written 5060
0.00 reads/s, 190.89 creates/s, 244.94 writes/s
Buffer pool hit rate 1000 / 1000, young-making rate 0 / 1000 not
0 / 1000
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read
ahead 0.00/s
LRU len: 5720, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
```


| Name | Description |
| --- | --- |
| Total memory allocated | 为缓冲池分配的总内存（以字节为单位）。 |
| Dictionary memory allocated | 为 InnoDB 数据字典分配的总内存（以字节为单位）。 |
| Buffer pool size | 分配给缓冲池的页面总大小。 |
| Free buffers | 缓冲池空闲列表的页面总大小。 |
| Database pages | 缓冲池 LRU 列表的页面总大小。 |
| Old database pages | 缓冲池旧 LRU 子列表的页面总大小。 |
| Modified db pages | 当前在缓冲池中修改的页数。 |
| Pending reads | 等待读入缓冲池的缓冲池页数。 |
| Pending writes LRU | 从 LRU 列表底部开始写入缓冲池中旧脏页的数量。 |
| Pending writes flush list | 检查点期间要刷新的缓冲池页面数。 |
| Pending writes single page | 缓冲池中待处理的独立页面写入数。 |
| Pages made young | 缓冲池 LRU 列表中年轻的页面总数（移动到“新”页面子列表的头部）。|
| Pages made not young | 缓冲池 LRU 列表中未变为年轻的页面总数（保留在“旧”子列表中但未变为年轻的页面）。 |
| youngs/s | 每秒平均访问缓冲池 LRU 列表中导致页面年轻的旧页面。 |
| non-youngs/s | 每秒平均访问缓冲池 LRU 列表中的旧页面，导致页面不年轻。 |
| Pages read | 从缓冲池中读取的总页数。 |
| Pages created | 在缓冲池中创建的页面总数。 |
| Pages written | 从缓冲池中写入的总页数。 |
| reads/s | 每秒平均读取缓冲池页数。 |
| creates/s | 每秒创建的缓冲池页的平均数。 |
| writes/s | 每秒平均写入缓冲池页数。 |
| Buffer pool hit rate | 从缓冲池读取页面与从磁盘存储读取页面的缓冲池页面命中率。 |
| young-making rate | 页面访问导致页面年轻化的平均命中率。有关详细信息，请参阅此表后面的注释。 |
| not (young-making rate) | 页面访问未导致页面年轻化的平均命中率。有关详细信息，请参阅此表后面的注释。 |
| Pages read ahead | 预读操作的每秒平均值。 |
| Pages evicted without access | 没有从缓冲池中访问而被逐出的页面的每秒平均值。 |
| Random read ahead | 随机预读操作的每秒平均值。 |
| LRU len | 缓冲池 LRU 列表的页面总大小。 |
| unzip_LRU len | 缓冲池 unzip_LRU 列表的长度（以页为单位）。 |
| I/O sum | 访问的缓冲池 LRU 列表页总数。 |
| I/O cur | 当前时间间隔内访问的缓冲池 LRU 列表页总数。 |
| I/O unzip sum | 解压缩的缓冲池 unzip_LRU 列表页总数。 |
| I/O unzip cur | 当前时间间隔内解压缩的缓冲池 unzip_LRU 列表页总数。 |


* youngs/s 指标仅适用于旧页面。它基于页面访问次数。给定页面可以有多次访问，所有这些都被计算在内。如果在没有大扫描发生时看到非常低的 youngs/s 值，请考虑减少延迟时间或增加用于旧子列表的缓冲池的百分比。增加百分比会使旧的子列表变大，从而使该子列表中的页面移动到尾部的时间更长，从而增加了再次访问这些页面并使其成为年轻页面的可能性。请参阅第 14.8.3.3 节，“使缓冲池具有抗扫描性”。
* non-youngs/s 指标仅适用于旧页面。它基于页面访问次数。给定页面可以有多次访问，所有这些都被计算在内。如果在执行大型表扫描时没有看到更高的非 youngs/s 值（以及更高的 youngs/s 值），请增加延迟值。请参阅第 14.8.3.3 节，“使缓冲池具有抗扫描性”。
* 年轻化率考虑了所有缓冲池页面访问，而不仅仅是对旧子列表中页面的访问。年轻制造率和未制造率通常不会加到总缓冲池命中率中。旧子列表中的页面命中导致页面移动到新子列表，但新子列表中的页面命中导致页面仅在距离头部一定距离时移动到列表头部。
* not (young-making rate) 是由于未满足 innodb_old_blocks_time 定义的延迟，或由于新子列表中的页面命中未导致页面被更新，页面访问未导致页面年轻的平均命中率移到头部。此速率考虑了所有缓冲池页面访问，而不仅仅是对旧子列表中页面的访问。

缓冲池服务器状态变量和 INNODB_BUFFER_POOL_STATS 表提供了许多在 InnoDB 标准监视器输出中发现的相同缓冲池指标。


#### 预读
预读请求是一种 I/O 请求，用于异步预取缓冲池中的多个页面，以预期很快需要这些页面。这些请求在一个范围内引入所有页面。 InnoDB 使用两种预读算法来提高 I/O 性能：

线性预读是一种根据缓冲池中被顺序访问的页面来预测可能很快需要哪些页面的技术。您可以通过使用配置参数 innodb_read_ahead_threshold 调整触发异步读取请求所需的顺序页面访问次数来控制 InnoDB 何时执行预读操作。在加入这个参数之前，InnoDB只会在读到当前extent的最后一页时才计算是否对整个next extent发出异步预取请求。

随机预读是一种根据缓冲池中已有的页面预测何时可能很快需要页面的技术，而不管这些页面的读取顺序如何。如果在缓冲池中发现来自同一范围的 13 个连续页面，则 InnoDB 异步发出请求以预取该范围的剩余页面。要启用此功能，请将配置变量 innodb_random_read_ahead 设置为 ON。

SHOW ENGINE INNODB STATUS 命令显示统计信息以帮助您评估预读算法的有效性。统计信息包括以下全局状态变量的计数器信息：
* Innodb_buffer_pool_read_ahead
* Innodb_buffer_pool_read_ahead_evicted
* Innodb_buffer_pool_read_ahead_rnd

在微调 innodb_random_read_ahead 设置时，此信息很有用。


### 双写缓冲区（Doublewrite Buffer）
双写缓冲区是一个存储区域，在将页面写入 InnoDB 数据文件中的适当位置之前，InnoDB 会在其中写入从缓冲池中刷新的页面。如果在页面写入过程中有操作系统、存储子系统或意外的 mysqld 进程退出，InnoDB 可以在崩溃恢复期间从双写缓冲区中找到该页面的良好副本。

虽然数据被写入两次，但双写缓冲区不需要两倍的 I/O 开销或两倍的 I/O 操作。数据以大的顺序块写入双写缓冲区，通过对操作系统的单个 fsync() 调用（innodb_flush_method 设置为 O_DIRECT_NO_FSYNC 的情况除外）。

在大多数情况下，默认情况下启用双写缓冲区。要禁用双写缓冲区，请将 innodb_doublewrite 设置为 0。

如果系统表空间文件（“ibdata 文件”）位于支持原子写入的 Fusion-io 设备上，双写缓冲将自动禁用，并且 Fusion-io 原子写入用于所有数据文件。由于双写缓冲区设置是全局的，因此对于驻留在非 Fusion-io 硬件上的数据文件，双写缓冲区也被禁用。此功能仅在 Fusion-io 硬件上受支持，并且仅在 Linux 上为 Fusion-io NVMFS 启用。要充分利用此功能，建议将 innodb_flush_method 设置为 O_DIRECT。




## 锁（Lock）

### 共享锁和独占锁（Shared and Exclusive Locks）
InnoDB 实现标准的行级锁定，其中有两种类型的锁，共享 (S) 锁和排它 (X) 锁。
共享 (S) 锁允许持有锁的事务读取一行。
排他 (X) 锁允许持有锁的事务更新或删除行。
如果事务 T1 在行 r 上持有共享 (S) 锁，则来自某个不同事务 T2 的请求在行 r 上的锁将按如下方式处理：
可以立即授予 T2 的 S 锁请求。结果，T1 和 T2 都持有 r 上的 S 锁。
不能立即授予 T2 对 X 锁的请求。
如果事务 T1 在行 r 上持有排他 (X) 锁，则无法立即授予来自某个不同事务 T2 对 r 上任一类型锁的请求。相反，事务 T2 必须等待事务 T1 释放它对行 r 的锁定。

### 意向锁（Intention Locks）
InnoDB 支持多粒度锁定，允许行锁和表锁共存。例如，诸如 LOCK TABLES ... WRITE 之类的语句在指定的表上获取排他锁（X 锁）。为了使多粒度级别的锁定变得可行，InnoDB 使用意向锁。意向锁是表级锁，指示事务稍后对表中的行需要哪种类型的锁（共享或独占）。意向锁有两种类型：
* 意向共享锁 (IS) 表示事务打算在表中的各个行上设置共享锁。
* 意向排他锁 (IX) 表示事务打算在表中的各个行上设置排他锁。

例如，SELECT ... LOCK IN SHARE MODE 设置一个 IS 锁，而 SELECT ... FOR UPDATE 设置一个 IX 锁。

意向锁定协议如下：
* 在事务可以获取表中行的共享锁之前，它必须首先获取表上的 IS 锁或更强锁。
* 在事务可以获取表中一行的排他锁之前，它必须首先获取表上的 IX 锁。

下表总结了表级锁类型兼容性：

|  | `X` | `IX` | `S` | `IS` |
| --- | --- | --- | --- | --- |
| `X` | Conflict | Conflict | Conflict | Conflict |
| `IX` | Conflict | Compatible | Conflict | Compatible |
| `S` | Conflict | Conflict | Compatible | Compatible |
| `IS` | Conflict | Compatible | Compatible | Compatible |

如果请求事务与现有锁兼容，则将锁授予请求事务，但如果它与现有锁冲突，则不会授予该锁。事务等待，直到释放冲突的现有锁。如果锁定请求与现有锁定冲突并且由于会导致死锁而无法授予，则会发生错误。

意向锁不会阻塞除完整表请求之外的任何内容（例如，LOCK TABLES ... WRITE）。意向锁的主要目的是表明有人正在锁定一行，或者将要锁定表中的一行。


### 记录锁（Record Locks）
记录锁是索引记录上的锁。例如，SELECT c1 FROM t WHERE c1 = 10 FOR UPDATE；防止任何其他事务插入、更新或删除 t.c1 值为 10 的行。
记录锁总是锁定索引记录，即使表没有定义索引。对于这种情况，InnoDB 创建一个隐藏的聚簇索引并使用该索引进行记录锁定。

### 间隙锁（Gap Locks）
间隙锁是在索引记录之间的间隙上的锁，或者是在第一条索引记录之前或最后一条索引记录之后的间隙上的锁。例如，SELECT c1 FROM t WHERE c1 BETWEEN 10 and 20 FOR UPDATE；防止其他事务将值 15 插入到列 t.c1 中，无论该列中是否已经存在任何此类值，因为该范围内所有现有值之间的间隙都已锁定。

间隙可能跨越单个索引值、多个索引值，甚至是空的。
间隙锁是性能和并发性之间权衡的一部分，并且用于某些事务隔离级别而不是其他事务隔离级别。
对于使用唯一索引锁定行以搜索唯一行的语句，不需要间隙锁定。 （这不包括搜索条件只包括多列唯一索引的部分列的情况；这种情况下确实会发生间隙锁定。）例如，如果id列有一个唯一索引，下面的语句只使用id 值为 100 的行的索引记录锁，其他会话是否在前面的间隙中插入行并不重要：

```sql
SELECT * FROM child WHERE id = 100;
```

如果 id 没有索引或具有非唯一索引，则该语句会锁定前面的间隙。
这里还值得注意的是，不同事务可以在间隙上持有冲突锁。例如，事务 A 可以在一个间隙上持有一个共享间隙锁（间隙 S 锁），而事务 B 在同一间隙上持有一个独占间隙锁（间隙 X 锁）。允许冲突间隙锁的原因是，如果从索引中清除记录，则必须合并不同事务在记录上持有的间隙锁。
InnoDB 中的间隙锁是“纯粹抑制性的”，这意味着它们的唯一目的是防止其他事务插入间隙。间隙锁可以共存。一个事务获取的间隙锁不会阻止另一个事务在同一间隙上获取间隙锁。共享和排他间隙锁之间没有区别。它们彼此不冲突，并且它们执行相同的功能。
可以明确禁用间隙锁定。如果您将事务隔离级别更改为 READ COMMITTED 或启用 innodb_locks_unsafe_for_binlog 系统变量（现已弃用），则会发生这种情况。在这种情况下，间隙锁定在搜索和索引扫描中被禁用，并且仅用于外键约束检查和重复键检查。
使用 READ COMMITTED 隔离级别或启用 innodb_locks_unsafe_for_binlog 也有其他影响。在 MySQL 评估 WHERE 条件后，释放不匹配行的记录锁。对于 UPDATE 语句，InnoDB 执行“半一致”读取，这样它将最新提交的版本返回给 MySQL，以便 MySQL 可以确定该行是否匹配 UPDATE 的 WHERE 条件。

### Next-Key Locks
Next-Key Locks 是索引记录上的记录锁和索引记录之前的间隙上的间隙锁的组合。
InnoDB 执行行级锁定的方式是，当它搜索或扫描表索引时，它会在遇到的索引记录上设置共享或排他锁。因此，行级锁实际上是索引记录锁。索引记录上的下一个键锁也会影响该索引记录之前的“间隙”。也就是说，下一个键锁是索引记录锁加上索引记录之前的间隙上的间隙锁。如果一个会话在索引中的记录 R 上具有共享锁或排他锁，则另一个会话不能在索引顺序中紧接在 R 之前的间隙中插入新的索引记录。
假设一个索引包含值 10、11、13 和 20。该索引可能的 next-key 锁涵盖以下区间，其中圆括号表示排除区间端点，方括号表示包含端点：

```sql
(negative infinity, 10]
(10, 11]
(11, 13]
(13, 20]
(20, positive infinity)
```

对于最后一个时间间隔，next-key 锁锁定索引中最大值上方的间隙以及具有比索引中实际值更高的值的“supremum”伪记录。 supremum 不是真正的索引记录，因此，实际上，这个下一个键锁只锁定最大索引值之后的间隙。

默认情况下，InnoDB 在 REPEATABLE READ 事务隔离级别运行。在这种情况下，InnoDB 使用 next-key 锁进行搜索和索引扫描，以防止出现幻读。



### 插入意向锁（Insert Intention Locks）
插入意图锁是一种在行插入之前由 INSERT 操作设置的间隙锁。这个锁表示插入的意图，这样插入到同一个索引间隙中的多个事务如果没有插入到间隙中的相同位置，则不需要相互等待。假设有值为 4 和 7 的索引记录。分别尝试插入值 5 和 6 的单独事务，在获得对插入行的排他锁之前，每个事务都使用插入意向锁锁定 4 和 7 之间的间隙，但不要互相阻塞，因为这些行是不冲突的。



### 自增锁（AUTO-INC Locks）
AUTO-INC 锁是一种特殊的表级锁，由插入到具有 AUTO_INCREMENT 列的表中的事务获取。在最简单的情况下，如果一个事务正在向表中插入值，则任何其他事务必须等待自己向该表中插入，以便第一个事务插入的行接收连续的主键值。

innodb_autoinc_lock_mode 变量控制用于自动增量锁定的算法。它允许您选择如何在可预测的自动增量值序列和插入操作的最大并发性之间进行权衡。


### mvcc

### 死锁


## 临时表

## 索引

### 聚簇索引和二级索引（Clustered and Secondary Indexes）
每个 InnoDB 表都有一个特殊的索引，称为聚簇索引，用于存储行数据。通常，聚簇索引与主键同义。为了从查询、插入和其他数据库操作中获得最佳性能，了解 InnoDB 如何使用聚簇索引来优化常见的查找和 DML 操作非常重要。
当您在表上定义 PRIMARY KEY 时，InnoDB 将其用作聚簇索引。应该为每个表定义一个主键。如果没有逻辑唯一且非空的列或列集来使用主键，则添加一个自增列。自动递增列值是唯一的，并在插入新行时自动添加。
如果你没有为表定义 PRIMARY KEY，InnoDB 使用第一个 UNIQUE 索引，所有键列都定义为 NOT NULL 作为聚簇索引。
如果表没有 PRIMARY KEY 或合适的 UNIQUE 索引，InnoDB 会在包含行 ID 值的合成列上生成一个名为 GEN_CLUST_INDEX 的隐藏聚簇索引。这些行按 InnoDB 分配的行 ID 排序。行 ID 是一个 6 字节的字段，随着插入新行而单调增加。因此，按行 ID 排序的行在物理上是按插入顺序排列的。

通过聚簇索引访问行很快，因为索引搜索直接指向包含行数据的页面。如果表很大，与使用与索引记录不同的页来存储行数据的存储组织相比，聚集索引架构通常可以节省磁盘 I/O 操作。

聚簇索引以外的索引称为二级索引。在 InnoDB 中，二级索引中的每条记录都包含该行的主键列，以及为二级索引指定的列。 InnoDB 使用这个主键值来搜索聚集索引中的行。
如果主键很长，二级索引会占用更多的空间，所以主键越短越好。

### 索引物理存储
除了空间索引，InnoDB 索引都是 B 树数据结构。空间索引使用 R 树，这是用于索引多维数据的专用数据结构。索引记录存储在其 B 树或 R 树数据结构的叶页中。索引页的默认大小为 16KB。页面大小由 MySQL 实例初始化时的 innodb_page_size 设置决定。请参阅第 14.8.1 节，“InnoDB 启动配置”。
当新记录插入到 InnoDB 聚簇索引中时，InnoDB 会尝试留出 1/16 的页面以供将来插入和更新索引记录。如果按顺序（升序或降序）插入索引记录，则生成的索引页大约为 15/16 满。如果记录以随机顺序插入，则页面从 1/2 到 15/16 满。
InnoDB 在创建或重建 B 树索引时执行批量加载。这种创建索引的方法称为排序索引构建。 innodb_fill_factor 变量定义在排序索引构建期间填充的每个 B 树页面上的空间百分比，剩余空间保留用于未来索引增长。空间索引不支持排序索引构建。有关详细信息，请参阅第 14.6.2.3 节，“排序索引构建”。 innodb_fill_factor 设置为 100 时，聚集索引页中有 1/16 的空间可用于未来的索引增长。
如果 InnoDB 索引页面的填充因子低于 MERGE_THRESHOLD（如果未指定则默认为 50%），InnoDB 会尝试收缩索引树以释放页面。 MERGE_THRESHOLD 设置适用于 B 树和 R 树索引。

### 排序索引构建
InnoDB 在创建或重建索引时执行批量加载，而不是一次插入一条索引记录。这种创建索引的方法也称为排序索引构建。空间索引不支持排序索引构建。
索引构建分为三个阶段。第一阶段扫描聚簇索引，生成索引条目并添加到排序缓冲区中。当排序缓冲区变满时，条目将被排序并写出到临时中间文件。此过程也称为“运行”。在第二阶段，将一个或多个运行写入临时中间文件，对文件中的所有条目执行合并排序。在第三个也是最后一个阶段，排序后的条目被插入到 B 树中。
在引入排序索引构建之前，索引条目是使用插入 API 一次一条记录插入到 B 树中的。此方法涉及打开 B 树游标以查找插入位置，然后使用乐观插入将条目插入到 B 树页面中。如果由于页面已满而导致插入失败，则将执行悲观插入，这涉及打开 B 树游标并根据需要拆分和合并 B 树节点以为条目找到空间。这种“自上而下”建立索引的方法的缺点是搜索插入位置的成本和 B 树节点的不断拆分和合并。
排序索引构建使用“自下而上”的方法来构建索引。使用这种方法，对最右边的叶页的引用将保存在 B 树的所有级别。在必要的 B 树深度分配最右边的叶页，并根据它们的排序顺序插入条目。一旦叶页已满，节点指针将附加到父页，并为下一次插入分配同级叶页。此过程一直持续到插入所有条目为止，这可能会导致插入到根级别。分配同级页面时，释放对先前固定的叶子页面的引用，新分配的叶子页面成为最右边的叶子页面和新的默认插入位置。

要为将来的索引增长留出空间，可以使用 innodb_fill_factor 变量来保留一定百分比的 B 树页面空间。例如，将 innodb_fill_factor 设置为 80 在排序索引构建期间保留 B 树页面中 20% 的空间。此设置适用于 B 树叶页和非叶页。它不适用于用于 TEXT 或 BLOB 条目的外部页面。保留的空间量可能与配置的不完全相同，因为 innodb_fill_factor 值被解释为提示而不是硬限制。

全文索引支持排序索引构建。以前，SQL 用于将条目插入全文索引。

对于压缩表，以前的索引创建方法将条目附加到压缩页和未压缩页。当修改日志（表示压缩页面上的可用空间）变满时，将重新压缩压缩页面。如果由于空间不足导致压缩失败，页面将被拆分。使用排序索引构建，条目仅附加到未压缩的页面。当未压缩的页面变满时，它会被压缩。自适应填充用于确保大多数情况下压缩成功，但如果压缩失败，则会拆分页面并再次尝试压缩。这个过程一直持续到压缩成功。有关 B 树页面压缩的更多信息，请参阅第 14.9.1.5 节，“InnoDB 表的压缩工作原理”。

在排序索引构建期间禁用重做日志记录。相反，有一个检查点可确保索引构建能够承受意外退出或失败。检查点强制将所有脏页写入磁盘。在排序索引构建期间，页面清理器线程会定期收到信号以刷新脏页，以确保可以快速处理检查点操作。通常，当干净页面的数量低于设定的阈值时，页面清理器线程会刷新脏页。对于排序索引构建，脏页会被及时刷新以减少检查点开销并并行化 I/O 和 CPU 活动。

排序的索引构建可能会导致优化器统计信息与以前的索引创建方法生成的统计信息不同。预计不会影响工作负载性能的统计差异是由于用于填充索引的算法不同所致。

### 全文索引
[文档](https://dev.mysql.com/doc/refman/5.7/en/innodb-fulltext-index.html)
全文索引是在基于文本的列（CHAR、VARCHAR 或 TEXT 列）上创建的，以加快对这些列中包含的数据的查询和 DML 操作。
全文索引被定义为 CREATE TABLE 语句的一部分，或者使用 ALTER TABLE 或 CREATE INDEX 添加到现有表中。
使用 MATCH() ... AGAINST 语法执行全文搜索。

InnoDB 全文索引采用倒排索引设计。倒排索引存储单词列表，对于每个单词，存储该单词出现的文档列表。为了支持邻近搜索，还存储每个单词的位置信息，作为字节偏移量。



### [索引优化](https://dev.mysql.com/doc/refman/5.7/en/optimization-indexes.html)


## 表空间（Tablespace）
### 系统表空间（System Tablespace）
系统表空间是InnoDB数据字典、doublewrite buffer、change buffer和undo logs的存储区。如果表是在系统表空间而不是 file-per-table 或通用表空间中创建的，它还可能包含表和索引数据。
系统表空间可以有一个或多个数据文件。默认情况下，在数据目录中创建一个名为 ibdata1 的单个系统表空间数据文件。系统表空间数据文件的大小和数量由 innodb_data_file_path 启动选项定义。有关配置信息，请参阅系统表空间数据文件配置。

### 文件表空间（File-Per-Table）
file-per-table 表空间包含单个 InnoDB 表的数据和索引，并存储在文件系统中的单个数据文件中。
InnoDB 默认在 file-per-table 表空间中创建表。此行为由 innodb_file_per_table 变量控制。禁用 innodb_file_per_table 会导致 InnoDB 在系统表空间中创建表。
innodb_file_per_table 设置可以在选项文件中指定或在运行时使用 SET GLOBAL 语句配置。在运行时更改设置需要足够的权限来设置全局系统变量。
在 MySQL 数据目录下的架构目录中的 .ibd 数据文件中创建一个文件每表表空间。 .ibd 文件以表 (table_name.ibd) 命名。
您可以使用 CREATE TABLE 语句的 DATA DIRECTORY 子句在数据目录外隐式创建一个 file-per-table 表空间数据文件。

File-per-table 表空间与共享表空间（例如系统表空间或通用表空间）相比具有以下优点：
* 在截断或删除在 file-per-table 表空间中创建的表后，磁盘空间将返回给操作系统。截断或删除存储在共享表空间中的表会在共享表空间数据文件中创建可用空间，该空间只能用于 InnoDB 数据。换句话说，共享表空间数据文件在表被截断或删除后不会缩小大小。
* 对驻留在共享表空间中的表执行表复制 ALTER TABLE 操作会增加表空间占用的磁盘空间量。此类操作可能需要与表中的数据加上索引一样多的额外空间。该空间不会像每个表的文件表空间那样释放回操作系统。
* 在驻留在 file-per-table 表空间中的表上执行时，TRUNCATE TABLE 性能更好。
* File-per-table 表空间数据文件可以在单独的存储设备上创建，用于 I/O 优化、空间管理或备份目的。
* 您可以从另一个 MySQL 实例导入驻留在 file-per-table 表空间中的表。
* 在 file-per-table 表空间中创建的表使用 Barracuda 文件格式。 Barracuda 文件格式启用与 DYNAMIC 和 COMPRESSED 行格式相关的功能。
* 存储在单个表空间数据文件中的表可以节省时间并提高在发生数据损坏、备份或二进制日志不可用或无法重新启动 MySQL 服务器实例时成功恢复的机会。
* 您可以使用 MySQL Enterprise Backup 快速备份或恢复在 file-per-table 表空间中创建的表，而不会中断其他 InnoDB 表的使用。这对于备份计划不同或需要备份频率较低的表是有益的。
* File-per-table 表空间允许通过监视表空间数据文件的大小来监视文件系统上的表大小。
* 当 innodb_flush_method 设置为 O_DIRECT 时，常见的 Linux 文件系统不允许并发写入单个文件，例如共享表空间数据文件。因此，将 file-per-table 表空间与此设置结合使用时可能会提高性能。
* 共享表空间中的表的大小受 64TB 表空间大小限制的限制。相比之下，每个 file-per-table 表空间的大小限制为 64TB，这为单个表的大小增长提供了充足的空间。

File-per-table 表空间与共享表空间（如系统表空间或通用表空间）相比具有以下缺点：
* 使用 file-per-table 表空间，每个表可能有未使用的空间，只能由同一个表的行使用，如果管理不当，可能会导致空间浪费。
* fsync 操作是在多个 file-per-table 数据文件而不是单个共享表空间数据文件上执行的。因为 fsync 操作是针对每个文件的，所以不能合并多个表的写操作，这会导致 fsync 操作的总数更高。
* mysqld 必须为每个 file-per-table 表空间保留一个打开的文件句柄，如果在 file-per-table 表空间中有许多表，这可能会影响性能。
* 当每个表都有自己的数据文件时，需要更多的文件描述符。
* 存在更多碎片的可能性，这会阻碍 DROP TABLE 和表扫描性能。但是，如果碎片得到管理，每个表的文件表空间可以提高这些操作的性能。
* 删除驻留在 file-per-table 表空间中的表时会扫描缓冲池，这对于大型缓冲池可能需要几秒钟。扫描是使用广泛的内部锁执行的，这可能会延迟其他操作。
* innodb_autoextend_increment 变量定义了在自动扩展共享表空间文件变满时扩展其大小的增量大小，不适用于 file-per-table 表空间文件，无论 innodb_autoextend_increment 设置如何，这些文件都是自动扩展的。最初的 file-per-table 表空间扩展是少量的，之后扩展以 4MB 的增量出现。

### 通用表空间（General Tablespaces）
通用表空间是使用 CREATE TABLESPACE 语法创建的共享 InnoDB 表空间。

### 撤消表空间（Undo Tablespaces）
撤消表空间包含撤消日志，这些记录是包含有关如何撤消事务对聚集索引记录的最新更改的信息的记录集合。
撤销日志默认存储在系统表空间中，但也可以存储在一个或多个撤销表空间中。使用撤消表空间可以减少任何一个表空间中撤消日志所需的空间量。撤消日志的 I/O 模式也使撤消表空间成为 SSD 存储的理想选择。
无法删除撤消表空间和这些表空间内的各个段。但是，可以截断存储在撤消表空间中的撤消日志。有关详细信息，请参阅截断撤消表空间。

### 临时表空间（Temporary Tablespace）
非压缩的、用户创建的临时表和磁盘内部临时表是在共享临时表空间中创建的。 innodb_temp_data_file_path 变量定义临时表空间数据文件的相对路径、名称、大小和属性。如果没有为 innodb_temp_data_file_path 指定值，则默认行为是在 innodb_data_home_dir 目录中创建一个名为 ibtmp1 的自动扩展数据文件，该文件略大于 12MB。
压缩临时表是使用 ROW_FORMAT=COMPRESSED 属性创建的临时表，在临时文件目录的 file-per-table 表空间中创建。
临时表空间在正常关闭或中止初始化时被删除，并在每次服务器启动时重新创建。临时表空间在创建时接收动态生成的空间 ID。如果无法创建临时表空间，则拒绝启动。如果服务器意外停止，临时表空间不会被删除。在这种情况下，数据库管理员可以手动删除临时表空间或重新启动服务器，这会自动删除并重新创建临时表空间。
临时表空间不能驻留在原始设备上。

Information Schema FILES 表提供有关 InnoDB 临时表空间的元数据。发出类似于此的查询以查看临时表空间元数据：
```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.FILES WHERE TABLESPACE_NAME='innodb_temporary'\G 数据库
```

Information Schema INNODB_TEMP_TABLE_INFO 表提供有关用户创建的临时表的元数据，这些临时表当前在 InnoDB 实例中处于活动状态。

默认情况下，临时表空间数据文件是自动扩展的，并根据需要增加大小以容纳磁盘上的临时表。例如，如果一个操作创建了一个大小为 20MB 的临时表，创建时默认大小为 12MB 的临时表空间数据文件将扩展大小以容纳它。当删除临时表时，释放的空间可以重新用于新的临时表，但数据文件仍保持扩展大小。
在使用大型临时表或广泛使用临时表的环境中，自动扩展临时表空间数据文件可能会变大。使用临时表的长时间运行的查询也可能导致大型数据文件。

要回收临时表空间数据文件占用的磁盘空间，请重新启动 MySQL 服务器。重新启动服务器会根据 innodb_temp_data_file_path 定义的属性删除并重新创建临时表空间数据文件。

为防止临时数据文件变得太大，您可以配置 innodb_temp_data_file_path 变量以指定最大文件大小。例如：
```conf
[mysqld]
innodb_temp_data_file_path=ibtmp1:12M:autoextend:max:500M
```

当数据文件达到最大大小时，查询将失败并显示表已满的错误。配置 innodb_temp_data_file_path 需要重启服务器。

或者，配置 default_tmp_storage_engine 和 internal_tmp_disk_storage_engine 变量，它们分别定义用于用户创建的和磁盘上的内部临时表的存储引擎。默认情况下，这两个变量都设置为 InnoDB。 MyISAM 存储引擎为每个临时表使用一个单独的文件，该文件在删除临时表时被删除。


## 事务（Transaction）

### ACID模型
ACID 模型是一组数据库设计原则，强调对业务数据和关键任务应用程序很重要的可靠性方面。 MySQL 包括 InnoDB 存储引擎等组件，这些组件严格遵守 ACID 模型，因此数据不会损坏，结果也不会因软件崩溃和硬件故障等异常情况而失真。当您依赖 ACID 兼容功能时，您不需要重新发明一致性检查和崩溃恢复机制。如果您有额外的软件保护措施、超可靠的硬件或可以容忍少量数据丢失或不一致的应用程序，您可以调整 MySQL 设置以牺牲一些 ACID 可靠性来换取更高的性能或吞吐量。

* A（atomicity），ACID 模型的原子性方面主要涉及 InnoDB 事务。相关的 MySQL 特性包括：
	- autocommit设置
	- COMMIT语句
	- ROLLBACK语句
* C（consistency），ACID 模型的一致性方面主要涉及内部 InnoDB 处理以保护数据免于崩溃。相关的 MySQL 特性包括：
	- InnoDB 双写缓冲区
	- InnoDB 崩溃恢复
* I（isolation），ACID 模型的隔离方面主要涉及 InnoDB 事务，特别是应用于每个事务的隔离级别。相关的 MySQL 特性包括：
	- autocommit设置
	- 事务隔离级别和 SET TRANSACTION 语句
	- InnoDB 锁定的底层细节
* D（durability），ACID 模型的持久性方面涉及与特定硬件配置交互的 MySQL 软件功能。由于有多种可能性取决于您的 CPU、网络和存储设备的能力，因此在这方面提供具体指导方针是最复杂的。 （这些指导方针可能采取“购买新硬件”的形式。）相关的 MySQL 特性包括：
	- InnoDB 双写缓冲区
	- innodb_flush_log_at_trx_commit 变量
	- sync_binlog 变量
	- innodb_file_per_table 变量
	- 存储设备（例如磁盘驱动器、SSD 或 RAID 阵列）中的写入缓冲区
	- 存储设备中的电池供电缓存
	- 用于运行 MySQL 的操作系统，特别是它对 fsync() 系统调用的支持
	- 不间断电源 (UPS) 保护运行 MySQL 服务器和存储 MySQL 数据的所有计算机服务器和存储设备的电力
	- 您的备份策略，例如备份频率和类型，以及备份保留期
	- 对于分布式或托管数据应用程序，MySQL 服务器硬件所在的数据中心的特定特征，以及数据中心之间的网络连接

[事务隔离级别](https://dev.mysql.com/doc/refman/5.7/en/innodb-transaction-isolation-levels.html)
事务隔离是数据库处理的基础之一。隔离是首字母缩略词 ACID 中的 I；隔离级别是在多个事务同时进行更改和执行查询时微调性能与结果的可靠性、一致性和可再现性之间的平衡的设置。
InnoDB 提供 SQL:1992 标准描述的所有四种事务隔离级别：READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ 和 SERIALIZABLE。 InnoDB 的默认隔离级别是可重复读。
用户可以使用 SET TRANSACTION 语句更改单个会话或所有后续连接的隔离级别。要为所有连接设置服务器的默认隔离级别，请在命令行或选项文件中使用 --transaction-isolation 选项。

InnoDB 使用不同的锁定策略支持此处描述的每个事务隔离级别。对于 ACID 合规性很重要的关键数据操作，您可以使用默认的 REPEATABLE READ 级别强制执行高度一致性。或者，您可以使用 READ COMMITTED 或什至 READ UNCOMMITTED 放宽一致性规则，在批量报告等情况下，精确一致性和可重复结果不如最小化锁定开销重要。 SERIALIZABLE 执行比 REPEATABLE READ 更严格的规则，主要用于特殊情况，例如 XA 事务以及解决并发和死锁问题。






### 隔离性和隔离级别

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



## group by

## order by

## count

## join

## 自增ID

# 应用篇

## 主从

## 读写分离

## 慢日志

## 优化查询


## 分库分表分区

## 备份和恢复

## 用户和权限




