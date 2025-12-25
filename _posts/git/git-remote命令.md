---
author: djaigo
title: git-remote命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
date: 2021-01-04 13:50:48
---

# git remote 命令

## 简介

`git remote` 命令用于管理远程仓库的引用。它允许你查看、添加、删除和修改远程仓库的配置。远程仓库是托管在服务器上的 Git 仓库，你可以通过 `git push` 和 `git pull` 与它们交互。

## 基本概念

- **远程仓库（Remote）**：托管在服务器上的 Git 仓库
- **远程名称（Remote Name）**：本地仓库中远程仓库的别名，默认为 `origin`
- **URL**：远程仓库的地址，可以是 HTTPS、SSH 或 Git 协议

## 命令语法

```sh
git remote [-v | --verbose]
git remote add [选项] <name> <url>
git remote rename <old> <new>
git remote remove <name>
git remote set-head <name> (-a | --auto | -d | --delete | <branch>)
git remote show [-n] <name>
git remote prune [-n | --dry-run] <name>
git remote update [-p | --prune] [(<group> | <remote>)...]
git remote set-branches [--add] <name> <branch>...
git remote get-url [--push] [--all] <name>
git remote set-url [--push] <name> <newurl> [<oldurl>]
git remote set-url --add <name> <newurl>
git remote set-url --delete <name> <url>
```

## 查看帮助文档

```sh
$ git remote -h
```sh
$ git remote -h 
usage: git remote [-v | --verbose]
   or: git remote add [-t <branch>] [-m <master>] [-f] [--tags | --no-tags] [--mirror=<fetch|push>] <name> <url>
   or: git remote rename <old> <new>
   or: git remote remove <name>
   or: git remote set-head <name> (-a | --auto | -d | --delete | <branch>)
   or: git remote [-v | --verbose] show [-n] <name>
   or: git remote prune [-n | --dry-run] <name>
   or: git remote [-v | --verbose] update [-p | --prune] [(<group> | <remote>)...]
   or: git remote set-branches [--add] <name> <branch>...
   or: git remote get-url [--push] [--all] <name>
   or: git remote set-url [--push] <name> <newurl> [<oldurl>]
   or: git remote set-url --add <name> <newurl>
   or: git remote set-url --delete <name> <url>

    -v, --verbose         be verbose; must be placed before a subcommand
```

## 工作原理

Git 与远程仓库绑定通过 `<name>` 标签（远程名称）进行关联，通常标签名为 `origin`。例如：
- 拉取代码：`git pull origin master`
- 推送代码：`git push origin master`

`git remote` 的所有操作结果都会写入 `.git/config` 文件中，可以直接编辑该文件来修改远程仓库配置。

## 查看配置文件

```sh
# 查看 .git/config 文件中的远程仓库配置
$ cat .git/config
[remote "origin"]
    url = git@github.com:user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

# -v --verbose
显示远端仓库推送和拉取地址。
支持单标签拥有多个推送地址，支持多个标签，前者可以让本地仓库的修改同时推送到不同的远端仓库，后者支持多个不同的远端仓库获取和推送。
远端地址需要通过`add`的方式添加指定操作。
单个标签支持推送多个远端：
```sh
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
github  git@github.com:github/project.git (push)
```

同时支持多个标签：
```sh
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
github  git@github.com:github/project.git (fetch)
github  git@github.com:github/project.git (push)
```

在使用上`git pull/push origin/github branch`就可以拉取响应标签相应分支的代码

## show

显示指定远程仓库的详细信息，包括：
- 远程仓库的 URL
- 远程分支列表
- 本地分支与远程分支的跟踪关系
- 远程分支的状态

```sh
# 显示 origin 远程仓库的详细信息
$ git remote show origin
* remote origin
  Fetch URL: git@github.com:user/repo.git
  Push  URL: git@github.com:user/repo.git
  HEAD branch: main
  Remote branches:
    main      tracked
    develop   tracked
    feature   new (next fetch will store in remotes/origin)
  Local branches configured for 'pull':
    main      merges with remote main
    develop   merges with remote develop
  Local refs configured for 'push':
    main      pushes to main (up to date)
    develop   pushes to develop (local out of date)
```

