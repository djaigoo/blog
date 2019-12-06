---
title: kafka
tags:
  - draft
categories:
  - draft
draft: true
date: 2018-09-06 16:57:59
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/kafka.png
---
# kafka介绍
kafka是一个分布式流媒体平台，具有三个关键功能：
* 发布和订阅记录流，类似于消息队列或企业消息传递系统
* 以容错的持久方式存储记录流
* 记录发生时处理流

kafka通常用于两大类应用：
* 构建可在系统或应用程序之间可靠获取数据的实时流数据管道
* 构建转换或响应数据流的实时流应用程序
<!--more-->
kafka概念
* kafka作为一个集群运行在一个或多个可跨多个数据中心的服务器上
* kafka集群以称为主体的类别存储记录流
* 每条记录都包含一个键，一个值，一个时间戳

kafka核心API
* Producer API：允许应用向一个或多个kafka topic发布记录流
* Consumer API：允许应用订阅一个或多个topic，并且处理生成给他们的记录流
* Streams API：允许应用充当流处理器，从一个或多个topic消费输入流，向一个或多个topic产生输出流，有效的将输入流装换为输出流
* Connector API：允许建立和运行可重复利用的producer或consumer，将kafka topic连接到现有应用程序或数据系统。例如，关系数据库的连接器可能会捕获表的每个更改

在kafka中，客户端和服务器之间的通信通过简单，高性能，语言无关的TCP协议完成。并保证向后兼容。

## topics and logs
topic是发布记录的类别或订阅源名称，kafka的主体是多用户，也就是说，一个主体可以有零个，一个，或多个消费者订阅写入它的数据。
对于每个topic，kafka集群都要维护一个分区日志。每个分区都是有序的，不可变的记录序列，不断附加到结构化的提交日志中。分区中的记录每个都分配了一个称为偏移的顺序ID号，它唯一地标识分区中的每个记录。
Kafka集群持久保存所有已发布的记录，无论是否已使用，使用可配置的保留期。例如，保留策略为两天，则发布记录后的两天内，都是可以被使用的，两天后将会被丢弃。Kafka的性能在数据大小方面实际上是恒定的，因此长时间存储数据不是问题。
实际上，基于每个消费者保留的唯一元数据是该消费者在日志中的偏移或者位置。这种偏移由消费者控制，通常消费者在读取记录时会线性的提高偏移量，但事实上，由于该位置由消费者控制，因此它可以按照自己所设定的任何顺序消费记录。例如，消费者可以重置为较旧的偏移量来重新处理过去的数据，或者跳到最近的记录并从“该点”开始消费。
日志中的分区有多种用途，它允许日志扩展到超出适合单个服务器的大小，每个单独的分区必须适合托管他的服务器，但topic可能有许多分区，因此，它可以处理任意数量的数据。分区还能充当并行性单位。

## Distribution
日志的分区分布在Kafka集群中的服务器上，每个服务器处理数据并请求分区的共享。每个分区都在可配置数量的服务器上进行复制，以实现容错。
每个分区都有一个服务器充当领导者，零个或多个服务器充当追随者。领导者处理分区的所有读取和写入请求，而追随者被动地复制领导者。如果领导者宕机，其中一名追随者成为新的领导者。每个服务器都充当其某些分区的领导者或其他服务器的追随者，因此负载在群集中得到很好的平衡。

## Geo-Replication
kafka mirrorMaker为集群提供了地理复制支持，可以跨多个数据中心或云服务器地区复制消息。可以在主动/被动方案中使用它进行备份和恢复;或者在主动/主动方案中，将数据放置在离用户较近的位置，或支持数据位置要求。

## Producers
生产者将数据发布到他们选择的topic上，生产者负责选择分配给主题中哪个分区的记录。这可以以循环方式完成，仅仅是为了平衡负载，或者可以根据一些语义分区功能（例如基于记录中的某些键）来完成。更多是关于一秒钟内使用分区的信息。

