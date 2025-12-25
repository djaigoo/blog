---
author: djaigo
title: Linux常用命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
  - command
---

本文档简要介绍 Linux 系统中常用的 shell 命令，包括文本处理、网络、文件操作、系统信息等类别。

# 文本处理命令

## grep - 文本搜索

在文件中搜索匹配模式的行。

```sh
# 基本用法
grep "pattern" file.txt

# 常用选项
grep -i "pattern" file.txt          # 忽略大小写
grep -r "pattern" dir/              # 递归搜索
grep -n "pattern" file.txt          # 显示行号
grep -v "pattern" file.txt          # 反向匹配
grep -E "pattern" file.txt          # 扩展正则表达式
grep -l "pattern" *.txt              # 只显示文件名
grep -c "pattern" file.txt          # 统计匹配行数
```

## sed - 流编辑器

对文本进行流式编辑，支持查找替换、删除、插入等操作。

```sh
# 基本用法
sed 's/old/new/g' file.txt          # 替换文本
sed -i 's/old/new/g' file.txt       # 直接修改文件
sed -n '10,20p' file.txt            # 打印10-20行
sed '/pattern/d' file.txt           # 删除匹配行
sed '1d' file.txt                   # 删除第一行
sed '$d' file.txt                   # 删除最后一行
sed 's/^/prefix/' file.txt          # 行首添加
sed 's/$/suffix/' file.txt          # 行尾添加
```

## awk - 文本处理工具

强大的文本分析和处理工具，支持按列处理。

```sh
# 基本用法
awk '{print $1}' file.txt           # 打印第一列
awk '{print $1, $3}' file.txt       # 打印第1和第3列
awk '{print $NF}' file.txt          # 打印最后一列
awk '/pattern/ {print}' file.txt    # 匹配模式后打印
awk -F: '{print $1}' /etc/passwd    # 指定分隔符
awk '{sum+=$1} END {print sum}' file.txt  # 求和
awk 'NR==1 || NR==10' file.txt      # 打印第1和第10行
```

## cut - 列提取

从文件中提取列。

```sh
# 基本用法
cut -d: -f1 /etc/passwd             # 以:分隔，提取第1列
cut -d' ' -f1,3 file.txt             # 以空格分隔，提取第1和第3列
cut -c1-10 file.txt                  # 提取第1-10个字符
cut -c1,3,5 file.txt                # 提取第1、3、5个字符
```

## sort - 排序

对文本行进行排序。

```sh
# 基本用法
sort file.txt                       # 按字母顺序排序
sort -n file.txt                    # 按数字排序
sort -r file.txt                    # 逆序排序
sort -u file.txt                    # 去重排序
sort -k2 file.txt                   # 按第2列排序
sort -t: -k3 -n /etc/passwd         # 以:分隔，按第3列数字排序
```

## uniq - 去重

去除相邻的重复行。

```sh
# 基本用法
uniq file.txt                       # 去重（需先排序）
sort file.txt | uniq                # 排序后去重
uniq -c file.txt                    # 统计重复次数
uniq -d file.txt                    # 只显示重复行
uniq -u file.txt                    # 只显示不重复的行
```

## wc - 统计

统计文件的行数、单词数、字符数。

```sh
# 基本用法
wc file.txt                         # 显示行数、单词数、字符数
wc -l file.txt                      # 只显示行数
wc -w file.txt                      # 只显示单词数
wc -c file.txt                      # 只显示字符数
wc -m file.txt                      # 只显示字符数（多字节字符）
```

## head/tail - 查看文件头尾

查看文件的开头或结尾部分。

```sh
# head - 查看文件开头
head file.txt                       # 显示前10行
head -n 20 file.txt                 # 显示前20行
head -c 100 file.txt                # 显示前100个字符

# tail - 查看文件结尾
tail file.txt                       # 显示后10行
tail -n 20 file.txt                 # 显示后20行
tail -f log.txt                     # 实时跟踪文件（常用于日志）
tail -F log.txt                     # 跟踪文件（文件被删除重建后继续跟踪）
```

## cat/less/more - 查看文件

查看文件内容。

