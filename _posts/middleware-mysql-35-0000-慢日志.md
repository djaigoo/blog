---
author: djaigo
title: middleware-mysql-37-0000-慢日志
categories:
  - null
date: 2023-03-29 19:50:47
tags:
---

慢查询性能
查看慢日志
`log_output` 参数是指定日志的存储方式。`log_output='FILE'`表示将日志存入文件，默认值是'FILE'。
`log_output='TABLE'`表示将日志存入数据库，这样日志信息就会被写入到mysql.`slow_log`表中。
MySQL数据库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如：`log_output='FILE,TABLE'`。
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
* `select_type` SELECT 的类型，可以是下表中显示的任何一种。 JSON 格式的 EXPLAIN 将 SELECT 类型公开为 `query_block` 的属性，除非它是 SIMPLE 或 PRIMARY。 JSON 名称（如果适用）也显示在表中。
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
* `key` 列表示 MySQL 实际决定使用的键（索引）。如果 MySQL 决定使用 `possible_keys` 索引之一来查找行，则该索引被列为键值。key 可以命名一个在 `possible_keys` 值中不存在的索引。如果 `possible_keys` 索引都不适合查找行，但查询选择的所有列都是某个其他索引的列，则可能会发生这种情况。也就是说，命名索引覆盖了选定的列，因此虽然它不用于确定检索哪些行，但索引扫描比数据行扫描更有效。对于 InnoDB，即使查询还选择了主键，二级索引也可能覆盖选定的列，因为 InnoDB 将主键值与每个二级索引一起存储。如果 key 为 NULL，则 MySQL 找不到可用于更有效地执行查询的索引。要强制 MySQL 使用或忽略 `possible_keys` 列中列出的索引，请在查询中使用 FORCE INDEX、USE INDEX 或 IGNORE INDEX。
* `key_len` 列指示 MySQL 决定使用的 key 的长度。 `key_len` 的值使您能够确定 MySQL 实际使用多部分键的多少部分。如果 key 列为 NULL，则 `key_len` 列也为 NULL。由于 key 存储格式的原因，可以为 NULL 的列的密钥长度比 NOT NULL 列的密钥长度长一倍。
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
  - `Scanned N databases (JSON property: message)`，这表示服务器在处理 `INFORMATION_SCHEMA` 表查询时执行的目录扫描次数，如第 8.2.3 节“优化 `INFORMATION_SCHEMA` 查询”中所述。 N 的值可以是 0、1 或全部。
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
  - `Using join buffer (Block Nested Loop), Using join buffer (Batched Key Access) (JSON property: using_join_buffer)`，来自早期连接的表被部分读入连接缓冲区，然后使用缓冲区中的行来执行与当前表的连接。 (Block Nested Loop) 表示使用 Block Nested-Loop 算法，(Batched Key Access) 表示使用 Batched Key Access 算法。也就是说，EXPLAIN 输出的前一行表中的键被缓冲，匹配的行从出现 Using join buffer 的行所代表的表中批量提取。在 JSON 格式的输出中，`using_join_buffer` 的值始终是 Block Nested Loop 或 Batched Key Access 之一。有关这些算法的更多信息，请参阅块嵌套循环连接算法和批量密钥访问连接。
  - `Using MRR (JSON property: message)`，使用多范围读取优化策略读取表。
  - `Using sort_union(...), Using union(...), Using intersect(...) (JSON property: message)`，这些指示特定算法，显示如何为 index_merge 连接类型合并索引扫描。
  - `Using temporary (JSON property: using_temporary_table)`，为了解析查询，MySQL 需要创建一个临时表来保存结果。如果查询包含以不同方式列出列的 GROUP BY 和 ORDER BY 子句，通常会发生这种情况。
  - `Using where (JSON property: attached_condition)`，WHERE 子句用于限制哪些行与下一个表匹配或发送给客户端。除非您特别打算从表中获取或检查所有行，否则如果 Extra 值不是 Using where 并且表连接类型是 ALL 或索引，则您的查询可能有问题。在 JSON 格式的输出中使用 where 没有直接的对应物； attached_condition 属性包含使用的任何 WHERE 条件。
  - `Using where with pushed condition (JSON property: message)`，此项仅适用于 NDB 表。这意味着 NDB Cluster 正在使用条件下推优化来提高非索引列和常量之间直接比较的效率。在这种情况下，条件被“下推”到集群的数据节点，并同时在所有数据节点上进行评估。这消除了通过网络发送不匹配行的需要，并且可以将此类查询的速度提高 5 到 10 倍，这比可以使用但未使用条件下推的情况要快。
  - `Zero limit (JSON property: message)`，查询有一个 LIMIT 0 子句，不能选择任何行。


常见Extra：`NULL`、`Using where`、`Using index`、`Using temporary`、`Using filesort`


