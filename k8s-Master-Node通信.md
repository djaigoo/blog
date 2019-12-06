---
title: k8s-Master-Node通信
tags:
  - k8s
categories:
  - k8s
draft: true
date: 2018-08-02 15:59:11
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---

## 概述

本文主要介绍master和Kubernetes集群之间通信路径。其目的是允许用户自定义安装，以增强网络配置，使集群可以在不受信任（untrusted）的网络上运行。
<!--more-->
## Cluster -> Master

从集群到Master节点的所有通信路径都在apiserver中终止。一个典型的deployment ，如果apiserver配置为监听运程连接上的HTTPS 443端口，应启用一种或多种client [authentication](http://docs.kubernetes.org.cn/51.html)，特别是如果允许[anonymous requests](http://docs.kubernetes.org.cn/51.html#Putting_a_Bearer_Token_in_a_Request)或service account tokens 。

Node节点应该配置为集群的公共根证书，以便安全地连接到apiserver。

希望连接到apiserver的Pod可以通过service account来实现，以便Kubernetes在实例化时自动将公共根证书和有效的bearer token插入到pod中，kubernetes service (在所有namespaces中)都配置了一个虚拟IP地址，该IP地址由apiserver重定向(通过kube - proxy)到HTTPS。

Master组件通过非加密(未加密或认证)端口与集群apiserver通信。这个端口通常只在Master主机的localhost接口上暴露。

## Master -> Cluster

从Master (apiserver)到集群有两个主要的通信路径。第一个是从apiserver到在集群中的每个节点上运行的kubelet进程。第二个是通过apiserver的代理功能从apiserver到任何node、pod或service 。

### apiserver - > kubelet

从apiserver到kubelet的连接用于获取pod的日志，通过kubectl来运行pod，并使用kubelet的端口转发功能。这些连接在kubelet的HTTPS终端处终止。

默认情况下，apiserver不会验证kubelet的服务证书，这会使连接不受到保护。

要验证此连接，使用--kubelet-certificate-authority flag为apiserver提供根证书包，以验证kubelet的服务证书。

如果不能实现，那么请在apiserver和kubelet之间使用 [SSH tunneling](https://kubernetes.io/docs/concepts/architecture/master-node-communication/#ssh-tunnels)。

最后，应该启用[Kubelet认证或授权](https://kubernetes.io/docs/admin/kubelet-authentication-authorization/)来保护Kubelet API。

### apiserver -> nodes、pods、services

从apiserver到Node、Pod或Service的连接默认为HTTP连接，因此不需进行认证加密。也可以通过HTTPS的安全连接，但是它们不会验证HTTPS 端口提供的证书，也不提供客户端凭据，因此连接将被加密但不会提供任何诚信的保证。这些连接不可以在不受信任/或公共网络上运行。

### SSH Tunnels

[Google Container Engine](https://cloud.google.com/container-engine/docs/) 使用SSH tunnels来保护 Master -> 集群 通信路径，SSH tunnel能够使Node、Pod或Service发送的流量不会暴露在集群外部。
