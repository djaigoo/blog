---
author: djaigo
title: middleware-mysql-18-0000-Database-Administration-Statements
categories:
  - null
date: 2023-03-29 19:52:46
tags:
---
# Account Management Statements
## grant
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
## revoke
# Table Maintenance Statements
## ANALYZE TABLE
```sql
ANALYZE [NO_WRITE_TO_BINLOG | LOCAL]
    TABLE tbl_name [, tbl_name] ...
```

ANALYZE TABLE 执行键分布分析并存储指定表的分布。对于 MyISAM 表，此语句等效于使用 myisamchk --analyze。
此语句需要表的 SELECT 和 INSERT 权限。
ANALYZE TABLE 适用于 InnoDB、NDB 和 MyISAM 表。它不适用于视图。
分区表支持ANALYZE TABLE，可以使用ALTER TABLE ... ANALYZE PARTITION来分析一个或多个分区。
在分析过程中，表被 InnoDB 和 MyISAM 的读锁锁定。
ANALYZE TABLE 从表定义缓存中删除表，这需要刷新锁。如果有长时间运行的语句或事务仍在使用该表，则后续语句和事务必须等待这些操作完成才能释放刷新锁。由于 ANALYZE TABLE 本身通常很快完成，因此涉及同一表的延迟事务或语句可能并不明显是由于剩余的刷新锁。

默认情况下，服务器将 ANALYZE TABLE 语句写入二进制日志，以便它们复制到副本。要禁止记录日志，请指定可选的 `NO_WRITE_TO_BINLOG` 关键字或其别名 LOCAL。

ANALYZE TABLE 返回一个结果集，其列如下表所示。

| Column | Value |
| --- | --- |
| `Table` | 表名 |
| `Op` | 操作总是 `analyze` |
| `Msg_type` | `status`, `error`, `info`, `note`, or `warning` |
| `Msg_text` | 信息 |

对于 InnoDB 表，ANALYZE TABLE 通过对每个索引树执行随机潜水并相应地更新索引基数估计来确定索引基数。因为这些只是估计值，所以重复运行 ANALYZE TABLE 可能会产生不同的数字。这使得 ANALYZE TABLE 在 InnoDB 表上速度很快，但不是 100% 准确，因为它没有考虑所有行。
您可以通过启用 `innodb_stats_persistent` 使 ANALYZE TABLE 收集的统计信息更加精确和稳定。启用 `innodb_stats_persistent` 时，在对索引列数据进行重大更改后运行 ANALYZE TABLE 很重要，因为不会定期重新计算统计信息（例如在服务器重启后）。
如果启用了 `innodb_stats_persistent`，则可以通过修改 `innodb_stats_persistent_sample_pages` 系统变量来更改随机潜水的次数。如果禁用 `innodb_stats_persistent`，请改为修改 `innodb_stats_transient_sample_pages`。
MySQL 在连接优化中使用索引基数估计。如果连接未以正确的方式优化，请尝试运行 ANALYZE TABLE。在少数情况下 ANALYZE TABLE 不能为您的特定表生成足够好的值，您可以在查询中使用 FORCE INDEX 以强制使用特定索引，或设置 `max_seeks_for_key` 系统变量以确保 MySQL 更喜欢索引查找而不是表扫描。请参阅第 B.3.5 节，“与优化器相关的问题”。

## CHECK TABLE
```sql
CHECK TABLE tbl_name [, tbl_name] ... [option] ...

option: {
    FOR UPGRADE
  | QUICK
  | FAST
  | MEDIUM
  | EXTENDED
  | CHANGED
}
```

CHECK TABLE 检查一个或多个表是否有错误。对于 MyISAM 表，关键统计信息也会更新。 CHECK TABLE 还可以检查视图是否存在问题，例如视图定义中引用的表不再存在。
CHECK TABLE 适用于 InnoDB、MyISAM、ARCHIVE 和 CSV 表。
CHECK TABLE 忽略未索引的虚拟生成列。
CHECK TABLE 返回一个结果集，其列如下表所示：

| Column | Value |
| --- | --- |
| `Table` | 表名 |
| `Op` | 总是 `check` |
| `Msg_type` | `status`, `error`, `info`, `note`, or `warning` |
| `Msg_text` | 信息 |

该语句可能会为每个已检查的表生成多行信息。最后一行的 `Msg_type` 值为 status，`Msg_text` 通常应该是 OK。对于 MyISAM 表，如果你没有得到 OK 或者 Table 已经是最新的，你通常应该运行表的修复。表已经是最新的意味着表的存储引擎表明不需要检查表。

