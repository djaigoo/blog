---
title: proto2字段分析
tags:
  - pb
categories:
  - tech
mathjax: true
date: 2019-04-10 10:05:35
---

# 定义消息类型
例如：
```cpp
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;
  optional int32 result_per_page = 3;
}
```

SearchRequest消息定义指定三个字段（名称/值对），每个字段对应要包含在此类消息中的每个数据。每个字段都有一个名称和类型。
### message
表示这是一个proto结构体，用于声明类型，后接类型名称
### 字段规则
您指定消息字段是以下之一：
 - `required`：必须包含字段
 - `optional`：可能包含字段
 - `repeated`：重复字段，任意次，包括零


由于历史原因，标量数字类型的重复字段不能尽可能有效地编码。新代码应该使用特殊选项[packed = true]来获得更高效的编码。例如：
```cpp
repeated int32 samples = 4 [packed=true];
```

## 字段编号
消息定义中的每个字段都有唯一的编号，这些数字用于以消息二进制格式标识字段，并且在使用消息类型后不应更改。
请注意，1到15范围内的字段编号需要一个字节进行编码，包括字段编号和字段类型。16到2047范围内的字段编号占用两个字节。因此，您应该将非常频繁出现的消息元素保留字段编号1到15。请记住为将来可能添加的频繁出现的元素留出一些空间。
您可以指定的最小字段数为1，最大字段数为$2^{29}-1$或536,870,911。您也不能使用数字19000到19999（FieldDescriptor :: kFirstReservedNumber到FieldDescriptor :: kLastReservedNumber），因为它们是为`protocol buffers`实现保留的，如果您在`.proto`中使用这些保留数字之一，`protocol buffers`编译器会报错，也不能使用原来的保留字。

## 注释
要为.proto文件添加注释，使用C/C ++样式`//`和`/ * ... * /`语法。

