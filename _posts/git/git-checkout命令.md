---
author: djaigo
title: git-checkout命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git checkout 命令

## 简介

`git checkout` 是 Git 中一个功能强大的命令，主要用于切换分支、创建新分支、恢复文件以及检出特定提交。它是 Git 中最常用的命令之一。

## 基本概念

`git checkout` 主要有两个用途：
1. **切换分支**：在不同的分支之间切换
2. **恢复文件**：将文件恢复到特定版本

## 命令语法

```sh
# 切换分支
git checkout [选项] <分支名>

# 创建并切换分支
git checkout -b <新分支名> [起始点]

# 恢复文件
git checkout [选项] [--] <文件>...

# 检出特定提交
git checkout [选项] <提交>
```

## 查看帮助文档

```sh
$ git checkout --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-b <分支名>` | 创建新分支并切换过去 |
| `-B <分支名>` | 创建或重置分支并切换过去 |
| `-f, --force` | 强制切换，丢弃本地更改 |
| `-q, --quiet` | 静默模式，减少输出 |
| `--track` | 设置上游分支跟踪 |
| `--no-track` | 不设置上游分支跟踪 |
| `-l, --create-reflog` | 为新分支创建 reflog |
| `--orphan <分支名>` | 创建孤立分支（无父提交） |
| `--detach` | 分离 HEAD（检出提交而非分支） |
| `--ours` | 在合并冲突时使用我们的版本 |
| `--theirs` | 在合并冲突时使用他们的版本 |
| `-p, --patch` | 交互式选择要恢复的更改 |
| `--` | 分隔选项和路径 |

# 切换分支

## 基本切换

```sh
# 切换到已存在的分支
$ git checkout main

# 切换到其他分支
$ git checkout develop

# 切换到远程分支（会自动创建跟踪分支）
$ git checkout origin/feature-branch
```

## 创建新分支并切换

```sh
# 从当前分支创建新分支
$ git checkout -b feature/new-feature

# 从指定分支创建新分支
$ git checkout -b feature/new-feature main

# 从指定提交创建新分支
$ git checkout -b hotfix abc1234

# 从远程分支创建本地分支
$ git checkout -b local-branch origin/remote-branch
```

## 强制切换

```sh
# 强制切换，丢弃本地未提交的更改
$ git checkout -f main

# 或使用长选项
$ git checkout --force develop
```

**警告**：使用 `-f` 会丢失未提交的更改，请谨慎使用！

## 重置并切换分支

```sh
# 如果分支存在则重置，不存在则创建
$ git checkout -B branch-name

# 从指定提交重置分支
$ git checkout -B branch-name commit-hash
```

## 跟踪远程分支

```sh
# 创建跟踪分支（自动设置上游）
$ git checkout --track origin/feature-branch

# 创建跟踪分支并指定本地名称
$ git checkout -b local-name --track origin/remote-name

# 不跟踪远程分支
$ git checkout --no-track -b local-branch origin/remote-branch
```

## 查看分支信息

```sh
# 切换分支时显示详细信息
$ git checkout -v main

# 查看所有分支
$ git branch -a

# 查看当前分支
$ git branch --show-current
```

# 恢复文件

## 恢复工作区文件

```sh
# 恢复单个文件到最后一次提交的状态
$ git checkout -- README.md

# 恢复多个文件
$ git checkout -- file1.txt file2.txt

# 恢复整个目录
$ git checkout -- src/

# 使用 -- 明确指定文件（推荐）
$ git checkout -- README.md
```

## 从特定提交恢复文件

```sh
# 从最后一次提交恢复
$ git checkout HEAD -- README.md

# 从指定提交恢复
$ git checkout abc1234 -- README.md

# 从指定分支恢复
$ git checkout main -- README.md

# 从远程分支恢复
$ git checkout origin/main -- README.md
```

## 交互式恢复

```sh
# 交互式选择要恢复的更改
$ git checkout -p README.md

# 交互式恢复所有文件
$ git checkout -p
```

## 恢复暂存区文件

```sh
# 从暂存区恢复文件（取消暂存）
$ git restore --staged README.md

# 注意：git checkout 不能直接取消暂存
# 需要使用 git restore 或 git reset
```

# 检出特定提交

## 分离 HEAD 状态

```sh
# 检出特定提交（进入分离 HEAD 状态）
$ git checkout abc1234

# 检出标签
$ git checkout v1.0.0

# 检出远程分支的提交
$ git checkout origin/main
```

**注意**：在分离 HEAD 状态下，任何提交都不会属于任何分支。如果需要保留更改，应该创建新分支。

## 从分离状态创建分支

```sh
# 在分离 HEAD 状态下创建分支
$ git checkout -b new-branch

# 或直接创建并切换
$ git checkout -b fix-bug abc1234
```

# 高级用法

## 创建孤立分支

```sh
# 创建没有历史记录的新分支
$ git checkout --orphan new-branch

# 这会创建一个全新的分支，没有任何提交历史
# 适合创建全新的项目或文档分支
```

