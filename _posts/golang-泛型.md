---
author: djaigo
title: golang-泛型
categories:
  - golang
date: 2022-10-14 11:34:21
tags:
---

泛型，对类型的集合附加某些代码，使这些类型拥有相同逻辑，可以理解为对类型的第二个维度的描述。
`golang`是在编译时将相应的类型都会具体实现一遍，多个类型的笛卡尔积会导致编译速度慢编译后文件大。

# 函数
```go
// 普通函数
func Add(a, b int) int
func Add(a, b uint) uint

// 泛型函数
func Add[T int|uint](a, b T) T
func Set[K ~int|uint, V float32|float64](a K, b V) bool

//       类型形参 类型约束     函数形参    函数形参类型 返回值
//       ↑       ↑          ↑          ↑          ↑
//       ↑       ↑↑↑↑↑↑↑↑   ↑↑↑↑↑↑↑↑↑↑ ↑          ↑
func Add[T       int|uint] (arg1, arg2 T)         T
```

与普通的Add函数相比，泛型函数多了对参数和返回值类型的定义：
* `T` 表示类型形参（`type arguments`）
* `int|uint`、`float32|float64` 表示类型约束，多个类型约束用`|`隔开，表示只允许类型约束列表中的类型能作为类型实参
* `a K, b V`表示类型为`K`和`V`的函数形参
* 多个类型参数用`,`隔开
* `~`表示底层类型（`underlying type`），`type MyInt int`表示类型名`MyInt`，底层类型为`int`

调用时，须对类型参数实例化，既可显式写出类型实参，也可由编译器自动填充，两者等价
```go
Add(1, 2)
Add[int](1, 2)
```

匿名函数不支持泛型，但是支持已经定义好的类型参数
```go
// ❌ 匿名函数不支持泛型
var add = func[T int|uint](a, b T) T {}

// ✅ 支持已经定义好的类型参数
func Func[T int | uint](a, b T) T {
    var add = func(a, b T) T {
        return a + b
    }
    return add(a, b)
}
```

在泛型函数中不能对类型参数所对应的函数形参进行类型断言，但支持反射（需要思考是否值得）
```go
// ❌ a和b是类型为T的Add函数的形参，不允许类型断言
func Add[T int | uint](a, b T) T {
    switch a.(type) {
    case int:
    case uint:
    }
}

// ✅ 支持反射
func Add[T int | uint](a, b T) T {
    v := reflect.ValueOf(a)
    switch v.Kind() {
    case reflect.Int:
    case reflect.Uint:
    }
}
```

# 结构
结构定义，类型必须显式声明，编译器不会自动填充
```go
// 声明泛型类型
type Slice[T int|uint|string] []T

// 实例化类型
var arr = Slice[int]{}
var arr Slice[int] = []int{}
```

结构体声明，允许类型形参嵌套，但不允许循环引用
```go
type Struct[T int|uint|float32|float64, S []T] struct {
    t T
    s S
}

var s = Struct[int, []int]{
    t: 0,
    s: []int{1, 2},
}
```

如果泛型约束为子集则可以嵌套声明`type IntSlice[T int|uint] Slice[T]`，因为`IntSlice`的类型约束是`Slice`类型约束的子集，所以允许嵌套声明；如果不是子集`type IntSlice[T int|int8] Slice[T]`则不允许嵌套声明。

错误实现类型声明
```go
// ❌ 类型形参不能单独使用
type Type[T int|uint] T

// ❌ 当还用指针时会与乘法定义冲突
type Type[T *int|*uint] []T
// ✅ 在后面加上逗号表示类型参数列表
type Type[T *int|*uint,] []T
// ✅ 改用匿名interface定义
type Type[T interface{*int|*uint}] []T

// ❌ 定义S为[]T，则S的元素类型必须与T类型相同
var s Struct[int, []uint]
// ✅ 类型定义必须相同
var s Struct[int, []int]

// ❌ 匿名类型不支持泛型
var s = struct[T int|uint] {
    t T
    s []T
}{}
```

成员方法，会对每一个类型约束都实现相应的方法
```go
func (s *Slice[T]) Sum() T {}

// 调用
s := Slice[int]{1, 2, 3}
fmt.Println(s.Sum())
```

golang不支持泛型方法，但支持使用结构泛型的类型参数
```go
// ❌ 不支持成员方法提供类型参数
func (s *Slice[T]) Push[V int|uint](v V)

// ✅ 支持使用结构泛型的类型参数
func (s *Slice[T]) Pop() T
```

做参数返回值

# 接口
接口用于定义类型约束的集合
```go
type Int interface {
    ~int|int8|int16|int32|int64
}
type Uint interface {
    ~uint|uint16|uint32|uint64
}
type Float interface {
    float32|float64
}
```

接口允许嵌套组合，`|`表示并集，换行表示交集

```go
// 接口可以嵌套
type Number interface {
    Int|Uint|Float
}

// 表示既是Int又是Uint 不存在这样的类型 所以是个空集
type NullNumber interface {
    Int
    Uint
}
```

