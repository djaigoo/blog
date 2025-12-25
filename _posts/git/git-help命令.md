---
author: djaigo
title: git-help命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git help 命令

## 简介

`git help` 是 Git 中用于显示帮助文档的命令。它是学习 Git 命令的重要工具。

## 基本概念

### Help 的作用

1. 显示命令的帮助文档
2. 列出所有可用命令
3. 显示 Git 概念和指南
4. 提供命令使用示例

## 命令语法

```sh
# 显示命令帮助
git help <命令>

# 列出所有命令
git help -a

# 显示指南
git help -g

# 显示所有帮助
git help --all
```

## 查看帮助文档

```sh
$ git help help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-a, --all` | 列出所有可用命令 |
| `-g, --guides` | 列出可用的指南 |
| `-i, --info` | 使用 info 格式显示 |
| `-m, --man` | 使用 man 格式显示 |
| `-w, --web` | 在浏览器中打开帮助 |

# 基本使用

## 1. 查看命令帮助

```sh
# 查看命令帮助
$ git help status

# 查看命令帮助（简短）
$ git status --help

# 在浏览器中查看
$ git help --web status
```

## 2. 列出所有命令

```sh
# 列出所有可用命令
$ git help -a

# 列出所有命令和指南
$ git help --all
```

## 3. 查看指南

```sh
# 列出可用的指南
$ git help -g

# 查看特定指南
$ git help everyday
$ git help workflows
```

## 4. 使用不同格式

```sh
# 使用 man 格式
$ git help -m status

# 使用 info 格式
$ git help -i status

# 在浏览器中打开
$ git help -w status
```

# 实际应用场景

## 场景1：学习新命令

```sh
# 查看命令帮助
$ git help rebase

# 查看命令选项
$ git help commit
```

## 场景2：查找可用命令

```sh
# 列出所有命令
$ git help -a

# 搜索特定命令
$ git help -a | grep branch
```

## 场景3：查看指南

```sh
# 查看日常使用指南
$ git help everyday

# 查看工作流指南
$ git help workflows
```

# 常用指南

Git 提供了一些有用的指南：

- `everyday`：日常 Git 使用指南
- `workflows`：Git 工作流指南
- `gittutorial`：Git 教程
- `giteveryday`：日常命令参考

# 总结

`git help` 是学习 Git 的重要工具：

1. **查看帮助**：`git help <命令>` 查看命令帮助
2. **列出命令**：`git help -a` 列出所有命令
3. **查看指南**：`git help -g` 列出指南
4. **浏览器查看**：`git help -w` 在浏览器中打开

**关键要点**：
- ✅ 使用 `git help` 学习命令
- ✅ 查看指南了解工作流
- ✅ 使用 `-w` 在浏览器中查看更友好

