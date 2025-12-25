---
author: djaigo
title: linux软链接和硬链接
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - link
---

我们知道文件都有文件名与数据，这在 Linux 上被分成两个部分：用户数据 (user data) 与元数据 (metadata)。用户数据，即文件数据块 (data block)，数据块是记录文件真实内容的地方；而元数据则是文件的附加属性，如文件大小、创建时间、所有者等信息。在 Linux 中，元数据中的 inode 号（inode 是文件元数据的一部分但其并不包含文件名，inode 号即索引节点号）才是文件的唯一标识而非文件名。文件名仅是为了方便人们的记忆和使用，系统或程序通过 inode 号寻找正确的文件数据块。

为解决文件的共享使用，Linux 系统引入了两种链接：硬链接 (hard link) 与软链接（又称符号链接，即 soft link 或 symbolic link）。链接为 Linux 系统解决了文件的共享使用，还带来了隐藏文件路径、增加权限安全及节省存储等好处。若一个 inode 号对应多个文件名，则称这些文件为硬链接。换言之，硬链接就是同一个文件使用了多个别名他们有共同的 inode。硬链接可由命令 `link` 或 `ln` 创建。

# ln 命令

`ln` 是创建链接的命令，语法如下：

```sh
# 创建硬链接
ln [选项] 源文件 目标文件

# 创建软链接
ln -s [选项] 源文件 目标文件
```

## 常用选项

| 选项 | 说明 |
|------|------|
| `-s, --symbolic` | 创建软链接（符号链接） |
| `-f, --force` | 强制创建，覆盖已存在的目标文件 |
| `-v, --verbose` | 显示详细信息 |
| `-i, --interactive` | 交互模式，覆盖前询问 |
| `-b` | 覆盖前备份 |
| `-n, --no-dereference` | 如果目标是一个符号链接，不要跟随它 |
| `-T, --no-target-directory` | 总是将目标视为普通文件 |
| `-t, --target-directory=DIRECTORY` | 在指定目录中创建链接 |

## 基本使用

```sh
# 创建硬链接
➜ ln file.txt hardlink.txt

# 创建软链接
➜ ln -s file.txt softlink.txt

# 创建指向目录的软链接
➜ ln -s /path/to/dir linkdir

# 强制创建（覆盖已存在的链接）
➜ ln -sf file.txt softlink.txt

# 显示详细信息
➜ ln -sv file.txt softlink.txt
```

# 硬链接

由于硬链接是有着相同 inode 号仅文件名不同的文件，因此硬链接存在以下几点特性：

*   文件有相同的 inode 及 data block；
*   只能对已存在的文件进行创建；
*   不能交叉文件系统进行硬链接的创建；
*   不能对目录进行创建，只可对文件创建；
*   删除一个硬链接文件并不影响其他有相同 inode 号的文件。

## 创建硬链接

```sh
# 创建硬链接
➜ ln original.txt hardlink.txt

# 查看 inode 号（硬链接有相同的 inode）
➜ ls -li original.txt hardlink.txt
123456 -rw-r--r-- 2 user group 1024 Jan 1 10:00 original.txt
123456 -rw-r--r-- 2 user group 1024 Jan 1 10:00 hardlink.txt
# 注意：两个文件的 inode 号相同（123456），链接数为 2

# 查看文件内容（内容相同）
➜ cat original.txt
Hello World
➜ cat hardlink.txt
Hello World

# 修改任一文件，另一个也会改变
➜ echo "New content" >> original.txt
➜ cat hardlink.txt
Hello World
New content
```

## 硬链接的特点

1. **共享 inode**：所有硬链接指向同一个 inode
2. **共享数据**：修改任一硬链接，其他硬链接也会看到变化
3. **链接计数**：`ls -l` 显示的第二列数字就是硬链接数
4. **删除行为**：只有当所有硬链接都被删除时，文件数据才会被删除

# 软链接

软链接与硬链接不同，若文件用户数据块中存放的内容是另一文件的路径名的指向，则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。软链接有着自己的 inode 号以及用户数据块。因此软链接的创建与使用没有类似硬链接的诸多限制：

