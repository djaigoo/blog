---
author: djaigo
title: 创建私有docker-image服务器
date: 2018-08-08 17:13:41
img: https://img-1251474779.cos.ap-beijing.myqcloud.com/docker.png
categories: 
  - docker
tags: 
  - image
  - registry
  - server
---

本文介绍怎样搭建和使用私有化的 Docker 镜像服务器（Docker Registry）。

## 为什么需要私有镜像服务器？

1. **安全性**：保护企业内部镜像，避免泄露到公共仓库
2. **速度**：内网传输速度快，减少带宽消耗
3. **稳定性**：不依赖外部服务，提高可用性
4. **合规性**：满足企业数据不出域的要求
5. **成本**：减少对 Docker Hub 等公共服务的依赖

## Docker Registry 简介

Docker Registry 是 Docker 官方提供的镜像存储服务，支持：
- 镜像的推送（push）和拉取（pull）
- 镜像的版本管理
- 镜像的存储和管理
- 支持 HTTP 和 HTTPS
- 支持用户认证和授权

# Docker Registry 服务器搭建

## 方式一：使用 Docker 运行（推荐）

### 1. 拉取官方 Registry 镜像

首先需要获取官方的 registry 镜像包。
```shell
# 拉取最新版本的 registry 镜像
$ docker pull registry:latest

# 或者拉取指定版本（推荐使用稳定版本）
$ docker pull registry:2.8.2
```

### 2. 配置 HTTP 访问（内网环境）

Docker 默认要求镜像服务器使用 HTTPS 协议传输，但在内网环境中可以配置为 HTTP。

#### 方法一：配置 Docker Daemon（推荐）

编辑 `/etc/docker/daemon.json` 文件（如果不存在则创建）：

```json
{
  "insecure-registries": ["your-registry-ip:5000"],
  "registry-mirrors": []
}
```

配置多个不安全的 registry：

```json
{
  "insecure-registries": [
    "192.168.1.100:5000",
    "registry.example.com:5000"
  ]
}
```

重启 Docker 服务使配置生效：

```shell
# CentOS/RHEL
$ sudo systemctl restart docker

# Ubuntu/Debian
$ sudo systemctl restart docker
```

#### 方法二：使用环境变量（临时）

```shell
$ export DOCKER_OPTS="--insecure-registry=your-registry-ip:5000"
```

### 3. 数据持久化

为了让 Docker Registry 的数据持久化，需要将本地磁盘映射到容器内部的 `/var/lib/registry`。

```shell
# 创建数据目录
$ mkdir -p /opt/docker-registry/data

# 设置权限（可选，根据实际情况调整）
$ chmod 755 /opt/docker-registry/data
```

### 4. 运行 Registry 容器

#### 基本运行方式

```shell
$ docker run -d \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  --restart=always \
  --name registry \
  registry:latest
```

#### 使用配置文件运行（推荐）

创建配置文件 `/opt/docker-registry/config.yml`：

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

使用配置文件运行：

```shell
$ docker run -d \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/config.yml:/etc/docker/registry/config.yml \
  --restart=always \
  --name registry \
  registry:latest
```

#### 完整运行命令（包含所有常用选项）

```shell
$ docker run -d \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/config.yml:/etc/docker/registry/config.yml \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true \
  --restart=always \
  --name registry \
  registry:latest
```

参数说明：
- `-d`：后台运行
- `-p 5000:5000`：端口映射
- `-v`：数据卷挂载
- `--restart=always`：自动重启
- `-e REGISTRY_STORAGE_DELETE_ENABLED=true`：启用删除功能

### 5. 验证 Registry 运行状态

```shell
# 检查容器状态
$ docker ps | grep registry

# 查看容器日志
$ docker logs registry

# 测试 Registry API
$ curl http://your-registry-ip:5000/v2/

# 查看仓库列表
$ curl http://your-registry-ip:5000/v2/_catalog
```

## 方式二：使用 Docker Compose（推荐用于生产环境）

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  registry:
    image: registry:latest
    container_name: registry
    restart: always
    ports:
      - "5000:5000"
    volumes:
      - ./data:/var/lib/registry
      - ./config.yml:/etc/docker/registry/config.yml
    environment:
      - REGISTRY_STORAGE_DELETE_ENABLED=true
    networks:
      - registry-net

networks:
  registry-net:
    driver: bridge
