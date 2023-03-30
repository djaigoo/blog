---
author: djaigo
title: middleware-mysql-10-0000-常用函数
categories:
  - null
date: 2023-03-29 19:50:00
tags:
---

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

# 字符串函数

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


# 日期函数

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



# 聚合函数
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


# 流程控制函数
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


# 其他函数
* [全文本搜索](https://dev.mysql.com/doc/refman/5.7/en/fulltext-search.html)
* [加密和压缩](https://dev.mysql.com/doc/refman/5.7/en/encryption-functions.html)
* [锁函数](https://dev.mysql.com/doc/refman/5.7/en/locking-functions.html)
* [数据库信息](https://dev.mysql.com/doc/refman/5.7/en/information-functions.html)
* [JSON操作](https://dev.mysql.com/doc/refman/5.7/en/json-function-reference.html)
* [杂项](https://dev.mysql.com/doc/refman/5.7/en/miscellaneous-functions.html)

