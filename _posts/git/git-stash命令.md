---
author: djaigo
title: git-stash命令
date: 2019-12-10 14:43:35
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories: 
  - git
tags: 
  - git
---

`git stash` 是 Git 中一个非常有用的命令，用于临时保存工作目录和暂存区的更改，而不需要提交。这对于需要快速切换分支、拉取远程更新或处理紧急任务时非常有用。

```sh
➜ git stash --help
用法: git stash list [<选项>]
   或: git stash show [<选项>] [<stash>]
   或: git stash drop [-q|--quiet] [<stash>]
   或: git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>]
   或: git stash branch <branchname> [<stash>]
   或: git stash [push [-p|--patch] [-k|--[no-]keep-index] [-q|--quiet]
          [-u|--include-untracked] [-a|--all] [-m|--message <message>]
          [--] [<pathspec>...]]
   或: git stash clear
   或: git stash create [<message>]
   或: git stash store [-m|--message <message>] [-q|--quiet] <commit>

    save [<message>]           将您的本地修改保存到新的stash中
    list [<options>]           列出所有的stash
    show [<options>] [<stash>]  展示在stash中的修改记录的差异
    drop [-q|--quiet] [<stash>] 从list中删除一个stash
    pop [--index] [-q|--quiet] [<stash>]  从stash列表中删除并应用最近的stash
    apply [--index] [-q|--quiet] [<stash>]  应用stash中的更改记录
    branch <branchname> [<stash>]  在最初创建存储的提交处分支
    clear                       删除所有stash
    create [<message>]          创建一个存储而不将其存储在ref命名空间中
    store                       将给定的提交存储到stash ref中
```

# 基本概念

## 什么是 Stash

Stash 是 Git 提供的一个临时存储区域，可以将当前工作目录和暂存区的更改保存起来，让工作目录回到干净的状态。这些更改可以稍后恢复。

## 应用场景

1. **切换分支**：需要切换到其他分支，但当前分支有未完成的更改
2. **拉取更新**：需要拉取远程更新，但本地有未提交的更改
3. **临时保存**：临时保存工作进度，处理其他紧急任务
4. **实验性更改**：保存实验性的更改，方便后续恢复或丢弃

## 与 commit 的区别

| 特性 | Stash | Commit |
|------|-------|--------|
| 历史记录 | 不记录在提交历史中 | 记录在提交历史中 |
| 可见性 | 只在本地，不推送到远程 | 可以推送到远程 |
| 用途 | 临时保存 | 永久保存 |
| 分支 | 可以在任何分支应用 | 属于特定分支 |
| 清理 | 可以随时删除 | 需要特殊操作删除 |

# 基本语法

```sh
git stash [push] [选项] [--] [<路径名>...]
git stash list [选项]
git stash show [选项] [<stash>]
git stash apply [选项] [<stash>]
git stash pop [选项] [<stash>]
git stash drop [选项] [<stash>]
git stash clear
git stash branch <分支名> [<stash>]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-u, --include-untracked` | 包含未跟踪的文件 |
| `-a, --all` | 包含所有文件，包括被忽略的文件 |
| `-k, --keep-index` | 保留暂存区的更改 |
| `-p, --patch` | 交互式选择要暂存的更改 |
| `-m, --message <消息>` | 为 stash 添加描述信息 |
| `-q, --quiet` | 静默模式，减少输出 |
| `--index` | 恢复时同时恢复暂存区状态 |

# 基本使用

## 保存更改（stash）

### 基本保存

```sh
# 保存当前工作目录和暂存区的所有更改
➜ git stash
Saved working directory and index state WIP on main: abc1234 Last commit message

# 保存并添加描述信息
➜ git stash save "WIP: working on feature"
Saved working directory and index state On main: WIP: working on feature
```

### 包含未跟踪的文件

```sh
# 默认情况下，stash 不包含未跟踪的文件
➜ git stash -u
# 或
➜ git stash --include-untracked

# 包含所有文件，包括被忽略的文件
➜ git stash -a
# 或
➜ git stash --all
```

### 保留暂存区的更改

```sh
# 使用 -k 选项，暂存区的更改不会被保存到 stash
➜ git stash -k
# 或
➜ git stash --keep-index
```

### 交互式选择

```sh
# 交互式选择要暂存的更改
➜ git stash -p
# 或
➜ git stash --patch
```

### 保存特定文件

```sh
# 只保存特定文件或目录的更改
➜ git stash push -- src/main.c
➜ git stash push -- src/
```

## 查看 Stash 列表

```sh
# 列出所有 stash
➜ git stash list
stash@{0}: WIP on main: abc1234 Last commit message
stash@{1}: On feature: WIP: working on feature
stash@{2}: WIP on main: def5678 Previous commit message
```

Stash 列表使用栈结构，最新的 stash 在顶部（stash@{0}）。

## 查看 Stash 内容

