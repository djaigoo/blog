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
**HEAD** 是一个特殊引用，指向当前所在的提交（即“当前检出的”版本）。在分支上时，HEAD 指向该分支，分支再指向最新提交；在**分离 HEAD**（detached HEAD）时，HEAD 直接指向某次提交。

* **引用写法**
  * `HEAD`：当前提交
  * `HEAD^` 或 `HEAD~1`：上一代提交（第一个父提交）
  * `HEAD~n`：上 n 代提交（如 `HEAD~3` 表示往前数第 3 个提交）
  * `HEAD^^` 与 `HEAD~2` 等价
  * `HEAD^2`：合并提交的**第二父提交**（仅对 merge 产生的提交有意义）
* **常见用法**
  * `git show HEAD`、`git diff HEAD`：查看当前提交或与工作区差异
  * `git reset --soft HEAD^`：回退到上一提交，保留暂存与工作区
  * `git checkout HEAD -- <file>`：用当前提交的版本覆盖工作区文件
  * `git revert HEAD`：新增一次提交，撤销当前提交的改动

# add
将新建文件或修改文件标记为**已修改**状态。
[git-add命令](/git/git-add命令.html)

# branch
分支
[git-branch命令](/git/git-branch命令.html)

# checkout
[git-checkout命令](/git/git-checkout命令.html)

# clone
克隆远端分支
[git-clone命令](/git/git-clone命令.html)

# commit
提交当前修改
[git-commit命令](/git/git-commit命令.html)

# config
git相关配置
[git-config命令](/git/git-config命令.html)

# diff
[git-diff命令](/git/git-diff命令.html)

# fetch
[git-fetch命令](/git/git-fetch命令.html)

# grep
[git-grep命令](/git/git-grep命令.html)

# help
打印帮助文档。
`git help -a`打印所有支持的命令。
[git-help命令](/git/git-help命令.html)

# init
初始化git仓库
[git-init命令](/git/git-init命令.html)

# log
[git-log命令](/git/git-log命令.html)

# merge
[git-merge命令](/git/git-merge命令.html)

# mv
[git-mv命令](/git/git-mv命令.html)

# pull
拉取远端代码
[git-pull命令](/git/git-pull命令.html)

# push
推送当前commit到远端
[git-push命令](/git/git-push命令.html)

# rebase
[git-rebase命令](/git/git-rebase命令.html)

# remote
[git-remote命令](/git/git-remote命令.html)

# reset
回退到某次提交
[git-reset命令](/git/git-reset命令.html)

# revert
回退某次提交
[git-revert命令](/git/git-revert命令.html)

# rm
[git-rm命令](/git/git-rm命令.html)

# show
[git-show命令](/git/git-show命令.html)

# stash
缓存本地修改
[git-stash命令](/git/git-stash命令.html)

# status
文件状态
[git-status命令](/git/git-status命令.html)

# tag
版本
[git-tag命令](/git/git-tag命令.html)