## Consumers
消费者使用消费者组名标记自己，并且发布到topic的每个记录被传递到每个订阅消费者组中的一个消费者实例。消费者实例可以在单独的进程中，也可以在不同的机器上。
如果所有消费者实例拥有相同的消费组，那么记录将有效的在消费者实例上进行负载均衡。如果所有消费者实例具有不同的消费者组，则每个记录将广播到所有消费者进程。
常见的情况，topic具有少量的消费者群体，每个一个逻辑订阅者。每个组由许多用于可伸缩性和容错的消费者实例组成，这只不过是发布、订阅语义，其中订阅者是消费者群集而不是单个进程。
在Kafka中实现消费的方式是通过在消费者实例上划分日志中的分区，以便每个实例在任何时间点都是分配的“公平份额”的独占消费者。维护组中成员资格的过程由Kafka协议动态处理。如果新实例加入该组，他们将从该组的其他成员接管一些分区;如果实例死亡，其分区将分发给其余实例。
Kafka仅提供分区内记录的所有命令，而不是topic中不同分区之间的记录。对于大多数应用程序而言，按分区排序与按键分区数据的能力相结合就足够了。但是，如果您需要获取记录进行所有命令，则可以使用仅包含一个分区的topic来实现，但这意味着每个消费者组只有一个消费者进程。

## Multi-tenancy
可以将kafka部署为多租户解决方案，通过配置哪些主题可以生成或使用数据来启用多租户，支持运营配额。管理员可以定义和强制执行配额，以控制客户端使用的代理资源。

## Guarantees
高级kafka提供一下保证:
* 生产者发送到特定主题分区的消息将按其发送顺序附加。也就是说，如果记录M1由与记录M2相同的生产者发送，并且首先发送M1，则M1将具有比M2更低的偏移并且在日志中更早出现。
* 消费者实例按照它们存储在日志中的顺序查看记录。
* 对于具有复制因子N的主题，我们将容忍最多N-1个服务器故障，而不会丢失任何提交到日志的记录。

## Messaging System
传统消息有两种模式，队列和发布-订阅。在队列中，消费者池可以从服务器读取并且每个记录转到其中一个;在发布-订阅中，记录被广播给所有消费者。排队的优势在于它允许您在多个消费者实例上划分数据处理，从而可以扩展您的处理。不幸的是，一旦一个进程读取它已经消失的数据，队列就不是​​多用户。发布-订阅允许您将数据广播到多个进程，但由于每条消息都发送给每个订阅者，因此无法进行扩展处理。
kafka消费者集群概念概括了这两个概念：与队列一样，消费者组允许将处理划分为一组进程（消费者组成员）；与发布-订阅一样，kafka允许向多个消费者组广播消息。
Kafka模型的优势在于每个主题都具有这些属性，它可以扩展处理并且也是多用户，不需要选择其中一个。
传统队列在服务器上按顺序保留记录，如果多个消费者从队列中消耗，则服务器按照存储顺序分发记录。但是，虽然服务器按顺序分发记录，但是记录是异步传递给消费者的，因此它们可能会在不同的消费者处出现故障。这实际上意味着在存在并行消耗的情况下丢失记录的顺序。消息传递系统通常通过具有“独占消费者”概念来解决这个问题，该概念只允许一个进程从队列中消耗，但当然这意味着处理中没有并行性。
kafka通过在topic中具有分区这一并行概念，所以能够在消费者流程池中提供命令保证和负载均衡。这是通过将topic中的分区分配给消费者组来实现的，以便每个分区仅由该组中的一个消费者使用。通过这样做，我们确保使用者是该分区的唯一读者并按顺序使用数据。由于有许多分区，这仍然可以平衡许多消费者实例的负载。但请注意，消费者组中的消费者实例不能超过分区。

## Storage System
任何允许发布与消费消息分离的消息的消息队列实际上充当了正在进行的消息的存储系统。写入Kafka的数据将写入磁盘并进行复制以实现容错。Kafka允许生产者等待确认，以便在完全复制之前写入不被认为是完整的，并且即使写入的服务器失败也保证写入仍然存在。磁盘结构Kafka很好地使用了规模，无论服务器上有50 KB还是50 TB的持久数据，Kafka都会执行相同的操作。由于认真对待存储并允许客户端控制其读取位置，您可以将Kafka视为一种专用于高性能，低延迟提交日志存储，复制和传播的专用分布式文件系统。

## Stream Processing
仅仅读取，写入和存储数据流是不够的，目的是实现流的实时处理。在Kafka中，流处理器是指从输入主题获取连续数据流，对此输入执行某些处理以及生成连续数据流以输出主题的任何内容。
可以使用生产者和消费者API直接进行简单处理。但是，对于更复杂的转换，Kafka提供了完全集成的Streams API。这允许构建执行非平凡处理的应用程序，这些应用程序可以计算流的聚合或将流连接在一起。此工具有助于解决此类应用程序面临的难题：处理无序数据，在代码更改时重新处理输入，执行有状态计算等。
Stream API构建在Kafka提供的核心原语上：它使用生产者和消费者API进行输入，使用Kafka进行有状态存储，并在流处理器实例之间使用相同的组机制来实现容错。

