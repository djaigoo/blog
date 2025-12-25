---
author: djaigo
title: tig命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/git.png'
categories:
  - git
tags:
  - git
---

`tig` 是一个基于文本的 Git 仓库浏览器，提供了交互式的终端界面来浏览 Git 历史、查看提交、查看差异等。它是 "Git" 的反向拼写，是 Git 命令行工具的优秀补充。

```sh
➜ tig --help
tig version 2.5.8
Usage: tig [options] [revs] [--] [paths]

Options:
    -C <path>              Run as if tig was started in <path>
    -v, --version          Show version and exit
    -h, --help             Show help message and exit
    -d, --date=<format>    Date format string
    -i, --follow           Follow file renames
    -S, --source=<repo>    Open repository from <repo>
    -w, --width=<width>    Set terminal width
    -h, --height=<height>  Set terminal height
    -u, --untracked-files  Show untracked files
    -s, --status           Show status view
    -l, --log              Show log view
    -b, --blame            Show blame view
    -r, --refs             Show refs view
    -t, --tree             Show tree view
    -c, --changelog        Show changelog view
    -p, --pager            Use pager for output
    --all                  Show all refs
    --pretty=<format>      Pretty format string
```

# 基本概念

## 什么是 Tig

Tig 是一个基于 ncurses 的 Git 仓库浏览器，提供了图形化的终端界面来浏览 Git 仓库。它不需要图形界面，完全在终端中运行，非常适合在服务器上使用。

## 主要功能

1. **浏览提交历史**：以交互式方式浏览 Git 提交历史
2. **查看提交详情**：查看提交的详细信息、差异、文件变更
3. **查看文件历史**：查看特定文件的历史记录
4. **查看分支和标签**：浏览所有分支和标签
5. **查看工作区状态**：查看工作目录和暂存区的状态
6. **交互式操作**：支持搜索、过滤、跳转等操作

## 安装

### macOS

```sh
# 使用 Homebrew
brew install tig

# 使用 MacPorts
sudo port install tig
```

### Linux

```sh
# Ubuntu/Debian
sudo apt-get install tig

# Fedora/RHEL
sudo yum install tig
# 或
sudo dnf install tig

# Arch Linux
sudo pacman -S tig
```

### 从源码编译

```sh
git clone https://github.com/jonas/tig.git
cd tig
make
sudo make install
```

# 基本语法

```sh
tig [选项] [revs] [--] [路径...]
```

其中：
- `选项`：控制 tig 行为的参数
- `revs`：可选的 Git 修订版本（提交、分支、标签等）
- `路径`：可选，指定要查看的文件或目录

# 常用选项

| 选项 | 说明 |
|------|------|
| `-s, --status` | 启动时显示状态视图 |
| `-l, --log` | 启动时显示日志视图（默认） |
| `-b, --blame` | 启动时显示 blame 视图 |
| `-r, --refs` | 启动时显示引用视图 |
| `-t, --tree` | 启动时显示树视图 |
| `-c, --changelog` | 启动时显示变更日志视图 |
| `-C <path>` | 在指定路径运行 tig |
| `-S, --source=<repo>` | 打开指定仓库 |
| `-u, --untracked-files` | 显示未跟踪的文件 |
| `-i, --follow` | 跟踪文件重命名 |
| `-w, --width=<width>` | 设置终端宽度 |
| `-h, --height=<height>` | 设置终端高度 |
| `--all` | 显示所有引用 |
| `-p, --pager` | 使用分页器输出 |

# 基本使用

## 启动 Tig

```sh
# 基本启动（显示日志视图）
➜ tig

# 启动时显示状态视图
➜ tig --status
# 或
➜ tig -s

# 启动时显示特定分支的日志
➜ tig main

# 启动时显示特定文件的日志
➜ tig -- src/main.c

# 启动时显示特定提交范围
➜ tig HEAD~10..HEAD
```

## 查看特定视图

```sh
# 查看日志视图
➜ tig --log

# 查看状态视图
➜ tig --status

# 查看引用视图（分支和标签）
➜ tig --refs

# 查看树视图
➜ tig --tree

# 查看 blame 视图（需要指定文件）
➜ tig --blame src/main.c
```

# 界面说明

## 主视图

Tig 有多个视图，每个视图显示不同的信息：

