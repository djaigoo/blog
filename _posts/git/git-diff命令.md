---
author: djaigo
title: git-diff命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

# git diff 命令

## 简介

`git diff` 是 Git 中一个非常重要的命令，用于显示文件之间的差异。它可以比较工作区、暂存区、不同提交之间的差异，帮助开发者了解代码的变化。

## 基本概念

Git 中有三个主要区域：
1. **工作区（Working Directory）**：当前正在编辑的文件
2. **暂存区（Staging Area / Index）**：已使用 `git add` 添加的文件
3. **仓库（Repository）**：已提交的版本

`git diff` 可以比较这些区域之间的差异。

## 命令语法

```sh
git diff [选项] [--] [<路径名>...]
git diff [选项] --cached [<提交>] [--] [<路径名>...]
git diff [选项] <提交> [--] [<路径名>...]
git diff [选项] <提交1> <提交2> [--] [<路径名>...]
git diff [选项] <提交1>..<提交2> [--] [<路径名>...]
git diff [选项] <提交1>...<提交2> [--] [<路径名>...]
```

## 查看帮助文档

```sh
$ git diff --help
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `--cached, --staged` | 比较暂存区和最后一次提交 |
| `-p, -u, --unified=<n>` | 显示统一格式的差异，n 为上下文行数 |
| `--stat` | 显示统计信息（修改的文件和行数） |
| `--name-only` | 只显示文件名 |
| `--name-status` | 显示文件名和状态（M/A/D/R） |
| `-w, --ignore-all-space` | 忽略所有空白字符的差异 |
| `-b, --ignore-space-change` | 忽略空白字符数量的变化 |
| `--ignore-blank-lines` | 忽略空白行的差异 |
| `-S<string>` | 显示包含指定字符串的更改 |
| `-G<regex>` | 显示匹配正则表达式的更改 |
| `--color[=<when>]` | 使用颜色高亮显示差异 |
| `--no-color` | 不使用颜色 |
| `-R` | 反向显示差异（新文件在前） |
| `--word-diff` | 按单词显示差异 |
| `--word-diff-regex=<regex>` | 使用正则表达式定义单词边界 |
| `--ignore-submodules` | 忽略子模块的更改 |
| `--submodule=<format>` | 指定子模块差异的格式 |
| `--ext-diff` | 允许执行外部 diff 工具 |
| `--no-ext-diff` | 禁止执行外部 diff 工具 |
| `--no-index` | 比较两个路径，即使它们不在 Git 仓库中 |

# 基本使用

## 1. 比较工作区和暂存区

显示工作区中已修改但未暂存的文件差异（默认行为）。

```sh
# 显示所有修改文件的差异
$ git diff

# 显示指定文件的差异
$ git diff README.md

# 显示指定目录的差异
$ git diff src/
```

**示例输出**：
```diff
diff --git a/src/main.c b/src/main.c
index 1234567..abcdefg 100644
--- a/src/main.c
+++ b/src/main.c
@@ -10,7 +10,7 @@ int main() {
     printf("Hello, World!\n");
-    printf("Old message\n");
+    printf("New message\n");
     return 0;
 }
```

## 2. 比较暂存区和最后一次提交

使用 `--cached` 或 `--staged` 选项。

```sh
# 显示暂存区与最后一次提交的差异
$ git diff --cached

# 或使用 --staged（Git 1.6.1+）
$ git diff --staged

# 显示指定文件的差异
$ git diff --cached README.md
```

## 3. 比较工作区和最后一次提交

```sh
# 显示工作区与最后一次提交的差异（包括已暂存和未暂存的更改）
$ git diff HEAD

# 显示指定文件的差异
$ git diff HEAD README.md
```

## 4. 比较两次提交

```sh
# 比较两个提交
$ git diff commit1 commit2

# 使用提交哈希
$ git diff abc1234 def5678

# 使用相对引用
$ git diff HEAD~1 HEAD

# 使用 .. 语法（等价）
$ git diff commit1..commit2

