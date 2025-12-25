---
author: djaigo
title: git-status命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

`git status` 是 Git 中一个非常重要的命令，用于显示工作目录和暂存区的状态。它可以告诉你哪些文件被修改了，哪些文件被暂存了，哪些文件还没有被 Git 跟踪，以及当前分支的状态。

```sh
➜ git status --help
用法: git status [<选项>] [--] [<路径名>...]

    -v, --verbose         详细输出
    -s, --short           简短格式输出
    -b, --branch          显示分支信息
    -u, --untracked-files[=<模式>]
                         显示未跟踪的文件
                          模式: no, normal, all
    --ignored             显示被忽略的文件
    --porcelain[=<版本>]  机器可读的输出格式
    --long                长格式输出（默认）
    --null                使用NUL字符终止条目
    -z, --null            使用NUL字符终止条目
    --column[=<样式>]      以列格式显示未跟踪的文件
    --no-column           不以列格式显示未跟踪的文件
    -a, --all             显示所有文件的状态
```

# 基本语法

```sh
git status [选项] [--] [<路径名>...]
```

其中：
- `选项`：控制输出格式和显示内容的参数
- `路径名`：可选，指定要查看状态的特定文件或目录

# 常用选项

| 选项 | 说明 |
|------|------|
| `-s, --short` | 简短格式输出，使用状态码表示文件状态 |
| `-b, --branch` | 显示分支信息 |
| `-u, --untracked-files[=<模式>]` | 显示未跟踪的文件，模式可以是 no、normal、all |
| `--ignored` | 显示被忽略的文件 |
| `--porcelain[=<版本>]` | 机器可读的输出格式，适合脚本处理 |
| `--long` | 长格式输出（默认） |
| `-v, --verbose` | 详细输出，显示更多信息 |
| `--null` | 使用NUL字符终止条目，便于脚本处理 |

# 基本使用

## 查看当前状态

```sh
# 查看工作目录和暂存区的状态
➜ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/main.c

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        newfile.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

## 简短格式输出

```sh
# 使用简短格式，更简洁
➜ git status -s
M  README.md
 M src/main.c
?? newfile.txt
```

简短格式的状态码说明：
- ` `（空格）：未修改
- `M`：已修改（在暂存区）
- ` M`：已修改（在工作区，未暂存）
- `MM`：已修改（在暂存区和工作区都有修改）
- `A`：新添加的文件（已暂存）
- `D`：已删除（已暂存）
- ` D`：已删除（在工作区，未暂存）
- `R`：重命名
- `C`：复制
- `??`：未跟踪的文件
- `!!`：被忽略的文件（需要 `--ignored` 选项）

## 显示分支信息

```sh
# 显示当前分支信息
➜ git status -b
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```

## 显示未跟踪的文件

```sh
# 显示未跟踪的文件（默认模式）
➜ git status -u
# 或
➜ git status -u=normal

# 不显示未跟踪的文件
➜ git status -u=no

# 显示所有未跟踪的文件（包括子目录中的）
➜ git status -u=all
```

## 显示被忽略的文件

```sh
# 显示被 .gitignore 忽略的文件
➜ git status --ignored
On branch main
Your branch is up to date with 'origin/main'.

Ignored files:
  (use "git add -f <file>..." to include in what will be committed)
        build/
        *.o
        .env

nothing to commit, working tree clean
```

## 机器可读格式

```sh
# 使用 porcelain 格式，适合脚本处理
➜ git status --porcelain
M  README.md
 M src/main.c
?? newfile.txt

# 使用 null 终止符，更安全
➜ git status --porcelain -z
```

# 状态说明

## 工作区状态

Git 工作区中的文件可以处于以下几种状态：

1. **未跟踪（Untracked）**
   - 新创建的文件，还没有被 Git 跟踪
   - 使用 `git add` 添加到暂存区后开始跟踪

2. **已修改（Modified）**
   - 文件已被 Git 跟踪，但工作区中的内容与最后一次提交不同
   - 需要 `git add` 添加到暂存区

3. **已暂存（Staged）**
   - 文件已添加到暂存区，准备提交
   - 使用 `git commit` 提交到仓库

4. **未修改（Unmodified）**
   - 文件与最后一次提交相同
   - 不会在 `git status` 中显示

## 分支状态

`git status` 还会显示分支的状态：

- **up to date**：本地分支与远程分支同步
- **ahead**：本地分支领先远程分支 N 个提交
- **behind**：本地分支落后远程分支 N 个提交
- **diverged**：本地分支和远程分支已分叉

# 实际应用场景

## 提交前检查

```sh
# 提交前查看状态，确保所有更改都已暂存
➜ git status
# 检查是否有未暂存的更改
# 检查是否有未跟踪的文件需要添加
```

## 查看特定文件状态

```sh
# 查看特定文件的状态
➜ git status src/main.c

# 查看特定目录的状态
➜ git status src/
```

## 检查工作区是否干净

```sh
# 在脚本中检查工作区是否干净
if git diff-index --quiet HEAD --; then
    echo "Working tree is clean"
else
    echo "Working tree has changes"
fi

# 或者使用 status
if [ -z "$(git status --porcelain)" ]; then
    echo "Working tree is clean"
else
    echo "Working tree has changes"
