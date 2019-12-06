---
title: k8s-Node
tags:
  - 基础
categories:
  - k8s
draft: true
date: 2018-08-02 15:31:05
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
## Node是什么？

Node 是 Pod 真正运行的主机，可以是物理机，也可以是虚拟机。为了管理 Pod，每个 Node 节点上至少要运行 container runtime（比如 `docker` 或者 `rkt`）、`kubelet` 和 `kube-proxy` 服务。
<!--more-->
![node](node.png)
## Node 管理
不像其他的资源（如 Pod 和 Namespace），Node 本质上不是 Kubernetes 来创建的，Kubernetes 只是管理 Node 上的资源。虽然可以通过 Manifest 创建一个 Node 对象（如下 yaml 所示），但 Kubernetes 也只是去检查是否真的是有这么一个 Node，如果检查失败，也不会往上调度 Pod。

```yaml
kind: Node
apiVersion: v1
metadata:
  name: 10-240-79-157
  labels:
    name: my-first-k8s-node

```

这个检查是由 Node Controller 来完成的。Node Controller 负责

*   维护 Node 状态
*   与 Cloud Provider 同步 Node
*   给 Node 分配容器 CIDR
*   删除带有 `NoExecute` taint 的 Node 上的 Pods

默认情况下，kubelet 在启动时会向 master 注册自己，并创建 Node 资源。


## Node Status
每个 Node 都包括以下状态信息：
*   地址（Addresses）：包括 hostname、外网 IP 和内网 IP
*   条件（Condition）：包括 OutOfDisk、Ready、MemoryPressure 和 DiskPressure
*   容量（Capacity）：Node 上的可用资源，包括 CPU、内存和 Pod 总数
*   基本信息（Info）：包括内核版本、容器引擎版本、OS 类型等

下面详细描述每个部分。

### Addresses

这些字段的使用取决于云提供商或裸机配置。
*   HostName：可以通过kubelet 中 --hostname-override参数覆盖。
*   ExternalIP：可以被集群外部路由到的IP。
*   InternalIP：只能在集群内进行路由的节点的IP地址。

### Condition

conditions字段描述所有Running节点的状态。

| Node Condition | Description |
| :---: | :--- |
| OutOfDisk | True：如果节点上没有足够的可用空间来添加新的pod；否则为：False |
| Ready | True：如果节点是健康的并准备好接收pod；False：如果节点不健康并且不接受pod；Unknown：如果节点控制器在过去40秒内没有收到node的状态报告。 |
| MemoryPressure | True：如果节点存储器上内存过低; 否则为：False。 |
| DiskPressure | True：如果磁盘容量存在压力 - 也就是说磁盘容量低；否则为：False。 |

node condition被表示为一个JSON对象。例如，下面的响应描述了一个健康的节点。

```json
"conditions": [
  {
    "kind": "Ready",
    "status": "True"
  }
]
```
如果Ready condition的Status是“Unknown” 或 “False”，比“pod-eviction-timeout”的时间长，则传递给“ kube-controller-manager”的参数，该节点上的所有Pod都将被节点控制器删除。默认的eviction timeout时间为5分钟。在某些情况下，当节点无法访问时，apiserver将无法与kubelet通信，删除Pod的需求不会传递到kubelet，直到重新与apiserver建立通信，这种情况下，计划删除的Pod会继续在划分的节点上运行。

在Kubernetes 1.5之前的版本中，节点控制器将强制从apiserver中删除这些不可达（上述情况）的pod。但是，在1.5及更高版本中，节点控制器在确认它们已经停止在集群中运行之前，不会强制删除Pod。可以看到这些可能在不可达节点上运行的pod处于"Terminating"或 “Unknown”。如果节点永久退出集群，Kubernetes是无法从底层基础架构辨别出来，则集群管理员需要手动删除节点对象，从Kubernetes删除节点对象会导致运行在上面的所有Pod对象从apiserver中删除，最终将会释放names。

### Capacity

描述节点上可用的资源：CPU、内存和可以调度到节点上的最大pod数。

### Info

关于节点的一些基础信息，如内核版本、Kubernetes版本（kubelet和kube-proxy版本）、Docker版本（如果有使用）、OS名称等。信息由Kubelet从节点收集。

## Management

