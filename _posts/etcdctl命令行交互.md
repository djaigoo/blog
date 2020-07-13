---
author: djaigo
title: etcdctl命令行交互
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/etcd.png'
categories:
  - etcd
tags:
  - etcd
  - etcdctl
  - cmd
date: 2020-03-24 09:39:09
updated: 2020-03-24 09:39:09
---

# 简介
etcd 是一个分布式一致性键值存储，用于共享配置和服务发现，专注于：
*   简单：良好定义的，面向用户的API (gRPC)
*   安全：带有可选客户端证书认证的自动 TLS
*   快速：测试验证，每秒 10000 写入
*   可靠：使用Raft适当分布

etcd是Go编写，并使用 Raft 一致性算法来管理高可用复制日志。

用户通常通过设置或者获取 key 的值来和 etcd 交互。本文描述如何使用 etcdctl 来操作， etcdctl 是一个和 etcd 服务器交互的命令行工具。这里描述的概念也适用于 gRPC API 或者客户端类库 API。

默认，为了向后兼容 etcdctl 使用 v2 API 来和 etcd 服务器通讯。为了让 etcdctl 使用 v3 API 来和etcd通讯，API 版本必须通过环境变量 `ETCDCTL_API` 设置为版本3。

```bash
export ETCDCTL_API=3
```

# 写入key

应用通过写入 key 来储存 key 到 etcd 中。每个存储的 key 被通过 Raft 协议复制到所有 etcd 集群成员来达到一致性和可靠性。

这是设置 key `foo` 的值为 `bar` 的命令:

```
$ etcdctl put foo bar
OK

```

etcdctl默认操作的etcd是`--endpoints=[127.0.0.1:2379]		gRPC endpoints`，下同。

# 读取 key

应用可以从 etcd 集群中读取 key 的值。查询可以读取单个 key，或者某个范围的 key。

假设 etcd 集群存储有下面的 key：

```
foo = bar
foo1 = bar1
foo2 = bar2
foo4 = bar4
foo5 = bar5
```

这是读取 key `foo` 的值的命令：

```
$ etcdctl get foo
foo
bar

```

这是覆盖从 `foo` to `foo5` 的 key 的命令：

```
$ etcdctl get foo foo5
foo
bar
foo1
bar1
foo2
bar2
foo4
bar4

```

> 注： 这里是按照左闭右开的区间进行获取。

## 读取 key 过往版本的值

应用可能想读取 key 的被替代的值。例如，应用可能想通过访问 key 的过往版本来回滚到旧的配置。或者，应用可能想通过访问 key 历史记录的多个请求来得到一个覆盖多个 key 上的统一视图。

因为 etcd 集群上键值存储的每个修改都会增加 etcd 集群的全局修订版本（所有的key共有一个版本），应用可以通过提供旧有的 etcd 版本来读取被替代的 key。

假设 etcd 集群已经有下列 key：

```
$ etcdctl put foo bar         # revision = 2
$ etcdctl put foo1 bar1       # revision = 3
$ etcdctl put foo bar_new     # revision = 4
$ etcdctl put foo1 bar1_new   # revision = 5

```

这里是访问 key 的过往版本的例子：

```
$ etcdctl get foo foo9 # 访问 key 的最新版本
foo
bar_new
foo1
bar1_new

$ etcdctl get --rev=4 foo foo9 # 访问 key 的修订版本4
foo
bar_new
foo1
bar1

$ etcdctl get --rev=3 foo foo9 # 访问 key 的修订版本3
foo
bar
foo1
bar1

$ etcdctl get --rev=2 foo foo9 # 访问 key 的修订版本2
foo
bar

$ etcdctl get --rev=1 foo foo9 # 访问 key 的修订版本1

```

# 删除 key

应用可以从 etcd 集群中删除一个 key 或者特定范围的 key。

下面是删除 key `foo` 的命令：

```
$ etcdctl del foo
1 # 删除了一个key

```

这是删除从 `foo` to `foo9` 范围的 key 的命令：

```
$ etcdctl del foo foo9
5 # 删除了5个key

```

# 前缀匹配
## 获取指定前缀所有key
通过设置`--prefix`调用对象是拥有指定前缀的key，设置`--keys-only`只显示key的名字，设置`--from-key`获取所有的键值。
```bash
$ etcdctl --prefix --keys-only=true get foo
foo

foo1

foo2

foo4

foo5

```

如果把前缀变成空字符就是获取当前etcd中所有的key。
```bash
$ etcdctl --prefix --keys-only=true get ""
foo

foo1

foo2

foo4

foo5
```

`--from-key`和`--prefix`不能同时使用。
```bash
$ etcdctl get "" --from-key --prefix
Error: `--prefix` and `--from-key` cannot be set at the same time, choose one
```

且`--from-key`必须写在get之后，不然会报错找不到flag。
```
$ etcdctl --from-key get ""
Error: unknown flag: --from-key
```


