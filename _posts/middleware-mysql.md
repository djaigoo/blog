---
# 简介篇
## MySQL
## 其他数据库
## Benchmark
## InnoDB
## MyISAM
## Memory
# 基础篇-数据
## 数据类型
## 常用函数

[详细文档](https://dev.mysql.com/doc/refman/5.7/en/functions.html)

##### 数值函数

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

## 数据库约束
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



## 变量

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


# 基础篇-SQL
## 数据定义语句（Data-Definition-Statements）
Data Definition Statements 定义相关结构，包括：数据库（DATABASE）、事件（EVENT）、方法（FUNCTION）、索引（INDEX）、存储过程（PROCEDURE）、数据表（TABLE）、触发器（TRIGGER）、视图（VIEW）等。
### CREATE
CREATE 用于创建相关结构，包括：数据库（DATABASE）、事件（EVENT）、方法（FUNCTION）、索引（INDEX）、存储过程（PROCEDURE）、数据表（TABLE）、触发器（TRIGGER）、视图（VIEW）等。

```sql
CREATE DATABASE
CREATE EVENT
CREATE FUNCTION
CREATE FUNCTION UDF
CREATE INDEX
CREATE LOGFILE GROUP
CREATE PROCEDURE
CREATE SERVER
CREATE TABLE
CREATE TABLESPACE
CREATE TRIGGER
CREATE USER
CREATE VIEW
```

#### CREATE DATABASE
```sql
```

#### CREATE EVENT
```sql
```

#### CREATE FUNCTION
```sql
```

#### CREATE INDEX
```sql
```

#### CREATE LOGFILE GROUP
```sql
```

#### CREATE PROCEDURE
```sql
```

#### CREATE FUNCTION
```sql
```

#### CREATE SERVER
```sql
```

#### CREATE TABLE
```sql
```

#### CREATE TABLESPACE
```sql
```

#### CREATE TRIGGER
```sql
```

#### CREATE VIEW
```sql
```

### ALTER
ALTER 用于修改相关结构，包括：数据库（DATABASE）、事件（EVENT）、方法（FUNCTION）、索引（INDEX）、存储过程（PROCEDURE）、数据表（TABLE）、触发器（TRIGGER）、视图（VIEW）等。\
```sql
ALTER DATABASE
ALTER EVENT
ALTER FUNCTION
ALTER INSTANCE
ALTER LOGFILE GROUP
ALTER PROCEDURE
ALTER SERVER
ALTER TABLE
ALTER TABLESPACE
ALTER USER
ALTER VIEW
```

#### ALTER DATABASE
```sql
```

#### ALTER EVENT
```sql
```

#### ALTER FUNCTION
```sql
```

#### ALTER INSTANCE
```sql
```

#### ALTER LOGFILE GROUP
```sql
```

#### ALTER PROCEDURE
```sql
```

#### ALTER SERVER
```sql
```

#### ALTER TABLE
```sql
```

#### ALTER TABLESPACE
```sql
```


### DROP
DROP 用于删除相关结构，包括：数据库（DATABASE）、事件（EVENT）、函数（FUNCTION）、索引（INDEX）、存储过程（PROCEDURE）、数据表（TABLE）、触发器（TRIGGER）、视图（VIEW）等。
```sql
DROP DATABASE
DROP EVENT
DROP FUNCTION
DROP FUNCTION UDF
DROP INDEX
DROP PROCEDURE
DROP SERVER
DROP TABLE
DROP TABLESPACE
DROP TRIGGER
DROP USER
DROP VIEW
```

#### DROP DATABASE
```sql
```

#### DROP EVENT
```sql
```

#### DROP FUNCTION
```sql
```

#### DROP INDEX
```sql
```

#### DROP LOGFILE GROUP
```sql
```

#### DROP PROCEDURE
```sql
```

#### DROP FUNCTION
```sql
```

#### DROP SERVER
```sql
```

#### DROP TABLE
```sql
```

#### DROP TABLESPACE
```sql
```

#### DROP TRIGGER
```sql
```

#### DROP VIEW
```sql
```

## 数据操作语句（Data-Manipulation-Statements）
### INSERT
INSERT 用于向表中添加数据，语法如下：
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

value:
    {expr | DEFAULT}

value_list:
    value [, value] ...

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
```

### UPDATE
语法：
```sql
UPDATE [LOW_PRIORITY] [IGNORE] table_reference
    SET assignment_list
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]

