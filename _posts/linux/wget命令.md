---
author: djaigo
title: linux-wget命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
  - network
---

`wget` 是 Linux 中用于从网络下载文件的命令行工具。它支持 HTTP、HTTPS 和 FTP 协议，可以递归下载、断点续传等功能。

```sh
➜ wget --help
GNU Wget 1.21.3，非交互式网络文件下载工具。
用法: wget [选项]... [URL]...

启动:
  -V,  --version           显示 Wget 的版本信息并退出
  -h,  --help              打印此帮助
  -b,  --background        启动后转入后台
  -e,  --execute=COMMAND   执行 `.wgetrc' 格式的命令

日志和输入文件:
  -o,  --output-file=FILE    将日志信息写入 FILE
  -a,  --append-output=FILE  将日志信息追加到 FILE
  -d,  --debug               打印大量调试信息
  -q,  --quiet               安静模式(无输出)
  -v,  --verbose             详述输出(此为默认值)
  -nv, --no-verbose          关闭详述输出，但不进入安静模式
       --report-speed=TYPE    以 TYPE 为单位报告带宽。TYPE 可以是 bits
  -i,  --input-file=FILE     从本地或外部 FILE 中读取 URL
  -F,  --force-html          把输入文件当作 HTML 处理
  -B,  --base=URL            解析 HTML 输入文件时(由 -i -F 选项指定)使用 URL 作为基础

下载:
  -t,  --tries=NUMBER        设置重试次数为 NUMBER (0 表示无限制)
       --retry-connrefused    即使拒绝连接也重试
  -O,  --output-document=FILE    将文档写入 FILE
  -nc, --no-clobber           不要下载已存在的文件
  -c,  --continue             断点续传下载文件
       --progress=TYPE        选择进度条类型
  -S,  --server-response      打印服务器响应
       --spider               不下载任何文件
  -T,  --timeout=SECONDS      将所有超时设为 SECONDS 秒
       --dns-timeout=SECS      设置 DNS 查询超时为 SECS 秒
       --connect-timeout=SECS  设置连接超时为 SECS 秒
       --read-timeout=SECS     设置读取超时为 SECS 秒
  -w,  --wait=SECONDS         等待间隔为 SECONDS 秒
       --waitretry=SECONDS    在获取文件的重试之间等待 1...SECONDS 秒
       --random-wait          在获取文件时等待 0.5...1.5 * WAIT 秒
       --no-proxy             明确禁止使用代理
  -Q,  --quota=NUMBER         设置下载配额为 NUMBER 字节
       --bind-address=ADDRESS 绑定至本地主机上的 ADDRESS (主机名或 IP)
  -4,  --inet4-only           仅连接至 IPv4 地址
  -6,  --inet6-only           仅连接至 IPv6 地址
       --prefer-family=FAMILY 首先连接指定地址族: IPv4, IPv6 或 none
       --user=USER            将 ftp 和 http 的用户名均设置为 USER
       --password=PASS        将 ftp 和 http 的密码均设置为 PASS
       --ask-password         提示输入密码
       --no-iri               关闭 IRI 支持
       --local-encoding=ENC   使用 ENC 作为本地编码
       --remote-encoding=ENC  使用 ENC 作为远程编码
       --unlink               删除文件前先解除其链接

目录:
  -nd, --no-directories          不创建目录
  -x,  --force-directories       强制创建目录
  -nH, --no-host-directories     不要创建主目录
       --protocol-directories    在目录名中使用协议名称
  -P,  --directory-prefix=PREFIX 保存文件到 PREFIX/...
       --cut-dirs=NUMBER         忽略远程目录中 NUMBER 个目录层

