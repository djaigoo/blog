---
author: djaigo
title: linux-history命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`history` 是 Linux shell 中用于显示和管理命令历史记录的内置命令。它可以帮助用户快速查找和重复执行之前的命令。

# 基本语法

```sh
history [选项] [N]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-c` | 清空历史记录 |
| `-d OFFSET` | 删除指定偏移量的历史记录 |
| `-a` | 追加当前会话的历史记录到历史文件 |
| `-n` | 读取未读的历史记录 |
| `-r` | 读取历史文件并追加到历史列表 |
| `-w` | 将当前历史记录写入历史文件 |
| `-p` | 展开历史参数但不执行 |
| `-s` | 将参数作为单个条目添加到历史列表 |

# 基本使用

## 显示历史记录

```sh
# 显示所有历史记录
➜ history

# 显示最近 N 条记录
➜ history 20

# 显示最近 10 条记录
➜ history 10
```

## 使用历史记录

```sh
# 执行历史中的第 N 条命令
➜ !N

# 执行上一条命令
➜ !!

# 执行最近匹配的命令
➜ !pattern

# 执行最近以 pattern 开头的命令
➜ !pattern
```

## 搜索历史记录

```sh
# 搜索包含 pattern 的历史命令
➜ history | grep pattern

# 使用 Ctrl+R 进行交互式搜索（在 bash 中）
# 按 Ctrl+R，输入关键词，按 Enter 执行
```

# 历史记录扩展

## 基本扩展

```sh
# !! - 上一条命令
➜ !!

# !N - 第 N 条命令
➜ !123

# !-N - 倒数第 N 条命令
➜ !-1  # 等同于 !!
➜ !-2  # 倒数第二条

# !string - 最近以 string 开头的命令
➜ !ls

# !?string? - 最近包含 string 的命令
➜ !?pattern?
```

## 参数扩展

```sh
# !^ - 上一条命令的第一个参数
➜ ls file1 file2
➜ cat !^  # 等同于 cat file1

# !$ - 上一条命令的最后一个参数
➜ ls file1 file2
➜ cat !$  # 等同于 cat file2

# !* - 上一条命令的所有参数
➜ ls file1 file2
➜ cat !*  # 等同于 cat file1 file2

# !:N - 上一条命令的第 N 个参数
➜ ls file1 file2 file3
➜ cat !:2  # 等同于 cat file2
```

## 命令部分扩展

```sh
# !:0 - 上一条命令的命令名
➜ /usr/bin/ls -l
➜ !:0  # 等同于 /usr/bin/ls

# !:1 - 上一条命令的第一个参数
# !:2 - 上一条命令的第二个参数
# 以此类推
```

# 历史记录配置

## 环境变量

```sh
# 设置历史记录数量
export HISTSIZE=10000

# 设置历史文件大小
export HISTFILESIZE=20000

# 设置历史文件位置
export HISTFILE=~/.bash_history

# 立即追加到历史文件（而不是退出时）
export PROMPT_COMMAND="history -a"

# 不保存重复的命令
export HISTCONTROL=ignoredups

# 不保存以空格开头的命令
export HISTCONTROL=ignorespace

# 同时使用多个选项
export HISTCONTROL=ignoreboth:erasedups
```

## 配置文件

在 `~/.bashrc` 或 `~/.bash_profile` 中配置：

```sh
# 增加历史记录数量
HISTSIZE=10000
HISTFILESIZE=20000

# 不保存重复命令
HISTCONTROL=ignoredups:erasedups

# 立即追加到历史文件
PROMPT_COMMAND="history -a; history -c; history -r"

# 添加时间戳
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
```

# 实际应用场景

## 查找命令

```sh
# 查找包含特定关键词的命令
➜ history | grep "nginx"

# 查找最近使用的命令
➜ history | tail -20
```

## 重复执行

```sh
# 执行上一条命令
➜ !!

# 执行最近的 ls 命令
➜ !ls

# 执行第 100 条命令
➜ !100
```

## 修改并执行

```sh
# 上一条命令是: ls file1.txt
# 修改为: cat file1.txt
➜ ^ls^cat

# 或者使用参数替换
➜ ls file1.txt
➜ cat !$
```

## 清空历史

```sh
# 清空当前会话的历史
➜ history -c

# 清空历史文件
➜ > ~/.bash_history
➜ history -w
```

# 高级用法

## 历史记录搜索

```sh
# 在 bash 中使用 Ctrl+R 搜索
# 1. 按 Ctrl+R
# 2. 输入关键词
# 3. 按 Ctrl+R 继续搜索
# 4. 按 Enter 执行
# 5. 按 Ctrl+G 取消

# 使用 fzf 进行模糊搜索（需安装）
➜ history | fzf
```

## 历史记录共享

```sh
# 多个终端共享历史记录
# 在 ~/.bashrc 中添加：
export PROMPT_COMMAND="history -a; history -c; history -r"
```

## 历史记录统计

```sh
# 统计最常用的命令
➜ history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10

# 统计命令使用频率
➜ history | awk '{print $2}' | sort | uniq -c | sort -rn
```

# 注意事项

1. **历史文件位置**：默认在 `~/.bash_history`（bash）或 `~/.zsh_history`（zsh）
2. **历史记录数量**：默认保存有限数量的历史记录
3. **安全性**：历史记录可能包含敏感信息（密码等），注意保护
4. **不同 shell**：不同 shell（bash、zsh）的历史记录机制略有不同

# 参考文献
* [Bash 历史记录](https://www.gnu.org/software/bash/manual/html_node/Bash-History-Facilities.html)

