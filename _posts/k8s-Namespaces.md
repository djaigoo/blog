---
title: k8s-Namespaces
tags:
  - k8s
categories:
  - k8s
draft: false
date: 2018-08-02 11:52:44
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
介绍Kubernetes的Namespaces
<!--more-->
k8s可以使用Namespace创建多个虚拟集群
# 何时使用多个Namespaces
团队或者项目中有许多用户，可以使用namespace来分区，如果需要他们提供特殊性质时，也可以使用namespace
- namespace为名称提供了一个范围，资源的name在namespace具有唯一性
- namespace是一种集群资源划分为多个用途（通过resource quota）的方法
- 未来，默认情况下，相同的namespace中的对象具有相同的访问控制策略

# 使用Namespace
## 创建

```shell
# 命令行直接创建
$ kubectl create namespace new-namespace

# 通过文件创建
$ cat my-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: new-namespace

$ kubectl create -f ./my-namespace.yaml
```
命名空间名称满足正则表达式`[a-z0-9]([-a-z0-9]*[a-z0-9])?`，最大长度为63位

## 删除
```shell
$ kubectl delete namespaces new-namespace
```
- 删除一个namespace会自动删除所有属于该namespace的资源
- default和kube-system namespace不可删除
- PersistentVolumes是不属于任何namespace的，但是PersistentVolumeCliaim是属于某个特定namespace的
- Events是否属于namespace取决于产生events的对象


## 查看
```shell
$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    1d
kube-system   Active    1d
```
k8s 从初始的两个namespace开始：default和kube-system（由k8s系统创建的对象的Namespace）

### Setting the namespace for a request
临时设置request的namespace，需要使用--namespace标志
```shell
$ kubectl --namespace=<insert-namespace-name-here> run nginx --image=nginx
$ kubectl --namespace=<insert-namespace-name-here> get pods
```

### setting the namespace preference 
可以使用kubectl命令创建Namespace可以永久保存在context中
```shell
$ kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
# Validate it
$ kubectl config view | grep namespace:
```


# 什么对象在Namespace中
大多数Kubernetes资源（例如pod、services、replication controllers或其他）都在某些Namespace中，但Namespace资源本身并不在Namespace中。
而低级别资源（如Node和persistentVolumes）不在任何Namespace中。
Events是一个例外：它们可能有也可能没有Namespace，具体取决于Events的对象。