## 保留字段
可以通过`reserved`设置保留字段，如果使用到指定的字段编译器将会报错。同一个reserved语句不能同时包含数字和字段。
```cpp
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

# 标量值类型
标量消息字段可以具有以下类型之一，该表显示`.proto`文件中指定的类型，以及自动生成的类中的相应类型：

<style> 
table th {
 white-space: nowrap; /*表头内容强制在一行显示*/
}
table td:nth-child(6) {
 white-space: nowrap; 
}
 </style>


| `.proto Type` | `Notes` | `C++ Type` | `Java Type` | `Python Type[2]` | `Go Type` |
| :---: | --- | :---: | :---: | :---: | :---: |
| double |` ` | double | double | float | `*float64` |
| float |`  `| float | float | float | `*float32` |
| int32 | 使用可变长度编码。编码负数的效率低，如果您的字段可能有负值，请改用sint32。 | int32 | int | int | `*int32` |
| int64 | 使用可变长度编码。编码负数的效率低，如果您的字段可能有负值，请改用sint64。 | int64 | long | `int/long[3]` | `*int64` |
| uint32 | 使用可变长度编码。 | uint32 | `int[1]` | `int/long[3]` | `*uint32` |
| uint64 | 使用可变长度编码。 | uint64 | `long[1]` | `int/long[3]` | `*uint64` |
| sint32 | 使用可变长度编码。签名的int值。这些比常规int32更有效地编码负数。 | int32 | int | int | `*int32` |
| sint64 | 使用可变长度编码。签名的int值。这些比常规int64更有效地编码负数。 | int64 | long | `int/long[3]` | `*int64` |
| fixed32 | 总是四个字节。如果值通常大于$2^{28}$，则比uint32更有效。 | uint32 | `int[1]`| `int/long[3]` | `*uint32` |
| fixed64 | 总是八个字节。如果值通常大于$2^{56}$，则比uint64更有效。 | uint64 | long[1] | `int/long[3]` | `*uint64` |
| sfixed32 | 总是四个字节。 | int32 | int | int | `*int32` |
| sfixed64 | 总是四个字节。 | int64 | long | `int/long[3]` | `*int64` |
| bool |` ` | bool | boolean | bool | `*bool` |
| string | 字符串必须始终包含UTF-8编码或7位ASCII文本。 | string | String | unicode (Python 2) or str (Python 3) | `*string` |
| bytes | 可以包含任意字节序列。 | string | ByteString | bytes | `[]byte` |


[查看更多...](https://developers.google.com/protocol-buffers/docs/encoding)

# 可选和默认值
如上所述，消息描述中的元素可以标记为可选。格式良好的消息可能包含也可能不包含可选元素。解析消息时，如果消息不包含可选元素，则解析对象中的相应字段将设置为该字段的默认值。可以将默认值指定为消息描述的一部分。例如，假设您要为`SearchRequest`的`result_per_page`值提供默认值10。
```cpp
optional int32 result_per_page = 3 [default = 10];
```

如果未为可选元素指定默认值，则使用特定于类型的默认值：
* 字符串，默认值为空字符串
* 字节，默认值为空字节字符串
* 布尔，默认值为false
* 数字类型，默认值为零
* 枚举，默认值是枚举类型定义中列出的第一个值，这意味着在将值添加到枚举值列表的开头时必须小心

# 枚举
在定义消息类型时，希望其中一个字段只能是预定义列表中的某个值。例如，假设您要为每个`SearchRequest`添加`Corpus`字段，其中`Corpus`可以是`UNIVERSAL`，`WEB`，`IMAGES`，`LOCAL`，`NEWS`，`PRODUCTS`或`VIDEO`。您可以通过向消息定义添加枚举来非常简单地执行此操作，具有枚举类型的字段只能将一组指定的常量作为其值（如果您尝试提供不同的值，则解析器会将其视为一个未知的领域）。在下面的例子中，我们添加了一个名为`Corpus`的枚举，其中包含所有可能的值，以及一个类型为`Corpus`的字段：
```cpp
message SearchRequest {
  required string query = 1;
  optional int32 page_number = 2;
  optional int32 result_per_page = 3 [default = 10];
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  optional Corpus corpus = 4 [default = UNIVERSAL];
}
```

您可以通过为不同的枚举常量指定相同的值来定义别名。为此，您需要将allow_alias选项设置为true，否则协议编译器将在找到别名时生成错误消息。
```cpp
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
enum EnumNotAllowingAlias {
  UNKNOWN = 0;
  STARTED = 1;
  // RUNNING = 1;  // 取消注释此行将导致Google内部的编译错误和外部的警告消息。
}
```

枚举器常量必须在32位整数范围内。由于枚举值在线上使用varint编码，因此负值效率低，因此不建议使用。
您可以在消息定义中定义枚举，如上例所示，也可以在外部定义枚举，这些枚举可以在`.proto`文件中的任何消息定义中重用。
您还可以使用语法`MessageType.EnumType`将一个消息中声明的枚举类型用作不同消息中字段的类型。
## 保留字段
如果通过完全删除枚举条目或将其注释掉来更新枚举类型，则未来用户可以在对类型进行自己的更新时重用该数值。如果以后加载相同.proto的旧版本，这可能会导致严重问题，包括数据损坏，隐私错误等。确保不会发生这种情况的一种方法是指定保留已删除条目的数值（和/或名称，这也可能导致JSON序列化问题）。如果将来的任何用户尝试使用这些标识符，协议缓冲编译器将会报错。
您可以使用max关键字指定保留的数值范围达到最大可能值。
```cpp
enum Foo {
  reserved 2, 15, 9 to 11, 40 to max;
  reserved "FOO", "BAR";
}
```

请注意，您不能在同一保留语句中混合字段名称和数值。

# 使用其他消息类型
您可以使用其他消息类型作为字段类型。例如，假设您希望在每个`SearchResponse`消息中包含`Result`消息。为此，您可以在同一`.proto`中定义`Result`消息类型，然后在`SearchResponse`中指定`Result`类型的字段：
```cpp
message SearchResponse {
  repeated Result result = 1;
}

