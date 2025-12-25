---
author: djaigo
title: git-rebase命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git rebase 命令

## 简介

`git rebase` 是 Git 中一个强大的命令，用于重新应用提交。它可以将一个分支的提交"重新播放"到另一个分支上，从而创建一条线性的提交历史。与 `git merge` 不同，rebase 会重写提交历史，使历史记录更加清晰和线性。

## 基本概念

### 什么是 Rebase

Rebase 的意思是"变基"，它会：
1. 找到当前分支和目标分支的共同祖先
2. 将当前分支的提交"撤销"（临时保存）
3. 将当前分支指向目标分支的最新提交
4. 重新应用之前保存的提交

### Rebase vs Merge

| 特性 | Rebase | Merge |
|------|--------|-------|
| **历史记录** | 线性、清晰 | 保留分支结构 |
| **提交历史** | 重写提交哈希 | 保留原始提交 |
| **合并提交** | 不创建合并提交 | 创建合并提交 |
| **适用场景** | 功能分支合并到主分支 | 需要保留分支历史 |
| **风险** | 重写历史，需谨慎 | 安全，不改变历史 |
| **冲突处理** | 逐个提交解决 | 一次性解决 |

### 何时使用 Rebase

✅ **适合使用 Rebase**：
- 功能分支合并到主分支前，保持历史线性
- 清理提交历史（交互式 rebase）
- 同步远程分支的更新

❌ **不适合使用 Rebase**：
- 已经推送到公共分支的提交
- 多人协作的共享分支
- 需要保留完整分支历史的情况

## 命令语法

```sh
# 基本 rebase
git rebase [选项] <目标分支>

# 交互式 rebase
git rebase -i [选项] <目标分支>

# 继续 rebase
git rebase --continue

# 中止 rebase
git rebase --abort

# 跳过当前提交
git rebase --skip
```

## 查看帮助文档

```sh
$ git rebase --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-i, --interactive` | 交互式 rebase，可以编辑、删除、合并提交 |
| `--continue` | 解决冲突后继续 rebase |
| `--abort` | 中止 rebase，回到 rebase 前的状态 |
| `--skip` | 跳过当前提交（通常用于空提交） |
| `--onto <newbase>` | 将提交重新应用到新的基础上 |
| `-p, --preserve-merges` | 保留合并提交（已废弃，使用 --rebase-merges） |
| `--rebase-merges` | 保留并重新创建合并提交 |
| `--autosquash` | 自动压缩标记为 fixup/squash 的提交 |
| `--autostash` | 自动暂存未提交的更改 |
| `-v, --verbose` | 详细输出 |
| `-q, --quiet` | 静默模式 |
| `--no-verify` | 跳过 pre-rebase 钩子 |
| `--exec <cmd>` | 在每个提交后执行命令 |
| `--root` | 从根提交开始 rebase |
| `--strategy=<strategy>` | 使用指定的合并策略 |
| `-X, --strategy-option=<option>` | 传递选项给合并策略 |

# 基本使用

## 1. 基本 Rebase

### 将当前分支 rebase 到目标分支

```sh
# 切换到功能分支
$ git checkout feature-branch

# 将功能分支 rebase 到主分支
$ git rebase main
```

**工作流程**：
1. Git 找到 `feature-branch` 和 `main` 的共同祖先
2. 临时保存 `feature-branch` 的提交
3. 将 `feature-branch` 指向 `main` 的最新提交
4. 重新应用保存的提交

### 示例

```sh
# 初始状态
main:        A---B---C
                    \
feature:             D---E

# 执行 git rebase main
$ git checkout feature
$ git rebase main

# 结果
main:        A---B---C
                    \
feature:             D'---E'
```

## 2. 交互式 Rebase

交互式 rebase 允许你编辑、删除、合并、重新排序提交。

### 基本用法

```sh
# 交互式 rebase 最近 3 个提交
$ git rebase -i HEAD~3

# 交互式 rebase 到指定分支
$ git rebase -i main

# 交互式 rebase 到指定提交
$ git rebase -i abc1234
```

### 交互式编辑器

打开编辑器后，会看到类似这样的内容：

