---
title: kafka常用命令
tags:
  - kafka
  - 命令
categories:
  - kafka
date: 2018-11-29 18:26:19
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/kafka.png
---

# kafka常用的命令汇总



## 查看topic的详细信息  

`./kafka-topics.sh -zookeeper 127.0.0.1:2181 -describe -topic testKJ1  `

## 为topic增加副本  

`./kafka-reassign-partitions.sh -zookeeper 127.0.0.1:2181 -reassignment-json-file json/partitions-to-move.json -execute  `

## 创建topic 

`./kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic testKJ1  `

## 为topic增加partition  

`./bin/kafka-topics.sh –zookeeper 127.0.0.1:2181 –alter –partitions 20 –topic testKJ1  `

## kafka生产者客户端命令  

`./kafka-console-producer.sh --broker-list localhost:9092 --topic testKJ1  `

## kafka消费者客户端命令  

`./kafka-console-consumer.sh -zookeeper localhost:2181 --from-beginning --topic testKJ1  `

## kafka服务启动  

`./kafka-server-start.sh -daemon ../config/server.properties   `

## 下线broker  

`./kafka-run-class.sh kafka.admin.ShutdownBroker --zookeeper 127.0.0.1:2181 --broker #brokerId# --num.retries 3 --retry.interval.ms 60  `

## 删除topic  
`./kafka-run-class.sh kafka.admin.DeleteTopicCommand --topic testKJ1 --zookeeper 127.0.0.1:2181  `

`./kafka-topics.sh --zookeeper localhost:2181 --delete --topic testKJ1  `

## 查看consumer组内消费的offset  

`./kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper localhost:2181 --group test --topic testKJ1`
