---
title: kafka高可用性
date: 2018-11-26 17:26:34
tags:
  - introduction
categories:
  - kafka
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/kafka.png
---

# Kafka高可用性

Kafka 在 0.8 以前的版本中，并不提供 High Availablity 机制，一旦一个或多个 Broker 宕机，则宕机期间其上所有 Partition 都无法继续提供服务。若该 Broker 永远不能再恢复，亦或磁盘故障，则其上数据将丢失。而 Kafka 的设计目标之一即是提供数据持久化，同时对于分布式系统来说，尤其当集群规模上升到一定程度后，一台或者多台机器宕机的可能性大大提高，对 Failover 要求非常高。因此，Kafka 从 0.8 开始提供 High Availability 机制。本文从 Data Replication 和 Leader Election 两方面介绍了 Kafka 的 HA 机制。

<!--more-->

## Kafka 为何需要 High Available

### 为何需要 Replication

在 Kafka 在 0.8 以前的版本中，是没有 Replication 的，一旦某一个 Broker 宕机，则其上所有的 Partition 数据都不可被消费，这与 Kafka 数据持久性及 Delivery Guarantee 的设计目标相悖。同时 Producer 都不能再将数据存于这些 Partition 中。

*   如果 Producer 使用同步模式则 Producer 会在尝试重新发送`message.send.max.retries`（默认值为 3）次后抛出 Exception，用户可以选择停止发送后续数据也可选择继续选择发送。而前者会造成数据的阻塞，后者会造成本应发往该 Broker 的数据的丢失。
*   如果 Producer 使用异步模式，则 Producer 会尝试重新发送`message.send.max.retries`（默认值为 3）次后记录该异常并继续发送后续数据，这会造成数据丢失并且用户只能通过日志发现该问题。同时，Kafka 的 Producer 并未对异步模式提供 callback 接口。

由此可见，在没有 Replication 的情况下，一旦某机器宕机或者某个 Broker 停止工作则会造成整个系统的可用性降低。随着集群规模的增加，整个集群中出现该类异常的几率大大增加，因此对于生产系统而言 Replication 机制的引入非常重要。

### 为何需要 Leader Election

注意：本文所述 Leader Election 主要指 Replica 之间的 Leader Election。

引入 Replication 之后，同一个 Partition 可能会有多个 Replica，而这时需要在这些 Replication 之间选出一个 Leader，Producer 和 Consumer 只与这个 Leader 交互，其它 Replica 作为 Follower 从 Leader 中复制数据。

因为需要保证同一个 Partition 的多个 Replica 之间的数据一致性（其中一个宕机后其它 Replica 必须要能继续服务并且即不能造成数据重复也不能造成数据丢失）。如果没有一个 Leader，所有 Replica 都可同时读 / 写数据，那就需要保证多个 Replica 之间互相（N×N 条通路）同步数据，数据的一致性和有序性非常难保证，大大增加了 Replication 实现的复杂性，同时也增加了出现异常的几率。而引入 Leader 后，只有 Leader 负责数据读写，Follower 只向 Leader 顺序 Fetch 数据（N 条通路），系统更加简单且高效。

## Kafka HA 设计解析

### 如何将所有 Replica 均匀分布到整个集群

为了更好的做负载均衡，Kafka 尽量将所有的 Partition 均匀分配到整个集群上。一个典型的部署方式是一个 Topic 的 Partition 数量大于 Broker 的数量。同时为了提高 Kafka 的容错能力，也需要将同一个 Partition 的 Replica 尽量分散到不同的机器。实际上，如果所有的 Replica 都在同一个 Broker 上，那一旦该 Broker 宕机，该 Partition 的所有 Replica 都无法工作，也就达不到 HA 的效果。同时，如果某个 Broker 宕机了，需要保证它上面的负载可以被均匀的分配到其它幸存的所有 Broker 上。

Kafka 分配 Replica 的算法如下：

1.  将所有 Broker（假设共 n 个 Broker）和待分配的 Partition 排序
2.  将第 i 个 Partition 分配到第（i mod n）个 Broker 上
3.  将第 i 个 Partition 的第 j 个 Replica 分配到第（(i + j) mode n）个 Broker 上

### Data Replication

Kafka 的 Data Replication 需要解决如下问题：

*   怎样 Propagate 消息
*   在向 Producer 发送 ACK 前需要保证有多少个 Replica 已经收到该消息
*   怎样处理某个 Replica 不工作的情况
*   怎样处理 Failed Replica 恢复回来的情况

#### Propagate 消息

Producer 在发布消息到某个 Partition 时，先通过 ZooKeeper 找到该 Partition 的 Leader，然后无论该 Topic 的 Replication Factor 为多少（也即该 Partition 有多少个 Replica），Producer 只将该消息发送到该 Partition 的 Leader。Leader 会将该消息写入其本地 Log。每个 Follower 都从 Leader pull 数据。这种方式上，Follower 存储的数据顺序与 Leader 保持一致。Follower 在收到该消息并写入其 Log 后，向 Leader 发送 ACK。一旦 Leader 收到了 ISR 中的所有 Replica 的 ACK，该消息就被认为已经 commit 了，Leader 将增加 HW 并且向 Producer 发送 ACK。

为了提高性能，每个 Follower 在接收到数据后就立马向 Leader 发送 ACK，而非等到数据写入 Log 中。因此，对于已经 commit 的消息，Kafka 只能保证它被存于多个 Replica 的内存中，而不能保证它们被持久化到磁盘中，也就不能完全保证异常发生后该条消息一定能被 Consumer 消费。但考虑到这种场景非常少见，可以认为这种方式在性能和数据持久化上做了一个比较好的平衡。在将来的版本中，Kafka 会考虑提供更高的持久性。

Consumer 读消息也是从 Leader 读取，只有被 commit 过的消息（offset 低于 HW 的消息）才会暴露给 Consumer。

Kafka Replication 的数据流如下图所示：

