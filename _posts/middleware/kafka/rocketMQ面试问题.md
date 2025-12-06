---
author: djaigo
title: rocketMQ面试问题
categories:
  - middleware
date: 2025-05-13 14:15:51
tags:
  - rocketMQ
---

# 底层刷盘机制
RocketMQ 是一个开源的分布式消息中间件，其底层刷盘机制对消息的可靠性和性能起着关键作用。RocketMQ 提供了两种刷盘策略：同步刷盘和异步刷盘，下面详细介绍这两种机制。

### 同步刷盘

同步刷盘指在消息写入内存后，必须将消息持久化到磁盘才会返回成功响应给生产者。这种策略保证了消息的可靠性，即使 Broker 发生故障，消息也不会丢失。

#### 实现原理

1.  生产者发送消息到 Broker 后，Broker 先将消息写入内存中的 `CommitLog` 缓存。
2.  调用 `MappedFile` 的 `flush` 方法，将内存中的数据强制刷写到磁盘。
3.  等待磁盘写入完成并返回成功结果后，Broker 才会给生产者返回消息发送成功的响应。

#### 配置方式

在 `broker.conf` 配置文件中设置 `flushDiskType = SYNC_FLUSH`。

#### 代码示例（简化版）

```java
// 消息写入内存
boolean result = commitLog.putMessage(msg);
if (result) {
    // 同步刷盘
    boolean flushOK = commitLog.getDispatcherList().get(0).flush(msg);
    if (flushOK) {
        // 返回成功响应给生产者
        return new Response(SUCCESS);
    }
}
return new Response(FAIL);

```

#### 优缺点

*   **优点**：消息可靠性高，几乎不会丢失消息。
*   **缺点**：性能相对较低，因为每次消息写入都需要等待磁盘操作完成，会增加消息发送的延迟。

### 异步刷盘

异步刷盘是指消息写入内存后，立即返回成功响应给生产者，由后台线程定期将内存中的数据刷写到磁盘。这种策略能提高消息的处理性能，但在 Broker 发生故障时，可能会丢失一部分未刷盘的消息。

#### 实现原理

1.  生产者发送消息到 Broker 后，Broker 先将消息写入内存中的 `CommitLog` 缓存。
2.  立即返回消息发送成功的响应给生产者。
3.  后台有一个 `FlushRealTimeService` 线程，按照一定的时间间隔（默认 500ms）将内存中的数据刷写到磁盘。

#### 配置方式

在 `broker.conf` 配置文件中设置 `flushDiskType = ASYNC_FLUSH`。

#### 代码示例（简化版）
```java
// 消息写入内存
boolean result = commitLog.putMessage(msg);
if (result) {
    // 立即返回成功响应给生产者
    return new Response(SUCCESS);
}
// 后台线程定期刷盘
class FlushRealTimeService extends ServiceThread {
    @Override
    public void run() {
        while (!this.isStopped()) {
            // 每隔 500ms 刷盘一次
            commitLog.flush();
            Thread.sleep(500); 
        }
    }
}

```

#### 优缺点

*   **优点**：性能高，消息发送延迟低，能处理更高的并发量。
*   **缺点**：消息可靠性相对较低，在 Broker 异常宕机时，可能会丢失最后一部分未刷盘的消息。

### 总结

*   **同步刷盘**：适用于对消息可靠性要求极高的场景，如金融交易等。
*   **异步刷盘**：适用于对性能要求较高，能容忍少量消息丢失的场景，如日志收集等。

# 集群分片机制
RocketMQ 集群分片机制主要涉及消息的存储和消费，核心包含 Broker 集群分片、Topic 分片和消费队列分片，下面详细介绍这些机制。

### Broker 集群分片

Broker 是 RocketMQ 中处理消息存储和转发的核心组件，通过集群部署提升系统可用性和扩展性。常见的 Broker 集群部署架构有以下几种：

#### 单 Master 模式

整个集群只有一个 Master Broker，所有消息的生产和消费都依赖这一个节点。该模式简单但存在单点故障问题，一旦 Master 宕机，服务就会不可用，仅适用于测试环境。

#### 多 Master 模式

