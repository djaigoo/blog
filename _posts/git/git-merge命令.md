---
author: djaigo
title: git-merge命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

`git merge` 是 Git 中一个核心命令，用于将两个或多个分支的更改合并到一起。它是 Git 分支工作流的基础，允许开发者将不同分支的代码整合到当前分支。

```sh
➜ git merge --help
用法: git merge [<选项>] [<提交>...]
   或: git merge --abort
   或: git merge --continue

选项:
    -n, --no-stat           合并后不显示差异统计
    --stat                  合并后显示差异统计
    --summary               合并后显示简短摘要
    --log[=<n>]             在提交信息中包含最多<n>个提交的日志
    --squash                 创建一个合并提交，但不实际合并
    --commit                 完成合并后自动提交（默认）
    --no-commit              完成合并后不自动提交
    -e, --edit               在提交前编辑提交信息
    --no-edit                使用自动生成的提交信息
    -m, --message=<msg>      设置合并提交信息
    -F, --file=<file>        从文件读取提交信息
    --ff, --no-ff, --ff-only 控制快进合并
    -S, --gpg-sign[=<key-id>] 使用 GPG 签名提交
    --no-verify              跳过 pre-commit 和 commit-msg 钩子
    --no-gpg-sign            不使用 GPG 签名
    -s, --strategy=<strategy> 使用指定的合并策略
    -X, --strategy-option=<option> 传递选项给合并策略
    --verify-signatures      验证要合并的提交的签名
    --summary                显示合并摘要
    -q, --quiet              静默模式
    -v, --verbose            详细输出
    --progress               显示进度
    --no-progress            不显示进度
    --allow-unrelated-histories 允许合并不相关的历史
    -r, --rebase[=<false|true|preserve|interactive>] 合并后变基
    --abort                  中止正在进行的合并
    --continue               继续正在进行的合并
    --quit                   退出但不中止合并
    --allow-empty            允许空提交
```

# 基本概念

## 什么是合并

合并是将两个或多个分支的更改整合到一起的过程。Git 会尝试自动合并更改，如果两个分支修改了不同的文件或文件的不同部分，合并会自动完成。如果两个分支修改了同一文件的同一部分，就会产生冲突，需要手动解决。

## 合并的类型

1. **快进合并（Fast-forward）**：当目标分支是源分支的直接祖先时，Git 只需移动指针
2. **三方合并（3-way merge）**：当两个分支有分叉时，Git 创建一个新的合并提交
3. **压缩合并（Squash merge）**：将多个提交压缩成一个提交

# 基本语法

```sh
git merge [选项] <提交>...
git merge --abort
git merge --continue
```

其中：
- `选项`：控制合并行为的参数
- `提交`：要合并的分支或提交（可以是分支名、标签、提交哈希等）
- `--abort`：中止正在进行的合并
- `--continue`：继续完成合并（解决冲突后）

# 常用选项

| 选项 | 说明 |
|------|------|
| `--no-ff` | 即使可以快进，也创建合并提交 |
| `--ff-only` | 只允许快进合并，否则失败 |
| `--squash` | 压缩合并，将多个提交压缩成一个 |
| `--no-commit` | 合并后不自动提交，允许检查合并结果 |
| `-m, --message=<msg>` | 设置合并提交信息 |
| `--no-edit` | 使用自动生成的提交信息，不打开编辑器 |
| `-e, --edit` | 在提交前编辑提交信息 |
| `-q, --quiet` | 静默模式，减少输出 |
| `-v, --verbose` | 详细输出 |
| `--abort` | 中止正在进行的合并 |
| `--continue` | 继续完成合并 |
| `--stat` | 显示合并后的差异统计 |
| `-s, --strategy=<strategy>` | 指定合并策略 |
| `-X, --strategy-option=<option>` | 传递选项给合并策略 |
| `--allow-unrelated-histories` | 允许合并不相关的历史 |

# 基本使用

## 合并分支

### 基本合并

```sh
# 合并 feature 分支到当前分支
➜ git merge feature

# 合并后，当前分支会包含 feature 分支的所有更改
```

### 合并示例