1. **日志视图（Log View）**：显示提交历史
2. **状态视图（Status View）**：显示工作目录状态
3. **引用视图（Refs View）**：显示分支和标签
4. **树视图（Tree View）**：显示文件树
5. **Blame 视图（Blame View）**：显示文件的逐行注释
6. **主视图（Main View）**：显示提交详情

## 基本操作

### 导航

| 按键 | 说明 |
|------|------|
| `↑` / `k` | 向上移动 |
| `↓` / `j` | 向下移动 |
| `Page Up` / `Ctrl+B` | 向上翻页 |
| `Page Down` / `Ctrl+F` | 向下翻页 |
| `Home` / `g` | 跳到顶部 |
| `End` / `G` | 跳到底部 |
| `Enter` | 进入/展开 |
| `Esc` / `q` | 退出/返回 |

### 视图切换

| 按键 | 说明 |
|------|------|
| `m` | 切换到主视图 |
| `l` | 切换到日志视图 |
| `s` | 切换到状态视图 |
| `r` | 切换到引用视图 |
| `t` | 切换到树视图 |
| `b` | 切换到 blame 视图 |

### 搜索

| 按键 | 说明 |
|------|------|
| `/` | 向前搜索 |
| `?` | 向后搜索 |
| `n` | 下一个匹配 |
| `N` | 上一个匹配 |

# 日志视图（Log View）

日志视图显示提交历史，是 tig 的默认视图。

## 基本操作

```sh
# 启动日志视图
➜ tig
# 或
➜ tig --log
```

## 日志视图操作

| 按键 | 说明 |
|------|------|
| `Enter` | 查看提交详情 |
| `C` | 查看提交的完整信息 |
| `D` | 查看提交的差异 |
| `T` | 查看提交的文件树 |
| `Y` | 复制提交哈希 |
| `R` | 刷新视图 |
| `f` | 标记提交 |
| `F` | 取消标记 |
| `/` | 搜索提交信息 |

## 查看特定范围的提交

```sh
# 查看最近 20 个提交
➜ tig HEAD~20..HEAD

# 查看特定分支
➜ tig feature-branch

# 查看两个分支之间的差异
➜ tig main..feature-branch

# 查看特定作者的提交
➜ tig --author="John Doe"
```

# 状态视图（Status View）

状态视图显示工作目录和暂存区的状态。

## 基本操作

```sh
# 启动状态视图
➜ tig --status
# 或
➜ tig -s
```

## 状态视图操作

| 按键 | 说明 |
|------|------|
| `Enter` | 查看文件差异 |
| `u` | 取消暂存文件 |
| `s` | 暂存文件 |
| `S` | 暂存所有文件 |
| `!` | 恢复文件 |
| `c` | 提交更改 |
| `C` | 提交所有更改 |
| `a` | 添加未跟踪的文件 |
| `A` | 添加所有未跟踪的文件 |
| `d` | 查看文件差异 |
| `D` | 查看所有差异 |

# 引用视图（Refs View）

引用视图显示所有分支和标签。

## 基本操作

```sh
# 启动引用视图
➜ tig --refs
# 或
➜ tig -r
```

## 引用视图操作

| 按键 | 说明 |
|------|------|
| `Enter` | 查看引用的日志 |
| `c` | 检出分支 |
| `C` | 创建新分支 |
| `d` | 删除分支 |
| `m` | 合并分支 |
| `r` | 重命名分支 |

# Blame 视图（Blame View）

Blame 视图显示文件的逐行注释，显示每行代码是谁在什么时候修改的。

## 基本操作

```sh
# 启动 blame 视图（需要指定文件）
➜ tig --blame src/main.c
# 或
➜ tig -b src/main.c
```

## Blame 视图操作

| 按键 | 说明 |
|------|------|
| `Enter` | 查看提交详情 |
| `D` | 查看行的差异 |
| `l` | 查看行的日志 |
| `b` | 在新分支中查看 |
| `r` | 刷新视图 |

# 主视图（Main View）

主视图显示提交的详细信息。

## 主视图操作

| 按键 | 说明 |
|------|------|
| `D` | 查看差异 |
| `T` | 查看文件树 |
| `l` | 查看日志 |
| `b` | 查看 blame |
| `s` | 查看状态 |
| `r` | 刷新视图 |
| `Y` | 复制提交哈希 |

# 实际应用场景

## 场景1：浏览提交历史

