---
author: djaigo
title: Clash DNS 配置指南
date: 2025-01-27 10:00:00
categories: 
  - tools
  - network
tags: 
  - clash
  - dns
  - 代理
  - 网络配置
---

# Clash DNS 配置指南

Clash 是一个基于 Go 语言开发的多平台代理客户端，支持多种代理协议。DNS 配置是 Clash 中非常重要的部分，正确配置 DNS 可以提升代理效果和访问速度。

## DNS 配置结构

在 Clash 配置文件中，DNS 配置位于 `dns` 字段下，基本结构如下：

```yaml
dns:
  enable: true                    # 是否启用 DNS
  listen: 0.0.0.0:53             # DNS 监听地址和端口
  ipv6: false                    # 是否启用 IPv6
  default-nameserver:            # 默认 DNS 服务器
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip         # DNS 模式：fake-ip 或 redir-host
  fake-ip-range: 198.18.0.1/16   # fake-ip 地址范围
  nameserver:                    # 普通域名 DNS 服务器
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
    - tls://dns.rubyfish.cn:853
  fallback:                      # 回退 DNS 服务器（用于被污染域名）
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - tls://1.1.1.1:853
    - tls://8.8.8.8:853
  fallback-filter:               # 回退过滤规则
    geoip: true                  # 使用 GeoIP 数据库
    geoip-code: CN               # GeoIP 国家代码
    ipcidr:                      # IP 段过滤
      - 240.0.0.0/4
    domain:                      # 域名过滤
      - '+.google.com'
      - '+.facebook.com'
      - '+.youtube.com'
  nameserver-policy:             # 域名策略（指定域名使用特定 DNS）
    'www.baidu.com': '223.5.5.5'
    '+.internal.company.com': '10.0.0.1'
```

## 核心配置说明

### 1. enhanced-mode（DNS 模式）

Clash 支持两种 DNS 模式：

#### fake-ip 模式（推荐）
```yaml
enhanced-mode: fake-ip
fake-ip-range: 198.18.0.1/16
```

**优点：**
- 响应速度快，无需等待真实 DNS 解析
- 减少 DNS 查询次数
- 更好的性能表现

**工作原理：**
- 为域名分配一个假的 IP 地址（在 `fake-ip-range` 范围内）
- 在流量路由时，通过域名匹配规则，而不是 IP 地址
- 适用于大多数场景

#### redir-host 模式
```yaml
enhanced-mode: redir-host
```

**优点：**
- 使用真实 IP 地址，便于调试
- 兼容性更好

**缺点：**
- 需要等待 DNS 解析完成
- 性能相对较慢

### 2. nameserver（普通域名 DNS）

用于解析普通域名，建议使用 DoH（DNS over HTTPS）或 DoT（DNS over TLS）协议，提高安全性和防污染能力。

**推荐的 DNS 服务器：**

```yaml
nameserver:
  # 国内 DNS（DoH）
  - https://doh.pub/dns-query              # 腾讯公共 DNS
  - https://dns.alidns.com/dns-query       # 阿里 DNS
  - https://doh.360.cn/dns-query           # 360 DNS
  
  # 国内 DNS（DoT）
  - tls://dns.rubyfish.cn:853              # Rubyfish DNS
  
  # 传统 DNS（备用）
  - 223.5.5.5                              # 阿里 DNS
  - 119.29.29.29                           # 腾讯 DNS
```

### 3. fallback（回退 DNS）

用于解析被污染的域名或无法通过 nameserver 解析的域名，通常使用国外 DNS 服务器。

```yaml
fallback:
  # 国外 DNS（DoH）
  - https://cloudflare-dns.com/dns-query  # Cloudflare DNS
  - https://dns.google/dns-query           # Google DNS
  - https://doh.opendns.com/dns-query      # OpenDNS
  
  # 国外 DNS（DoT）
  - tls://1.1.1.1:853                      # Cloudflare DNS
  - tls://8.8.8.8:853                      # Google DNS
  - tls://dns.quad9.net:853                # Quad9 DNS
```

### 4. fallback-filter（回退过滤）

控制哪些域名使用 fallback DNS 解析。

```yaml
fallback-filter:
  geoip: true                    # 启用 GeoIP 过滤
  geoip-code: CN                 # 如果 IP 不在 CN，使用 fallback
  ipcidr:                        # IP 段过滤
    - 240.0.0.0/4                # 保留地址段
  domain:                        # 域名过滤（+ 表示包含子域名）
    - '+.google.com'
    - '+.facebook.com'
    - '+.youtube.com'
    - '+.twitter.com'
    - '+.instagram.com'
```