与 [pods](http://docs.kubernetes.org.cn/312.html) 和 services 不同，节点不是由Kubernetes 系统创建，它是由Google Compute Engine等云提供商在外部创建的，或使用物理和虚拟机。这意味着当Kubernetes创建一个节点时，它只是创建一个代表节点的对象，创建后，Kubernetes将检查节点是否有效。例如，如果使用以下内容创建一个节点：

```json
{
  "kind": "Node",
  "apiVersion": "v1",
  "metadata": {
    "name": "10.240.79.157",
    "labels": {
      "name": "my-first-k8s-node"
    }
  }
}
```
Kubernetes将在内部创建一个节点对象，并通过基于metadata.name字段的健康检查来验证节点，如果节点有效，即所有必需的服务会同步运行，则才能在上面运行pod。请注意，Kubernetes将保留无效节点的对象（除非客户端有明确删除它）并且它将继续检查它是否变为有效。

目前，有三个组件与Kubernetes节点接口进行交互：节点控制器（node controller）、kubelet和kubectl。

### Node Controller

节点控制器（Node Controller）是管理节点的Kubernetes master组件。

节点控制器在节点的生命周期中具有多个角色。第一个是在注册时将CIDR块分配给节点。

第二个是使节点控制器的内部列表与云提供商的可用机器列表保持最新。当在云环境中运行时，每当节点不健康时，节点控制器将询问云提供程序是否该节点的VM仍然可用，如果不可用，节点控制器会从其节点列表中删除该节点。

第三是监测节点的健康状况。当节点变为不可访问时，节点控制器负责将NodeStatus的NodeReady条件更新为ConditionUnknown，随后从节点中卸载所有pod ，如果节点继续无法访问，（默认超时时间为40 --node-monitor-period秒，开始报告ConditionUnknown，之后为5m开始卸载）。节点控制器按每秒来检查每个节点的状态。

在Kubernetes 1.4中，我们更新了节点控制器的逻辑，以更好地处理大量节点到达主节点的一些问题（例如，主节某些网络问题）。从1.4开始，节点控制器将在决定关于pod卸载的过程中会查看集群中所有节点的状态。

在大多数情况下，节点控制器将逐出速率限制为 --node-eviction-rate（默认为0.1）/秒，这意味着它不会每10秒从多于1个节点驱逐Pod。

当给定可用性的区域中的节点变得不健康时，节点逐出行为发生变化，节点控制器同时检查区域中节点的不健康百分比（NodeReady条件为ConditionUnknown或ConditionFalse）。如果不健康节点的比例为 --unhealthy-zone-threshold（默认为0.55），那么驱逐速度就会降低：如果集群很小（即小于或等于--large-cluster-size-threshold节点 - 默认值为50），则停止驱逐，否则， --secondary-node-eviction-rate（默认为0.01）每秒。这些策略在可用性区域内实现的原因是，一个可用性区域可能会从主分区中被分区，而其他可用区域则保持连接。如果集群没有跨多个云提供商可用性区域，那么只有一个可用区域(整个集群)。

在可用区域之间传播节点的一个主要原因是，当整个区域停止时，工作负载可以转移到健康区域。因此，如果区域中的所有节点都不健康，则节点控制器以正常速率逐出--node-eviction-rate。如所有的区域都是完全不健康的（即群集中没有健康的节点），在这种情况下，节点控制器会假设主连接有一些问题，并停止所有驱逐，直到某些连接恢复。

从Kubernetes 1.6开始，节点控制器还负责驱逐在节点上运行的NoExecutepod。

### Self-Registration of Nodes

当kubelet flag --register-node为true（默认值）时，kubelet将向API服务器注册自身。这是大多数发行版使用的首选模式。

对于self-registration，kubelet从以下选项开始：

*   `--api-servers` - Location of the apiservers.
*   `--kubeconfig` - Path to credentials to authenticate itself to the apiserver.
*   `--cloud-provider` - How to talk to a cloud provider to read metadata about itself.
*   `--register-node` - Automatically register with the API server.
*   `--register-with-taints` - Register the node with the given list of taints (comma separated `<key>=<value>:<effect>`). No-op if `register-node` is false.
*   `--node-ip` IP address of the node.
*   `--node-labels` - Labels to add when registering the node in the cluster.
*   `--node-status-update-frequency` - Specifies how often kubelet posts node status to master.

#### 手动管理节点

集群管理员可以创建和修改节点对象。

如果管理员希望手动创建节点对象，请设置kubelet flag  --register-node=false。

管理员可以修改节点资源（不管--register-node设置如何），修改包括在节点上设置的labels 标签，并将其标记为不可调度的。

节点上的标签可以与pod上的节点选择器一起使用，以控制调度，例如将一个pod限制为只能在节点的子集上运行。

将节点标记为不可调度将防止新的pod被调度到该节点，但不会影响节点上的任何现有的pod，这在节点重新启动之前是有用的。例如，要标记节点不可调度，请运行以下命令：

kubectl cordon $NODENAME

**注意**，由daemonSet控制器创建的pod可以绕过Kubernetes调度程序，并且不遵循节点上无法调度的属性。

### Node容量

节点的容量(cpu数量和内存数量)是节点对象的一部分。通常，节点在创建节点对象时注册并通知其容量。如果是[手动管理节点](http://docs.kubernetes.org.cn/304.html#i)，则需要在添加节点时设置节点容量。

Kubernetes调度程序可确保节点上的所有pod都有足够的资源。它会检查节点上容器的请求的总和不大于节点容量。

如果要明确保留非pod过程的资源，可以创建一个占位符pod。使用以下模板：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-reserver
spec:
  containers:
  - name: sleep-forever
    image: gcr.io/google_containers/pause:0.8.0
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
```


将cpu和内存值设置为你想要保留的资源量，将文件放置在manifest目录中(`--config=DIR` flag of kubelet)。在要预留资源的每个kubelet上执行此操作。

## API 对象

Node是Kubernetes REST API中的最高级别资源。