```sh
# 启动 tig 浏览提交历史
➜ tig

# 在日志视图中：
# - 使用上下箭头浏览提交
# - 按 Enter 查看提交详情
# - 按 D 查看提交的差异
# - 按 / 搜索提交信息
```

## 场景2：查看工作区状态

```sh
# 启动状态视图
➜ tig --status

# 在状态视图中：
# - 查看修改的文件
# - 按 s 暂存文件
# - 按 u 取消暂存
# - 按 d 查看文件差异
# - 按 c 提交更改
```

## 场景3：查看文件历史

```sh
# 查看特定文件的历史
➜ tig -- src/main.c

# 在日志视图中：
# - 只显示与 src/main.c 相关的提交
# - 按 Enter 查看提交详情
# - 按 D 查看文件差异
```

## 场景4：查看文件注释（Blame）

```sh
# 查看文件的逐行注释
➜ tig --blame src/main.c

# 在 blame 视图中：
# - 查看每行代码的作者和提交
# - 按 Enter 查看提交详情
# - 按 D 查看行的差异
```

## 场景5：比较分支

```sh
# 查看两个分支之间的差异
➜ tig main..feature-branch

# 在日志视图中：
# - 只显示 feature-branch 中有但 main 中没有的提交
# - 可以查看每个提交的详细信息
```

## 场景6：搜索提交

```sh
# 启动 tig
➜ tig

# 在日志视图中：
# - 按 / 进入搜索模式
# - 输入搜索关键词（提交信息、作者等）
# - 按 Enter 搜索
# - 按 n 查找下一个匹配
```

# 高级用法

## 自定义启动视图

```sh
# 启动时显示状态视图
➜ tig --status

# 启动时显示引用视图
➜ tig --refs

# 启动时显示树视图
➜ tig --tree
```

## 查看特定提交范围

```sh
# 查看最近 10 个提交
➜ tig HEAD~10..HEAD

# 查看特定日期范围的提交
➜ tig --since="2024-01-01" --until="2024-12-31"

# 查看特定作者的提交
➜ tig --author="John Doe"
```

## 查看特定路径

```sh
# 只查看特定目录的提交
➜ tig -- src/

# 只查看特定文件的提交
➜ tig -- src/main.c src/utils.c

# 查看多个路径
➜ tig -- src/ tests/
```

## 使用配置文件

Tig 支持配置文件 `~/.tigrc` 来自定义行为：

```sh
# 设置默认视图
set main-view = log
set status-view = status

# 设置颜色主题
set color = true

# 设置键绑定
bind main D !git diff %(commit)
bind status s !git add %(file)
```

## 与其他工具集成

```sh
# 在 Git 别名中使用 tig
git config --global alias.lg "!tig"

# 使用 tig 作为 Git 日志查看器
git config --global pager.log "tig --no-pager"
```

# 常用快捷键参考

## 全局快捷键

| 按键 | 说明 |
|------|------|
| `q` / `Esc` | 退出/返回 |
| `?` | 显示帮助 |
| `R` | 刷新视图 |
| `Ctrl+L` | 刷新屏幕 |

## 日志视图快捷键

| 按键 | 说明 |
|------|------|
| `Enter` | 查看提交详情 |
| `C` | 查看完整提交信息 |
| `D` | 查看提交差异 |
| `T` | 查看文件树 |
| `Y` | 复制提交哈希 |
| `f` | 标记提交 |
| `F` | 取消标记 |
| `/` | 搜索 |

## 状态视图快捷键

| 按键 | 说明 |
|------|------|
| `s` | 暂存文件 |
| `S` | 暂存所有文件 |
| `u` | 取消暂存 |
| `!` | 恢复文件 |
| `c` | 提交 |
| `C` | 提交所有 |
| `a` | 添加未跟踪文件 |
| `A` | 添加所有未跟踪文件 |
| `d` | 查看差异 |

## 引用视图快捷键

| 按键 | 说明 |
|------|------|
| `Enter` | 查看引用日志 |
| `c` | 检出分支 |
| `C` | 创建分支 |
| `d` | 删除分支 |
| `m` | 合并分支 |
| `r` | 重命名分支 |

# 配置文件

## 配置文件位置

Tig 的配置文件位于 `~/.tigrc`。

## 常用配置示例

