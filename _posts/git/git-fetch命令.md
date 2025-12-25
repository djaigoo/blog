---
author: djaigo
title: git-fetch命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git fetch 命令

## 简介

`git fetch` 是 Git 中用于从远程仓库获取最新更改的命令。与 `git pull` 不同，`git fetch` 只获取更改，不会自动合并到当前分支。

## 基本概念

### Fetch vs Pull

| 特性 | Fetch | Pull |
|------|-------|------|
| **操作** | 只获取，不合并 | 获取并合并 |
| **工作区** | 不改变工作区 | 自动合并到工作区 |
| **安全性** | 更安全，可以先检查 | 可能直接产生冲突 |
| **使用场景** | 需要检查后再合并 | 快速同步 |

### Fetch 的作用

1. 从远程获取最新提交
2. 更新远程分支引用
3. 不改变当前工作区
4. 可以安全地查看远程更改

## 命令语法

```sh
# 获取所有远程更新
git fetch [远程仓库]

# 获取指定远程
git fetch origin

# 获取指定分支
git fetch origin main
```

## 查看帮助文档

```sh
$ git fetch --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `--all` | 获取所有远程仓库的更新 |
| `-p, --prune` | 删除已不存在的远程分支引用 |
| `--tags` | 获取所有标签 |
| `--dry-run` | 预览模式，不实际获取 |
| `-v, --verbose` | 详细输出 |
| `-q, --quiet` | 静默模式 |
| `--unshallow` | 将浅仓库转换为完整仓库 |
| `--depth=<n>` | 浅获取，只获取最近 n 次提交 |

# 基本使用

## 1. 基本获取

```sh
# 获取默认远程（origin）的更新
$ git fetch

# 获取指定远程的更新
$ git fetch origin

# 获取指定分支
$ git fetch origin main
```

## 2. 获取所有远程

```sh
# 获取所有远程仓库的更新
$ git fetch --all
```

## 3. 清理已删除的远程分支

```sh
# 获取并清理已删除的远程分支引用
$ git fetch -p

# 或使用
$ git fetch --prune
```

## 4. 获取标签

```sh
# 获取所有标签
$ git fetch --tags origin

# 获取时包含标签
$ git fetch origin --tags
```

## 5. 浅获取

```sh
# 只获取最近 10 次提交
$ git fetch --depth=10 origin
```

# 实际应用场景

## 场景1：检查远程更新

```sh
# 获取远程更新
$ git fetch origin

# 查看远程分支的更改
$ git log HEAD..origin/main

# 决定是否合并
$ git merge origin/main
```

## 场景2：同步所有远程

```sh
# 获取所有远程的更新
$ git fetch --all
```

## 场景3：清理远程分支引用

```sh
# 获取并清理已删除的远程分支
$ git fetch -p origin
```

## 场景4：查看远程分支

```sh
# 获取远程更新
$ git fetch origin

# 查看所有远程分支
$ git branch -r

# 查看远程分支详情
$ git branch -rv
```

## 场景5：比较本地和远程

```sh
# 获取远程更新
$ git fetch origin

# 比较本地和远程
$ git diff main origin/main

# 查看远程的提交
$ git log origin/main --oneline
```

# 常见问题和解决方案

## 问题1：看不到远程分支

**解决方案**：
```sh
# 先获取远程更新
$ git fetch origin

# 查看远程分支
$ git branch -r
```

## 问题2：远程分支已删除但本地仍显示

**解决方案**：
```sh
# 清理已删除的远程分支引用
$ git fetch -p origin

# 或使用
$ git remote prune origin
```

## 问题3：获取速度慢

**解决方案**：
```sh
# 使用浅获取
$ git fetch --depth=10 origin

# 或只获取特定分支
$ git fetch origin main
```

# 最佳实践

## 1. 定期 Fetch

```sh
# 开始工作前获取更新
$ git fetch origin

# 查看更新
$ git log HEAD..origin/main
```

## 2. 使用 Prune 清理

```sh
# 获取时自动清理
$ git fetch -p origin
```

## 3. Fetch 后检查再合并

```sh
# ✅ 推荐：先 fetch 检查
$ git fetch origin
$ git log HEAD..origin/main
$ git merge origin/main

# ⚠️ 也可以：直接 pull（但可能产生意外冲突）
$ git pull origin main
```

# 总结

`git fetch` 是安全获取远程更新的方式：

1. **基本用法**：`git fetch origin` 获取远程更新
2. **清理引用**：`git fetch -p` 清理已删除的远程分支
3. **查看更新**：fetch 后可以安全地查看远程更改
4. **安全合并**：检查后再决定是否合并

**关键要点**：
- ✅ 使用 fetch 安全地获取更新
- ✅ fetch 后检查再合并
- ✅ 使用 `-p` 清理已删除的远程分支
- ✅ 定期 fetch 保持同步