```sh
# cat - 显示整个文件
cat file.txt                        # 显示文件内容
cat file1.txt file2.txt             # 连接多个文件
cat -n file.txt                     # 显示行号
cat -A file.txt                      # 显示所有字符（包括控制字符）

# less - 分页查看（推荐）
less file.txt                       # 分页查看，支持上下滚动
# 在less中：空格=下一页，b=上一页，q=退出，/搜索

# more - 分页查看（较老）
more file.txt                       # 分页查看，只能向下
```

## tr - 字符转换

转换或删除字符。

```sh
# 基本用法
tr 'a-z' 'A-Z' < file.txt           # 小写转大写
tr ' ' '\n' < file.txt              # 空格转换行
tr -d '0-9' < file.txt              # 删除数字
tr -s ' ' < file.txt                # 压缩连续空格
```

## paste - 合并文件

按列合并文件。

```sh
# 基本用法
paste file1.txt file2.txt           # 按列合并
paste -d: file1.txt file2.txt       # 指定分隔符
paste -s file.txt                   # 将文件行合并为一行
```

## join - 连接文件

基于共同字段连接两个文件。

```sh
# 基本用法
join file1.txt file2.txt            # 基于第一列连接
join -1 2 -2 1 file1.txt file2.txt  # 指定连接字段
join -t: file1.txt file2.txt         # 指定分隔符
```

# 网络命令

## curl - 网络请求

发送 HTTP 请求，下载文件等。

```sh
# 基本用法
curl http://example.com             # GET 请求
curl -O http://example.com/file.zip # 下载文件
curl -o output.txt http://example.com # 保存到文件
curl -L http://example.com          # 跟随重定向
curl -I http://example.com          # 只显示响应头
curl -X POST -d "data" http://example.com # POST 请求
curl -H "Content-Type: application/json" -d '{"key":"value"}' http://example.com
curl -u user:pass http://example.com # 基本认证
curl -v http://example.com          # 详细输出
```

## wget - 下载工具

从网络下载文件。

```sh
# 基本用法
wget http://example.com/file.zip    # 下载文件
wget -O output.zip http://example.com/file.zip # 指定输出文件名
wget -c http://example.com/file.zip # 断点续传
wget -r http://example.com         # 递归下载
wget -P /path/to/save http://example.com/file.zip # 指定保存目录
wget --limit-rate=200k http://example.com/file.zip # 限制下载速度
```

## ping - 网络连通性测试

测试网络连通性和延迟。

```sh
# 基本用法
ping example.com                    # 持续ping
ping -c 4 example.com               # ping 4次后停止
ping -i 2 example.com                # 间隔2秒ping
ping -s 1024 example.com            # 指定数据包大小
```

## netstat - 网络连接信息

显示网络连接、路由表、接口统计等。

```sh
# 基本用法
netstat -an                         # 显示所有连接
netstat -tuln                       # 显示TCP/UDP监听端口
netstat -rn                         # 显示路由表
netstat -i                          # 显示网络接口统计
netstat -p                          # 显示进程信息
netstat -s                          # 显示网络统计信息
```

## ss - Socket 统计（netstat 的替代）

显示 socket 统计信息，比 netstat 更快。

```sh
# 基本用法
ss -an                              # 显示所有连接
ss -tuln                            # 显示TCP/UDP监听端口
ss -tulnp                           # 显示进程信息
ss -s                               # 显示统计信息
ss -o state established             # 显示已建立的连接
```

## ifconfig - 网络接口配置

配置和显示网络接口信息。

```sh
# 基本用法
ifconfig                            # 显示所有接口
ifconfig eth0                       # 显示特定接口
ifconfig eth0 up                    # 启用接口
ifconfig eth0 down                  # 禁用接口
ifconfig eth0 192.168.1.100         # 设置IP地址
ifconfig eth0 netmask 255.255.255.0 # 设置子网掩码
```

## ip - 网络配置（ifconfig 的替代）

现代的网络配置工具，功能更强大。

```sh
# 基本用法
ip addr show                        # 显示IP地址
ip link show                        # 显示网络接口
ip route show                       # 显示路由表
ip addr add 192.168.1.100/24 dev eth0 # 添加IP地址
ip link set eth0 up                 # 启用接口
ip route add default via 192.168.1.1 # 添加默认路由
```

## telnet - 远程登录

测试端口连通性和远程登录。

```sh
# 基本用法
telnet example.com 80               # 测试端口连通性
telnet example.com                  # 远程登录（默认23端口）
```

## nc (netcat) - 网络工具

