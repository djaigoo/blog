---
title: 创建自己的docker image服务器
tags:
  - image
categories:
  - docker
draft: true
date: 2018-08-08 17:13:41
update: 
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/docker.png
---
介绍怎样搭建和使用自己的docker image服务器
<!--more-->

# docker hub image server
## pull官方registry镜像
```shell
$ docker pull registry:2.6.2
Trying to pull repository docker.io/library/registry ... 
2.6.2: Pulling from docker.io/library/registry
4064ffdc82fe: Pull complete 
c12c92d1c5a2: Pull complete 
4fbc9b6835cc: Pull complete 
765973b0f65f: Pull complete 
3968771a7c3a: Pull complete 
Digest: sha256:51bb55f23ef7e25ac9b8313b139a8dd45baa832943c8ad8f7da2ddad6355b3c8
```
## insecure registry
docker默认image server使用https协议传输，但是内网传输可以简单的使用http，所以我们可以在`/etc/docker/daemon.json`添加`"insecure-registries": ["image_server_ip:port"]`，这样我们的image server就支持http传输了。
## 数据持久化
为了让docker image server的数据持久化，我们需要将本地磁盘映射到容器内部的`/var/lib/registry`，这样方便我们的image server迁移。
## 运行registry镜像
```shell
$ docker run -d -p 5000:5000 -v `pwd`/data:/var/lib/registry --restart=always --name registry docker.io/registry:2.6.2
dccda7ae748e2b0a485ea9e501e09567c012acb392412727b7ee0e73ffff5961
```
这样我们就可以启动我们的镜像服务器了，映射端口5000，映射本地磁盘
# docker client
## image 命名
镜像命名格式image-hub-ip:port/image_name，例如：`172.16.220.41:5000/myhub/nginx`。这样我们就可以往我们自己的image server推送我们私有的image了。
```shell
$ docker push 172.16.220.41:5000/myhub/nginx:v0.1
The push refers to a repository [172.16.220.41:5000/myhub/nginx]
08d25fa0442e: Pushed 
a8c4aeeaa045: Pushed 
cdb3f9544e4c: Pushed 
v0.1: digest: sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189 size: 948
```
## 测试
删除本地镜像
```shell
$ docker rmi 172.16.220.41:5000/myhub/nginx:v0.1
Untagged: 172.16.220.41:5000/myhub/nginx:v0.1
Untagged: 172.16.220.41:5000/myhub/nginx@sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
```
拉取image
```shell
$ docker pull 172.16.220.41:5000/myhub/nginx:v0.1
Trying to pull repository 172.16.220.41:5000/myhub/nginx ... 
v0.1: Pulling from 172.16.220.41:5000/myhub/nginx
Digest: sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
Status: Downloaded newer image for 172.16.220.41:5000/myhub/nginx:v0.1
```
可以看到我们又重新获取到了镜像，这样我们的image server就搭建完成了。


