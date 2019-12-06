---
title: k8s-Volume
tags:
  - k8s
categories:
  - k8s
draft: true
date: 2018-08-02 15:06:49
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/k8s.png
---
默认情况下容器中的磁盘文件是非持久化的，对于运行在容器中的应用来说面临两个问题，第一：当容器挂掉kubelet将重启启动它时，文件将会丢失；第二：当Pod中同时运行多个容器，容器之间需要共享文件时。Kubernetes的Volume解决了这两个问题。

## 背景

在Docker中也有一个docker Volume的概念 ，Docker的Volume只是磁盘中的一个目录，生命周期不受管理。当然Docker现在也提供Volume将数据持久化存储，但支持功能比较少（例如，对于Docker 1.7，每个容器只允许挂载一个Volume，并且不能将参数传递给Volume）。

另一方面，Kubernetes Volume具有明确的生命周期 - 与pod相同。因此，Volume的生命周期比Pod中运行的任何容器要持久，在容器重新启动时能可以保留数据，当然，当Pod被删除不存在时，Volume也将消失。注意，Kubernetes支持许多类型的Volume，Pod可以同时使用任意类型/数量的Volume。

内部实现中，一个Volume只是一个目录，目录中可能有一些数据，pod的容器可以访问这些数据。至于这个目录是如何产生的、支持它的介质、其中的数据内容是什么，这些都由使用的特定Volume类型来决定。

要使用Volume，pod需要指定Volume的类型和内容（`spec.volumes`字段），和映射到容器的位置（`spec.containers.volumeMounts`字段）。

## Volume 类型
Kubernetes支持Volume类型有：
|||||
| :--: | :--: | :--: | :--: |
| emptyDir | fc (fibre channel) | secret | vsphereVolume |
| hostPath | flocker | persistentVolumeClaim | Quobyte |
| gcePersistentDisk | glusterfs | downwardAPI | PortworxVolume |
| awsElasticBlockStore | rbd | projected | ScaleIO |
| nfs | cephfs | azureFileVolume | StorageOS |
| iscsi | gitRepo | azureDisk | local |

### emptyDir

使用emptyDir，当Pod分配到Node上时，将会创建emptyDir，并且只要Node上的Pod一直运行，Volume就会一直存。当Pod（不管任何原因）从Node上被删除时，emptyDir也同时会删除，存储的数据也将永久删除。注：删除容器不影响emptyDir。

示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```


### hostPath

hostPath允许挂载Node上的文件系统到Pod里面去。如果Pod需要使用Node上的文件，可以使用hostPath。

示例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # directory location on host
      path: /data
```


### gcePersistentDisk

gcePersistentDisk可以挂载GCE上的永久磁盘到容器，需要Kubernetes运行在GCE的VM中。与emptyDir不同，Pod删除时，gcePersistentDisk被删除，但Persistent Disk的内容任然存在。这就意味着gcePersistentDisk能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。

**提示：使用gcePersistentDisk，必须用gcloud或使用GCE API或UI 创建PD**

创建PD

使用GCE PD与pod之前，需要创建它

```shell
gcloud compute disks create --size=500GB --zone=us-central1-a my-data-disk
```
示例
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    # This GCE PD must already exist.
    gcePersistentDisk:
      pdName: my-data-disk
      fsType: ext4
```


### awsElasticBlockStore

awsElasticBlockStore可以挂载AWS上的EBS盘到容器，需要Kubernetes运行在AWS的EC2上。与emptyDir Pod被删除情况不同，Volume仅被卸载，内容将被保留。这就意味着awsElasticBlockStore能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。

提示：必须使用aws ec2 create-volumeAWS API 创建EBS Volume，然后才能使用。

**创建EBS Volume**

在使用EBS Volume与pod之前，需要创建它。
```shell
aws ec2 create-volume --availability-zone eu-west-1a --size 10 --volume-type gp2
```
AWS EBS配置示例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-ebs
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-ebs
      name: test-volume
  volumes:
  - name: test-volume
    # This AWS EBS volume must already exist.
    awsElasticBlockStore:
      volumeID: <volume-id>
      fsType: ext4
```


### NFS

NFS 是Network File System的缩写，即网络文件系统。Kubernetes中通过简单地配置就可以挂载NFS到Pod中，而NFS中的数据是可以永久保存的，同时NFS支持同时写操作。Pod被删除时，Volume被卸载，内容被保留。这就意味着NFS能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间相互传递。

### iSCSI

