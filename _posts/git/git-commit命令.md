---
author: djaigo
title: git-commit命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git commit 命令

## 简介

`git commit` 是 Git 中用于将暂存区的更改提交到仓库的命令。它是 Git 工作流中的关键步骤，用于保存项目的快照。

## 基本概念

### 什么是提交

提交（commit）是 Git 仓库中的一个快照，记录了某个时间点工作目录的状态。每个提交包含：
- 提交信息（commit message）
- 作者信息
- 时间戳
- 指向父提交的指针
- 文件的完整快照

### 提交的作用

1. **保存更改**：将暂存区的更改永久保存到仓库
2. **创建历史**：形成项目的开发历史
3. **版本控制**：可以回退到任何提交
4. **协作基础**：团队成员可以共享提交

## 命令语法

```sh
# 基本提交
git commit [选项]

# 提交并添加信息
git commit -m "提交信息"

# 提交所有更改（跳过 git add）
git commit -a -m "提交信息"
```

## 查看帮助文档

```sh
$ git commit --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-m, --message=<msg>` | 直接指定提交信息 |
| `-a, --all` | 自动暂存所有已跟踪文件的更改 |
| `--amend` | 修改最后一次提交 |
| `-v, --verbose` | 在编辑器中显示差异 |
| `-q, --quiet` | 静默模式 |
| `-s, --signoff` | 添加 Signed-off-by 行 |
| `-S, --gpg-sign` | 使用 GPG 签名提交 |
| `--no-verify` | 跳过 pre-commit 和 commit-msg 钩子 |
| `--allow-empty` | 允许空提交 |
| `--no-edit` | 使用上次的提交信息（amend 时） |
| `-e, --edit` | 编辑提交信息（默认行为） |
| `--fixup=<commit>` | 创建 fixup 提交 |
| `--squash=<commit>` | 创建 squash 提交 |
| `-C, --reuse-message=<commit>` | 重用指定提交的信息 |
| `-c, --reedit-message=<commit>` | 重用并编辑指定提交的信息 |
| `-F, --file=<file>` | 从文件读取提交信息 |
| `--author=<author>` | 指定作者 |
| `--date=<date>` | 指定提交日期 |

# 基本使用

## 1. 基本提交

```sh
# 提交暂存区的更改（会打开编辑器）
$ git commit

# 提交并直接指定信息
$ git commit -m "Add new feature"

# 提交并添加详细描述
$ git commit -m "Add new feature" -m "Detailed description"
```

## 2. 提交所有更改

```sh
# 自动暂存所有已跟踪文件的更改并提交
$ git commit -a -m "Update all tracked files"

# 或分步执行
$ git add -A
$ git commit -m "Update all files"
```

## 3. 修改最后一次提交

```sh
# 修改最后一次提交（添加更多更改）
$ git add forgotten-file.txt
$ git commit --amend

# 只修改提交信息
$ git commit --amend -m "New commit message"

# 修改提交信息但不打开编辑器
$ git commit --amend --no-edit
```

## 4. 空提交

```sh
# 创建空提交（不包含任何更改）
$ git commit --allow-empty -m "Trigger CI"
```

## 5. 签名提交

```sh
# 使用 GPG 签名提交
$ git commit -S -m "Signed commit"

# 配置默认签名
$ git config --global commit.gpgsign true
```

## 6. 从文件读取提交信息

```sh
# 从文件读取提交信息
$ git commit -F commit-message.txt

# 或使用
$ git commit --file=commit-message.txt
```

# 提交信息规范

## 基本格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

## 类型（Type）

- `feat`：新功能
- `fix`：bug 修复
- `docs`：文档更改
- `style`：代码格式（不影响代码运行）
- `refactor`：重构
- `perf`：性能优化
- `test`：测试相关
- `chore`：构建过程或辅助工具的变动

## 示例

