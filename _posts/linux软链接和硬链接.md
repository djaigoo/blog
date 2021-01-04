---
author: djaigo
title: linux软链接和硬链接
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - link
date: 2020-04-09 13:00:43
---

我们知道文件都有文件名与数据，这在 Linux 上被分成两个部分：用户数据 (user data) 与元数据 (metadata)。用户数据，即文件数据块 (data block)，数据块是记录文件真实内容的地方；而元数据则是文件的附加属性，如文件大小、创建时间、所有者等信息。在 Linux 中，元数据中的 inode 号（inode 是文件元数据的一部分但其并不包含文件名，inode 号即索引节点号）才是文件的唯一标识而非文件名。文件名仅是为了方便人们的记忆和使用，系统或程序通过 inode 号寻找正确的文件数据块。
为解决文件的共享使用，Linux 系统引入了两种链接：硬链接 (hard link) 与软链接（又称符号链接，即 soft link 或 symbolic link）。链接为 Linux 系统解决了文件的共享使用，还带来了隐藏文件路径、增加权限安全及节省存储等好处。若一个 inode 号对应多个文件名，则称这些文件为硬链接。换言之，硬链接就是同一个文件使用了多个别名他们有共同的 inode。硬链接可由命令 link 或 ln 创建。

# 硬链接
由于硬链接是有着相同 inode 号仅文件名不同的文件，因此硬链接存在以下几点特性：

*   文件有相同的 inode 及 data block；
*   只能对已存在的文件进行创建；
*   不能交叉文件系统进行硬链接的创建；
*   不能对目录进行创建，只可对文件创建；
*   删除一个硬链接文件并不影响其他有相同 inode 号的文件。

# 软链接
软链接与硬链接不同，若文件用户数据块中存放的内容是另一文件的路径名的指向，则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。软链接有着自己的 inode 号以及用户数据块。因此软链接的创建与使用没有类似硬链接的诸多限制：

*   软链接有自己的文件属性及权限等；
*   可对不存在的文件或目录创建软链接；
*   软链接可交叉文件系统；
*   软链接可对文件或目录创建；
*   创建软链接时，链接计数 i_nlink 不会增加；
*   删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

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

# 参考文献
[理解 Linux 的硬链接与软链接](https://www.ibm.com/developerworks/cn/linux/l-cn-hardandsymb-links/index.html)