# 使用 ... 语法（比较两个提交的共同祖先和第二个提交）
$ git diff commit1...commit2
```

## 5. 比较分支

```sh
# 比较两个分支
$ git diff branch1 branch2

# 比较当前分支和另一个分支
$ git diff main develop

# 比较当前分支和远程分支
$ git diff main origin/main

# 使用 .. 语法
$ git diff main..develop

# 使用 ... 语法（比较共同祖先）
$ git diff main...develop
```

## 6. 比较提交和文件

```sh
# 比较特定提交和当前工作区
$ git diff HEAD src/main.c

# 比较两个提交中的特定文件
$ git diff commit1 commit2 -- README.md

# 比较提交和暂存区
$ git diff --cached HEAD~1
```

# 输出格式说明

## 统一格式（Unified Format）

Git 默认使用统一格式显示差异：

```diff
diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,3 @@
 line 1
-line 2 (old)
+line 2 (new)
 line 3
```

**格式说明**：
- `--- a/file.txt`：原始文件
- `+++ b/file.txt`：修改后的文件
- `@@ -1,3 +1,3 @@`：块头，表示从第1行开始，共3行
- `-`：删除的行
- `+`：添加的行
- 没有符号：未修改的行

## 上下文行数

```sh
# 显示 3 行上下文（默认）
$ git diff

# 显示 5 行上下文
$ git diff -U5

# 显示 10 行上下文
$ git diff --unified=10
```

# 常用选项详解

## --stat：显示统计信息

```sh
# 显示修改统计
$ git diff --stat
README.md    | 2 +-
src/main.c   | 5 +++--
2 files changed, 4 insertions(+), 3 deletions(-)

# 显示更详细的统计
$ git diff --stat --summary
```

## --name-only：只显示文件名

```sh
# 只显示修改的文件名
$ git diff --name-only
README.md
src/main.c
src/utils.h
```

## --name-status：显示文件名和状态

```sh
# 显示文件名和状态
$ git diff --name-status
M       README.md
M       src/main.c
A       src/utils.h
D       oldfile.txt
R100    oldname.txt    newname.txt
```

状态码说明：
- `M`：修改（Modified）
- `A`：添加（Added）
- `D`：删除（Deleted）
- `R`：重命名（Renamed）
- `C`：复制（Copied）

## 忽略空白字符

```sh
# 忽略所有空白字符的差异
$ git diff -w

# 忽略空白字符数量的变化
$ git diff -b

# 忽略空白行
$ git diff --ignore-blank-lines

# 组合使用
$ git diff -w -b --ignore-blank-lines
```

## 颜色输出

```sh
# 启用颜色（默认）
$ git diff --color

# 禁用颜色
$ git diff --no-color

# 总是使用颜色
$ git diff --color=always

# 自动检测（默认）
$ git diff --color=auto
```

## 搜索特定更改

```sh
# 显示包含特定字符串的更改
$ git diff -S"function_name"

# 显示匹配正则表达式的更改
$ git diff -G"^import"

# 组合使用
$ git diff -S"TODO" --stat
```

## 单词级别差异

```sh
# 按单词显示差异
$ git diff --word-diff

# 使用自定义正则表达式定义单词
$ git diff --word-diff-regex='[A-Za-z0-9]+'
```

**示例输出**：
```diff
diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
--- a/file.txt
+++ b/file.txt
@@ -1 +1 @@
This is [-old-]{+new+} text.
```

# 高级用法

## 比较特定路径

```sh
# 比较特定文件
$ git diff HEAD -- README.md

# 比较特定目录
$ git diff HEAD -- src/

# 比较多个文件
$ git diff HEAD -- file1.txt file2.txt

# 使用通配符
$ git diff HEAD -- "*.py"
```

## 限制上下文行数

```sh
# 不显示上下文
$ git diff -U0

# 显示 1 行上下文
$ git diff -U1

# 显示更多上下文
$ git diff -U20
```

## 反向显示

```sh
# 反向显示差异（新文件在前）
$ git diff -R

# 比较两个提交，反向显示
$ git diff -R commit1 commit2
```

## 比较非 Git 文件

```sh
# 比较两个不在 Git 仓库中的文件
$ git diff --no-index file1.txt file2.txt

