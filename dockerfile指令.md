---
title: Dockerfile指令
tags:
  - Dockerfile
categories:
  - docker
draft: true
date: 2018-08-06 09:59:49
---
Dockerfile语法由两部分构成，注释和命令+参数
<!--more-->
# Dockerfile常用命令
## FROM
FROM 设置基本镜像，基础镜像可以是任意镜像，如果基础镜像没有被发现，Docker试图从Docker image index中查找镜像。
FROM必须是Dockerfile的第一个命令。如果同一个Dockerfile创建多个镜像时，可以使用多个FROM指令（每个镜像一次）。
## MAINTAINER
MAINTAINER 指定维护者的信息，并放在FROM的后面
## RUN
RUN 接收命令作为参数创建镜像，可以创建新的镜像。每条RUN指令都会在当前基础镜像的基础上执行，并提交生成新的镜像。
执行格式：
* RUN ...，使用/bin/bash，执行当前语句
* RUN [“executable”, “ param”, ...]，使用exec的方式运行指令

## USER
USER 指定运行容器时的用户名或UID，后序的RUN也会使用指定的用户。
## VOLUME
VOLUME 让容器使用宿主机上的目录，是对容器和宿主机上的目录的映射，一般用于数据的永久存储，例：数据库，和需要保持的数据。调用格式：`VOLUME [“container_dir”, “host_dir”]`
## WORKDIR
WORKDIR 命令用于设置CMD指令的命令的运行目录，为后序的RUN，CMD，ENTRYPOINT指令配置工作目录，后序可以使用多个WORKDIR指令，如果后序指令参数是相对路径，则会基于之前的指令指定路径。
```shell
WORKDIR /a
WORKDIR b
WORKDIR c
# finally path /a/b/c
```

## CMD 
CMD 执行指令，每个容器只能执行一条CMD指令，存在多个CMD指令时，只执行最后一个。
支持三种格式：
* CMD [“executable”, “parma”, ...]，使用exec执行
* CMD command parma1, ...，在/bin/sh上执行
* CMD [“parma”, ...]，提供给ENTRYPOINT做默认参数

## ENV
ENV 为容器设置指定的环境变量，会被后序的RUN指令使用，并在容器运行时保持。
## ADD
ADD 从源系统的文件系统上传至目标容器的文件系统，如果源是一个URL，那么会下载URL内容并复制到容器中，如果文件是可识别的压缩格式，则docker会帮忙解压缩。
## COPY
COPY 将文件从指定路径复制添加到容器内部路径
## EXPOSE
EXPOSE 暴露docker容器的指定端口
## ENTRYPOINT
ENTRYPOINT 配置容器后执行的命令，并且不可被docker run 提供的参数覆盖，每个Dockerfile中只能有一个ENTRYPOINT，但指定多个时，只有最后一个起效。
执行格式：
* ENTRYPOINT [“executable”, “param”, ...]
* ENTRYPOINT command param ...

## ONBUILD
ONBUILD 指定的命令在构建镜像时并不执行，而是在子镜像中执行。









