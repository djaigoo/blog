---
author: djaigo
title: middleware-mysql-5-0000-InnoDB
categories:
  - null
date: 2023-03-29 19:49:52
tags:
---

InnoDB 是一个兼顾高可靠性和高性能的通用存储引擎。在 MySQL 5.7 中，InnoDB 是默认的 MySQL 存储引擎。除非您配置了不同的默认存​​储引擎，否则发出不带 ENGINE 子句的 CREATE TABLE 语句会创建一个 InnoDB 表。

InnoDB 的主要优势：
* 它的 DML 操作遵循 ACID 模型，事务具有提交、回滚和崩溃恢复功能以保护用户数据。
* 行级锁定和 Oracle 风格的一致性读取提高了多用户并发性和性能。
* InnoDB 表在磁盘上安排您的数据以优化基于主键的查询。每个 InnoDB 表都有一个称为聚簇索引的主键索引，它组织数据以最小化主键查找的 I/O。
* 为了保持数据完整性，InnoDB 支持 FOREIGN KEY 约束。对于外键，检查插入、更新和删除以确保它们不会导致相关表之间的不一致。
