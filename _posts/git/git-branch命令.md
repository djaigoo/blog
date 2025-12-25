---
author: djaigo
title: git-branch命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git branch 命令

## 简介

`git branch` 是 Git 中用于管理分支的命令。分支是 Git 的核心功能之一，允许你在不同的开发线上并行工作，而不会相互干扰。

## 基本概念

### 什么是分支

分支是 Git 中指向提交的指针。每个分支代表一条独立的开发线，可以在不影响其他分支的情况下进行开发。

### 分支的作用

1. **并行开发**：多个功能可以同时开发
2. **实验性更改**：在不影响主分支的情况下尝试新功能
3. **版本管理**：维护不同的版本（如稳定版、开发版）
4. **功能隔离**：每个功能在独立分支上开发

## 命令语法

```sh
# 列出分支
git branch [选项]

# 创建分支
git branch <分支名> [起始点]

# 删除分支
git branch -d <分支名>
git branch -D <分支名>  # 强制删除

# 重命名分支
git branch -m <旧名称> <新名称>
git branch -m <新名称>  # 重命名当前分支

# 查看分支信息
git branch -v
git branch -vv  # 显示跟踪信息
```

## 查看帮助文档

```sh
$ git branch --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-a, --all` | 显示所有分支（本地和远程） |
| `-r, --remotes` | 只显示远程分支 |
| `-v, --verbose` | 显示详细信息（最后提交） |
| `-vv` | 显示详细信息（包括跟踪分支） |
| `-d, --delete` | 删除分支（需要分支已合并） |
| `-D` | 强制删除分支（即使未合并） |
| `-m, --move` | 重命名分支 |
| `-M` | 强制重命名分支 |
| `-c, --copy` | 复制分支 |
| `-C` | 强制复制分支 |
| `--set-upstream` | 设置上游分支 |
| `--unset-upstream` | 取消上游分支设置 |
| `--track` | 创建跟踪分支 |
| `--no-track` | 不创建跟踪分支 |
| `--merged` | 只显示已合并的分支 |
| `--no-merged` | 只显示未合并的分支 |
| `-l, --list` | 列出分支（默认行为） |
| `--contains <commit>` | 只显示包含指定提交的分支 |
| `--no-contains <commit>` | 只显示不包含指定提交的分支 |

# 基本使用

## 1. 列出分支

```sh
# 列出本地分支
$ git branch

# 列出所有分支（本地和远程）
$ git branch -a

# 只列出远程分支
$ git branch -r

# 显示详细信息
$ git branch -v

# 显示详细信息（包括跟踪分支）
$ git branch -vv
```

**示例输出**：
```
* main
  develop
  feature/login
  remotes/origin/main
  remotes/origin/develop
```

`*` 表示当前所在的分支。

## 2. 创建分支

```sh
# 从当前分支创建新分支
$ git branch feature/new-feature

# 从指定分支创建新分支
$ git branch feature/new-feature main

# 从指定提交创建新分支
$ git branch hotfix abc1234

# 从标签创建分支
$ git branch release/v1.0.0 v1.0.0

# 创建并切换到新分支（使用 git checkout 或 git switch）
$ git checkout -b feature/new-feature
$ git switch -c feature/new-feature
```

## 3. 删除分支

```sh
# 删除已合并的分支
$ git branch -d feature/old-feature

# 强制删除分支（即使未合并）
$ git branch -D feature/old-feature

# 删除远程分支（需要推送）
$ git push origin --delete feature/old-feature
```

**注意**：
- 不能删除当前所在的分支
- `-d` 只能删除已合并的分支
- `-D` 可以强制删除，但会丢失未合并的更改

## 4. 重命名分支

```sh
# 重命名当前分支
$ git branch -m new-branch-name

# 重命名指定分支（需要先切换到其他分支）
$ git checkout main
$ git branch -m old-name new-name

# 强制重命名（覆盖已存在的分支）
$ git branch -M new-name
```

## 5. 查看分支信息

```sh
# 查看所有分支的详细信息
$ git branch -v

# 查看跟踪信息
$ git branch -vv

# 查看已合并的分支
$ git branch --merged

# 查看未合并的分支
$ git branch --no-merged

# 查看包含特定提交的分支
$ git branch --contains abc1234
```

## 6. 设置跟踪分支

```sh
# 设置上游分支
$ git branch --set-upstream-to=origin/main main

# 创建跟踪分支
$ git branch --track local-branch origin/remote-branch

# 取消跟踪
$ git branch --unset-upstream
```

# 高级用法

## 1. 复制分支

```sh
# 复制分支
$ git branch -c source-branch new-branch

# 强制复制（覆盖已存在的分支）
$ git branch -C source-branch new-branch
```

## 2. 基于特定提交创建分支

```sh
# 从提交创建分支
$ git branch feature/fix abc1234

# 从相对引用创建
$ git branch hotfix HEAD~3
```

## 3. 列出特定条件下的分支

```sh
# 列出已合并到 main 的分支
$ git branch --merged main

# 列出未合并到 main 的分支
$ git branch --no-merged main

# 列出包含特定提交的分支
$ git branch --contains feature-commit

# 列出不包含特定提交的分支
$ git branch --no-contains bug-commit
```

## 4. 批量操作

