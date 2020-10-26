---
author: djaigo
title: golang MPG 有限状态机
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - golang
tags:
  - mpg
  - infra
date: 2020-09-29 17:54:01
updated: 2020-09-29 17:54:01
---

# P有限状态机

_Prunning
* releasep，解绑m和p，将p的状态置为_Pidle
* procresize，修改p的个数的时候，如果当前id小于修改值，则保留_Prunning状态


_Pidle
* 