*   软链接有自己的文件属性及权限等；
*   可对不存在的文件或目录创建软链接；
*   软链接可交叉文件系统；
*   软链接可对文件或目录创建；
*   创建软链接时，链接计数 i_nlink 不会增加；
*   删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

## 创建软链接

```sh
# 创建软链接（符号链接）
➜ ln -s original.txt softlink.txt

# 查看软链接（注意箭头 -> 和不同的 inode）
➜ ls -li original.txt softlink.txt
123456 -rw-r--r-- 1 user group 1024 Jan 1 10:00 original.txt
789012 lrwxrwxrwx 1 user group   12 Jan 1 10:01 softlink.txt -> original.txt
# 注意：软链接有独立的 inode（789012），文件类型是 l（链接）

# 查看软链接指向的路径
➜ readlink softlink.txt
original.txt

# 创建指向目录的软链接
➜ ln -s /path/to/dir linkdir
➜ ls -ld linkdir
lrwxrwxrwx 1 user group 12 Jan 1 10:01 linkdir -> /path/to/dir

# 创建指向不存在文件的软链接（死链接）
➜ ln -s nonexistent.txt deadlink.txt
➜ ls -l deadlink.txt
lrwxrwxrwx 1 user group 16 Jan 1 10:02 deadlink.txt -> nonexistent.txt
➜ cat deadlink.txt
cat: deadlink.txt: No such file or directory
```

## 软链接的特点

1. **独立 inode**：软链接有自己的 inode 号
2. **路径存储**：软链接存储的是目标文件的路径
3. **可以跨文件系统**：可以链接到不同文件系统的文件
4. **可以链接目录**：可以对目录创建软链接
5. **死链接**：如果目标文件被删除，软链接变成死链接
6. **相对路径和绝对路径**：可以使用相对路径或绝对路径

# inode
在 Linux 中，索引节点结构存在于系统内存及磁盘，其可区分成 VFS inode 与实际文件系统的 inode。VFS inode 作为实际文件系统中 inode 的抽象，定义了结构体 inode 与其相关的操作 inode_operations（见内核源码 include/linux/fs.h）。

```c
struct inode { 
   ... 
   const struct inode_operations   *i_op; // 索引节点操作
   unsigned long           i_ino;      // 索引节点号
   atomic_t                i_count;    // 引用计数器
   unsigned int            i_nlink;    // 硬链接数目
   ... 
} 
 
struct inode_operations { 
   ... 
   int (*create) (struct inode *,struct dentry *,int, struct nameidata *); 
   int (*link) (struct dentry *,struct inode *,struct dentry *); 
   int (*unlink) (struct inode *,struct dentry *); 
   int (*symlink) (struct inode *,struct dentry *,const char *); 
   int (*mkdir) (struct inode *,struct dentry *,int); 
   int (*rmdir) (struct inode *,struct dentry *); 
   ... 
}
```

如清单 10. 所见，每个文件存在两个计数器：`i_count` 与 `i_nlink`，即引用计数与硬链接计数。结构体 inode 中的 `i_count` 用于跟踪文件被访问的数量，而 `i_nlink` 则是上述使用 ls -l 等命令查看到的文件硬链接数。或者说 `i_count` 跟踪文件在内存中的情况，而 `i_nlink` 则是磁盘计数器。当文件被删除时，则 `i_nlink` 先被设置成 0。文件的这两个计数器使得 Linux 系统升级或程序更新变的容易。系统或程序可在不关闭的情况下（即文件 `i_count` 不为 0），将新文件以同样的文件名进行替换，新文件有自己的 inode 及 data block，旧文件会在相关进程关闭后被完整的删除。

文件系统 ext4 中的 inode
```c
struct ext4_inode { 
   ... 
   __le32  i_atime;        // 文件内容最后一次访问时间
   __le32  i_ctime;        // inode 修改时间
   __le32  i_mtime;        // 文件内容最后一次修改时间
   __le16  i_links_count;  // 硬链接计数
   __le32  i_blocks_lo;    // Block 计数
   __le32  i_block[EXT4_N_BLOCKS];  // 指向具体的 block 
   ... 
};
```

