---
title: net-http-cookie
tags:
  - net
  - http
categories:
  - golang
date: 2018-08-01 19:24:44
draft: true
---
大概记录一下golang里面的net/http包内client.go的文件，及其相关内容
<!-- more -->
# Cookie 
## Cookie struct
Cookie 表示HTTP cookie相关内容，用于HTTP响应和HTTP请求header
```golang
type Cookie struct {
	Name  string
	Value string

	Path       string    // optional
	Domain     string    // optional
	Expires    time.Time // optional
	RawExpires string    // for reading cookies only

	// MaxAge=0 表示没有当前MaxAge
	// MaxAge<0 表示立即删除当前cookie，等同于'Max-Age: 0'
	// MaxAge>0 表示MaxAge存在，并用秒来表示
	MaxAge   int
	Secure   bool
	HttpOnly bool
	Raw      string
	Unparsed []string // 未解析的kv对原始文本
}
```
## Cookie method
```golang
func (c *Cookie) String() string
```
String 返回cookie的序列化以在Cookie头中使用（如果仅设置Name和Value）或Set-Cookie响应头（如果设置了其他字段）。如果c为nil或者c.Name非法，返回空字符串
# Cookie function
```golang
func readSetCookies(h Header) []*Cookie
```
readSetCookies 解析h中的所有“Set-Cookie”值并返回成功解析的Cookie。
```golang
func SetCookie(w ResponseWriter, cookie *Cookie)
```
SetCookie 向w中添加Set-Cookie header。 提供的cookie必须具有有效的名称。 无效的cookie可能会被静默删除。
```golang
func readCookies(h Header, filter string) []*Cookie
```
readCookies 从h中解析cookie，返回成功解析的cookies，如果filter不为空，则只返回当前filter名字的cookie
```golang
func validCookieDomain(v string) bool
```
validCookieDomain 判断v是否是合法的cookie格式
```golang
func validCookieExpires(t time.Time) bool
```
validCookieExpires 判断v的过期时间是否合法
```golang
func isCookieDomainName(s string) bool
```
isCookieDomainName 判断s是否是有效域名或名字由‘.’开始
```golang
func sanitizeCookieName(n string) string
```
sanitizeCookieName 
```golang
func sanitizeCookieValue(v string) string
```
sanitizeCookieValue 
```golang
func validCookieValueByte(b byte) bool
```
validCookieValueByte 
```golang
func sanitizeCookiePath(v string) string
```
sanitizeCookiePath 
```golang
func validCookiePathByte(b byte) bool
```
validCookiePathByte 
```golang
func sanitizeOrWarn(fieldName string, valid func(byte) bool, v string) string
```
sanitizeOrWarn 
```golang
func parseCookieValue(raw string, allowDoubleQuote bool) (string, bool)
```
parseCookieValue 
```golang
func isCookieNameValid(raw string) bool
```
isCookieNameValid 判断cookie name是否合法

