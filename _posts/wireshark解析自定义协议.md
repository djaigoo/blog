---
author: djaigo
title: wireshark解析自定义协议
img: 'https://img-1251474779.cos.ap-beijing.myqcloud.com/golang.png'
categories:
  - wireshark
tags:
  - lua
date: 2020-07-23 15:10:11
updated: 2020-07-23 15:10:11
---

# lua脚本
wireshark插件有代码固定的格式
```lua
do
    -- 定义协议
    local PROTO = Proto('proto', 'Proto')

    -- 定义协议字段
    local field = ProtoField.char("field", "proto field", base.NONE)

    -- 协议绑定字段
    PROTO.fields = {
        field,
    }

    -- 获取源数据
    local data_dis = Dissector.get("data")

    -- 协议解剖函数
    local function proto_dissector(buf, pinfo, root)
        -- 自定义协议dissector
    end

    -- 让wireshark调用的解剖函数
    function PROTO.dissector(buf, pinfo, root)
        if proto_dissector(buf, pinfo, root) then
            -- 自定义解剖函数执行成功
        else
            -- 自定义解剖函数执行失败，让其他底层协议解剖
            data_dis:call(buf, pinfo, root)
        end
    end

    -- 监听端口
    local listen_port = {
        8000,
    }

    -- 获取tcp.port的解剖器
    local dissectors = DissectorTable.get('tcp.port')
    for _, port in ipairs(listen_port) do
        -- 将自定义协议绑定到指定端口的解剖器
        dissectors:add(port, PROTO)
    end
end
```

# 实践
参考[https://github.com/jzwinck/redis-wireshark](https://github.com/jzwinck/redis-wireshark)
自己实现了一个[wireshark-redis](https://github.com/djaigoo/wireshark-redis)

# 参考文献
* [Chapter 11. Wireshark’s Lua API Reference Manual](https://www.wireshark.org/docs/wsdg_html_chunked/wsluarm_modules.html)