fi
```

## 查看详细的差异信息

```sh
# 使用 verbose 选项查看更详细的信息
➜ git status -v
# 会显示每个文件的详细差异
```

## 统计文件数量

```sh
# 统计修改的文件数量
➜ git status -s | wc -l

# 统计未跟踪的文件数量
➜ git status -s | grep '^??' | wc -l

# 统计已暂存的文件数量
➜ git status -s | grep '^[MADRC]' | wc -l
```

# 与其他命令的组合

## git status + grep

```sh
# 查找特定类型的文件
➜ git status -s | grep '\.txt$'

# 查找已修改的文件
➜ git status -s | grep '^ M'

# 查找已暂存的文件
➜ git status -s | grep '^[MADRC]'
```

## git status + awk

```sh
# 提取文件名
➜ git status -s | awk '{print $2}'

# 只显示已修改的文件名
➜ git status -s | awk '/^ M/ {print $2}'
```

## git status + xargs

```sh
# 对所有已修改的文件执行命令
➜ git status -s | awk '/^ M/ {print $2}' | xargs ls -l

# 添加所有已修改的文件
➜ git status -s | awk '/^ M/ {print $2}' | xargs git add
```

# 常见问题与技巧

## 忽略某些文件

如果某些文件总是显示为未跟踪，可以添加到 `.gitignore`：

```sh
# 创建或编辑 .gitignore
echo "*.log" >> .gitignore
echo "build/" >> .gitignore

# 查看被忽略的文件
git status --ignored
```

## 查看特定路径的状态

```sh
# 只查看 src 目录的状态
➜ git status src/

# 只查看特定文件
➜ git status README.md
```

## 在脚本中使用

```sh
#!/bin/bash
# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "Warning: You have uncommitted changes"
    git status -s
    exit 1
fi

# 或者使用 status
if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: You have uncommitted changes"
    git status -s
    exit 1
fi
```

## 查看分支信息

```sh
# 查看当前分支和远程分支的关系
➜ git status -b

# 在简短格式中显示分支信息
➜ git status -sb
## main...origin/main [ahead 2]
 M src/main.c
```

## 过滤输出

```sh
# 只显示已修改的文件（不包括未跟踪的文件）
➜ git status -s | grep -v '^??'

# 只显示特定扩展名的文件
➜ git status -s | grep '\.\(c\|h\)$'
```

## 统计信息

```sh
# 统计各种状态的文件数量
➜ git status -s | awk '
    /^[MADRC]/ { staged++ }
    /^ [MAD]/ { modified++ }
    /^\?\?/ { untracked++ }
    END {
        print "Staged:", staged
        print "Modified:", modified
        print "Untracked:", untracked
    }'
```

# 输出格式详解

## 长格式输出（默认）

```
On branch <分支名>
Your branch is <状态> with '<远程>/<分支>'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        <文件状态>:   <文件名>

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        <文件状态>:   <文件名>

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        <文件名>
```

## 简短格式输出（-s）

```
<状态码> <文件名>
```

## Porcelain 格式（--porcelain）

```
<状态码1><状态码2> <文件名>
```

状态码说明：
- 第一个字符：暂存区的状态
- 第二个字符：工作区的状态

# 状态码详解

## 暂存区状态（第一个字符）

| 字符 | 说明 |
|------|------|
| ` ` | 无变化 |
| `A` | 添加 |
| `M` | 修改 |
| `D` | 删除 |
| `R` | 重命名 |
| `C` | 复制 |
| `U` | 未合并（冲突） |

## 工作区状态（第二个字符）

| 字符 | 说明 |
|------|------|
| ` ` | 无变化 |
| `M` | 修改 |
| `D` | 删除 |
| `T` | 类型改变 |
| `U` | 未合并（冲突） |
| `?` | 未跟踪 |

# 实际示例

## 示例1：正常状态

```sh
➜ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

## 示例2：有未暂存的修改

```sh
➜ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   src/main.c

no changes added to commit (use "git add" and/or "git commit -a")
```

## 示例3：有已暂存的修改

```sh
➜ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md

```

## 示例4：分支领先远程

```sh
➜ git status
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```

## 示例5：分支落后远程

```sh
➜ git status
On branch main
Your branch is behind 'origin/main' by 3 commits, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean
```

## 示例6：分支已分叉

```sh
➜ git status
On branch main
Your branch and 'origin/main' have diverged,
and have 2 and 3 different commits each, respectively.
  (use "git pull" to merge the remote branch into yours)

nothing to commit, working tree clean
```

# 注意事项

1. **性能考虑**：在大型仓库中，`git status` 可能需要一些时间，因为它需要检查所有文件的状态

2. **忽略文件**：被 `.gitignore` 忽略的文件默认不会显示，使用 `--ignored` 选项可以查看

3. **子模块**：如果仓库包含子模块，`git status` 也会显示子模块的状态

4. **脚本使用**：在脚本中使用时，建议使用 `--porcelain` 选项，输出格式更稳定

5. **路径限制**：可以指定路径来只查看特定文件或目录的状态

6. **颜色输出**：默认情况下，`git status` 会使用颜色高亮显示，在脚本中可能需要禁用颜色

# 参考文献
* [Git官方文档 - git-status](https://git-scm.com/docs/git-status)
* [Pro Git Book](https://git-scm.com/book)