集群中有多个 Master Broker，每个 Master 独立工作，消息可以分散存储在不同的 Master 上。这种模式提高了系统的可用性和吞吐量，但每个 Master 节点的数据是独立的，没有数据冗余。

#### 多 Master 多 Slave 模式

集群中包含多个 Master 和多个 Slave，每个 Master 可以有一个或多个 Slave 节点。Slave 节点会从对应的 Master 节点同步数据，实现数据冗余。根据同步策略不同，又分为同步双写和异步复制：

*   **同步双写**：消息写入 Master 后，必须同步到至少一个 Slave 才返回成功，保证消息可靠性，但会增加写入延迟。
*   **异步复制**：消息写入 Master 后立即返回成功，Slave 异步从 Master 拉取数据，写入性能高，但在 Master 宕机时可能丢失部分未同步的消息。

### Topic 分片

Topic 是 RocketMQ 中消息的逻辑分类，为了提高消息处理能力，一个 Topic 会被划分为多个分片，即多个队列（Message Queue）。

#### 队列划分

一个 Topic 可以包含多个 Message Queue，这些队列分布在不同的 Broker 节点上。例如，一个 Topic 有 4 个 Message Queue，可能分布在 2 个 Broker 节点上，每个 Broker 节点有 2 个队列。

#### 消息路由

生产者发送消息时，会根据一定的策略（如轮询、Hash 等）将消息发送到不同的 Message Queue 中。例如，使用轮询策略时，生产者会依次将消息发送到每个 Message Queue 中。

#### 代码示例


```java
// 创建生产者
DefaultMQProducer producer = new DefaultMQProducer("producer_group");
producer.start();

// 创建消息
Message msg = new Message("TestTopic", "Hello RocketMQ".getBytes(RemotingHelper.DEFAULT_CHARSET));

// 发送消息，使用轮询策略选择 Message Queue
SendResult sendResult = producer.send(msg);
System.out.printf("%s%n", sendResult);

producer.shutdown();

```

### 消费队列分片

消费队列用于管理消费者对消息的消费进度，每个 Message Queue 对应一个或多个消费队列。

#### 消费者分组

多个消费者可以组成一个消费者组，共同消费一个 Topic 的消息。消费者组中的每个消费者会分配到部分 Message Queue 进行消费，实现负载均衡。

#### 消息消费

消费者通过拉取或推送的方式从分配到的 Message Queue 中获取消息进行消费。RocketMQ 会根据消费者数量和 Message Queue 数量动态调整分配策略，确保消息被高效消费。

#### 代码示例


```java
// 创建消费者
DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("consumer_group");
consumer.subscribe("TestTopic", "*");

// 注册消息监听器
consumer.registerMessageListener(new MessageListenerConcurrently() {
    @Override
    public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
        for (MessageExt msg : msgs) {
            System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), new String(msg.getBody()));
        }
        return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
    }
});

// 启动消费者
consumer.start();

```

### 总结

RocketMQ 的集群分片机制通过 Broker 集群部署、Topic 分片和消费队列分片，实现了消息的分布式存储和消费，提高了系统的可用性、扩展性和消息处理能力。

# 推拉模式

RocketMQ 消费者有推模式（Push）和拉模式（Pull）两种，它们各有特点，选择哪种模式取决于具体的业务场景，下面为你详细介绍两种模式并给出选择建议。

### 推模式（Push）

#### 原理

推模式本质上是基于拉模式实现的，由 Broker 主动向消费者推送消息。消费者启动后会向 Broker 注册，Broker 会根据消费者的负载情况，将消息推送给消费者。RocketMQ 中的 `DefaultMQPushConsumer` 类实现了推模式。

#### 优点

*   **使用简单**：消费者只需关注消息处理逻辑，无需关心消息的拉取和负载均衡等细节，降低了开发复杂度。
*   **实时性高**：Broker 主动推送消息，能及时将新消息传递给消费者，适合对消息实时性要求较高的场景。

#### 缺点

*   **流量控制困难**：Broker 难以精准控制消息推送速度，可能导致消费者处理不过来，出现消息堆积或消费者崩溃的情况。
*   **资源占用不稳定**：若消息推送量突然增大，消费者可能因资源耗尽而影响性能。

#### 代码示例