```
pick abc1234 First commit
pick def5678 Second commit
pick ghi9012 Third commit

# Rebase abc1234..ghi9012 onto xyz3456 (3 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to the label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge message was
# .       specified). Use -c <commit> to reword the commit message.
#
# These lines can be re-ordered; they are executed from top to bottom.
```

### 交互式命令说明

| 命令 | 缩写 | 说明 |
|------|------|------|
| `pick` | `p` | 使用该提交（不做修改） |
| `reword` | `r` | 使用提交，但修改提交信息 |
| `edit` | `e` | 使用提交，但暂停以便修改 |
| `squash` | `s` | 使用提交，但合并到前一个提交 |
| `fixup` | `f` | 类似 squash，但丢弃提交信息 |
| `exec` | `x` | 执行 shell 命令 |
| `drop` | `d` | 删除提交 |
| `break` | `b` | 在此处暂停 |

## 3. 处理 Rebase 冲突

### 冲突发生

```sh
$ git rebase main
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt
error: could not apply abc1234... Commit message

# 解决冲突后
$ git add file.txt
$ git rebase --continue
```

### 解决冲突的步骤

```sh
# 1. 查看冲突文件
$ git status

# 2. 编辑冲突文件，解决冲突
$ vim conflicted-file.txt

# 3. 标记冲突已解决
$ git add conflicted-file.txt

# 4. 继续 rebase
$ git rebase --continue

# 或跳过当前提交（如果不需要）
$ git rebase --skip

# 或中止 rebase
$ git rebase --abort
```

## 4. 中止和继续 Rebase

```sh
# 中止 rebase，回到 rebase 前的状态
$ git rebase --abort

# 继续 rebase（解决冲突后）
$ git rebase --continue

# 跳过当前提交
$ git rebase --skip
```

# 高级用法

## 1. 使用 --onto 重新应用提交

```sh
# 将 feature 分支的提交重新应用到 new-base 上
$ git rebase --onto new-base old-base feature

# 示例：将 feature 分支的最后 3 个提交应用到 main
$ git rebase --onto main feature~3 feature
```

## 2. 保留合并提交

```sh
# 保留合并提交并重新创建
$ git rebase --rebase-merges main

# 旧方式（已废弃）
$ git rebase -p main
```

## 3. 自动压缩提交

```sh
# 自动压缩标记为 fixup 的提交
$ git rebase -i --autosquash HEAD~5

# 使用 fixup 提交
$ git commit --fixup abc1234
$ git rebase -i --autosquash abc1234^
```

## 4. 自动暂存未提交的更改

```sh
# rebase 前自动暂存，完成后自动恢复
$ git rebase --autostash main
```

## 5. 在每个提交后执行命令

```sh
# 在每个提交后运行测试
$ git rebase -i --exec "npm test" HEAD~5

# 在每个提交后运行 lint
$ git rebase -i --exec "npm run lint" main
```

## 6. 从根提交开始 Rebase

```sh
# 从第一个提交开始交互式 rebase
$ git rebase -i --root
```

# 实际应用场景

## 场景1：同步主分支的更新

```sh
# 在功能分支上同步主分支的更新
$ git checkout feature-branch
$ git fetch origin
$ git rebase origin/main

# 或一步完成
$ git pull --rebase origin main
```

## 场景2：清理提交历史

```sh
# 交互式 rebase 最近 5 个提交
$ git rebase -i HEAD~5

# 在编辑器中：
# - 将多个提交合并（squash）
# - 修改提交信息（reword）
# - 删除不必要的提交（drop）
# - 重新排序提交
```

## 场景3：修改提交信息

```sh
# 修改最近一次提交的信息
$ git rebase -i HEAD~1
# 将 pick 改为 reword

# 修改多个提交的信息
$ git rebase -i HEAD~3
# 将需要修改的提交改为 reword
```

## 场景4：合并多个提交

```sh
# 将多个提交合并成一个
$ git rebase -i HEAD~5

# 在编辑器中：
pick abc1234 Important feature
squash def5678 Fix typo
squash ghi9012 Update docs
squash jkl3456 Fix test
pick mno7890 Another feature

# 结果：前 4 个提交合并成一个
```

## 场景5：删除提交

```sh
# 删除某个提交
$ git rebase -i HEAD~5

# 在编辑器中：
pick abc1234 Commit 1
drop def5678 Commit 2  # 删除这个提交
pick ghi9012 Commit 3
```