特殊类型集
* any，表示任意类型的集合，是对原有`interface{}`的替代
* comparable，表示可以判断是否相等的类型集合，不能与其他类型进行`|`操作


接口函数，允许类型与函数同时定义，并且语义同上，换行表示交集
```go
// Number 表示类型为Int或Uint或Float的并且实现了Add函数的类型
type Number interface {
    Int | Uint | Float
    Add(a, b int)
}
```

## 接口分类
* 基本接口，表示只有方法约束的接口，`1.18`之前的`interface`
* 一般接口，不止包含方法约束还包括类型约束，只能用于类型约束，不能用于变量声明
* 泛型接口，声明时包含类型形参的接口

```go
// 基本接口
type NumberAdd interface {
    Add(a, b int) int
}

// 一般接口
type IntAdd interface {
    Int
    Add(a, b int) int
}
// ❌ 一般接口不允许定义变量
var iadd IntAdd

// 泛型接口
type IntSub[T Number] interface {
    Int
    Sub(a, b T) T
}
```

### 基本接口（Basic interfaces）
只包含函数约束列表的接口，即原有接口定义形式，兼容原有语义

### 一般接口（General interfaces）
描述兼容泛型的接口，支持函数约束和类型约束，接口类型集规则如下：
* 空接口的类型集是所有非接口类型的集合，`any = interface{}`
* 非空接口的类型集是其接口元素的类型集的交集，每行表示`&`语义
* 方法的类型集是所有非接口类型拥有的方法集中包含该方法，定义实现接口
* 非接口类型的类型集是仅由类型组成的集合，类型的集合，允许`|`操作
* `~T`形式的项的类型集是底层类型为`T`的所有类型的集合
* 项并集`t1|t2|…|tn`是项的类型集的并集

```go
// 定义实现io.ReadWriter且底层类型是[]byte或string或底层类型是Data字段结构的接口
type ReadWriter interface {
    io.ReadWriter
    ~[]byte | ~string | ~struct{ Data int }
}
```

错误示例
```go
type Invalid interface {
    // ❌ MyInt的底层类型不是MyInt所以不能使用~ ，不允许对其他类型或接口使用
    ~MyInt
    ~error
    // ❌ 类型参数不能作为类型约束
    Type
    int | ~Type
    // ❌ 不能自己嵌套自己
    Invalid
    int | Invalid
    // ❌ 接口方法不能拥有类型参数
    Func[T int]()
}

// ❌ 不允许循环嵌套
type Bad1 interface {
    Bad2
}
type Bad2 interface {
    Bad1
}
```


### 泛型接口
在定义时拥有类型约束，即表示泛型接口
```go
// 定义泛型接口
type Adder[T ~int | ~uint] interface {
    Add(a, b T) T
}

// IntAdder 定义类型参数为T
// 数据类型为Int|Uint
// 实现了error接口
// 实现了泛型函数Add
type IntAdder[T ~int | ~uint] interface {
    Int | Uint
    error
    Add(a, b T) T
}
```


## 实现接口
类型`T`实现接口`I`的条件
* 类型`T`不是接口并且是类型集`I`的元素
* 类型`T`是一个接口并且类型集`T`是类型集`I`的子集

### 基本接口
和原有逻辑一样，只要实现了函数约束列表中的所有函数即可实现该接口
```go
// 实现error接口
type Error struct {}
func (Error) Error() string {}
```

### 一般接口
一般接口只能用作类型约束不能被实现
```go
// 实现ReadWriter接口
type Bytes []byte
func (Bytes) Read(p []byte) (n int, err error) {}
func (Bytes) Write(p []byte) (n int, err error) {}

// 基于类型约束实现read函数
func read[T ReadWriter](reader T) {
    reader.Read(nil)
}

// ❌ 一般接口只能用于类型约束
var rwer ReadWriter
```


### 泛型接口
需要先确定接口类型参数，让接口转为具体的实例化接口。实例化后如果是基本接口则即可声明变量又可作类型约束，如果实例化后是一般接口则只可做类型约束。
```go
// 定义实现泛型接口类型
type MyInt int
func (MyInt) Add(a, b int) int {}

// 声明泛型接口变量
var adder Adder[int]

// 将泛型接口作为函数参数类型
func adder(a Adder[int]) {}

// 将泛型接口作为类型约束
func intAdd[T IntAdd[int]](a,b T) T
```

# 总结
* golang实现泛型，减少了对不同类型相同的代码
* 利用先约束后使用的策略，明确代码含义
* 支持了对底层数据类型的支持，弥补了对基础类型不能实现方法的不足
* 有类型约束的类型只能做类型约束，不能实例化对象

# 参考文献
1. [The Go Programming Language Specification](https://go.dev/ref/spec)
2. [Go 1.18 泛型全面讲解：一篇讲清泛型的全部](https://segmentfault.com/a/1190000041634906)