```sh
# 删除所有已合并的分支（除了当前分支和 main）
$ git branch --merged | grep -v "\*\|main" | xargs git branch -d

# 删除所有远程已删除的本地分支
$ git remote prune origin
$ git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
```

# 实际应用场景

## 场景1：创建功能分支

```sh
# 从主分支创建功能分支
$ git checkout main
$ git pull origin main
$ git branch feature/user-profile
$ git checkout feature/user-profile

# 或一步完成
$ git checkout -b feature/user-profile main
```

## 场景2：清理已合并的分支

```sh
# 查看已合并的分支
$ git branch --merged

# 删除已合并的分支
$ git branch -d feature/old-feature-1
$ git branch -d feature/old-feature-2

# 批量删除
$ git branch --merged | grep feature/ | xargs git branch -d
```

## 场景3：重命名分支

```sh
# 重命名当前分支
$ git branch -m feature/new-name

# 重命名其他分支
$ git checkout main
$ git branch -m feature/old-name feature/new-name
```

## 场景4：查看分支关系

```sh
# 查看所有分支及其跟踪关系
$ git branch -vv

# 查看分支图
$ git log --oneline --graph --all --decorate
```

## 场景5：创建发布分支

```sh
# 从标签创建发布分支
$ git branch release/v1.0.0 v1.0.0

# 从主分支创建发布分支
$ git checkout -b release/v1.0.0 main
```

## 场景6：设置跟踪分支

```sh
# 创建跟踪分支
$ git branch --track local-feature origin/feature

# 设置现有分支的跟踪
$ git branch --set-upstream-to=origin/main main
```

# 与其他命令的组合

## git branch + git checkout

```sh
# 创建并切换分支
$ git checkout -b new-branch

# 或使用 git switch（Git 2.23+）
$ git switch -c new-branch
```

## git branch + git merge

```sh
# 合并分支后删除
$ git checkout main
$ git merge feature-branch
$ git branch -d feature-branch
```

## git branch + git push

```sh
# 推送新分支到远程
$ git branch feature/new
$ git push -u origin feature/new

# 删除远程分支
$ git push origin --delete feature/old
```

# 常见问题和解决方案

## 问题1：无法删除当前分支

**错误信息**：
```
error: Cannot delete branch 'branch-name' checked out at '/path'
```

**解决方案**：
```sh
# 先切换到其他分支
$ git checkout main
$ git branch -d branch-name
```

## 问题2：分支未合并无法删除

**错误信息**：
```
error: The branch 'branch-name' is not fully merged
```

**解决方案**：
```sh
# 方案1：先合并分支
$ git merge branch-name
$ git branch -d branch-name

# 方案2：强制删除（会丢失未合并的更改）
$ git branch -D branch-name
```

## 问题3：分支名冲突

**问题**：本地和远程有同名分支但内容不同

**解决方案**：
```sh
# 重命名本地分支
$ git branch -m local-branch-name

# 或使用不同的命名规范
$ git branch feature/local-feature
```

## 问题4：查看远程分支

**问题**：看不到远程分支

**解决方案**：
```sh
# 先获取远程信息
$ git fetch origin

# 查看远程分支
$ git branch -r

# 查看所有分支
$ git branch -a
```

## 问题5：跟踪分支未设置

**问题**：推送时提示未设置上游分支

**解决方案**：
```sh
# 设置跟踪分支
$ git branch --set-upstream-to=origin/branch-name branch-name

# 或推送时设置
$ git push -u origin branch-name
```

# 最佳实践

## 1. 使用描述性的分支名

```sh
# ✅ 好的分支名
$ git branch feature/user-authentication
$ git branch bugfix/login-error
$ git branch hotfix/security-patch

# ❌ 不好的分支名
$ git branch test
$ git branch fix
$ git branch new
```

## 2. 定期清理已合并的分支

```sh
# 定期清理已合并的分支
$ git branch --merged | grep -v "\*\|main\|develop" | xargs git branch -d
```

## 3. 使用分支保护

```sh
# 重要分支（如 main）应该设置保护
# 这通常在 Git 托管平台（GitHub、GitLab）上配置
```

## 4. 保持分支同步

```sh
# 定期同步主分支
$ git checkout main
$ git pull origin main

# 更新功能分支
$ git checkout feature-branch
$ git rebase main
```

## 5. 使用分支命名规范

常见的命名规范：
- `feature/功能名`：新功能
- `bugfix/问题描述`：bug 修复
- `hotfix/紧急修复`：紧急修复
- `release/版本号`：发布分支
- `develop`：开发分支
- `main/master`：主分支

## 6. 删除远程分支

```sh
# 删除远程分支
$ git push origin --delete branch-name

# 清理本地对已删除远程分支的引用
$ git remote prune origin
```

# 总结

`git branch` 是 Git 分支管理的核心命令，掌握它可以帮助你：

1. **创建分支**：为不同功能创建独立分支
2. **查看分支**：了解所有分支的状态
3. **删除分支**：清理不需要的分支
4. **管理分支**：重命名、复制、设置跟踪

**关键要点**：
- ✅ 使用描述性的分支名
- ✅ 定期清理已合并的分支
- ✅ 保持分支同步
- ✅ 遵循分支命名规范
- ❌ 不要删除未合并的重要分支
- ❌ 不要强制删除可能包含重要更改的分支

通过合理使用 `git branch`，可以更好地组织和管理 Git 仓库的分支结构。