### 选项

- `-n, --no-query`：不查询远程仓库，只显示本地缓存的信息

```sh
# 快速显示，不查询远程
$ git remote show -n origin
```

## update

更新远程仓库的引用信息。它会从远程仓库获取最新的分支和标签信息，但不会合并到本地分支。

```sh
# 更新所有远程仓库
$ git remote update

# 更新指定的远程仓库
$ git remote update origin

# 更新多个远程仓库
$ git remote update origin upstream

# 更新并清理已删除的远程分支引用
$ git remote update -p origin
# 或
$ git remote update --prune origin
```

### 选项

- `-p, --prune`：在更新后清理已删除的远程分支引用

### 使用场景

```sh
# 场景1：同步所有远程仓库的最新信息
$ git remote update

# 场景2：检查远程分支是否有更新
$ git remote update origin
$ git log HEAD..origin/main

# 场景3：清理已删除的远程分支
$ git remote update --prune origin
```

# add

将本地仓库与远程仓库绑定。

## 基本用法

```sh
# 添加远程仓库
$ git remote add <name> <url>

# 示例：添加 GitHub 仓库
$ git remote add origin git@github.com:user/repo.git
```

当在 GitHub 新建一个仓库时，GitHub 会提示相应的操作，其中就有一个 `git remote add origin git@github.com:myself/project.git`，就是将本地仓库与远程 GitHub 上的仓库进行绑定。

**注意**：每个远程名称只能 `add` 一次，如果已存在同名的远程仓库，需要先删除或重命名。

## 常用选项

- `-t <branch>`：只跟踪指定的分支
- `-m <master>`：设置主分支（已废弃）
- `-f`：添加后立即执行 `git fetch`
- `--tags`：获取所有标签
- `--no-tags`：不获取标签
- `--mirror=<fetch|push>`：设置为镜像仓库

## 使用示例

```sh
# 基本添加
$ git remote add origin https://github.com/user/repo.git

# 添加后立即获取
$ git remote add -f origin https://github.com/user/repo.git

# 只跟踪特定分支
$ git remote add origin -t main -t develop https://github.com/user/repo.git

# 添加并获取所有标签
$ git remote add --tags origin https://github.com/user/repo.git

# 添加 SSH 地址
$ git remote add origin git@github.com:user/repo.git
```

## 常见 URL 格式

```sh
# HTTPS
$ git remote add origin https://github.com/user/repo.git

# SSH
$ git remote add origin git@github.com:user/repo.git

# Git 协议（通常只读）
$ git remote add origin git://github.com/user/repo.git

# 本地路径
$ git remote add local /path/to/repo.git

# 相对路径
$ git remote add local ../other-repo.git
```

# rename

重命名远程仓库的名称。

```sh
# 重命名远程仓库
$ git remote rename <old> <new>

# 示例：将 origin 重命名为 upstream
$ git remote rename origin upstream

# 查看结果
$ git remote -v
upstream  git@github.com:user/repo.git (fetch)
upstream  git@github.com:user/repo.git (push)
```

## 使用场景

```sh
# 场景1：将 origin 改为更具体的名称
$ git remote rename origin github

# 场景2：添加新的 origin，将旧的改为 upstream
$ git remote rename origin upstream
$ git remote add origin git@github.com:newuser/repo.git
```

**注意**：重命名后，所有相关的分支跟踪关系会自动更新。

# remove

移除远程仓库配置。

```sh
# 移除远程仓库
$ git remote remove <name>
# 或
$ git remote rm <name>

# 示例：移除 origin
$ git remote remove origin

# 查看结果
$ git remote -v
# 无输出，表示已删除
```

## 使用场景

```sh
# 场景1：移除错误的远程仓库
$ git remote remove wrong-remote

# 场景2：清理不需要的远程仓库
$ git remote remove old-upstream
```

**注意**：移除远程仓库不会删除已获取的远程分支引用，需要使用 `git remote prune` 清理。

# set-head