# 比较目录
$ git diff --no-index dir1/ dir2/
```

## 使用外部 diff 工具

```sh
# 配置外部 diff 工具
$ git config --global diff.tool vimdiff

# 使用外部工具
$ git difftool

# 使用特定工具
$ git difftool --tool=vimdiff
```

# 实际应用场景

## 场景1：查看未暂存的更改

```sh
# 查看工作区中所有未暂存的更改
$ git diff

# 查看特定文件的更改
$ git diff src/main.c
```

## 场景2：查看已暂存的更改

```sh
# 查看暂存区中准备提交的更改
$ git diff --cached

# 查看特定文件的暂存更改
$ git diff --cached README.md
```

## 场景3：查看所有更改（工作区 + 暂存区）

```sh
# 查看工作区和暂存区的所有更改
$ git diff HEAD

# 或分步查看
$ git diff              # 工作区 vs 暂存区
$ git diff --cached     # 暂存区 vs HEAD
```

## 场景4：代码审查

```sh
# 查看两个分支的差异
$ git diff main..feature-branch

# 查看统计信息
$ git diff --stat main..feature-branch

# 查看特定文件的差异
$ git diff main..feature-branch -- src/main.c
```

## 场景5：查看提交历史中的更改

```sh
# 查看最后一次提交的更改
$ git diff HEAD~1 HEAD

# 查看最近 3 次提交的更改
$ git diff HEAD~3 HEAD

# 查看特定提交的更改
$ git diff abc1234^..abc1234
```

## 场景6：查找特定更改

```sh
# 查找包含 "TODO" 的更改
$ git diff -S"TODO"

# 查找匹配正则表达式的更改
$ git diff -G"function.*\(\)"

# 在特定提交范围内查找
$ git diff commit1..commit2 -S"bug"
```

## 场景7：忽略空白字符差异

```sh
# 代码格式化后，忽略空白字符差异
$ git diff -w

# 只关注实际代码更改
$ git diff -b --ignore-blank-lines
```

## 场景8：生成补丁文件

```sh
# 生成补丁文件
$ git diff > changes.patch

# 生成两个提交之间的补丁
$ git diff commit1 commit2 > feature.patch

# 应用补丁
$ git apply changes.patch
```

## 场景9：比较远程分支

```sh
# 查看本地分支和远程分支的差异
$ git diff main origin/main

# 查看远程分支的更改
$ git fetch origin
$ git diff main origin/main
```

## 场景10：查看文件重命名

```sh
# 查看重命名和移动
$ git diff --name-status HEAD~1 HEAD

# 查看重命名的详细信息
$ git diff -M HEAD~1 HEAD
```

# 与其他命令的组合

## git diff + git log

```sh
# 查看提交历史中的更改
$ git log --oneline
$ git diff commit1 commit2

# 查看每次提交的更改
$ git log -p
```

## git diff + git show

```sh
# git show 显示提交的详细信息（包括差异）
$ git show commit1

# git diff 可以更灵活地比较
$ git diff commit1^..commit1
```

## git diff + git stash

```sh
# 查看 stash 中的更改
$ git stash show -p

# 使用 git diff 查看
$ git diff stash@{0}
```

## git diff + grep

```sh
# 在差异中搜索
$ git diff | grep "function_name"

# 查找特定模式的更改
$ git diff -G"pattern" | grep "file"
```

# 常见问题和技巧

## 问题1：diff 输出太长

**解决方案**：
```sh
# 只显示文件名
$ git diff --name-only

# 只显示统计信息
$ git diff --stat

# 限制上下文行数
$ git diff -U3
```

## 问题2：只想看特定类型的更改

**解决方案**：
```sh
# 只看添加的文件
$ git diff --diff-filter=A

# 只看删除的文件
$ git diff --diff-filter=D

# 只看修改的文件
$ git diff --diff-filter=M

# 组合使用
$ git diff --diff-filter=AM  # 只看添加和修改
```

## 问题3：忽略某些文件的差异

**解决方案**：
```sh
# 使用路径过滤
$ git diff -- ':!*.log' ':!*.tmp'