### 5. nameserver-policy（域名策略）

为特定域名指定 DNS 服务器，优先级最高。

```yaml
nameserver-policy:
  # 指定域名使用特定 DNS
  'www.baidu.com': '223.5.5.5'
  '+.internal.company.com': '10.0.0.1'      # 内网域名
  '+.lan': '192.168.1.1'                    # 本地网络
```

**指定某些域名不使用 fake-ip：**

在 `fake-ip` 模式下，所有域名默认都会使用 fake-ip。如果需要让某些域名使用真实 IP 解析（不使用 fake-ip），可以通过以下方式实现：

#### 方法 1：使用系统 DNS（推荐）

让特定域名使用系统 DNS，这样可以绕过 fake-ip，使用真实 IP：

```yaml
dns:
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  nameserver-policy:
    # 这些域名使用系统 DNS，不使用 fake-ip
    '+.xdf.cn': 'system'                    # 使用系统 DNS
    '+.test.xdf.cn': 'system'               # 测试环境使用系统 DNS
    '+.internal.company.com': 'system'      # 内网域名使用系统 DNS
    '+.lan': 'system'                       # 本地网络使用系统 DNS
    '+.local': 'system'                     # 本地域名使用系统 DNS
```

#### 方法 2：指定传统 DNS 服务器

为特定域名指定传统 DNS 服务器，配合规则可以实现类似效果：

```yaml
dns:
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - 223.5.5.5                            # 传统 DNS 备用
  nameserver-policy:
    # 指定域名使用传统 DNS
    '+.xdf.cn': '223.5.5.5'
    '+.test.xdf.cn': '119.29.29.29'
```

**注意：** 在 fake-ip 模式下，即使指定了 DNS 服务器，Clash 仍然可能使用 fake-ip。如果需要完全禁用 fake-ip 对某些域名的使用，建议：

1. **使用系统 DNS**：通过 `nameserver-policy` 设置为 `system`
2. **全局切换模式**：如果大量域名需要真实 IP，考虑切换到 `redir-host` 模式
3. **混合模式**：为需要真实 IP 的域名使用系统 DNS，其他域名继续使用 fake-ip

#### 完整示例：指定域名不使用 fake-ip

```yaml
dns:
  enable: true
  ipv6: false
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip                  # 全局使用 fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  fallback:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
  nameserver-policy:
    # 这些域名不使用 fake-ip，使用系统 DNS 获取真实 IP
    '+.xdf.cn': 'system'                   # 企业域名
    '+.test.xdf.cn': 'system'              # 测试环境
    '+.internal.company.com': 'system'     # 内网域名
    '+.lan': 'system'                      # 本地网络
    '+.local': 'system'                    # 本地域名
    # 其他域名继续使用 fake-ip
```

**验证方法：**

```bash
# 测试域名解析（应该返回真实 IP，而不是 fake-ip-range 范围内的 IP）
nslookup teston.test.xdf.cn 127.0.0.1

# 查看解析结果，IP 应该在 fake-ip-range (198.18.0.1/16) 之外
dig teston.test.xdf.cn @127.0.0.1
```

## 完整配置示例

### 基础配置（推荐）

```yaml
dns:
  enable: true
  ipv6: false
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
    - tls://dns.rubyfish.cn:853
  fallback:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - tls://1.1.1.1:853
    - tls://8.8.8.8:853
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4
    domain:
      - '+.google.com'
      - '+.facebook.com'
      - '+.youtube.com'
      - '+.twitter.com'
      - '+.instagram.com'
      - '+.tiktok.com'
```

### 高级配置（自定义策略）

```yaml
dns:
  enable: true
  listen: 0.0.0.0:53
  ipv6: false
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
    - tls://dns.rubyfish.cn:853
  fallback:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - tls://1.1.1.1:853
    - tls://8.8.8.8:853
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4
    domain:
      - '+.google.com'
      - '+.facebook.com'
      - '+.youtube.com'
  nameserver-policy:
    # 内网域名使用本地 DNS
    '+.lan': '192.168.1.1'
    '+.local': '192.168.1.1'
    '+.internal.company.com': '10.0.0.1'
    # 特定域名使用特定 DNS
    'www.baidu.com': '223.5.5.5'
```