HTTP 选项:
  --http-user=USER        设置 http 用户名为 USER
  --http-password=PASS   设置 http 密码为 PASS
  --no-cache              不在服务器上缓存数据
  --default-page=NAME     改变默认页面名称(通常是 "index.html")
  -E,  --adjust-extension  以合适的扩展名保存 HTML/CSS 文件
  --ignore-length         忽略头部的 `Content-Length' 字段
  --header=STRING         在头部插入 STRING
  --max-redirect          每页所允许的最大重定向数
  --proxy-user=USER       使用 USER 作为代理用户名
  --proxy-password=PASS   使用 PASS 作为代理密码
  --referer=URL           在 HTTP 请求头中包含 `Referer: URL'
  --save-headers          保存 HTTP 头到文件
  -U,  --user-agent=AGENT  标识为 AGENT 而不是 Wget/VERSION
  --no-http-keep-alive    禁用 HTTP keep-alive (持久连接)
  --no-cookies            不使用 cookies
       --load-cookies=FILE  会话开始前从 FILE 中载入 cookies
       --save-cookies=FILE  会话结束后保存 cookies 到 FILE
  --keep-session-cookies  载入和保存会话(非永久) cookies
  --method=HTTPMethod     使用 HTTP 方法
       --body-data=STRING       使用 STRING 作为请求体
       --body-file=FILE         使用 FILE 中的内容作为请求体
       --content-disposition     当选择本地文件名时允许 Content-Disposition 头部(实验性)
       --content-on-error        输出服务器错误时接收到的内容
       --auth-no-challenge       发送基本 HTTP 认证信息而无需先等待服务器的质询

HTTPS (SSL/TLS) 选项:
       --secure-protocol=PR    选择安全协议，可以是 auto、SSLv2、
                               SSLv3、TLSv1、TLSv1_1、TLSv1_2 或 PFS
       --no-check-certificate   不要验证服务器的证书
       --certificate=FILE       客户端证书文件
       --certificate-type=TYPE  客户端证书类型，PEM 或 DER
       --private-key=FILE       私钥文件
       --private-key-type=TYPE  私钥文件类型，PEM 或 DER
       --ca-certificate=FILE    包含 CA 证书的文件
       --ca-directory=DIR       包含 CA 证书的目录
       --crl-file=FILE          包含 CRL 的文件
       --pinnedpubkey=FILE/PUBLICKEYFILE 使用 FILE 或 PUBLICKEYFILE 中的公钥(PEM/DER)来验证服务器

HSTS 选项:
       --no-hsts                禁用 HSTS
       --hsts-file               HSTS 数据库路径(将覆盖默认值)

FTP 选项:
  --ftp-user=USER        设置 ftp 用户名为 USER
  --ftp-password=PASS    设置 ftp 密码为 PASS
  --no-remove-listing    不要删除 `.listing' 文件
  --no-glob               不在 FTP 文件名中使用通配符展开
  --no-passive-ftp        禁用"被动"传输模式
  --preserve-permissions  保留远程文件的权限
  --retr-symlinks         递归目录时，获取链接指向的文件(而非目录)

递归下载:
  -r,  --recursive         指定递归下载
  -l,  --level=NUMBER      最大递归深度(inf 或 0 表示无限制，即全部下载)
       --delete-after      下载完成后删除本地文件
  -k,  --convert-links     转换文档中的链接使其适合本地查看
  -K,  --backup-converted  转换链接 X 前先备份文件为 X.orig
  -m,  --mirror            打开适合镜像的选项(-r -N -l inf --no-remove-listing)
  -p,  --page-requisites   下载所有用于显示 HTML 页面的图片等元素
       --strict-comments   用严格(SGML)模式处理 HTML 注释

递归接受/拒绝:
  -A,  --accept=LIST               逗号分隔的可接受扩展名列表
  -R,  --reject=LIST               逗号分隔的拒绝扩展名列表
       --accept-regex=REGEX        匹配接受的 URL 的正则表达式
       --reject-regex=REGEX        匹配拒绝的 URL 的正则表达式
  -D,  --domains=LIST              逗号分隔的可接受域名列表
       --exclude-domains=LIST      逗号分隔的拒绝域名列表
       --follow-ftp                跟踪 HTML 文档中的 FTP 链接
       --follow-tags=LIST          逗号分隔的 HTML 标签列表，wget 会跟踪这些标签中的链接
       --ignore-tags=LIST          逗号分隔的 HTML 标签列表，wget 会忽略这些标签中的链接
  -H,  --span-hosts                递归时转向外部主机
  -L,  --relative                  仅跟踪相对链接
  -I,  --include-directories=LIST  允许目录的列表
  -X,  --exclude-directories=LIST  拒绝目录的列表
  -np, --no-parent                 不追溯至父目录
```

# 基本语法

