---
author: djaigo
title: git-remote命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - null
tags:
  - git
date: 2021-01-04 13:50:48
---

`remote`命令让`git`本地仓库与远端仓库进行绑定。
`git remote -h`帮助文档
```sh
$ git remote -h 
usage: git remote [-v | --verbose]
   or: git remote add [-t <branch>] [-m <master>] [-f] [--tags | --no-tags] [--mirror=<fetch|push>] <name> <url>
   or: git remote rename <old> <new>
   or: git remote remove <name>
   or: git remote set-head <name> (-a | --auto | -d | --delete | <branch>)
   or: git remote [-v | --verbose] show [-n] <name>
   or: git remote prune [-n | --dry-run] <name>
   or: git remote [-v | --verbose] update [-p | --prune] [(<group> | <remote>)...]
   or: git remote set-branches [--add] <name> <branch>...
   or: git remote get-url [--push] [--all] <name>
   or: git remote set-url [--push] <name> <newurl> [<oldurl>]
   or: git remote set-url --add <name> <newurl>
   or: git remote set-url --delete <name> <url>

    -v, --verbose         be verbose; must be placed before a subcommand
```

`git`与远端绑定通过`<name>`标签进行相关联，通常标签名为`origin`，例如：拉取代码`git pull origin master`，推送代码`git push origin master`。

`git remote`的相关操作的结果都会写入`.git/config`文件中。

# -v --verbose
显示远端仓库推送和拉取地址。
支持单标签拥有多个推送地址，支持多个标签，前者可以让本地仓库的修改同时推送到不同的远端仓库，后者支持多个不同的远端仓库获取和推送。
远端地址需要通过`add`的方式添加指定操作。
单个标签支持推送多个远端：
```sh
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
github  git@github.com:github/project.git (push)
```

同时支持多个标签：
```sh
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
github  git@github.com:github/project.git (fetch)
github  git@github.com:github/project.git (push)
```

在使用上`git pull/push origin/github branch`就可以拉取响应标签相应分支的代码

## show
只显示指定标签的内容

## update

# add
将本地仓库与远端仓库绑定。
当在github新建一个仓库时，github会提示相应的操作，其中就有一个`git remote add origin git@github.com:myself/project.git`，就是将本地仓库与远端github上的仓库进行绑定，每个标签只能`add`一次。

# rename
重命名标签名

# remove
移除标签

# set-head

# prune

# set-branches

# get-url
获取标签对应的远端仓库地址。
```sh
$ git remote get-url origin
git@github.com:myself/project.git
$ git remote get-url github
git@github.com:github/project.git
```


# set-url
修改标签对应远端仓库地址。
```sh
$ git remote set-url origin git@github.com:github/project.git
$ git remote get-url origin                                  
git@github.com:github/project.git
```

## --add
向标签添加一个新的远端仓库推送地址。这样就可以实现同一个本地仓库，执行`git push origin master`时，可以同时向两个远端仓库推送代码。
```sh
$ git remote set-url origin git@github.com:github/project.git
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
origin  git@github.com:github/project.git (push)
github  git@github.com:github/project.git (fetch)
github  git@github.com:github/project.git (push)
```

## --delete
删除标签对应的远端仓库地址。
```sh
$ git remote set-url --delete origin git@github.com:github/project.git
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
github  git@github.com:github/project.git (fetch)
github  git@github.com:github/project.git (push)
```

如果删除的是可以从远端仓库拉取的地址则会报错`fatal: Will not delete all non-push URLs`



