---
author: djaigo
title: git-mv命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git mv 命令

## 简介

`git mv` 是 Git 中用于移动或重命名文件的命令。它实际上是 `mv` 命令加上 `git add` 和 `git rm` 的组合。

## 基本概念

### Git Mv vs 普通 Mv

| 特性 | Git Mv | 普通 Mv |
|------|--------|---------|
| **Git 跟踪** | 自动跟踪移动 | 需要手动添加 |
| **历史保留** | 保留文件历史 | 可能丢失历史 |
| **操作** | 移动 + 暂存 | 只移动文件 |

## 命令语法

```sh
# 移动/重命名文件
git mv <源文件> <目标文件>

# 移动目录
git mv <源目录> <目标目录>
```

## 查看帮助文档

```sh
$ git mv --help
```

# 基本使用

## 1. 重命名文件

```sh
# 重命名文件
$ git mv old-name.txt new-name.txt

# 查看状态
$ git status
```

## 2. 移动文件

```sh
# 移动文件到目录
$ git mv file.txt src/file.txt

# 移动文件到新位置
$ git mv old/path/file.txt new/path/file.txt
```

## 3. 移动目录

```sh
# 移动目录
$ git mv old-dir new-dir

# 移动目录内容
$ git mv old-dir/* new-dir/
```

## 4. 强制移动

```sh
# 强制移动（覆盖已存在的文件）
$ git mv -f old-file.txt existing-file.txt
```

# 实际应用场景

## 场景1：重命名文件

```sh
# 重命名文件
$ git mv README.txt README.md

# 提交更改
$ git commit -m "Rename README.txt to README.md"
```

## 场景2：重组目录结构

```sh
# 移动文件到新目录
$ git mv file.txt src/utils/file.txt

# 提交更改
$ git commit -m "Reorganize file structure"
```

## 场景3：批量移动

```sh
# 移动多个文件
$ git mv file1.txt file2.txt src/

# 提交更改
$ git commit -m "Move files to src directory"
```

# 与普通 mv 的区别

## 使用 Git Mv（推荐）

```sh
# Git 会自动跟踪移动
$ git mv old.txt new.txt
$ git status
# renamed: old.txt -> new.txt
```

## 使用普通 Mv

```sh
# 需要手动添加和删除
$ mv old.txt new.txt
$ git rm old.txt
$ git add new.txt
$ git status
```

# 常见问题和解决方案

## 问题1：文件已存在

**解决方案**：
```sh
# 使用 -f 强制覆盖
$ git mv -f old-file.txt existing-file.txt
```

## 问题2：想保留两个文件

**解决方案**：
```sh
# 先复制文件
$ cp old-file.txt new-file.txt
$ git add new-file.txt

# 然后删除旧文件（如果需要）
$ git rm old-file.txt
```

# 最佳实践

## 1. 使用 git mv 而不是普通 mv

```sh
# ✅ 推荐：使用 git mv
$ git mv old.txt new.txt

# ❌ 不推荐：使用普通 mv（需要额外步骤）
$ mv old.txt new.txt
$ git rm old.txt
$ git add new.txt
```

## 2. 移动后立即提交

```sh
# 移动文件
$ git mv old.txt new.txt

# 立即提交
$ git commit -m "Rename file"
```

# 总结

`git mv` 是移动和重命名文件的便捷命令：

1. **重命名文件**：`git mv old new` 重命名文件
2. **移动文件**：`git mv file dir/` 移动文件
3. **自动跟踪**：Git 自动跟踪移动操作
4. **保留历史**：保留文件的历史记录

**关键要点**：
- ✅ 使用 `git mv` 而不是普通 `mv`
- ✅ Git 会自动跟踪移动操作
- ✅ 保留文件的历史记录
- ✅ 移动后记得提交