```

启动服务：

```shell
$ docker-compose up -d
```

## 方式三：配置 HTTPS（生产环境推荐）

### 1. 生成 SSL 证书

#### 使用自签名证书（测试环境）

```shell
# 创建证书目录
$ mkdir -p /opt/docker-registry/certs

# 生成自签名证书
$ openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout /opt/docker-registry/certs/domain.key \
  -x509 -days 365 \
  -out /opt/docker-registry/certs/domain.crt
```

#### 使用 Let's Encrypt 证书（生产环境）

```shell
# 安装 certbot
$ sudo apt-get install certbot

# 获取证书
$ sudo certbot certonly --standalone -d registry.example.com
```

### 2. 配置 HTTPS Registry

修改配置文件 `config.yml`：

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  tls:
    certificate: /certs/domain.crt
    key: /certs/domain.key
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

运行容器：

```shell
$ docker run -d \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/config.yml:/etc/docker/registry/config.yml \
  -v /opt/docker-registry/certs:/certs \
  --restart=always \
  --name registry \
  registry:latest
```

### 3. 客户端配置

如果使用自签名证书，需要在客户端安装证书：

```shell
# 复制证书到系统信任目录
$ sudo cp /opt/docker-registry/certs/domain.crt /etc/docker/certs.d/registry.example.com:5000/ca.crt

# 或者复制到用户目录
$ mkdir -p ~/.docker/certs.d/registry.example.com:5000
$ cp /opt/docker-registry/certs/domain.crt ~/.docker/certs.d/registry.example.com:5000/ca.crt
```

## 方式四：配置用户认证（生产环境必需）

### 1. 使用 htpasswd 创建用户

```shell
# 安装 htpasswd（Apache 工具）
$ sudo apt-get install apache2-utils
# 或
$ sudo yum install httpd-tools

# 创建密码文件
$ mkdir -p /opt/docker-registry/auth
$ htpasswd -Bbn username password > /opt/docker-registry/auth/htpasswd

# 添加更多用户
$ htpasswd -Bbn user2 password2 >> /opt/docker-registry/auth/htpasswd
```

### 2. 配置认证

修改 `config.yml`：

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
auth:
  htpasswd:
    realm: Registry Realm
    path: /auth/htpasswd
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

运行容器：

```shell
$ docker run -d \
  -p 5000:5000 \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/config.yml:/etc/docker/registry/config.yml \
  -v /opt/docker-registry/auth:/auth \
  --restart=always \
  --name registry \
  registry:latest
```

### 3. 客户端登录

```shell
# 登录到私有仓库
$ docker login your-registry-ip:5000
Username: username
Password: password
Login Succeeded
```

## 完整配置示例（生产环境）

创建完整的 `config.yml`：

```yaml
version: 0.1
log:
  level: info
  fields:
    service: registry
    environment: production
storage:
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
    maxthreads: 100
  delete:
    enabled: true
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    X-Frame-Options: [DENY]
  tls:
    certificate: /certs/domain.crt
    key: /certs/domain.key
auth:
  htpasswd:
    realm: Registry Realm
    path: /auth/htpasswd
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
compatibility:
  schema1:
    enabled: true
```

## Registry 配置选项说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `storage.filesystem.rootdirectory` | 存储根目录 | `/var/lib/registry` |
| `storage.delete.enabled` | 启用删除功能 | `false` |
| `http.addr` | 监听地址 | `:5000` |
| `http.tls.certificate` | TLS 证书路径 | - |
| `http.tls.key` | TLS 私钥路径 | - |
| `auth.htpasswd.path` | 认证文件路径 | - |
| `compatibility.schema1.enabled` | 启用 Schema v1 支持 | `false` |
# Docker 客户端使用

## 镜像命名规则

私有 Registry 的镜像命名格式：`registry-ip:port/namespace/image-name:tag`

例如：`172.16.220.41:5000/myhub/nginx:v0.1`

- `172.16.220.41:5000`：Registry 服务器地址和端口
- `myhub`：命名空间（可选，用于组织镜像）
- `nginx`：镜像名称
- `v0.1`：标签（版本）

## 基本操作

### 1. 登录 Registry

```shell
# 登录到私有仓库（如果配置了认证）
$ docker login 172.16.220.41:5000
Username: username
Password: password
Login Succeeded