message Result {
  required string url = 1;
  optional string title = 2;
  repeated string snippets = 3;
}
```

## 导入定义
我们可以通过导入来使用其他`.proto`文件中的定义。要导入另一个`.proto`的定义，请在文件顶部添加一个`import`语句：
```cpp
import "myproject/other_protos.proto";
```

默认情况下，您只能使用直接导入的.proto文件中的定义。但是，有时您可能需要将.proto文件移动到新位置。现在，您可以在旧位置放置一个虚拟.proto文件，以使用import public概念将所有导入转发到新位置，而不是直接移动.proto文件并在一次更改中更新所有调用站点。任何导入包含import public语句的proto的人都可以传递依赖导入公共依赖项。例如：
```cpp
// new.proto
// All definitions are moved here
```
```cpp
// old.proto
// This is the proto that all clients are importing.
import public "new.proto";
import "other.proto";
```
```cpp
// client.proto
import "old.proto";
// You use definitions from old.proto and new.proto, but not other.proto
```

编译器使用`-I`/`--proto_path`标志在协议编译器命令行中指定的一组目录中搜索导入的文件。如果没有给出标志，它将查找调用编译器的目录。通常，您应将`--proto_path`标志设置为项目的根目录，并对所有导入使用完全限定名称。

# 嵌套类型
消息类型之间可以嵌套使用
```cpp
message SearchResponse {
  message Result {
    required string url = 1;
    optional string title = 2;
    repeated string snippets = 3;
  }
  repeated Result result = 1;
}
```

如果要在其父消息类型之外重用此消息类型，请将其称为`Parent.Type`：
```cpp
message SomeOtherMessage {
  optional SearchResponse.Result result = 1;
}
```

# 更新消息类型
如果现有的消息类型不再满足您的所有需求 - 例如，您希望消息格式具有额外的字段 - 但您仍然希望使用使用旧格式创建的代码，请不要担心！在不破坏任何现有代码的情况下更新消息类型非常简单。
请记住以下规则：
* 请勿更改任何现有字段的字段编号
* 您添加的任何新字段都应该是可选的或重复的。这意味着使用“旧”消息格式的代码序列化的任何消息都可以由新生成的代码进行解析，因为它们不会缺少任何必需的元素。您应该为这些元素设置合理的默认值，以便新代码可以与旧代码生成的消息正确交互。同样，您的新代码创建的消息可以由旧代码解析：旧的二进制文件在解析时只是忽略新字段。但是，未丢弃未知字段，如果稍后将序列化消息，则将未知字段与其一起序列化 - 因此，如果将消息传递给新代码，则新字段仍然可用。
* 只要在更新的消息类型中不再使用字段编号，就可以删除非必填字段。您可能希望重命名该字段，可能添加前缀“OBSOLETE_”，或者保留字段编号，以便.proto的未来用户不会意外地重复使用该编号。
* 只要类型和数量保持不变，非必需字段就可以转换为扩展名，反之亦然。
* int32，uint32，int64，uint64和bool都是兼容的 - 这意味着您可以将字段从这些类型之一更改为另一种类型，而不会破坏向前或向后兼容性。如果从导线中解析出一个不适合相应类型的数字，您将获得与在C ++中将该数字转换为该类型相同的效果（例如，如果将64位数字作为int32读取，它将被截断为32位）。
* sint32和sint64彼此兼容，但与其他整数类型不兼容。
* 只要字节是有效的UTF-8，字符串和字节是兼容的。
* 如果字节包含消息的编码版本，则嵌入消息与字节兼容。
* fixed32与sfixed32兼容，fixed64与sfixed64兼容。
* 可选与重复兼容。给定重复字段的序列化数据作为输入，期望该字段是可选的客户端将采用最后一个输入值（如果它是基本类型字段）或合并所有输入元素（如果它是消息类型字段）。
* 更改默认值通常是正常的，只要您记住永远不会通过网络发送默认值。因此，如果程序接收到未设置特定字段的消息，则程序将看到在该程序的协议版本中定义的默认值。它不会看到发件人代码中定义的默认值。
* enum在线格式方面与int32，uint32，int64和uint64兼容（请注意，如果值不适合，将截断值），但请注意，在反序列化消息时，客户端代码可能会以不同方式处理它们。值得注意的是，当消息被反序列化时，将丢弃无法识别的枚举值，这使得字段具有.. accessor返回false并且其getter返回枚举定义中列出的第一个值，或者如果指定了一个，则返回默认值。在重复的枚举字段的情况下，任何无法识别的值都会从列表中删除。但是，整数字段将始终保留其值。因此，在接收线路上的超出范围枚举值时，将整数升级为枚举时需要非常小心。
* 在当前的Java和C ++实现中，当剥离出无法识别的枚举值时，它们与其他未知字段一起存储。请注意，如果此数据被序列化，然后由识别这些值的客户端重新解析，则会导致奇怪的行为。对于可选字段，即使在反序列化原始消息之后写入新值，仍然会识别旧值的旧值。对于重复字段，旧值将显示在任何已识别和新添加的值之后，这意味着不会保留顺序。
* 将单个可选值更改为新oneof的成员是安全且二进制兼容的。如果您确定没有代码一次设置多个，则将多个可选字段移动到新的oneof中可能是安全的。将任何字段移动到现有字段中是不安全的。

# 扩展
扩展允许您声明消息中的一系列字段号可用于第三方扩展。扩展名是字段的占位符，该字段的类型不是由原始.proto文件定义的。这允许其他.proto文件通过定义某些或所有字段的类型以及这些字段号添加到消息定义中。让我们来看一个例子：
```cpp
message Foo {
  // ...
  extensions 100 to 199;
}
```

这表示foo中字段编号`[100, 199]`的范围是为扩展保留的。其他用户现在可以在自己的`.proto`文件中向foo添加新字段，这些文件使用指定范围内的字段号导入`.proto`，例如：
```cpp
extend Foo {
  optional int32 bar = 126;
}
```

这会在foo的原始定义中添加一个名为bar、字段号为126的字段。编码用户的foo消息时，线格式与用户在foo中定义的新字段完全相同。但是，访问应用程序代码中扩展字段的方式与访问常规字段的方式稍有不同——生成的数据访问代码具有用于处理扩展的特殊访问器。例如，下面是如何在C++中设置BAR的值：
```cpp
Foo foo; 
foo.SetExtension(bar,  15);
```

同样，foo类定义模板化的访问器`hasExtension()`、`clearExtension()`、`getExtension()`、`mutableExtension()`和`addExtension()`。它们都具有与正常字段对应的生成访问器匹配的语义。有关使用扩展的详细信息，请参见为所选语言生成的代码引用。

## 嵌套扩展
您可以在其他类型的范围内声明扩展：
```cpp
message Baz {
  extend Foo {
    optional int32 bar = 126;
  }
  ...
}
```

在这种情况下，访问此扩展的C++代码是：
```cpp
Foo foo;
foo.SetExtension(Baz::bar, 15);
```

换句话说，唯一的影响是`Baz`范围内定义了`bar`。
一种常见的模式是在扩展的字段类型的范围内定义扩展，例如，这里是对`Baz`类型的`foo`的扩展，其中扩展被定义为baz的一部分：
```cpp
message Baz {
  extend Foo {
    optional Baz foo_ext = 127;
  }
  ...
}
```

但是，不要求在该类型中定义具有消息类型的扩展。您也可以这样做：
```cpp
message Baz {
  ...
}