### 查看最新 stash 的更改

```sh
# 查看最新 stash 的统计信息
➜ git stash show
 src/main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

# 查看详细的差异
➜ git stash show -p
# 或
➜ git stash show --patch
diff --git a/src/main.c b/src/main.c
index 1234567..abcdefg 100644
--- a/src/main.c
+++ b/src/main.c
@@ -1,5 +1,14 @@
 #include <stdio.h>
+
+void new_function() {
+    // new code
+}
+
 int main() {
     return 0;
 }
```

### 查看特定 stash

```sh
# 查看 stash@{1} 的内容
➜ git stash show stash@{1}

# 查看 stash@{1} 的详细差异
➜ git stash show -p stash@{1}
```

## 应用 Stash

### apply（应用但不删除）

```sh
# 应用最新的 stash（不删除）
➜ git stash apply

# 应用特定的 stash
➜ git stash apply stash@{1}

# 应用并恢复暂存区状态
➜ git stash apply --index
```

`apply` 命令会应用 stash 中的更改，但不会从 stash 列表中删除。这意味着可以多次应用同一个 stash。

### pop（应用并删除）

```sh
# 应用最新的 stash 并删除
➜ git stash pop

# 应用特定的 stash 并删除
➜ git stash pop stash@{1}

# 应用并恢复暂存区状态
➜ git stash pop --index
```

`pop` 命令会应用 stash 中的更改，然后从 stash 列表中删除。如果应用时发生冲突，stash 不会被删除。

## 删除 Stash

### 删除特定 stash

```sh
# 删除最新的 stash
➜ git stash drop

# 删除特定的 stash
➜ git stash drop stash@{1}

# 静默删除（不显示确认信息）
➜ git stash drop -q stash@{1}
```

### 清空所有 stash

```sh
# 删除所有 stash
➜ git stash clear
```

**注意**：`clear` 命令会永久删除所有 stash，无法恢复，请谨慎使用。

## 从 Stash 创建分支

```sh
# 基于最新的 stash 创建新分支
➜ git stash branch feature-branch

# 基于特定的 stash 创建新分支
➜ git stash branch feature-branch stash@{1}
```

这个命令会：
1. 创建一个新分支
2. 切换到新分支
3. 应用 stash 中的更改
4. 如果成功应用，删除该 stash

这对于处理可能产生冲突的 stash 很有用。

# 实际应用场景

## 场景1：切换分支前保存更改

```sh
# 当前分支有未提交的更改
➜ git status
On branch feature
Changes not staged for commit:
        modified:   src/main.c

# 保存更改
➜ git stash
Saved working directory and index state WIP on feature: abc1234

# 切换到其他分支
➜ git checkout main

# 处理完其他任务后，切换回来
➜ git checkout feature

# 恢复更改
➜ git stash pop
```

## 场景2：拉取远程更新

```sh
# 本地有未提交的更改
➜ git status
Changes not staged for commit:
        modified:   src/main.c

# 保存更改
➜ git stash

# 拉取远程更新
➜ git pull origin main

# 恢复更改
➜ git stash pop
```

## 场景3：临时保存实验性更改

```sh
# 做一些实验性的更改
➜ git stash save "experimental: try new approach"

# 继续其他工作...

# 如果实验失败，直接丢弃
➜ git stash drop stash@{0}

# 如果实验成功，恢复并提交
➜ git stash pop
➜ git add .
➜ git commit -m "Implement new approach"
```

## 场景4：处理多个 Stash

```sh
# 保存第一个更改
➜ git stash save "WIP: feature A"

# 继续工作，保存第二个更改
➜ git stash save "WIP: feature B"

# 查看所有 stash
➜ git stash list
stash@{0}: WIP on main: WIP: feature B
stash@{1}: WIP on main: WIP: feature A

# 应用特定的 stash
➜ git stash apply stash@{1}
```

## 场景5：保存未跟踪的文件

```sh
# 有未跟踪的文件需要保存
➜ git status
Untracked files:
        newfile.txt

# 保存包括未跟踪的文件
➜ git stash -u
Saved working directory and index state WIP on main: abc1234

# 恢复时，未跟踪的文件也会恢复
➜ git stash pop
```

# 高级用法

## 交互式选择更改

```sh
# 交互式选择要暂存的更改
➜ git stash -p
diff --git a/src/main.c b/src/main.c
index 1234567..abcdefg 100644
--- a/src/main.c
+++ b/src/main.c
@@ -1,5 +1,10 @@
 #include <stdio.h>
+
+void new_function() {
+    // new code
+}
+
 int main() {
     return 0;
 }
Stash this hunk [y,n,q,a,d,/,e,?]? y
```

交互式选项：
- `y`：暂存这个块
- `n`：不暂存这个块
- `q`：退出
- `a`：暂存这个块和后面的所有块
- `d`：不暂存这个块和后面的所有块
- `/`：搜索匹配的行
- `e`：手动编辑块
- `?`：显示帮助

