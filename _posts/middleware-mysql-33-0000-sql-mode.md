---
author: djaigo
title: middleware-mysql-32-0000-sql-mode
categories:
  - null
date: 2023-03-29 19:50:40
tags:
---
通过命令`select @@sql_mode;`可以获取当前的sql_mode。

MySQL的sql_mode合理设置
sql_mode是个很容易被忽视的变量,默认值是空值,在这种设置下是可以允许一些非法操作的,比如允许一些非法数据的插入。在生产环境必须将这个值设置为严格模式,所以开发、测试环境的数据库也必须要设置,这样在开发测试阶段就可以发现问题.
sql model 常用来解决下面几类问题
* 通过设置sql mode, 可以完成不同严格程度的数据校验，有效地保障数据准备性。
* 通过设置sql model 为宽松模式，来保证大多数sql符合标准的sql语法，这样应用在不同数据库之间进行迁移时，则不需要对业务sql 进行较大的修改。
* 在不同数据库之间进行数据迁移之前，通过设置SQL Mode 可以使MySQL 上的数据更方便地迁移到目标数据库中。

sql_mode常用值如下: 
* `ONLY_FULL_GROUP_BY`：对于GROUP BY聚合操作,如果在SELECT中的列,没有在GROUP BY中出现,那么这个SQL是不合法的,因为列不在GROUP BY从句中
* `NO_AUTO_VALUE_ON_ZERO`：该值影响自增长列的插入。默认设置下,插入0或NULL代表生成下一个自增长值。如果用户 希望插入的值为0,而该列又是自增长的,那么这个选项就有用了。
* `STRICT_TRANS_TABLES`：在该模式下,如果一个值不能插入到一个事务表中,则中断当前的操作,对非事务表不做
* `NO_ZERO_IN_DATE`：在严格模式下,不允许日期和月份为零
* `NO_ZERO_DATE`：设置该值,mysql数据库不允许插入零日期,插入零日期会抛出错误而不是警告。
* `ERROR_FOR_DIVISION_BY_ZERO`：在INSERT或UPDATE过程中,如果数据被零除,则产生错误而非警告。如 果未给出该模式,那么数据被零除时MySQL返回NULL
* `NO_AUTO_CREATE_USER`：禁止GRANT创建密码为空的用户
* `NO_ENGINE_SUBSTITUTION`：如果需要的存储引擎被禁用或未编译,那么抛出错误。不设置此值时,用默认的存储引擎替代,并抛出一个异常
* `PIPES_AS_CONCAT`：将"||"视为字符串的连接操作符而非或运算符,这和Oracle数据库是一样的,也和字符串的拼接函数Concat相类似
* `ANSI_QUOTES`：启用`ANSI_QUOTES`后,不能用双引号来引用字符串,因为它被解释为识别符

如果使用mysql，为了继续保留大家使用oracle的习惯，可以对mysql的`sql_mode`设置如下:
在my.cnf添加如下配置
```conf
[mysqld]
sql_mode='ONLY_FULL_GROUP_BY,NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,PIPES_AS_CONCAT,ANSI_QUOTES'
```

MySQL5.6和MySQL5.7默认的sql_mode模式参数是不一样的,5.6的mode是`NO_ENGINE_SUBSTITUTION`，其实表示的是一个空值，相当于没有什么模式设置，可以理解为宽松模式。5.7的mode是`STRICT_TRANS_TABLES`，也就是严格模式。
如果设置的是宽松模式，那么我们在插入数据的时候，即便是给了一个错误的数据，也可能会被接受，并且不报错，例如：我在创建一个表时，该表中有一个字段为name，给name设置的字段类型时char(10)，如果我在插入数据的时候，其中name这个字段对应的有一条数据的长度超过了10，例如'1234567890abc'，超过了设定的字段长度10，那么不会报错，并且取前十个字符存上，也就是说你这个数据被存为了'1234567890',而'abc'就没有了，但是我们知道，我们给的这条数据是错误的，因为超过了字段长度，但是并没有报错，并且mysql自行处理并接受了，这就是宽松模式的效果，其实在开发、测试、生产等环境中，我们应该采用的是严格模式，出现这种错误，应该报错才对，所以MySQL5.7版本就将sql_mode默认值改为了严格模式，并且我们即便是用的MySQL5.6，也应该自行将其改为严格模式，而你记着，MySQL等等的这些数据库，都是想把关于数据的所有操作都自己包揽下来，包括数据的校验，其实好多时候，我们应该在自己开发的项目程序级别将这些校验给做了，虽然写项目的时候麻烦了一些步骤，但是这样做之后，我们在进行数据库迁移或者在项目的迁移时，就会方便很多，这个看你们自行来衡量。mysql除了数据校验之外，你慢慢的学习过程中会发现，它能够做的事情还有很多很多，将你程序中做的好多事情都包揽了。
改为严格模式后可能会存在的问题：若设置模式中包含了`NO_ZERO_DATE`，那么MySQL数据库不允许插入零日期，插入零日期会抛出错误而不是警告。例如表中含字段TIMESTAMP列（如果未声明为NULL或显示DEFAULT子句）将自动分配DEFAULT '0000-00-00 00:00:00'（零时间戳），也或者是本测试的表day列默认允许插入零日期 '0000-00-00' COMMENT '日期'；这些显然是不满足`sql_mode`中的`NO_ZERO_DATE`而报错。