// This can even be in a different file.
extend Foo {
  optional Baz foo_baz_ext = 127;
}
```

事实上，为了避免混淆，可能更倾向于使用这种语法。如上所述，嵌套语法经常被错误地认为是由不熟悉扩展的用户进行的子类化。

## 选择扩展号码
确保两个用户不使用相同的字段号向同一消息类型添加扩展非常重要——如果扩展被意外地解释为错误的类型，则可能导致数据损坏。您可能需要考虑为项目定义一个扩展编号约定，以防止发生这种情况。
如果编号约定可能涉及具有非常大字段号的扩展，则可以使用max关键字指定扩展范围达到最大可能字段号：
```cpp
message Foo {
  extensions 1000 to max;
}
```

`max` is $2^{29} - 1$，或者 `536,870,911`

# Oneof
如果有一条消息包含多个可选字段，并且最多同时设置一个字段，则可以使用one-of功能强制执行此行为并保存内存。
除了一个共享内存中的所有字段外，其中一个字段与可选字段类似，并且最多可以同时设置一个字段。设置其中一个的任何成员将自动清除所有其他成员。您可以使用特殊的`case()`或`WhichOneof()`方法检查其中一个值的设置（如果有），这取决于您选择的语言。
## 使用Oneof
```cpp
message SampleMessage {
  oneof test_oneof {
     string name = 4;
     SubMessage sub_message = 9;
  }
}
```

然后将一个字段添加到定义中。可以添加任何类型的字段，但不能使用`required`， `optional`，`repeated`的关键字。如果需要向其中一个添加重复字段，可以使用包含重复字段的消息。
在生成的代码中，其中一个字段与常规可选方法具有相同的getter和setter。您还可以得到一个特殊的方法来检查其中一个值（如果有）是设置的。
## Oneof特性
* 设置oneof字段将自动清除oneof的所有其他成员。因此，如果您设置了几个字段中的一个，那么只有您设置的最后一个字段仍然有一个值。
* 如果解析器在线路上遇到同一个的多个成员，则在解析的消息中只使用看到的最后一个成员。
* 扩展不支持Oneof
* Oneof不能被`repeated`修饰
* 反射API适用于Oneof字段。
* 如果使用C++，请确保代码不会导致内存崩溃。
* 在C++中，如果使用swap()函数交换两个Oneof，是可以的。

## 兼容性
添加或删除其中一个字段时要小心。如果检查`Oneof`的值返回`NONE/NOT_SET`，则可能意味着oneof尚未设置，或者已设置为`Oneof`的其他版本中的字段。因为没有办法知道`wire`上的未知字段是否是`Oneof`的成员。
### 标签重用
* 将可选字段移入或移出
在消息序列化和解析之后，您可能会丢失一些信息（某些字段将被清除）。但是，您可以安全地将单个字段移动到的新字段中，并且如果知道只设置了一个字段，则可以移动多个字段。
* 删除一个字段并将其添加回来
这可能会在消息序列化和分析之后清除当前设置的Oneof字段。
* 拆分或何必`Oneof`
和移动有规律的`optional`字段有相似的问题

# Maps
如果需要在message声明一个关联映射，`protocol buffers`提供了一个快捷语法
`map<key_type, value_type> map_field = N;`。
其中`key_type`可以是任何整数或字符串类型（等除浮点类型和字节之外的任何标量类型）。请注意，枚举不是有效的`key_type`。`value_type`可以是除另一个映射之外的任何类型。
因此，例如，如果要创建一个项目映射，其中每个项目消息都与一个字符串键相关联，可以这样定义它：
```cpp
map<string,  Project> projects =  3;
```

生成的映射API当前可用于所有Proto2支持的语言。

## Maps特性
* 扩展不支持Maps
* Maps不支持`repeated`,，`optional`，或`required`
* `wire`排序和映射值的映射迭代排序是未定义的，因此不能依赖于特定顺序中的映射项。
* 为`.proto`生成文本格式时，`Maps`按键排序，数字键按数字顺序排列。
* 当从`wire`进行分析或合并时，如果存在重复的映射键，则使用最后一个键。从文本格式分析映射时，如果有重复的键，解析可能会失败。

## 向后兼容
映射语法在网络上等价于以下内容，因此不支持映射的协议缓冲区实现仍然可以处理您的数据：
```cpp
message MapFieldEntry {
  optional key_type key = 1;
  optional value_type value = 2;
}

