---
author: djaigo
title: linux watch命令
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - linux
tags:
  - cmd
  - command
date: 2020-01-15 10:09:36
updated: 2020-01-15
enable html: false
---

watch 是监视某个shell命令控制台输出。
```text
Usage:
 watch [options] command

Options:
  -b, --beep             beep if command has a non-zero exit
  -c, --color            interpret ANSI color and style sequences
  -d, --differences[=&lt;permanent&gt;]
                         highlight changes between updates
  -e, --errexit          exit if command has a non-zero exit
  -g, --chgexit          exit when output from command changes
  -n, --interval &lt;secs&gt;  seconds to wait between updates
  -p, --precise          attempt run command in precise intervals
  -t, --no-title         turn off header
  -x, --exec             pass command to exec instead of "sh -c"

 -h, --help     display this help and exit
 -v, --version  output version information and exit

```

参数说明：

| 选项 | 说明 |
| --- | --- |
|`-b, --beep`|忽略命令有非零返回码| 
|`-c, --color`|  解释ANSI颜色和样式序列   |
|`-d, --differences[=<permanent>]`|高亮变化的部分|
|`-e, --errexit`|  当命令返回非零错误码时退出   |
|`-g, --chgexit`| 当输出有变化时退出    |
|`-n, --interval <secs>`|  执行命令的时间间隔，单位秒   |
|`-p, --precise`|尝试以精确的间隔运行命令|
|`-t, --no-title`| 不显示头部标题 |
|`-x, --exec`| 利用exec执行命令|
|`-h, --help`|  打印帮助文档并退出   |
|`-v, --version`|   打印版本并退出  |

示例：
```sh
~ watch -b -c -d -p -t -n 1 'date;exit 1'
```