## 配置优化建议

### 1. 选择合适的 DNS 模式

- **日常使用**：推荐使用 `fake-ip` 模式，性能更好
- **调试场景**：使用 `redir-host` 模式，便于查看真实 IP

### 2. DNS 服务器选择

- **nameserver**：优先使用国内 DNS（DoH/DoT），速度快
- **fallback**：使用国外 DNS（DoH/DoT），用于解析被污染域名
- **协议选择**：优先使用 DoH/DoT，比传统 DNS 更安全

### 3. fallback-filter 配置

- **geoip**：启用后，非 CN IP 会使用 fallback DNS
- **domain**：明确指定需要代理的域名，提高效率
- **ipcidr**：过滤保留地址段，避免误判

### 4. 性能优化

- 将响应快的 DNS 服务器放在前面
- 合理配置 fallback-filter，减少不必要的 fallback 查询
- 使用 nameserver-policy 为常用域名指定 DNS

## 常见问题

### 1. DNS 解析慢

**原因：**
- DNS 服务器响应慢
- fallback 查询过多

**解决方案：**
- 更换更快的 DNS 服务器
- 优化 fallback-filter 配置
- 将常用域名添加到 nameserver-policy

### 2. 某些网站无法访问

**原因：**
- DNS 污染
- fallback 配置不当

**解决方案：**
- 将域名添加到 fallback-filter.domain
- 使用 nameserver-policy 指定 DNS
- 检查代理规则配置

### 3. 内网域名无法解析

**原因：**
- 内网域名被 fallback 处理

**解决方案：**
- 使用 nameserver-policy 为内网域名指定本地 DNS
- 在 fallback-filter 中排除内网域名

### 4. 如何指定某些域名不使用 fake-ip

**需求场景：**
- 某些域名需要真实 IP 地址（如企业内网、测试环境）
- 某些应用需要真实 IP 才能正常工作
- 调试时需要查看真实 IP 地址

**解决方案：**

#### 方法 1：使用系统 DNS（最推荐）

在 `nameserver-policy` 中为特定域名指定使用系统 DNS，这样可以绕过 fake-ip：

```yaml
dns:
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
  nameserver-policy:
    # 这些域名使用系统 DNS，不使用 fake-ip
    '+.xdf.cn': 'system'
    '+.test.xdf.cn': 'system'
    '+.internal.company.com': 'system'
    '+.lan': 'system'
    '+.local': 'system'
```

#### 方法 2：全局切换到 redir-host 模式

如果大量域名需要真实 IP，可以全局切换：

```yaml
dns:
  enhanced-mode: redir-host  # 全局使用真实 IP
  # ... 其他配置 ...
```

#### 方法 3：混合配置

为需要真实 IP 的域名使用系统 DNS，其他域名继续使用 fake-ip：

```yaml
dns:
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  nameserver-policy:
    # 需要真实 IP 的域名
    '+.xdf.cn': 'system'
    '+.test.xdf.cn': 'system'
    # 其他域名继续使用 fake-ip
```

**验证方法：**

```bash
# 测试域名解析，IP 应该在 fake-ip-range (198.18.0.1/16) 之外
nslookup teston.test.xdf.cn 127.0.0.1
dig teston.test.xdf.cn @127.0.0.1

# 如果返回的 IP 在 198.18.0.0/16 范围内，说明仍在使用 fake-ip
# 如果返回真实 IP，说明配置成功
```

### 5. DNS 解析失败：couldn't find ip

**错误示例：**
```
[TCP] dial DIRECT error: dns resolve failed: couldn't find ip
```

**原因分析：**
- 在 `fake-ip` 模式下，某些特殊域名（如测试环境域名、企业内网域名）可能无法正确解析
- DNS 服务器无法解析该域名（可能是内网域名或特殊配置的域名）
- fallback-filter 配置不当，导致域名被错误过滤
- nameserver 和 fallback 都无法解析该域名
- **Clash Verge 特殊问题**：`direct-nameserver-follow-policy: false` 可能导致 DIRECT 规则不遵循 nameserver-policy

**解决方案：**

#### 方案 1：使用 nameserver-policy 指定 DNS（推荐）

为特定域名指定能够解析的 DNS 服务器：