## 恢复暂存区状态

```sh
# 保存时保留暂存区
➜ git stash -k

# 应用时恢复暂存区状态
➜ git stash apply --index
```

## 基于 Stash 创建分支

```sh
# 如果直接应用 stash 可能产生冲突，可以创建新分支
➜ git stash branch fix-conflict stash@{1}
Switched to a new branch 'fix-conflict'
On branch fix-conflict
Changes to be committed:
        modified:   src/main.c
Dropped stash@{1} (abc1234...)
```

## 查看 Stash 的详细信息

```sh
# 查看 stash 的完整信息
➜ git stash show -p stash@{0}

# 查看 stash 的统计信息
➜ git stash show --stat stash@{0}

# 查看 stash 创建时的提交信息
➜ git log --oneline --graph --all --reflog | grep stash
```

# 常见问题与技巧

## 冲突处理

当应用 stash 时可能发生冲突：

```sh
➜ git stash pop
Auto-merging src/main.c
CONFLICT (content): Merge conflict in src/main.c
```

解决方法：
1. 解决冲突
2. 添加解决后的文件：`git add src/main.c`
3. 如果使用 `pop`，冲突解决后 stash 会自动删除
4. 如果使用 `apply`，需要手动删除：`git stash drop`

## 查看 Stash 的完整内容

```sh
# 查看 stash 中所有文件的完整差异
➜ git stash show -p stash@{0}

# 查看特定文件的差异
➜ git diff stash@{0} -- src/main.c
```

## 比较 Stash 和当前工作目录

```sh
# 比较 stash 和当前工作目录
➜ git diff stash@{0}

# 比较 stash 和特定提交
➜ git diff stash@{0} HEAD
```

## 重命名 Stash

Git 不直接支持重命名 stash，但可以通过以下方式：

```sh
# 创建一个新的 stash 并删除旧的
➜ git stash show -p stash@{0} | git stash push -m "New message"
➜ git stash drop stash@{1}
```

## 清理旧的 Stash

```sh
# 查看所有 stash
➜ git stash list

# 删除特定的 stash
➜ git stash drop stash@{5}

# 或者清空所有
➜ git stash clear
```

## 在脚本中使用

```sh
#!/bin/bash
# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "Saving uncommitted changes..."
    git stash save "Auto-save before script"
    STASHED=1
fi

# 执行脚本操作...

# 如果有保存的更改，恢复它们
if [ "$STASHED" = "1" ]; then
    echo "Restoring uncommitted changes..."
    git stash pop
fi
```

## 查看 Stash 的创建时间

```sh
# 使用 reflog 查看 stash 的创建时间
➜ git reflog show stash
abc1234 stash@{0}: WIP on main: def5678 Last commit
def5678 stash@{1}: On feature: WIP: working on feature
```

## 只保存特定文件

```sh
# 只保存特定文件的更改
➜ git stash push -- src/main.c src/utils.c

# 只保存特定目录的更改
➜ git stash push -- src/
```

## 查看 Stash 的统计信息

```sh
# 查看统计信息
➜ git stash show --stat stash@{0}
 src/main.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)
```

# 最佳实践

1. **添加描述信息**：使用 `-m` 选项为 stash 添加有意义的描述
   ```sh
   git stash save -m "WIP: implementing user authentication"
   ```

2. **及时清理**：定期清理不再需要的 stash
   ```sh
   git stash list
   git stash drop stash@{n}
   ```

3. **使用分支处理复杂情况**：如果应用 stash 可能产生冲突，使用 `git stash branch`
   ```sh
   git stash branch feature-branch stash@{0}
   ```

4. **检查冲突**：应用 stash 后检查是否有冲突
   ```sh
   git stash pop
   git status  # 检查是否有冲突
   ```

5. **保存未跟踪的文件**：如果需要保存新文件，使用 `-u` 选项
   ```sh
   git stash -u
   ```

6. **不要长期保存**：Stash 应该用于临时保存，不应该长期保存重要更改

# 注意事项

1. **Stash 只在本地**：Stash 不会推送到远程仓库，只在本地存在

2. **可能丢失**：如果删除了包含 stash 的引用，stash 可能会丢失（虽然可以通过 reflog 恢复）

3. **冲突处理**：应用 stash 时可能产生冲突，需要手动解决

4. **暂存区状态**：默认情况下，`apply` 不会恢复暂存区状态，需要使用 `--index` 选项

5. **未跟踪的文件**：默认情况下，未跟踪的文件不会被保存，需要使用 `-u` 或 `-a` 选项

6. **大文件**：Stash 不适合保存大文件，应该使用其他方式

# 参考文献
* [Git官方文档 - git-stash](https://git-scm.com/docs/git-stash)
* [Pro Git Book](https://git-scm.com/book)