设置远程仓库的默认分支（HEAD）。

```sh
# 自动设置（从远程获取）
$ git remote set-head origin -a
# 或
$ git remote set-head origin --auto

# 手动设置
$ git remote set-head origin main

# 删除设置
$ git remote set-head origin -d
# 或
$ git remote set-head origin --delete
```

## 使用场景

```sh
# 场景1：自动检测远程默认分支
$ git remote set-head origin -a

# 场景2：手动指定默认分支
$ git remote set-head origin develop
```

# prune

清理已删除的远程分支引用。

```sh
# 清理指定远程仓库的已删除分支
$ git remote prune <name>
# 或
$ git remote prune --dry-run <name>  # 预览，不实际删除

# 示例：清理 origin 的已删除分支
$ git remote prune origin

# 预览模式
$ git remote prune -n origin
# 或
$ git remote prune --dry-run origin
```

## 使用场景

```sh
# 场景1：清理已删除的远程分支
$ git remote prune origin

# 场景2：预览将要删除的分支
$ git remote prune -n origin
Pruning origin
URL: git@github.com:user/repo.git
 * [would prune] origin/deleted-branch
```

## 与 update 的区别

- `git remote update -p`：更新并清理
- `git remote prune`：只清理，不更新

# set-branches

设置远程仓库要跟踪的分支。

```sh
# 设置跟踪的分支
$ git remote set-branches <name> <branch>...

# 添加跟踪的分支（不覆盖现有）
$ git remote set-branches --add <name> <branch>...

# 示例：只跟踪 main 分支
$ git remote set-branches origin main

# 示例：添加跟踪 develop 分支
$ git remote set-branches --add origin develop

# 跟踪所有分支
$ git remote set-branches origin '*'
```

## 使用场景

```sh
# 场景1：只跟踪特定分支（减少获取时间）
$ git remote set-branches origin main develop

# 场景2：添加新的跟踪分支
$ git remote set-branches --add origin feature/new-feature
```

# get-url

获取远程仓库的 URL 地址。

## 基本用法

```sh
# 获取 fetch URL（默认）
$ git remote get-url <name>

# 获取 push URL
$ git remote get-url --push <name>

# 获取所有 URL
$ git remote get-url --all <name>
```

## 使用示例

```sh
# 获取 origin 的 URL
$ git remote get-url origin
git@github.com:myself/project.git

# 获取 push URL
$ git remote get-url --push origin
git@github.com:myself/project.git

# 获取所有 URL（如果有多个）
$ git remote get-url --all origin
git@github.com:myself/project.git
git@github.com:backup/project.git
```

## 使用场景

```sh
# 场景1：查看远程仓库地址
$ git remote get-url origin

# 场景2：在脚本中使用
REPO_URL=$(git remote get-url origin)
echo "Repository: $REPO_URL"

# 场景3：检查是否有多个 push URL
$ git remote get-url --all origin
```

# set-url

修改远程仓库的 URL 地址。

## 基本用法

```sh
# 修改远程仓库 URL
$ git remote set-url <name> <newurl>

# 修改 push URL
$ git remote set-url --push <name> <newurl>

# 修改指定的 URL（当有多个 URL 时）
$ git remote set-url <name> <newurl> <oldurl>
```

## 使用示例

```sh
# 修改 origin 的 URL
$ git remote set-url origin git@github.com:newuser/project.git

# 验证修改
$ git remote get-url origin
git@github.com:newuser/project.git

# 修改 push URL（fetch URL 不变）
$ git remote set-url --push origin git@github.com:backup/project.git

# 查看结果
$ git remote -v
origin  git@github.com:newuser/project.git (fetch)
origin  git@github.com:backup/project.git (push)
```

## 常见场景

### 场景1：更换远程仓库地址

```sh
# 从 HTTPS 切换到 SSH
$ git remote set-url origin git@github.com:user/repo.git

# 从 SSH 切换到 HTTPS
$ git remote set-url origin https://github.com/user/repo.git

# 更换到新的仓库
$ git remote set-url origin https://github.com/newuser/newrepo.git
```