```yaml
dns:
  # ... 其他配置 ...
  nameserver-policy:
    # 为 xdf.cn 及其子域名指定 DNS
    '+.xdf.cn': '223.5.5.5'              # 使用阿里 DNS
    '+.test.xdf.cn': '119.29.29.29'      # 测试环境使用腾讯 DNS
    'teston.test.xdf.cn': '223.5.5.5'    # 特定域名指定 DNS
```

#### 方案 2：切换到 redir-host 模式

如果域名需要真实 IP 解析，可以切换到 `redir-host` 模式：

```yaml
dns:
  enhanced-mode: redir-host  # 从 fake-ip 切换到 redir-host
  # ... 其他配置 ...
```

或者为特定域名使用 redir-host：

```yaml
dns:
  enhanced-mode: fake-ip
  # ... 其他配置 ...
  nameserver-policy:
    '+.xdf.cn': '223.5.5.5'
```

#### 方案 3：添加传统 DNS 作为备用

确保 nameserver 中包含传统 DNS（UDP），某些特殊域名可能无法通过 DoH/DoT 解析：

```yaml
dns:
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
    - 223.5.5.5                    # 添加传统 DNS
    - 119.29.29.29                 # 添加传统 DNS
    - 114.114.114.114              # 添加传统 DNS
```

#### 方案 4：检查并调整 fallback-filter

如果域名被误过滤，需要调整 fallback-filter：

```yaml
dns:
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4
    domain:
      - '+.google.com'
      # 如果 xdf.cn 需要走代理，添加到 domain 列表
      # 如果不需要走代理，确保不在 domain 列表中
```

#### 方案 5：使用系统 DNS 作为备用

如果上述方案都不行，可以配置使用系统 DNS：

```yaml
dns:
  nameserver:
    - https://doh.pub/dns-query
    - system                        # 使用系统 DNS
  # 或者
  default-nameserver:
    - system                        # 默认使用系统 DNS
```

#### 完整示例配置

针对 `teston.test.xdf.cn` 无法解析的问题，推荐配置：

```yaml
dns:
  enable: true
  ipv6: false
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
    - 223.5.5.5                    # 传统 DNS 备用
    - 119.29.29.29                 # 传统 DNS 备用
  fallback:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - tls://1.1.1.1:853
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4
    domain:
      - '+.google.com'
      - '+.facebook.com'
  nameserver-policy:
    # 为 xdf.cn 域名指定 DNS
    '+.xdf.cn': '223.5.5.5'
    '+.test.xdf.cn': '119.29.29.29'
```

**调试步骤：**

1. **测试 DNS 解析**：
   ```bash
   # 测试域名是否能解析
   nslookup teston.test.xdf.cn 223.5.5.5
   dig teston.test.xdf.cn @223.5.5.5
   ```

2. **查看 Clash 日志**：
   - 查看 DNS 查询记录
   - 确认域名使用了哪个 DNS 服务器
   - 检查是否有错误信息

3. **逐步排查**：
   - 先尝试方案 1（nameserver-policy）
   - 如果不行，尝试方案 2（切换模式）
   - 最后尝试方案 3（添加传统 DNS）

## 配置解析示例

下面是一个实际使用的 Clash DNS 配置示例，我们来详细解析每个配置项的作用：

```yaml
dns:
  default-nameserver:
    - 223.5.5.5
    - 8.8.8.8
  direct-nameserver-follow-policy: false
  enable: true
  enhanced-mode: fake-ip
  fake-ip-filter:
    # - "+.xdf.cn"
    - "+.yclassroom.com"
    - '+.rb.sys'
    - "*.lan"
    - "*.local"
    - "*.arpa"
    - time.*.com
    - ntp.*.com
    - "*.msftncsi.com"
    - www.msftconnecttest.com
  fake-ip-filter-mode: blacklist
  fake-ip-range: 198.18.0.1/16
  fallback:
    - 10.200.150.211
    - 10.200.150.212
    - https://dns.alidns.com/dns-query
    - https://dns.google/dns-query
    - https://cloudflare-dns.com/dns-query
  fallback-filter:
    geoip: true
    geoip-code: CN
    ipcidr:
      - 240.0.0.0/4
      - 0.0.0.0/32
  listen: :53
  nameserver:
    # - 10.200.150.211
    # - 10.200.150.212
    - 8.8.8.8
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  prefer-h3: false
  proxy-server-nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query
  respect-rules: false
  use-hosts: false
  use-system-hosts: false
  nameserver-policy:
    '+.xdf.cn': 'system'
```

### 配置项详细解析