```sh
# 假设当前在 main 分支
➜ git branch
* main
  feature

# 合并 feature 分支
➜ git merge feature
Updating abc1234..def5678
Fast-forward
 src/main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)
```

## 快进合并（Fast-forward）

当目标分支是源分支的直接祖先时，Git 会执行快进合并，只需移动分支指针。

```sh
# 快进合并（默认行为）
➜ git merge feature

# 如果不想快进，强制创建合并提交
➜ git merge --no-ff feature
```

### 快进合并示例

```sh
# 创建并切换到 feature 分支
➜ git checkout -b feature
Switched to a new branch 'feature'

# 做一些提交
➜ echo "new feature" > feature.txt
➜ git add feature.txt
➜ git commit -m "Add new feature"

# 切换回 main 分支
➜ git checkout main
Switched to branch 'main'

# 合并 feature 分支（快进）
➜ git merge feature
Updating abc1234..def5678
Fast-forward
 feature.txt | 1 +
 1 file changed, 1 insertion(+)
```

## 三方合并（3-way Merge）

当两个分支有分叉时，Git 会创建一个新的合并提交。

```sh
# 三方合并
➜ git merge feature

# 这会创建一个合并提交，包含两个分支的更改
```

### 三方合并示例

```sh
# 在 main 分支上做一些更改
➜ git checkout main
➜ echo "main change" >> main.txt
➜ git add main.txt
➜ git commit -m "Change in main"

# 在 feature 分支上做一些更改
➜ git checkout feature
➜ echo "feature change" >> feature.txt
➜ git add feature.txt
➜ git commit -m "Change in feature"

# 切换回 main 并合并
➜ git checkout main
➜ git merge feature
Merge made by the 'recursive' strategy.
 feature.txt | 1 +
 1 file changed, 1 insertion(+)
```

## 压缩合并（Squash Merge）

将多个提交压缩成一个提交，保持历史记录整洁。

```sh
# 压缩合并
➜ git merge --squash feature

# 压缩合并后需要手动提交
➜ git commit -m "Merge feature branch (squashed)"
```

### 压缩合并示例

```sh
# 压缩合并 feature 分支
➜ git merge --squash feature
Squashed commit of the following 3 commits:
  abc1234 Add feature A
  def5678 Add feature B
  ghi9012 Fix bug in feature

# 查看状态
➜ git status
On branch main
Changes to be committed:
        modified:   src/main.c
        new file:   feature.txt

# 提交压缩后的更改
➜ git commit -m "Merge feature branch (squashed)"
```

# 合并策略

## 可用的合并策略

| 策略 | 说明 |
|------|------|
| `resolve` | 三路合并策略，用于两个分支的合并 |
| `recursive` | 递归合并策略（默认），用于两个分支的合并，可以处理多个共同祖先 |
| `octopus` | 章鱼合并策略，用于合并多个分支 |
| `ours` | 使用当前分支的版本，忽略要合并的分支 |
| `subtree` | 子树合并策略，用于合并子树 |

## 指定合并策略

```sh
# 使用 resolve 策略
➜ git merge -s resolve feature

# 使用 ours 策略（使用当前分支的版本）
➜ git merge -s ours feature

# 使用 octopus 策略合并多个分支
➜ git merge -s octopus branch1 branch2 branch3
```

## 合并策略选项

```sh
# 使用 ours 选项（冲突时使用当前分支的版本）
➜ git merge -X ours feature

# 使用 theirs 选项（冲突时使用要合并分支的版本）
➜ git merge -X theirs feature

# 忽略空白字符的差异
➜ git merge -X ignore-all-space feature

# 忽略空白字符数量的变化
➜ git merge -X ignore-space-change feature

# 重命名检测
➜ git merge -X rename-threshold=50 feature
```

# 冲突处理

## 什么是冲突

当两个分支修改了同一文件的同一部分时，Git 无法自动决定使用哪个版本，就会产生冲突。

## 冲突示例

```sh
# 尝试合并时发生冲突
➜ git merge feature
Auto-merging src/main.c
CONFLICT (content): Merge conflict in src/main.c
Automatic merge failed; fix conflicts and then commit the result.
```

