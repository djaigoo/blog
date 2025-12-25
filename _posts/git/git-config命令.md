---
author: djaigo
title: git-config命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git config 命令

## 简介

`git config` 是 Git 中用于配置 Git 的命令。它可以设置用户信息、仓库设置、别名等。

## 基本概念

### 配置级别

1. **系统级别（--system）**：`/etc/gitconfig`，影响所有用户
2. **全局级别（--global）**：`~/.gitconfig`，影响当前用户
3. **仓库级别（--local）**：`.git/config`，只影响当前仓库

优先级：仓库 > 全局 > 系统

## 命令语法

```sh
# 查看配置
git config [--global|--system|--local] --list

# 设置配置
git config [--global|--system|--local] <key> <value>

# 获取配置
git config [--global|--system|--local] <key>

# 删除配置
git config [--global|--system|--local] --unset <key>
```

## 查看帮助文档

```sh
$ git config --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `--global` | 全局配置（用户级别） |
| `--system` | 系统配置（所有用户） |
| `--local` | 仓库配置（默认） |
| `--list, -l` | 列出所有配置 |
| `--get` | 获取配置值 |
| `--unset` | 删除配置项 |
| `--unset-all` | 删除所有匹配的配置项 |
| `--add` | 添加配置项 |
| `--get-regexp` | 使用正则表达式获取配置 |
| `--edit` | 编辑配置文件 |
| `--file <file>` | 指定配置文件 |

# 基本使用

## 1. 查看配置

```sh
# 查看所有配置
$ git config --list

# 查看全局配置
$ git config --global --list

# 查看仓库配置
$ git config --local --list

# 查看系统配置
$ git config --system --list
```

## 2. 设置用户信息

```sh
# 设置用户名（全局）
$ git config --global user.name "Your Name"

# 设置邮箱（全局）
$ git config --global user.email "your.email@example.com"

# 设置仓库级别的用户信息
$ git config user.name "Project Name"
$ git config user.email "project@example.com"
```

## 3. 获取配置值

```sh
# 获取用户名
$ git config user.name

# 获取邮箱
$ git config user.email

# 获取全局配置
$ git config --global user.name
```

## 4. 删除配置

```sh
# 删除配置项
$ git config --global --unset user.name

# 删除所有匹配的配置
$ git config --global --unset-all alias.co
```

## 5. 编辑配置文件

```sh
# 编辑全局配置
$ git config --global --edit

# 编辑仓库配置
$ git config --local --edit
```

# 常用配置

## 1. 用户信息

```sh
# 设置全局用户信息
$ git config --global user.name "Your Name"
$ git config --global user.email "your.email@example.com"
```

## 2. 编辑器配置

```sh
# 设置默认编辑器
$ git config --global core.editor "vim"
$ git config --global core.editor "code --wait"  # VS Code
$ git config --global core.editor "nano"
```

## 3. 默认分支名

```sh
# 设置默认分支为 main
$ git config --global init.defaultBranch main
```

## 4. 合并工具

```sh
# 设置合并工具
$ git config --global merge.tool vimdiff
$ git config --global merge.tool "code --wait"  # VS Code
```

## 5. 别名配置

```sh
# 创建常用别名
$ git config --global alias.st status
$ git config --global alias.co checkout
$ git config --global alias.br branch
$ git config --global alias.ci commit
$ git config --global alias.unstage "reset HEAD --"
$ git config --global alias.last "log -1 HEAD"
$ git config --global alias.visual "!gitk"
```

## 6. 颜色配置

```sh
# 启用颜色输出
$ git config --global color.ui auto

# 配置特定颜色
$ git config --global color.branch auto
$ git config --global color.diff auto
$ git config --global color.status auto
```

## 7. 换行符配置

```sh
# Windows
$ git config --global core.autocrlf true

# Linux/Mac
$ git config --global core.autocrlf input