#### 1. 基础配置

```yaml
enable: true                    # 启用 DNS 功能
listen: :53                     # DNS 监听所有网络接口的 53 端口
enhanced-mode: fake-ip          # 使用 fake-ip 模式，提升性能
fake-ip-range: 198.18.0.1/16    # fake-ip 地址范围
```

**说明：**
- `listen: :53` 表示监听所有网络接口的 53 端口，其他设备可以将 DNS 设置为该服务器
- `enhanced-mode: fake-ip` 使用 fake-ip 模式，为域名分配假 IP，提升解析速度

#### 2. default-nameserver（默认 DNS 服务器）

```yaml
default-nameserver:
  - 223.5.5.5                   # 阿里 DNS
  - 8.8.8.8                     # Google DNS
```

**作用：**
- 用于解析 DNS 服务器本身的域名（如 DoH/DoT 服务器的域名）
- 当 nameserver 和 fallback 中的 DNS 服务器域名需要解析时使用
- 作为最后的备用 DNS

#### 3. fake-ip-filter（fake-ip 过滤列表）

```yaml
fake-ip-filter:
  # - "+.xdf.cn"                # 已注释，不使用 fake-ip
  - "+.yclassroom.com"           # yclassroom.com 及其子域名不使用 fake-ip
  - '+.rb.sys'                   # rb.sys 及其子域名不使用 fake-ip
  - "*.lan"                      # 所有 .lan 域名不使用 fake-ip
  - "*.local"                    # 所有 .local 域名不使用 fake-ip
  - "*.arpa"                     # 所有 .arpa 域名不使用 fake-ip
  - time.*.com                   # time.*.com 域名不使用 fake-ip
  - ntp.*.com                    # ntp.*.com 域名不使用 fake-ip
  - "*.msftncsi.com"             # Windows 网络连接测试域名
  - www.msftconnecttest.com      # Windows 网络连接测试域名
fake-ip-filter-mode: blacklist  # 黑名单模式
```

**作用：**
- **黑名单模式**：列表中的域名**不使用** fake-ip，使用真实 IP
- 这些域名通常是：
  - 内网域名（`.lan`, `.local`, `.arpa`）
  - 企业内网域名（`yclassroom.com`, `rb.sys`）
  - 时间同步服务（`time.*.com`, `ntp.*.com`）
  - Windows 网络测试域名（`msftncsi.com`, `msftconnecttest.com`）

**注意：**
- `+.xdf.cn` 被注释掉了，说明 `xdf.cn` 域名会使用 fake-ip
- 但通过 `nameserver-policy` 配置，`xdf.cn` 会使用系统 DNS，实际效果类似

#### 4. nameserver（普通域名 DNS 服务器）

```yaml
nameserver:
  # - 10.200.150.211            # 内网 DNS，已注释
  # - 10.200.150.212            # 内网 DNS，已注释
  - 8.8.8.8                      # Google DNS（传统 UDP）
  - https://doh.pub/dns-query    # 腾讯 DoH
  - https://dns.alidns.com/dns-query  # 阿里 DoH
```

**作用：**
- 用于解析普通域名（国内域名、未被污染的域名）
- 优先使用 DoH（DNS over HTTPS），更安全
- 包含传统 DNS（8.8.8.8）作为备用
- 内网 DNS（10.200.150.211/212）被注释，可能因为网络环境变化

#### 5. fallback（回退 DNS 服务器）

```yaml
fallback:
  - 10.200.150.211              # 内网 DNS 1
  - 10.200.150.212              # 内网 DNS 2
  - https://dns.alidns.com/dns-query    # 阿里 DoH
  - https://dns.google/dns-query        # Google DoH
  - https://cloudflare-dns.com/dns-query # Cloudflare DoH
```

**作用：**
- 用于解析被污染的域名或无法通过 nameserver 解析的域名
- **注意**：内网 DNS 放在最前面，说明优先使用内网 DNS 解析
- 如果内网 DNS 无法解析，再使用公共 DNS（阿里、Google、Cloudflare）

#### 6. fallback-filter（回退过滤规则）

```yaml
fallback-filter:
  geoip: true                    # 启用 GeoIP 过滤
  geoip-code: CN                 # 如果 IP 不在中国，使用 fallback
  ipcidr:
    - 240.0.0.0/4                # 保留地址段（多播地址）
    - 0.0.0.0/32                  # 无效地址
```