其中三个时间的定义可对应与命令 stat 中查看到三个时间。`i_links_count` 不仅用于文件的硬链接计数，也用于目录的子目录数跟踪（目录并不显示硬链接数，命令 ls -ld 查看到的是子目录数）。由于文件系统 ext3 对 `i_links_count` 有限制，其最大数为：32000（该限制在 ext4 中被取消）。尝试在 ext3 文件系统上验证目录子目录及普通文件硬链接最大数可见的错误信息。因此实际文件系统的 inode 之间及与 VFS inode 相较是有差异的。

# 查看链接信息

## 使用 ls 命令

```sh
# 查看文件详细信息（显示链接数）
➜ ls -l file.txt
-rw-r--r-- 2 user group 1024 Jan 1 10:00 file.txt
# 第二列的数字 2 表示硬链接数为 2

# 查看软链接
➜ ls -l softlink.txt
lrwxrwxrwx 1 user group 12 Jan 1 10:01 softlink.txt -> original.txt
# 文件类型 l 表示链接，-> 指向目标文件

# 显示 inode 号
➜ ls -li file.txt hardlink.txt
123456 -rw-r--r-- 2 user group 1024 Jan 1 10:00 file.txt
123456 -rw-r--r-- 2 user group 1024 Jan 1 10:00 hardlink.txt
# 相同的 inode 号表示是硬链接
```

## 使用 stat 命令

```sh
# 查看文件详细信息
➜ stat file.txt
  File: file.txt
  Size: 1024        Blocks: 8          IO Block: 4096   regular file
Device: 803h/2051d  Inode: 123456      Links: 2
Access: (0644/-rw-r--r--)  Uid: ( 1000/   user)   Gid: ( 1000/   group)
Access: 2024-01-01 10:00:00.000000000 +0800
Modify: 2024-01-01 10:00:00.000000000 +0800
Change: 2024-01-01 10:00:00.000000000 +0800
 Birth: -
# Links: 2 表示硬链接数为 2

# 查看软链接信息
➜ stat softlink.txt
  File: softlink.txt -> original.txt
  Size: 12          Blocks: 0          IO Block: 4096   symbolic link
Device: 803h/2051d  Inode: 789012      Links: 1
# 注意：软链接的 Links 始终为 1，因为它有独立的 inode
```

## 使用 readlink 命令

```sh
# 查看软链接指向的路径
➜ readlink softlink.txt
original.txt

# 查看绝对路径
➜ readlink -f softlink.txt
/home/user/original.txt

# 查看规范路径（解析所有链接）
➜ readlink -e softlink.txt
/home/user/original.txt
```

## 使用 find 命令

```sh
# 查找所有硬链接
➜ find . -samefile file.txt
./file.txt
./hardlink.txt

# 查找所有软链接
➜ find . -type l

# 查找指向特定文件的软链接
➜ find . -type l -exec readlink -f {} \; | grep original.txt
```

# 硬链接与软链接对比

| 特性 | 硬链接 | 软链接 |
|------|--------|--------|
| **inode 号** | 相同 | 不同 |
| **文件类型** | 普通文件 | 链接文件（l） |
| **存储内容** | 文件数据 | 目标文件路径 |
| **跨文件系统** | 不支持 | 支持 |
| **链接目录** | 不支持 | 支持 |
| **链接不存在文件** | 不支持 | 支持（死链接） |
| **删除原文件** | 不影响（只要还有其他硬链接） | 变成死链接 |
| **文件大小** | 与原文件相同 | 等于路径字符串长度 |
| **性能** | 较快（直接访问） | 较慢（需要解析路径） |
| **链接计数** | 增加 i_nlink | 不增加 i_nlink |

# 实际应用场景

## 硬链接的应用

### 1. 文件备份

```sh
# 创建重要文件的硬链接作为备份
➜ ln important.txt important.txt.backup

# 即使删除原文件，备份仍然可用
➜ rm important.txt
➜ cat important.txt.backup
# 内容仍然存在
```

### 2. 节省存储空间

```sh
# 多个位置需要访问同一文件，使用硬链接节省空间
➜ ln /shared/data.txt /user1/data.txt
➜ ln /shared/data.txt /user2/data.txt
# 三个文件共享同一份数据，只占用一份存储空间
```