iscsi允许将现有的iscsi磁盘挂载到我们的pod中，和emptyDir不同的是，删除Pod时会被删除，但Volume只是被卸载，内容被保留，这就意味着iscsi能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。。

### flocker

Flocker是一个开源的容器集群数据卷管理器。它提供各种存储后端支持的数据卷的管理和编排。

### glusterfs

glusterfs，允许将Glusterfs（一个开源网络文件系统）Volume安装到pod中。不同于emptyDir，Pod被删除时，Volume只是被卸载，内容被保留。味着glusterfs能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。

### RBD

RBD允许Rados Block Device格式的磁盘挂载到Pod中，同样的，当pod被删除的时候，rbd也仅仅是被卸载，内容保留，rbd能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。


### cephfs

cephfs Volume可以将已经存在的CephFS Volume挂载到pod中，与emptyDir特点不同，pod被删除的时，cephfs仅被被卸载，内容保留。cephfs能够允许我们提前对数据进行处理，而且这些数据可以在Pod之间“切换”。

提示：可以使用自己的Ceph服务器运行导出，然后在使用cephfs。


### gitRepo

gitRepo volume将git代码下拉到指定的容器路径中。

示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: server
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - mountPath: /mypath
      name: git-volume
  volumes:
  - name: git-volume
    gitRepo:
      repository: "git@somewhere:me/my-git-repository.git"
      revision: "22f1d8406d464b0c0874075539c1f2e96c253775"

```

### secret

secret volume用于将敏感信息（如密码）传递给pod。可以将secrets存储在Kubernetes API中，使用的时候以文件的形式挂载到pod中，而不用连接api。 secret volume由tmpfs（RAM支持的文件系统）支持。


### persistentVolumeClaim

persistentVolumeClaim用来挂载持久化磁盘的。PersistentVolumes是用户在不知道特定云环境的细节的情况下，实现持久化存储（如GCE PersistentDisk或iSCSI卷）的一种方式。



### downwardAPI

通过环境变量的方式告诉容器Pod的信息



### projected

Projected volume将多个Volume源映射到同一个目录

目前，可以支持以下类型的卷源：

*   secret
*   downwardAPI
*   configMap

所有卷源都要求与pod在同一命名空间中。

示例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - downwardAPI:
          items:
            - path: "labels"
              fieldRef:
                fieldPath: metadata.labels
            - path: "cpu_limit"
              resourceFieldRef:
                containerName: container-test
                resource: limits.cpu
      - configMap:
          name: myconfigmap
          items:
            - key: config
              path: my-group/my-config
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
spec:
  containers:
  - name: container-test
    image: busybox
    volumeMounts:
    - name: all-in-one
      mountPath: "/projected-volume"
      readOnly: true
  volumes:
  - name: all-in-one
    projected:
      sources:
      - secret:
          name: mysecret
          items:
            - key: username
              path: my-group/my-username
      - secret:
          name: mysecret2
          items:
            - key: password
              path: my-group/my-password
              mode: 511
```


### FlexVolume

alpha功能

### AzureFileVolume

AzureFileVolume用于将Microsoft Azure文件卷（SMB 2.1和3.0）挂载到Pod中。


### AzureDiskVolume

Azure是微软提供的公有云服务，如果使用Azure上面的虚拟机来作为Kubernetes集群使用时，那么可以通过AzureDisk这种类型的卷插件来挂载Azure提供的数据磁盘。


### vsphereVolume

需要条件：配置了vSphere Cloud Provider的Kubernetes

vsphereVolume用于将vSphere VMDK Volume挂载到Pod中。卸载卷后，内容将被保留。它同时支持VMFS和VSAN数据存储。

重要提示：使用POD之前，必须使用以下方法创建VMDK。

#### 创建一个VMDK卷

*   使用vmkfstools创建。先将ssh接入ESX，然后使用以下命令创建vmdk
```shell
vmkfstools -c 2G /vmfs/volumes/DatastoreName/volumes/myDisk.vmdk
```

*   使用vmware-vdiskmanager创建
```shell
shell vmware-vdiskmanager -c -t 0 -s 40GB -a lsilogic myDisk.vmdk
```

示例

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-vmdk
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-vmdk
      name: test-volume
  volumes:
  - name: test-volume
    # This VMDK volume must already exist.
    vsphereVolume:
      volumePath: "[DatastoreName] volumes/myDisk"
      fsType: ext4