UPDATE [LOW_PRIORITY] [IGNORE] table_references
    SET assignment_list
    [WHERE where_condition]

value:
    {expr | DEFAULT}

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
```
### DELETE
```sql
DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]
```
### SELECT
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
### other
#### CALL
CALL 语句调用先前使用 CREATE PROCEDURE 定义的存储过程。
```sql
CALL sp_name([parameter[,...]])
CALL sp_name[()]
```
#### DO
DO 执行表达式但不返回任何结果。在大多数情况下，DO 是 SELECT expr, ... 的简写，但它的优点是当您不关心结果时速度稍快。
```sql
DO expr [, expr] ...
```

#### HANDLER
HANDLER 语句提供对表存储引擎接口的直接访问。它可用于 InnoDB 和 MyISAM 表。
HANDLER ... OPEN 语句打开一个表，使其可以使用后续的 HANDLER ... READ 语句访问。此表对象不被其他会话共享，并且在会话调用 HANDLER ... CLOSE 或会话终止之前不会关闭。


```sql
HANDLER tbl_name OPEN [ [AS] alias]

HANDLER tbl_name READ index_name { = | <= | >= | < | > } (value1,value2,...)
    [ WHERE where_condition ] [LIMIT ... ]
HANDLER tbl_name READ index_name { FIRST | NEXT | PREV | LAST }
    [ WHERE where_condition ] [LIMIT ... ]
HANDLER tbl_name READ { FIRST | NEXT }
    [ WHERE where_condition ] [LIMIT ... ]

HANDLER tbl_name CLOSE
```
#### REPLACE
REPLACE 的工作方式与 INSERT 完全相同，只是如果表中的旧行与 PRIMARY KEY 或 UNIQUE 索引的新行具有相同的值，则在插入新行之前删除旧行。
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

value:
    {expr | DEFAULT}

value_list:
    value [, value] ...

assignment:
    col_name = value

assignment_list:
    assignment [, assignment] ...
```
#### LOAD
##### LOAD DATA
```sql
LOAD DATA
    [LOW_PRIORITY | CONCURRENT] [LOCAL]
    INFILE 'file_name'
    [REPLACE | IGNORE]
    INTO TABLE tbl_name
    [PARTITION (partition_name [, partition_name] ...)]
    [CHARACTER SET charset_name]
    [{FIELDS | COLUMNS}
        [TERMINATED BY 'string']
        [[OPTIONALLY] ENCLOSED BY 'char']
        [ESCAPED BY 'char']
    ]
    [LINES
        [STARTING BY 'string']
        [TERMINATED BY 'string']
    ]
    [IGNORE number {LINES | ROWS}]
    [(col_name_or_user_var
        [, col_name_or_user_var] ...)]
    [SET col_name={expr | DEFAULT}
        [, col_name={expr | DEFAULT}] ...]
```

##### LOAD XML
```sql
LOAD XML
    [LOW_PRIORITY | CONCURRENT] [LOCAL]
    INFILE 'file_name'
    [REPLACE | IGNORE]
    INTO TABLE [db_name.]tbl_name
    [CHARACTER SET charset_name]
    [ROWS IDENTIFIED BY '<tagname>']
    [IGNORE number {LINES | ROWS}]
    [(field_name_or_user_var
        [, field_name_or_user_var] ...)]
    [SET col_name={expr | DEFAULT}
        [, col_name={expr | DEFAULT}] ...]
```
## 事务和锁定语句（Transactional-and-Locking-Statements）
### transaction
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

#### 隐式提交（Implicit Commit）

### SAVEPOINT
SAVEPOINT 语句设置一个名为标识符的命名事务保存点。如果当前事务有一个同名的保存点，则删除旧的保存点并设置一个新的保存点。
ROLLBACK TO SAVEPOINT 语句将事务回滚到指定的保存点而不终止事务。当前事务在设置保存点之后对行所做的修改在回滚中被撤消，但 InnoDB 不会释放在保存点之后存储在内存中的行锁。 （对于新插入的行，锁信息由该行存储的事务ID携带，锁不单独存储在内存中，此时在undo中释放行锁。）晚于指定保存点的时间将被删除。