网络调试和数据传输工具。

```sh
# 基本用法
nc -l 8080                          # 监听端口
nc example.com 80                   # 连接到远程主机
nc -zv example.com 80               # 扫描端口
nc -l -p 8080 -e /bin/bash          # 监听并执行命令（反向shell）
```

## dig - DNS 查询

DNS 查询工具。

```sh
# 基本用法
dig example.com                     # 查询A记录
dig example.com MX                  # 查询MX记录
dig @8.8.8.8 example.com           # 指定DNS服务器
dig -x 8.8.8.8                      # 反向DNS查询
```

## nslookup - DNS 查询

另一个 DNS 查询工具。

```sh
# 基本用法
nslookup example.com                # 查询域名
nslookup 8.8.8.8                    # 反向查询
```

## traceroute - 路由追踪

追踪数据包到达目标主机的路径。

```sh
# 基本用法
traceroute example.com              # 追踪路由
traceroute -n example.com           # 不解析主机名
traceroute -m 30 example.com        # 设置最大跳数
```

## tcpdump - 网络抓包

捕获和分析网络数据包。

```sh
# 基本用法
tcpdump -i eth0                     # 捕获eth0接口的数据包
tcpdump port 80                     # 捕获80端口的数据包
tcpdump host 192.168.1.1            # 捕获特定主机的数据包
tcpdump -w capture.pcap             # 保存到文件
tcpdump -r capture.pcap             # 读取文件
tcpdump -n                           # 不解析主机名
```

# 文件操作命令

## ls - 列出文件

列出目录内容。

```sh
# 基本用法
ls                                 # 列出当前目录
ls -l                              # 详细列表
ls -a                              # 显示隐藏文件
ls -h                              # 人类可读的文件大小
ls -t                              # 按时间排序
ls -S                              # 按大小排序
ls -R                              # 递归列出
ls -lh                             # 组合选项
```

## cd - 切换目录

切换工作目录。

```sh
# 基本用法
cd /path/to/dir                    # 切换到指定目录
cd ~                               # 切换到用户主目录
cd -                               # 切换到上一个目录
cd ..                              # 切换到上一级目录
```

## pwd - 显示当前目录

显示当前工作目录的路径。

```sh
pwd                                # 显示当前目录
```

## mkdir - 创建目录

创建新目录。

```sh
# 基本用法
mkdir dirname                      # 创建目录
mkdir -p dir1/dir2/dir3            # 递归创建目录
mkdir -m 755 dirname               # 指定权限
```

## rm - 删除文件/目录

删除文件或目录。

```sh
# 基本用法
rm file.txt                        # 删除文件
rm -r dir/                         # 递归删除目录
rm -f file.txt                     # 强制删除，不提示
rm -rf dir/                        # 强制递归删除（危险）
rm -i file.txt                     # 交互式删除
```

## cp - 复制文件

复制文件或目录。

```sh
# 基本用法
cp file1.txt file2.txt             # 复制文件
cp -r dir1/ dir2/                  # 递归复制目录
cp -p file1.txt file2.txt          # 保留权限和时间戳
cp -a dir1/ dir2/                  # 归档复制（保留所有属性）
cp -u file1.txt file2.txt          # 只复制更新的文件
```

## mv - 移动/重命名

移动或重命名文件/目录。

```sh
# 基本用法
mv file1.txt file2.txt             # 重命名文件
mv file.txt /path/to/dir/          # 移动文件
mv -i file1.txt file2.txt          # 交互式移动
mv -u file1.txt file2.txt          # 只移动更新的文件
```

## find - 查找文件

查找文件和目录。

```sh
# 基本用法
find /path -name "*.txt"           # 按名称查找
find /path -type f                 # 查找文件
find /path -type d                 # 查找目录
find /path -mtime -7               # 查找7天内修改的文件
find /path -size +100M             # 查找大于100M的文件
find /path -exec ls -l {} \;       # 对找到的文件执行命令
find /path -name "*.txt" -delete   # 删除找到的文件
```

## chmod - 修改权限

修改文件或目录的权限。

```sh
# 基本用法
chmod 755 file.txt                 # 数字方式设置权限
chmod u+x file.txt                 # 给所有者添加执行权限
chmod g-w file.txt                 # 删除组的写权限
chmod a+r file.txt                 # 给所有人添加读权限
chmod -R 755 dir/                  # 递归设置权限
```

