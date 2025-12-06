---
author: djaigo
title: mysql-log
categories:
  - middleware
date: 2023-12-05 10:44:17
tags:
  - mysql
  - binlog
---


[mysql5.7 man手册](https://dev.mysql.com/doc/refman/5.7/en/)

# Server Log
MySQL 服务器有多个日志可以帮助您了解正在发生的活动。

| Log Type | Information Written to Log |
| --- | --- |
| Error log | 启动、运行或停止 mysqld 时遇到的问题 |
| General query log | 已建立的客户连接和从客户处收到的声明 |
| Binary log | 更改数据的语句（也用于复制） |
| Relay log | 从复制源服务器接收到的数据更改 |
| Slow query log | 执行时间超过 `long_query_time` 秒的查询 |
| DDL log (metadata log) | DDL语句执行的元数据操作 |

## Error log
错误日志包含mysqld启动和关闭时间的记录。它还包含服务器启动和关闭期间以及服务器运行期间发生的错误、警告和注释等诊断消息。例如，如果 mysqld 注意到需要自动检查或修复某个表，它就会向错误日志写入一条消息。
在某些操作系统上，如果 mysqld 异常退出，错误日志会包含堆栈跟踪。该跟踪可用于确定 mysqld 退出的位置。
如果用于启动 mysqld，mysqld_safe 可能会将消息写入错误日志。例如，当mysqld_safe注意到mysqld异常退出时，它会重新启动mysqld并将mysqld重新启动消息写入错误日志。

## 

## Binlog



# InnoDB Log

## Redo Log

重做日志是一种基于磁盘的数据结构，在崩溃恢复期间用于纠正不完整事务写入的数据。在正常操作期间，重做日志会对由 SQL 语句或低级 API 调用产生的更改表数据的请求进行编码。在初始化期间和接受连接之前，会自动重播在意外关闭之前未完成更新数据文件的修改。有关重做日志在崩溃恢复中的作用的信息，请参阅第 14.19.2 节“InnoDB 恢复”。

默认情况下，重做日志在磁盘上由两个名为 ib_logfile0 和 ib_logfile1 的文件物理表示。 MySQL 以循环方式写入重做日志文件。重做日志中的数据按照受影响的记录进行编码；这些数据统称为重做。通过重做日志的数据传递由不断增加的 LSN 值表示。

要更改 InnoDB 重做日志文件的数量或大小，请执行以下步骤：
1. 停止 MySQL 服务器并确保其关闭时没有错误。
2. 编辑 my.cnf 以更改日志文件配置。要更改日志文件大小，请配置 `innodb_log_file_size`。要增加日志文件的数量，请配置 `innodb_log_files_in_group`。
3. 再次启动 MySQL 服务器。
4. 如果InnoDB检测到`innodb_log_file_size`与重做日志文件大小不同，它会写入日志检查点，关闭并删除旧的日志文件，按请求的大小创建新的日志文件，然后打开新的日志文件。


请考虑以下优化重做日志记录的准则：

* 让您的重做日志文件变大，甚至与缓冲池一样大。当InnoDB将重做日志文件写满时，它必须在检查点将缓冲池的修改内容写入磁盘。小重做日志文件会导致许多不必要的磁盘写入。尽管历史上较大的重做日志文件会导致恢复时间过长，但现在恢复速度要快得多，并且您可以放心地使用大型重做日志文件。
* 重做日志文件的大小和数量使用 `innodb_log_file_size` 和 `innodb_log_files_in_group` 配置选项进行配置。有关修改现有重做日志文件配置的信息，请参阅更改 InnoDB 重做日志文件的数量或大小。
* 考虑增加日志缓冲区的大小。大型日志缓冲区允许大型事务运行，而无需在事务提交之前将日志写入磁盘。因此，如果您有更新、插入或删除许多行的事务，则增大日志缓冲区可以节省磁盘 I/O。日志缓冲区大小是使用 `innodb_log_buffer_size` 配置选项配置的。
* 配置 `innodb_log_write_ahead_size` 配置选项以避免“read-on-write”。该选项定义重做日志的预写块大小。设置 `innodb_log_write_ahead_size` 以匹配操作系统或文件系统缓存块大小。当重做日志块由于重做日志的预写块大小与操作系统或文件系统缓存块大小不匹配而未完全缓存到操作系统或文件系统时，就会发生写时读。
* `innodb_log_write_ahead_size` 的有效值为 InnoDB 日志文件块大小 (2n) 的倍数。最小值是 InnoDB 日志文件块大小 (512)。当指定最小值时，不会发生预写。最大值等于 `innodb_page_size` 值。如果为 `innodb_log_write_ahead_size` 指定的值大于 `innodb_page_size` 值，则 `innodb_log_write_ahead_size` 设置将被截断为 `innodb_page_size` 值。
* 相对于操作系统或文件系统缓存块大小，将 `innodb_log_write_ahead_size` 值设置得太低会导致读写。由于同时写入多个块，因此将该值设置得太高可能会对日志文件写入的 fsync 性能产生轻微影响。

## Undo Logs

撤消日志是与单个读写事务关联的撤消日志记录的集合。撤消日志记录包含有关如何撤消事务对聚集索引记录的最新更改的信息。如果另一个事务需要查看原始数据作为一致读取操作的一部分，则将从撤消日志记录中检索未修改的数据。撤消日志存在于撤消日志段中，而撤消日志段又包含在回滚段中。回滚段驻留在系统表空间、撤消表空间和临时表空间中。
驻留在临时表空间中的撤消日志用于修改用户定义的临时表中的数据的事务。这些撤消日志不会被重做日志记录，因为崩溃恢复不需要它们。它们仅用于服务器运行时的回滚。这种类型的撤消日志通过避免重做日志记录 I/O 来提高性能。
InnoDB最多支持128个回滚段，其中32个分配给临时表空间。这留下了 96 个回滚段，可以分配给修改常规表中数据的事务。 `innodb_rollback_segments` 变量定义了 InnoDB 使用的回滚段的数量。
回滚段支持的事务数量取决于回滚段中的撤消槽数量以及每个事务所需的撤消日志数量。回滚段中的撤消槽数量根据 InnoDB 页大小而不同。

| InnoDB Page Size | Number of Undo Slots in a Rollback Segment (InnoDB Page Size / 16) |
| --- | --- |
| `4096 (4KB)` | `256` |
| `8192 (8KB)` | `512` |
| `16384 (16KB)` | `1024` |
| `32768 (32KB)` | `2048` |
| `65536 (64KB)` | `4096` |


一个事务最多分配四个撤消日志，一个对应以下操作类型：
* 对用户定义表的 INSERT 操作
* 对用户定义表的 UPDATE 和 DELETE 操作
* 对用户定义的临时表进行 INSERT 操作
* 对用户定义的临时表进行 UPDATE 和 DELETE 操作

撤消日志根据需要分配。例如，对常规表和临时表执行 INSERT、UPDATE 和 DELETE 操作的事务需要完全分配四个撤消日志。仅对常规表执行 INSERT 操作的事务需要单个撤消日志。
对常规表执行操作的事务将从分配的系统表空间或撤消表空间回滚段分配撤消日志。对临时表执行操作的事务将从分配的临时表空间回滚段分配撤消日志。
分配给事务的撤消日志在其持续时间内保持附加到事务。例如，分配给常规表上的 INSERT 操作的事务的撤消日志将用于该事务在常规表上执行的所有 INSERT 操作。
考虑到上述因素，可以使用以下公式来估计 InnoDB 能够支持的并发读写事务数。

> 在达到 InnoDB 能够支持的并发读写事务数之前，可能会遇到并发事务限制错误。当分配给事务的回滚段用完撤消槽时，就会发生这种情况。在这种情况下，请尝试重新运行事务。当事务对临时表进行操作时，InnoDB能够支持的并发读写事务数量受到分配给临时表空间的回滚段数量的限制，该数量为32。


* 如果每个事务执行 INSERT 或 UPDATE 或 DELETE 操作，则 InnoDB 能够支持的并发读写事务数为：
$(innodb_page_size / 16) * (innodb_rollback_segments - 32)$

* 如果每个事务执行一个 INSERT 和一个 UPDATE 或 DELETE 操作，则 InnoDB 能够支持的并发读写事务数为：
$(innodb_page_size / 16 / 2) * (innodb_rollback_segments - 32)$

* 如果每个事务对临时表执行INSERT操作，则InnoDB能够支持的并发读写事务数为：
$(innodb_page_size / 16) * 32$

* 如果每个事务对临时表执行 INSERT 和 UPDATE 或 DELETE 操作，则 InnoDB 能够支持的并发读写事务数为：
$(innodb_page_size / 16 / 2) * 32$