```java
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.common.message.MessageExt;
import java.util.List;

public class PushConsumerExample {
    public static void main(String[] args) throws Exception {
        // 创建推模式消费者实例
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("consumer_group");
        // 设置 NameServer 地址
        consumer.setNamesrvAddr("localhost:9876");
        // 订阅主题
        consumer.subscribe("TestTopic", "*");

        // 注册消息监听器
        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
                for (MessageExt msg : msgs) {
                    System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), new String(msg.getBody()));
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        // 启动消费者
        consumer.start();
        System.out.printf("Consumer Started.%n");
    }
}

```

### 拉模式（Pull）

#### 原理

拉模式下，消费者主动从 Broker 拉取消息。消费者需要自己管理消息拉取的时机、频率和偏移量等，RocketMQ 中的 `DefaultMQPullConsumer` 类实现了拉模式。

#### 优点

*   **灵活控制**：消费者可以根据自身的处理能力和业务需求，灵活控制消息拉取的频率和数量，避免消息堆积。
*   **资源利用率高**：消费者可以根据自身资源情况调整拉取策略，提高资源利用率。

#### 缺点

*   **开发复杂度高**：需要手动管理消息拉取、偏移量更新和负载均衡等，开发难度较大。
*   **实时性较差**：若消费者拉取间隔设置不合理，可能导致消息处理延迟。

#### 代码示例


```java
import org.apache.rocketmq.client.consumer.DefaultMQPullConsumer;
import org.apache.rocketmq.client.consumer.PullResult;
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.common.message.MessageQueue;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class PullConsumerExample {
    private static final Map<MessageQueue, Long> OFFSE_TABLE = new HashMap<>();

    public static void main(String[] args) throws MQClientException {
        // 创建拉模式消费者实例
        DefaultMQPullConsumer consumer = new DefaultMQPullConsumer("consumer_group");
        // 设置 NameServer 地址
        consumer.setNamesrvAddr("localhost:9876");
        // 启动消费者
        consumer.start();

        // 获取主题的所有消息队列
        Set<MessageQueue> mqs = consumer.fetchSubscribeMessageQueues("TestTopic");
        for (MessageQueue mq : mqs) {
            System.out.printf("Consume from the queue: %s%n", mq);
            SINGLE_MQ:
            while (true) {
                try {
                    // 拉取消息
                    PullResult pullResult = consumer.pullBlockIfNotFound(mq, null, getMessageQueueOffset(mq), 32);
                    System.out.printf("%s%n", pullResult);
                    putMessageQueueOffset(mq, pullResult.getNextBeginOffset());
                    switch (pullResult.getPullStatus()) {
                        case FOUND:
                            // 处理消息
                            for (MessageExt msg : pullResult.getMsgFoundList()) {
                                System.out.printf("%s%n", new String(msg.getBody()));
                            }
                            break;
                        case NO_MATCHED_MSG:
                            break;
                        case NO_NEW_MSG:
                            break SINGLE_MQ;
                        case OFFSET_ILLEGAL:
                            break;
                        default:
                            break;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        // 关闭消费者
        consumer.shutdown();
    }

    private static long getMessageQueueOffset(MessageQueue mq) {
        Long offset = OFFSE_TABLE.get(mq);
        if (offset != null) {
            return offset;
        }
        return 0;
    }

    private static void putMessageQueueOffset(MessageQueue mq, long offset) {
        OFFSE_TABLE.put(mq, offset);
    }
}

```

### 选择建议

*   **选择推模式的场景**：
    *   业务对消息实时性要求高，需要尽快处理新消息，如实时监控、即时通讯等场景。
    *   开发人员希望简化代码逻辑，减少消息拉取和管理的复杂度。
*   **选择拉模式的场景**：
    *   消费者处理能力波动较大，需要根据自身资源动态调整消息拉取频率，如批量数据处理场景。
    *   业务对消息处理顺序和流程有严格控制需求，需要手动管理消息偏移量。


# 消息丢失
RocketMQ 中消息丢失可能发生在生产者、Broker 以及消费者这三个环节，下面分别介绍不同环节消息丢失的原因及对应的解决办法。

### 生产者端

#### 丢失原因