FOR UPGRADE 选项检查命名表是否与当前版本的 MySQL 兼容。对于 FOR UPGRADE，服务器检查每个表以确定自创建表以来表的任何数据类型或索引是否有任何不兼容的更改。如果不是，则检查成功。否则，如果可能存在不兼容性，服务器将对表运行全面检查（这可能需要一些时间）。如果完整检查成功，服务器会用当前的 MySQL 版本号标记表的 .frm 文件。标记 .frm 文件可确保使用相同版本的服务器快速进一步检查表。

由于数据类型的存储格式已更改或其排序顺序已更改，可能会发生不兼容。我们的目标是避免这些更改，但有时它们是纠正比版本之间不兼容更糟糕的问题所必需的。

检查数据一致性
下表显示了可以提供的其他检查选项。这些选项被传递给存储引擎，存储引擎可能会使用或忽略它们。

| Type | Meaning |
| --- | --- |
| `QUICK` | 不要扫描行来检查不正确的链接。适用于 InnoDB 和 MyISAM 表和视图。 |
| `FAST` | 仅检查未正确关闭的表。 InnoDB 忽略；仅适用于 MyISAM 表和视图。 |
| `CHANGED` | 仅检查自上次检查以来已更改或未正确关闭的表。 InnoDB 忽略；仅适用于 MyISAM 表和视图。 |
| `MEDIUM` | 扫描行以验证删除的链接是否有效。这还会计算行的密钥校验和，并使用计算出的密钥校验和来验证这一点。 InnoDB 忽略；仅适用于 MyISAM 表和视图。 |
| `EXTENDED` | 对每一行的所有键进行完整的键查找。这样可以确保表是 100% 一致的，但是需要很长时间。 InnoDB 忽略；仅适用于 MyISAM 表和视图。 |

如果未指定 QUICK、MEDIUM 或 EXTENDED 选项，则动态格式 MyISAM 表的默认检查类型为 MEDIUM。这与在表上运行 `myisamchk --medium-check tbl_name` 的结果相同。对于静态格式的 MyISAM 表，默认检查类型也是 MEDIUM，除非指定了 CHANGED 或 FAST。在这种情况下，默认值为 QUICK。为 CHANGED 和 FAST 跳过行扫描，因为行很少损坏。

如果表已损坏，问题很可能出在索引中，而不是数据部分。所有上述检查类型都会彻底检查索引，因此应该会发现大部分错误。
要检查您认为没问题的表，请不使用检查选项或 QUICK 选项。后者应该在您赶时间时使用，并且可以承担 QUICK 没有在数据文件中发现错误的非常小的风险。 （在大多数情况下，在正常使用情况下，MySQL 应该会发现数据文件中有任何错误。如果发生这种情况，该表将被标记为“已损坏”，并且在修复之前无法使用。）
FAST 和 CHANGED 主要用于脚本（例如，从 cron 执行）以定期检查表。在大多数情况下，FAST 优于 CHANGED。 （唯一不受欢迎的情况是您怀疑在 MyISAM 代码中发现了错误。）
EXTENDED 仅在运行正常检查后使用，但当 MySQL 尝试更新行或按键查找行时仍然从表中获取错误。如果正常检查成功，则不太可能发生这种情况。使用 CHECK TABLE ... EXTENDED 可能会影响查询优化器生成的执行计划。

CHECK TABLE 报告的一些问题无法自动更正：
* `Found row where the auto_increment column has the value 0`，这意味着您在表中有一行，其中 `AUTO_INCREMENT` 索引列包含值 0。（可以通过使用 UPDATE 语句将列显式设置为 0 来创建 `AUTO_INCREMENT` 列为 0 的行。）这本身不是错误，但如果您决定转储表并恢复它或在表上执行 ALTER TABLE，则可能会导致麻烦。在这种情况下，`AUTO_INCREMENT` 列会根据 `AUTO_INCREMENT` 列的规则更改值，这可能会导致出现重复键错误等问题。要消除警告，请执行 UPDATE 语句将列设置为 0 以外的某个值。