## 使用 reflog

```sh
# 为新分支创建 reflog（默认不创建）
$ git checkout -l -b new-branch

# 查看 reflog
$ git reflog
```

## 合并冲突时选择版本

```sh
# 在合并冲突时，使用我们的版本
$ git checkout --ours conflicted-file.txt

# 使用他们的版本
$ git checkout --theirs conflicted-file.txt

# 然后添加到暂存区
$ git add conflicted-file.txt
```

## 批量恢复文件

```sh
# 恢复所有修改的文件
$ git checkout .

# 恢复特定类型的文件
$ git checkout -- '*.txt'

# 恢复特定目录
$ git checkout -- src/
```

# 实际应用场景

## 场景1：日常分支切换

```sh
# 切换到主分支
$ git checkout main

# 切换到功能分支
$ git checkout feature/login

# 切换回上一个分支
$ git checkout -
```

## 场景2：创建功能分支

```sh
# 从主分支创建新功能分支
$ git checkout main
$ git pull origin main
$ git checkout -b feature/user-profile

# 或一步完成
$ git checkout -b feature/user-profile origin/main
```

## 场景3：修复紧急 bug

```sh
# 从主分支创建热修复分支
$ git checkout main
$ git checkout -b hotfix/critical-bug

# 修复后提交
$ git add .
$ git commit -m "Fix critical bug"

# 切换回主分支并合并
$ git checkout main
$ git merge hotfix/critical-bug
```

## 场景4：恢复误删的文件

```sh
# 恢复误删的文件
$ git checkout HEAD -- deleted-file.txt

# 从特定提交恢复
$ git checkout abc1234 -- deleted-file.txt
```

## 场景5：撤销文件更改

```sh
# 撤销工作区的更改
$ git checkout -- modified-file.txt

# 查看要恢复的文件
$ git status
$ git checkout -- file1.txt file2.txt
```

## 场景6：查看历史版本

```sh
# 查看特定提交的代码
$ git checkout abc1234

# 查看后返回原分支
$ git checkout main

# 或创建临时分支查看
$ git checkout -b temp-view abc1234
```

## 场景7：同步远程分支

```sh
# 获取远程更新
$ git fetch origin

# 切换到远程分支（自动创建跟踪分支）
$ git checkout feature-branch

# 如果本地分支已存在，设置跟踪
$ git checkout -b local-branch --track origin/remote-branch
```

## 场景8：处理合并冲突

```sh
# 合并时发生冲突
$ git merge feature-branch

# 查看冲突文件
$ git status

# 选择使用我们的版本
$ git checkout --ours conflicted-file.txt
$ git add conflicted-file.txt

# 或使用他们的版本
$ git checkout --theirs conflicted-file.txt
$ git add conflicted-file.txt
```

## 场景9：创建发布分支

```sh
# 从标签创建发布分支
$ git checkout -b release/v1.0.0 v1.0.0

# 或从主分支创建
$ git checkout -b release/v1.0.0 main
```

## 场景10：实验性更改

```sh
# 创建实验分支
$ git checkout -b experiment/new-approach

# 进行实验
# ...

# 如果实验失败，切换回主分支
$ git checkout main
$ git branch -D experiment/new-approach
```

# 与其他命令的组合

## git checkout + git branch

```sh
# 查看所有分支
$ git branch -a

# 创建并切换分支
$ git checkout -b new-branch

# 删除分支（需要先切换到其他分支）
$ git checkout main
$ git branch -D old-branch
```

## git checkout + git fetch

```sh
# 获取远程更新
$ git fetch origin

# 切换到远程分支
$ git checkout feature-branch
```

## git checkout + git stash

```sh
# 如果有未提交的更改，先暂存
$ git stash

# 切换分支
$ git checkout other-branch

# 切换回来后恢复
$ git checkout original-branch
$ git stash pop
```

## git checkout + git merge

```sh
# 切换到主分支
$ git checkout main

# 合并功能分支
$ git merge feature-branch
```

# 常见问题和解决方案

## 问题1：有未提交的更改无法切换分支

**错误信息**：
```
error: Your local changes to the following files would be overwritten by checkout
```

**解决方案**：
```sh
# 方案1：提交更改
$ git add .
$ git commit -m "Save changes"
$ git checkout other-branch

# 方案2：暂存更改
$ git stash
$ git checkout other-branch
$ git stash pop

# 方案3：强制切换（会丢失更改）
$ git checkout -f other-branch

# 方案4：恢复文件
$ git checkout -- modified-file.txt
$ git checkout other-branch
```

## 问题2：分离 HEAD 状态

**问题**：检出了提交而非分支，处于分离 HEAD 状态

**解决方案**：
```sh
# 创建新分支保存更改
$ git checkout -b new-branch-name

# 或切换回分支
$ git checkout main
```

## 问题3：分支不存在

**错误信息**：
```
error: pathspec 'branch-name' did not match any file(s) known to git
```