```sh
wget [选项] [URL...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-O, --output-document=FILE` | 指定输出文件名 |
| `-P, --directory-prefix=PREFIX` | 指定保存目录 |
| `-c, --continue` | 断点续传 |
| `-r, --recursive` | 递归下载 |
| `-l, --level=NUMBER` | 递归深度 |
| `-k, --convert-links` | 转换链接 |
| `-p, --page-requisites` | 下载页面所需的所有文件 |
| `-np, --no-parent` | 不追溯至父目录 |
| `-t, --tries=NUMBER` | 重试次数 |
| `-T, --timeout=SECONDS` | 超时时间 |
| `-w, --wait=SECONDS` | 下载间隔 |
| `--limit-rate=RATE` | 限制下载速度 |
| `-q, --quiet` | 安静模式 |
| `-v, --verbose` | 详细输出 |
| `-i, --input-file=FILE` | 从文件读取 URL |
| `--user=USER` | 设置用户名 |
| `--password=PASS` | 设置密码 |
| `--no-check-certificate` | 不验证 SSL 证书 |

# 基本使用

## 下载文件

```sh
# 基本下载
➜ wget http://example.com/file.zip

# 指定输出文件名
➜ wget -O output.zip http://example.com/file.zip

# 指定保存目录
➜ wget -P /path/to/save http://example.com/file.zip

# 断点续传
➜ wget -c http://example.com/largefile.zip

# 不覆盖已存在的文件
➜ wget -nc http://example.com/file.zip
```

## 递归下载

```sh
# 递归下载整个网站
➜ wget -r http://example.com

# 限制递归深度
➜ wget -r -l 2 http://example.com

# 递归下载并转换链接
➜ wget -r -k http://example.com

# 下载页面所需的所有文件（图片、CSS等）
➜ wget -p http://example.com/page.html
```

## 批量下载

```sh
# 从文件读取 URL 列表
➜ wget -i urls.txt

# urls.txt 内容：
# http://example.com/file1.zip
# http://example.com/file2.zip
```

## 限制下载速度

```sh
# 限制下载速度为 200KB/s
➜ wget --limit-rate=200k http://example.com/file.zip

# 限制为 1MB/s
➜ wget --limit-rate=1m http://example.com/file.zip
```

## 认证下载

```sh
# HTTP 基本认证
➜ wget --user=username --password=password http://example.com/file.zip

# 交互式输入密码
➜ wget --user=username --ask-password http://example.com/file.zip

# FTP 下载
➜ wget --ftp-user=user --ftp-password=pass ftp://example.com/file.zip
```

# 实际应用场景

## 下载文件

```sh
# 下载软件包
➜ wget https://example.com/software.tar.gz

# 下载并解压
➜ wget -O - http://example.com/file.tar.gz | tar -xzf -
```

## 镜像网站

```sh
# 镜像整个网站
➜ wget -mk -np http://example.com

# 只下载特定类型的文件
➜ wget -r -A "*.pdf,*.doc" http://example.com
```

## 定时下载

```sh
# 在脚本中使用 wget
#!/bin/bash
while true; do
    wget http://example.com/data.json
    sleep 3600  # 每小时下载一次
done
```

## 使用代理

```sh
# 使用 HTTP 代理
➜ wget --proxy=on --http-proxy=proxy.example.com:8080 http://example.com

# 使用代理认证
➜ wget --proxy-user=user --proxy-password=pass \
  --http-proxy=proxy.example.com:8080 http://example.com
```

# 高级用法

## 下载选项

```sh
# 设置重试次数
➜ wget -t 5 http://example.com/file.zip

# 设置超时时间
➜ wget -T 30 http://example.com/file.zip

# 下载间隔（避免对服务器造成压力）
➜ wget -w 2 http://example.com/file.zip
```

## 递归下载控制

```sh
# 只下载特定类型的文件
➜ wget -r -A "*.jpg,*.png" http://example.com

# 排除特定类型的文件
➜ wget -r -R "*.html,*.htm" http://example.com

# 只下载特定目录
➜ wget -r -I /images http://example.com

# 排除特定目录
➜ wget -r -X /tmp,/cache http://example.com
```

## 后台下载

```sh
# 后台下载
➜ wget -b http://example.com/largefile.zip

# 查看下载日志
➜ tail -f wget-log
```

# 注意事项

1. **递归下载**：使用 `-r` 时要小心，可能下载大量文件
2. **服务器压力**：使用 `-w` 选项避免对服务器造成过大压力
3. **SSL 证书**：生产环境不要使用 `--no-check-certificate`
4. **权限**：某些文件可能需要认证才能下载

# 参考文献
* [GNU Wget 官方文档](https://www.gnu.org/software/wget/manual/)

