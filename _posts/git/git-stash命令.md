---
author: djaigo
title: git-stash命令
date: 2019-12-10 14:43:35
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png
categories: 
  - git
tags: 
---

# git stash
将当前所有更改记录存放于栈区，可以在必要时将当前的更改恢复
应用场景：
* 需要切换分支，但是不想commit目前的文件更改
* 用于临时切换分支

## 命令
git stash
将当前更改存储到栈区，当前文件目录就会回退到最近分支commit的状态

apply   -- 应用stash中的更改记录，调回指定的存储，如果不指明则默认最新存储。如果应用存储是会发生冲突的，所以应用后需要合并冲突
branch  -- 在最初创建存储的提交处分支，如果你存储一份修改，暂时不去理会，然后继续在你存储的分支上工作，你在重新应用工作时可能会碰到一些问题合并冲突的问题
这个命令会创建一个新的分支，检查你存储的提交，重新应用分支，如果成功，将会丢弃储藏
clear   -- 删除所有stash
create  -- 创建一个存储而不将其存储在ref命名空间中
drop    -- 从list中删除一个stash
list    -- 列出所有的stash
pop     -- 从stash列表中删除并应用最近的stash
save    -- 将您的本地修改保存到新的stash中
show    -- 展示在stash中的修改记录的差异

## 与commit的区别
commit会记录在历史记录中，而stash不会

实体包：数据传输结构体定义
工具包：功能函数实现
错误包：产生错误定义
模拟包：mock数据定义，函数实现
部署包：部署远端服务器实现
数据层：远端数据层实现
服务层：本地功能实现
路由层：分配路由，指定处理服务handle
