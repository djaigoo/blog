---
tuchuang: https://img-1251474779.cos.ap-beijing.myqcloud.com
title: kafka背景和架构介绍
date: 2018-11-26 14:16:34
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/kafka.png
tags:
  - introduction
categories:
  - kafka
---


本文摘自[Kafka 设计解析](https://www.infoq.cn/article/kafka-analysis-part-1)
<!--more-->

Kafka 是由 LinkedIn 开发的一个分布式的消息系统，使用 Scala 编写，它以可水平扩展和高吞吐率而被广泛使用。目前越来越多的开源分布式处理系统如 Cloudera、Apache Storm、Spark 都支持与 Kafka 集成。InfoQ 一直在紧密关注[Kafka 的应用以及发展](http://www.infoq.com/cn/kafka/)，“Kafka 剖析”专栏将会从架构设计、实现、应用场景、性能等方面深度解析 Kafka。

## 背景介绍

### Kafka 创建背景

Kafka 是一个消息系统，原本开发自 LinkedIn，用作 LinkedIn 的活动流（Activity Stream）和运营数据处理管道（Pipeline）的基础。现在它已被[多家不同类型的公司](https://cwiki.apache.org/confluence/display/KAFKA/Powered+By) 作为多种类型的数据管道和消息系统使用。

活动流数据是几乎所有站点在对其网站使用情况做报表时都要用到的数据中最常规的部分。活动数据包括页面访问量（Page View）、被查看内容方面的信息以及搜索情况等内容。这种数据通常的处理方式是先把各种活动以日志的形式写入某种文件，然后周期性地对这些文件进行统计分析。运营数据指的是服务器的性能数据（CPU、IO 使用率、请求时间、服务日志等等数据)。运营数据的统计方法种类繁多。

近年来，活动和运营数据处理已经成为了网站软件产品特性中一个至关重要的组成部分，这就需要一套稍微更加复杂的基础设施对其提供支持。

### Kafka 简介

Kafka 是一种分布式的，基于发布 / 订阅的消息系统。主要设计目标如下：

*   以时间复杂度为 O(1) 的方式提供消息持久化能力，即使对 TB 级以上数据也能保证常数时间复杂度的访问性能。
*   高吞吐率。即使在非常廉价的商用机器上也能做到单机支持每秒 100K 条以上消息的传输。
*   支持 Kafka Server 间的消息分区，及分布式消费，同时保证每个 Partition 内的消息顺序传输。
*   同时支持离线数据处理和实时数据处理。
*   Scale out：支持在线水平扩展。

### 为何使用消息系统

*   **解耦**在项目启动之初来预测将来项目会碰到什么需求，是极其困难的。消息系统在处理过程中间插入了一个隐含的、基于数据的接口层，两边的处理过程都要实现这一接口。这允许你独立的扩展或修改两边的处理过程，只要确保它们遵守同样的接口约束。
*   **冗余**有些情况下，处理数据的过程会失败。除非数据被持久化，否则将造成丢失。消息队列把数据进行持久化直到它们已经被完全处理，通过这一方式规避了数据丢失风险。许多消息队列所采用的 " 插入 - 获取 - 删除 " 范式中，在把一个消息从队列中删除之前，需要你的处理系统明确的指出该消息已经被处理完毕，从而确保你的数据被安全的保存直到你使用完毕。
*   **扩展性**因为消息队列解耦了你的处理过程，所以增大消息入队和处理的频率是很容易的，只要另外增加处理过程即可。不需要改变代码、不需要调节参数。扩展就像调大电力按钮一样简单。
*   **灵活性 & 峰值处理能力**在访问量剧增的情况下，应用仍然需要继续发挥作用，但是这样的突发流量并不常见；如果为以能处理这类峰值访问为标准来投入资源随时待命无疑是巨大的浪费。使用消息队列能够使关键组件顶住突发的访问压力，而不会因为突发的超负荷的请求而完全崩溃。
*   **可恢复性**系统的一部分组件失效时，不会影响到整个系统。消息队列降低了进程间的耦合度，所以即使一个处理消息的进程挂掉，加入队列中的消息仍然可以在系统恢复后被处理。
*   **顺序保证**在大多使用场景下，数据处理的顺序都很重要。大部分消息队列本来就是排序的，并且能保证数据会按照特定的顺序来处理。Kafka 保证一个 Partition 内的消息的有序性。
*   **缓冲**在任何重要的系统中，都会有需要不同的处理时间的元素。例如，加载一张图片比应用过滤器花费更少的时间。消息队列通过一个缓冲层来帮助任务最高效率的执行———写入队列的处理会尽可能的快速。该缓冲有助于控制和优化数据流经过系统的速度。
*   **异步通信**很多时候，用户不想也不需要立即处理消息。消息队列提供了异步处理机制，允许用户把一个消息放入队列，但并不立即处理它。想向队列中放入多少消息就放多少，然后在需要的时候再去处理它们。

### 常用 Message Queue 对比

*   **RabbitMQ**

    RabbitMQ 是使用 Erlang 编写的一个开源的消息队列，本身支持很多的协议：AMQP，XMPP, SMTP, STOMP，也正因如此，它非常重量级，更适合于企业级的开发。同时实现了 Broker 构架，这意味着消息在发送给客户端时先在中心队列排队。对路由，负载均衡或者数据持久化都有很好的支持。

*   **Redis**

    Redis 是一个基于 Key-Value 对的 NoSQL 数据库，开发维护很活跃。虽然它是一个 Key-Value 数据库存储系统，但它本身支持 MQ 功能，所以完全可以当做一个轻量级的队列服务来使用。对于 RabbitMQ 和 Redis 的入队和出队操作，各执行 100 万次，每 10 万次记录一次执行时间。测试数据分为 128Bytes、512Bytes、1K 和 10K 四个不同大小的数据。实验表明：入队时，当数据比较小时 Redis 的性能要高于 RabbitMQ，而如果数据大小超过了 10K，Redis 则慢的无法忍受；出队时，无论数据大小，Redis 都表现出非常好的性能，而 RabbitMQ 的出队性能则远低于 Redis。

*   **ZeroMQ**

    ZeroMQ 号称最快的消息队列系统，尤其针对大吞吐量的需求场景。ZeroMQ 能够实现 RabbitMQ 不擅长的高级 / 复杂的队列，但是开发人员需要自己组合多种技术框架，技术上的复杂度是对这 MQ 能够应用成功的挑战。ZeroMQ 具有一个独特的非中间件的模式，你不需要安装和运行一个消息服务器或中间件，因为你的应用程序将扮演这个服务器角色。你只需要简单的引用 ZeroMQ 程序库，可以使用 NuGet 安装，然后你就可以愉快的在应用程序之间发送消息了。但是 ZeroMQ 仅提供非持久性的队列，也就是说如果宕机，数据将会丢失。其中，Twitter 的 Storm 0.9.0 以前的版本中默认使用 ZeroMQ 作为数据流的传输（Storm 从 0.9 版本开始同时支持 ZeroMQ 和 Netty 作为传输模块）。

*   **ActiveMQ**

    ActiveMQ 是 Apache 下的一个子项目。 类似于 ZeroMQ，它能够以代理人和点对点的技术实现队列。同时类似于 RabbitMQ，它少量代码就可以高效地实现高级应用场景。

*   **Kafka/Jafka**

    Kafka 是 Apache 下的一个子项目，是一个高性能跨语言分布式发布 / 订阅消息队列系统，而 Jafka 是在 Kafka 之上孵化而来的，即 Kafka 的一个升级版。具有以下特性：快速持久化，可以在 O(1) 的系统开销下进行消息持久化；高吞吐，在一台普通的服务器上既可以达到 10W/s 的吞吐速率；完全的分布式系统，Broker、Producer、Consumer 都原生自动支持分布式，自动实现负载均衡；支持 Hadoop 数据并行加载，对于像 Hadoop 的一样的日志数据和离线分析系统，但又要求实时处理的限制，这是一个可行的解决方案。Kafka 通过 Hadoop 的并行加载机制统一了在线和离线的消息处理。Apache Kafka 相对于 ActiveMQ 是一个非常轻量级的消息系统，除了性能非常好之外，还是一个工作良好的分布式系统。

## Kafka 架构

### Terminology

*   **Broker**Kafka 集群包含一个或多个服务器，这种服务器被称为 broker
*   **Topic**每条发布到 Kafka 集群的消息都有一个类别，这个类别被称为 Topic。（物理上不同 Topic 的消息分开存储，逻辑上一个 Topic 的消息虽然保存于一个或多个 broker 上但用户只需指定消息的 Topic 即可生产或消费数据而不必关心数据存于何处）
*   **Partition**Parition 是物理上的概念，每个 Topic 包含一个或多个 Partition.
*   **Producer**负责发布消息到 Kafka broker
*   **Consumer**消息消费者，向 Kafka broker 读取消息的客户端。
*   **Consumer Group**每个 Consumer 属于一个特定的 Consumer Group（可为每个 Consumer 指定 group name，若不指定 group name 则属于默认的 group）。

### Kafka 拓扑结构

![拓扑结构](https://img-1251474779.cos.ap-beijing.myqcloud.com/bc99c2a3176ee1695a3d4f1f4f08a5c8.png)

如上图所示，一个典型的 Kafka 集群中包含若干 Producer（可以是 web 前端产生的 Page View，或者是服务器日志，系统 CPU、Memory 等），若干 broker（Kafka 支持水平扩展，一般 broker 数量越多，集群吞吐率越高），若干 Consumer Group，以及一个[Zookeeper](http://zookeeper.apache.org/)集群。Kafka 通过 Zookeeper 管理集群配置，选举 leader，以及在 Consumer Group 发生变化时进行 rebalance。Producer 使用 push 模式将消息发布到 broker，Consumer 使用 pull 模式从 broker 订阅并消费消息。

### Topic & Partition

Topic 在逻辑上可以被认为是一个 queue，每条消费都必须指定它的 Topic，可以简单理解为必须指明把这条消息放进哪个 queue 里。为了使得 Kafka 的吞吐率可以线性提高，物理上把 Topic 分成一个或多个 Partition，每个 Partition 在物理上对应一个文件夹，该文件夹下存储这个 Partition 的所有消息和索引文件。若创建 topic1 和 topic2 两个 topic，且分别有 13 个和 19 个分区，则整个集群上会相应会生成共 32 个文件夹（本文所用集群共 8 个节点，此处 topic1 和 topic2 replication-factor 均为 1），如下图所示。

![topic-partition log文件夹](https://img-1251474779.cos.ap-beijing.myqcloud.com/23a66b1eddc902e6554fa0f2e3ad5cf2.png)

每个日志文件都是一个 log entrie 序列，每个 log entrie 包含一个 4 字节整型数值（值为 N+5），1 个字节的 "magic value"，4 个字节的 CRC 校验码，其后跟 N 个字节的消息体。每条消息都有一个当前 Partition 下唯一的 64 字节的 offset，它指明了这条消息的起始位置。磁盘上存储的消息格式如下：


```
message length:
+-----------------+-------------+----------------+--------------+
|     4 byte      |   1 byte    |     4 byte     |   n byte     |
+---------------------------------------------------------------+
| log entrie(n+5) | magic value | CRC check code | message body |
+-----------------+-------------+----------------+--------------+
```

这个 log entries 并非由一个文件构成，而是分成多个 segment，每个 segment 以该 segment 第一条消息的 offset 命名并以“.kafka”为后缀。另外会有一个索引文件，它标明了每个 segment 下包含的 log entry 的 offset 范围，如下图所示。

![kafka log 在磁盘中的排列](https://img-1251474779.cos.ap-beijing.myqcloud.com/ace18b341531d5c8905e9eff8042ce01.png)

因为每条消息都被 append 到该 Partition 中，属于顺序写磁盘，因此效率非常高（经验证，顺序写磁盘效率比随机写内存还要高，这是 Kafka 高吞吐率的一个很重要的保证）。

![向partition写入消息](https://img-1251474779.cos.ap-beijing.myqcloud.com/6eaf2d21206b315a88da5c8091a6c083.png)

对于传统的 message queue 而言，一般会删除已经被消费的消息，而 Kafka 集群会保留所有的消息，无论其被消费与否。当然，因为磁盘限制，不可能永久保留所有数据（实际上也没必要），因此 Kafka 提供两种策略删除旧数据。一是基于时间，二是基于 Partition 文件大小。例如可以通过配置 $KAFKA_HOME/config/server.properties，让 Kafka 删除一周前的数据，也可在 Partition 文件超过 1GB 时删除旧数据，配置如下所示。

```
# The minimum age of a log file to be eligible for deletion
log.retention.hours=168
# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824
# The interval at which log segments are checked to see if they can be deleted according to the retention policies
log.retention.check.interval.ms=300000
# If log.cleaner.enable=true is set the cleaner will be enabled and individual logs can then be marked for log compaction.
log.cleaner.enable=false
```

这里要注意，因为 Kafka 读取特定消息的时间复杂度为 O(1)，即与文件大小无关，所以这里删除过期文件与提高 Kafka 性能无关。选择怎样的删除策略只与磁盘以及具体的需求有关。另外，Kafka 会为每一个 Consumer Group 保留一些 metadata 信息——当前消费的消息的 position，也即 offset。这个 offset 由 Consumer 控制。正常情况下 Consumer 会在消费完一条消息后递增该 offset。当然，Consumer 也可将 offset 设成一个较小的值，重新消费一些消息。因为 offet 由 Consumer 控制，所以 Kafka broker 是无状态的，它不需要标记哪些消息被哪些消费过，也不需要通过 broker 去保证同一个 Consumer Group 只有一个 Consumer 能消费某一条消息，因此也就不需要锁机制，这也为 Kafka 的高吞吐率提供了有力保障。

### Producer 消息路由

Producer 发送消息到 broker 时，会根据 Paritition 机制选择将其存储到哪一个 Partition。如果 Partition 机制设置合理，所有消息可以均匀分布到不同的 Partition 里，这样就实现了负载均衡。如果一个 Topic 对应一个文件，那这个文件所在的机器 I/O 将会成为这个 Topic 的性能瓶颈，而有了 Partition 后，不同的消息可以并行写入不同 broker 的不同 Partition 里，极大的提高了吞吐率。可以在 $KAFKA_HOME/config/server.properties 中通过配置项 num.partitions 来指定新建 Topic 的默认 Partition 数量，也可在创建 Topic 时通过参数指定，同时也可以在 Topic 创建之后通过 Kafka 提供的工具修改。

在发送一条消息时，可以指定这条消息的 key，Producer 根据这个 key 和 Partition 机制来判断应该将这条消息发送到哪个 Parition。Paritition 机制可以通过指定 Producer 的 paritition. class 这一参数来指定，该 class 必须实现 kafka.producer.Partitioner 接口。本例中如果 key 可以被解析为整数则将对应的整数与 Partition 总数取余，该消息会被发送到该数对应的 Partition。（每个 Parition 都会有个序号, 序号从 0 开始）


```java
import kafka.producer.Partitioner;
import kafka.utils.VerifiableProperties;

public class JasonPartitioner<T> implements Partitioner {

   public JasonPartitioner(VerifiableProperties verifiableProperties) {}

   @Override
   public int partition(Object key, int numPartitions) {
       try {
           int partitionNum = Integer.parseInt((String) key);
           return Math.abs(Integer.parseInt((String) key) % numPartitions);
       } catch (Exception e) {
           return Math.abs(key.hashCode() % numPartitions);
       }
   }
}
```

如果将上例中的类作为 partition.class，并通过如下代码发送 20 条消息（key 分别为 0，1，2，3）至 topic3（包含 4 个 Partition）。

```java
 public void sendMessage() throws InterruptedException{
　　for(int i = 1; i <= 5; i++){
　　      List messageList = new ArrayList<KeyedMessage<String, String>>();
　　      for(int j = 0; j < 4; j++）{
　　          messageList.add(new KeyedMessage<String, String>("topic2", j+"", "The " + i + " message for key " + j));
　　      }
　　      producer.send(messageList);
   }
　　producer.close();
}
```

则 key 相同的消息会被发送并存储到同一个 partition 里，而且 key 的序号正好和 Partition 序号相同。（Partition 序号从 0 开始，本例中的 key 也从 0 开始）。下图所示是通过 Java 程序调用 Consumer 后打印出的消息列表。

![消费消息列表](https://img-1251474779.cos.ap-beijing.myqcloud.com/ccecc519a0e614dd889585753c5b6f8f.png)

### Consumer Group

（本节所有描述都是基于 Consumer hight level API 而非 low level API）。

使用 Consumer high level API 时，同一 Topic 的一条消息只能被同一个 Consumer Group 内的一个 Consumer 消费，但多个 Consumer Group 可同时消费这一消息。

![消费关系](https://img-1251474779.cos.ap-beijing.myqcloud.com/68f2ca117290d8f438610923c108ce22.png)

这是 Kafka 用来实现一个 Topic 消息的广播（发给所有的 Consumer）和单播（发给某一个 Consumer）的手段。一个 Topic 可以对应多个 Consumer Group。如果需要实现广播，只要每个 Consumer 有一个独立的 Group 就可以了。要实现单播只要所有的 Consumer 在同一个 Group 里。用 Consumer Group 还可以将 Consumer 进行自由的分组而不需要多次发送消息到不同的 Topic。

实际上，Kafka 的设计理念之一就是同时提供离线处理和实时处理。根据这一特性，可以使用 Storm 这种实时流处理系统对消息进行实时在线处理，同时使用 Hadoop 这种批处理系统进行离线处理，还可以同时将数据实时备份到另一个数据中心，只需要保证这三个操作所使用的 Consumer 属于不同的 Consumer Group 即可。下图是 Kafka 在 Linkedin 的一种简化部署示意图。

![](https://img-1251474779.cos.ap-beijing.myqcloud.com/3ffb96d698fdbf58e84ac0ed3e268082.png)

下面这个例子更清晰地展示了 Kafka Consumer Group 的特性。首先创建一个 Topic (名为 topic1，包含 3 个 Partition)，然后创建一个属于 group1 的 Consumer 实例，并创建三个属于 group2 的 Consumer 实例，最后通过 Producer 向 topic1 发送 key 分别为 1，2，3 的消息。结果发现属于 group1 的 Consumer 收到了所有的这三条消息，同时 group2 中的 3 个 Consumer 分别收到了 key 为 1，2，3 的消息。如下图所示。

![](https://img-1251474779.cos.ap-beijing.myqcloud.com/3971ea5c5361b15712262ad2e336468b.png)

### Push vs. Pull

作为一个消息系统，Kafka 遵循了传统的方式，选择由 Producer 向 broker push 消息并由 Consumer 从 broker pull 消息。一些 logging-centric system，比如 Facebook 的[Scribe](https://github.com/facebookarchive/scribe)和 Cloudera 的[Flume](http://flume.apache.org/)，采用 push 模式。事实上，push 模式和 pull 模式各有优劣。

push 模式很难适应消费速率不同的消费者，因为消息发送速率是由 broker 决定的。push 模式的目标是尽可能以最快速度传递消息，但是这样很容易造成 Consumer 来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。而 pull 模式则可以根据 Consumer 的消费能力以适当的速率消费消息。

对于 Kafka 而言，pull 模式更合适。pull 模式可简化 broker 的设计，Consumer 可自主控制消费消息的速率，同时 Consumer 可以自己控制消费方式——即可批量消费也可逐条消费，同时还能选择不同的提交方式从而实现不同的传输语义。

### Kafka delivery guarantee

有这么几种可能的 delivery guarantee：

*   At most once 消息可能会丢，但绝不会重复传输

*   At least one 消息绝不会丢，但可能会重复传输

*   Exactly once 每条消息肯定会被传输一次且仅传输一次，很多时候这是用户所想要的。

    当 Producer 向 broker 发送消息时，一旦这条消息被 commit，因数 replication 的存在，它就不会丢。但是如果 Producer 发送数据给 broker 后，遇到网络问题而造成通信中断，那 Producer 就无法判断该条消息是否已经 commit。虽然 Kafka 无法确定网络故障期间发生了什么，但是 Producer 可以生成一种类似于主键的东西，发生故障时幂等性的重试多次，这样就做到了 Exactly once。截止到目前 (Kafka 0.8.2 版本，2015-03-04)，这一 Feature 还并未实现，有希望在 Kafka 未来的版本中实现。（所以目前默认情况下一条消息从 Producer 到 broker 是确保了 At least once，可通过设置 Producer 异步发送实现 At most once）。

    接下来讨论的是消息从 broker 到 Consumer 的 delivery guarantee 语义。（仅针对 Kafka consumer high level API）。Consumer 在从 broker 读取消息后，可以选择 commit，该操作会在 Zookeeper 中保存该 Consumer 在该 Partition 中读取的消息的 offset。该 Consumer 下一次再读该 Partition 时会从下一条开始读取。如未 commit，下一次读取的开始位置会跟上一次 commit 之后的开始位置相同。当然可以将 Consumer 设置为 autocommit，即 Consumer 一旦读到数据立即自动 commit。如果只讨论这一读取消息的过程，那 Kafka 是确保了 Exactly once。但实际使用中应用程序并非在 Consumer 读取完数据就结束了，而是要进行进一步处理，而数据处理与 commit 的顺序在很大程度上决定了消息从 broker 和 consumer 的 delivery guarantee semantic。

*   读完消息先 commit 再处理消息。这种模式下，如果 Consumer 在 commit 后还没来得及处理消息就 crash 了，下次重新开始工作后就无法读到刚刚已提交而未处理的消息，这就对应于 At most once

*   读完消息先处理再 commit。这种模式下，如果在处理完消息之后 commit 之前 Consumer crash 了，下次重新开始工作时还会处理刚刚未 commit 的消息，实际上该消息已经被处理过了。这就对应于 At least once。在很多使用场景下，消息都有一个主键，所以消息的处理往往具有幂等性，即多次处理这一条消息跟只处理一次是等效的，那就可以认为是 Exactly once。（笔者认为这种说法比较牵强，毕竟它不是 Kafka 本身提供的机制，主键本身也并不能完全保证操作的幂等性。而且实际上我们说 delivery guarantee 语义是讨论被处理多少次，而非处理结果怎样，因为处理方式多种多样，我们不应该把处理过程的特性——如是否幂等性，当成 Kafka 本身的 Feature）

*   如果一定要做到 Exactly once，就需要协调 offset 和实际操作的输出。精典的做法是引入两阶段提交。如果能让 offset 和操作输入存在同一个地方，会更简洁和通用。这种方式可能更好，因为许多输出系统可能不支持两阶段提交。比如，Consumer 拿到数据后可能把数据放到 HDFS（Hadoop分布式文件系统），如果把最新的 offset 和数据本身一起写到 HDFS，那就可以保证数据的输出和 offset 的更新要么都完成，要么都不完成，间接实现 Exactly once。（目前就 high level API 而言，offset 是存于 Zookeeper 中的，无法存于 HDFS，而 low level API 的 offset 是由自己去维护的，可以将之存于 HDFS 中）

总之，Kafka 默认保证 At least once，并且允许通过设置 Producer 异步提交来实现 At most once。而 Exactly once 要求与外部存储系统协作，幸运的是 Kafka 提供的 offset 可以非常直接非常容易得使用这种方式。
