---
title: k8s-Names
tags:
  - k8s
categories:
  - k8s
draft: false
date: 2018-08-02 11:44:17
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
介绍Kubernetes的Name
<!--more-->

# k8s Names
Kubernetes REST API中的所有对象都用Name和UID来明确地标识
对于非唯一用户提供的属性，Kubernetes提供labels和annotations

## Name
Name 在一个对象中同一时间只能拥有单个Name，如果对象被删除，也可以使用相同Name创建新的对象，Name用于在资源引用URL中的对象
通常情况，Name最长到253字符（包括数字，字母，-，.），但是某些资源可能有更具体的限制条件

## UIDs
UIDs 是有k8s生成的，在k8s几群的整个生命周期中创建的每个对象都有不同的UID（即他们在空间和时间上是唯一的）