```sh
# ~/.tigrc

# 设置默认视图
set main-view = log
set status-view = status

# 启用颜色
set color = true

# 设置日期格式
set date-format = "%Y-%m-%d %H:%M"

# 自定义键绑定
bind main D !git diff %(commit)
bind status s !git add %(file)
bind status u !git restore --staged %(file)

# 设置显示选项
set line-graphics = true
set tab-size = 4

# 设置搜索选项
set search-case-sensitive = false
set search-regex = true
```

## 配置选项说明

| 选项 | 说明 |
|------|------|
| `main-view` | 默认主视图（log, status, refs, tree） |
| `status-view` | 状态视图设置 |
| `color` | 启用/禁用颜色 |
| `date-format` | 日期格式 |
| `line-graphics` | 使用线条图形 |
| `tab-size` | Tab 键大小 |
| `search-case-sensitive` | 搜索是否区分大小写 |
| `search-regex` | 搜索是否使用正则表达式 |

# 常见问题与技巧

## 问题1：如何退出 tig？

按 `q` 或 `Esc` 键退出当前视图，多次按 `q` 可以完全退出 tig。

## 问题2：如何刷新视图？

按 `R` 键刷新当前视图，或按 `Ctrl+L` 刷新屏幕。

## 问题3：如何搜索提交？

在日志视图中按 `/` 键，输入搜索关键词，按 `Enter` 搜索，按 `n` 查找下一个匹配。

## 问题4：如何查看文件的完整历史？

```sh
# 使用 --follow 选项跟踪文件重命名
➜ tig --follow -- src/main.c
```

## 问题5：如何查看未跟踪的文件？

```sh
# 使用 -u 选项显示未跟踪的文件
➜ tig --status -u
```

## 问题6：如何在 tig 中执行 Git 命令？

在 tig 中按 `!` 键可以执行 shell 命令，输入 Git 命令即可。

## 技巧1：快速查看提交差异

在日志视图中，将光标移到提交上，按 `D` 键即可查看该提交的差异。

## 技巧2：标记多个提交

在日志视图中，按 `f` 键标记提交，可以标记多个提交进行比较。

## 技巧3：复制提交哈希

在日志视图或主视图中，按 `Y` 键可以复制当前提交的哈希值。

## 技巧4：查看特定作者的提交

```sh
# 启动 tig 后，使用搜索功能
# 按 / 键，输入 author:John Doe
```

## 技巧5：自定义键绑定

在 `~/.tigrc` 中自定义键绑定：

```sh
# 绑定 D 键执行 git diff
bind main D !git diff %(commit)

# 绑定 s 键执行 git show
bind main s !git show %(commit)
```

# 与其他工具的比较

## Tig vs Git Log

| 特性 | Tig | Git Log |
|------|-----|---------|
| 交互式 | 是 | 否 |
| 图形界面 | 是 | 否 |
| 搜索 | 内置 | 需要管道 |
| 文件操作 | 支持 | 不支持 |
| 学习曲线 | 中等 | 低 |

## Tig vs Gitk

| 特性 | Tig | Gitk |
|------|-----|------|
| 界面 | 文本界面 | 图形界面 |
| 依赖 | 只需终端 | 需要 X11 |
| 速度 | 快 | 较慢 |
| 远程使用 | 支持 | 需要 X11 转发 |

# 最佳实践

1. **熟悉基本操作**：先熟悉基本的导航和视图切换操作

2. **使用配置文件**：根据个人习惯配置 `~/.tigrc`

3. **结合 Git 命令**：Tig 是 Git 的补充，不是替代，结合使用效果更好

4. **使用搜索功能**：充分利用搜索功能快速定位提交

5. **标记提交**：使用标记功能比较多个提交

6. **查看差异**：经常使用 `D` 键查看提交差异，了解代码变更

# 注意事项

1. **终端兼容性**：Tig 需要支持 ncurses 的终端

2. **性能**：在大型仓库中，首次加载可能需要一些时间

3. **配置**：配置文件语法需要正确，否则可能无法启动

4. **依赖**：需要安装 ncurses 库

5. **学习曲线**：需要一些时间熟悉快捷键和操作

# 参考文献
* [Tig 官方文档](https://github.com/jonas/tig)
* [Tig 手册页](https://jonas.github.io/tig/doc/manual.html)
* [Tig 配置参考](https://github.com/jonas/tig/blob/master/tigrc)

