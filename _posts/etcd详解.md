---
title: etcd详解
tags:
  - base
categories:
  - etcd
draft: true
date: 2018-09-03 17:24:35
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/etcd.png
---
# etcd 
## etcd 简介
etcd是一个分布式可靠的键值存储，用于分布式系统的最关键数据，是一个高可用强一致性的服务发现存储数据库，可以让服务快速透明的接入计算集群中，让共享配置信息快速被集群中的而所有机器发现，构建一套高可用、安全、易于部署以及响应快速的服务集群。
<!--more-->
## etcd 特点
etcd **A highly-available key value store for shared configuration and service discovery.**，是一个键值存储仓库，用于配置共享和服务发现。专注于一下特点：
* 简单：定义明确，面向用户的API（gRPC）
* 安全：具有可选客户端证书身份验证的自动TLS
* 快速：基准测试10,000次/秒
* 可靠：使用Raft正确分布

## 启动etcd
可以通过[GitHub][https://github.com/etcd-io/etcd/releases]下载最新版的releases，下载后可以直接启动etcd服务，通过etcdctl进行控制etcd服务。
```shell
# service etcd restart
Redirecting to /bin/systemctl restart etcd.service
```
## etcd命令
### 访问etcd
使用etcdctl可以访问etcd，通过put和get可以设置和获取键值
```shell
export ETCDCTL_API=3
HOST=127.0.0.1
ENDPOINTS=$HOST:2379,$HOST:2380

etcdctl --endpoints=$ENDPOINTS put foo "hello world"
etcdctl --endpoints=$ENDPOINTS get foo
etcdctl --endpoints=$ENDPOINTS --write-out="json" get foo
```
返回结果：
```shell
OK
foo
hello world
{"header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"revision":6,"raft_term":3},"kvs":[{"key":"Zm9v","create_revision":2,"mod_revision":6,"version":5,"value":"aGVsbG8gd29ybGQ="}],"count":1}
```

### 相关命令
* put 存入键值对
* get 获取键的值
* del 删除键值对
* txn 事务
* watch 监视
* lease 设置TTL
* lock 分布式锁
* elect 选举领导
* endpoint 集群设置
  * status 集群状态
  * health 健康检查
* snapshot 快照
  * save 保存快照
  * status 显示快照状态
* migrate 迁移，将etcd v2的数据迁移到v3上
* member 添加，删除，更新成员资格
* auth，user，role 都是用来认证的

### 相关参数
* --endpoints 指定etcd服务器集群
* --write-out 指定输出格式
  * table 表格格式
  * json json格式
* --prefix 获取指定前缀的

# etcd3 API
所有etcd3 API都在gRPC服务里面定义，他们对etcd 远程调用进行了分类。

## gRPC Services
发送到etcd的每个API请求都是gRPC的远程调用，etcd3按照服务的功能进行分类。
处理etcd键空间的服务包括：
* KV，创建，更新，提取，删除键值对
* Watch，监视修改的键
* Lease，允许消费客户端keep-alive消息

管理集群本身的服务：
* Auth，基于角色的身份验证机制，用于验证用户身份
* Cluster，提供成员信息和配置工具
* Maintenance，恢复快照，对存储进行碎片整理，并返回每个成员的状态信息

### Requests and Responses
etcd3中的所有RPC都遵循相同的格式，每个RPC都有一个函数Name，NameRequest作为参数，NameResponse作为响应。例如，Range RPC描述：
```golang
service KV {
  Range(RangeRequest) returns (RangeResponse)
  ...
}
```

### Response header
来自etcd API的所有响应都有一个附加的响应头，其中包含响应的集群元数据，例：
```golang
message ResponseHeader {
  uint64 cluster_id = 1;
  uint64 member_id = 2;
  int64 revision = 3;
  uint64 raft_term = 4;
}
```

*   Cluster_ID，生成响应的集群的ID。
*   Member_ID，生成响应的成员的ID。
*   Revision，生成响应时键值存储的修订版。
*   Raft_Term，生成响应时成员的Raft术语。

应用程序可以读取`Cluster_ID(Member_Id)`以确保它与预期的集群（成员）进行通信。
应用程序可以使用Revision来了解键值存储的最新版本，当应用程序指定历史修订版以产生时间`travel query`并希望在请求时知道最新修订版时，尤其有用。
应用程序可用Raft_Term检测集群何时完成新的领导者选举。

## Key-Value API
Key-Value API操作存储在etcd中的键值对
### System primitives
#### Key-Value pair
键值对是Key-Value API可操作的最小单位，每个键值对都有许多以protobuf格式定义的字段：
```golang
message KeyValue {
  bytes key = 1;
  int64 create_revision = 2;
  int64 mod_revision = 3;
  int64 version = 4;
  bytes value = 5;
  int64 lease = 6;
}
```

* Key，以字节为单位，不允许空key
* Value，以字节为单位
* Version，key的版本，删除将会重置为0，对key的任何修改都会增加其版本
* Create_Revision，最后一次创建key的版本
* Mod_Revision，最后修改key的版本
* Lease，附加到key的租约

除了key和value之外，etcd还附加了其他的修订元数据作为key消息的一个部分，次修订信息按创建时间和修改时间排序排序秘钥，这对于管理分布式同步的并发性非常有用。etcd客户端的分布式共享锁在等待锁的拥有权时会创建修订版本号。类似，修改修订版用于检测软件事务存储器读取冲突，并等待领导者选举更新。

#### Revisions
etcd维护一个64位集群范围的计数器，即存储修订版本。每次修改key space都会递增，该修订版用作全局逻辑时钟，按顺序进行更新存储。在内部，新修订的键入意味着将更改写入后端的B+树。
在etcd3的多版本并发控制时，revision变得更有价值。MVCC模型可以从过去的修订中查看键值存储，因为保留了历史key的revision。管理员可以配置历史记录的保留策略，以实现细粒度的存储管理，通常etcd3会丢弃计时器上原key的revision。这也为长客户端断开连接提供了可靠地处理，而不仅仅是暂时的网络中断，watchers可以从上次监视到的历史修订中恢复。类似的，为了在特定时间点从存储中读取，可以使用修订标记读取请求，以在提交修订的时间点从key space的视图返回key。
#### Key Ranges
etcd3数据模型通过二进制key space索引所有的秘钥，这不同于其他使用分层系统将key存于目录的键值存储系统。不是按照目录列出key，而是通过key intervals[a, b)。
这些间隔通常在etcd3里面称做“range 范围”，范围上的操作比目录上的操作更强大。与分层存储一样，范围支持单键查找[a, a+1)（例如：[‘a’, ‘a\x00’)查找‘a’）和目录查找，方法是按照目录深度编码键。range还支持编码前缀，例如，range[‘a’, ‘b’)查找以字符串‘a’为前缀的所有键。
通常，请求的范围用`key`和`range_end`字段表示，key是该范围的第一个键，必须是非空，`range_end`是范围的最后一个键，如果`range_end`未定义或为空，则将范围定义为仅包含键参数。如果`range_end`是`key`加1（例如，“aa” + 1 == “ab”, “a\xff” + 1 == b），则该范围表示所以以`key`为前缀的key，如果`key`和`range_end`都是`\0`，那么范围代表所有的键，如果`range_end`是`'\0'`，则范围是大于或等于key的所有key argument。
### Range
使用Range API调用从键值存储中获取键，其中包含RangeRequest：
```golang
message RangeRequest {
  enum SortOrder {
	NONE = 0; // default, no sorting
	ASCEND = 1; // lowest target value first
	DESCEND = 2; // highest target value first
  }
  enum SortTarget {
	KEY = 0;
	VERSION = 1;
	CREATE = 2;
	MOD = 3;
	VALUE = 4;
  }

  bytes key = 1;
  bytes range_end = 2;
  int64 limit = 3;
  int64 revision = 4;
  SortOrder sort_order = 5;
  SortTarget sort_target = 6;
  bool serializable = 7;
  bool keys_only = 8;
  bool count_only = 9;
  int64 min_mod_revision = 10;
  int64 max_mod_revision = 11;
  int64 min_create_revision = 12;
  int64 max_create_revision = 13;
}
```
* Key, Range_End，要获取key的范围
* Limit，为请求返回的最大key数，当Limit设置为0，表示没有限制
* Revision，用于范围的键值存储的时间节点。如果revision小于或等于零，则范围超过最新的键值存储。如果压缩修订版，则返回ErrCompacted作为响应。
* Sort_Order，排序请求
* Sort_Target，要排序的键值字段
* Serializable，设置范围请求以使用可序列化的成员本地读取。默认情况下，Range是可线性化的; 它反映了该集群目前的共识。为了获得更好的性能和可用性，为了换取可能的过时读取，可在本地提供可序列化范围请求，而无需与群集中的其他节点达成共识
* Keys_Only，仅返回键而不返回值
* Count_Only，仅返回返回中键的计数
* `Min_Mod_Revision`，key修改版本的下限，过滤掉比较小的修订版
* `Max_Mod_Revision`，key修改版本的上限，过滤掉较大的修订版本
* `Min_Create_Revision`，key创建版本的下界，过滤掉小的创建版本
* `Max_Create_Revision`，key创建版本的上界，过滤掉大的创建版本

客户端收到RangeResponse来自Range呼叫的消息：
```golang
message RangeResponse {
  ResponseHeader header = 1;
  repeated mvccpb.KeyValue kvs = 2;
  bool more = 3;
  int64 count = 4;
}
```
* KVs，范围请求匹配的键值对列表，当Count_Only设置，KVs为空
* More，表示如果Limit设置了，在请求范围内是否有更多的键要返回
* Count，满足范围请求的key总数

### Put
使用Range API调用从键值存储中获取键，其中包含RangeRequest：
```golang
message PutRequest {
  bytes key = 1;
  bytes value = 2;
  int64 lease = 3;
  bool prev_kv = 4;
  bool ignore_value = 5;
  bool ignore_lease = 6;
}
```
* Key，放入键值存储key的名称
* Value，在键值存储中key的值，以字节为单位
* Lease，与键值存储中键关联的租约ID，租约值为0表示没有租约
* Prev_Kv，设置后，在Put请求更新之前返回原来的键值对
* Ignore_Value，设置后，更新key而不更改当前value，如果key不存在返回error
* Ignore_Lease，设置后，更新key而不更改当前租约，如果key不存在返回error

客户端收到来自Put呼叫PutResponse消息：
```golang
message PutResponse {
  ResponseHeader header = 1;
  mvccpb.KeyValue prev_kv = 2;
}
```
* Prev_Kv，如果被设置，键值对将被复写

### Delete Range
使用DeleteRange，删除key的range，其中DeleteRangeRequest：
```golang
message DeleteRangeRequest {
  bytes key = 1;
  bytes range_end = 2;
  bool prev_kv = 3;
}
```
* Key,Range_End，要删除key的范围
* Prev_Kv，设置后返回已删除键值对内容

客户端收到DeleteRange的回复消息DeleteRangeResponse消息：
```golang
message DeleteRangeResponse {
  ResponseHeader header = 1;
  int64 deleted = 2;
  repeated mvccpb.KeyValue prev_kvs = 3;
}
```
* Deleted，已删除的key数
* Prev_Kv，DeleteRange操作删除的所有键值对列表

### Transaction
事务是原子If/Then/Else构造，形成一个原语，用于将请求分组在原子块中（then/else），这些原子块的执行基于键值存储的内容被保护（if）。事务可用于保护key免受意外的并发更新，构建比较和交换操作以及开发更高级别的并发控制。
事务可以在单个请求中以原子的方式处理多个请求。对于键值存储的修改，这意味着存储的修订仅针对事务递增一次，并且事务生成的所有事件将具有相同的修订。但是，禁止在单个事务中多次修改同一个key。
所有的事务都将通过连词来保护，类似于“If”语句，每次比较都会检查存储中的单个key。它可以检查值的缺失或存在，与给定值进行比较，或检查秘钥的修订版本或版本。两种不同的比较适用于相同或者不同的key。所有的比较都是原子的，如果所有比较都为真，则说事务成功并且etcd应用事务的then/success request块，否则为失败，并且应用else/failure request块。

每次比较都会编码成一个Compare消息：
```golang
message Compare {
  enum CompareResult {
    EQUAL = 0;
    GREATER = 1;
    LESS = 2;
    NOT_EQUAL = 3;
  }
  enum CompareTarget {
    VERSION = 0;
    CREATE = 1;
    MOD = 2;
    VALUE= 3;
  }
  CompareResult result = 1;
  // target is the key-value field to inspect for the comparison.
  CompareTarget target = 2;
  // key is the subject key for the comparison operation.
  bytes key = 3;
  oneof target_union {
    int64 version = 4;
    int64 create_revision = 5;
    int64 mod_revision = 6;
    bytes value = 7;
  }
}
```
* Result，逻辑比较操作的类型（例如：等于，小于……）
* Target，要比较的键值字段，key的version，创建revision，修改revision，或者值
* Key，要比较的key
* Target_Union，用于比较用户指定数据

在处理完比较块后，事务应用一个请求块，是一个RequestOp消息列表：
```golang
message RequestOp {
  // request is a union of request types accepted by a transaction.
  oneof request {
    RangeRequest request_range = 1;
    PutRequest request_put = 2;
    DeleteRangeRequest request_delete_range = 3;
  }
}
```
* `Request_Range`，一个RangeRequest
* `Request_Put`，一个PutRequest，key必须是唯一的，他不可能与其他Puts或Deletes共享key
* `Request_Delete_Range`，一个DeleteRangeRequest，他可能不会与任何Puts或Deletes请求共享key
终止，一个事务是通过Txn API发出的，他需要TxnRequest：
```golang
message TxnRequest {
  repeated Compare compare = 1;
  repeated RequestOp success = 2;
  repeated RequestOp failure = 3;
}
```
* Compare，表示保护事务的术语组合的连词列表
* Success，如果所有测试评估为true，则处理请求列表
* Failure，如果任何比较测试评估为false，则处理请求列表

客户端收到来自Txn的TxnResponse消息：
```golang
message TxnResponse {
  ResponseHeader header = 1;
  bool succeeded = 2;
  repeated ResponseOp responses = 3;
}
```
* Success，无论是Compare评估为真还是假
* Response，如果Success为True，则应用Success块的结果对应的响应列表，如果Success为False，则医用Failure块的结果

该Responses列表对应于应用RequestOp列表的结果，每个响应编码为ResponseOp：
```golang
message ResponseOp {
  oneof response {
    RangeResponse response_range = 1;
    PutResponse response_put = 2;
    DeleteRangeResponse response_delete_range = 3;
  }
}
```


## Watch API
Watch API 提供基于事件的接口，用于异步监视key的更改，etcd3 watch通过持续观察当前或历史的给定修改，等待key的更改，并将关键更新流回客户端。

### Events
每个key的更改都用Event消息表示，一个Event消息通知提供更新的数据和更新的类型：
```golang
message Event {
  enum EventType {
    PUT = 0;
    DELETE = 1;
  }
  EventType type = 1;
  KeyValue kv = 2;
  KeyValue prev_kv = 3;
}
```
* Type，事件的类型。PUT类型表示新数据已存储到key中，DELETE表示key已删除
* KV，与事件关联的KeyValue。PUT事件包含当前的kv对，kv.Version = 1的PUT事件表示创建key，DELETE事件包含已删除的秘钥，其修改修订版设置为删除修订版 
* Prev_KV，在事件之前修订的键值对，为了节省带宽，只有在watch明确启动时才会填写

### Watch streams
watches是一个长时间运行请求，使用gRPC流来传输事件数据。watch stream是双向的：客户端写入流以建立监视；读取流以接收监视事件。单个监听流可以通过使用监听标识符标记事件来复用许多不同的监视，这种多路复用有助于减少核心etcd集群的内存占用和连接开销。

watches对事件有三点保证：
* Ordered，事件按修订排序，如果事件发生在已经发布的事件之前，则该事件将用于不会出现在watch
* Reliable，一系列事件永远不会丢失任何事件的后续序列，如果有事件按时间顺序排列为`a<b<c`，watch收到了事件a和c，则保证接收事件b
* Atomic，事件清单保证包含完整的修订，多个键上相同修订版的更新不会分成几个事件列表

客户端通过发送WatchCreateRequest返回的流来创建watch：
```golang
message WatchCreateRequest {
  bytes key = 1;
  bytes range_end = 2;
  int64 start_revision = 3;
  bool progress_notify = 4;

  enum FilterType {
    NOPUT = 0;
    NODELETE = 1;
  }
  repeated FilterType filters = 5;
  bool prev_kv = 6;
}
```
* Key,Range_End，要监视的key范围
* Start_Revision，包含开始监视的可选修订，如果没有给出，它将会以watch创建响应的修订版建立事件
* Progress_Notify，设置后，如果最近没有事件，watch会定期收到没有事件WatchResponse。它被用于当客户端希望从最近的已知修订版本开始恢复断开连接的watcher。etcd服务器根据当前服务器负载决定发送通知的频率。
* Filters，要在服务器端过滤掉的事件类型列表
* Prev_Kv，设置后，watch会收到键值对事件发生前的值，这对于了解被覆盖的数据非常有用

客户端会收到WatchResponse，来了解WatchCreateRequest某个已建立的watch或是否有新事件：
```golang
message WatchResponse {
  ResponseHeader header = 1;
  int64 watch_id = 2;
  bool created = 3;
  bool canceled = 4;
  int64 compact_revision = 5;

  repeated mvccpb.Event events = 11;
}
```
* Watch_ID，与响应对应的监视ID
* Created，设置为true，表示响应是针对创建监视请求，客户端应记录ID并期望在流上接收监听事件，发送给创建的监视者的所有事件都将具有相同的watch_id
* Canceled，设置为true，表示响应时取消监视请求，不会向已取消的监视者发送更多的事件
* `Compact_Revision`，如果监视者尝试观看压缩版本，则设置为etcd可用的最小历史版本。在压缩版本中创建监视程序或监视者无法跟上键值存储的进度时会发生这种情况，监视者将被取消，使用相同的start_revision创建监视将失败
* Events，指定watch ID对应的顺序事件列表

如果客户端希望停止接收监听事件，则会发出WatchCancelRequest：
```golang
message WatchCancelRequest {
   int64 watch_id = 1;
}
```
* Watch_ID，要取消的监视ID，以便不在传输任何事件

## Lease API
租约是检测客户活跃度的机制。集群授予租约生存时间，如果etcd集群在给定的TTL周期内没有收到Keep-Alive，则租约到期。
为了将租约绑定到键值存储中，每个键可以附加到最多一个租约，当租约到期或被撤销时，附加到该租约的所有key都将被删除，每个过期的key在事件历史记录中生成删除事件。

### Obtaining leases
通过调用LeaseGrant API获取租约，他需要LeaseGrantRequest：
```golang
message LeaseGrantRequest {
  int64 TTL = 1;
  int64 ID = 2;
}
```
* TTL，咨询租约时间，单位为秒
* ID，请求租约的ID，如果ID设置为0，则etcd将选择一个ID

客户端收到LeaseGrant响应LeaseGrantResponse：
```golang
message LeaseGrantResponse {
  ResponseHeader header = 1;
  int64 ID = 2;
  int64 TTL = 3;
}
```
* ID，授予租约的租约ID
* TTL，服务器为租约选择的生存时间（以秒为单位）

```golang
message LeaseRevokeRequest {
  int64 ID = 1;
}
```
* ID，要撤销的租约ID，撤消租约后，将删除所有附加的秘钥

### Keep alives
使用LeaseKeepAlive API调用创建的双向流刷新租约，当客户希望刷新租约时，他会通过LeaseKeepAliveRequest流发送：
```golang
message LeaseKeepAliveRequest {
  int64 ID = 1;
}
```
* ID，要保持活动租约的租约ID

保持活动流响应LeaseKeepAliveResponse
```golang
message LeaseKeepAliveResponse {
  ResponseHeader header = 1;
  int64 ID = 2;
  int64 TTL = 3;
}
```
* ID，使用新TTL刷新租约
* TTL，租约剩余的新生村时间，以秒为单位


## etcd 数据模型
etcd is designed to reliably store infrequently updated data and provide reliable watch queries. etcd exposes previous versions of key-value pairs to support inexpensive snapshots and watch history events (“time travel queries”). A persistent, multi-version, concurrency-control data model is a good fit for these use cases.

etcd stores data in a multiversion persistent key-value store. The persistent key-value store preserves the previous version of a key-value pair when its value is superseded with new data. The key-value store is effectively immutable; its operations do not update the structure in-place, but instead always generates a new updated structure. All past versions of keys are still accessible and watchable after modification. To prevent the data store from growing indefinitely over time from maintaining old versions, the store may be compacted to shed the oldest versions of superseded data.

### Logical view
The store’s logical view is a flat binary key space. The key space has a lexically sorted index on byte string keys so range queries are inexpensive.

The key space maintains multiple revisions. Each atomic mutative operation (e.g., a transaction operation may contain multiple operations) creates a new revision on the key space. All data held by previous revisions remains unchanged. Old versions of key can still be accessed through previous revisions. Likewise, revisions are indexed as well; ranging over revisions with watchers is efficient. If the store is compacted to recover space, revisions before the compact revision will be removed.

A key’s lifetime spans a generation. Each key may have one or multiple generations. Creating a key increments the generation of that key, starting at 1 if the key never existed. Deleting a key generates a key tombstone, concluding the key’s current generation. Each modification of a key creates a new version of the key. Once a compaction happens, any generation ended before the given revision will be removed and values set before the compaction revision except the latest one will be removed.

### Physical view
etcd stores the physical data as key-value pairs in a persistent b+tree. Each revision of the store’s state only contains the delta from its previous revision to be efficient. A single revision may correspond to multiple keys in the tree.

The key of key-value pair is a 3-tuple (major, sub, type). Major is the store revision holding the key. Sub differentiates among keys within the same revision. Type is an optional suffix for special value (e.g., t if the value contains a tombstone). The value of the key-value pair contains the modification from previous revision, thus one delta from previous revision. The b+tree is ordered by key in lexical byte-order. Ranged lookups over revision deltas are fast; this enables quickly finding modifications from one specific revision to another. Compaction removes out-of-date keys-value pairs.

etcd also keeps a secondary in-memory btree index to speed up range queries over keys. The keys in the btree index are the keys of the store exposed to user. The value is a pointer to the modification of the persistent b+tree. Compaction removes dead pointers.

# etcd 应用场景
## 键值存储服务
键值存储，etcd本身就是一个键值存储服务，可以通过put，get，delete增删查键值，还可以通过watch进行监视键值的变化。而且具有高一致性，可以使用etcd集群，向外界提供服务。
通过New方法传入Config对象进行创建etcd对象。
其中Config结构为：
```golang
type Config struct {
    // Endpoints 集群节点地址，ip:port
    // 可以填写[]string{"localhost:2379", "localhost:2380"}
    Endpoints []string `json:"endpoints"`
    
    // AutoSyncInterval 是使用其最新成员更新端点的时间间隔
    // 0表示禁止自动同步，默认是0
    AutoSyncInterval time.Duration `json:"auto-sync-interval"`
    
    // DiaTimeout 连接超时时间
    DialTimeout time.Duration `json:"dial-timeout"`
    
    // DialKeepAliveTime 是客户端ping服务器已查看传输是否处于活动状态的时间
    DialKeepAliveTime time.Duration `json:"dial-keep-alive-time"`
    
    // DialKeepAliveTimeout 是客户端等待保持活动探测的时间。如果此时未收到响应，则关闭连接。
    DialKeepAliveTimeout time.Duration `json:"dial-keep-alive-timeout"`
    
    // MaxCallSendMsgSize 是客户端请求发送限制（以字节为单位）
    // 如果是0，则默认为2Mib，确保MaxCallSendMsgSize小于服务端默认发送/接收限制
    // （--max-request-bytes标志为etcd或embed.Config.MaxRequestBytes）
    MaxCallSendMsgSize int
    
    // MaxCallRecvMsgSize 是客户端响应接收限制
    // 如果是0，默认为math.MaxInt32，因为范围响应很容易超过请求发送限制
    // 确保MaxCallRecvMsgSize大于等于服务端默认发送/接收限制
    // （--max-request-bytes标志为etcd或embed.Config.MaxRequestBytes）
    MaxCallRecvMsgSize int
    
    // TLS 保留客户端安全凭证（如果有）。
    TLS *tls.Config
    
    // Username 用于认证的用户名
    Username string `json:"username"`
    
    // Password 用于认证的密码
    Password string `json:"password"`
    
    // RejectOldCluster 如果设置，将拒绝针对过时的集群创建客户端
    RejectOldCluster bool `json:"reject-old-cluster"`
    
    // DialOptions 是grpc客户端的拨号选项列表（例如，用于拦截器）
    DialOptions []grpc.DialOption
    
    // Context 是默认的客户端上下文;它可用于取消grpc拨出和其他没有明确上下文的操作。
    Context context.Context
}
```
通常简单的配置etcd，即可用于生产，记得在使用完后关闭client，否则会导致goroutine泄漏
```golang
client, err := clientv3.New(clientv3.Config{
    Endpoints:   []string{"localhost:2379", "localhost:2380"},
    DialTimeout: 5 * time.Second,
    Username:    "etcd",
    Password:    "etcd",
})
defer client.Close()
```
如果要指定客户端超时，可以通过context.WithTimeout封装一下，WithTimeout会返回一个上下文ctx和一个取消函数cancle
```go
ctx, cancle := context.WithTimeout(context.Background(), 5*time.Second)
defer cancle()
```
通过上下文ctx我们就可以操作etcd，client是协程安全的，所有可以复用client
```go
// put
presp, err := client.Put(ctx, key, "test")

// get
gresp, err := client.Get(ctx, key)

// delete
dresp, err := client.Delete(ctx, key)
```
etcd客户端会返回3种错误：
* context error: 被取消或者超过截止时间
* gRPC status error: 例如当客户端的上下文截止日期超过当前服务端时间漂移
* gRPC error: 查看[error](https://github.com/coreos/etcd/blob/master/etcdserver/api/v3rpc/rpctypes/error.go)

```go
resp, err := kvc.Put(ctx, "", "")
if err != nil {
    if err == context.Canceled {
        // ctx is canceled by another routine
	} else if err == context.DeadlineExceeded {
		// ctx is attached with a deadline and it exceeded
	} else if ev, ok := status.FromError(err); ok {
		code := ev.Code()
		if code == codes.DeadlineExceeded {
			// server-side context might have timed-out first (due to clock skew)
			// while original client-side context is not timed-out yet
		}
	} else if verr, ok := err.(*v3rpc.ErrEmptyKey); ok {
		// process (verr.Errors)
	} else {
		// bad cluster endpoints, which are not etcd servers
	}
}

go func() { cli.Close() }()
_, err := kvc.Get(ctx, "a")
if err != nil {
	if err == context.Canceled {
		// grpc balancer calls 'Get' with an inflight client.Close
	} else if err == grpc.ErrClientConnClosing {
		// grpc balancer calls 'Get' after client.Close.
	}
}
```

对于操作我们可以使用etcd提供的Watch操作来监视键值的变化
```go
for {
    wat := client.Watch(ctx, key)
    for wresp := range wat {
        for _, ev := range wresp.Events {
            fmt.Printf("%s %q : %q\n", ev.Type, ev.Kv.Key, ev.Kv.Value)
        }
    }
}
```
通过watch我们可以监视键值的情况，这样对于管理键值有很大的帮助，也为服务发现提供了可能。


## 服务发现
服务发现问题，即在同一个分布式集群中的进程或服务，要如何才能找到对方并建立连接。本质上说，服务发现就是想要了解及群众是否有进程在监听端口，并且通过名字就可以查找和连接。
要解决服务发现问题，必须要以下模块：
- **一个强一致性，高可用的服务存储目录。**基于Raft算法让etcd天生就满足这个要求。
- **一种注册服务和监控服务健康状态的机制。**用户可以在etcd中注册服务，并且对注册的服务设置key TTL，定时保持服务的心跳已达到监控健康状态的效果。
- **一种查找和连接服务的机制。**通过etcd指定过的主题下注册的服务也能在对应的主题下查找到，为了确保连接，我们可以在每个服务机器上都部署一个Proxy模式的etcd，这样就可以确保能访问etcd集群的服务都能互相连接。

作为一个服务发现服务必须具有以下实现功能：
* 网关agent监听服务的状态，监听到新的服务时，将服务添加到服务列表中
* 动态的增删服务
  * 当server启动成功后，向etcd注册服务，并定时向etcd发送心跳
  * 当server删除后，监听服务检测到某个key超时，可以根据自己的策略来决定是否删除当前server
* 客户端连接server之前，先向agent请求server地址，agent可以根据自己的策略给client分配服务，client根据分配的server地址去连接服务

服务发现，可以快速微服务架构的增扩服务节点，达到服务的弹性化，合理利用资源。


 