# 或使用 .gitignore
$ git diff -- ':!.gitignore'
```

## 问题4：查看二进制文件的差异

**解决方案**：
```sh
# Git 默认不显示二进制文件的差异
# 可以配置文本转换器
$ git config diff.pdf.textconv pdftotext

# 或使用外部工具
$ git difftool binary-file.pdf
```

## 问题5：比较时包含未跟踪的文件

**解决方案**：
```sh
# 使用 git status 查看未跟踪的文件
$ git status

# git diff 默认不显示未跟踪的文件
# 需要先添加到暂存区
$ git add untracked-file.txt
$ git diff --cached
```

## 技巧1：使用别名简化命令

```sh
# 创建别名
$ git config --global alias.d 'diff'
$ git config --global alias.dc 'diff --cached'
$ git config --global alias.ds 'diff --stat'

# 使用别名
$ git d
$ git dc
$ git ds
```

## 技巧2：使用颜色主题

```sh
# 配置颜色
$ git config --global color.diff auto
$ git config --global color.diff.meta "yellow bold"
$ git config --global color.diff.frag "magenta bold"
$ git config --global color.diff.old "red bold"
$ git config --global color.diff.new "green bold"
```

## 技巧3：保存差异到文件

```sh
# 保存到文件
$ git diff > diff.txt

# 保存特定提交的差异
$ git diff commit1 commit2 > feature-diff.txt

# 使用重定向追加
$ git diff >> all-diffs.txt
```

## 技巧4：在编辑器中使用

```sh
# 在 Vim 中使用
$ git diff | vim -

# 在 less 中查看（支持搜索）
$ git diff | less
```

# 最佳实践

## 1. 提交前检查

```sh
# 提交前查看所有更改
$ git diff --cached

# 确保没有意外更改
$ git diff HEAD
```

## 2. 代码审查

```sh
# 查看功能分支的更改
$ git diff main..feature-branch --stat

# 查看详细差异
$ git diff main..feature-branch
```

## 3. 调试问题

```sh
# 查看特定时间段的更改
$ git diff commit1..commit2

# 查找引入问题的更改
$ git diff -S"bug" commit1..commit2
```

## 4. 文档化更改

```sh
# 生成补丁文件用于文档
$ git diff > CHANGES.patch

# 生成统计报告
$ git diff --stat > CHANGES.txt
```

## 5. 使用合适的上下文

```sh
# 代码审查时使用更多上下文
$ git diff -U10

# 快速查看时使用较少上下文
$ git diff -U3
```

## 6. 忽略无关差异

```sh
# 格式化后忽略空白差异
$ git diff -w

# 只关注实际代码更改
$ git diff -b --ignore-blank-lines
```

# 输出格式说明

## 差异块头（Hunk Header）

```diff
@@ -10,7 +10,7 @@
```

格式：`@@ -起始行,行数 +起始行,行数 @@`

- `-10,7`：原始文件从第10行开始，共7行
- `+10,7`：新文件从第10行开始，共7行

## 行标记

- ` `（空格）：未修改的行
- `-`：删除的行（红色）
- `+`：添加的行（绿色）
- `\`：行尾没有换行符

## 文件头

```diff
diff --git a/file.txt b/file.txt
index 1234567..abcdefg 100644
```

- `--git`：Git 格式
- `a/file.txt`：原始文件路径
- `b/file.txt`：新文件路径
- `index`：文件的 blob 对象哈希
- `100644`：文件模式（普通文件）

# 总结

`git diff` 是 Git 中最重要的命令之一，掌握它可以帮助你：

1. **查看更改**：了解工作区、暂存区和提交之间的差异
2. **代码审查**：比较分支和提交，进行代码审查
3. **调试问题**：查找引入问题的更改
4. **生成补丁**：创建补丁文件用于分享或备份
5. **统计分析**：查看代码更改的统计信息

通过合理使用 `git diff` 的各种选项，可以更高效地查看和理解代码的变化。

