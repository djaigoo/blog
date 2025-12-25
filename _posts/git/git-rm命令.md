---
author: djaigo
title: git-rm命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git rm 命令

## 简介

`git rm` 是 Git 中用于从 Git 仓库和工作区删除文件的命令。它同时删除文件并暂存删除操作。

## 基本概念

### Git Rm vs 普通 Rm

| 特性 | Git Rm | 普通 Rm |
|------|--------|---------|
| **工作区** | 删除文件 | 删除文件 |
| **暂存区** | 自动暂存删除 | 需要手动添加 |
| **操作** | 删除 + 暂存 | 只删除文件 |

## 命令语法

```sh
# 删除文件
git rm <文件>

# 删除目录
git rm -r <目录>

# 只从暂存区删除（保留文件）
git rm --cached <文件>
```

## 查看帮助文档

```sh
$ git rm --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-f, --force` | 强制删除（即使文件已修改） |
| `-r, --recursive` | 递归删除目录 |
| `--cached` | 只从暂存区删除，保留工作区文件 |
| `-n, --dry-run` | 预览模式，不实际删除 |
| `-q, --quiet` | 静默模式 |
| `--ignore-unmatch` | 如果文件不存在也不报错 |

# 基本使用

## 1. 删除文件

```sh
# 删除文件（从工作区和暂存区）
$ git rm file.txt

# 查看状态
$ git status
# deleted: file.txt
```

## 2. 删除目录

```sh
# 递归删除目录
$ git rm -r directory/

# 或使用
$ git rm -r directory
```

## 3. 只从 Git 删除（保留文件）

```sh
# 只从 Git 跟踪中删除，保留文件
$ git rm --cached file.txt

# 常用于添加到 .gitignore 的文件
$ git rm --cached sensitive-file.txt
$ echo "sensitive-file.txt" >> .gitignore
```

## 4. 强制删除

```sh
# 强制删除已修改的文件
$ git rm -f file.txt
```

## 5. 预览删除

```sh
# 预览将要删除的文件
$ git rm -n file.txt
```

# 实际应用场景

## 场景1：删除不需要的文件

```sh
# 删除文件
$ git rm unwanted-file.txt

# 提交删除
$ git commit -m "Remove unwanted file"
```

## 场景2：从 Git 中移除但保留文件

```sh
# 文件已添加到 .gitignore，需要从 Git 中移除
$ git rm --cached file.txt

# 添加到 .gitignore
$ echo "file.txt" >> .gitignore

# 提交
$ git add .gitignore
$ git commit -m "Stop tracking file.txt"
```

## 场景3：批量删除

```sh
# 删除多个文件
$ git rm file1.txt file2.txt file3.txt

# 删除匹配模式的文件
$ git rm *.log
```

## 场景4：删除目录

```sh
# 删除整个目录
$ git rm -r old-directory/

# 提交
$ git commit -m "Remove old directory"
```

# 常见问题和解决方案

## 问题1：文件已修改无法删除

**错误信息**：
```
error: the following file has local modifications
```

**解决方案**：
```sh
# 使用 -f 强制删除
$ git rm -f file.txt

# 或先提交/丢弃更改
$ git add file.txt
$ git commit -m "Update file"
$ git rm file.txt
```

## 问题2：只想从 Git 中移除

**解决方案**：
```sh
# 使用 --cached 只从 Git 中移除
$ git rm --cached file.txt

# 文件保留在工作区
```

## 问题3：误删文件

**解决方案**：
```sh
# 从最后一次提交恢复
$ git checkout HEAD -- file.txt

# 或使用 git restore（Git 2.23+）
$ git restore file.txt
```

# 最佳实践

## 1. 删除后立即提交

```sh
# 删除文件
$ git rm file.txt

# 立即提交
$ git commit -m "Remove file"
```

## 2. 使用 --cached 移除跟踪

```sh
# 从 Git 中移除但保留文件
$ git rm --cached file.txt
$ echo "file.txt" >> .gitignore
$ git commit -m "Stop tracking file.txt"
```

## 3. 预览删除

```sh
# 删除前预览
$ git rm -n file.txt
```

# 总结

`git rm` 是从 Git 仓库删除文件的命令：

1. **删除文件**：`git rm file` 删除文件
2. **删除目录**：`git rm -r dir` 递归删除
3. **移除跟踪**：`git rm --cached file` 只从 Git 移除
4. **强制删除**：`git rm -f file` 强制删除

**关键要点**：
- ✅ 使用 `git rm` 而不是普通 `rm`
- ✅ 删除后记得提交
- ✅ 使用 `--cached` 移除跟踪但保留文件
- ✅ 删除前可以预览