生产者发送消息时，由于网络抖动、Broker 服务异常等原因，可能导致消息发送失败，若未进行重试或错误处理，消息就会丢失。

#### 解决方案

*   **同步发送与重试机制**：使用同步发送消息的方式，确保消息发送成功。若发送失败，设置重试机制重新发送消息。


```java
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

public class ProducerExample {
    public static void main(String[] args) throws MQClientException, InterruptedException {
        DefaultMQProducer producer = new DefaultMQProducer("ProducerGroup");
        producer.setNamesrvAddr("localhost:9876");
        // 设置发送失败时的重试次数
        producer.setRetryTimesWhenSendFailed(3); 
        producer.start();

        try {
            Message msg = new Message("TestTopic", "TagA", "Hello RocketMQ".getBytes());
            // 同步发送消息
            SendResult sendResult = producer.send(msg); 
            System.out.printf("Send result: %s%n", sendResult);
        } catch (Exception e) {
            e.printStackTrace();
        }
        producer.shutdown();
    }
}

```

*   **异步发送与回调处理**：异步发送消息时，通过回调函数确认消息发送结果，对失败的情况进行相应处理。


```java
import org.apache.rocketmq.client.exception.MQClientException;
import org.apache.rocketmq.client.producer.DefaultMQProducer;
import org.apache.rocketmq.client.producer.SendCallback;
import org.apache.rocketmq.client.producer.SendResult;
import org.apache.rocketmq.common.message.Message;

public class AsyncProducerExample {
    public static void main(String[] args) throws MQClientException, InterruptedException {
        DefaultMQProducer producer = new DefaultMQProducer("AsyncProducerGroup");
        producer.setNamesrvAddr("localhost:9876");
        producer.start();

        Message msg = new Message("TestTopic", "TagA", "Hello RocketMQ Async".getBytes());
        // 异步发送消息
        producer.send(msg, new SendCallback() {
            @Override
            public void onSuccess(SendResult sendResult) {
                System.out.printf("Send async message success. Result: %s%n", sendResult);
            }

            @Override
            public void onException(Throwable e) {
                System.out.printf("Send async message failed. Error: %s%n", e);
                // 可在此处添加重试逻辑
            }
        });

        Thread.sleep(5000);
        producer.shutdown();
    }
}

```

### Broker 端

#### 丢失原因

Broker 未将消息正确持久化到磁盘，如刷盘失败、机器突然宕机等，会导致内存中的消息丢失。

#### 解决方案

*   **同步刷盘**：在 `broker.conf` 配置文件中设置 `flushDiskType = SYNC_FLUSH`，确保消息写入磁盘后，Broker 才返回成功响应给生产者。


```plaintext
flushDiskType = SYNC_FLUSH

```

*   **同步复制**：采用多 Master 多 Slave 架构中的同步双写模式，消息写入 Master 后，必须同步到至少一个 Slave 才返回成功。在 `broker.conf` 中设置如下参数：


```plaintext
brokerRole = SYNC_MASTER
flushDiskType = SYNC_FLUSH

```

### 消费者端

#### 丢失原因

消费者在处理消息过程中发生异常，或者在消息还未处理完成时就提交了消费进度，导致消息没有被正确消费，后续也不会重新消费该消息。

#### 解决方案

*   **正确提交消费进度**：确保在消息消费成功后再提交消费进度，若消费失败则稍后重试。


```java
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.common.message.MessageExt;

import java.util.List;

public class ConsumerExample {
    public static void main(String[] args) throws Exception {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("ConsumerGroup");
        consumer.setNamesrvAddr("localhost:9876");
        consumer.subscribe("TestTopic", "*");

        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
                for (MessageExt msg : msgs) {
                    try {
                        // 处理消息
                        System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), new String(msg.getBody()));
                    } catch (Exception e) {
                        // 消费失败，稍后重试
                        return ConsumeConcurrentlyStatus.RECONSUME_LATER; 
                    }
                }
                // 消费成功，提交消费进度
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS; 
            }
        });

        consumer.start();
    }
}

```

通过以上针对不同环节的处理措施，可以有效避免 RocketMQ 中消息丢失的问题。