```

### Quobyte

在kubernetes中使用Quobyte存储，需要提前部署Quobyte软件，要求必须是1.3以及更高版本，并且在kubernetes管理的节点上面部署Quobyte客户端。

### PortworxVolume

Portworx能把你的服务器容量进行蓄积（pool），将你的服务器或者云实例变成一个聚合的高可用的计算和存储节点。

PortworxVolume可以通过Kubernetes动态创建，也可以在Kubernetes pod中预先配置和引用。示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-portworx-volume-pod
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /mnt
      name: pxvol
  volumes:
  - name: pxvol
    # This Portworx volume must already exist.
    portworxVolume:
      volumeID: "pxvol"
      fsType: "<fs-type>"
```


### ScaleIO

ScaleIO是一种基于软件的存储平台（虚拟SAN），可以使用现有硬件来创建可扩展共享块网络存储的集群。ScaleIO卷插件允许部署的pod访问现有的ScaleIO卷（或者可以为持久卷声明动态配置新卷）。

示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-0
spec:
  containers:
  - image: gcr.io/google_containers/test-webserver
    name: pod-0
    volumeMounts:
    - mountPath: /test-pd
      name: vol-0
  volumes:
  - name: vol-0
    scaleIO:
      gateway: https://localhost:443/api
      system: scaleio
      volumeName: vol-0
      secretRef:
        name: sio-secret
      fsType: xfs

```


### StorageOS

StorageOS是一家英国的初创公司，给无状态容器提供简单的自动块存储、状态来运行数据库和其他需要企业级存储功能，但避免随之而来的复杂性、刚性以及成本。

核心：是StorageOS向容器提供块存储，可通过文件系统访问。

StorageOS容器需要64位Linux，没有额外的依赖关系，提供免费开发许可证。

安装说明，请参阅[StorageOS文档](https://docs.storageos.com/)

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: redis
    role: master
  name: test-storageos-redis
spec:
  containers:
    - name: master
      image: kubernetes/redis:v1
      env:
        - name: MASTER
          value: "true"
      ports:
        - containerPort: 6379
      volumeMounts:
        - mountPath: /redis-master-data
          name: redis-data
  volumes:
    - name: redis-data
      storageos:
        # The `redis-vol01` volume must already exist within StorageOS in the `default` namespace.
        volumeName: redis-vol01
        fsType: ext4
```


### Local

目前处于 Kubernetes 1.7中的 alpha 级别。

Local 是Kubernetes集群中每个节点的本地存储（如磁盘，分区或目录），在Kubernetes1.7中kubelet可以支持对kube-reserved和system-reserved指定本地存储资源。

通过上面的这个新特性可以看出来，Local Storage同HostPath的区别在于对Pod的调度上，使用Local Storage可以由Kubernetes自动的对Pod进行调度，而是用HostPath只能人工手动调度Pod，因为Kubernetes已经知道了每个节点上kube-reserved和system-reserved设置的本地存储限制。

示例：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
  annotations:
        "volume.alpha.kubernetes.io/node-affinity": '{
            "requiredDuringSchedulingIgnoredDuringExecution": {
                "nodeSelectorTerms": [
                    { "matchExpressions": [
                        { "key": "kubernetes.io/hostname",
                          "operator": "In",
                          "values": ["example-node"]
                        }
                    ]}
                 ]}
              }'
spec:
    capacity:
      storage: 100Gi
    accessModes:
    - ReadWriteOnce
    persistentVolumeReclaimPolicy: Delete
    storageClassName: local-storage
    local:
      path: /mnt/disks/ssd1
```

请注意，本地PersistentVolume需要手动清理和删除。


## Using subPath

有时，可以在一个pod中，将同一个卷共享，使其有多个用处。volumeMounts.subPath特性可以用来指定卷中的一个子目录，而不是直接使用卷的根目录。

以下是使用单个共享卷的LAMP堆栈（Linux Apache Mysql PHP）的pod的示例。HTML内容映射到其html文件夹，数据库将存储在mysql文件夹中：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-lamp-site
spec:
    containers:
    - name: mysql
      image: mysql
      volumeMounts:
      - mountPath: /var/lib/mysql
        name: site-data
        subPath: mysql
    - name: php
      image: php
      volumeMounts:
      - mountPath: /var/www/html
        name: site-data
        subPath: html
    volumes:
    - name: site-data
      persistentVolumeClaim:
        claimName: my-lamp-site-data
```


## Resources

emptyDir Volume的存储介质（Disk，SSD等）取决于kubelet根目录（如/var/lib/kubelet）所处文件系统的存储介质。不限制emptyDir或hostPath Volume使用的空间大小，不对容器或Pod的资源隔离。