# 观察 key 的变化

应用可以观察一个 key 或者特定范围内的 key 来监控任何更新。

这是在 key `foo` 上进行观察的命令：

```
$ etcdctl watch foo
foo
bar
```

```sh
$ etcdctl put foo bar
OK
```
这是观察从 `foo` to `foo9` 范围key的命令：
```bash
$ etcdctl watch foo foo9
# 在另外一个终端: etcdctl put foo bar
foo
bar
# 在另外一个终端: etcdctl put foo1 bar1
foo1
bar1

```

## 观察 key 的历史改动

应用可能想观察 etcd 中 key 的历史改动。例如，应用想接收到某个 key 的所有修改。如果应用一直连接到etcd，那么 `watch` 就足够好了。但是，如果应用或者 etcd 出错，改动可能发生在出错期间，这样应用就没能实时接收到这个更新。为了保证更新被接收，应用必须能够观察到 key 的历史变动。为了做到这点，应用可以在观察时指定一个历史修订版本，就像读取 key 的过往版本一样。

假设我们完成了下列操作序列：

```
etcdctl put foo bar         # revision = 2
etcdctl put foo1 bar1       # revision = 3
etcdctl put foo bar_new     # revision = 4
etcdctl put foo1 bar1_new   # revision = 5

```

这是观察历史改动的例子：

```
# 从修订版本 2 开始观察key `foo` 的改动
$ etcdctl watch --rev=2 foo
PUT
foo
bar
PUT
foo
bar_new

# 从修订版本 3 开始观察key `foo` 的改动
$ etcdctl watch --rev=3 foo
PUT
foo
bar_new

```

# 压缩修订版本

如我们提到的，etcd 保存修订版本以便应用可以读取 key 的过往版本。但是，为了避免积累无限数量的历史数据，压缩过往的修订版本就变得很重要。压缩之后，etcd 删除历史修订版本，释放资源来提供未来使用。所有修订版本在压缩修订版本之前的被替代的数据将不可访问。

这是压缩修订版本的命令：

```
$ etcdctl compact 5
compacted revision 5

# 在压缩修订版本之前的任何修订版本都不可访问
$ etcdctl get --rev=4 foo
{"level":"warn","ts":"2020-03-24T10:25:00.189+0800","caller":"clientv3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"endpoint://client-d0dbfe68-878e-4b3f-8bc9-8c1c8fad1a10/127.0.0.1:2379","attempt":0,"error":"rpc error: code = OutOfRange desc = etcdserver: mvcc: required revision has been compacted"}

```

# 租约
## 授予租约

应用可以为 etcd 集群里面的 key 授予租约。当 key 被附加到租约时，它的生存时间被绑定到租约的生存时间，而租约的生存时间相应的被 `time-to-live` (TTL)管理。租约的实际 TTL 值是不低于最小 TTL，由 etcd 集群选择。一旦租约的 TTL 到期，租约就过期并且所有附带的 key 都将被删除。

这是授予租约的命令：

```
# 授予租约，TTL为100秒
$ etcdctl lease grant 100
lease 00d4710a3e7c7539 granted with TTL(100s)

# 附加key foo到租约32695410dcc0ca06
$ etcdctl put --lease=00d4710a3e7c7539 foo bar
OK

```

## 撤销租约

应用通过租约 id 可以撤销租约。撤销租约将删除所有它附带的 key。

假设我们完成了下列的操作：

```
$ etcdctl lease grant 10
lease 32695410dcc0ca06 granted with TTL(10s)
$ etcdctl put --lease=32695410dcc0ca06 foo bar
OK

```

这是撤销同一个租约的命令：

```
$ etcdctl lease revoke 32695410dcc0ca06
lease 32695410dcc0ca06 revoked

$ etcdctl get foo
# 空应答，因为租约撤销导致foo被删除

```

## 维持租约

应用可以通过刷新 key 的 TTL 来维持租约，以便租约不过期。

假设我们完成了下列操作：

```
$ etcdctl lease grant 10
lease 32695410dcc0ca06 granted with TTL(10s)

```

这是维持同一个租约的命令：

```
$ etcdctl lease keep-alive 32695410dcc0ca0
lease 32695410dcc0ca0 keepalived with TTL(100)
lease 32695410dcc0ca0 keepalived with TTL(100)
lease 32695410dcc0ca0 keepalived with TTL(100)
...

```

> 注： 上面的这个命令中，etcdctl 不是单次续约，而是 etcdctl 会一直不断的发送请求来维持这个租约。

 [](https://skyao.gitbooks.io/learning-etcd3/content/documentation/dev-guide/local_cluster.html)


# 参考文献
1. [etcd3介绍](https://skyao.gitbooks.io/learning-etcd3/content/introduction/)
2. [和etcd交互](https://skyao.gitbooks.io/learning-etcd3/content/documentation/dev-guide/interacting_v3.html)
