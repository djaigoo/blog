---
author: djaigo
title: git命令手册
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
date: 2020-11-09 14:18:16
---
`git`常用命令手册（速查表）

# 基础知识
## 仓库
* 本地仓库
* 远端仓库

## 文件状态
* **未跟踪（untrack）**：表示新增加的或被忽略的文件
* **已修改（modified）**：表示修改了文件，但还没保存到git仓库中。
* **已暂存（staged）**：表示对一个已修改文件的当前版本做了标记，使之包含在下次提交的快照中。 
* **已提交（committed）**：表示文件已保存在git仓库中。

## 忽略文件
`.gitignore`文件内容表示不跟踪文件、文件夹列表

## HEAD


# add
将新建文件或修改文件标记为**已修改**状态。
# branch
分支
# checkout
# clone
克隆远端分支
# commit
提交当前修改
# config
git相关配置
# diff
# fetch
# grep
# help
打印帮助文档。
`git help -a`打印所有支持的命令。

# init
初始化git仓库
# log
# merge
# mv
# pull
拉取远端代码
# push
推送当前commit到远端
# rebase
# remote
{% post_link git-remote命令 [git-remote命令] %}

# reset
回退到某次提交
# revert
回退某次提交
# rm
# show
# stash
缓存本地修改
{% post_link git-stash命令 [git-stash命令] %}

# status
文件状态
# tag
版本