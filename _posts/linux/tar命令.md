---
author: djaigo
title: linux-tar命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
---

`tar`（tape archive）是 Linux 中用于创建和解压归档文件的命令。它可以将多个文件打包成一个文件，并支持多种压缩格式。

```sh
➜ tar --help
用法: tar [选项...] [文件]...
GNU 'tar' 将许多文件保存到单个归档文件中，并可以还原归档文件中单独的文件。

主操作模式:
  -A, --catenate, --concatenate   追加 tar 文件到归档
  -c, --create                     创建一个新归档
  -d, --diff, --compare            找出归档和文件系统的差异
  -r, --append                     追加文件到归档结尾
  -t, --list                       列出归档内容
  -u, --update                     仅追加比归档中副本更新的文件
  -x, --extract, --get             从归档中解压文件
      --delete                     从归档中删除(不能在磁带上执行)
      --test-label                 测试归档卷标并退出

压缩选项:
  -a, --auto-compress              根据扩展名自动选择压缩程序
  -I, --use-compress-program=PROG  通过 PROG 过滤归档(必须接受 -d)
  -j, --bzip2                      通过 bzip2 过滤归档
  -J, --xz                         通过 xz 过滤归档
  -z, --gzip, --gunzip, --ungzip   通过 gzip 过滤归档
  -Z, --compress, --uncompress     通过 compress 过滤归档
      --lzip                       通过 lzip 过滤归档
      --lzma                       通过 lzma 过滤归档
      --lzop                       通过 lzop 过滤归档
      --zstd                       通过 zstd 过滤归档

文件选择:
  -C, --directory=DIR              改变到目录 DIR
      --exclude=PATTERN            排除匹配 PATTERN 的文件
  -f, --file=ARCHIVE               使用归档文件或设备 ARCHIVE
      --files-from=FILE            从 FILE 中读取要归档的文件名
  -T, --files-from=FILE            从 FILE 中读取要归档的文件名
      --exclude-from=FILE          从 FILE 中读取要排除的文件名
  -X, --exclude-from=FILE          从 FILE 中读取要排除的文件名

文件操作:
      --remove-files               归档后删除源文件
      --strip-components=NUMBER    解压时从文件名中去除 NUMBER 个前导部分
  -v, --verbose                    详细列出处理的文件
  -w, --interactive, --confirmation 每个操作都要求确认
```

# 基本语法

```sh
tar [选项] [文件...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-c, --create` | 创建归档 |
| `-x, --extract` | 解压归档 |
| `-t, --list` | 列出归档内容 |
| `-f, --file=ARCHIVE` | 指定归档文件名 |
| `-z, --gzip` | 使用 gzip 压缩/解压 |
| `-j, --bzip2` | 使用 bzip2 压缩/解压 |
| `-J, --xz` | 使用 xz 压缩/解压 |
| `-v, --verbose` | 详细输出 |
| `-C, --directory=DIR` | 改变到指定目录 |
| `--exclude=PATTERN` | 排除匹配的文件 |
| `-p, --preserve-permissions` | 保留权限 |

# 基本使用

## 创建归档

```sh
# 创建 tar 归档（不压缩）
➜ tar -cf archive.tar file1.txt file2.txt

# 创建并压缩（gzip）
➜ tar -czf archive.tar.gz dir/

# 创建并压缩（bzip2）
➜ tar -cjf archive.tar.bz2 dir/

# 创建并压缩（xz）
➜ tar -cJf archive.tar.xz dir/

# 详细输出
➜ tar -czvf archive.tar.gz dir/
```

## 解压归档

```sh
# 解压 tar 归档
➜ tar -xf archive.tar

# 解压 gzip 压缩的归档
➜ tar -xzf archive.tar.gz

# 解压 bzip2 压缩的归档
➜ tar -xjf archive.tar.bz2

# 解压到指定目录
➜ tar -xzf archive.tar.gz -C /path/to/dir/

# 详细输出
➜ tar -xzvf archive.tar.gz
```

## 列出归档内容

```sh
# 列出归档内容
➜ tar -tf archive.tar

# 详细列出
➜ tar -tzvf archive.tar.gz
```

## 追加文件

```sh
# 追加文件到归档
➜ tar -rf archive.tar newfile.txt

# 注意：不能追加到压缩的归档
```

# 实际应用场景

## 备份文件

```sh
# 备份目录
➜ tar -czf backup-$(date +%Y%m%d).tar.gz /path/to/backup

# 备份并排除某些文件
➜ tar -czf backup.tar.gz --exclude='*.log' --exclude='*.tmp' dir/

# 备份多个目录
➜ tar -czf backup.tar.gz dir1/ dir2/ dir3/
```

## 压缩和解压

```sh
# 压缩当前目录
➜ tar -czf current_dir.tar.gz .

# 解压到当前目录
➜ tar -xzf archive.tar.gz

# 解压特定文件
➜ tar -xzf archive.tar.gz path/to/file.txt
```

## 网络传输

```sh
# 创建归档并通过管道传输
➜ tar -czf - dir/ | ssh user@host "cat > backup.tar.gz"

# 从远程解压
➜ ssh user@host "tar -czf - dir/" | tar -xzf -
```

## 增量备份

```sh
# 创建完整备份
➜ tar -czf full_backup.tar.gz dir/

# 创建增量备份（只备份新文件）
➜ tar -czf incremental_backup.tar.gz --newer-mtime="2024-01-01" dir/
```

# 压缩格式对比

| 格式 | 选项 | 扩展名 | 压缩率 | 速度 |
|------|------|--------|--------|------|
| 不压缩 | -cf | .tar | 无 | 最快 |
| gzip | -czf | .tar.gz, .tgz | 中等 | 快 |
| bzip2 | -cjf | .tar.bz2 | 高 | 慢 |
| xz | -cJf | .tar.xz | 最高 | 最慢 |

# 高级用法

## 排除文件

```sh
# 排除多个模式
➜ tar -czf backup.tar.gz \
  --exclude='*.log' \
  --exclude='*.tmp' \
  --exclude='node_modules' \
  dir/

# 从文件读取排除列表
➜ tar -czf backup.tar.gz -X exclude.txt dir/
```

## 只解压特定文件

```sh
# 解压特定文件
➜ tar -xzf archive.tar.gz path/to/file.txt

# 解压匹配模式的文件
➜ tar -xzf archive.tar.gz --wildcards "*.txt"
```

## 保留权限

```sh
# 创建时保留权限
➜ tar -czpf archive.tar.gz dir/

# 解压时保留权限
➜ tar -xzpf archive.tar.gz
```

## 从标准输入/输出

```sh
# 从标准输入读取
➜ tar -czf - dir/ | ssh user@host "cat > backup.tar.gz"

# 输出到标准输出
➜ tar -czf - dir/ > backup.tar.gz
```

# 注意事项

1. **选项顺序**：`-f` 选项必须在最后，因为它后面跟文件名
2. **压缩格式**：解压时必须使用与压缩时相同的格式
3. **路径**：使用相对路径可以避免解压时覆盖系统文件
4. **权限**：某些文件可能需要 root 权限才能解压

# 参考文献
* [GNU tar 官方文档](https://www.gnu.org/software/tar/manual/)