### 3. 文件版本管理

```sh
# 创建硬链接保持文件版本
➜ ln config.conf config.conf.v1
➜ # 修改 config.conf
➜ ln config.conf config.conf.v2
```

## 软链接的应用

### 1. 版本管理

```sh
# 创建指向当前版本的软链接
➜ ln -s python3.9 python
➜ ln -s python3.10 python
# 通过修改软链接切换版本
```

### 2. 路径简化

```sh
# 创建短路径的软链接
➜ ln -s /very/long/path/to/file.txt short.txt
➜ cat short.txt  # 访问更方便
```

### 3. 配置管理

```sh
# 创建配置文件的软链接
➜ ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
# 启用配置只需创建软链接，禁用只需删除软链接
```

### 4. 跨文件系统链接

```sh
# 链接到不同文件系统的文件
➜ ln -s /mnt/external/data.txt ~/data.txt
```

### 5. 动态库版本管理

```sh
# 库文件版本管理
➜ ln -s libmylib.so.1.0.0 libmylib.so.1
➜ ln -s libmylib.so.1 libmylib.so
# 更新库时只需修改软链接
```

# 常见问题

## 1. 如何判断是硬链接还是软链接？

```sh
# 方法1：使用 ls -l（软链接显示 ->）
➜ ls -l file.txt link.txt
-rw-r--r-- 2 user group 1024 Jan 1 10:00 file.txt
lrwxrwxrwx 1 user group   12 Jan 1 10:01 link.txt -> file.txt

# 方法2：使用 stat（查看文件类型）
➜ stat link.txt | grep "symbolic link"

# 方法3：使用 file 命令
➜ file link.txt
link.txt: symbolic link to file.txt
```

## 2. 删除软链接的正确方法

```sh
# 正确：直接删除软链接文件
➜ rm softlink.txt

# 错误：删除软链接指向的文件（会变成死链接）
➜ rm original.txt
➜ ls -l softlink.txt
lrwxrwxrwx 1 user group 12 Jan 1 10:01 softlink.txt -> original.txt
➜ cat softlink.txt
cat: softlink.txt: No such file or directory
```

## 3. 软链接的相对路径和绝对路径

```sh
# 绝对路径（推荐，更稳定）
➜ ln -s /absolute/path/to/file.txt link1.txt

# 相对路径（相对于软链接所在目录）
➜ ln -s ../file.txt link2.txt
# 注意：相对路径是相对于软链接文件的位置，不是当前工作目录
```

## 4. 硬链接的限制

```sh
# 不能对目录创建硬链接
➜ ln dir hardlink_dir
ln: dir: hard link not allowed for directory

# 不能跨文件系统创建硬链接
➜ ln /mnt/otherfs/file.txt ./link.txt
ln: failed to create hard link './link.txt' => '/mnt/otherfs/file.txt': Invalid cross-device link
```

## 5. 查找所有硬链接

```sh
# 使用 find 的 -samefile 选项
➜ find / -samefile /path/to/file.txt 2>/dev/null

# 使用 find 的 -inum 选项（通过 inode 号）
➜ ls -i file.txt
123456 file.txt
➜ find / -inum 123456 2>/dev/null
```

# 注意事项

1. **硬链接不能跨文件系统**：硬链接必须在同一文件系统内
2. **硬链接不能链接目录**：只能对文件创建硬链接
3. **软链接路径**：使用相对路径时要注意路径是相对于软链接文件的位置
4. **死链接**：删除软链接指向的文件会导致死链接，需要及时清理
5. **循环链接**：避免创建循环的软链接（A -> B, B -> A）
6. **权限**：软链接的权限通常是 777，但实际权限由目标文件决定
7. **备份**：备份时要注意是否包含软链接，以及如何处理死链接

# 参考文献
* [理解 Linux 的硬链接与软链接](https://www.ibm.com/developerworks/cn/linux/l-cn-hardandsymb-links/index.html)
* [GNU Coreutils - ln](https://www.gnu.org/software/coreutils/manual/html_node/ln-invocation.html)