## chown - 修改所有者

修改文件或目录的所有者。

```sh
# 基本用法
chown user:group file.txt          # 修改所有者和组
chown user file.txt                # 只修改所有者
chown -R user:group dir/            # 递归修改
```

## tar - 归档工具

创建和解压归档文件。

```sh
# 基本用法
tar -czf archive.tar.gz dir/       # 创建gzip压缩归档
tar -xzf archive.tar.gz             # 解压gzip归档
tar -cjf archive.tar.bz2 dir/       # 创建bzip2压缩归档
tar -xjf archive.tar.bz2            # 解压bzip2归档
tar -tf archive.tar.gz             # 列出归档内容
tar -xzf archive.tar.gz -C /path/  # 解压到指定目录
```

## zip/unzip - 压缩工具

创建和解压 zip 文件。

```sh
# zip - 创建压缩文件
zip -r archive.zip dir/             # 递归压缩目录
zip -9 archive.zip file.txt        # 最大压缩率

# unzip - 解压文件
unzip archive.zip                   # 解压文件
unzip -l archive.zip                # 列出内容
unzip -d /path/ archive.zip         # 解压到指定目录
```

# 系统信息命令

## ps - 进程信息

显示进程信息。

```sh
# 基本用法
ps                                 # 显示当前终端进程
ps aux                             # 显示所有进程
ps -ef                             # 显示所有进程（另一种格式）
ps aux | grep nginx                # 查找特定进程
ps -p 1234                         # 显示特定PID的进程
```

## top/htop - 进程监控

实时显示进程和系统资源使用情况。

```sh
# top - 系统监控
top                                # 实时监控
top -u username                    # 监控特定用户
top -p 1234                        # 监控特定进程

# htop - 增强版top（需安装）
htop                               # 更友好的界面
```

## kill - 终止进程

终止进程。

```sh
# 基本用法
kill 1234                          # 终止进程（默认SIGTERM）
kill -9 1234                       # 强制终止（SIGKILL）
kill -HUP 1234                     # 发送HUP信号
killall nginx                      # 终止所有nginx进程
pkill nginx                        # 按名称终止进程
```

## df - 磁盘空间

显示文件系统磁盘空间使用情况。

```sh
# 基本用法
df                                 # 显示所有文件系统
df -h                              # 人类可读格式
df -T                              # 显示文件系统类型
df -i                              # 显示inode使用情况
```

## du - 目录大小

显示目录或文件的磁盘使用情况。

```sh
# 基本用法
du                                 # 显示当前目录大小
du -h                              # 人类可读格式
du -sh dir/                        # 显示目录总大小
du -h --max-depth=1                # 只显示一级目录
du -ah                             # 显示所有文件和目录
```

## free - 内存信息

显示内存使用情况。

```sh
# 基本用法
free                               # 显示内存使用
free -h                            # 人类可读格式
free -m                            # 以MB为单位
free -g                            # 以GB为单位
free -s 5                          # 每5秒刷新一次
```

## uname - 系统信息

显示系统信息。

```sh
# 基本用法
uname                              # 显示内核名称
uname -a                           # 显示所有信息
uname -r                            # 显示内核版本
uname -m                            # 显示机器硬件名称
```

## uptime - 运行时间

显示系统运行时间和负载。

```sh
uptime                             # 显示运行时间和负载
```

## who/w - 登录用户

显示当前登录的用户。

```sh
# who - 显示登录用户
who                                # 显示登录用户
whoami                             # 显示当前用户

# w - 显示登录用户和活动
w                                  # 显示登录用户和活动
```

## date - 日期时间

显示或设置系统日期和时间。

```sh
# 基本用法
date                               # 显示当前日期时间
date +%Y-%m-%d                     # 格式化输出
date +%H:%M:%S                     # 只显示时间
date -s "2024-01-01 12:00:00"      # 设置系统时间（需root）
```

# 其他常用命令

## history - 命令历史

显示命令历史记录。

```sh
# 基本用法
history                            # 显示命令历史
history | grep "pattern"           # 搜索历史命令
!123                               # 执行历史中第123条命令
!!                                 # 执行上一条命令
!pattern                           # 执行最近匹配的命令
```

## alias - 命令别名

创建命令别名。