### 场景2：设置不同的 fetch 和 push URL

```sh
# fetch 从一个地址，push 到另一个地址
$ git remote set-url origin https://github.com/user/repo.git
$ git remote set-url --push origin git@github.com:user/repo.git
```

## --add

向远程仓库添加一个新的推送地址。这样就可以实现同一个本地仓库，执行 `git push origin master` 时，可以同时向多个远程仓库推送代码。

```sh
# 添加额外的 push URL
$ git remote set-url --add <name> <newurl>

# 示例：添加备份推送地址
$ git remote set-url --add origin git@github.com:backup/project.git

# 查看结果
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
origin  git@github.com:backup/project.git (push)
```

### 使用场景

```sh
# 场景1：同时推送到 GitHub 和 GitLab
$ git remote set-url origin https://github.com/user/repo.git
$ git remote set-url --add origin https://gitlab.com/user/repo.git

# 推送时会同时推送到两个仓库
$ git push origin main

# 场景2：添加备份仓库
$ git remote set-url --add origin git@backup-server.com:repo.git
```

**注意**：使用 `--add` 时，只会添加 push URL，fetch URL 保持不变。如果需要从多个地址拉取，需要添加多个远程仓库。

## --delete

删除远程仓库的指定 URL。

```sh
# 删除指定的 URL
$ git remote set-url --delete <name> <url>

# 示例：删除备份推送地址
$ git remote set-url --delete origin git@github.com:backup/project.git

# 查看结果
$ git remote -v
origin  git@github.com:myself/project.git (fetch)
origin  git@github.com:myself/project.git (push)
```

### 使用场景

```sh
# 场景1：移除不需要的推送地址
$ git remote set-url --delete origin git@backup-server.com:repo.git

# 场景2：清理多余的 URL
$ git remote set-url --delete origin https://old-repo.com/repo.git
```

### 注意事项

如果删除的是唯一的 fetch URL（可以从远程仓库拉取的地址），则会报错：

```sh
$ git remote set-url --delete origin git@github.com:myself/project.git
fatal: Will not delete all non-push URLs
```

这是因为 Git 需要至少保留一个 fetch URL 来拉取代码。解决方法：

```sh
# 方法1：先添加新的 fetch URL，再删除旧的
$ git remote set-url --add origin git@github.com:newuser/project.git
$ git remote set-url origin git@github.com:newuser/project.git

# 方法2：只删除 push URL
$ git remote set-url --delete origin git@github.com:backup/project.git
```

# 实际应用场景

## 场景1：克隆后修改远程地址

```sh
# 克隆仓库
$ git clone https://github.com/user/repo.git

# 进入目录
$ cd repo

# 修改为 SSH 地址（更安全、更快）
$ git remote set-url origin git@github.com:user/repo.git

# 验证
$ git remote -v
```

## 场景2：Fork 后添加上游仓库

```sh
# 1. 克隆自己的 fork
$ git clone git@github.com:yourname/repo.git
$ cd repo

# 2. 添加上游仓库
$ git remote add upstream git@github.com:original/repo.git

# 3. 查看所有远程仓库
$ git remote -v
origin    git@github.com:yourname/repo.git (fetch)
origin    git@github.com:yourname/repo.git (push)
upstream  git@github.com:original/repo.git (fetch)
upstream  git@github.com:original/repo.git (push)

# 4. 同步上游更改
$ git fetch upstream
$ git merge upstream/main
```

## 场景3：同时推送到多个仓库

```sh
# 添加多个推送地址
$ git remote set-url origin https://github.com/user/repo.git
$ git remote set-url --add origin https://gitlab.com/user/repo.git
$ git remote set-url --add origin git@backup-server.com:repo.git

# 一次推送，推送到所有地址
$ git push origin main
```

## 场景4：迁移仓库

```sh
# 1. 查看当前远程地址
$ git remote -v

# 2. 修改为新的地址
$ git remote set-url origin https://github.com/newuser/newrepo.git

# 3. 验证
$ git remote get-url origin

# 4. 推送所有分支
$ git push origin --all
$ git push origin --tags
```