```sh
# 功能提交
$ git commit -m "feat: add user authentication"

# Bug 修复
$ git commit -m "fix: resolve login error"

# 文档更新
$ git commit -m "docs: update README"

# 详细提交
$ git commit -m "feat: add user authentication" -m "Implement JWT-based authentication with refresh tokens"
```

# 实际应用场景

## 场景1：常规提交

```sh
# 添加文件
$ git add file.txt

# 提交
$ git commit -m "Add new file"
```

## 场景2：修改上次提交

```sh
# 发现遗漏了文件
$ git add forgotten-file.txt

# 修改上次提交
$ git commit --amend --no-edit
```

## 场景3：提交所有更改

```sh
# 一次性提交所有已跟踪文件的更改
$ git commit -a -m "Update all files"
```

## 场景4：创建 fixup 提交

```sh
# 创建 fixup 提交（用于后续自动压缩）
$ git commit --fixup abc1234

# 后续使用 rebase 自动压缩
$ git rebase -i --autosquash abc1234^
```

## 场景5：提交时跳过钩子

```sh
# 跳过 pre-commit 钩子（谨慎使用）
$ git commit --no-verify -m "Quick fix"
```

# 与其他命令的组合

## git commit + git add

```sh
# 标准流程
$ git add file.txt
$ git commit -m "Add file"
```

## git commit + git status

```sh
# 提交前检查
$ git status
$ git commit -m "Commit message"
```

## git commit + git log

```sh
# 提交后查看
$ git commit -m "Add feature"
$ git log --oneline -1
```

# 常见问题和解决方案

## 问题1：提交信息写错了

**解决方案**：
```sh
# 修改最后一次提交信息
$ git commit --amend -m "Correct message"
```

## 问题2：遗漏了文件

**解决方案**：
```sh
# 添加遗漏的文件
$ git add forgotten-file.txt

# 修改上次提交
$ git commit --amend --no-edit
```

## 问题3：想撤销提交

**解决方案**：
```sh
# 撤销最后一次提交（保留更改）
$ git reset --soft HEAD~1

# 撤销最后一次提交（丢弃更改）
$ git reset --hard HEAD~1
```

## 问题4：提交了错误的文件

**解决方案**：
```sh
# 从最后一次提交中移除文件（保留文件）
$ git reset HEAD~1 file.txt
$ git commit --amend
```

# 最佳实践

## 1. 编写清晰的提交信息

```sh
# ✅ 好的提交信息
$ git commit -m "feat: add user login functionality"

# ❌ 不好的提交信息
$ git commit -m "update"
$ git commit -m "fix"
```

## 2. 提交前检查

```sh
# 提交前查看更改
$ git status
$ git diff --cached
```

## 3. 小而频繁的提交

```sh
# ✅ 推荐：小而专注的提交
$ git commit -m "feat: add login button"
$ git commit -m "feat: add login form"

# ❌ 不推荐：大而杂的提交
$ git commit -m "update everything"
```

## 4. 使用提交信息模板

```sh
# 配置提交信息模板
$ git config --global commit.template ~/.gitmessage

# 创建模板文件
$ cat > ~/.gitmessage << EOF
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
EOF
```

## 5. 不要使用 --no-verify

```sh
# ❌ 不推荐：跳过钩子
$ git commit --no-verify

# ✅ 推荐：修复问题后再提交
$ git commit
```

# 总结

`git commit` 是保存更改到仓库的关键命令：

1. **基本用法**：`git commit -m "message"` 提交暂存区的更改
2. **修改提交**：`git commit --amend` 修改最后一次提交
3. **提交所有**：`git commit -a` 自动暂存并提交所有更改
4. **提交信息**：遵循规范，编写清晰的提交信息

**关键要点**：
- ✅ 编写清晰、描述性的提交信息
- ✅ 提交前检查更改
- ✅ 小而频繁的提交
- ✅ 遵循提交信息规范
- ❌ 不要跳过钩子（除非必要）
- ❌ 不要提交不相关的更改

