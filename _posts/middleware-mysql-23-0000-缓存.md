---
author: djaigo
title: middleware-mysql-22-0000-缓存
categories:
  - null
date: 2023-03-29 19:50:23
tags:
---

查看buffer
```sql
mysql> show variables like '%buffer%';
+-------------------------------------------+----------------+
| Variable_name                             | Value          |
+-------------------------------------------+----------------+
| bulk_insert_buffer_size                   | 8388608        |
| innodb_buffer_pool_chunk_size             | 134217728      |
| innodb_buffer_pool_dump_at_shutdown       | ON             |
| innodb_buffer_pool_dump_now               | OFF            |
| innodb_buffer_pool_dump_pct               | 25             |
| innodb_buffer_pool_filename               | ib_buffer_pool |
| innodb_buffer_pool_in_core_file           | OFF            |
| innodb_buffer_pool_instances              | 2              |
| innodb_buffer_pool_load_abort             | OFF            |
| innodb_buffer_pool_load_at_startup        | ON             |
| innodb_buffer_pool_load_now               | OFF            |
| innodb_buffer_pool_recover_abort          | OFF            |
| innodb_buffer_pool_recover_after_transmit | OFF            |
| innodb_buffer_pool_recover_now            | OFF            |
| innodb_buffer_pool_recover_pct            | 60             |
| innodb_buffer_pool_size                   | 3221225472     |
| innodb_buffer_pool_snapshot_interval      | 0              |
| innodb_buffer_pool_snapshot_now           | OFF            |
| innodb_buffer_pool_snapshot_pct           | 60             |
| innodb_buffer_pool_snapshot_threshold     | 0              |
| innodb_buffer_pool_transmit_enabled       | OFF            |
| innodb_buffer_pool_transmit_interval      | 10             |
| innodb_change_buffer_max_size             | 25             |
| innodb_change_buffering                   | all            |
| innodb_log_buffer_size                    | 67108864       |
| innodb_sort_buffer_size                   | 1048576        |
| join_buffer_size                          | 262144         |
| key_buffer_size                           | 16777216       |
| myisam_sort_buffer_size                   | 8388608        |
| net_buffer_length                         | 8192           |
| preload_buffer_size                       | 32768          |
| read_buffer_size                          | 262144         |
| read_rnd_buffer_size                      | 524288         |
| sort_buffer_size                          | 524288         |
| sql_buffer_result                         | OFF            |
+-------------------------------------------+----------------+
```

# innodb buffer pool
## **2.1 Buffer Pool Instance**

Buffer Pool实例，大小等于innodb_buffer_pool_size/innodb_buffer_pool_instances，每个Buffer Pool Instance都有自己的锁，信号量，物理块(Buffer chunks)以及逻辑链表(List)。即各个instance之间没有竞争关系，可以并发读取与写入。所有instance的物理块(Buffer chunks)在数据库启动的时候被分配，直到数据库关闭内存才予以释放。每个Buffer Pool Instance有一个page hash链表，通过它，使用space_id和page_no就能快速找到已经被读入内存的数据页，而不用线性遍历LRU List去查找。注意这个hash表不是InnoDB的自适应哈希，自适应哈希是为了减少Btree的扫描，而page hash是为了避免扫描LRU List。

> 当innodb_buffer_pool_size小于1GB时候，innodb_buffer_pool_instances被重置为1，主要是防止有太多小的instance从而导致性能问题。

## **2.2 数据页**

InnoDB中，数据管理的最小单位为页，默认是16KB，页中除了存储用户数据，还可以存储控制信息的数据。InnoDB IO子系统的读写最小单位也是页。

## **2.3 Buffer Chunks**

包括两部分：数据页和数据页对应的控制体，控制体中有指针指向数据页。Buffer Chunks是最低层的物理块，在启动阶段从操作系统申请，直到数据库关闭才释放。通过遍历chunks可以访问几乎所有的数据页，有两种状态的数据页除外：没有被解压的压缩页(BUF_BLOCK_ZIP_PAGE)以及被修改过且解压页已经被驱逐的压缩页(BUF_BLOCK_ZIP_DIRTY)。此外数据页里面不一定都存的是用户数据，开始是控制信息，比如行锁，自适应哈希等。

## **2.4 逻辑链表**

链表节点是数据页的控制体(控制体中有指针指向真正的数据页)，链表中的所有节点都有同一的属性，引入其的目的是方便管理。Innodb Buffer Pool 相关的链表有:

### **2.4.1 Free List**

其上的节点都是未被使用的节点，如果需要从数据库中分配新的数据页，直接从上获取即可。InnoDB需要保证Free List有足够的节点，提供给用户线程用，否则需要从FLU List或者LRU List淘汰一定的节点。InnoDB初始化后，Buffer Chunks中的所有数据页都被加入到Free List，表示所有节点都可用。

### **2.4.2 LRU List**