# 查看登录信息
$ cat ~/.docker/config.json
```

### 2. 标记镜像

在推送镜像前，需要先标记（tag）镜像：

```shell
# 方式一：从现有镜像标记
$ docker tag nginx:latest 172.16.220.41:5000/myhub/nginx:v0.1

# 方式二：构建时直接标记
$ docker build -t 172.16.220.41:5000/myhub/nginx:v0.1 .
```

### 3. 推送镜像

```shell
$ docker push 172.16.220.41:5000/myhub/nginx:v0.1
The push refers to a repository [172.16.220.41:5000/myhub/nginx]
08d25fa0442e: Pushed 
a8c4aeeaa045: Pushed 
cdb3f9544e4c: Pushed 
v0.1: digest: sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189 size: 948
```

### 4. 拉取镜像

```shell
$ docker pull 172.16.220.41:5000/myhub/nginx:v0.1
Trying to pull repository 172.16.220.41:5000/myhub/nginx ... 
v0.1: Pulling from 172.16.220.41:5000/myhub/nginx
Digest: sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
Status: Downloaded newer image for 172.16.220.41:5000/myhub/nginx:v0.1
```

### 5. 查看本地镜像

```shell
$ docker images | grep 172.16.220.41:5000
172.16.220.41:5000/myhub/nginx   v0.1   abc123def456   2 hours ago   133MB
```

### 6. 删除本地镜像

```shell
$ docker rmi 172.16.220.41:5000/myhub/nginx:v0.1
Untagged: 172.16.220.41:5000/myhub/nginx:v0.1
Untagged: 172.16.220.41:5000/myhub/nginx@sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
```

### 7. 使用镜像运行容器

```shell
$ docker run -d -p 80:80 172.16.220.41:5000/myhub/nginx:v0.1
```

## 完整测试流程

```shell
# 1. 拉取基础镜像
$ docker pull nginx:latest

# 2. 标记镜像
$ docker tag nginx:latest 172.16.220.41:5000/myhub/nginx:v0.1

# 3. 推送镜像
$ docker push 172.16.220.41:5000/myhub/nginx:v0.1

# 4. 删除本地镜像
$ docker rmi 172.16.220.41:5000/myhub/nginx:v0.1

# 5. 从私有仓库拉取
$ docker pull 172.16.220.41:5000/myhub/nginx:v0.1

# 6. 验证镜像
$ docker images | grep nginx
$ docker run --rm 172.16.220.41:5000/myhub/nginx:v0.1 nginx -v
```

# Registry API 使用

## 查看仓库列表

```shell
# 查看所有仓库
$ curl http://172.16.220.41:5000/v2/_catalog

# 带认证的请求
$ curl -u username:password http://172.16.220.41:5000/v2/_catalog
```

## 查看仓库标签

```shell
# 查看指定仓库的所有标签
$ curl http://172.16.220.41:5000/v2/myhub/nginx/tags/list

# 带认证
$ curl -u username:password http://172.16.220.41:5000/v2/myhub/nginx/tags/list
```

## 删除镜像

### 1. 启用删除功能

在 `config.yml` 中配置：

```yaml
storage:
  delete:
    enabled: true
```

### 2. 获取镜像摘要

```shell
# 获取镜像的 digest
$ curl -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  http://172.16.220.41:5000/v2/myhub/nginx/manifests/v0.1

# 从响应头中获取 Digest
# Docker-Content-Digest: sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
```

### 3. 删除镜像

```shell
$ curl -X DELETE \
  -u username:password \
  http://172.16.220.41:5000/v2/myhub/nginx/manifests/sha256:4ffd9758ea9ea360fd87d0cee7a2d1cf9dba630bb57ca36b3108dcd3708dc189
```

### 4. 清理未使用的层

```shell
# 进入 Registry 容器
$ docker exec -it registry sh

# 运行垃圾回收
$ registry garbage-collect /etc/docker/registry/config.yml
```

# Registry 管理工具

## 使用 Registry UI

### 1. 使用 docker-registry-ui

```shell
$ docker run -d \
  -p 8080:80 \
  -e REGISTRY_URL=http://registry:5000 \
  --link registry:registry \
  --name registry-ui \
  joxit/docker-registry-ui:latest