## 场景5：使用不同的协议

```sh
# 从 HTTPS 切换到 SSH（提高安全性）
$ git remote set-url origin git@github.com:user/repo.git

# 从 SSH 切换到 HTTPS（避免 SSH 配置问题）
$ git remote set-url origin https://github.com/user/repo.git
```

## 场景6：清理远程分支引用

```sh
# 1. 查看远程分支
$ git branch -r

# 2. 更新远程信息
$ git remote update

# 3. 清理已删除的远程分支
$ git remote prune origin

# 4. 验证
$ git branch -r
```

# 常见问题和解决方案

## 问题1：推送失败 - 远程仓库不存在

**错误信息**：
```
fatal: 'origin' does not appear to be a git repository
```

**解决方案**：
```sh
# 检查远程仓库配置
$ git remote -v

# 如果不存在，添加远程仓库
$ git remote add origin <url>

# 如果 URL 错误，修改 URL
$ git remote set-url origin <correct-url>
```

## 问题2：无法删除唯一的 fetch URL

**错误信息**：
```
fatal: Will not delete all non-push URLs
```

**解决方案**：
```sh
# 先添加新的 fetch URL
$ git remote set-url origin <new-url>

# 然后再删除旧的（如果需要）
```

## 问题3：远程分支引用混乱

**问题**：远程分支已删除，但本地仍显示

**解决方案**：
```sh
# 清理已删除的远程分支引用
$ git remote prune origin

# 或更新并清理
$ git remote update --prune origin
```

## 问题4：多个远程仓库冲突

**问题**：有多个远程仓库，不知道推送到哪个

**解决方案**：
```sh
# 查看所有远程仓库
$ git remote -v

# 查看详细信息
$ git remote show origin

# 明确指定推送到哪个远程
$ git push origin main
$ git push backup main
```

## 问题5：SSH 和 HTTPS 混用导致的问题

**问题**：有时使用 HTTPS，有时使用 SSH，导致认证混乱

**解决方案**：
```sh
# 统一使用 SSH
$ git remote set-url origin git@github.com:user/repo.git

# 或统一使用 HTTPS
$ git remote set-url origin https://github.com/user/repo.git
```

# 最佳实践

## 1. 命名规范

- ✅ 使用 `origin` 作为主要的远程仓库
- ✅ 使用 `upstream` 作为上游仓库（fork 场景）
- ✅ 使用描述性的名称，如 `github`、`gitlab`、`backup`

## 2. URL 选择

- ✅ **生产环境**：使用 SSH（更安全、更快）
- ✅ **临时访问**：使用 HTTPS（无需配置 SSH 密钥）
- ✅ **只读访问**：使用 Git 协议（如果支持）

## 3. 多远程仓库管理

```sh
# 推荐配置
$ git remote add origin git@github.com:user/repo.git      # 主仓库
$ git remote add upstream git@github.com:upstream/repo.git  # 上游仓库
$ git remote add backup git@backup-server.com:repo.git     # 备份仓库
```

## 4. 定期清理

```sh
# 定期清理已删除的远程分支
$ git remote prune origin

# 检查远程仓库状态
$ git remote show origin
```

## 5. 使用配置文件

直接编辑 `.git/config` 文件可以更精确地控制远程仓库配置：

```ini
[remote "origin"]
    url = git@github.com:user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    pushurl = git@github.com:user/repo.git
    pushurl = git@backup-server.com:repo.git
```

## 6. 验证配置

```sh
# 推送前验证远程配置
$ git remote -v
$ git remote show origin

# 测试连接
$ git ls-remote origin
```

# 总结

`git remote` 是管理远程仓库的核心命令，掌握它可以帮助你：

1. **管理远程仓库**：添加、删除、重命名远程仓库
2. **配置 URL**：修改和添加多个推送地址
3. **同步信息**：更新远程分支和标签信息
4. **清理引用**：删除已不存在的远程分支引用
5. **多仓库协作**：管理多个远程仓库（fork、备份等场景）

通过合理使用 `git remote`，可以更高效地管理 Git 仓库的远程连接。