# 重复消费
在 RocketMQ 里，因网络波动、消费者处理超时、Broker 重发消息等情况，容易出现消息重复消费问题。下面从不同方面介绍处理重复消费的方法。

### 业务端去重

#### 唯一 ID 法

生产者发送消息时，为每条消息生成唯一 ID，消费者消费消息前，先检查该 ID 是否已处理，若处理过则跳过。


```java
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.common.message.MessageExt;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class UniqueIdConsumerExample {
    // 使用 HashSet 存储已处理的消息 ID
    private static final Set<String> processedMessageIds = new HashSet<>();

    public static void main(String[] args) throws Exception {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("ConsumerGroup");
        consumer.setNamesrvAddr("localhost:9876");
        consumer.subscribe("TestTopic", "*");

        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
                for (MessageExt msg : msgs) {
                    String msgId = msg.getMsgId();
                    if (processedMessageIds.contains(msgId)) {
                        continue; // 消息已处理，跳过
                    }
                    try {
                        // 处理消息
                        System.out.printf("%s Receive New Messages: %s %n", Thread.currentThread().getName(), new String(msg.getBody()));
                        processedMessageIds.add(msgId); // 记录已处理的消息 ID
                    } catch (Exception e) {
                        return ConsumeConcurrentlyStatus.RECONSUME_LATER;
                    }
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        consumer.start();
    }
}

```

**注意**：使用 `HashSet` 仅适用于单机环境，分布式环境下可使用 Redis 等分布式缓存存储消息 ID。

#### 数据库唯一约束

在数据库表中设置唯一约束，当重复消息插入时，因违反唯一约束而失败，避免重复处理。


```sql
-- 创建带有唯一约束的表
CREATE TABLE order_table (
    order_id VARCHAR(32) PRIMARY KEY,  -- 订单 ID 设为唯一主键
    amount DECIMAL(10, 2),
    create_time TIMESTAMP
);

```

```java
import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
import org.apache.rocketmq.common.message.MessageExt;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class DBConstraintConsumerExample {
    public static void main(String[] args) throws Exception {
        DefaultMQPushConsumer consumer = new DefaultMQPushConsumer("ConsumerGroup");
        consumer.setNamesrvAddr("localhost:9876");
        consumer.subscribe("TestTopic", "*");

        consumer.registerMessageListener(new MessageListenerConcurrently() {
            @Override
            public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> msgs, ConsumeConcurrentlyContext context) {
                for (MessageExt msg : msgs) {
                    try {
                        String orderId = new String(msg.getBody());
                        insertOrder(orderId);
                    } catch (Exception e) {
                        if (e instanceof SQLException && ((SQLException) e).getSQLState().equals("23000")) {
                            // 违反唯一约束，说明消息已处理
                            continue;
                        }
                        return ConsumeConcurrentlyStatus.RECONSUME_LATER;
                    }
                }
                return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
            }
        });

        consumer.start();
    }

    private static void insertOrder(String orderId) throws SQLException {
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "password");
        String sql = "INSERT INTO order_table (order_id, amount, create_time) VALUES (?, 100.00, NOW())";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, orderId);
        pstmt.executeUpdate();
        pstmt.close();
        conn.close();
    }
}

```

### 幂等性设计

保证业务操作的幂等性，即多次执行相同操作，产生的结果与执行一次的结果相同。

#### 状态机更新

对于有状态变化的业务，可通过状态机控制操作。比如订单状态有“待支付”“已支付”“已取消”，支付操作只有在“待支付”状态下才能执行。


```java
public class OrderService {
    public boolean payOrder(String orderId) {
        Order order = getOrder(orderId);
        if (order.getStatus() == OrderStatus.PENDING_PAYMENT) {
            // 执行支付逻辑
            updateOrderStatus(orderId, OrderStatus.PAID);
            return true;
        }
        return false;
    }

    private Order getOrder(String orderId) {
        // 从数据库获取订单信息
        return null;
    }

    private void updateOrderStatus(String orderId, OrderStatus status) {
        // 更新订单状态到数据库
    }
}

enum OrderStatus {
    PENDING_PAYMENT, PAID, CANCELLED
}

```

通过以上方法，能有效处理 RocketMQ 中的重复消费问题。