InnoDB 表的 CHECK TABLE 使用注意事项：
* 如果 CHECK TABLE 遇到损坏的页面，服务器将退出以防止错误传播（错误＃10132）。如果损坏发生在二级索引中但表数据是可读的，运行 CHECK TABLE 仍然会导致服务器退出。
* 如果 CHECK TABLE 在聚簇索引中遇到损坏的 `DB_TRX_ID` 或 `DB_ROLL_PTR` 字段，CHECK TABLE 会导致 InnoDB 访问无效的撤消日志记录，从而导致与 MVCC 相关的服务器退出。
* 如果 CHECK TABLE 在 InnoDB 表或索引中遇到错误，它会报告错误，并且通常会标记索引，有时会将表标记为已损坏，从而阻止进一步使用索引或表。此类错误包括二级索引中的条目数量不正确或链接不正确。
* 如果 CHECK TABLE 在二级索引中发现不正确的条目数，它会报告错误但不会导致服务器退出或阻止对文件的访问。
* CHECK TABLE 检查索引页面结构，然后检查每个关键条目。它不验证指向聚集记录的键指针或遵循 BLOB 指针的路径。
* 当 InnoDB 表存储在它自己的 .ibd 文件中时，.ibd 文件的前 3 页包含标题信息而不是表或索引数据。 CHECK TABLE 语句不检测仅影响标头数据的不一致。要验证 InnoDB .ibd 文件的全部内容，请使用 innochecksum 命令。
* 在大型 InnoDB 表上运行 CHECK TABLE 时，其他线程可能会在 CHECK TABLE 执行期间被阻塞。为避免超时，CHECK TABLE 操作的信号量等待阈值（600 秒）延长了 2 小时（7200 秒）。如果 InnoDB 检测到信号量​​等待 240 秒或更长时间，它会开始将 InnoDB 监视器输出打印到错误日志中。如果锁定请求超出信号量等待阈值，InnoDB 将中止进程。要完全避免信号量等待超时的可能性，请运行 CHECK TABLE QUICK 而不是 CHECK TABLE。
* InnoDB SPATIAL 索引的 CHECK TABLE 功能包括 R-tree 有效性检查和检查以确保 R-tree 行计数与聚集索引匹配。
* CHECK TABLE 支持虚拟生成列上的二级索引，这是 InnoDB 支持的。

MyISAM 表的 CHECK TABLE 使用注意事项：
* CHECK TABLE 更新 MyISAM 表的关键统计信息。
* 如果 CHECK TABLE 输出没有返回 OK 或 Table 已经是最新的，您通常应该运行表的修复。请参阅第 7.6 节，“MyISAM 表维护和崩溃恢复”。
* 如果 CHECK TABLE 选项 QUICK、MEDIUM 或 EXTENDED 均未指定，则动态格式 MyISAM 表的默认检查类型为 MEDIUM。这与在表上运行 myisamchk --medium-check tbl_name 的结果相同。对于静态格式的 MyISAM 表，默认检查类型也是 MEDIUM，除非指定了 CHANGED 或 FAST。在这种情况下，默认值为 QUICK。为 CHANGED 和 FAST 跳过行扫描，因为行很少损坏。

## OPTIMIZE TABLE
```sql
OPTIMIZE [NO_WRITE_TO_BINLOG | LOCAL]
    TABLE tbl_name [, tbl_name] ...
```

OPTIMIZE TABLE 对表数据和关联索引数据的物理存储进行重组，减少存储空间，提高访问表时的I/O效率。对每个表所做的确切更改取决于该表使用的存储引擎。此语句需要表的 SELECT 和 INSERT 权限。此语句不适用于视图。分区表支持优化表。
在这些情况下使用 OPTIMIZE TABLE，具体取决于表的类型：
* 在对具有自己的 .ibd 文件的 InnoDB 表执行大量插入、更新或删除操作之后，因为它是在启用 `innodb_file_per_table` 选项的情况下创建的。重组了表和索引，可以回收磁盘空间供操作系统使用。
* 在对作为 InnoDB 表中 FULLTEXT 索引的一部分的列进行大量插入、更新或删除操作之后。首先设置配置选项 `innodb_optimize_fulltext_only=1`。为了将索引维护周期保持在合理的时间，设置 `innodb_ft_num_word_optimize` 选项以指定在搜索索引中更新多少个单词，并运行一系列 OPTIMIZE TABLE 语句，直到搜索索引完全更新。
* 在删除 MyISAM 或 ARCHIVE 表的大部分后，或对具有可变长度行（具有 VARCHAR、VARBINARY、BLOB 或 TEXT 列的表）的 MyISAM 或 ARCHIVE 表进行许多更改后。删除的行在链表中维护，后续的 INSERT 操作重用旧行位置。您可以使用 OPTIMIZE TABLE 回收未使用的空间并对数据文件进行碎片整理。在对表进行大量更改后，此语句还可以提高使用该表的语句的性能，有时效果会很显着。

