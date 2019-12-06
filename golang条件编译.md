---
title: golang条件编译
tags:
  - golang
categories:
  - golang
draft: true
date: 2018-08-24 14:19:01
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png
---

golang代码在不同平台下底层接口函数可能不一样，但是函数主要功能是一样的，这样就会导致不同的平台golang代码编译不通过，golang提供了类似C语言的条件编译进行筛选不同平台文件进行编译。
<!--more-->

## Build Constraints
在golang源码文件开始行之前标记`// +build`就可以标记当前文件的编译约束的条件
约束可以出现在任何文件，但是他们必须出现在文件顶部，在它前面只能是空行和注释，即约束必须在golang文件的package子句之前
使用时必须将约束和包文档区分开来，必须在一系列约束后面加一个空行

约束编写格式：
* 以空格分隔表示“or”
* 以逗号分隔表示“and”
* 以!开头表示否定
* 换行表示有多个约束，总体是各个约束的“and”

build满足的条件单词
* 目标操作系统，由runtime.GOOS拼写，例如：“windows”，“linux”
* 目标体系结构，由runtime.GOARCH拼写，例如：“386”
* 正在使用的编译器，“gc”或者“gccgo”
* 如果ctxt.CgoEnabled为true，使用“cgo”
* “go1.x”，表示从GO版本1.x开始
* ctxt.BuildTags中列出的任何其他单词

如果文件的名称剥离扩展名，和可能的“_test”后缀之后匹配以下任何模式：
* `*_GOOS`，表示一直任何的操作系统
* `*_GOARCH`，表示任何体系结构值
* `*_GOOS_GOARCH`
例如：`source_windows_amd64.go`该文件被认为具有需要这些术语的隐式构建约束（除了文件中的任何显示约束）

保持文件不被考虑用于构建
`// +build ignore`，任何其他词也会起作用，但“忽略”是常规的

必须在Linux或OS X上才能时候cgo构建文件`// +build linux, cgo darwin, cgo`

除了android标签和文件之外，使用GOOS=android匹配构建标签和文件





