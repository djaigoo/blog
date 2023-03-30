---
author: djaigo
title: middleware-mysql-17-0000-复合语句（Compound-Statements）
categories:
  - null
date: 2023-03-29 19:52:45
tags:
---
# BEGIN END
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

# DECLARE
DECLARE 语句用于声明变量（VARIABLE）、错误条件（CONDITION）、游标（CURSOR）、条件处理（HANDLER）等。
```sql
DECLARE VARIABLE
DECLARE CONDITION
DECLARE CURSOR
DECLARE HANDLER
```


## DECLARE VARIABLE
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



## DECLARE CONDITION
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


## 游标（cursor）
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

## DECLARE HANDLER
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



# Flow Control Statements
## CASE
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

## IF
```sql
IF search_condition THEN statement_list
    [ELSEIF search_condition THEN statement_list] ...
    [ELSE statement_list]
END IF
```

## ITERATE
```sql
ITERATE label
```

## LEAVE
```sql
LEAVE label
```

## LOOP
```sql
[begin_label:] LOOP
    statement_list
END LOOP [end_label]
```

## REPEAT
```sql
[begin_label:] REPEAT
    statement_list
UNTIL search_condition
END REPEAT [end_label]
```

## RETURN
```sql
RETURN expr
```

## WHILE
```sql
[begin_label:] WHILE search_condition DO
    statement_list
END WHILE [end_label]
```
