---
author: djaigo
title: redis conf 说明
date: 2019-12-10 14:43:35
update: 
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/redis.png
categories: 
  - redis
tags: 
  - redis
  - config
enable html: true
---

最新Redis配置文件获取[redis.conf](http://download.redis.io/redis-stable/redis.conf)

# start
启动Redis启动。
```sh
$ ./redis-server /path/to/redis.conf
```

配置文件单位说明，单位不区分大小写。
```sh
# 1k => 1000 bytes
# 1kb => 1024 bytes
# 1m => 1000000 bytes
# 1mb => 1024 * 1024 bytes
# 1g => 1000000000 bytes
# 1gb => 1024 * 1024 * 1024 bytes
```

# include
`include`可以引入其他的配置文件，且不会被`CONFIG REWRITE`命令复写。Redis总是使用最后处理的行作为配置指令的值，最好在文件开始的时候`include`，避免运行时复写配置。如果想用`include`覆盖之前的配置可以放在文件末尾。
```sh
# include /path/to/local.conf
# include /path/to/other.conf
```

# module
在启动时加载模块，如果无法加载，Redis会`abort`，可以同时加载多个模块。
```sh
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so
```

# network
## bind
默认地，如果没有指定`bind`指令，Redis监听监听服务器上所有可用网络接口的连接。可以使用`bind`配置指令只侦听一个或多个选定的网卡接口，后跟一个或多个IP地址。
如果不指定bind指定是一件很危险的事，所以Redis默认指定本地的环回地址。
```sh
# bind 192.168.1.100 10.0.0.1
bind 127.0.0.1 ::1
```

## protected-mode
保护模式是一层安全保护，以避免Redis实例在Internet上保持打开状态被访问和利用。
当保护模式打开，并且：
* Redis未`bind`到一组地址
* 没有配置密码

Redis只能接受来自IPv4和IPv6环回地址（127.0.0.1和::1）、Unix域套接字的连接。
保护模式默认是打开的。如果想其他地址访问Redis没有使用密码，或没有使用bind指定网络接口可以关闭保护模式。
```sh
protected-mode yes
```

## port
接受指定端口的连接。如果指定为0，Redis不会监听TCP socket。
```sh
port 6379
```

## tcp-backlog
TCP listen()函数的backlog参数，挂起连接队列的最大长度。
```sh
tcp-backlog 511
```

## Unix socket
指定`Unix socket`的路径，Redis默认不监听`Unix socket`。
```sh
# unixsocket /tmp/redis.sock
# unixsocketperm 700
```

## timeout
设置连接多少秒没有使用后断开连接，0表示不启用。
```sh
timeout 0
```

## TCP keepalive
如果非零，使用SO_KEEPALIVE发送TCP ACK，来保活连接。
这样做有两个理由：
* 检测对端状态
* 

在Linux上，每隔指定的值（单位秒）都会发送TCP ACK，如果需要关闭连接则需要两倍这个时间。
其他内核取决于内核配置。
Redis默认300秒。
```sh
tcp-keepalive 300
```

# general
## daemonize
Redis默认是不作为`daemon`运行，可以使用`yes`启动该选项。
Redis在启用指令后会在`/var/run/redis.pid`产生`pid`文件。
```sh
daemonize no
```

## supervised
如果使用upstart或者systemd启动Redis，可以使用supervised指令进行交互。
选项：
* no - 不使用supervision交互
* upstart - 让Redis进入`SIGSTOP`模式
* systemd - 向`$NOTIFY_SOCKET`写入`READY=1`
* auto - 基于环境变量`UPSTART_JOB`或 `NOTIFY_SOCKET`来设置upstart还是systemd模式

supervised只表示进程已经就绪，并不持续supervisor。
```sh
supervised no
```

## pidfile
如果指定了pidfile，那么Redis将会在启动的时候写入，退出的时候删除。
当Redis启动是使用非daemonized，配置中没有指定pidfile，则不会有pidfile创建；当Redis使用daemonized启动时，即使没有指定pidfile，也会创建，默认是`/var/run/redis.pid`。
如果Redis无法创建pidfile，也不会产生任何影响，Redis依旧可以正常启动和运行。
```sh
pidfile /var/run/redis_6379.pid
```

## loglevel
设置日志等级：
* debug，对开发测试有用
* verbose，一些有用的信息，不像debug那么杂乱
* notice，一般生产日志
* warning，记录关键信息

```sh
loglevel notice
```

## logfile
指定日志文件名，空字符串表示Redis日志强制输出到标准输出。如果使用daemonized并且把日志输出到标准输出，则日志会被发送到`/dev/null`。
```sh
logfile ""
```

## syslog
### enabled
将日志输出到system logger，指定`syslog-enabled`为`yes`，可以按照需求添加其他参数。
```sh
# syslog-enabled no
```

### ident
指定syslog标识。
```sh
# syslog-ident redis
```

### facility
指定syslog的`facility`，必须是`USER`或介于`LOCAL0-LOCAL7`。
```sh
# syslog-facility local0
```

## databases
设置Redis数据库的数量，默认`DB`是0，可以使用`SELECT`选择`dbid`介于`0-databases-1`。
```sh
databases 16
```

## show logo
默认在Redis启动的时候打印`ASCII logo`，仅在log输出在标准输出或标准输出是TTY的时候。只有在交互式的时候才显示`logo`。
```sh
always-show-logo yes
```

# snapshotting
## save
数据库快照，将Redis数据保存到disk，命令`save second changes`。
当指定秒和写操作次数同时满足的时候写入disk。
可以通过注释掉save来禁用快照，也可以使用`save ""`来禁用已经设置的快照选项。
示例表示：
* 900秒（15分钟）至少有一个键改动
* 300秒（5分钟）至少有10个键改动
* 60秒（1分钟）至少有10000个键改动
```sh
save 900 1
save 300 10
save 60 10000
```

## stop-writes-on-bgsave-error
当启动RDB快照时，Redis会停止写入，并且最后一次后台保存会失败。
```sh
stop-writes-on-bgsave-error yes
```

## rdbcompression
当使用dump .rdb数据库时，是否使用LZF压缩字符串对象
```sh
rdbcompression yes
```

## rdbchecksum
CRC64校验和存放于RDB文件的末尾，这可以抵抗损坏，但是有性能问题，可以禁用。
```sh
rdbchecksum yes
```

## dbfilename
指定dump文件
```sh
dbfilename dump.rdb
```

## dir
指定工作目录，`dbfilename`指定的文件将会在`dir`中创建，只追加的文件也在此目录中创建。
`dir`必须指定一个目录，非文件路径。
```sh
dir ./
```


# replication
## replicaof
`Master-Replica`拷贝，使用replicaof让一个Redis实例复制另一个Redis实例。
相关概念：
* Redis复制是异步的，如果一个主Redis实例没有与给定数量的副本连接，那么可以配置他停止接收写操作
* 如果复制链接丢失的时间相对较少，Redis副本可以与主服务器执行部分重新同步。根据需要，您可能需要使用合理的值配置复制积压工作的大小（请参阅此文件的下一节）。
* 复制是一个自动的过程，网络分区副本自动尝试重新连接到主服务器，并与它们重新同步。

```sh
# replicaof masterip masterport
```

## masterauth
如果master有密码（使用requirepass配置），副本在复制的之前必须要验证密码，否则将拒绝复制。
```sh
# masterauth <master-password>
```

## replica-serve-stale-data
当副本与master断开连接，或当复制正在进行时，副本可以以两种不同的方式发挥做用：
* 如果将`replica-serve-stale-data`设置成`yes`，副本将仍然回复客户端的请求，可能数据已过期，或者为空
* 如果将`replica-serve-stale-data`设置成`no`，副本将用`SYNC with master in progress`回复所有请求，除了`INFO`，`replicaOF`，`AUTH`，`PING`，`SHUTDOWN`，`REPLCONF`，`ROLE`，`CONFIG`，`SUBSCRIBE`，`UNSUBSCRIBE`，`PSUBSCRIBE`，`PUNSUBSCRIBE`，`PUBLISH`，`PUBSUB`，`COMMAND`，`POST`，`HOST:`，`LATENCY`

```sh
replica-serve-stale-data yes
```

## replica-read-only
设置副本实例是否可以写，默认副本是只读的。副本仍可以执行所有管理命令，可以使用`rename-command`遮蔽这些管理命令。
```sh
replica-read-only yes
```

## repl-diskless-sync
新的复制副本和重新连接的复制副本无法继续仅接收差异的复制过程，需要执行所谓的“完全同步”。RDB文件从主服务器传输到副本服务器。
传输可以通过两种不同的方式进行：
* 磁盘支持，Redis主服务器创建一个新进程，将RDB文件写入磁盘，稍后，父进程将文件以递增方式传输到副本。
* 无磁盘，Redis主服务器创建一个新进程，将RDB文件写入副本套接字，不通过磁盘。

使用磁盘备份复制，在生成RDB文件的同时，可以在生成RDB文件的当前子级完成工作后，将更多的副本排队并与RDB文件一起提供服务。
在无盘复制中，一旦传输开始，到达的新副本将排队，当当前副本终止时，将开始新的传输。`master`实例机会在开始传输之前等待一段可配置的时间（以秒为单位），以希望多个副本能够到达，并且可以并行传输。
使用低速磁盘和快速（大带宽）网络，无盘复制工作得更好。
```sh
repl-diskless-sync no
```

## repl-diskless-sync-delay
启动无盘复制时，可以配置服务器的等待延迟，这一点很重要，因为一旦传输开始，就不可能为到达的新副本提供服务，这些副本将排队等待下一次RDB传输，因此服务器将等待一段延迟，以便让更多副本到达。
默认5秒，设置为0表示禁用
```sh
repl-diskless-sync-delay 5
```

## repl-ping-replica-period
副本以预先定义的间隔向服务器发送ping。可以使用`repl-ping-replica-period`选项更改此间隔。默认值为10秒。
```sh
# repl-ping-replica-period 10
```

## repl-timeout
以下情况会复制超时：
* 从副本角度看，同步期间的批量传输I/O。
* 从副本角度看，master实例超时。
* 从master实例看，复制超时。

确保`repl-timeout`比`repl-ping-replica-period`大，否则每次主服务器和副本之间的通信量低时都会检测到超时。
```sh
# repl-timeout 60
```

## repl-disable-tcp-nodelay
在副本发送`SYNC`后禁用`TCP_NODELAY`？
如果选择`yes`，Redis会占用少量带宽发送少量TCP包给副本，但这可能会增加副本同步延迟，使用Linux内核默认配置最多可延迟40毫秒。
如果选择`no`，延迟会减少，但是会占用更多带宽用于复制。
默认选择`no`，但是在非常高流量下或者master和副本之间有多跳时，`yes`也是不错的选择。
```sh
repl-disable-tcp-nodelay no
```

## repl-backlog-size
设置副本`backlog`大小，`backlog`是一个缓冲区，当副本断开连接一段时间后，它会累积副本数据，因此当副本希望再次重新连接时，通常不需要完全重新同步，部分重新同步就足够了，只需传递断开连接时副本丢失的数据部分。只有在至少连接了一个副本后，才会分配积压工作。
```sh
#repl-backlog-size 1mb
```

## repl-backlog-ttl
当master不在连接副本一段时间后释放backlog，该选项设置最后一个断开连接的副本后多久释放backlog，单位秒。如果为0，则永不释放。副本不会释放backlog，所以总是积压。
```sh
# repl-backlog-ttl 3600
```

## replica-priority
副本优先级，当master不在工作时，升级优先级编号低的成为master。当设置成0时，表示无法变成master。默认情况下优先级为100。
```sh
replica-priority 100
```

## min-replicas-to-write
如果小于指定副本数量，并且通信小于指定时间，master会停止写入操作。副本必须都处于在线状态。其中一个选项为0表示禁用。默认禁用。
示例表示，3个副本并且滞后10秒。
```sh
# min-replicas-to-write 3
# min-replicas-max-lag 10
```

## replica-announce-ip
Redis master可以通过指定副本地址连接副本，Redis Sentinel可以发现副本实例。
复制副本通常报告的列出的IP和地址是通过以下方式获得的：
* IP，通过检查复制副本用于与主服务器连接的套接字的对等地址，可以自动检测该地址。
* port，在复制握手期间，该端口由副本通信，通常是副本用来侦听连接的端口。

但是，当使用端口转发或网络地址转换（NAT）时，复制副本实际上可以通过不同的IP和端口对访问。副本可以使用以下两个选项向其主服务器报告一组特定的IP和端口，以便信息和角色都报告这些值。
```sh
# replica-announce-ip 5.5.5.5
# replica-announce-port 1234
```

# security
## requirepass
设置密码，客户端在使用的时候需要使用`AUTH`鉴权。
```sh
# requirepass foobared
```

## rename-command
重命名命令。如果设置为空表示禁用命令。修改命令可能会在AOF模式或传输到副本中引发问题。
```sh
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
# rename-command CONFIG ""
```

# client
## maxclient
设置客户端最大连接数，如果不指定则是当前文件系统最大值减32，达到限制后新的连接会收到`max number of clients reached`错误。
```sh
# maxclients 10000
```

# memory management
## maxmemory
设置占用内存最大值字节数，达到内存限制时，会采用所选的策略删除键。
如果Redis无法根据策略删除密钥，或者策略设置为`noeviction`。如果命令将使用更多内存，如SET，LPUSH等时，Redis将开始回复错误。只读命令正常回复。
当将Redis用作LRU或LFU缓存，或为实例设置硬内存限制（使用`noevection`策略）时，此选项通常很有用。
如果将副本附加到一个启用了`maxmemory`的实例上，则会从已用的内存计数中减去提供副本所需的输出缓冲区的大小，这样网络问题或重新同步就不会触发一个循环，在该循环中取出键，而反过来，输出缓冲区的复制副本中充满了被收回的键的del，从而导致删除更多的键，等等，直到数据库完全清空。
简而言之，如果您附加了副本，建议您为`maxmemory`设置一个较低的限制，以便系统上有一些用于副本输出缓冲区的可用RAM（但如果策略为`noevicetion`，则不需要这样做）。
```sh
# maxmemory <bytes>
```

## maxmemory-policy
当内存到达maxmemory的限制时，可以采用以下选项清理内存：
* volatile-lru，在具有过期集的密钥中使用近似的LRU逐出。
* allkeys-lru，使用近似的LRU逐出任何密钥。
* volatile-lfu，在具有过期集的键中使用近似的逐出。
* allkeys-lfu，使用近似的LFU逐出任何键。
* volatile-random，在有过期集的密钥中删除一个随机密钥。
* allkeys-random，随机删除任意键。
* volatile-ttl，删除最接近过期时间的密钥（次要TTL）。
* noeviction，不要逐出任何内容，只返回写操作错误。

LRU指`Least Recently Used`，LFU指`Least Frequently Used`。
当操作命令是`set` `setnx` `setex` `append` `incr` `decr` `rpush` `lpush` `rpushx` `lpushx` `linsert` `lset` `rpoplpush` `sadd` `sinter` `sinterstore` `sunion` `sunionstore` `sdiff` `sdiffstore` `zadd` `zincrby` `zunionstore` `zinterstore` `hset` `hsetnx` `hmset` `hincrby` `incrby` `decrby` `getset` `mset` `msetnx` `exec` `sort`时，如果没有合适的键删除时返回错误。
默认`noeviction`。
```sh
# maxmemory-policy noeviction
```

## maxmemory-samples
LRU，LFU和最小的TTL算法是不准确的算法，可以通过设置改选项提高精确度。
默认值为5会产生足够好的结果。10近似非常接近但成本更高的CPU，3更快但不是很准确。
```sh
# maxmemory-samples 5
```

## replica-ignore-maxmemory
副本会忽略`maxmemory`指令，当master剔除键会发送DEL进行同步。但是如果副本可写，或者希望与master内存设置不一样，并且确定写入是幂等的，可以设置此值。
```sh
# replica-ignore-maxmemory yes
```

# lazy freeing
Redis有两种方法删除键。一种是通过DEL阻塞的删除对象，删除时间与键关联的内存大小有关，如果是大key则可能会阻塞服务器很久。所以Redis提供异步删除。例如：`UNLINK`，`FLUSHALL`，`FLUSHDB`，会以恒定的时间，后台逐步释放。
这些命令是用户主动调用的，在某些情况下，Redis会主动的删除键：
* 到达内存限制的时候，会主动调用剔除策略进行删除键；
* 键到达了过期时间；
* 修改键值可能会删除原有内容，例如`RENAME`，`SET`等；
* 在复制过程中，当一个副本与其主服务器执行完全重新同步时，将删除整个数据库的内容，以便加载刚刚传输的RDB文件。

在上述所有情况下，默认情况是以阻塞方式删除对象，就像调用`DEL`一样。但是，您可以具体配置每种情况，以便以非阻塞方式释放内存，就像调用`UNLINK`时一样，使用以下配置指令：
```sh
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
```

# append only mode
## appendonly no
默认情况，Redis采用异步的方式转储磁盘，但有可能丢失数据，取决于保存点。
Redis提供追加模式，一种更好的持久性。例如使用fsync policy，Redis仅会丢失1秒的写入或Redis进程本身发生什么错误丢失写入数据，但是系统仍能正常运行。
`AOF`和`RDB`持久性可以同时启用而不会出现问题。如果在启动时启用`AOF`，Redis将加载`AOF`。
```sh
appendonly no
```

## appendfilename
指定追加文件
```sh
appendfilename "appendonly.aof"
```

## appendfsync
`fsync()`调用告诉操作系统在磁盘上实际写入数据，而不是在输出缓冲区中等待更多数据。有些操作系统将真正刷新磁盘上的数据，而另一些操作系统则会尽快进行刷新。
Redis支持三种模式：
* `no`，不调用`fsync()`，仅让操作系统管理刷新数据，快速；
* `always`，每次写入数据的时候添加文件，慢，安全；
* `everysec`，每秒添加一次，折中。

默认采用`everysec`。
```sh
# appendfsync always
appendfsync everysec
# appendfsync no
```

## no-appendfsync-on-rewrite
当`AOF`的同步策略设置为`always`或`everysec`时，后台保存数据，这会有大量`IO`操作，在某些平台下，调用`fsync()`会阻塞很长时间。
为了缓解这个问题，可以使用`BGSAVE`或`BGREWRITEAOF`止主进程调用`fsync()`阻塞。
这意味着当另一个子进程正在保存时，redis的耐久性与`appendfsync none`相同。实际上，这意味着在最坏的情况下（使用默认的Linux设置），可能会丢失长达30秒的日志。
如果遇到延迟问题，请将其转为`yes`。否则 ，从耐久性的角度来看，`no`，这是最安全的选择。
```sh
no-appendfsync-on-rewrite no
```

## auto-aof-rewrite-percentage
自动重写仅附加文件。 当`AOF`日志大小增长指定的百分比时， Redis能够自动重写日志文件，隐式调用`BGREWRITEAOF`。
工作方式：Redis会记录最后一次复写时`AOF`文件大小，如果复写发生在重启时，这个大小是`AOF`在启动的时使用。
将此基本大小与当前大小进行比较。如果当前大小大于指定的百分比，则会触发重写。另外需要为要重写的`AOF`文件指定最小大小，这对于避免重写`AOF`文件很有用，即使达到了增加的百分比，但仍然很小。
指定零的百分比以禁用自动AOF重写功能。
```sh
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```

## aof-load-truncated
在Redis启动过程中，当`AOF`数据被加载回内存时，可能会发现`AOF`文件在末尾被截断。当运行Redis的系统崩溃时可能会发生这种情况，尤其是当安装`ext4`文件系统时，如果没有`data=ordered`选项（但是，当Redis本身崩溃或中止，但操作系统仍然正常工作时，则不会发生这种情况）。
当发生这种情况时，Redis退出并报错，也可以加载尽可能多的数据（现在是默认值），如果在末尾发现`AOF`文件被截断，则可以启动它。以下选项控制此行为。
如果设置为`yes`，则会加载一个已截断的`AOF`文件，并且Redis服务器开始发出日志，通知用户事件。否则，如果该选项设置为`no`，则服务器将以错误中止并拒绝启动。
当选项设置为否时，用户需要在重新启动服务器之前使用`redis-check-aof`修复`aof`文件。如果在中间发现AOF文件已损坏，服务器仍将退出并出现错误。此选项仅适用于Redis尝试从AOF文件读取更多数据但未找到足够字节的情况。
```sh
aof-load-truncated yes
```

## aof-use-rdb-preamble
在重写`AOF`文件时，Redis可以使用AOF文件中的RDB前导码来更快地重写和恢复。启用此选项时，重写的`AOF`文件由两个不同的节`[RDB file][AOF tail]`组成。
Redis加载时，会识别出`AOF`文件以`REDIS`字符串开始并加载前缀`RDB`文件，然后继续加载`AOF`尾部。
```sh
aof-use-rdb-preamble yes
```

# LUA scripting
Lua脚本的最大执行时间（以毫秒为单位）。
如果达到最大执行时间，redis将记录脚本在最大允许时间之后仍在执行中，并开始对出现错误的查询进行回复。
当长时间运行的脚本超过最大执行时间时，只有`SCRIPT KILL`和`SHUTDOWN NOSAVE`命令可用。第一个可以用于停止尚未调用写入命令的脚本。第二种方法是在脚本已经发出写命令但用户不希望等待脚本自然终止的情况下关闭服务器。
将其设置为0或负值，以便无警告地无限执行。
```sh
lua-time-limit 5000
```

# Redis cluster
## cluster-enabled
普通的redis实例不能是redis集群的一部分；只有作为集群节点启动的节点才能。为了启动Redis实例作为群集节点，解注释并设置成`yes`即可。
```sh
# cluster-enabled yes
```

## cluster-config-file
每个集群节点都有一个集群配置文件，此文件不需要手动编辑。它创建和更新都有Redis节点进行。每个Redis集群节点都需要不同的集群配置文件。确保在同一系统中运行的实例没有重叠的群集配置文件名。
```sh
# cluster-config-file nodes-6379.conf
```

## cluster-node-timeout
集群节点超时，单位毫秒。
```sh
# cluster-node-timeout 15000
```

## cluster-replica-validity-factor
如果故障主机的数据看起来太旧，那么它的副本将避免启动故障转移。
对于副本来说没法验证数据的是否太旧，所以需要执行两项检查：
* 如果有多个副本能够进行故障转移，它们会交换消息，以尽量利用具有最佳复制偏移量的副本（从主处理的更多数据）。副本将尝试按偏移量获取它们的列组，并将与列组成比例的延迟应用于故障转移的开始。
* 每个副本都计算与主副本的最后一次交互的时间。这可以是接收到的最后一个ping或命令（如果主服务器仍然处于“已连接”状态），也可以是断开与主服务器的连接后经过的时间（如果复制链接当前已关闭）。如果上一次交互太旧，则复制副本将不会尝试进行故障转移。

第二点可以由用户进行调整，即，如果副本上次与主服务器交互时间超过时间大于：`(node-timeout * replica-validity-factor) + repl-ping-replica-period`。
因此，例如，如果节点超时为30秒，副本有效性系数为10，并且假设默认的复制副本周期为10秒，那么如果副本无法与主副本进行超过310秒的对话，则不会尝试进行故障转移。
较大的副本有效性系数可能允许具有太旧数据的副本故障转移到主服务器，而太小的值可能会阻止群集根本无法选择副本。
为了获得最大的可用性，可以将副本有效性系数设置为0，这意味着，无论副本上次与主服务器交互的时间如何，它们都将始终尝试对主服务器进行故障转移。（然而，他们总是尝试应用与他们的偏移等级成比例的延迟）。
零是唯一能够保证当所有分区恢复时群集始终能够继续运行的值。
```sh
# cluster-replica-validity-factor 10
```

## cluster-migration-barrier
群集副本能够迁移到孤立的主服务器，即没有工作副本的主服务器。这提高了集群抵御故障的能力，否则，如果一个孤立的主机没有工作的副本，它就不能在发生故障的情况下进行故障转移。
只有在至少有一个给定数量的旧主控形状的其他工作副本的情况下，副本才会迁移到孤立的主控形状。这个数字是“移民壁垒”。迁移屏障为1意味着只有在主副本至少有一个其他工作副本的情况下，副本才会迁移，以此类推。它通常反映出集群中每个主服务器所需的副本数量。
默认值为1（仅当主副本至少保留一个副本时才迁移副本）。要禁用迁移，只需将其设置为非常大的值。#可以设置值0，但仅对调试和生产中的危险有用。
```sh
# cluster-migration-barrier 1
```

## cluster-require-full-coverage
默认情况下，如果Redis群集节点检测到至少有一个散列槽未被发现（没有可用节点提供服务），则它们将停止接受查询。这样，如果集群部分关闭（例如一系列散列槽不再被覆盖），所有集群最终都将不可用。一旦所有插槽再次被覆盖，它就会自动返回可用状态。
然而，有时您希望集群的子集工作，继续接受对仍然被覆盖的密钥空间部分的查询。为此，只需将`cluster-require-full-coverage`选项设置为no。
```sh
# cluster-require-full-coverage yes
```

## cluster-replica-no-failover
当设置为“是”时，此选项可防止副本在主服务器故障时尝试故障转移其主服务器。但是，如果强制的话，主服务器仍然可以执行手动故障转移。
这在不同的情况下很有用，特别是在多个数据中心操作的情况下，如果不升级，我们希望一方永远不会升级；如果发生完全的DC故障。
```sh
# cluster-replica-no-failover no
```

# CLUSTER DOCKER/NAT support
在某些部署中，Redis群集节点地址发现失败，原因是地址是NAT，或者端口是转发的（典型情况是Docker和其他容器）。
为了使redis集群在这样的环境中工作，需要一个静态配置，其中每个节点都知道其公共地址。以下两个选项用于此范围，分别是：
* cluster-announce-ip
* cluster-announce-port
* cluster-announce-bus-port

每个节点都指示其地址、客户机端口和集群消息总线端口。然后将信息发布到总线数据包的头部，以便其他节点能够正确映射发布信息的节点的地址。
如果不使用上述选项，则将使用普通的Redis群集自动检测。
请注意，重新映射时，总线端口可能不在客户机端口+10000的固定偏移量处，因此您可以根据重新映射的方式指定任何端口和总线端口。如果未设置总线端口，则通常使用固定偏移量10000。
例如：
```sh
# cluster-announce-ip 10.1.1.5
# cluster-announce-port 6379
# cluster-announce-bus-port 6380
```

# slow log
Redis slow log是一个系统日志查询，它超过了指定的执行时间。执行时间不包括I/O操作，如与客户机交谈、发送回复等，而只包括实际执行命令所需的时间（这是命令执行的唯一阶段，线程被阻塞，无法以平均值服务其他请求时间）。
您可以用两个参数配置慢日志：一个参数告诉redis命令要记录的执行时间（以微秒计），另一个参数是慢日志的长度。当记录新命令时，最旧的命令将从记录的命令队列中删除。
## slowlog-slower-than
以下时间以微秒表示，因此1000000等于一秒。注意，负数会禁用慢速日志，而零值会强制记录每个命令。
```sh
slowlog-log-slower-than 10000
```

## slowlog-max-len
这个长度没有限制。只是要知道它会消耗内存。可以使用`SLOWLOG RESET`来回收慢速日志使用的内存。
```sh
slowlog-max-len 128
```

# latency monitor
Redis延迟监控子系统在运行时对不同的操作进行采样，以便收集与Redis实例的可能延迟源相关的数据。
通过`LATENCY`命令，用户可以使用这些信息来打印图形和获取报告。
系统只记录在时间等于或大于通过延迟监视器阈值配置指令指定的毫秒数内执行的操作。当其值设置为零时，延迟监视器将关闭。
默认情况下，延迟监控是禁用的，因为如果您没有延迟问题，则通常不需要它，并且收集数据会对性能产生影响，尽管这一影响很小，但可以在大负载下进行测量。如果需要，可以使用命令`CONFIG SET latency-monitor-threshold <milliseconds>`在运行时轻松启用延迟监控。
```sh
latency-monitor-threshold 0
```

# event notification
例如，如果启用了keyspace事件通知，并且客户机对存储在数据库0中的密钥`foo`执行`DEL`操作，则将通过pub/sub发布两条消息：
```sh
PUBLISH __keyspace@0__:foo del
PUBLISH __keyevent@0__:del foo
```

可以在一组类中选择Redis将通知的事件。每个类都由单个字符标识：
```sh
#  K     Keyspace events, published with __keyspace@<db>__ prefix.
#  E     Keyevent events, published with __keyevent@<db>__ prefix.
#  g     Generic commands (non-type specific) like DEL, EXPIRE, RENAME, ...
#  $     String commands
#  l     List commands
#  s     Set commands
#  h     Hash commands
#  z     Sorted set commands
#  x     Expired events (events generated every time a key expires)
#  e     Evicted events (events generated when a key is evicted for maxmemory)
#  A     Alias for g$lshzxe, so that the "AKE" string means all the events.
```

`notify-keyspace-events`将一个由零个或多个字符组成的字符串作为参数。空字符串表示通知被禁用。

默认情况下，所有通知都被禁用，因为大多数用户不需要此功能，而且此功能有一些开销。请注意，如果不指定`K`或`E`中的至少一个，则不会传递任何事件。
```sh
notify-keyspace-events ""
```

# advanced config
 