# 禁用自动转换
$ git config --global core.autocrlf false
```

## 8. 推送配置

```sh
# 设置默认推送行为
$ git config --global push.default simple

# 设置 pull 使用 rebase
$ git config --global pull.rebase true
```

## 9. 凭据存储

```sh
# 存储凭据（HTTPS）
$ git config --global credential.helper store

# 使用缓存（15分钟）
$ git config --global credential.helper cache

# 使用系统凭据管理器
$ git config --global credential.helper manager-core  # Windows
$ git config --global credential.helper osxkeychain   # Mac
```

# 实际应用场景

## 场景1：首次配置 Git

```sh
# 设置用户信息
$ git config --global user.name "Your Name"
$ git config --global user.email "your.email@example.com"

# 设置编辑器
$ git config --global core.editor "vim"

# 启用颜色
$ git config --global color.ui auto
```

## 场景2：创建常用别名

```sh
# 创建简化命令的别名
$ git config --global alias.st status
$ git config --global alias.co checkout
$ git config --global alias.br branch
$ git config --global alias.ci commit

# 使用别名
$ git st
$ git co main
```

## 场景3：项目特定配置

```sh
# 为特定项目设置不同的用户信息
$ cd project
$ git config user.name "Project Name"
$ git config user.email "project@example.com"
```

## 场景4：配置合并工具

```sh
# 设置 VS Code 为合并工具
$ git config --global merge.tool vscode
$ git config --global mergetool.vscode.cmd "code --wait \$MERGED"
```

## 场景5：配置凭据存储

```sh
# 存储 HTTPS 凭据
$ git config --global credential.helper store

# 之后输入一次密码，Git 会记住
```

# 配置文件位置

## 全局配置

```sh
# 查看全局配置文件
$ cat ~/.gitconfig

# 或
$ git config --global --list --show-origin
```

## 仓库配置

```sh
# 查看仓库配置文件
$ cat .git/config

# 或
$ git config --local --list --show-origin
```

## 系统配置

```sh
# 系统配置文件位置
/etc/gitconfig

# 查看
$ git config --system --list
```

# 常见问题和解决方案

## 问题1：配置不生效

**解决方案**：
```sh
# 检查配置级别
$ git config --list --show-origin

# 检查优先级（仓库 > 全局 > 系统）
$ git config user.name
```

## 问题2：想删除配置

**解决方案**：
```sh
# 删除配置项
$ git config --global --unset user.name

# 删除所有匹配的配置
$ git config --global --unset-all alias.st
```

## 问题3：配置了错误的编辑器

**解决方案**：
```sh
# 重新设置编辑器
$ git config --global core.editor "vim"

# 或删除后重新设置
$ git config --global --unset core.editor
$ git config --global core.editor "vim"
```

# 最佳实践

## 1. 首次使用 Git 时配置

```sh
# 首次配置
$ git config --global user.name "Your Name"
$ git config --global user.email "your.email@example.com"
$ git config --global core.editor "vim"
$ git config --global color.ui auto
```

## 2. 使用别名简化命令

```sh
# 创建常用别名
$ git config --global alias.st status
$ git config --global alias.co checkout
$ git config --global alias.br branch
```

## 3. 项目特定配置

```sh
# 为特定项目设置不同的配置
$ git config user.name "Project Name"
$ git config user.email "project@example.com"
```

## 4. 定期检查配置

```sh
# 查看所有配置
$ git config --list

# 查看配置来源
$ git config --list --show-origin
```

# 总结

`git config` 是配置 Git 的核心命令：

1. **查看配置**：`git config --list` 查看所有配置
2. **设置配置**：`git config --global <key> <value>` 设置配置
3. **获取配置**：`git config <key>` 获取配置值
4. **删除配置**：`git config --unset <key>` 删除配置

**关键要点**：
- ✅ 首次使用 Git 时配置用户信息
- ✅ 使用别名简化常用命令
- ✅ 了解配置级别和优先级
- ✅ 为特定项目设置不同的配置

