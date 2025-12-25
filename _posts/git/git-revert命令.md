---
author: djaigo
title: git-revert命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git revert 命令

## 简介

`git revert` 是 Git 中用于撤销提交的命令。与 `git reset` 不同，`git revert` 通过创建新提交来撤销更改，不会重写历史。

## 基本概念

### Revert vs Reset

| 特性 | Revert | Reset |
|------|--------|-------|
| **历史** | 不重写历史 | 重写历史 |
| **安全性** | 安全，适合已推送的提交 | 危险，只适合本地提交 |
| **操作** | 创建新提交 | 移动 HEAD 指针 |
| **协作** | 适合共享分支 | 不适合共享分支 |

### Revert 的作用

1. 撤销指定提交的更改
2. 创建新的提交记录撤销操作
3. 不改变历史记录
4. 适合已推送的提交

## 命令语法

```sh
# 撤销单个提交
git revert <提交>

# 撤销多个提交
git revert <提交1> <提交2>

# 撤销范围
git revert <提交1>..<提交2>
```

## 查看帮助文档

```sh
$ git revert --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-n, --no-commit` | 不自动提交，只修改工作区 |
| `-e, --edit` | 编辑提交信息（默认） |
| `--no-edit` | 使用自动生成的提交信息 |
| `-m <parent-number>` | 指定父提交（用于合并提交） |
| `-s, --signoff` | 添加 Signed-off-by 行 |
| `-S, --gpg-sign` | 使用 GPG 签名提交 |
| `--no-verify` | 跳过 pre-commit 钩子 |
| `--continue` | 继续 revert（解决冲突后） |
| `--abort` | 中止 revert |
| `--skip` | 跳过当前提交 |

# 基本使用

## 1. 撤销单个提交

```sh
# 撤销最后一次提交
$ git revert HEAD

# 撤销指定提交
$ git revert abc1234

# 撤销并自动提交
$ git revert --no-edit abc1234
```

## 2. 撤销多个提交

```sh
# 撤销多个提交（按顺序）
$ git revert abc1234 def5678

# 撤销范围（不包含起始提交）
$ git revert HEAD~3..HEAD
```

## 3. 撤销合并提交

```sh
# 撤销合并提交（需要指定主分支）
$ git revert -m 1 merge-commit-hash

# -m 1 表示保留第一个父提交（通常是主分支）
```

## 4. 撤销但不提交

```sh
# 撤销但不自动提交
$ git revert -n abc1234

# 可以修改后再提交
$ git add .
$ git commit -m "Revert with modifications"
```

## 5. 处理冲突

```sh
# 撤销时如果有冲突
$ git revert abc1234
# CONFLICT (content): Merge conflict in file.txt

# 解决冲突
$ vim file.txt
$ git add file.txt

# 继续 revert
$ git revert --continue

# 或中止
$ git revert --abort
```

# 实际应用场景

## 场景1：撤销已推送的提交

```sh
# 撤销已推送的提交（安全方式）
$ git revert abc1234

# 推送到远程
$ git push origin main
```

## 场景2：撤销错误的修复

```sh
# 发现修复有问题，撤销修复提交
$ git revert fix-commit-hash

# 提交撤销
$ git push origin main
```

## 场景3：撤销合并提交

```sh
# 撤销合并提交
$ git revert -m 1 merge-commit-hash

# 推送到远程
$ git push origin main
```

## 场景4：撤销多个相关提交

```sh
# 撤销一系列提交
$ git revert HEAD~3..HEAD

# 或逐个撤销
$ git revert commit1
$ git revert commit2
$ git revert commit3
```

## 场景5：撤销后修改

```sh
# 撤销但不提交
$ git revert -n abc1234

# 修改撤销内容
$ vim file.txt

# 提交修改后的撤销
$ git add .
$ git commit -m "Revert with modifications"
```

# 常见问题和解决方案

## 问题1：撤销合并提交失败

**错误信息**：
```
error: commit abc1234 is a merge but no -m option was given
```

**解决方案**：
```sh
# 指定主分支（通常是 -m 1）
$ git revert -m 1 merge-commit-hash
```

## 问题2：撤销时产生冲突

**解决方案**：
```sh
# 解决冲突
$ git status
$ vim conflicted-file.txt
$ git add conflicted-file.txt

# 继续
$ git revert --continue

# 或中止
$ git revert --abort
```

## 问题3：想撤销多个提交但顺序不对

**解决方案**：
```sh
# 按相反顺序撤销（从新到旧）
$ git revert --no-commit HEAD~2..HEAD
$ git commit -m "Revert multiple commits"
```

# 最佳实践

## 1. 用于已推送的提交

```sh
# ✅ 推荐：已推送的提交使用 revert
$ git revert abc1234
$ git push origin main

# ❌ 不要：已推送的提交使用 reset
$ git reset HEAD~1  # 危险！
```

## 2. 撤销后立即推送

```sh
# 撤销提交
$ git revert abc1234

# 立即推送到远程
$ git push origin main
```

## 3. 编写清晰的撤销信息

```sh
# 编辑撤销提交信息
$ git revert -e abc1234

# 或使用描述性信息
$ git revert -m "Revert problematic feature" abc1234
```

## 4. 撤销合并提交时指定主分支

```sh
# 撤销合并提交时明确指定主分支
$ git revert -m 1 merge-commit-hash
```

# 总结

`git revert` 是安全撤销提交的方式：

1. **基本用法**：`git revert <提交>` 撤销提交
2. **撤销合并**：`git revert -m 1` 撤销合并提交
3. **不提交**：`git revert -n` 撤销但不自动提交
4. **处理冲突**：解决冲突后使用 `--continue`

**关键要点**：
- ✅ 用于已推送的提交（安全）
- ✅ 不重写历史，创建新提交
- ✅ 适合共享分支
- ✅ 撤销合并提交时指定主分支
- ❌ 不要对已推送的提交使用 reset