repeated MapFieldEntry map_field = N;
```

任何支持映射的`protocol buffers`实现必须同时生成和接受上述定义的数据。

# Packages
可以向`.proto`文件添加可选的`package`说明符，以防止协议消息类型之间的名称冲突。
```cpp
package foo.bar;
message Open { ... }
```

然后，在定义消息类型的字段时，可以使用包说明符：
```cpp
message Foo {
  ...
  required foo.bar.Open open = 1;
  ...
}
```

包说明符影响生成代码的方式取决于所选语言：
* **C++**，生成的类被封装在C++命名空间内。例如，open将位于命名空间foo:：bar中。
* **Java**，该包被用作Java包，除非您在您的.PROTO文件中明确地提供了一个`option java_package`。
* **Python**，package指令被忽略，因为python模块是根据它们在文件系统中的位置组织的。
* **Go**，package指令被忽略，生成的.pb.go文件位于以相应的go-proto-library规则命名的包中。

注意，即使package指令不直接影响生成的代码（例如在python中），仍然强烈建议为.proto文件指定包，否则可能导致描述符中的命名冲突，并使proto不可移植到其他语言。

## Packages解析
`protocol buffers`中的类型名称解析像`C++`一样工作：首先搜索最内层的范围，然后搜索最内层的，等等。每个包都被认为是“内部的”到它的父包。前导`"."`（例如，.foo.bar.baz）表示从最外面的作用域开始。
`protocol buffers`编译器通过分析导入的.proto文件解析所有类型名。每种语言的代码生成器都知道如何引用该语言中的每种类型，即使它有不同的作用域规则。

# 定义服务
如果要将消息类型与RPC（远程过程调用）系统一起使用，可以在.proto文件中定义一个RPC服务接口，协议缓冲区编译器将以所选语言生成服务接口代码和存根。因此，例如，如果要使用接收SearchRequest并返回SearchResponse的方法定义RPC服务，可以在.proto文件中定义它，如下所示：
```cpp
service SearchService {
  rpc Search (SearchRequest) returns (SearchResponse);
}
```

默认情况下，协议编译器将生成一个名为SearchService的抽象接口和相应的“存根”实现。存根将所有调用转发到rpcchannel，而rpcchannel又是一个抽象接口，您必须根据自己的rpc系统定义自己。例如，您可以实现一个rpcchannel，它将消息序列化并通过HTTP发送到服务器。换句话说，生成的存根提供了一个类型安全的接口，用于进行基于协议缓冲区的RPC调用，而无需将您锁定到任何特定的RPC实现中。因此，在C++中，你可能会得到这样的代码：
```cpp
using google::protobuf;

