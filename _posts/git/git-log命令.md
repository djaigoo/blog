---
author: djaigo
title: git-log命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git log 命令

## 简介

`git log` 是 Git 中用于查看提交历史的命令。它是了解项目开发历史和追踪更改的重要工具。

## 基本概念

### 什么是提交历史

提交历史是 Git 仓库中所有提交的记录，包括：
- 提交哈希
- 作者信息
- 提交时间
- 提交信息
- 文件更改

## 命令语法

```sh
# 基本查看
git log [选项] [提交范围] [--] [路径]

# 查看所有提交
git log

# 查看指定分支
git log branch-name

# 查看指定文件
git log -- file.txt
```

## 查看帮助文档

```sh
$ git log --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `--oneline` | 单行显示每个提交 |
| `--graph` | 以图形方式显示分支 |
| `--all` | 显示所有分支 |
| `--decorate` | 显示分支和标签 |
| `-n, --max-count=<n>` | 只显示最近 n 个提交 |
| `--since, --after` | 显示指定时间之后的提交 |
| `--until, --before` | 显示指定时间之前的提交 |
| `--author=<pattern>` | 按作者过滤 |
| `--grep=<pattern>` | 按提交信息过滤 |
| `-S<string>` | 显示包含指定字符串更改的提交 |
| `--follow` | 跟踪文件重命名 |
| `--stat` | 显示文件更改统计 |
| `-p, --patch` | 显示详细差异 |
| `--pretty=<format>` | 自定义输出格式 |
| `--abbrev-commit` | 使用短提交哈希 |
| `--date=<format>` | 自定义日期格式 |
| `--name-only` | 只显示文件名 |
| `--name-status` | 显示文件名和状态 |

# 基本使用

## 1. 基本查看

```sh
# 查看提交历史
$ git log

# 单行显示
$ git log --oneline

# 显示最近 10 个提交
$ git log -10
```

## 2. 图形化显示

```sh
# 图形化显示分支
$ git log --graph --oneline

# 显示所有分支
$ git log --graph --oneline --all

# 显示分支和标签
$ git log --graph --oneline --all --decorate
```

## 3. 按时间过滤

```sh
# 显示最近一周的提交
$ git log --since="1 week ago"

# 显示指定日期之后的提交
$ git log --since="2024-01-01"

# 显示指定日期之前的提交
$ git log --until="2024-12-31"

# 显示最近 7 天的提交
$ git log --since="7 days ago"
```

## 4. 按作者过滤

```sh
# 显示指定作者的提交
$ git log --author="John"

# 使用正则表达式
$ git log --author="John\|Jane"
```

## 5. 按提交信息过滤

```sh
# 搜索提交信息
$ git log --grep="fix bug"

# 使用正则表达式
$ git log --grep="^fix"
```

## 6. 按文件过滤

```sh
# 查看特定文件的提交历史
$ git log -- README.md

# 查看目录的提交历史
$ git log -- src/

# 跟踪文件重命名
$ git log --follow -- README.md
```

## 7. 显示统计信息

```sh
# 显示文件更改统计
$ git log --stat

# 显示详细差异
$ git log -p

# 只显示文件名
$ git log --name-only

# 显示文件名和状态
$ git log --name-status
```

## 8. 自定义格式

```sh
# 自定义输出格式
$ git log --pretty=format:"%h - %an, %ar : %s"

# 常用格式占位符：
# %h - 短提交哈希
# %H - 完整提交哈希
# %an - 作者名
# %ae - 作者邮箱
# %ar - 相对时间
# %ad - 日期
# %s - 提交信息
```

# 实际应用场景

## 场景1：查看最近提交

```sh
# 查看最近 5 个提交
$ git log -5 --oneline

# 查看最近一周的提交
$ git log --since="1 week ago" --oneline
```

## 场景2：查看分支历史

```sh
# 查看所有分支的图形化历史
$ git log --graph --oneline --all --decorate

# 查看特定分支
$ git log --oneline feature-branch
```

## 场景3：查找特定提交

```sh
# 按作者查找
$ git log --author="John" --oneline

# 按提交信息查找
$ git log --grep="bug fix" --oneline

# 按文件内容查找
$ git log -S"function_name" --oneline
```

## 场景4：查看文件历史

```sh
# 查看文件的提交历史
$ git log -- README.md

# 跟踪文件重命名
$ git log --follow -- README.md

# 显示文件更改详情
$ git log -p -- README.md
```

## 场景5：生成报告

```sh
# 生成提交报告
$ git log --pretty=format:"%h | %an | %ad | %s" --date=short > commits.txt

# 统计每个作者的提交数
$ git shortlog -sn
```

# 常用组合

## 1. 美观的日志显示

```sh
# 图形化单行显示
$ git log --graph --oneline --all --decorate

# 创建别名
$ git config --global alias.lg "log --graph --oneline --all --decorate"
$ git lg
```

## 2. 查看特定时间范围

```sh
# 查看今天的提交
$ git log --since="today" --oneline

# 查看本月的提交
$ git log --since="1 month ago" --oneline
```

## 3. 查看两个提交之间的历史

```sh
# 查看两个提交之间的历史
$ git log commit1..commit2

# 查看两个分支的差异
$ git log main..feature-branch
```

## 4. 查看文件更改

```sh
# 查看文件的详细更改历史
$ git log -p -- README.md

# 查看文件的统计信息
$ git log --stat -- README.md
```

# 常见问题和解决方案

## 问题1：日志输出太长

**解决方案**：
```sh
# 使用单行显示
$ git log --oneline

# 限制数量
$ git log -10 --oneline

# 使用分页器
$ git log | less
```

## 问题2：想查看特定文件的更改

**解决方案**：
```sh
# 查看文件历史
$ git log -- file.txt

# 跟踪重命名
$ git log --follow -- file.txt
```

## 问题3：查找包含特定代码的提交

**解决方案**：
```sh
# 查找包含特定字符串的提交
$ git log -S"function_name" --oneline

# 查找匹配正则表达式的提交
$ git log -G"pattern" --oneline
```

# 最佳实践

## 1. 使用别名简化

```sh
# 创建常用别名
$ git config --global alias.lg "log --graph --oneline --all --decorate"
$ git config --global alias.ll "log --oneline -10"
```

## 2. 组合使用选项

```sh
# 常用的组合
$ git log --graph --oneline --all --decorate -10
```

## 3. 导出日志

```sh
# 导出日志到文件
$ git log --pretty=format:"%h | %an | %ad | %s" > log.txt
```

# 总结

`git log` 是查看提交历史的核心命令：

1. **基本用法**：`git log` 查看提交历史
2. **图形化显示**：`git log --graph` 显示分支关系
3. **过滤查看**：按时间、作者、文件等过滤
4. **自定义格式**：使用 `--pretty=format` 自定义输出

**关键要点**：
- ✅ 使用 `--oneline` 简化输出
- ✅ 使用 `--graph` 查看分支关系
- ✅ 使用过滤选项查找特定提交
- ✅ 创建别名简化常用命令