近期最少使用链表(Least Recently Used)，这个是InnoDB中最重要的链表。所有新读取进来的数据页都被放在上面。链表按照最近最少使用算法排序，最近最少使用的节点被放在链表末尾，如果Free List里面没有节点了，就会从中淘汰末尾的节点。LRU List还包含没有被解压的压缩页，这些压缩页刚从磁盘读取出来，还没来得及被解压。LRU List被分为两部分，默认前5/8为young list，存储经常被使用的热点page，后3/8为old list。新读入的page默认被加在old list头，只有满足一定条件后，才被移到young list上，主要是为了预读的数据页和全表扫描污染buffer pool。

### **2.4.3 FLU List**

这个链表中的所有节点都是脏页，也就是说这些数据页都被修改过，但是还没来得及被刷新到磁盘上。在FLU List上的页面一定在LRU List上，但是反之则不成立。一个数据页可能会在不同的时刻被修改多次，在数据页上记录了最老(也就是第一次)的一次修改的lsn，即oldest_modification。不同数据页有不同的oldest_modification，FLU List中的节点按照oldest_modification排序，链表尾是最小的，也就是最早被修改的数据页，当需要从FLU List中淘汰页面时候，从链表尾部开始淘汰。加入FLU List，需要使用flush_list_mutex保护，所以能保证FLU List中节点的顺序。

### **2.4.4 Unzip LRU List**

这个链表中存储的数据页都是解压页，也就是说，这个数据页是从一个压缩页通过解压而来的。

### **2.4.5 Zip Clean List**

这个链表只在Debug模式下有，主要是存储没有被解压的压缩页。这些压缩页刚刚从磁盘读取出来，还没来的及被解压，一旦被解压后，就从此链表中删除，然后加入到Unzip LRU List中。

### **2.4.6 Zip Free**

压缩页有不同的大小，比如8K，4K，InnoDB使用了类似内存管理的伙伴系统来管理压缩页。Zip Free可以理解为由5个链表构成的一个二维数组，每个链表分别存储了对应大小的内存碎片，例如8K的链表里存储的都是8K的碎片，如果新读入一个8K的页面，首先从这个链表中查找，如果有则直接返回，如果没有则从16K的链表中分裂出两个8K的块，一个被使用，另外一个放入8K链表中。

## **2.6 Frame**

帧，16K的虚拟地址空间， 在缓冲池的管理上，整个缓冲区是是以大小为16k的frame(可以理解为数据块)为单位来进行的，frame是innodb中页的大小。

## **2.7 Page**

页，16K的物理内存， page上存的是需要保存到磁盘上的数据， 这些数据可能是数据记录信息， 也可以是索引信息或其他的元数据等；

## **2.8 Control Block**

控制块，对于每个frame, 对应一个block， block上的信息是专门用于进行frame控制的管理信息， 但是这些信息不需要记录到磁盘，而是根据读入数据块在内存中的状态动态生成的， 主要包括：

*   1\. 页面管理的普通信息，互斥锁， 页面的状态等
*   2\. 脏回写(flush)管理信息
*   3\. lru控制信息
*   4\. 快速查找的管理信息， 为了便于快速的超找某一个block或frame， 缓冲区里面的block被组织到一些hash表中; 缓冲区中的block数量是一定的， innodb缓冲区对所管理的block用lru(last recently used)策略进行替换。

## **2.9 Buffer Pool分配方式**

MySQL使用mmap分配Buffer Pool，但是都是虚存，在top命令中占用VIRT这一列，而不是RES这一列，只有相应的内存被真正使用到了，才会被统计到RES中，从而提高内存使用率。这就是为什么常常看到MySQL一启动就被分配了很多的VIRT，而RES却是慢慢涨上来的原因。这里大家可能有个疑问，为啥不用malloc。其实查阅malloc文档，可以发现，当请求的内存数量大于MMAP_THRESHOLD(默认为128KB)时候，malloc底层就是调用了mmap。在InnoDB中，默认使用mmap来分配。 分配完了内存，buf_chunk_init函数中，把这片内存划分为两个部分，前一部分是数据页控制体(buf_block_t)，后一部分是真正的数据页，按照UNIV_PAGE_SIZE分隔。假设page大小为16KB，则数据页控制体占的内存:数据页约等于1:38.6，也就是说如果innodb_buffer_pool_size被配置为40G，则需要额外的1G多空间来存数据页的控制体。 划分完空间后，遍历数据页控制体，设置buf_block_t::frame指针，指向真正的数据页，然后把这些数据页加入到Free List中即可。初始化完Buffer Chunks的内存，还需要初始化BUF_BLOCK_POOL_WATCH类型的数据页控制块，page hash的结构体，zip hash的结构体(所有被压缩页的伙伴系统分配走的数据页面会加入到这个哈希表中)。注意这些内存是额外分配的，不包含在Buffer Chunks中。

## **2.10 互斥访问**