## 场景6：重新排序提交

```sh
# 重新排列提交顺序
$ git rebase -i HEAD~5

# 在编辑器中调整顺序：
pick ghi9012 Commit 3
pick abc1234 Commit 1
pick def5678 Commit 2
```

## 场景7：拆分提交

```sh
# 拆分一个提交
$ git rebase -i HEAD~3

# 将需要拆分的提交改为 edit
edit abc1234 Large commit

# Git 会暂停，允许你：
$ git reset HEAD~1
$ git add file1.txt
$ git commit -m "First part"
$ git add file2.txt
$ git commit -m "Second part"
$ git rebase --continue
```

## 场景8：修复之前的提交

```sh
# 使用 fixup 自动修复
$ git commit --fixup abc1234

# 自动压缩到目标提交
$ git rebase -i --autosquash abc1234^
```

## 场景9：同步远程分支

```sh
# 拉取并 rebase（推荐）
$ git pull --rebase origin main

# 或分步执行
$ git fetch origin
$ git rebase origin/main
```

## 场景10：将功能分支 rebase 到主分支

```sh
# 工作流程
$ git checkout main
$ git pull origin main
$ git checkout feature-branch
$ git rebase main

# 解决冲突（如果有）
$ git add .
$ git rebase --continue

# 推送到远程（需要强制推送）
$ git push --force-with-lease origin feature-branch
```

# 与 Merge 的对比

## Merge 方式

```sh
# 使用 merge 合并分支
$ git checkout main
$ git merge feature-branch
```

**历史记录**：
```
main:        A---B---C-------M
                \           /
feature:         D---E-----/
```

## Rebase 方式

```sh
# 使用 rebase 合并分支
$ git checkout feature-branch
$ git rebase main
$ git checkout main
$ git merge feature-branch  # 快进合并
```

**历史记录**：
```
main:        A---B---C---D'---E'
```

## 选择建议

- **使用 Merge**：需要保留分支历史、多人协作、已推送的提交
- **使用 Rebase**：个人功能分支、清理历史、保持线性历史

# 常见问题和解决方案

## 问题1：Rebase 冲突

**问题**：rebase 过程中出现冲突

**解决方案**：
```sh
# 1. 查看冲突
$ git status

# 2. 解决冲突
$ vim conflicted-file.txt

# 3. 标记已解决
$ git add conflicted-file.txt

# 4. 继续
$ git rebase --continue

# 或中止
$ git rebase --abort
```

## 问题2：已经推送的提交被 rebase

**问题**：rebase 改变了提交历史，需要强制推送

**解决方案**：
```sh
# 使用 --force-with-lease（更安全）
$ git push --force-with-lease origin branch-name

# 或使用 --force（不推荐）
$ git push --force origin branch-name
```

**警告**：不要对共享分支使用 force push！

## 问题3：Rebase 过程中想放弃

**解决方案**：
```sh
# 中止 rebase，回到原始状态
$ git rebase --abort
```

## 问题4：交互式 rebase 编辑器不熟悉

**问题**：不知道如何使用 vim/emacs

**解决方案**：
```sh
# 配置使用其他编辑器
$ git config --global core.editor "code --wait"  # VS Code
$ git config --global core.editor "nano"          # Nano
$ git config --global core.editor "vim"           # Vim
```

## 问题5：Rebase 后提交哈希改变

**问题**：这是正常现象，rebase 会重写提交历史

**说明**：
- Rebase 会创建新的提交（新的哈希值）
- 原始提交仍然存在（通过 reflog 可以找回）
- 这是 rebase 的预期行为

## 问题6：Rebase 后丢失提交

**问题**：rebase 过程中误操作

**解决方案**：
```sh
# 使用 reflog 找回
$ git reflog

# 找到 rebase 前的提交
$ git checkout abc1234

# 创建新分支保存
$ git checkout -b recovery-branch
```

## 问题7：Rebase 太多次提交很慢

**问题**：rebase 大量提交时很慢

**解决方案**：
```sh
# 使用 --strategy-option 加速
$ git rebase --strategy-option=ours main

# 或分批 rebase
$ git rebase -i HEAD~10  # 先处理最近 10 个
```

