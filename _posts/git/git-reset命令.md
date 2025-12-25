---
author: djaigo
title: git-reset命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git reset 命令

## 简介

`git reset` 是 Git 中用于回退到指定提交的命令。它可以重置 HEAD 指针、暂存区和工作区。

## 基本概念

### Reset 的三种模式

1. **--soft**：只重置 HEAD，保留暂存区和工作区
2. **--mixed**（默认）：重置 HEAD 和暂存区，保留工作区
3. **--hard**：重置 HEAD、暂存区和工作区（危险！）

### Reset vs Revert

| 特性 | Reset | Revert |
|------|-------|--------|
| **历史** | 重写历史 | 创建新提交 |
| **安全性** | 可能丢失更改 | 安全，不丢失 |
| **使用场景** | 本地未推送的提交 | 已推送的提交 |
| **协作** | 不适合共享分支 | 适合共享分支 |

## 命令语法

```sh
# 重置到指定提交
git reset [模式] [提交]

# 重置文件
git reset [提交] -- <文件>
```

## 查看帮助文档

```sh
$ git reset --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `--soft` | 只重置 HEAD，保留暂存区和工作区 |
| `--mixed` | 重置 HEAD 和暂存区，保留工作区（默认） |
| `--hard` | 重置 HEAD、暂存区和工作区 |
| `--merge` | 重置并保留未暂存的更改 |
| `--keep` | 重置但保留工作区的更改 |
| `-q, --quiet` | 静默模式 |
| `--pathspec-from-file=<file>` | 从文件读取路径规范 |

# 基本使用

## 1. Soft Reset（保留更改）

```sh
# 重置到指定提交，保留所有更改在暂存区
$ git reset --soft HEAD~1

# 重置到指定提交
$ git reset --soft abc1234
```

**使用场景**：想修改最后一次提交，保留所有更改。

## 2. Mixed Reset（默认，保留工作区）

```sh
# 重置到上一个提交，保留工作区更改
$ git reset HEAD~1

# 或明确指定
$ git reset --mixed HEAD~1

# 重置到指定提交
$ git reset abc1234
```

**使用场景**：想取消暂存，但保留工作区的更改。

## 3. Hard Reset（危险！）

```sh
# 重置到上一个提交，丢弃所有更改
$ git reset --hard HEAD~1

# 重置到指定提交
$ git reset --hard abc1234
```

**警告**：`--hard` 会永久丢失未提交的更改！

## 4. 重置文件

```sh
# 从暂存区移除文件（保留工作区）
$ git reset HEAD file.txt

# 重置文件到指定提交
$ git reset HEAD~1 -- file.txt
```

## 5. 重置到远程分支

```sh
# 重置到远程分支状态
$ git fetch origin
$ git reset --hard origin/main
```

# 实际应用场景

## 场景1：撤销最后一次提交（保留更改）

```sh
# 撤销提交，保留更改在暂存区
$ git reset --soft HEAD~1

# 可以修改后重新提交
$ git commit -m "Updated commit message"
```

## 场景2：取消暂存

```sh
# 从暂存区移除文件
$ git reset HEAD file.txt

# 或使用 git restore（Git 2.23+）
$ git restore --staged file.txt
```

## 场景3：回退到之前的提交

```sh
# 回退到上一个提交（保留工作区）
$ git reset HEAD~1

# 查看状态
$ git status
```

## 场景4：完全重置（危险）

```sh
# 完全重置到远程状态（会丢失本地更改）
$ git fetch origin
$ git reset --hard origin/main
```

## 场景5：重置特定文件

```sh
# 重置文件到上一个提交的状态
$ git reset HEAD~1 -- file.txt

# 重置文件到指定提交
$ git reset abc1234 -- file.txt
```

# 常见问题和解决方案

## 问题1：误用了 --hard

**解决方案**：
```sh
# 使用 reflog 找回
$ git reflog

# 找到重置前的提交
$ git reset --hard abc1234
```

## 问题2：想保留工作区的更改

**解决方案**：
```sh
# 使用 --soft 或默认（--mixed）
$ git reset --soft HEAD~1  # 保留在暂存区
$ git reset HEAD~1         # 保留在工作区
```

## 问题3：重置后想恢复

**解决方案**：
```sh
# 使用 reflog 查看历史
$ git reflog

# 恢复到重置前的状态
$ git reset --hard HEAD@{1}
```

# 最佳实践

## 1. 谨慎使用 --hard

```sh
# ❌ 危险：会丢失未提交的更改
$ git reset --hard HEAD~1

# ✅ 安全：先检查状态
$ git status
$ git reset --soft HEAD~1
```

## 2. 重置前备份

```sh
# 创建备份分支
$ git branch backup-branch

# 然后重置
$ git reset HEAD~1
```

## 3. 使用 reflog 作为安全网

```sh
# reflog 会记录所有操作
$ git reflog

# 可以恢复到任何状态
$ git reset --hard HEAD@{n}
```

## 4. 只对本地提交使用

```sh
# ✅ 可以：本地未推送的提交
$ git reset HEAD~1

# ❌ 不要：已推送的提交（使用 revert）
$ git revert HEAD
```

# 总结

`git reset` 是回退提交的强大命令：

1. **--soft**：只重置 HEAD，保留更改
2. **--mixed**：重置 HEAD 和暂存区，保留工作区
3. **--hard**：完全重置（危险！）
4. **文件重置**：可以重置特定文件

**关键要点**：
- ✅ 谨慎使用 `--hard`，会丢失更改
- ✅ 使用 `--soft` 或默认模式保留更改
- ✅ 使用 reflog 恢复误操作
- ✅ 只对本地未推送的提交使用 reset
- ❌ 不要对已推送的提交使用 reset（使用 revert）