缓冲池的整个缓冲区一个数据结构buf_pool进行管理和控制， 一个专门的mutex保护着， 这个mutex是用来保护buf_pool这个控制结构中的数据域的， 并不保护缓冲区中的数据frame以及用于管理的block, 缓冲区里block或者frame中的访问是由专门的读写锁来保护的， 每个block/frame一个。在5.1以前， 每个block是没专门的mutex保护的，如果需要进行互斥保护，直接使用缓冲区的mutex, 结果导致很高的争用； 5.1以后，每个block一个mutex对其进行保护， 从而在很大程度上解缓了对buf_pool的mutex的争用。

## 存储内容
BUffer Pool中缓存的数据页类型有: 索引页、数据页、undo页、插入缓冲（insert buffer)、自适应哈希索引（adaptive hash index)、InnoDB存储的锁信息（lock info)、数据字典信息（data dictionary)等。

## 预读
## **Buffer Pool预热**

MySQL在重启后，Buffer Pool里面没有什么数据，这个时候业务上对数据库的数据操作，MySQL就只能从磁盘中读取数据到内存中，这个过程可能需要很久才能是内存中的数据是业务频繁使用的。Buffer Pool中数据从无到业务频繁使用热数据的过程称之为预热。所以在预热这个过程中，MySQL数据库的性能不会特别好，并且Buffer Pool越大，预热过程越长。

为了减短这个预热过程，在MySQL关闭前，把Buffer Pool中的页面信息保存到磁盘，等到MySQL启动时，再根据之前保存的信息把磁盘中的数据加载到Buffer Pool中即可。

### **4.1.1 Buffer Pool Dump**

遍历所有Buffer Pool Instance的LRU List，对于其中的每个数据页，按照space_id和page_no组成一个64位的数字，写到外部文件中

### **4.1.2 Buffer Pool Load**

读取指定的外部文件，把所有的数据读入内存后，使用归并排序对数据排序，以64个数据页为单位进行IO合并，然后发起一次真正的读取操作。排序的作用就是便于IO合并。

## **4.2 预读机制**

InnoDB在I/O的优化上有个比较重要的特性为预读，预读请求是一个i/o请求，它会异步地在缓冲池中预先回迁多个页面，预计很快就会需要这些页面，这些请求在一个范围内引入所有页面。InnoDB以64个page为一个extent，那么InnoDB的预读是以page为单位还是以extent？

