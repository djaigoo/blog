---
author: djaigo
title: git-clone命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git clone 命令

## 简介

`git clone` 是 Git 中用于克隆（复制）远程仓库到本地的命令。它是获取远程项目副本的标准方式。

## 基本概念

### 什么是克隆

克隆是创建一个远程仓库的完整副本，包括：
- 所有文件
- 完整的提交历史
- 所有分支
- 所有标签

### 克隆 vs 下载

| 特性 | Clone | 下载 ZIP |
|------|-------|----------|
| 提交历史 | ✅ 完整历史 | ❌ 无历史 |
| 分支 | ✅ 所有分支 | ❌ 只有主分支 |
| 版本控制 | ✅ 可以提交 | ❌ 不能提交 |
| 更新 | ✅ 可以 pull | ❌ 需要重新下载 |

## 命令语法

```sh
# 基本克隆
git clone <仓库URL> [目录名]

# 克隆到指定目录
git clone <仓库URL> <目录名>

# 克隆指定分支
git clone -b <分支名> <仓库URL>
```

## 查看帮助文档

```sh
$ git clone --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-b, --branch <分支名>` | 克隆指定分支 |
| `--depth <n>` | 浅克隆，只克隆最近 n 次提交 |
| `--single-branch` | 只克隆指定分支 |
| `--no-single-branch` | 克隆所有分支（默认） |
| `--shallow-submodules` | 浅克隆子模块 |
| `--recursive, --recurse-submodules` | 递归克隆子模块 |
| `--bare` | 创建裸仓库（无工作目录） |
| `--mirror` | 创建镜像仓库 |
| `-o, --origin <名称>` | 设置远程仓库名称（默认 origin） |
| `-j, --jobs <n>` | 并行克隆子模块的数量 |
| `--template <模板目录>` | 使用指定的模板目录 |
| `-q, --quiet` | 静默模式 |
| `-v, --verbose` | 详细输出 |
| `--progress` | 显示进度 |
| `--no-checkout` | 克隆后不检出工作目录 |

# 基本使用

## 1. 基本克隆

```sh
# 克隆仓库（使用 HTTPS）
$ git clone https://github.com/user/repo.git

# 克隆仓库（使用 SSH）
$ git clone git@github.com:user/repo.git

# 克隆到指定目录
$ git clone https://github.com/user/repo.git my-project
```

## 2. 克隆指定分支

```sh
# 克隆特定分支
$ git clone -b develop https://github.com/user/repo.git

# 只克隆指定分支（不克隆其他分支）
$ git clone -b develop --single-branch https://github.com/user/repo.git
```

## 3. 浅克隆

```sh
# 只克隆最近 10 次提交
$ git clone --depth 10 https://github.com/user/repo.git

# 浅克隆指定分支
$ git clone --depth 10 -b develop https://github.com/user/repo.git
```

## 4. 克隆子模块

```sh
# 递归克隆子模块
$ git clone --recursive https://github.com/user/repo.git

# 或使用
$ git clone --recurse-submodules https://github.com/user/repo.git

# 浅克隆子模块
$ git clone --recursive --shallow-submodules https://github.com/user/repo.git
```

## 5. 裸仓库克隆

```sh
# 创建裸仓库（用于服务器）
$ git clone --bare https://github.com/user/repo.git repo.git
```

## 6. 镜像克隆

```sh
# 创建镜像仓库（包括所有引用）
$ git clone --mirror https://github.com/user/repo.git
```

## 7. 克隆后不检出

```sh
# 克隆但不检出工作目录
$ git clone --no-checkout https://github.com/user/repo.git

# 之后可以手动检出
$ cd repo
$ git checkout main
```

# 实际应用场景

## 场景1：克隆开源项目

```sh
# 克隆 GitHub 项目
$ git clone https://github.com/user/project.git

# 进入项目目录
$ cd project
```

## 场景2：克隆到特定目录

```sh
# 克隆到指定目录
$ git clone https://github.com/user/repo.git my-local-name
```

## 场景3：克隆特定分支

```sh
# 只克隆开发分支
$ git clone -b develop https://github.com/user/repo.git
```

## 场景4：快速克隆（浅克隆）

```sh
# 只克隆最近提交（加快速度）
$ git clone --depth 1 https://github.com/user/repo.git
```

## 场景5：克隆包含子模块的项目

```sh
# 递归克隆子模块
$ git clone --recursive https://github.com/user/repo.git
```

## 场景6：克隆到服务器

```sh
# 创建裸仓库用于服务器
$ git clone --bare https://github.com/user/repo.git repo.git
```

# URL 格式

## HTTPS

```sh
$ git clone https://github.com/user/repo.git
$ git clone https://gitlab.com/user/repo.git
```

## SSH

```sh
$ git clone git@github.com:user/repo.git
$ git clone ssh://git@gitlab.com/user/repo.git
```

## Git 协议

```sh
$ git clone git://github.com/user/repo.git
```

## 本地路径

```sh
$ git clone /path/to/repo.git
$ git clone ../other-repo.git
```

# 常见问题和解决方案

## 问题1：克隆速度慢

**解决方案**：
```sh
# 使用浅克隆
$ git clone --depth 1 https://github.com/user/repo.git

# 使用 SSH（如果配置了密钥）
$ git clone git@github.com:user/repo.git
```

## 问题2：需要认证

**解决方案**：
```sh
# HTTPS：使用用户名和密码或 token
$ git clone https://username:token@github.com/user/repo.git

# SSH：配置 SSH 密钥
$ ssh-keygen -t ed25519 -C "your_email@example.com"
$ git clone git@github.com:user/repo.git
```

## 问题3：子模块未克隆

**解决方案**：
```sh
# 克隆时包含子模块
$ git clone --recursive https://github.com/user/repo.git

# 或克隆后初始化子模块
$ git clone https://github.com/user/repo.git
$ cd repo
$ git submodule update --init --recursive
```

## 问题4：克隆后没有文件

**解决方案**：
```sh
# 检查是否使用了 --no-checkout
$ git clone --no-checkout https://github.com/user/repo.git

# 手动检出
$ cd repo
$ git checkout main
```

# 最佳实践

## 1. 使用 SSH（如果可能）

```sh
# ✅ 推荐：使用 SSH（更快、更安全）
$ git clone git@github.com:user/repo.git

# ⚠️ 也可以：使用 HTTPS
$ git clone https://github.com/user/repo.git
```

## 2. 浅克隆大型仓库

```sh
# 对于大型仓库，使用浅克隆
$ git clone --depth 1 https://github.com/user/large-repo.git
```

## 3. 克隆后检查

```sh
# 克隆后检查状态
$ git clone https://github.com/user/repo.git
$ cd repo
$ git status
$ git branch -a
```

## 4. 使用描述性的目录名

```sh
# ✅ 好的命名
$ git clone https://github.com/user/repo.git my-project-name

# ❌ 不好的命名
$ git clone https://github.com/user/repo.git repo
```

# 总结

`git clone` 是获取远程仓库副本的标准方式：

1. **基本用法**：`git clone <URL>` 克隆仓库
2. **指定分支**：`git clone -b <branch> <URL>` 克隆特定分支
3. **浅克隆**：`git clone --depth 1 <URL>` 只克隆最近提交
4. **子模块**：`git clone --recursive <URL>` 包含子模块

**关键要点**：
- ✅ 使用 SSH 提高速度和安全性
- ✅ 大型仓库使用浅克隆
- ✅ 克隆后检查状态和分支
- ✅ 使用描述性的目录名