```sh
# 基本用法
alias ll='ls -alF'                 # 创建别名
alias grep='grep --color=auto'     # 创建别名
unalias ll                         # 删除别名
alias                               # 显示所有别名
```

## which/whereis - 查找命令

查找命令的位置。

```sh
# which - 查找命令路径
which ls                           # 查找ls命令路径
which -a python                    # 查找所有匹配的命令

# whereis - 查找命令、源码和手册页
whereis ls                         # 查找ls相关文件
whereis -b ls                      # 只查找二进制文件
```

## man - 帮助手册

查看命令的帮助手册。

```sh
# 基本用法
man ls                             # 查看ls命令手册
man -k keyword                     # 搜索关键字
man -f command                     # 显示命令的简短描述
```

## nohup - 后台运行

在后台运行命令，即使终端关闭也不中断。

```sh
# 基本用法
nohup command &                    # 后台运行命令
nohup command > output.log 2>&1 &  # 后台运行并重定向输出
```

## screen/tmux - 终端复用

终端复用工具，可以创建多个会话。

```sh
# screen - 终端复用
screen                              # 创建新会话
screen -S name                      # 创建命名会话
screen -r name                      # 恢复会话
screen -ls                          # 列出所有会话
# 在screen中：Ctrl+A+D 分离会话

# tmux - 现代终端复用（需安装）
tmux                                # 创建新会话
tmux new -s name                    # 创建命名会话
tmux attach -t name                 # 附加到会话
tmux ls                             # 列出所有会话
# 在tmux中：Ctrl+B+D 分离会话
```

## watch - 定期执行

定期执行命令并显示输出。

```sh
# 基本用法
watch -n 1 'ps aux | grep nginx'   # 每秒执行一次
watch -d 'ls -l'                   # 高亮显示变化
watch -n 5 'df -h'                  # 每5秒执行一次
```

## xargs - 参数传递

从标准输入读取参数并执行命令。

```sh
# 基本用法
find . -name "*.txt" | xargs rm     # 删除找到的文件
find . -name "*.txt" | xargs grep "pattern" # 在找到的文件中搜索
echo "file1 file2" | xargs ls -l    # 对参数执行命令
find . -name "*.txt" -print0 | xargs -0 rm # 处理包含空格的文件名
```

## tee - 分流输出

将输出同时写入文件和标准输出。

```sh
# 基本用法
ls -l | tee output.txt              # 同时显示和保存
ls -l | tee -a output.txt           # 追加模式
command 2>&1 | tee output.log       # 同时保存标准输出和错误输出
```

## diff - 文件比较

比较两个文件的差异。

```sh
# 基本用法
diff file1.txt file2.txt           # 比较两个文件
diff -u file1.txt file2.txt         # 统一格式输出
diff -r dir1/ dir2/                 # 递归比较目录
```

## patch - 应用补丁

应用补丁文件。

```sh
# 基本用法
patch < patchfile                   # 应用补丁
patch -p1 < patchfile               # 应用补丁（去除一级目录）
```

# 管道和重定向

## 管道 (|)

将一个命令的输出作为另一个命令的输入。

```sh
# 基本用法
ls -l | grep "txt"                  # 管道传递
ps aux | grep nginx                 # 查找进程
cat file.txt | sort | uniq          # 多个管道
```

## 重定向

```sh
# 输出重定向
command > file.txt                  # 覆盖写入
command >> file.txt                 # 追加写入
command 2> error.log                # 错误输出重定向
command > output.log 2>&1           # 标准输出和错误都重定向
command > /dev/null 2>&1            # 丢弃所有输出

# 输入重定向
command < file.txt                  # 从文件读取输入
command << EOF                      # Here document
content
EOF
```

# 组合使用示例

```sh
# 查找并统计
find . -name "*.log" | xargs wc -l

# 日志分析
tail -f access.log | grep "ERROR" | awk '{print $1}' | sort | uniq -c

# 系统监控
watch -n 1 'ps aux | grep nginx | grep -v grep'

# 批量处理
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# 网络诊断
ping -c 4 example.com && curl -I http://example.com

# 文件操作
tar -czf backup.tar.gz $(find . -name "*.log") && rm $(find . -name "*.log")
```

# 参考文献
* [Linux命令大全](https://www.runoob.com/linux/linux-command-manual.html)
* [GNU Coreutils](https://www.gnu.org/software/coreutils/)