```

### 2. 使用 Portus

Portus 是 SUSE 开发的 Registry Web UI，功能更强大。

## 使用命令行工具

### 安装 registry-cli

```shell
$ pip install docker-registry-cli
```

### 使用示例

```shell
# 列出所有仓库
$ regcli catalog http://172.16.220.41:5000

# 列出仓库标签
$ regcli tags http://172.16.220.41:5000/myhub/nginx

# 删除标签
$ regcli delete http://172.16.220.41:5000/myhub/nginx:v0.1
```

# 常见问题和解决方案

## 问题 1：推送镜像失败 - 获取 https://xxx:5000/v2/ 时出错

**原因**：Docker 默认要求使用 HTTPS。

**解决方案**：
1. 配置 `insecure-registries`（内网环境）
2. 配置 HTTPS 证书（生产环境）

## 问题 2：推送镜像失败 - 未授权

**原因**：Registry 配置了认证，但客户端未登录。

**解决方案**：
```shell
$ docker login your-registry-ip:5000
```

## 问题 3：删除镜像后空间未释放

**原因**：需要运行垃圾回收。

**解决方案**：
```shell
# 停止 Registry
$ docker stop registry

# 运行垃圾回收
$ docker run --rm \
  -v /opt/docker-registry/data:/var/lib/registry \
  -v /opt/docker-registry/config.yml:/etc/docker/registry/config.yml \
  registry:latest \
  bin/registry garbage-collect /etc/docker/registry/config.yml

# 重启 Registry
$ docker start registry
```

## 问题 4：Registry 容器频繁重启

**原因**：可能是配置错误或存储问题。

**解决方案**：
```shell
# 查看容器日志
$ docker logs registry

# 检查配置文件
$ docker exec registry cat /etc/docker/registry/config.yml

# 检查数据目录权限
$ ls -la /opt/docker-registry/data
```

## 问题 5：镜像推送很慢

**原因**：网络问题或存储性能问题。

**解决方案**：
1. 检查网络连接
2. 使用 SSD 存储
3. 配置镜像加速器
4. 使用本地存储而不是网络存储

# 最佳实践

## 1. 安全建议

- ✅ 生产环境必须使用 HTTPS
- ✅ 配置用户认证和授权
- ✅ 定期更新 Registry 镜像
- ✅ 限制网络访问（使用防火墙）
- ✅ 定期备份数据
- ✅ 使用强密码策略

## 2. 性能优化

- ✅ 使用 SSD 存储
- ✅ 配置适当的缓存策略
- ✅ 使用 CDN 加速（如果支持）
- ✅ 定期清理未使用的镜像
- ✅ 使用分层存储

## 3. 高可用部署

- ✅ 使用负载均衡器
- ✅ 配置多个 Registry 实例
- ✅ 使用共享存储（NFS、Ceph 等）
- ✅ 配置健康检查
- ✅ 使用容器编排工具（Kubernetes、Docker Swarm）

## 4. 监控和日志

- ✅ 配置日志收集
- ✅ 监控 Registry 性能
- ✅ 设置告警规则
- ✅ 定期检查存储使用情况

## 5. 备份策略

```shell
# 备份 Registry 数据
$ tar -czf registry-backup-$(date +%Y%m%d).tar.gz /opt/docker-registry/data

# 恢复备份
$ tar -xzf registry-backup-20240101.tar.gz -C /
```

# 与 CI/CD 集成

## Jenkins 集成

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t registry:5000/myapp:${BUILD_NUMBER} .'
            }
        }
        stage('Push') {
            steps {
                sh '''
                    docker login -u ${REGISTRY_USER} -p ${REGISTRY_PASS} registry:5000
                    docker push registry:5000/myapp:${BUILD_NUMBER}
                '''
            }
        }
    }
}
```

## GitLab CI 集成

```yaml
build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
```

# 总结

通过本文，我们学习了：

1. **Registry 的基本概念**：了解为什么需要私有镜像服务器
2. **多种部署方式**：Docker 运行、Docker Compose、HTTPS 配置、认证配置
3. **客户端使用**：镜像的推送、拉取、标记等操作
4. **API 使用**：通过 API 管理镜像
5. **管理工具**：使用 UI 和命令行工具管理 Registry
6. **问题排查**：常见问题的解决方案
7. **最佳实践**：安全、性能、高可用等方面的建议

搭建私有 Docker Registry 可以满足企业级需求，提供安全、快速、稳定的镜像存储服务。


