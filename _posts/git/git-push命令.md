---
author: djaigo
title: git-push命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git push 命令

## 简介

`git push` 是 Git 中用于将本地提交推送到远程仓库的命令。它是将本地更改共享到远程仓库的主要方式。

## 基本概念

### 什么是推送

推送是将本地分支的提交上传到远程仓库的过程。它使其他开发者可以访问你的更改。

### 推送的前提条件

1. 本地有新的提交
2. 已配置远程仓库
3. 有推送权限

## 命令语法

```sh
# 基本推送
git push [远程仓库] [分支名]

# 推送当前分支
git push

# 推送所有分支
git push --all

# 推送标签
git push --tags
```

## 查看帮助文档

```sh
$ git push --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-u, --set-upstream` | 设置上游分支并推送 |
| `--all` | 推送所有分支 |
| `--tags` | 推送所有标签 |
| `--force, -f` | 强制推送（覆盖远程） |
| `--force-with-lease` | 更安全的强制推送 |
| `--delete` | 删除远程分支 |
| `--dry-run` | 预览模式，不实际推送 |
| `-v, --verbose` | 详细输出 |
| `-q, --quiet` | 静默模式 |
| `--no-verify` | 跳过 pre-push 钩子 |
| `--follow-tags` | 推送提交时同时推送相关标签 |
| `--mirror` | 镜像推送（推送所有引用） |

# 基本使用

## 1. 基本推送

```sh
# 推送当前分支到远程
$ git push

# 推送到指定远程和分支
$ git push origin main

# 首次推送并设置上游
$ git push -u origin main
```

## 2. 推送所有分支

```sh
# 推送所有分支
$ git push --all origin

# 推送所有分支和标签
$ git push --all --tags origin
```

## 3. 推送标签

```sh
# 推送所有标签
$ git push --tags origin

# 推送单个标签
$ git push origin v1.0.0

# 推送提交时同时推送相关标签
$ git push --follow-tags origin
```

## 4. 删除远程分支

```sh
# 删除远程分支
$ git push origin --delete branch-name

# 或使用
$ git push origin :branch-name
```

## 5. 强制推送

```sh
# 强制推送（危险，会覆盖远程）
$ git push --force origin main

# 更安全的强制推送（推荐）
$ git push --force-with-lease origin main
```

**警告**：强制推送会覆盖远程历史，请谨慎使用！

## 6. 预览推送

```sh
# 预览将要推送的内容
$ git push --dry-run origin main
```

# 实际应用场景

## 场景1：首次推送

```sh
# 创建新分支
$ git checkout -b feature/new-feature

# 提交更改
$ git add .
$ git commit -m "Add new feature"

# 首次推送并设置上游
$ git push -u origin feature/new-feature
```

## 场景2：常规推送

```sh
# 提交更改后推送
$ git add .
$ git commit -m "Update feature"
$ git push
```

## 场景3：推送标签

```sh
# 创建标签
$ git tag v1.0.0

# 推送标签
$ git push origin v1.0.0

# 或推送所有标签
$ git push --tags origin
```

## 场景4：删除远程分支

```sh
# 删除已合并的功能分支
$ git push origin --delete feature/old-feature
```

## 场景5：强制推送（谨慎使用）

```sh
# 在 rebase 后需要强制推送
$ git rebase main
$ git push --force-with-lease origin feature-branch
```

# 常见问题和解决方案

## 问题1：推送被拒绝

**错误信息**：
```
! [rejected]        main -> main (non-fast-forward)
```

**解决方案**：
```sh
# 先拉取远程更新
$ git pull origin main

# 解决冲突后推送
$ git push origin main

# 或使用 rebase
$ git pull --rebase origin main
$ git push origin main
```

## 问题2：需要认证

**解决方案**：
```sh
# HTTPS：配置凭据
$ git config --global credential.helper store

# SSH：配置 SSH 密钥
$ ssh-keygen -t ed25519 -C "your_email@example.com"
```

## 问题3：推送失败（权限不足）

**解决方案**：
```sh
# 检查远程仓库配置
$ git remote -v

# 确认有推送权限
# 联系仓库管理员添加权限
```

## 问题4：推送了错误的提交

**解决方案**：
```sh
# 如果还没有其他人拉取，可以强制推送
$ git reset HEAD~1
$ git push --force-with-lease origin main

# 如果已经有人拉取，使用 revert
$ git revert HEAD
$ git push origin main
```

# 最佳实践

## 1. 使用 --force-with-lease

```sh
# ✅ 推荐：更安全的强制推送
$ git push --force-with-lease origin main

# ❌ 不推荐：可能覆盖其他人的提交
$ git push --force origin main
```

## 2. 首次推送设置上游

```sh
# 首次推送时设置上游
$ git push -u origin branch-name

# 之后可以直接使用
$ git push
```

## 3. 推送前检查

```sh
# 推送前查看状态
$ git status
$ git log origin/main..HEAD

# 预览推送
$ git push --dry-run origin main
```

## 4. 不要强制推送共享分支

```sh
# ❌ 不要对共享分支使用 force push
$ git push --force origin main  # 危险！

# ✅ 只对个人功能分支使用
$ git push --force-with-lease origin feature/my-branch
```

## 5. 推送前同步

```sh
# 推送前先拉取
$ git pull origin main
$ git push origin main
```

# 总结

`git push` 是将本地更改共享到远程仓库的关键命令：

1. **基本用法**：`git push origin branch` 推送分支
2. **首次推送**：`git push -u origin branch` 设置上游
3. **强制推送**：`git push --force-with-lease` 更安全
4. **推送标签**：`git push --tags` 推送所有标签

**关键要点**：
- ✅ 使用 `--force-with-lease` 而不是 `--force`
- ✅ 首次推送时设置上游
- ✅ 推送前先同步远程更新
- ✅ 不要强制推送共享分支
- ❌ 不要强制推送可能影响其他人的提交