**作用：**
- `geoip: true` + `geoip-code: CN`：如果解析出的 IP 不在中国，会使用 fallback DNS 重新解析
- `ipcidr`：如果解析出的 IP 在这些地址段内，也会使用 fallback DNS
- 这样可以确保被污染的域名能够正确解析

#### 7. nameserver-policy（域名策略）

```yaml
nameserver-policy:
  '+.xdf.cn': 'system'           # xdf.cn 及其子域名使用系统 DNS
```

**作用：**
- 为 `xdf.cn` 及其所有子域名指定使用系统 DNS
- 优先级最高，会覆盖其他 DNS 配置
- 这样可以确保 `xdf.cn` 域名使用真实 IP，不使用 fake-ip

#### 8. 高级配置选项

```yaml
direct-nameserver-follow-policy: false  # DIRECT 规则不遵循 nameserver-policy
prefer-h3: false                        # 不使用 HTTP/3
proxy-server-nameserver:                # 代理服务器域名解析使用的 DNS
  - https://doh.pub/dns-query
  - https://dns.alidns.com/dns-query
respect-rules: false                    # DNS 解析不遵循代理规则
use-hosts: false                        # 不使用 /etc/hosts 文件
use-system-hosts: false                  # 不使用系统 hosts 文件
```

**详细说明：**

- **`direct-nameserver-follow-policy: false`**
  - 当流量匹配 DIRECT 规则时，不使用 nameserver-policy 指定的 DNS
  - 直接使用 nameserver 或 fallback 中的 DNS

- **`prefer-h3: false`**
  - 不使用 HTTP/3 协议进行 DNS 查询
  - 使用 HTTP/2 或 HTTP/1.1

- **`proxy-server-nameserver`**
  - 专门用于解析代理服务器（如 Shadowsocks、VMess 等）的域名
  - 确保代理服务器地址能够正确解析

- **`respect-rules: false`**
  - DNS 查询不遵循代理规则
  - DNS 查询会直接进行，不会通过代理

- **`use-hosts: false`** 和 **`use-system-hosts: false`**
  - 不使用本地 hosts 文件
  - 所有域名都通过配置的 DNS 服务器解析

### 配置特点总结

这个配置的特点：

1. **混合 DNS 环境**
   - 同时使用内网 DNS（10.200.150.211/212）和公共 DNS
   - 适合企业内网环境

2. **fake-ip 黑名单**
   - 内网域名、时间服务、Windows 测试域名不使用 fake-ip
   - 确保这些服务使用真实 IP

3. **域名策略**
   - `xdf.cn` 使用系统 DNS，确保正确解析
   - 其他域名使用 fake-ip，提升性能

4. **GeoIP 过滤**
   - 自动检测被污染的域名（IP 不在中国）
   - 使用 fallback DNS 重新解析

5. **安全性**
   - 优先使用 DoH（DNS over HTTPS）
   - 避免 DNS 查询被监听和篡改

### 配置优化建议

1. **如果内网 DNS 不可用**
   - 取消注释 `nameserver` 中的内网 DNS
   - 或者从 `fallback` 中移除内网 DNS

2. **如果需要使用 hosts 文件**
   - 设置 `use-hosts: true` 或 `use-system-hosts: true`
   - 可以在 hosts 文件中配置本地域名映射

3. **如果需要更快的解析**
   - 将响应快的 DNS 服务器放在前面
   - 考虑启用 `prefer-h3: true`（如果 DNS 服务器支持）

4. **如果需要调试**
   - 临时将 `enhanced-mode` 改为 `redir-host`
   - 可以查看真实 IP 地址

## 测试 DNS 配置

### 1. 检查 DNS 解析

```bash
# 使用 dig 命令测试
dig @127.0.0.1 -p 53 www.google.com

# 使用 nslookup 测试
nslookup www.google.com 127.0.0.1
```

### 2. 查看 Clash 日志

在 Clash 日志中查看 DNS 查询记录，确认配置是否生效。

### 3. 测试不同域名

- 测试国内域名（如 baidu.com）
- 测试国外域名（如 google.com）
- 测试内网域名（如 .lan 域名）

## 总结

正确配置 Clash DNS 可以：
- ✅ 提升访问速度
- ✅ 避免 DNS 污染
- ✅ 提高代理效果
- ✅ 优化网络体验

建议根据实际网络环境和使用需求，调整 DNS 配置参数，找到最适合的配置方案。