![](https://pic3.zhimg.com/80/v2-a4c7d4b6d8ef094105aecb50f222a88a_1440w.webp)

数据库请求数据的时候，会将读请求交给文件系统，放入请求队列中；相关进程从请求队列中将读请求取出，根据需求到相关数据区(内存、磁盘)读取数据；取出的数据，放入响应队列中，最后数据库就会从响应队列中将数据取走，完成一次数据读操作过程。

接着进程继续处理请求队列，(如果数据库是全表扫描的话，数据读请求将会占满请求队列)，判断后面几个数据读请求的数据是否相邻，再根据自身系统IO带宽处理量， 进行预读，进行读请求的合并处理 ，一次性读取多块数据放入响应队列中，再被数据库取走。(如此，一次物理读操作，实现多页数据读取，rrqm>0（ # iostat -x ），假设是4个读请求合并，则rrqm参数显示的就是4)

InnoDB使用两种预读算法来提高I/O性能： 线性预读（linear read-ahead）和随机预读（randomread-ahead）

为了区分这两种预读的方式，我们可以把线性预读以extent为单位，而随机预读以extent中的page为单位。线性预读着眼于将下一个extent提前读取到buffer pool中，而随机预读着眼于将当前extent中的剩余的page提前读取到buffer pool中。

## **4.2.1 线性预读（linear read-ahead）**

线性预读方式有一个很重要的变量控制是否将下一个extent预读到buffer pool中，通过使用配置参数 innodb_read_ahead_threshold ，控制触发innodb执行预读操作的时间。

如果一个extent中的被顺序读取的page超过或者等于该参数变量时，Innodb将会异步的将下一个extent读取到buffer pool中，innodb_read_ahead_threshold可以设置为0-64的任何值(因为一个extent中也就只有64页)，默认值为56，值越高，访问模式检查越严格。

```text
mysql> show variables like 'innodb_read_ahead_threshold';
+-----------------------------+-------+
| Variable_name               | Value |
+-----------------------------+-------+
| innodb_read_ahead_threshold | 56    |
+-----------------------------+-------+
```

例如 ，如果将值设置为48，则InnoDB只有在顺序访问当前extent中的48个pages时才触发线性预读请求，将下一个extent读到内存中。如果值为8，InnoDB触发异步预读，即使程序段中只有8页被顺序访问。

可以在MySQL配置文件中设置此参数的值，或者使用SET GLOBAL需要该SUPER权限的命令动态更改该参数。

在没有该变量之前，当访问到extent的最后一个page的时候，innodb会决定是否将下一个extent放入到buffer pool中。

## **4.2.2 随机预读（randomread-ahead）**

随机预读方式则是表示当同一个extent中的一些page在buffer pool中发现时，Innodb会将该extent中的剩余page一并读到buffer pool中。

```text
mysql> show variables like 'innodb_random_read_ahead';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_random_read_ahead | OFF   |
+--------------------------+-------+
```

由于随机预读方式给innodb code带来了一些不必要的复杂性，同时在性能也存在不稳定性，在5.5中已经将这种预读方式 废弃，默认是OFF 。若要启用此功能，即将配置变量设置innodb_random_read_ahead为ON。

# sql buffer
## bulk_insert_buffer
## join_buffer
## key_buffer
## net_buffer
## read_buffer
## sort_buffer
## sql_buffer
## redo log buffer

# change buffer



在前面的基础篇文章中，我给你介绍过索引的基本概念，相信你已经了解了唯一索引和普通索引的区别。今天我们就继续来谈谈，在不同的业务场景下，应该选择普通索引，还是唯一索引？

假设你在维护一个市民系统，每个人都有一个唯一的身份证号，而且业务代码已经保证了不会写入两个重复的身份证号。如果市民系统需要按照身份证号查姓名，就会执行类似这样的 SQL 语句：

```
select name from CUser where id_card = 'xxxxxxxyyyyyyzzzzz';
```

所以，你一定会考虑在 id_card 字段上建索引。

由于身份证号字段比较大，我不建议你把身份证号当做主键，那么现在你有两个选择，要么给 id_card 字段创建唯一索引，要么创建一个普通索引。如果业务代码已经保证了不会写入重复的身份证号，那么这两个选择逻辑上都是正确的。

现在我要问你的是，从性能的角度考虑，你选择唯一索引还是普通索引呢？选择的依据是什么呢？

简单起见，我们还是用第 4 篇文章[《深入浅出索引（上）》](https://time.geekbang.org/column/article/69236)中的例子来说明，假设字段 k 上的值都不重复。


图 1 InnoDB 的索引组织结构

接下来，我们就从这两种索引对查询语句和更新语句的性能影响来进行分析。

# 查询过程

假设，执行查询的语句是 select id from T where k=5。这个查询语句在索引树上查找的过程，先是通过 B+ 树从树根开始，按层搜索到叶子节点，也就是图中右下角的这个数据页，然后可以认为数据页内部通过二分法来定位记录。

*   对于普通索引来说，查找到满足条件的第一个记录 (5,500) 后，需要查找下一个记录，直到碰到第一个不满足 k=5 条件的记录。
*   对于唯一索引来说，由于索引定义了唯一性，查找到第一个满足条件的记录后，就会停止继续检索。

那么，这个不同带来的性能差距会有多少呢？答案是，微乎其微。

你知道的，InnoDB 的数据是按数据页为单位来读写的。也就是说，当需要读一条记录的时候，并不是将这个记录本身从磁盘读出来，而是以页为单位，将其整体读入内存。在 InnoDB 中，每个数据页的大小默认是 16KB。

因为引擎是按页读写的，所以说，当找到 k=5 的记录的时候，它所在的数据页就都在内存里了。那么，对于普通索引来说，要多做的那一次“查找和判断下一条记录”的操作，就只需要一次指针寻找和一次计算。

当然，如果 k=5 这个记录刚好是这个数据页的最后一个记录，那么要取下一个记录，必须读取下一个数据页，这个操作会稍微复杂一些。

但是，我们之前计算过，对于整型字段，一个数据页可以放近千个 key，因此出现这种情况的概率会很低。所以，我们计算平均性能差异时，仍可以认为这个操作成本对于现在的 CPU 来说可以忽略不计。

# 更新过程

为了说明普通索引和唯一索引对更新语句性能的影响这个问题，我需要先跟你介绍一下 change buffer。

当需要更新一个数据页时，如果数据页在内存中就直接更新，而如果这个数据页还没有在内存中的话，在不影响数据一致性的前提下，InooDB 会将这些更新操作缓存在 change buffer 中，这样就不需要从磁盘中读入这个数据页了。在下次查询需要访问这个数据页的时候，将数据页读入内存，然后执行 change buffer 中与这个页有关的操作。通过这种方式就能保证这个数据逻辑的正确性。

需要说明的是，虽然名字叫作 change buffer，实际上它是可以持久化的数据。也就是说，change buffer 在内存中有拷贝，也会被写入到磁盘上。

将 change buffer 中的操作应用到原数据页，得到最新结果的过程称为 merge。除了访问这个数据页会触发 merge 外，系统有后台线程会定期 merge。在数据库正常关闭（shutdown）的过程中，也会执行 merge 操作。

显然，如果能够将更新操作先记录在 change buffer，减少读磁盘，语句的执行速度会得到明显的提升。而且，数据读入内存是需要占用 buffer pool 的，所以这种方式还能够避免占用内存，提高内存利用率。

那么，**什么条件下可以使用 change buffer 呢？**

对于唯一索引来说，所有的更新操作都要先判断这个操作是否违反唯一性约束。比如，要插入 (4,400) 这个记录，就要先判断现在表中是否已经存在 k=4 的记录，而这必须要将数据页读入内存才能判断。如果都已经读入到内存了，那直接更新内存会更快，就没必要使用 change buffer 了。

因此，唯一索引的更新就不能使用 change buffer，实际上也只有普通索引可以使用。

change buffer 用的是 buffer pool 里的内存，因此不能无限增大。change buffer 的大小，可以通过参数 innodb_change_buffer_max_size 来动态设置。这个参数设置为 50 的时候，表示 change buffer 的大小最多只能占用 buffer pool 的 50%。

现在，你已经理解了 change buffer 的机制，那么我们再一起来看看**如果要在这张表中插入一个新记录 (4,400) 的话，InnoDB 的处理流程是怎样的。**

第一种情况是，**这个记录要更新的目标页在内存中**。这时，InnoDB 的处理流程如下：

*   对于唯一索引来说，找到 3 和 5 之间的位置，判断到没有冲突，插入这个值，语句执行结束；
*   对于普通索引来说，找到 3 和 5 之间的位置，插入这个值，语句执行结束。

这样看来，普通索引和唯一索引对更新语句性能影响的差别，只是一个判断，只会耗费微小的 CPU 时间。

但，这不是我们关注的重点。

第二种情况是，**这个记录要更新的目标页不在内存中**。这时，InnoDB 的处理流程如下：

*   对于唯一索引来说，需要将数据页读入内存，判断到没有冲突，插入这个值，语句执行结束；
*   对于普通索引来说，则是将更新记录在 change buffer，语句执行就结束了。

将数据从磁盘读入内存涉及随机 IO 的访问，是数据库里面成本最高的操作之一。change buffer 因为减少了随机磁盘访问，所以对更新性能的提升是会很明显的。

之前我就碰到过一件事儿，有个 DBA 的同学跟我反馈说，他负责的某个业务的库内存命中率突然从 99% 降低到了 75%，整个系统处于阻塞状态，更新语句全部堵住。而探究其原因后，我发现这个业务有大量插入数据的操作，而他在前一天把其中的某个普通索引改成了唯一索引。

# change buffer 的使用场景

通过上面的分析，你已经清楚了使用 change buffer 对更新过程的加速作用，也清楚了 change buffer 只限于用在普通索引的场景下，而不适用于唯一索引。那么，现在有一个问题就是：普通索引的所有场景，使用 change buffer 都可以起到加速作用吗？

因为 merge 的时候是真正进行数据更新的时刻，而 change buffer 的主要目的就是将记录的变更动作缓存下来，所以在一个数据页做 merge 之前，change buffer 记录的变更越多（也就是这个页面上要更新的次数越多），收益就越大。

因此，对于写多读少的业务来说，页面在写完以后马上被访问到的概率比较小，此时 change buffer 的使用效果最好。这种业务模型常见的就是账单类、日志类的系统。

反过来，假设一个业务的更新模式是写入之后马上会做查询，那么即使满足了条件，将更新先记录在 change buffer，但之后由于马上要访问这个数据页，会立即触发 merge 过程。这样随机访问 IO 的次数不会减少，反而增加了 change buffer 的维护代价。所以，对于这种业务模式来说，change buffer 反而起到了副作用。

# 索引选择和实践

回到我们文章开头的问题，普通索引和唯一索引应该怎么选择。其实，这两类索引在查询能力上是没差别的，主要考虑的是对更新性能的影响。所以，我建议你尽量选择普通索引。

如果所有的更新后面，都马上伴随着对这个记录的查询，那么你应该关闭 change buffer。而在其他情况下，change buffer 都能提升更新性能。

在实际使用中，你会发现，普通索引和 change buffer 的配合使用，对于数据量大的表的更新优化还是很明显的。

特别地，在使用机械硬盘时，change buffer 这个机制的收效是非常显著的。所以，当你有一个类似“历史数据”的库，并且出于成本考虑用的是机械硬盘时，那你应该特别关注这些表里的索引，尽量使用普通索引，然后把 change buffer 尽量开大，以确保这个“历史数据”表的数据写入速度。

# change buffer 和 redo log

理解了 change buffer 的原理，你可能会联想到我在前面文章中和你介绍过的 redo log 和 WAL。

在前面文章的评论中，我发现有同学混淆了 redo log 和 change buffer。WAL 提升性能的核心机制，也的确是尽量减少随机读写，这两个概念确实容易混淆。所以，这里我把它们放到了同一个流程里来说明，便于你区分这两个概念。

> 备注：这里，你可以再回顾下第 2 篇文章[《日志系统：一条 SQL 更新语句是如何执行的？》](https://time.geekbang.org/column/article/68633)中的相关内容。

现在，我们要在表上执行这个插入语句：

```
mysql> insert into t(id,k) values(id1,k1),(id2,k2);
```

这里，我们假设当前 k 索引树的状态，查找到位置后，k1 所在的数据页在内存 (InnoDB buffer pool) 中，k2 所在的数据页不在内存中。如图 2 所示是带 change buffer 的更新状态图。


图 2 带 change buffer 的更新过程

分析这条更新语句，你会发现它涉及了四个部分：内存、redo log（ib_log_fileX）、 数据表空间（t.ibd）、系统表空间（ibdata1）。

这条更新语句做了如下的操作（按照图中的数字顺序）：

1.  Page 1 在内存中，直接更新内存；

2.  Page 2 没有在内存中，就在内存的 change buffer 区域，记录下“我要往 Page 2 插入一行”这个信息

3.  将上述两个动作记入 redo log 中（图中 3 和 4）。

做完上面这些，事务就可以完成了。所以，你会看到，执行这条更新语句的成本很低，就是写了两处内存，然后写了一处磁盘（两次操作合在一起写了一次磁盘），而且还是顺序写的。

同时，图中的两个虚线箭头，是后台操作，不影响更新的响应时间。

那在这之后的读请求，要怎么处理呢？

比如，我们现在要执行 select * from t where k in (k1, k2)。这里，我画了这两个读请求的流程图。

如果读语句发生在更新语句后不久，内存中的数据都还在，那么此时的这两个读操作就与系统表空间（ibdata1）和 redo log（ib_log_fileX）无关了。所以，我在图中就没画出这两部分。


图 3 带 change buffer 的读过程

从图中可以看到：

1.  读 Page 1 的时候，直接从内存返回。有几位同学在前面文章的评论中问到，WAL 之后如果读数据，是不是一定要读盘，是不是一定要从 redo log 里面把数据更新以后才可以返回？其实是不用的。你可以看一下图 3 的这个状态，虽然磁盘上还是之前的数据，但是这里直接从内存返回结果，结果是正确的。

2.  要读 Page 2 的时候，需要把 Page 2 从磁盘读入内存中，然后应用 change buffer 里面的操作日志，生成一个正确的版本并返回结果。

可以看到，直到需要读 Page 2 的时候，这个数据页才会被读入内存。

所以，如果要简单地对比这两个机制在提升更新性能上的收益的话，**redo log 主要节省的是随机写磁盘的 IO 消耗（转成顺序写），而 change buffer 主要节省的则是随机读磁盘的 IO 消耗。**

# 小结

今天，我从普通索引和唯一索引的选择开始，和你分享了数据的查询和更新过程，然后说明了 change buffer 的机制以及应用场景，最后讲到了索引选择的实践。

由于唯一索引用不上 change buffer 的优化机制，因此如果业务可以接受，从性能角度出发我建议你优先考虑非唯一索引。




我经常会被问到这样一个问题：我的主机内存只有 100G，现在要对一个 200G 的大表做全表扫描，会不会把数据库主机的内存用光了？

这个问题确实值得担心，被系统 OOM（out of memory）可不是闹着玩的。但是，反过来想想，逻辑备份的时候，可不就是做整库扫描吗？如果这样就会把内存吃光，逻辑备份不是早就挂了？

所以说，对大表做全表扫描，看来应该是没问题的。但是，这个流程到底是怎么样的呢？

# 全表扫描对 server 层的影响

假设，我们现在要对一个 200G 的 InnoDB 表 db1\. t，执行一个全表扫描。当然，你要把扫描结果保存在客户端，会使用类似这样的命令：

```
mysql -h$host -P$port -u$user -p$pwd -e "select * from db1.t" > $target_file
```

你已经知道了，InnoDB 的数据是保存在主键索引上的，所以全表扫描实际上是直接扫描表 t 的主键索引。这条查询语句由于没有其他的判断条件，所以查到的每一行都可以直接放到结果集里面，然后返回给客户端。

那么，这个“结果集”存在哪里呢？

实际上，服务端并不需要保存一个完整的结果集。取数据和发数据的流程是这样的：

1.  获取一行，写到 net_buffer 中。这块内存的大小是由参数 net_buffer_length 定义的，默认是 16k。

2.  重复获取行，直到 net_buffer 写满，调用网络接口发出去。

3.  如果发送成功，就清空 net_buffer，然后继续取下一行，并写入 net_buffer。

4.  如果发送函数返回 EAGAIN 或 WSAEWOULDBLOCK，就表示本地网络栈（socket send buffer）写满了，进入等待。直到网络栈重新可写，再继续发送。

这个过程对应的流程图如下所示。


图 1 查询结果发送流程

从这个流程中，你可以看到：

1.  一个查询在发送过程中，占用的 MySQL 内部的内存最大就是 net_buffer_length 这么大，并不会达到 200G；

2.  socket send buffer 也不可能达到 200G（默认定义 /proc/sys/net/core/wmem_default），如果 socket send buffer 被写满，就会暂停读数据的流程。

也就是说，**MySQL 是“边读边发的”**，这个概念很重要。这就意味着，如果客户端接收得慢，会导致 MySQL 服务端由于结果发不出去，这个事务的执行时间变长。

比如下面这个状态，就是我故意让客户端不去读 socket receive buffer 中的内容，然后在服务端 show processlist 看到的结果。


图 2 服务端发送阻塞

如果你看到 State 的值一直处于**“Sending to client”**，就表示服务器端的网络栈写满了。

我在上一篇文章中曾提到，如果客户端使用–quick 参数，会使用 mysql_use_result 方法。这个方法是读一行处理一行。你可以想象一下，假设有一个业务的逻辑比较复杂，每读一行数据以后要处理的逻辑如果很慢，就会导致客户端要过很久才会去取下一行数据，可能就会出现如图 2 所示的这种情况。

因此，**对于正常的线上业务来说，如果一个查询的返回结果不会很多的话，我都建议你使用 mysql_store_result 这个接口，直接把查询结果保存到本地内存。**

当然前提是查询返回结果不多。在[第 30 篇文章](https://time.geekbang.org/column/article/78427)评论区，有同学说到自己因为执行了一个大查询导致客户端占用内存近 20G，这种情况下就需要改用 mysql_use_result 接口了。

另一方面，如果你在自己负责维护的 MySQL 里看到很多个线程都处于“Sending to client”这个状态，就意味着你要让业务开发同学优化查询结果，并评估这么多的返回结果是否合理。

而如果要快速减少处于这个状态的线程的话，将 net_buffer_length 参数设置为一个更大的值是一个可选方案。

与“Sending to client”长相很类似的一个状态是**“Sending data”**，这是一个经常被误会的问题。有同学问我说，在自己维护的实例上看到很多查询语句的状态是“Sending data”，但查看网络也没什么问题啊，为什么 Sending data 要这么久？

实际上，一个查询语句的状态变化是这样的（注意：这里，我略去了其他无关的状态）：

*   MySQL 查询语句进入执行阶段后，首先把状态设置成“Sending data”；
*   然后，发送执行结果的列相关的信息（meta data) 给客户端；
*   再继续执行语句的流程；
*   执行完成后，把状态设置成空字符串。

也就是说，“Sending data”并不一定是指“正在发送数据”，而可能是处于执行器过程中的任意阶段。比如，你可以构造一个锁等待的场景，就能看到 Sending data 状态。


图 3 读全表被锁


图 4 Sending data 状态

可以看到，session B 明显是在等锁，状态显示为 Sending data。

也就是说，仅当一个线程处于“等待客户端接收结果”的状态，才会显示"Sending to client"；而如果显示成“Sending data”，它的意思只是“正在执行”。

现在你知道了，查询的结果是分段发给客户端的，因此扫描全表，查询返回大量的数据，并不会把内存打爆。

在 server 层的处理逻辑我们都清楚了，在 InnoDB 引擎里面又是怎么处理的呢？ 扫描全表会不会对引擎系统造成影响呢？

# 全表扫描对 InnoDB 的影响

在[第 2](https://time.geekbang.org/column/article/68633)和[第 15 篇](https://time.geekbang.org/column/article/73161)文章中，我介绍 WAL 机制的时候，和你分析了 InnoDB 内存的一个作用，是保存更新的结果，再配合 redo log，就避免了随机写盘。

内存的数据页是在 Buffer Pool (BP) 中管理的，在 WAL 里 Buffer Pool 起到了加速更新的作用。而实际上，Buffer Pool 还有一个更重要的作用，就是加速查询。

在第 2 篇文章的评论区有同学问道，由于有 WAL 机制，当事务提交的时候，磁盘上的数据页是旧的，那如果这时候马上有一个查询要来读这个数据页，是不是要马上把 redo log 应用到数据页呢？

答案是不需要。因为这时候内存数据页的结果是最新的，直接读内存页就可以了。你看，这时候查询根本不需要读磁盘，直接从内存拿结果，速度是很快的。所以说，Buffer Pool 还有加速查询的作用。

而 Buffer Pool 对查询的加速效果，依赖于一个重要的指标，即：**内存命中率**。

你可以在 show engine innodb status 结果中，查看一个系统当前的 BP 命中率。一般情况下，一个稳定服务的线上系统，要保证响应时间符合要求的话，内存命中率要在 99% 以上。

执行 show engine innodb status ，可以看到“Buffer pool hit rate”字样，显示的就是当前的命中率。比如图 5 这个命中率，就是 99.0%。


图 5 show engine innodb status 显示内存命中率

如果所有查询需要的数据页都能够直接从内存得到，那是最好的，对应的命中率就是 100%。但，这在实际生产上是很难做到的。

InnoDB Buffer Pool 的大小是由参数 innodb_buffer_pool_size 确定的，一般建议设置成可用物理内存的 60%~80%。

在大约十年前，单机的数据量是上百个 G，而物理内存是几个 G；现在虽然很多服务器都能有 128G 甚至更高的内存，但是单机的数据量却达到了 T 级别。

所以，innodb_buffer_pool_size 小于磁盘的数据量是很常见的。如果一个 Buffer Pool 满了，而又要从磁盘读入一个数据页，那肯定是要淘汰一个旧数据页的。

InnoDB 内存管理用的是最近最少使用 (Least Recently Used, LRU) 算法，这个算法的核心就是淘汰最久未使用的数据。

下图是一个 LRU 算法的基本模型。


图 6 基本 LRU 算法

InnoDB 管理 Buffer Pool 的 LRU 算法，是用链表来实现的。

1.  在图 6 的状态 1 里，链表头部是 P1，表示 P1 是最近刚刚被访问过的数据页；假设内存里只能放下这么多数据页；

2.  这时候有一个读请求访问 P3，因此变成状态 2，P3 被移到最前面；

3.  状态 3 表示，这次访问的数据页是不存在于链表中的，所以需要在 Buffer Pool 中新申请一个数据页 Px，加到链表头部。但是由于内存已经满了，不能申请新的内存。于是，会清空链表末尾 Pm 这个数据页的内存，存入 Px 的内容，然后放到链表头部。

4.  从效果上看，就是最久没有被访问的数据页 Pm，被淘汰了。

这个算法乍一看上去没什么问题，但是如果考虑到要做一个全表扫描，会不会有问题呢？

假设按照这个算法，我们要扫描一个 200G 的表，而这个表是一个历史数据表，平时没有业务访问它。

那么，按照这个算法扫描的话，就会把当前的 Buffer Pool 里的数据全部淘汰掉，存入扫描过程中访问到的数据页的内容。也就是说 Buffer Pool 里面主要放的是这个历史数据表的数据。

对于一个正在做业务服务的库，这可不妙。你会看到，Buffer Pool 的内存命中率急剧下降，磁盘压力增加，SQL 语句响应变慢。

所以，InnoDB 不能直接使用这个 LRU 算法。实际上，InnoDB 对 LRU 算法做了改进。


图 7 改进的 LRU 算法

在 InnoDB 实现上，按照 5:3 的比例把整个 LRU 链表分成了 young 区域和 old 区域。图中 LRU_old 指向的就是 old 区域的第一个位置，是整个链表的 5/8 处。也就是说，靠近链表头部的 5/8 是 young 区域，靠近链表尾部的 3/8 是 old 区域。

改进后的 LRU 算法执行流程变成了下面这样。

1.  图 7 中状态 1，要访问数据页 P3，由于 P3 在 young 区域，因此和优化前的 LRU 算法一样，将其移到链表头部，变成状态 2。

2.  之后要访问一个新的不存在于当前链表的数据页，这时候依然是淘汰掉数据页 Pm，但是新插入的数据页 Px，是放在 LRU_old 处。

3.  处于 old 区域的数据页，每次被访问的时候都要做下面这个判断：

    *   若这个数据页在 LRU 链表中存在的时间超过了 1 秒，就把它移动到链表头部；
    *   如果这个数据页在 LRU 链表中存在的时间短于 1 秒，位置保持不变。1 秒这个时间，是由参数 innodb_old_blocks_time 控制的。其默认值是 1000，单位毫秒。

这个策略，就是为了处理类似全表扫描的操作量身定制的。还是以刚刚的扫描 200G 的历史数据表为例，我们看看改进后的 LRU 算法的操作逻辑：

1.  扫描过程中，需要新插入的数据页，都被放到 old 区域 ;

2.  一个数据页里面有多条记录，这个数据页会被多次访问到，但由于是顺序扫描，这个数据页第一次被访问和最后一次被访问的时间间隔不会超过 1 秒，因此还是会被保留在 old 区域；

3.  再继续扫描后续的数据，之前的这个数据页之后也不会再被访问到，于是始终没有机会移到链表头部（也就是 young 区域），很快就会被淘汰出去。

可以看到，这个策略最大的收益，就是在扫描这个大表的过程中，虽然也用到了 Buffer Pool，但是对 young 区域完全没有影响，从而保证了 Buffer Pool 响应正常业务的查询命中率。

# 小结

今天，我用“大查询会不会把内存用光”这个问题，和你介绍了 MySQL 的查询结果，发送给客户端的过程。

由于 MySQL 采用的是边算边发的逻辑，因此对于数据量很大的查询结果来说，不会在 server 端保存完整的结果集。所以，如果客户端读结果不及时，会堵住 MySQL 的查询过程，但是不会把内存打爆。

而对于 InnoDB 引擎内部，由于有淘汰策略，大查询也不会导致内存暴涨。并且，由于 InnoDB 对 LRU 算法做了改进，冷数据的全表扫描，对 Buffer Pool 的影响也能做到可控。

当然，我们前面文章有说过，全表扫描还是比较耗费 IO 资源的，所以业务高峰期还是不能直接在线上主库执行全表扫描的。
