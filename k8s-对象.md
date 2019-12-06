---
title: k8s-对象
tags:
  - k8s
categories:
  - k8s
draft: false
date: 2018-08-02 10:58:27
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
介绍Kubernetes的对象
<!--more-->

# 什么是k8s对象
k8s对象是k8s系统中的持久实体，k8s使用这些实体来表示集群的状态：
- 容器化应用正在运行，在哪些节点上
- 这些应用可用的资源
- 关于这些应用如何运行的策略，如重新策略，升级和容错

k8s对象一旦创建了，k8s系统会确保对象存在，通过创建对象，可以有效告诉k8s系统你希望的集群的工作负载是什么的。要使用k8s对象都需要使用k8s API。

## 对象（object）规范和状态
每个k8s对象都包含两个嵌套对象字段，用于管理Object的配置：
- Object Spec，描述了对象所需的状态和希望Object具有的特性
- Object Status，描述对象的实际状态，并有k8s系统提供和更新

## 描述k8s对象
在k8s创建对象时，必须提供描述其所需的Status和Spec，以及关于对象的一些基本信息。
当使用k8s API创建对象时，改API请求必须将该信息作为json包含在body中，通常可以将信息提供给kubectl.yaml文件，在进行API请求时，kubectl将信息装换为json 
示例：
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```
通过yaml文件创建Deployment，可以通过kubectl create来实现，将yaml文件作为参数传递
```shell
$ kubectl create -f docs/user-guide/nginx-deployment.yaml --record
```
其输出与此类似
```shell
$ deployment "nginx-deployment" created
```
## 必填字段
如下字段为必填字段：
- apiVersion，创建对象的k8s API版本
- kind，要创建什么样的对象
- metadata，具有唯一标识对象的数据，包括name（字符串）、UID和Namespace（可选项）

还需要提供对象的Spec字段，k8s对象都是不同的，以及容器内嵌套的特定于该对象的字段
k8s API reference可以查找所有可创建k8s的Spec格式



