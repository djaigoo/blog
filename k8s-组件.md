---
title: Kubernetes-组件
tags:
  - k8s
categories:
  - k8s
draft: false
date: 2018-08-02 10:17:29
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
介绍Kubernetes集群所需的各种组件
<!--more-->

# master 组件
master 组件提供集群的管理控制中心
master 组件可以运行在任何节点上

## kube-apiserver
kube-apiserver 用于暴露k8s API，任何的资源请求/调用操作都是通过它提供的接口进行

## ETCD
etcd 是k8s提供的默认存储系统，保存所有集群的数据，使用时需要为数据提供备份计划

## kube-controller-manager
kube-controller-manager 运行管理控制器，包括：
- 节点（Node）控制器
- 副本（Replication）控制器，负责维护系统中每个副本中的pod
- 端点（Endpoints）控制器，填充Endpoints对象（连接services&pods)
- Service-Account和Token控制器，为新的Namespace创建默认账户访问API Token

## cloud-controller-manager
cloud-controller-manager 负责与底层云服务提供商平台交互，具体功能：
- 节点（Node）控制器
- 路由（Route）控制器
- Service控制器
- 卷（Volume）控制器

## addons
addons 插件是实现集群pod和Services功能。Pod由Deployments，ReplicationController等进行管理。Namespace插件对象是在kube-system Namespace中创建

## DNS
DNS 为k8s service提供DNS记录

## kube-ui
kube-ui 提供集群状态基础信息查看

## 容器资源监测
容器资源监测 提供一个UI浏览监控数据

## cluster-level logging
cluster-level logging 负责保存容器日志，搜索、查看日志

# 节点（Node）组件
节点组件运行在Node中，提供k8s运行时环境，以及维护Pod

## kubelet
kubelet 主要的节点代理，他会监视已分配节点的pod，具体功能：
- 安装pod所需的volume
- 下载pod的secrets
- pod中运行的docker容器
- 定期执行容器健康检查
- 在创建镜像pod时，返回pod的状态
- 返回node的状态

## kube-proxy
 kube-proxy 通过在主机上维护网络规则并执行连接转发来实现k8s服务抽象

## docker
docker 运行的容器

## RKT
RKT 运行容器，作为docker工具的替代方案

## supervisord
supervisord 轻量级的监控系统，用于保障kubelet和docker运行

## fluentd
fluentd 提供cluster-level logging