```sql
SAVEPOINT identifier
ROLLBACK [WORK] TO [SAVEPOINT] identifier
RELEASE SAVEPOINT identifier
```
### LOCK TABLES
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
## 复合语句（Compound-Statements）
### BEGIN END
BEGIN ... END 语法用于编写复合语句，这些语句可以出现在存储程序（存储过程和函数、触发器和事件）中。复合语句可以包含多个语句，由 BEGIN 和 END 关键字括起来。 statement_list 表示一个或多个语句的列表，每个语句以分号 (;) 语句定界符终止。 statement_list 本身是可选的，所以空复合语句（BEGIN END）是合法的。
BEGIN ... END 语句允许嵌套执行。

语法如下：
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

要在带标签的构造中引用标签，请使用 ITERATE 或 LEAVE 语句。以下示例使用这些语句继续迭代或终止循环：
```sql
CREATE PROCEDURE doiterate(p1 INT)
BEGIN
  label1: LOOP
    SET p1 = p1 + 1;
    IF p1 < 10 THEN ITERATE label1; END IF;
    LEAVE label1;
  END LOOP label1;
END;
```

### DECLARE
DECLARE 语句用于声明变量（VARIABLE）、错误条件（CONDITION）、游标（CURSOR）、条件处理（HANDLER）等。
```sql
DECLARE VARIABLE
DECLARE CONDITION
DECLARE CURSOR
DECLARE HANDLER
```


#### DECLARE VARIABLE
```sql
DECLARE var_name [, var_name] ... type [DEFAULT value]
```
DECLARE VARIABLE 语句声明存储程序中的局部变量。要为变量提供默认值，请包含 DEFAULT 子句。该值可以指定为表达式；它不必是常数。如果缺少 DEFAULT 子句，则初始值为 NULL。
具有以下属性：
* 变量声明必须出现在游标或处理程序声明之前。
* 局部变量名称不区分大小写。允许的字符和引用规则与其他标识符相同。
* 局部变量的范围是声明它的 BEGIN ... END 块。可以在声明块内嵌套的块中引用变量，但声明同名变量的块除外。

因为局部变量仅在存储程序执行期间在范围内，所以在存储程序中创建的准备语句中不允许引用它们。准备好的语句范围是当前会话，而不是存储的程序，因此语句可以在程序结束后执行，此时变量将不再在范围内。例如，SELECT ... INTO local_var 不能用作准备语句。此限制也适用于存储过程和函数参数。
局部变量不应与表列同名。如果 SQL 语句，例如 SELECT ... INTO 语句，包含对列的引用和声明的具有相同名称的局部变量，则 MySQL 当前将引用解释为变量的名称。



#### DECLARE CONDITION
```sql
DECLARE condition_name CONDITION FOR condition_value

condition_value: {
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
}
```
DECLARE ... CONDITION 语句声明一个命名的错误条件，将名称与需要特定处理的条件相关联。该名称可以在后续的 DECLARE ... HANDLER 语句中引用。
条件声明必须出现在游标（CURSOR）或处理程序（HANDLER）声明之前。
DECLARE ... CONDITION 的条件值指示与条件名称关联的特定条件或条件类别。它可以采用以下形式：
* mysql_error_code：表示 MySQL 错误代码的整数文字。
* 不要使用 MySQL 错误代码 0，因为它表示成功而不是错误情况。有关 MySQL 错误代码的列表，请参阅服务器错误消息参考。
* SQLSTATE [VALUE] sqlstate_value：表示 SQLSTATE 值的 5 个字符的字符串文字。不要使用以“00”开头的 SQLSTATE 值，因为这些值表示成功而不是错误情况。有关 SQLSTATE 值的列表，请参阅服务器错误消息参考。


#### 游标（cursor）
```sql
DECLARE cursor_name CURSOR FOR select_statement
CLOSE cursor_name
FETCH [[NEXT] FROM] cursor_name INTO var_name [, var_name] ...
OPEN cursor_name
```

MySQL 支持存储程序中的游标。语法与嵌入式 SQL 中的一样。游标具有以下属性：
* 不敏感（Asensitive），服务器可能会也可能不会复制其结果表
* 只读（Read only），不可更新
* 不可滚动（Nonscrollable），只能单向遍历，不能跳行

游标声明必须出现在处理程序声明之前以及变量和条件声明之后。