![](https://static001.infoq.cn/resource/image/83/88/83afae5ea62d63d69c69cd650ae14e88.png)

#### ACK 前需要保证有多少个备份

和大部分分布式系统一样，Kafka 处理失败需要明确定义一个 Broker 是否“活着”。对于 Kafka 而言，Kafka 存活包含两个条件，一是它必须维护与 ZooKeeper 的 session（这个通过 ZooKeeper 的 Heartbeat 机制来实现）。二是 Follower 必须能够及时将 Leader 的消息复制过来，不能“落后太多”。

Leader 会跟踪与其保持同步的 Replica 列表，该列表称为 ISR（即 in-sync Replica）。如果一个 Follower 宕机，或者落后太多，Leader 将把它从 ISR 中移除。这里所描述的“落后太多”指 Follower 复制的消息落后于 Leader 后的条数超过预定值（该值可在 $KAFKA_HOME/config/server.properties 中通过`replica.lag.max.messages`配置，其默认值是 4000）或者 Follower 超过一定时间（该值可在 $KAFKA_HOME/config/server.properties 中通过`replica.lag.time.max.ms`来配置，其默认值是 10000）未向 Leader 发送 fetch 请求。

Kafka 的复制机制既不是完全的同步复制，也不是单纯的异步复制。事实上，完全同步复制要求所有能工作的 Follower 都复制完，这条消息才会被认为 commit，这种复制方式极大的影响了吞吐率（高吞吐率是 Kafka 非常重要的一个特性）。而异步复制方式下，Follower 异步的从 Leader 复制数据，数据只要被 Leader 写入 log 就被认为已经 commit，这种情况下如果 Follower 都复制完都落后于 Leader，而如果 Leader 突然宕机，则会丢失数据。而 Kafka 的这种使用 ISR 的方式则很好的均衡了确保数据不丢失以及吞吐率。Follower 可以批量的从 Leader 复制数据，这样极大的提高复制性能（批量写磁盘），极大减少了 Follower 与 Leader 的差距。

需要说明的是，Kafka 只解决 fail/recover，不处理“Byzantine”（“拜占庭”）问题。一条消息只有被 ISR 里的所有 Follower 都从 Leader 复制过去才会被认为已提交。这样就避免了部分数据被写进了 Leader，还没来得及被任何 Follower 复制就宕机了，而造成数据丢失（Consumer 无法消费这些数据）。而对于 Producer 而言，它可以选择是否等待消息 commit，这可以通过`request.required.acks`来设置。这种机制确保了只要 ISR 有一个或以上的 Follower，一条被 commit 的消息就不会丢失。

#### Leader Election 算法

上文说明了 Kafka 是如何做 Replication 的，另外一个很重要的问题是当 Leader 宕机了，怎样在 Follower 中选举出新的 Leader。因为 Follower 可能落后许多或者 crash 了，所以必须确保选择“最新”的 Follower 作为新的 Leader。一个基本的原则就是，如果 Leader 不在了，新的 Leader 必须拥有原来的 Leader commit 过的所有消息。这就需要作一个折衷，如果 Leader 在标明一条消息被 commit 前等待更多的 Follower 确认，那在它宕机之后就有更多的 Follower 可以作为新的 Leader，但这也会造成吞吐率的下降。

一种非常常用的选举 leader 的方式是“Majority Vote”（“少数服从多数”），但 Kafka 并未采用这种方式。这种模式下，如果我们有 2f+1 个 Replica（包含 Leader 和 Follower），那在 commit 之前必须保证有 f+1 个 Replica 复制完消息，为了保证正确选出新的 Leader，fail 的 Replica 不能超过 f 个。因为在剩下的任意 f+1 个 Replica 里，至少有一个 Replica 包含有最新的所有消息。这种方式有个很大的优势，系统的 latency 只取决于最快的几个 Broker，而非最慢那个。Majority Vote 也有一些劣势，为了保证 Leader Election 的正常进行，它所能容忍的 fail 的 follower 个数比较少。如果要容忍 1 个 follower 挂掉，必须要有 3 个以上的 Replica，如果要容忍 2 个 Follower 挂掉，必须要有 5 个以上的 Replica。也就是说，在生产环境下为了保证较高的容错程度，必须要有大量的 Replica，而大量的 Replica 又会在大数据量下导致性能的急剧下降。这就是这种算法更多用在[ZooKeeper](http://zookeeper.apache.org/)这种共享集群配置的系统中而很少在需要存储大量数据的系统中使用的原因。例如 HDFS 的 HA Feature 是基于[majority-vote-based journal](http://blog.cloudera.com/blog/2012/10/quorum-based-journaling-in-cdh4-1)，但是它的数据存储并没有使用这种方式。

实际上，Leader Election 算法非常多，比如 ZooKeeper 的[Zab](http://web.stanford.edu/class/cs347/reading/zab.pdf), [Raft](https://ramcloud.stanford.edu/wiki/download/attachments/11370504/raft.pdf)和[Viewstamped Replication](http://pmg.csail.mit.edu/papers/vr-revisited.pdf)。而 Kafka 所使用的 Leader Election 算法更像微软的[PacificA](http://research.microsoft.com/apps/pubs/default.aspx?id=66814)算法。

Kafka 在 ZooKeeper 中动态维护了一个 ISR（in-sync replicas），这个 ISR 里的所有 Replica 都跟上了 leader，只有 ISR 里的成员才有被选为 Leader 的可能。在这种模式下，对于 f+1 个 Replica，一个 Partition 能在保证不丢失已经 commit 的消息的前提下容忍 f 个 Replica 的失败。在大多数使用场景中，这种模式是非常有利的。事实上，为了容忍 f 个 Replica 的失败，Majority Vote 和 ISR 在 commit 前需要等待的 Replica 数量是一样的，但是 ISR 需要的总的 Replica 的个数几乎是 Majority Vote 的一半。

虽然 Majority Vote 与 ISR 相比有不需等待最慢的 Broker 这一优势，但是 Kafka 作者认为 Kafka 可以通过 Producer 选择是否被 commit 阻塞来改善这一问题，并且节省下来的 Replica 和磁盘使得 ISR 模式仍然值得。

#### 如何处理所有 Replica 都不工作

上文提到，在 ISR 中至少有一个 follower 时，Kafka 可以确保已经 commit 的数据不丢失，但如果某个 Partition 的所有 Replica 都宕机了，就无法保证数据不丢失了。这种情况下有两种可行的方案：

*   等待 ISR 中的任一个 Replica“活”过来，并且选它作为 Leader
*   选择第一个“活”过来的 Replica（不一定是 ISR 中的）作为 Leader

这就需要在可用性和一致性当中作出一个简单的折衷。如果一定要等待 ISR 中的 Replica“活”过来，那不可用的时间就可能会相对较长。而且如果 ISR 中的所有 Replica 都无法“活”过来了，或者数据都丢失了，这个 Partition 将永远不可用。选择第一个“活”过来的 Replica 作为 Leader，而这个 Replica 不是 ISR 中的 Replica，那即使它并不保证已经包含了所有已 commit 的消息，它也会成为 Leader 而作为 consumer 的数据源（前文有说明，所有读写都由 Leader 完成）。Kafka0.8.* 使用了第二种方式。根据 Kafka 的文档，在以后的版本中，Kafka 支持用户通过配置选择这两种方式中的一种，从而根据不同的使用场景选择高可用性还是强一致性。

#### 如何选举 Leader

最简单最直观的方案是，所有 Follower 都在 ZooKeeper 上设置一个 Watch，一旦 Leader 宕机，其对应的 ephemeral znode 会自动删除，此时所有 Follower 都尝试创建该节点，而创建成功者（ZooKeeper 保证只有一个能创建成功）即是新的 Leader，其它 Replica 即为 Follower。

但是该方法会有 3 个问题：

*   split-brain 这是由 ZooKeeper 的特性引起的，虽然 ZooKeeper 能保证所有 Watch 按顺序触发，但并不能保证同一时刻所有 Replica“看”到的状态是一样的，这就可能造成不同 Replica 的响应不一致
*   herd effect 如果宕机的那个 Broker 上的 Partition 比较多，会造成多个 Watch 被触发，造成集群内大量的调整
*   ZooKeeper 负载过重 每个 Replica 都要为此在 ZooKeeper 上注册一个 Watch，当集群规模增加到几千个 Partition 时 ZooKeeper 负载会过重。

Kafka 0.8.* 的 Leader Election 方案解决了上述问题，它在所有 broker 中选出一个 controller，所有 Partition 的 Leader 选举都由 controller 决定。controller 会将 Leader 的改变直接通过 RPC 的方式（比 ZooKeeper Queue 的方式更高效）通知需为为此作为响应的 Broker。同时 controller 也负责增删 Topic 以及 Replica 的重新分配。

### HA 相关 ZooKeeper 结构

首先声明本节所示 ZooKeeper 结构中，实线框代表路径名是固定的，而虚线框代表路径名与业务相关

**admin** （该目录下 znode 只有在有相关操作时才会存在，操作结束时会将其删除）

![](https://static001.infoq.cn/resource/image/6c/9f/6c8411ba9131f47ddc2abc143d90499f.png)

/admin/preferred_replica_election 数据结构
```json
{
   "fields":[
      {
         "name":"version",
         "type":"int",
         "doc":"version id"
      },
      {
         "name":"partitions",
         "type":{
            "type":"array",
            "items":{
               "fields":[
                  {
                     "name":"topic",
                     "type":"string",
                     "doc":"topic of the partition for which preferred replica election should be triggered"
                  },
                  {
                     "name":"partition",
                     "type":"int",
                     "doc":"the partition for which preferred replica election should be triggered"
                  }
               ],
            }
            "doc":"an array of partitions for which preferred replica election should be triggered"
         }
      }
   ]
}
```



Example:
```json
{
  "version": 1,
  "partitions":
     [
        {
            "topic": "topic1",
            "partition": 8         
        },
        {
            "topic": "topic2",
            "partition": 16        
        }
     ]            
}
```



`/admin/reassign_partitions`用于将一些 Partition 分配到不同的 broker 集合上。对于每个待重新分配的 Partition，Kafka 会在该 znode 上存储其所有的 Replica 和相应的 Broker id。该 znode 由管理进程创建并且一旦重新分配成功它将会被自动移除。其数据结构如下：
```json
{
  "fields":[
    {
      "name":"version",
      "type":"int",
      "doc":"version id"
    },
    {
      "name":"partitions",
      "type":{
        "type":"array",
        "items":{
          "fields":[
            {
              "name":"topic",
              "type":"string",
              "doc":"topic of the partition to be reassigned"
            },
            {
              "name":"partition",
              "type":"int",
              "doc":"the partition to be reassigned"
            },
            {
              "name":"replicas",
              "type":"array",
              "items":"int",
              "doc":"a list of replica ids"
            }
          ]
        },
        "doc":"an array of partitions to be reassigned to new replicas"
      }
    }
  ]
}
```



Example:
{
  "version": 1,
  "partitions":
     [
        {
            "topic": "topic3",
            "partition": 1,
            "replicas": [1, 2, 3]
        }
     ]            
}

/admin/delete_topics 数据结构：

Schema:
{ "fields":
    [ {"name": "version", "type": "int", "doc": "version id"},
      {"name": "topics",
       "type": { "type": "array", "items": "string", "doc": "an array of topics to be deleted"}
      } ]
}

Example:
{
  "version": 1,
  "topics": ["topic4", "topic5"]
}

**brokers**

![](https://static001.infoq.cn/resource/image/c7/63/c7c5b0deb2b762b377efba7818eabe63.png)

broker（即`/brokers/ids/[brokerId]`）存储“活着”的 broker 信息。数据结构如下：

Schema:
{ "fields":
    [ {"name": "version", "type": "int", "doc": "version id"},
      {"name": "host", "type": "string", "doc": "ip address or host name of the broker"},
      {"name": "port", "type": "int", "doc": "port of the broker"},
      {"name": "jmx_port", "type": "int", "doc": "port for jmx"}
    ]
}

Example:
{
    "jmx_port":-1,
    "host":"node1",
    "version":1,
    "port":9092
}

topic 注册信息（`/brokers/topics/[topic]`），存储该 topic 的所有 partition 的所有 replica 所在的 broker id，第一个 replica 即为 preferred replica，对一个给定的 partition，它在同一个 broker 上最多只有一个 replica, 因此 broker id 可作为 replica id。数据结构如下：

Schema:
{ "fields" :
    [ {"name": "version", "type": "int", "doc": "version id"},
      {"name": "partitions",
       "type": {"type": "map",
                "values": {"type": "array", "items": "int", "doc": "a list of replica ids"},
                "doc": "a map from partition id to replica list"},
      }
    ]
}
Example:
{
    "version":1,
    "partitions":
        {"12":[6],
        "8":[2],
        "4":[6],
        "11":[5],
        "9":[3],
        "5":[7],
        "10":[4],
        "6":[8],
        "1":[3],
        "0":[2],
        "2":[4],
        "7":[1],
        "3":[5]}
}

partition state（`/brokers/topics/[topic]/partitions/[partitionId]/state`） 结构如下：

Schema:
{ "fields":
    [ {"name": "version", "type": "int", "doc": "version id"},
      {"name": "isr",
       "type": {"type": "array",
                "items": "int",
                "doc": "an array of the id of replicas in isr"}
      },
      {"name": "leader", "type": "int", "doc": "id of the leader replica"},
      {"name": "controller_epoch", "type": "int", "doc": "epoch of the controller that last updated the leader and isr info"},
      {"name": "leader_epoch", "type": "int", "doc": "epoch of the leader"}
    ]
}

Example:
{
    "controller_epoch":29,
    "leader":2,
    "version":1,
    "leader_epoch":48,
    "isr":[2]
}

**controller**  

`/controller -> int (broker id of the controller)`存储当前 controller 的信息

Schema:
{ "fields":
    [ {"name": "version", "type": "int", "doc": "version id"},
      {"name": "brokerid", "type": "int", "doc": "broker id of the controller"}
    ]
}
Example:
{
    "version":1,
　　"brokerid":8
}

`/controller_epoch -> int (epoch)`直接以整数形式存储 controller epoch，而非像其它 znode 一样以 JSON 字符串形式存储。

### broker failover 过程简介

1.  Controller 在 ZooKeeper 注册 Watch，一旦有 Broker 宕机（这是用宕机代表任何让系统认为其 die 的情景，包括但不限于机器断电，网络不可用，GC 导致的 Stop The World，进程 crash 等），其在 ZooKeeper 对应的 znode 会自动被删除，ZooKeeper 会 fire Controller 注册的 watch，Controller 读取最新的幸存的 Broker。
2.  Controller 决定 set_p，该集合包含了宕机的所有 Broker 上的所有 Partition。
3.  对 set_p 中的每一个 Partition

    3.1 从`/brokers/topics/[topic]/partitions/[partition]/state`读取该 Partition 当前的 ISR

    3.2 决定该 Partition 的新 Leader。如果当前 ISR 中有至少一个 Replica 还幸存，则选择其中一个作为新 Leader，新的 ISR 则包含当前 ISR 中所有幸存的 Replica。否则选择该 Partition 中任意一个幸存的 Replica 作为新的 Leader 以及 ISR（该场景下可能会有潜在的数据丢失）。如果该 Partition 的所有 Replica 都宕机了，则将新的 Leader 设置为 -1。

    3.3 将新的 Leader，ISR 和新的`leader_epoch`及`controller_epoch`写入`/brokers/topics/[topic]/partitions/[partition]/state`。注意，该操作只有其 version 在 3.1 至 3.3 的过程中无变化时才会执行，否则跳转到 3.1

4.  直接通过 RPC 向 set_p 相关的 Broker 发送 LeaderAndISRRequest 命令。Controller 可以在一个 RPC 操作中发送多个命令从而提高效率。

    broker failover 顺序图如下所示。

    ![](https://static001.infoq.cn/resource/image/1e/2d/1e39d5d6165cf0117b537589a660e82d.png)

## Broker Failover 过程

### Controller 对 Broker failure 的处理过程

1.  Controller 在 ZooKeeper 的`/brokers/ids`节点上注册 Watch。一旦有 Broker 宕机（本文用宕机代表任何让 Kafka 认为其 Broker die 的情景，包括但不限于机器断电，网络不可用，GC 导致的 Stop The World，进程 crash 等），其在 ZooKeeper 对应的 Znode 会自动被删除，ZooKeeper 会 fire Controller 注册的 Watch，Controller 即可获取最新的幸存的 Broker 列表。
2.  Controller 决定 set_p，该集合包含了宕机的所有 Broker 上的所有 Partition。
3.  对 set_p 中的每一个 Partition：

    3.1 从`/brokers/topics/[topic]/partitions/[partition]/state`读取该 Partition 当前的 ISR。

    3.2 决定该 Partition 的新 Leader。如果当前 ISR 中有至少一个 Replica 还幸存，则选择其中一个作为新 Leader，新的 ISR 则包含当前 ISR 中所有幸存的 Replica。否则选择该 Partition 中任意一个幸存的 Replica 作为新的 Leader 以及 ISR（该场景下可能会有潜在的数据丢失）。如果该 Partition 的所有 Replica 都宕机了，则将新的 Leader 设置为 -1。

    3.3 将新的 Leader，ISR 和新的`leader_epoch`及`controller_epoch`写入`/brokers/topics/[topic]/partitions/[partition]/state`。注意，该操作只有 Controller 版本在 3.1 至 3.3 的过程中无变化时才会执行，否则跳转到 3.1。

4.  直接通过 RPC 向 set_p 相关的 Broker 发送 LeaderAndISRRequest 命令。Controller 可以在一个 RPC 操作中发送多个命令从而提高效率。

    Broker failover 顺序图如下所示。

    ![](https://static001.infoq.cn/resource/image/1e/2d/1e39d5d6165cf0117b537589a660e82d.png)

LeaderAndIsrRequest 结构如下

![](https://static001.infoq.cn/resource/image/c9/67/c9627fa7246f4df539da3d7f3b66ca67.png)

LeaderAndIsrResponse 结构如下

![](https://static001.infoq.cn/resource/image/d6/20/d6121a3ce66cc5d9e90c081af7de7120.png)

### 创建 / 删除 Topic

1.  Controller 在 ZooKeeper 的`/brokers/topics`节点上注册 Watch，一旦某个 Topic 被创建或删除，则 Controller 会通过 Watch 得到新创建 / 删除的 Topic 的 Partition/Replica 分配。
2.  对于删除 Topic 操作，Topic 工具会将该 Topic 名字存于`/admin/delete_topics`。若`delete.topic.enable`为 true，则 Controller 注册在`/admin/delete_topics`上的 Watch 被 fire，Controller 通过回调向对应的 Broker 发送 StopReplicaRequest，若为 false 则 Controller 不会在`/admin/delete_topics`上注册 Watch，也就不会对该事件作出反应。
3.  对于创建 Topic 操作，Controller 从`/brokers/ids`读取当前所有可用的 Broker 列表，对于 set_p 中的每一个 Partition：

    3.1 从分配给该 Partition 的所有 Replica（称为 AR）中任选一个可用的 Broker 作为新的 Leader，并将 AR 设置为新的 ISR（因为该 Topic 是新创建的，所以 AR 中所有的 Replica 都没有数据，可认为它们都是同步的，也即都在 ISR 中，任意一个 Replica 都可作为 Leader）

    3.2 将新的 Leader 和 ISR 写入`/brokers/topics/[topic]/partitions/[partition]`

4.  直接通过 RPC 向相关的 Broker 发送 LeaderAndISRRequest。

    创建 Topic 顺序图如下所示。

    ![](https://static001.infoq.cn/resource/image/51/d6/51d051dfffd50ca924f11a51233274d6.png)

### Broker 响应请求流程

Broker 通过`kafka.network.SocketServer`及相关模块接受各种请求并作出响应。整个网络通信模块基于 Java NIO 开发，并采用 Reactor 模式，其中包含 1 个 Acceptor 负责接受客户请求，N 个 Processor 负责读写数据，M 个 Handler 处理业务逻辑。

Acceptor 的主要职责是监听并接受客户端（请求发起方，包括但不限于 Producer，Consumer，Controller，Admin Tool）的连接请求，并建立和客户端的数据传输通道，然后为该客户端指定一个 Processor，至此它对该客户端该次请求的任务就结束了，它可以去响应下一个客户端的连接请求了。其核心代码如下。

![](https://static001.infoq.cn/resource/image/6f/14/6f7dd41ab4da75b1c035784d9feb1b14.png)

Processor 主要负责从客户端读取数据并将响应返回给客户端，它本身并不处理具体的业务逻辑，并且其内部维护了一个队列来保存分配给它的所有 SocketChannel。Processor 的 run 方法会循环从队列中取出新的 SocketChannel 并将其`SelectionKey.OP_READ`注册到 selector 上，然后循环处理已就绪的读（请求）和写（响应）。Processor 读取完数据后，将其封装成 Request 对象并将其交给 RequestChannel。

RequestChannel 是 Processor 和 KafkaRequestHandler 交换数据的地方，它包含一个队列 requestQueue 用来存放 Processor 加入的 Request，KafkaRequestHandler 会从里面取出 Request 来处理；同时它还包含一个 respondQueue，用来存放 KafkaRequestHandler 处理完 Request 后返还给客户端的 Response。

Processor 会通过 processNewResponses 方法依次将 requestChannel 中 responseQueue 保存的 Response 取出，并将对应的`SelectionKey.OP_WRITE`事件注册到 selector 上。当 selector 的 select 方法返回时，对检测到的可写通道，调用 write 方法将 Response 返回给客户端。

KafkaRequestHandler 循环从 RequestChannel 中取 Request 并交给`kafka.server.KafkaApis`处理具体的业务逻辑。

### LeaderAndIsrRequest 响应过程

对于收到的 LeaderAndIsrRequest，Broker 主要通过 ReplicaManager 的 becomeLeaderOrFollower 处理，流程如下：

1.  若请求中 controllerEpoch 小于当前最新的 controllerEpoch，则直接返回 ErrorMapping.StaleControllerEpochCode。
2.  对于请求中 partitionStateInfos 中的每一个元素，即（(topic, partitionId), partitionStateInfo)：

    2.1 若 partitionStateInfo 中的 leader epoch 大于当前 ReplicManager 中存储的 (topic, partitionId) 对应的 partition 的 leader epoch，则：

    2.1.1 若当前 brokerid（或者说 replica id）在 partitionStateInfo 中，则将该 partition 及 partitionStateInfo 存入一个名为 partitionState 的 HashMap 中

    2.1.2 否则说明该 Broker 不在该 Partition 分配的 Replica list 中，将该信息记录于 log 中

    2.2 否则将相应的 Error code（ErrorMapping.StaleLeaderEpochCode）存入 Response 中

3.  筛选出 partitionState 中 Leader 与当前 Broker ID 相等的所有记录存入 partitionsTobeLeader 中，其它记录存入 partitionsToBeFollower 中。
4.  若 partitionsTobeLeader 不为空，则对其执行 makeLeaders 方。
5.  若 partitionsToBeFollower 不为空，则对其执行 makeFollowers 方法。
6.  若 highwatermak 线程还未启动，则将其启动，并将 hwThreadInitialized 设为 true。
7.  关闭所有 Idle 状态的 Fetcher。

LeaderAndIsrRequest 处理过程如下图所示

![](https://static001.infoq.cn/resource/image/99/07/99b9ffa122f721ef4a755034e08c9e07.png)

### Broker 启动过程

Broker 启动后首先根据其 ID 在 ZooKeeper 的`/brokers/ids`zonde 下创建临时子节点（[Ephemeral node](http://zookeeper.apache.org/doc/trunk/zookeeperOver.html#Nodes+and+ephemeral+nodes)），创建成功后 Controller 的 ReplicaStateMachine 注册其上的 Broker Change Watch 会被 fire，从而通过回调 KafkaController.onBrokerStartup 方法完成以下步骤：

1.  向所有新启动的 Broker 发送 UpdateMetadataRequest，其定义如下。

    ![](https://static001.infoq.cn/resource/image/f6/19/f648909e076d75c0c0050b851034e019.png)

2.  将新启动的 Broker 上的所有 Replica 设置为 OnlineReplica 状态，同时这些 Broker 会为这些 Partition 启动 high watermark 线程。
3.  通过 partitionStateMachine 触发 OnlinePartitionStateChange。

### Controller Failover

Controller 也需要 Failover。每个 Broker 都会在 Controller Path (`/controller`) 上注册一个 Watch。当前 Controller 失败时，对应的 Controller Path 会自动消失（因为它是 Ephemeral Node），此时该 Watch 被 fire，所有“活”着的 Broker 都会去竞选成为新的 Controller（创建新的 Controller Path），但是只会有一个竞选成功（这点由 ZooKeeper 保证）。竞选成功者即为新的 Leader，竞选失败者则重新在新的 Controller Path 上注册 Watch。因为[ZooKeeper 的 Watch 是一次性的，被 fire 一次之后即失效](http://zookeeper.apache.org/doc/trunk/zookeeperProgrammers.html#ch_zkWatches)，所以需要重新注册。

Broker 成功竞选为新 Controller 后会触发 KafkaController.onControllerFailover 方法，并在该方法中完成如下操作：

1.  读取并增加 Controller Epoch。
2.  在 ReassignedPartitions Patch(`/admin/reassign_partitions`) 上注册 Watch。
3.  在 PreferredReplicaElection Path(`/admin/preferred_replica_election`) 上注册 Watch。
4.  通过 partitionStateMachine 在 Broker Topics Patch(`/brokers/topics`) 上注册 Watch。
5.  若`delete.topic.enable`设置为 true（默认值是 false），则 partitionStateMachine 在 Delete Topic Patch(`/admin/delete_topics`) 上注册 Watch。
6.  通过 replicaStateMachine 在 Broker Ids Patch(`/brokers/ids`) 上注册 Watch。
7.  初始化 ControllerContext 对象，设置当前所有 Topic，“活”着的 Broker 列表，所有 Partition 的 Leader 及 ISR 等。
8.  启动 replicaStateMachine 和 partitionStateMachine。
9.  将 brokerState 状态设置为 RunningAsController。
10.  将每个 Partition 的 Leadership 信息发送给所有“活”着的 Broker。
11.  若`auto.leader.rebalance.enable`配置为 true（默认值是 true），则启动 partition-rebalance 线程。
12.  若`delete.topic.enable`设置为 true 且 Delete Topic Patch(`/admin/delete_topics`) 中有值，则删除相应的 Topic。

### Partition 重新分配

管理工具发出重新分配 Partition 请求后，会将相应信息写到`/admin/reassign_partitions`上，而该操作会触发 ReassignedPartitionsIsrChangeListener，从而通过执行回调函数 KafkaController.onPartitionReassignment 来完成以下操作：

1.  将 ZooKeeper 中的 AR（Current Assigned Replicas）更新为 OAR（Original list of replicas for partition） + RAR（Reassigned replicas）。
2.  强制更新 ZooKeeper 中的 leader epoch，向 AR 中的每个 Replica 发送 LeaderAndIsrRequest。
3.  将 RAR - OAR 中的 Replica 设置为 NewReplica 状态。
4.  等待直到 RAR 中所有的 Replica 都与其 Leader 同步。
5.  将 RAR 中所有的 Replica 都设置为 OnlineReplica 状态。
6.  将 Cache 中的 AR 设置为 RAR。
7.  若 Leader 不在 RAR 中，则从 RAR 中重新选举出一个新的 Leader 并发送 LeaderAndIsrRequest。若新的 Leader 不是从 RAR 中选举而出，则还要增加 ZooKeeper 中的 leader epoch。
8.  将 OAR - RAR 中的所有 Replica 设置为 OfflineReplica 状态，该过程包含两部分。第一，将 ZooKeeper 上 ISR 中的 OAR - RAR 移除并向 Leader 发送 LeaderAndIsrRequest 从而通知这些 Replica 已经从 ISR 中移除；第二，向 OAR - RAR 中的 Replica 发送 StopReplicaRequest 从而停止不再分配给该 Partition 的 Replica。
9.  将 OAR - RAR 中的所有 Replica 设置为 NonExistentReplica 状态从而将其从磁盘上删除。
10.  将 ZooKeeper 中的 AR 设置为 RAR。
11.  删除`/admin/reassign_partition`。

**_注意_**：最后一步才将 ZooKeeper 中的 AR 更新，因为这是唯一一个持久存储 AR 的地方，如果 Controller 在这一步之前 crash，新的 Controller 仍然能够继续完成该过程。

以下是 Partition 重新分配的案例，OAR = ｛1，2，3｝，RAR = ｛4，5，6｝，Partition 重新分配过程中 ZooKeeper 中的 AR 和 Leader/ISR 路径如下

| AR | leader/isr | Sttep |
| --- | --- | --- |
| {1,2,3} | 1/{1,2,3} | (initial state) |
| {1,2,3,4,5,6} | 1/{1,2,3} | (step 2) |
| {1,2,3,4,5,6} | 1/{1,2,3,4,5,6} | (step 4) |
| {1,2,3,4,5,6} | 4/{1,2,3,4,5,6} | (step 7) |
| {1,2,3,4,5,6} | 4/{4,5,6} | (step 8) |
| {4,5,6} | 4/{4,5,6} | (step 10) |

### Follower 从 Leader Fetch 数据

Follower 通过向 Leader 发送 FetchRequest 获取消息，FetchRequest 结构如下

![](https://static001.infoq.cn/resource/image/2d/b1/2d3bc7798cd01e41041da838a6e534b1.png)

从 FetchRequest 的结构可以看出，每个 Fetch 请求都要指定最大等待时间和最小获取字节数，以及由 TopicAndPartition 和 PartitionFetchInfo 构成的 Map。实际上，Follower 从 Leader 数据和 Consumer 从 Broker Fetch 数据，都是通过 FetchRequest 请求完成，所以在 FetchRequest 结构中，其中一个字段是 clientID，并且其默认值是 ConsumerConfig.DefaultClientId。

Leader 收到 Fetch 请求后，Kafka 通过 KafkaApis.handleFetchRequest 响应该请求，响应过程如下：

1.  replicaManager 根据请求读出数据存入 dataRead 中。
2.  如果该请求来自 Follower 则更新其相应的 LEO（log end offset）以及相应 Partition 的 High Watermark
3.  根据 dataRead 算出可读消息长度（单位为字节）并存入 bytesReadable 中。
4.  满足下面 4 个条件中的 1 个，则立即将相应的数据返回
    *   Fetch 请求不希望等待，即 fetchRequest.macWait <= 0
    *   Fetch 请求不要求一定能取到消息，即 fetchRequest.numPartitions <= 0，也即 requestInfo 为空
    *   有足够的数据可供返回，即 bytesReadable >= fetchRequest.minBytes
    *   读取数据时发生异常
5.  若不满足以上 4 个条件，FetchRequest 将不会立即返回，并将该请求封装成 DelayedFetch。检查该 DeplayedFetch 是否满足，若满足则返回请求，否则将该请求加入 Watch 列表

Leader 通过以 FetchResponse 的形式将消息返回给 Follower，FetchResponse 结构如下

![](https://static001.infoq.cn/resource/image/a5/9c/a5b4b661ec2970fe44774ac127378e9c.png)

## Replication 工具

### Topic Tool

`$KAFKA_HOME/bin/kafka-topics.sh`，该工具可用于创建、删除、修改、查看某个 Topic，也可用于列出所有 Topic。另外，该工具还可修改某个 Topic 的以下配置。

unclean.leader.election.enable
delete.retention.ms
segment.jitter.ms
retention.ms
flush.ms
segment.bytes
flush.messages
segment.ms
retention.bytes
cleanup.policy
segment.index.bytes
min.cleanable.dirty.ratio
max.message.bytes
file.delete.delay.ms
min.insync.replicas
index.interval.bytes

### Replica Verification Tool

`$KAFKA_HOME/bin/kafka-replica-verification.sh`，该工具用来验证所指定的一个或多个 Topic 下每个 Partition 对应的所有 Replica 是否都同步。可通过`topic-white-list`这一参数指定所需要验证的所有 Topic，支持正则表达式。

## Preferred Replica Leader Election Tool

**_用途_**

有了 Replication 机制后，每个 Partition 可能有多个备份。某个 Partition 的 Replica 列表叫作 AR（Assigned Replicas），AR 中的第一个 Replica 即为“Preferred Replica”。创建一个新的 Topic 或者给已有 Topic 增加 Partition 时，Kafka 保证 Preferred Replica 被均匀分布到集群中的所有 Broker 上。理想情况下，Preferred Replica 会被选为 Leader。以上两点保证了所有 Partition 的 Leader 被均匀分布到了集群当中，这一点非常重要，因为所有的读写操作都由 Leader 完成，若 Leader 分布过于集中，会造成集群负载不均衡。但是，随着集群的运行，该平衡可能会因为 Broker 的宕机而被打破，该工具就是用来帮助恢复 Leader 分配的平衡。

事实上，每个 Topic 从失败中恢复过来后，它默认会被设置为 Follower 角色，除非某个 Partition 的 Replica 全部宕机，而当前 Broker 是该 Partition 的 AR 中第一个恢复回来的 Replica。因此，某个 Partition 的 Leader（Preferred Replica）宕机并恢复后，它很可能不再是该 Partition 的 Leader，但仍然是 Preferred Replica。

**_原理_**

1\. 在 ZooKeeper 上创建`/admin/preferred_replica_election`节点，并存入需要调整 Preferred Replica 的 Partition 信息。

2\. Controller 一直 Watch 该节点，一旦该节点被创建，Controller 会收到通知，并获取该内容。

3\. Controller 读取 Preferred Replica，如果发现该 Replica 当前并非是 Leader 并且它在该 Partition 的 ISR 中，Controller 向该 Replica 发送 LeaderAndIsrRequest，使该 Replica 成为 Leader。如果该 Replica 当前并非是 Leader，且不在 ISR 中，Controller 为了保证没有数据丢失，并不会将其设置为 Leader。

**_用法_**

$KAFKA_HOME/bin/kafka-preferred-replica-election.sh --zookeeper localhost:2181

在包含 8 个 Broker 的 Kafka 集群上，创建 1 个名为 topic1，replication-factor 为 3，Partition 数为 8 的 Topic，使用如下命令查看其 Partition/Replica 分布。

$KAFKA_HOME/bin/kafka-topics.sh --describe --topic topic1 --zookeeper localhost:2181

查询结果如下图所示，从图中可以看到，Kafka 将所有 Replica 均匀分布到了整个集群，并且 Leader 也均匀分布。

![](https://static001.infoq.cn/resource/image/20/ea/20d6fee834daf63bda0a70dca9dd57ea.png)

手动停止部分 Broker，topic1 的 Partition/Replica 分布如下图所示。从图中可以看到，由于 Broker 1/2/4 都被停止，Partition 0 的 Leader 由原来的 1 变为 3，Partition 1 的 Leader 由原来的 2 变为 5，Partition 2 的 Leader 由原来的 3 变为 6，Partition 3 的 Leader 由原来的 4 变为 7。

![](https://static001.infoq.cn/resource/image/1e/64/1ecade3d8c3c0922a6aee3ac0a7a6364.png)

再重新启动 ID 为 1 的 Broker，topic1 的 Partition/Replica 分布如下。可以看到，虽然 Broker 1 已经启动（Partition 0 和 Partition5 的 ISR 中有 1），但是 1 并不是任何一个 Parititon 的 Leader，而 Broker 5/6/7 都是 2 个 Partition 的 Leader，即 Leader 的分布不均衡——一个 Broker 最多是 2 个 Partition 的 Leader，而最少是 0 个 Partition 的 Leader。

![](https://static001.infoq.cn/resource/image/c6/2b/c6ab286ca7c9cc7f0c3fcc82dcf8ae2b.png)

运行该工具后，topic1 的 Partition/Replica 分布如下图所示。由图可见，除了 Partition 1 和 Partition 3 由于 Broker 2 和 Broker 4 还未启动，所以其 Leader 不是其 Preferred Repliac 外，其它所有 Partition 的 Leader 都是其 Preferred Replica。同时，与运行该工具前相比，Leader 的分配更均匀——一个 Broker 最多是 2 个 Parittion 的 Leader，最少是 1 个 Partition 的 Leader。

![](https://static001.infoq.cn/resource/image/d5/b7/d5f809261fd6a5a33b90d1f8bba17ab7.png)

启动 Broker 2 和 Broker 4，Leader 分布与上一步相比并未变化，如下图所示。

![](https://static001.infoq.cn/resource/image/06/76/0645b566b027759cd71820b488b66076.png)

再次运行该工具，所有 Partition 的 Leader 都由其 Preferred Replica 承担，Leader 分布更均匀——每个 Broker 承担 1 个 Partition 的 Leader 角色。

除了手动运行该工具使 Leader 分配均匀外，Kafka 还提供了自动平衡 Leader 分配的功能，该功能可通过将`auto.leader.rebalance.enable`设置为 true 开启，它将周期性检查 Leader 分配是否平衡，若不平衡度超过一定阈值则自动由 Controller 尝试将各 Partition 的 Leader 设置为其 Preferred Replica。检查周期由`leader.imbalance.check.interval.seconds`指定，不平衡度阈值由`leader.imbalance.per.broker.percentage`指定。

### Kafka Reassign Partitions Tool

**_用途_**

该工具的设计目标与 Preferred Replica Leader Election Tool 有些类似，都旨在促进 Kafka 集群的负载均衡。不同的是，Preferred Replica Leader Election 只能在 Partition 的 AR 范围内调整其 Leader，使 Leader 分布均匀，而该工具还可以调整 Partition 的 AR。

Follower 需要从 Leader Fetch 数据以保持与 Leader 同步，所以仅仅保持 Leader 分布的平衡对整个集群的负载均衡来说是不够的。另外，生产环境下，随着负载的增大，可能需要给 Kafka 集群扩容。向 Kafka 集群中增加 Broker 非常简单方便，但是对于已有的 Topic，并不会自动将其 Partition 迁移到新加入的 Broker 上，此时可用该工具达到此目的。某些场景下，实际负载可能远小于最初预期负载，此时可用该工具将分布在整个集群上的 Partition 重装分配到某些机器上，然后可以停止不需要的 Broker 从而实现节约资源的目的。

需要说明的是，该工具不仅可以调整 Partition 的 AR 位置，还可调整其 AR 数量，即改变该 Topic 的 replication factor。

**_原理_**

该工具只负责将所需信息存入 ZooKeeper 中相应节点，然后退出，不负责相关的具体操作，所有调整都由 Controller 完成。

1\. 在 ZooKeeper 上创建`/admin/reassign_partitions`节点，并存入目标 Partition 列表及其对应的目标 AR 列表。

2\. Controller 注册在`/admin/reassign_partitions`上的 Watch 被 fire，Controller 获取该列表。

3\. 对列表中的所有 Partition，Controller 会做如下操作：

*   启动`RAR - AR`中的 Replica，即新分配的 Replica。（RAR = Reassigned Replicas， AR = Assigned Replicas）
*   等待新的 Replica 与 Leader 同步
*   如果 Leader 不在 RAR 中，从 RAR 中选出新的 Leader
*   停止并删除`AR - RAR`中的 Replica，即不再需要的 Replica
*   删除`/admin/reassign_partitions`节点

**_用法_**

该工具有三种使用模式

*   generate 模式，给定需要重新分配的 Topic，自动生成 reassign plan（并不执行）
*   execute 模式，根据指定的 reassign plan 重新分配 Partition
*   verify 模式，验证重新分配 Partition 是否成功

下面这个例子将使用该工具将 Topic 的所有 Partition 重新分配到 Broker 4/5/6/7 上，步骤如下：

1\. 使用 generate 模式，生成 reassign plan

指定需要重新分配的 Topic （{"topics":[{"topic":"topic1"}],"version":1}），并存入`/tmp/topics-to-move.json`文件中，然后执行如下命令

$KAFKA_HOME/bin/kafka-reassign-partitions.sh --zookeeper localhost:2181
--topics-to-move-json-file /tmp/topics-to-move.json 
--broker-list "4,5,6,7" --generate

结果如下图所示

![](https://static001.infoq.cn/resource/image/10/b0/10bcf297d6d1afb32c4334d2485a0fb0.png)

2\. 使用 execute 模式，执行 reassign plan

将上一步生成的 reassignment plan 存入`/tmp/reassign-plan.json`文件中，并执行

$KAFKA_HOME/bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 
--reassignment-json-file /tmp/reassign-plan.json --execute

![](https://static001.infoq.cn/resource/image/86/79/8605d8749b0f66b642966f274f1c0b79.png)

此时，ZooKeeper 上`/admin/reassign_partitions`节点被创建，且其值与`/tmp/reassign-plan.json`文件的内容一致。

![](https://static001.infoq.cn/resource/image/4c/e5/4c9677c9fd1f32035f320d4bdb3bbbe5.png)

3\. 使用 verify 模式，验证 reassign 是否完成

执行 verify 命令

$KAFKA_HOME/bin/kafka-reassign-partitions.sh --zookeeper localhost:2181 
--reassignment-json-file /tmp/reassign-plan.json --verify

结果如下所示，从图中可看出 topic1 的所有 Partititon 都根据 reassign plan 重新分配成功。

![](https://static001.infoq.cn/resource/image/7b/49/7b0300124b3207e79c1b101e0e73f949.png)

接下来用 Topic Tool 再次验证。

bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic topic1

结果如下图所示，从图中可看出 topic1 的所有 Partition 都被重新分配到 Broker 4/5/6/7，且每个 Partition 的 AR 与 reassign plan 一致。

![](https://static001.infoq.cn/resource/image/34/0f/34a1fa0d93054c3941b49822828ec30f.png)

需要说明的是，在使用 execute 之前，并不一定要使用 generate 模式自动生成 reassign plan，使用 generate 模式只是为了方便。事实上，某些场景下，generate 模式生成的 reassign plan 并不一定能满足需求，此时用户可以自己设置 reassign plan。

#### State Change Log Merge Tool

**_用途_**

该工具旨在从整个集群的 Broker 上收集状态改变日志，并生成一个集中的格式化的日志以帮助诊断状态改变相关的故障。每个 Broker 都会将其收到的状态改变相关的的指令存于名为`state-change.log`的日志文件中。某些情况下，Partition 的 Leader election 可能会出现问题，此时我们需要对整个集群的状态改变有个全局的了解从而诊断故障并解决问题。该工具将集群中相关的`state-change.log`日志按时间顺序合并，同时支持用户输入时间范围和目标 Topic 及 Partition 作为过滤条件，最终将格式化的结果输出。

**_用法_**

bin/kafka-run-class.sh kafka.tools.StateChangeLogMerger 
--logs /opt/kafka_2.11-0.8.2.1/logs/state-change.log 
--topic topic1 --partitions 0,1,2,3,4,5,6,7

