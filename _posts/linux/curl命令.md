---
author: djaigo
title: linux-curl命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/linux.png'
categories:
  - linux
tags:
  - shell
  - network
---

`curl` 是一个强大的命令行工具，用于传输数据，支持多种协议（HTTP、HTTPS、FTP、SFTP等）。它是 Linux 系统中最常用的网络工具之一。

```sh
➜ curl --help
Usage: curl [options...] <url>
 -d, --data <data>          HTTP POST data
 -f, --fail                 Fail silently (no output at all) on HTTP errors
 -h, --help <category>      Get help for commands
 -i, --include              Include protocol response headers in the output
 -o, --output <file>        Write to file instead of stdout
 -O, --remote-name          Write output to a file named as the remote file
 -s, --silent               Silent mode
 -T, --upload-file <file>   Transfer local FILE to destination
 -u, --user <user:password> Server user and password
 -A, --user-agent <name>    Send User-Agent <name> to server
 -v, --verbose              Make the operation more talkative
 -w, --write-out <format>   Use output format after completion
 -x, --proxy <[protocol://]host[:port]> Use proxy on given port
 -L, --location             Follow redirects
 -H, --header <header>      Pass custom header(s) to server
 -X, --request <command>    Specify request command to use
```

# 基本语法

```sh
curl [选项] [URL...]
```

# 常用选项

| 选项 | 说明 |
|------|------|
| `-X, --request <method>` | 指定 HTTP 方法（GET、POST、PUT、DELETE等） |
| `-d, --data <data>` | 发送 POST 数据 |
| `-H, --header <header>` | 添加 HTTP 头 |
| `-i, --include` | 显示响应头 |
| `-I, --head` | 只显示响应头 |
| `-o, --output <file>` | 保存到文件 |
| `-O, --remote-name` | 使用远程文件名保存 |
| `-L, --location` | 跟随重定向 |
| `-u, --user <user:pass>` | 基本认证 |
| `-v, --verbose` | 详细输出 |
| `-s, --silent` | 静默模式 |
| `-w, --write-out <format>` | 输出格式 |
| `-x, --proxy <proxy>` | 使用代理 |
| `-c, --cookie-jar <file>` | 保存 cookie |
| `-b, --cookie <data>` | 发送 cookie |
| `-k, --insecure` | 忽略 SSL 证书错误 |
| `--compressed` | 请求压缩响应 |

# 基本使用

## GET 请求

```sh
# 基本 GET 请求
➜ curl http://example.com

# 显示响应头
➜ curl -i http://example.com

# 只显示响应头
➜ curl -I http://example.com

# 跟随重定向
➜ curl -L http://example.com
```

## POST 请求

```sh
# POST 请求（表单数据）
➜ curl -X POST -d "name=value" http://example.com/api

# POST JSON 数据
➜ curl -X POST -H "Content-Type: application/json" \
  -d '{"key":"value"}' http://example.com/api

# POST 文件
➜ curl -X POST -F "file=@/path/to/file" http://example.com/upload
```

## 下载文件

```sh
# 下载文件（使用远程文件名）
➜ curl -O http://example.com/file.zip

# 下载文件（指定本地文件名）
➜ curl -o output.zip http://example.com/file.zip

# 断点续传
➜ curl -C - -O http://example.com/largefile.zip

# 限制下载速度
➜ curl --limit-rate 1M -O http://example.com/file.zip
```

## 认证

```sh
# 基本认证
➜ curl -u username:password http://example.com

# Bearer Token
➜ curl -H "Authorization: Bearer token" http://example.com/api

# Cookie 认证
➜ curl -b "session=abc123" http://example.com
```

## 自定义请求头

```sh
# 添加自定义头
➜ curl -H "User-Agent: MyApp/1.0" \
  -H "Accept: application/json" \
  http://example.com/api
```

# 实际应用场景

## API 测试

```sh
# 测试 REST API
➜ curl -X GET http://api.example.com/users

# 创建资源
➜ curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"John"}' http://api.example.com/users

# 更新资源
➜ curl -X PUT -H "Content-Type: application/json" \
  -d '{"name":"Jane"}' http://api.example.com/users/1

# 删除资源
➜ curl -X DELETE http://api.example.com/users/1
```

## 文件上传

```sh
# 上传文件
➜ curl -X POST -F "file=@/path/to/file.txt" \
  http://example.com/upload

# 上传多个文件
➜ curl -X POST \
  -F "file1=@file1.txt" \
  -F "file2=@file2.txt" \
  http://example.com/upload
```

## 监控和测试

```sh
# 测试网站响应时间
➜ curl -o /dev/null -s -w "Time: %{time_total}s\n" \
  http://example.com

# 测试 HTTPS
➜ curl -k https://example.com

# 查看详细请求过程
➜ curl -v http://example.com
```

## 使用代理

```sh
# HTTP 代理
➜ curl -x http://proxy.example.com:8080 http://example.com

# SOCKS5 代理
➜ curl --socks5 proxy.example.com:1080 http://example.com
```

## 保存 Cookie

```sh
# 保存 cookie
➜ curl -c cookies.txt http://example.com/login

# 使用 cookie
➜ curl -b cookies.txt http://example.com/dashboard
```

# 高级用法

## 输出格式

```sh
# 显示响应时间
➜ curl -w "Time: %{time_total}s\n" -o /dev/null -s http://example.com

# 显示更多信息
➜ curl -w "\nTime: %{time_total}s\nSize: %{size_download} bytes\n" \
  -o /dev/null -s http://example.com
```

## 批量请求

```sh
# 从文件读取 URL
➜ curl -K urls.txt

# urls.txt 内容：
# url = "http://example.com/1"
# url = "http://example.com/2"
```

## 压缩传输

```sh
# 请求压缩响应
➜ curl --compressed http://example.com
```

# 常见问题

## SSL 证书错误

```sh
# 忽略 SSL 证书错误（不推荐，仅用于测试）
➜ curl -k https://example.com
```

## 超时设置

```sh
# 设置连接超时
➜ curl --connect-timeout 10 http://example.com

# 设置总超时
➜ curl --max-time 30 http://example.com
```

## 重试

```sh
# 失败时重试
➜ curl --retry 3 http://example.com

# 重试间隔
➜ curl --retry 3 --retry-delay 5 http://example.com
```

# 参考文献
* [curl 官方文档](https://curl.se/docs/)
* [curl 手册页](https://curl.se/docs/manual.html)

