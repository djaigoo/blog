---
title: docker-image创建，使用，删除
tags:
  - docker-image
categories:
  - docker
draft: true
date: 2018-08-06 16:43:23
---
docker image的相关操作
<!--more-->

# 如何编写Dockerfile
[dockerfile指令](/blog/dockerfile指令)

# docker image的使用

## 查看本机所拥有的镜像
使用`docker image ls`获取本机的镜像
## 获取基础镜像
使用`docekr pull imagename:version`获取指定version的image
## 更新镜像并提交
可以进入容器内部，执行某些命令让该镜像变成一个新的镜像，然后使用`docker commit -m="commit message"`来提交自己的更改
## 使用dockerfile创建镜像
在编辑好dockerfile后可以通过`docker build`来创建自己的镜像
## 设置镜像标签
使用`docker tag image_id repository:version`设置version
## 推送镜像到docker hub
使用`docker push`将自己的镜像可以push到docker hub网站上，供他人下载使用
## 删除镜像
首先使用`docker ps`查看镜像是否有实例在运行，如果有需要先调用`docker rm container_id`删除container，在删除镜像`docker rmi image_id`