## Pieces Together
消息传递，存储和流处理的这种组合可能看起来很不寻常，但它对于Kafka作为流媒体平台的作用至关重要。像HDFS这样的分布式文件系统允许存储静态文件以进行批处理。这样的系统允许有效地存储和处理过去的历史数据。传统的企业消息系统允许处理您订阅后到达的未来消息。以这种方式构建的应用程序在到达时处理未来消息。Kafka结合了这两种功能，这种组合对于Kafka作为流媒体应用程序平台以及流数据管道的使用至关重要。
kafka通过结合存储和低延迟订阅，流应用程序可以以相同的方式处理过去和未来的数据。也就是说，单个应用程序可以处理历史存储的数据，而不是在它到达最后一条记录时结束，它可以在未来数据到达时继续处理。这是包含批处理以及消息驱动应用程序的流处理的一般概念。
同样，对于流数据管道传输，订阅实时事件的组合使得可以将Kafka用于极低延迟的管道;但是，能够可靠地存储数据使得可以将其用于必须保证数据传输的关键数据，或者与仅定期加载数据或可能长时间停机以进行维护的离线系统集成。流处理设施可以在数据到达时对其进行转换。

# 快速开始
## Download the code
下载源码[**Kafka_1.12-2.0.0**](http://mirrors.hust.edu.cn/apache/kafka/2.0.0/kafka_2.12-2.0.0.tgz)
```shell
$ tar -xzf kafka_2.12-2.0.0.tgz
$ cd kafka_2.12-2.0.0
```
## Start the server
kafka使用了ZooKeeper，所以首先需要启动ZooKeeper服务，ZooKeeper则需要java的支持
通过下载rpm安装java
可以[下载java](http://www.oracle.com/technetwork/java/javase/downloads/index.html)最适合的版本
```shell
$ rpm -ivh java.rpm
```

通过脚本快速启动ZooKeeper server
```shell
$ bin/zookeeper-server-start.sh config/zookeeper.properties
```

通过脚本快速启动Kafka server
```shell
$ bin/kafka-server-start.sh config/server.properties
```

## Create a topic
创建topic，下面代码是创建只有一个分区，一个副本，名字为“test”的topic
```shell
$ bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```
我们可以通过list topic命令像是我们运行的topic
```shell
$ bin/kafka-topics.sh --list --zookeeper localhost:2181
test
```
或者，也可以将代理配置为在发布不存在的主题时自动创建主题，而不是手动创建主题。


## Send some messages
Kafka附带一个命令行客户端，它将从文件或标准输入中获取输入，并将其作为消息发送到Kafka集群。默认情况下，每行将作为单独的消息发送。
运行生产者，然后在控制台中键入一些消息以发送到服务器。
```shell
$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
```

## Start a consumer
Kafka还有一个命令行消费者，它会将消息转储到标准输出。
```shell
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```
如果在不同的终端中运行上述每个命令，那么现在应该能够在生产者终端中键入消息并看到它们出现在消费者终端中。所有命令行工具都有其他选项;运行不带参数的命令将显示更详细地记录它们的使用信息。
## Setting up a multi-broker cluster
到目前为止，我们一直在与一个经纪人竞争，但这并不好玩。对于Kafka，单个代理只是一个大小为1的集群，因此除了启动更多代理实例之外没有太多变化。但是为了感受它，让我们将我们的集群扩展到三个节点（仍然在我们的本地机器上）。
首先为每一个代理创建一个配置文件。
```
config/server-1.properties:
    broker.id=1
    listeners=PLAINTEXT://:9093
    log.dirs=/tmp/kafka-logs-1
```
```
config/server-2.properties:
    broker.id=2
    listeners=PLAINTEXT://:9094
    log.dirs=/tmp/kafka-logs-2
```
broker.id属性是群集中每个节点的唯一且永久的名称。我们必须覆盖端口和日志目录，因为我们在同一台机器上运行这些，并且我们希望让所有代理尝试在同一端口上注册或覆盖彼此的数据。
启动这两个新的节点
```shell
$ bin/kafka-server-start.sh config/server-1.properties &
...
$ bin/kafka-server-start.sh config/server-2.properties &
...
```
现在创建一个复制因子为3的新topic
```shell
$ bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 3 --partitions 1 --topic my-replicated-topic
```
这样就能创建一个集群，可以使用describe topics查看集群在做什么
```shell
$ bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic
Topic:my-replicated-topic   PartitionCount:1    ReplicationFactor:3 Configs:
    Topic: my-replicated-topic  Partition: 0    Leader: 1   Replicas: 1,2,0 Isr: 1,2,0
```
输出解释：第一行给出了所有分区的摘要，每个附加行提供有关一个分区的信息。由于我们只有一个分区用于此topic，因此只有一行。
* “leader”是负责给定分区的所有读取和写入的节点。每个节点将成为随机选择的分区部分的领导者。
* “replicas”是复制此分区日志的节点列表，无论它们是否为领导者，或者即使它们当前处于活动状态。
* “isr”是“同步”复制品的集合。这是副本列表的子集，该列表当前处于活跃状态并且已经被领导者捕获。

我们可以在我们创建的原始topic上运行相同的命令，以查看它的位置：
```shell
$ bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test
Topic:test  PartitionCount:1    ReplicationFactor:1 Configs:
    Topic: test Partition: 0    Leader: 0   Replicas: 0 Isr: 0
```
可以看到，原始topic没有副本，位于服务器0上，他是集群中的唯一的服务器。
可以向新topic发布消息
```shell
$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-replicated-topic
```
消费信息
```shell
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
```

检验容错率
杀掉节点1，即原来leader，再查看集群状态，leader已经切换到了节点2，并且节点1不再位于同步副本集中
```shell
$ bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic my-replicated-topic
Topic:my-replicated-topic   PartitionCount:1    ReplicationFactor:3 Configs:
    Topic: my-replicated-topic  Partition: 0    Leader: 2   Replicas: 1,2,0 Isr: 2,0
```
但是即使最初接收写入的领导者挂掉，但是这些消息仍可供消费
```shell
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
```


## Use Kafka Connect to import/export data
将数据从控制台输入，再到控制台输出，这是一个比较方便的点。但是还有很多情况是将其他来源的数据或将数据从kafka导出到其他系统。对于许多系统，您可以使用Kafka Connect导入或导出数据，而不是编写自定义集成代码。
Kafka Connect是Kafka附带的工具，用于向Kafka导入和导出数据。它是一个可扩展的工具，运行连接器，实现与外部系统交互的自定义​​逻辑。使用简单的连接器运行Kafka Connect，这些连接器将数据从文件导入Kafka主题并将数据从Kafka主题导出到文件。

创建测试数据，将消息写入test.txt中
```shell
$ echo -e "foo\nbar" > test.txt
```
启动两个独立模式运行的连接器，这意味着我们在单个本地专用进程中运行。我们提供三个配置文件作为参数。
kafka connect 流程的配置，包含常见配置，例如要连接的kafka代理和数据的序列化格式，其余配置文件均指定要创建的连接器。这些文件包括唯一的连接器名称，要实例化的连接器类以及连接器所需的任何其他配置。
```shell
$ bin/connect-standalone.sh config/connect-standalone.properties config/connect-file-source.properties config/connect-file-sink.properties
```
Kafka附带的这些示例配置文件使用您之前启动的默认本地群集配置并创建两个连接器：第一个是源连接器，它从输入文件读取行并生成每个Kafka主题，第二个是宿连接器从Kafka主题读取消息并将每个消息生成为输出文件中的一行。
在启动过程中，您将看到许多日志消息，包括一些指示正在实例化连接器的日志消息。一旦Kafka Connect进程启动，源连接器应该开始从test.txt读取行并将它们生成主题connect-test，并且接收器连接器应该开始从主题connect-test读取消息并将它们写入文件测试.sink.txt。我们可以检测输出文件，验证数据是否已通过整个管道是否畅通。
```shell
$ more test.sink.txt
foo
bar
```
请注意，数据存储在Kafka主题connect-test中，因此我们还可以运行控制台使用者来查看主题中的数据（或使用自定义使用者代码来处理它）：
```shell
$ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
{"schema":{"type":"string","optional":false},"payload":"foo"}
{"schema":{"type":"string","optional":false},"payload":"bar"}
```
连接器继续处理数据，因此我们可以将数据添加到文件中并看到它在管道中移动：
```shell
$ echo Another line>> test.txt
```
您应该看到该行出现在控制台使用者输出和接收器文件中。
## Use Kafka Streams to process data
Kafka Streams是一个客户端库，用于构建任务关键型实时应用程序和微服务，其中输入和/或输出数据存储在Kafka集群中。Kafka Streams结合了在客户端编写和部署标准Java和Scala应用程序的简单性以及Kafka服务器端集群技术的优势，使这些应用程序具有高度可扩展性，弹性，容错性，分布式等等。