protobuf::RpcChannel* channel;
protobuf::RpcController* controller;
SearchService* service;
SearchRequest request;
SearchResponse response;

void DoSearch() {
  // You provide classes MyRpcChannel and MyRpcController, which implement
  // the abstract interfaces protobuf::RpcChannel and protobuf::RpcController.
  channel = new MyRpcChannel("somehost.example.com:1234");
  controller = new MyRpcController;

  // The protocol compiler generates the SearchService class based on the
  // definition given above.
  service = new SearchService::Stub(channel);

  // Set up the request.
  request.set_query("protocol buffers");

  // Execute the RPC.
  service->Search(controller, request, response, protobuf::NewCallback(&Done));
}

void Done() {
  delete service;
  delete channel;
  delete controller;
}
```

所有服务类也实现了服务接口，它提供了一种在编译时不知道方法名或其输入和输出类型的情况下调用特定方法的方法。在服务器端，这可以用来实现一个可以注册服务的RPC服务器。
```cpp
using google::protobuf;

class ExampleSearchService : public SearchService {
 public:
  void Search(protobuf::RpcController* controller,
              const SearchRequest* request,
              SearchResponse* response,
              protobuf::Closure* done) {
    if (request->query() == "google") {
      response->add_result()->set_url("http://www.google.com");
    } else if (request->query() == "protocol buffers") {
      response->add_result()->set_url("http://protobuf.googlecode.com");
    }
    done->Run();
  }
};