OPTIMIZE TABLE 适用于 InnoDB、MyISAM 和 ARCHIVE 表。内存 NDB 表的动态列也支持优化表。它不适用于内存表的固定宽度列，也不适用于磁盘数据表。 OPTIMIZE 在 NDB Cluster 表上的性能可以使用 `--ndb-optimization-delay` 进行调整，它控制 OPTIMIZE TABLE 处理批处理行之间等待的时间长度。对于 NDB Cluster 表，OPTIMIZE TABLE 可以通过（例如）杀死执行 OPTIMIZE 操作的 SQL 线程来中断。
默认情况下，OPTIMIZE TABLE 不适用于使用任何其他存储引擎创建的表，并返回一个表明缺乏支持的结果。您可以通过使用 --skip-new 选项启动 mysqld 来使 OPTIMIZE TABLE 为其他存储引擎工作。在这种情况下，OPTIMIZE TABLE 只是映射到 ALTER TABLE。
默认情况下，服务器将 OPTIMIZE TABLE 语句写入二进制日志，以便它们复制到副本。要禁止记录日志，请指定可选的 `NO_WRITE_TO_BINLOG` 关键字或其别名 LOCAL。
OPTIMIZE TABLE 返回一个结果集，其列如下表所示：

| Column | Value |
| --- | --- |
| `Table` | 表名 |
| `Op` | 总是 `optimize` |
| `Msg_type` | `status`, `error`, `info`, `note`, or `warning` |
| `Msg_text` | 信息 |

OPTIMIZE TABLE table 捕获并抛出将表统计信息从旧文件复制到新创建的文件时发生的任何错误。例如。如果 .frm、.MYD 或 .MYI 文件所有者的用户 ID 与 mysqld 进程的用户 ID 不同，OPTIMIZE TABLE 会生成“无法更改文件所有权”错误，除非 mysqld 由 root 启动用户。

### InnoDB 详细信息
对于 InnoDB 表，OPTIMIZE TABLE 映射到 ALTER TABLE ... FORCE，它重建表以更新索引统计信息并释放聚簇索引中未使用的空间。当您在 InnoDB 表上运行它时，这会显示在 OPTIMIZE TABLE 的输出中，如下所示：

```sql
mysql> OPTIMIZE TABLE foo;
+----------+----------+----------+-------------------------------------------------------------------+
| Table    | Op       | Msg_type | Msg_text                                                          |
+----------+----------+----------+-------------------------------------------------------------------+
| test.foo | optimize | note     | Table does not support optimize, doing recreate + analyze instead |
| test.foo | optimize | status   | OK                                                                |
+----------+----------+----------+-------------------------------------------------------------------+
```

OPTIMIZE TABLE 对常规和分区 InnoDB 表使用在线 DDL，这减少了并发 DML 操作的停机时间。 OPTIMIZE TABLE触发的表重建就地完成。独占表锁仅在操作的准备阶段和提交阶段短暂使用。在准备阶段，更新元数据并创建中间表。在提交阶段，提交表元数据更改。

OPTIMIZE TABLE 在以下条件下使用表复制方法重建表：
* 当启用 `old_alter_table` 系统变量时。
* 当使用 `--skip-new` 选项启动服务器时。

包含 FULLTEXT 索引的 InnoDB 表不支持使用在线 DDL 优化表。改为使用表复制方法。

InnoDB 使用页面分配方法存储数据，并且不会像传统存储引擎（如 MyISAM）那样受到碎片的影响。在考虑是否运行 OPTIMIZE TABLE 时，请考虑您的服务器预期处理的事务工作量：
* 预计会出现某种程度的碎片化。 InnoDB 仅填充 93% 的页面，以便在无需拆分页面的情况下为更新留出空间。
* 删除操作可能会留下间隙，使页面填充少于预期，这可能值得优化表。
* 当有足够的空间可用时，对行的更新通常会重写同一页中的数据，具体取决于数据类型和行格式。
* 随着时间的推移，高并发工作负载可能会在索引中留下空白，因为 InnoDB 通过其 MVCC 机制保留了相同数据的多个版本。

### MyISAM 详细信息
对于 MyISAM 表，OPTIMIZE TABLE 的工作方式如下：
* 如果表有删除或拆分行，修复表。
* 如果索引页未排序，请对它们进行排序。
* 如果表的统计信息不是最新的（并且无法通过对索引进行排序来完成修复），请更新它们。

注意事项：
* OPTIMIZE TABLE 对常规和分区 InnoDB 表在线执行。否则，MySQL 在 OPTIMIZE TABLE 运行期间锁定表。
* OPTIMIZE TABLE 不对 R 树索引进行排序，例如 POINT 列上的空间索引。 

# SHOW

## SHOW CREATE


