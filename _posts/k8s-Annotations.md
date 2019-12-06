---
title: k8s-Annotations
tags:
  - k8s
categories:
  - k8s
draft: true
date: 2018-08-02 15:28:20
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
# Kubernetes Annotations

可以使用Kubernetes Annotations将任何非标识metadata附加到对象。客户端（如工具和库）可以检索此metadata。
<!--more-->
## 将metadata附加到对象

可以使用[Labels](http://docs.kubernetes.org.cn/247.html)或Annotations将元数据附加到Kubernetes对象。标签可用于选择对象并查找满足某些条件的对象集合。相比之下，Annotations不用于标识和选择对象。Annotations中的元数据可以是small 或large，structured 或unstructured，并且可以包括标签不允许使用的字符。

Annotations就如标签一样，也是由key/value组成：

```json
"annotations": {
  "key1" : "value1",
  "key2" : "value2"
}
```


以下是在Annotations中记录信息的一些例子：

*   构建、发布的镜像信息，如时间戳，发行ID，git分支，PR编号，镜像hashes和注Registry地址。
*   一些日志记录、监视、分析或audit repositories。
*   一些工具信息：例如，名称、版本和构建信息。
*   用户或工具/系统来源信息，例如来自其他生态系统组件对象的URL。
*   负责人电话/座机，或一些信息目录。

**注意**：Annotations不会被Kubernetes直接使用，其主要目的是方便用户阅读查找。
