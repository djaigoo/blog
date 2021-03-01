---
title: protocol buffers
tags:
  - pb
categories:
  - tech
mathjax: true
date: 2019-04-09 16:32:26
---

# 什么是**Protocol Buffers**
Protocol Buffers （简称 Protobuf）是 Google 开源的一款跨语言，跨平台，扩展性好的序列化工具，相比于 XML 和 JSON 等流行的编码格式，Protobuf 的性能非常高。因此，Protobuf 的编码格式（文件后缀为 `.proto`）在网络开发中得到了广泛的应用，**protoc** 作为 Protobuf 的编译器，可以根据 Protobuf 的定义文件 `.proto` 生成多种语言（如：C++, Java, Go, Python 等）的类型定义文件及编解码操作代码。
其他详情可以参考[官方文档](https://developers.google.com/protocol-buffers/)。

# 安装
## 源码安装
官方源码：[https://github.com/google/protobuf](https://github.com/google/protobuf)
可以选择[releases](https://github.com/protocolbuffers/protobuf/releases)获取最新版和选择官方支持的语言版本

### 安装依赖
如官网所列，protoc 有如下依赖：
autoconf, automake, libtool, curl, make, g++, unzip, gmock
其中 gmock 依赖于 libtool

### 编译安装：

```
$ wget https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-all-3.7.1.tar.gz
$ tar xf protobuf-all-3.7.1.tar.gz
$ cd protobuf-all-3.7.1
$ ./configure
$ make
$ make check
$ sudo make install
```

注：
安装完成之后，会在 /usr/lib 目录下生成前缀为 libprotobuf, libprotobuf-lite, libprotoc 这三类静态和动态库文件。

## 二进制

## 支持golang
下载编译器插件
```bash
go get  -u github.com/golang/protobuf/protoc-gen-go
```

会在`$GOPATH/bin`中生成可执行文件`protoc-gen-go`，可以将文件移动至`$PATH`里面的目录下或者将`$GOPATH/bin`加入`$PATH`。

# 运行
## C++
```bash
protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/addressbook.proto
```

$`SRC_DIR`表示应用程序源代码文件所在目录（如果不写即是当前目录`.`），`DST_DIR`表示生成文件的目录，最后指出需要编译的目标proto文件。

## Golang
```bash
protoc -I=$SRC_DIR --go_out=$DST_DIR $SRC_DIR/addressbook.proto
```

$`SRC_DIR`表示应用程序源代码文件所在目录（如果不写即是当前目录`.`），`DST_DIR`表示生成文件的目录，最后指出需要编译的目标proto文件。

# 版本
## proto2
示例：
```cpp
syntax = "proto2";
package hw;
/*
    注释风格支持C语言注释
*/

// 导入其他文件的message
import "hw.import.proto";

// 枚举类型
enum Corpus {
    // 设置保留字段
    reserved 7, 15, 9 to 11, 40 to max; // 保留字段编号
    reserved "FOO", "BAR"; // 保留字段名称
    // 开启别名
    option allow_alias = true;
    UNIVERSAL = 0;
    DEFAULT = 0; // 开启别名可以多个字段使用同一个字段编号
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
}

// 定义消息体
/*
变量值类型与转换为语言后的类型
proto Type  C++ Type    Java Type   Go Type     Python Type[2]
double      double      double      *float64    float
float       float       float       *float32    float
int32       int32       int         *int32      int
int64       int64       long        *int64      int/long[3]
uint32      uint32      int[1]      *uint32     int/long[3]
uint64      uint64      long[1]     *uint64     int/long[3]
sint32      int32       int         *int32      int
sint64      int64       long        *int64      int/long[3]
fixed32     uint32      int[1]      *uint32     int/long[3]
fixed64     uint64      long[1]     *uint64     int/long[3]
sfixed32    int32       int         *int32      int
sfixed64    int64       long        *int64      int/long[3]
bool        bool        boolean     *bool       bool
string      string      String      *string     unicode(Python2)|str(Python3)
bytes       string      ByteString  []byte      bytes
*/
message HelloWorld {
    // 设置保留字段
    reserved 2, 15, 9 to 11; // 保留字段编号
    reserved "foo", "bar"; // 保留字段

    required string query = 1; // 设置字段
    optional int32 page_number = 4 [default = 10]; // 设置字段默认值
    repeated int32 result_per_page = 3 [packed = true]; // 循环字段可以使用packed设置高效编码
    optional Corpus corpus = 5 [default = UNIVERSAL]; // 设置枚举类型
    optional Imported imported = 6; // 设置外部文件message

    // 嵌套message
    message Result {
        optional int32 status_code = 1; // 可重新利用字段编号
    }

    // 扩展字段编号
    extensions 100 to 199;

    // OneOf，字段编号不能与已定义的编号冲突
    oneof test_oneof {
        string name = 7;
        string sex = 8;
    }
}

// 使用其他message内部的message
message Response {
    required HelloWorld.Result result = 1;
}

// 声明扩展
extend HelloWorld {
    optional int32 bar = 126;
}
// 在类型内声明扩展
message ExHelloWorld {
    extend HelloWorld {
        optional int32 bar_ex = 127;
    }
}
// 直接调用扩展
message ExtendHelloWorld {
    optional HelloWorld hello_world = 1;
}
```


## proto3
示例：
```cpp

```


# 优缺点
## 优点
* 小巧，采用二进制流，便于传输数据
* 快速，编码解码比较快
* 方便，自动生成相应的操作代码，减少了维护代码的成本，支持大部分主流语言，无需关心底层，直接调用函数即可
* 兼容性好，不必破坏已部署的、依靠“老”数据格式的程序就可以对数据结构进行升级。这样您的程序就可以不必担心因为消息结构的改变而造成的大规模的代码重构或者迁移的问题。因为添加新的消息中的 field 并不会引起已经发布的程序的任何改变。

## 缺点
* 可读性差，对机器友好，对人不友好。如果没有`.proto`文件无法表示数据含义，所以使用场景一般是内部服务的数据传输
* 描述数据能力差，无法类似xml那样自描述字段相关内容