# 最佳实践

## 1. 只对本地提交使用 Rebase

```sh
# ✅ 正确：本地功能分支
$ git rebase main

# ❌ 错误：已推送的共享分支
$ git rebase main  # 如果已经推送，不要这样做
```

## 2. 使用 --force-with-lease 而不是 --force

```sh
# ✅ 推荐：更安全
$ git push --force-with-lease origin branch-name

# ⚠️ 不推荐：可能覆盖其他人的提交
$ git push --force origin branch-name
```

## 3. 定期同步主分支

```sh
# 在功能分支开发过程中定期 rebase
$ git fetch origin
$ git rebase origin/main
```

## 4. 使用交互式 rebase 清理提交

```sh
# 提交前清理历史
$ git rebase -i HEAD~5

# 合并相关提交
# 修改提交信息
# 删除不必要的提交
```

## 5. 解决冲突后仔细检查

```sh
# 解决冲突后
$ git add .
$ git rebase --continue

# 检查结果
$ git log --oneline
$ git status
```

## 6. 使用 --autostash 自动暂存

```sh
# 自动处理未提交的更改
$ git rebase --autostash main
```

## 7. 团队协作时沟通

```sh
# 如果需要对共享分支 rebase，先与团队沟通
# 确保其他人知道历史会被重写
```

## 8. 使用 --rebase-merges 保留合并

```sh
# 需要保留合并提交时
$ git rebase --rebase-merges main
```

## 9. 配置 pull.rebase

```sh
# 配置 git pull 默认使用 rebase
$ git config --global pull.rebase true

# 之后可以直接使用
$ git pull
```

## 10. 备份重要分支

```sh
# rebase 前创建备份分支
$ git branch backup-branch
$ git rebase main
```

# 常用工作流

## 工作流1：功能分支开发

```sh
# 1. 创建功能分支
$ git checkout -b feature/new-feature main

# 2. 开发并提交
$ git add .
$ git commit -m "Add feature"

# 3. 同步主分支更新
$ git fetch origin
$ git rebase origin/main

# 4. 推送到远程
$ git push origin feature/new-feature

# 5. 创建 Pull Request
```

## 工作流2：清理提交历史

```sh
# 1. 查看提交历史
$ git log --oneline

# 2. 交互式 rebase
$ git rebase -i HEAD~10

# 3. 在编辑器中：
#    - squash 合并相关提交
#    - reword 修改提交信息
#    - drop 删除无用提交

# 4. 推送到远程
$ git push --force-with-lease origin branch-name
```

## 工作流3：修复之前的提交

```sh
# 1. 创建 fixup 提交
$ git commit --fixup abc1234

# 2. 自动压缩
$ git rebase -i --autosquash abc1234^

# 3. 推送到远程
$ git push --force-with-lease origin branch-name
```

# 安全注意事项

## ⚠️ 重要警告

1. **不要 rebase 已推送的公共分支**
   - 会重写历史，影响其他开发者
   - 如果必须，先与团队沟通

2. **使用 --force-with-lease 而不是 --force**
   - `--force-with-lease` 更安全
   - 会检查远程是否有新的提交

3. **Rebase 前备份重要分支**
   ```sh
   $ git branch backup-branch
   ```

4. **解决冲突后仔细检查**
   - 确保所有更改都正确
   - 运行测试验证

5. **团队协作时沟通**
   - 如果需要对共享分支 rebase，先通知团队
   - 确保其他人知道历史会被重写

# 总结

`git rebase` 是一个强大的命令，可以帮助你：

1. **保持线性历史**：创建清晰、线性的提交历史
2. **清理提交**：合并、删除、重新排序提交
3. **同步更新**：将功能分支同步到主分支的最新状态
4. **修改历史**：编辑提交信息、拆分提交

**关键要点**：
- ✅ 只对本地提交使用 rebase
- ✅ 使用 `--force-with-lease` 而不是 `--force`
- ✅ 定期同步主分支更新
- ✅ 解决冲突后仔细检查
- ❌ 不要 rebase 已推送的公共分支
- ❌ 团队协作时先沟通

通过合理使用 `git rebase`，可以创建更清晰、更易维护的 Git 历史记录。