int main() {
  // You provide class MyRpcServer.  It does not have to implement any
  // particular interface; this is just an example.
  MyRpcServer server;

  protobuf::Service* service = new ExampleSearchService;
  server.ExportOnPort(1234, service);
  server.Run();

  delete service;
  return 0;
}
```

如果您不想插入自己现有的RPC系统，现在可以使用GRPC：一种在谷歌开发的语言和平台无关的开源RPC系统。GRPC特别适用于协议缓冲区，允许您使用特殊的协议缓冲区编译器插件直接从.proto文件生成相关的RPC代码。但是，由于Proto2和Proto3生成的客户机和服务器之间存在潜在的兼容性问题，我们建议您使用Proto3定义GRPC服务。您可以在Proto3语言指南中找到有关Proto3语法的更多信息。如果您想将proto2与grpc一起使用，则需要使用3.0.0或更高版本的协议缓冲区编译器和库。

# 选项
**高级功能**
`.proto`文件中的各个声明可以使用许多选项进行注释。选项不会更改声明的整体含义，但可能会影响在特定上下文中处理它的方式。可用选项的完整列表在`google/protobuf/descriptor.proto`中定义。
有些选项是文件级选项，这意味着它们应该在顶级范围内写入，而不是在任何消息、枚举或服务定义内写入。有些选项是消息级选项，这意味着它们应该写在消息定义中。有些选项是字段级选项，这意味着它们应该写在字段定义中。还可以在枚举类型、枚举值、服务类型和服务方法上编写选项；但是，目前没有任何有用的选项可用于这些类型。

## 自定义选项
协议缓冲区甚至允许您定义和使用自己的选项。请注意，这是大多数人不需要的高级功能。由于选项是由google/protobuf/descriptor.proto中定义的消息定义的（如fileoptions或fieldoptions），因此定义您自己的选项只是扩展这些消息的问题。例如：
```cpp
import "google/protobuf/descriptor.proto";

extend google.protobuf.MessageOptions {
  optional string my_option = 51234;
}

message MyMessage {
  option (my_option) = "Hello world!";
}
```

# 生成代码
若要生成Java、Python或C++代码，需要使用`.proto`文件中定义的消息类型，则需要在.PROTO上运行协议缓冲编译器PotoC。如果尚未安装编译器，请下载该包并按照自述文件中的说明进行操作。
```bash
protoc --proto_path=_IMPORT_PATH_ --cpp_out=_DST_DIR_ --java_out=_DST_DIR_ --python_out=_DST_DIR_ _path/to/file_.proto
```

* `IMPORT_PATH`
指定解析导入指令时要在其中查找`.proto`文件的目录。如果省略，则使用当前目录。可以通过多次传递`--proto_path`选项来指定多个导入目录；它们将按顺序进行搜索。`-I=_IMPORT_PATH`可用作`--proto_path`的简短形式。
* 可以提供一个或多个输出指令，类似`--cpp_out`写法，支持其他语言
另外，如果dst_dir以.zip或.jar结尾，编译器将把输出写入具有给定名称的单个zip格式存档文件。JAVA JAR规范要求JAR输出也将得到清单文件。请注意，如果输出存档已经存在，它将被覆盖；编译器不够智能，无法将文件添加到现有存档。
* 必须提供一个或多个.proto文件作为输入。
可以一次指定多个.proto文件。尽管文件是相对于当前目录命名的，但每个文件必须位于导入路径之一，以便编译器可以确定其规范名称。