#### DECLARE HANDLER
DECLARE ... HANDLER 语句指定处理一个或多个条件的处理程序。如果这些条件之一发生，则执行指定的语句。 statement 可以是简单的语句，例如 SET var_name = value，也可以是使用 BEGIN 和 END 编写的复合语句（请参阅第 13.6.1 节，“BEGIN ... END 复合语句”）。
处理程序声明必须出现在变量或条件声明之后。

handler_action 值指示处理程序在执行处理程序语句后采取的操作：
* CONTINUE：继续执行当前程序。
* EXIT：对于声明处理程序的 BEGIN ... END 复合语句，执行终止。即使条件发生在内部块中也是如此。
* UNDO：不支持。

```sql
DECLARE handler_action HANDLER
    FOR condition_value [, condition_value] ...
    statement

handler_action: {
    CONTINUE
  | EXIT
  | UNDO
}

condition_value: {
    mysql_error_code
  | SQLSTATE [VALUE] sqlstate_value
  | condition_name
  | SQLWARNING
  | NOT FOUND
  | SQLEXCEPTION
}
```

DECLARE ... HANDLER 的条件值指示激活处理程序的特定条件或条件类别。它可以采用以下形式：

* mysql_error_code：表示MySQL错误码的整型字面值，如1051表示“未知表”：
* SQLSTATE [VALUE] sqlstate_value：一个 5 个字符的字符串文字，表示 SQLSTATE 值，例如“42S01”以指定“未知表”：
* condition_name：先前使用 DECLARE ... CONDITION 指定的条件名称。条件名称可以与 MySQL 错误代码或 SQLSTATE 值相关联。
* SQLWARNING：以“01”开头的 SQLSTATE 值类别的简写。
* NOT FOUND：以“02”开头的 SQLSTATE 值类的简写。这在游标上下文中是相关的，用于控制游标到达数据集末尾时发生的情况。如果没有更多行可用，则会出现无数据条件，SQLSTATE 值为“02000”。要检测这种情况，您可以为它或 NOT FOUND 情况设置一个处理程序。
* SQLEXCEPTION：不以“00”、“01”或“02”开头的 SQLSTATE 值类的简写。



### Flow Control Statements
#### CASE
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

#### IF
```sql
IF search_condition THEN statement_list
    [ELSEIF search_condition THEN statement_list] ...
    [ELSE statement_list]
END IF
```

#### ITERATE
```sql
ITERATE label
```

#### LEAVE
```sql
LEAVE label
```

#### LOOP
```sql
[begin_label:] LOOP
    statement_list
END LOOP [end_label]
```

#### REPEAT
```sql
[begin_label:] REPEAT
    statement_list
UNTIL search_condition
END REPEAT [end_label]
```

#### RETURN
```sql
RETURN expr
```

#### WHILE
```sql
[begin_label:] WHILE search_condition DO
    statement_list
END WHILE [end_label]
```
## Database-Administration-Statements
### Account Management Statements
#### grant
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

object_type: {
    TABLE
  | FUNCTION
  | PROCEDURE
}

priv_level: {
    *
  | *.*
  | db_name.*
  | db_name.tbl_name
  | tbl_name
  | db_name.routine_name
}

user:
    (see Section 6.2.4, “Specifying Account Names”)

auth_option: {
    IDENTIFIED BY 'auth_string'
  | IDENTIFIED WITH auth_plugin
  | IDENTIFIED WITH auth_plugin BY 'auth_string'
  | IDENTIFIED WITH auth_plugin AS 'auth_string'
  | IDENTIFIED BY PASSWORD 'auth_string'
}

tls_option: {
    SSL
  | X509
  | CIPHER 'cipher'
  | ISSUER 'issuer'
  | SUBJECT 'subject'
}

resource_option: {
  | MAX_QUERIES_PER_HOUR count
  | MAX_UPDATES_PER_HOUR count
  | MAX_CONNECTIONS_PER_HOUR count
  | MAX_USER_CONNECTIONS count
}
```
#### revoke
### Table Maintenance Statements
### SET
### SHOW

## TCL
# 进阶篇
## 执行流程
## 日志
## 缓存
## 锁
## 内存引擎
## 临时表
## 事务
## 索引
## group-by
## order-by
## count
## join
## sql-mode
## 预读
# 应用篇
## 主从
## 读写分离
## 慢日志
## 优化查询
## 分库分表分区
## 备份和恢复
## 用户和权限