## 冲突标记

冲突文件会包含冲突标记：

```c
<<<<<<< HEAD
// 当前分支的代码
printf("Current branch\n");
=======
// 要合并分支的代码
printf("Feature branch\n");
>>>>>>> feature
```

## 解决冲突

### 步骤1：查看冲突文件

```sh
# 查看冲突状态
➜ git status
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   src/main.c
```

### 步骤2：编辑冲突文件

手动编辑冲突文件，选择要保留的代码，删除冲突标记：

```c
// 解决后的代码
printf("Merged code\n");
```

### 步骤3：标记冲突已解决

```sh
# 添加解决后的文件
➜ git add src/main.c

# 或者添加所有已解决的文件
➜ git add .
```

### 步骤4：完成合并

```sh
# 继续完成合并
➜ git merge --continue

# 或者直接提交
➜ git commit
```

## 中止合并

如果不想完成合并，可以中止：

```sh
# 中止合并，恢复到合并前的状态
➜ git merge --abort
```

## 使用合并工具

```sh
# 使用配置的合并工具
➜ git mergetool

# 配置合并工具（例如使用 vimdiff）
➜ git config --global merge.tool vimdiff
```

# 实际应用场景

## 场景1：合并功能分支

```sh
# 开发完功能后，合并到主分支
➜ git checkout main
Switched to branch 'main'

# 拉取最新代码
➜ git pull origin main

# 合并功能分支
➜ git merge feature

# 如果有冲突，解决后继续
➜ git add .
➜ git commit

# 推送到远程
➜ git push origin main
```

## 场景2：合并多个提交

```sh
# 使用压缩合并，将多个提交压缩成一个
➜ git merge --squash feature
➜ git commit -m "Merge feature: Add new functionality"
```

## 场景3：合并时保留分支历史

```sh
# 使用 --no-ff 强制创建合并提交
➜ git merge --no-ff feature

# 这样可以保留分支的完整历史
```

## 场景4：只允许快进合并

```sh
# 使用 --ff-only，如果不是快进则失败
➜ git merge --ff-only feature

# 如果不是快进合并，会报错并退出
```

## 场景5：合并不相关的历史

```sh
# 合并两个不相关的仓库
➜ git merge --allow-unrelated-histories other-repo/main
```

## 场景6：合并时使用特定策略

```sh
# 冲突时使用当前分支的版本
➜ git merge -X ours feature

# 冲突时使用要合并分支的版本
➜ git merge -X theirs feature
```

# 高级用法

## 合并特定提交

```sh
# 合并特定的提交（cherry-pick）
➜ git cherry-pick abc1234

# 合并多个提交
➜ git cherry-pick abc1234 def5678
```

## 合并时编辑提交信息

```sh
# 合并时编辑提交信息
➜ git merge -e feature

# 或者直接指定提交信息
➜ git merge -m "Merge feature branch" feature
```

## 合并后不自动提交

```sh
# 合并后不自动提交，允许检查合并结果
➜ git merge --no-commit feature

# 检查合并结果
➜ git status
➜ git diff --cached

# 如果满意，手动提交
➜ git commit -m "Merge feature branch"
```

## 合并时显示统计信息

```sh
# 合并后显示差异统计
➜ git merge --stat feature

# 合并后显示简短摘要
➜ git merge --summary feature
```

## 合并时包含提交日志

```sh
# 在合并提交信息中包含最多 10 个提交的日志
➜ git merge --log=10 feature
```

## 验证签名

```sh
# 合并时验证提交的签名
➜ git merge --verify-signatures feature
```

# 常见问题与技巧

## 问题1：如何查看合并前的差异？

```sh
# 合并前查看差异
➜ git diff main..feature

# 或者
➜ git diff main feature
```

## 问题2：如何撤销合并？

```sh
# 如果合并还没有推送到远程
➜ git reset --hard HEAD~1

# 如果合并已经推送到远程
➜ git revert -m 1 HEAD
```

## 问题3：如何查看合并历史？

```sh
# 查看合并提交
➜ git log --merges

# 查看合并提交的图形化历史
➜ git log --graph --oneline --all
```