**解决方案**：
```sh
# 检查分支是否存在
$ git branch -a

# 如果远程存在，创建跟踪分支
$ git checkout -b local-branch origin/remote-branch

# 或先获取
$ git fetch origin
$ git checkout branch-name
```

## 问题4：文件名冲突

**问题**：分支名和文件名相同

**解决方案**：
```sh
# 使用 -- 明确指定是分支
$ git checkout -- branch-name

# 或使用完整路径
$ git checkout refs/heads/branch-name
```

## 问题5：无法删除当前分支

**错误信息**：
```
error: Cannot delete branch 'branch-name' checked out at '/path'
```

**解决方案**：
```sh
# 先切换到其他分支
$ git checkout main

# 然后删除
$ git branch -D branch-name
```

## 问题6：恢复文件后仍显示为修改

**问题**：使用 `git checkout -- file` 后，文件仍显示为修改

**解决方案**：
```sh
# 检查文件状态
$ git status

# 可能需要恢复暂存区
$ git restore --staged file.txt
$ git restore file.txt

# 或使用 git reset
$ git reset HEAD file.txt
$ git checkout -- file.txt
```

# 最佳实践

## 1. 切换分支前检查状态

```sh
# 切换前查看状态
$ git status

# 有未提交更改时先处理
$ git stash
# 或
$ git commit -m "WIP"
```

## 2. 使用描述性的分支名

```sh
# ✅ 好的分支名
$ git checkout -b feature/user-authentication
$ git checkout -b bugfix/login-error
$ git checkout -b hotfix/security-patch

# ❌ 不好的分支名
$ git checkout -b test
$ git checkout -b fix
$ git checkout -b new
```

## 3. 定期同步远程分支

```sh
# 获取远程更新
$ git fetch origin

# 切换到远程分支
$ git checkout feature-branch

# 或创建跟踪分支
$ git checkout -b local-branch --track origin/remote-branch
```

## 4. 恢复文件时使用 --

```sh
# ✅ 推荐：明确指定文件
$ git checkout -- README.md

# ⚠️ 可能混淆：如果分支名和文件名相同
$ git checkout README.md  # 可能是分支名
```

## 5. 避免在分离 HEAD 状态下工作

```sh
# ❌ 不推荐：在分离 HEAD 状态下提交
$ git checkout abc1234
$ git commit -m "Changes"  # 这些提交不属于任何分支

# ✅ 推荐：创建分支后再工作
$ git checkout -b temp-branch abc1234
$ git commit -m "Changes"
```

## 6. 使用 git switch 和 git restore（Git 2.23+）

Git 2.23 引入了新命令来分离 `git checkout` 的功能：

```sh
# 切换分支（推荐使用 git switch）
$ git switch main
$ git switch -c new-branch

# 恢复文件（推荐使用 git restore）
$ git restore README.md
$ git restore --staged README.md
```

## 7. 创建分支时指定起始点

```sh
# ✅ 明确指定起始点
$ git checkout -b feature/new main

# ✅ 从远程分支创建
$ git checkout -b local origin/remote

# ❌ 不明确（从当前分支创建，可能不是想要的）
$ git checkout -b feature/new
```

## 8. 处理合并冲突

```sh
# 查看冲突
$ git status

# 选择版本
$ git checkout --ours file.txt
# 或
$ git checkout --theirs file.txt

# 添加到暂存区
$ git add file.txt
```

# git checkout vs git switch vs git restore

## Git 2.23+ 的新命令

Git 2.23 引入了 `git switch` 和 `git restore` 来替代 `git checkout` 的部分功能：

| 功能 | 旧命令 | 新命令（推荐） |
|------|--------|---------------|
| 切换分支 | `git checkout branch` | `git switch branch` |
| 创建分支 | `git checkout -b branch` | `git switch -c branch` |
| 恢复文件 | `git checkout -- file` | `git restore file` |
| 取消暂存 | `git reset HEAD file` | `git restore --staged file` |

## 使用建议

- **Git 2.23+**：优先使用 `git switch` 和 `git restore`
- **旧版本 Git**：继续使用 `git checkout`
- **兼容性**：`git checkout` 仍然可用，不会被移除

# 常用别名

```sh
# 创建别名简化命令
$ git config --global alias.co checkout
$ git config --global alias.cob 'checkout -b'
$ git config --global alias.sw 'switch'
$ git config --global alias.rs 'restore'

# 使用别名
$ git co main
$ git cob feature/new
$ git sw main
$ git rs README.md
```

# 总结

`git checkout` 是 Git 中最常用的命令之一，掌握它可以帮助你：

1. **切换分支**：在不同分支之间自由切换
2. **创建分支**：快速创建新的工作分支
3. **恢复文件**：撤销文件更改或恢复误删文件
4. **查看历史**：检出特定提交查看历史版本
5. **处理冲突**：在合并冲突时选择版本

虽然 Git 2.23+ 引入了 `git switch` 和 `git restore` 来分离功能，但 `git checkout` 仍然是最广泛使用的命令，理解它的各种用法对于 Git 工作流至关重要。