## 问题4：如何只合并特定文件？

```sh
# 不能直接只合并特定文件，但可以这样做：
# 1. 合并但不提交
➜ git merge --no-commit feature

# 2. 重置不需要的文件
➜ git reset HEAD unwanted-file.txt
➜ git checkout -- unwanted-file.txt

# 3. 提交
➜ git commit -m "Merge specific files from feature"
```

## 问题5：如何解决大量冲突？

```sh
# 使用合并工具
➜ git mergetool

# 或者使用策略选项自动解决
➜ git merge -X ours feature  # 使用当前分支的版本
➜ git merge -X theirs feature  # 使用要合并分支的版本
```

## 技巧1：合并前先更新

```sh
# 合并前先拉取最新代码
➜ git pull origin main

# 然后再合并
➜ git merge feature
```

## 技巧2：使用压缩合并保持历史整洁

```sh
# 对于功能分支，使用压缩合并
➜ git merge --squash feature
➜ git commit -m "Add feature: description"
```

## 技巧3：合并时添加详细描述

```sh
# 使用 -m 选项添加详细的合并信息
➜ git merge -m "Merge feature branch

This merge adds the following features:
- Feature A
- Feature B
- Bug fixes" feature
```

## 技巧4：合并后立即测试

```sh
# 合并后不自动提交，先测试
➜ git merge --no-commit feature

# 运行测试
➜ make test

# 如果测试通过，提交
➜ git commit -m "Merge feature branch"
```

## 技巧5：查看合并的统计信息

```sh
# 合并后查看统计信息
➜ git merge --stat feature

# 或者使用 diffstat
➜ git merge feature | diffstat
```

# 最佳实践

1. **合并前更新**：合并前先拉取最新代码，确保本地分支是最新的

2. **使用描述性的提交信息**：合并时添加清晰的提交信息，说明合并的内容

3. **解决冲突后测试**：解决冲突后，运行测试确保代码正常工作

4. **使用压缩合并**：对于功能分支，考虑使用压缩合并保持主分支历史整洁

5. **保留合并历史**：对于重要的合并，使用 `--no-ff` 保留完整的合并历史

6. **及时合并**：不要长时间不合并，避免积累太多冲突

7. **合并后立即推送**：合并完成后，及时推送到远程仓库

8. **使用合并工具**：对于复杂冲突，使用合并工具而不是手动编辑

# 注意事项

1. **工作区必须干净**：合并前确保工作区没有未提交的更改，可以使用 `git stash` 保存

2. **冲突解决**：解决冲突后必须使用 `git add` 标记文件已解决，然后提交

3. **合并提交**：合并会创建一个新的提交，即使没有冲突

4. **快进合并**：默认情况下，如果可以快进，Git 会执行快进合并

5. **合并策略**：不同的合并策略适用于不同的场景，选择合适的策略

6. **远程合并**：合并本地分支不会自动推送到远程，需要手动推送

7. **撤销合并**：如果合并还没有推送，可以使用 `git reset` 撤销；如果已经推送，需要使用 `git revert`

8. **合并多个分支**：可以一次合并多个分支，但需要谨慎使用

# 与其他命令的区别

## merge vs rebase

| 特性 | merge | rebase |
|------|-------|--------|
| 历史记录 | 保留分支历史 | 重写历史，线性化 |
| 提交数量 | 创建合并提交 | 不创建合并提交 |
| 适用场景 | 共享分支 | 个人分支 |
| 冲突处理 | 一次解决所有冲突 | 逐个提交解决冲突 |

## merge vs cherry-pick

| 特性 | merge | cherry-pick |
|------|-------|-------------|
| 范围 | 合并整个分支 | 只合并特定提交 |
| 历史 | 保留分支关系 | 不保留分支关系 |
| 用途 | 整合分支 | 选择性应用提交 |

# 参考文献
* [Git官方文档 - git-merge](https://git-scm.com/docs/git-merge)
* [Pro Git Book](https://git-scm.com/book)
* [Git Merge Strategies](https://git-scm.com/docs/merge-strategies)

