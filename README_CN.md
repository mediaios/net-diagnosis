# iOS网络诊断SDK

## [README of English](https://github.com/mediaios/net-diagnosis)

## 介绍 

通过集成“iOS网络诊断sdk”，您可以轻松地在iOS上实现ping / traceroute /移动公共网络信息/端口扫描等网络诊断相关的功能。

## 环境要求

* iOS >= 9.0
* Xcode >= 7.0
* 设置 `Enable Bitcode` 为 `NO`

## 安装使用

### 通过pod方式

在你工程的`Podfile`中添加以下依赖： 

```
pod 'PhoneNetSDK'
```

### 快速开始

首先需要在你的项目中导入`SDK`头文件：

```
#import <PhoneNetSDK/PhoneNetSDK.h>
```

另外，你需要将`-lc++`，`-ObjC`，`$(inherited)`添加到项目的`Build Setting`->`other links flags`中。 如下所示：

![](https://ws2.sinaimg.cn/large/006tKfTcly1g0l5g4kt38j30og0e7q45.jpg)

### ping

```
 [[PhoneNetManager shareInstance] netStartPing:@"www.baidu.com" packetCount:10 pingResultHandler:^(NSString * _Nullable pingres) {
       // your processing logic 
  }];
```

### TCP ping 

```
_tcpPing = [PNTcpPing start:hostDomain port:portNum.integerValue count:3 complete:^(NSMutableString *pingres) {
	// your processing logic
}];
```

### traceroute


在命令行中默认的traceroute命令发的是UDP的包(简称 udp traceroute)：
```
 [[PhoneNetManager shareInstance] netStartTraceroute:@"www.baidu.com" tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp) {
     // your processing logic                
  }];
```

### ICMP traceroute 

在mac的terminal中，输入`traceroute -I baidu.com` 就是采用ICMP协议的方式做traceroute. sdk中提供了这种功能：
```
 _udpTraceroute = [PNUdpTraceroute start:ip complete:^(NSMutableString *res) {
                    // your processinig logic
                }];
```

### 根据域名查ip(nslookup)

```
[[PhoneNetManager shareInstance] netLookupDomain:@"www.google.com" completeHandler:^(NSMutableArray<DomainLookUpRes *> * _Nullable lookupRes, PNError * _Nullable sdkError) {
	// your processing logic
}];
```

### 端口扫描

```
[[PhoneNetManager shareInstance] netPortScan:@"www.baidu.com" beginPort:8000 endPort:9000 completeHandler:^(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError) {
	// your processing logic    
}];
```

### 其它功能

* 设置SDK的日志级别
* 获取设备的公网ip信息
* 随着版本的迭代，会提供更多高级功能

## 联系我们

* 如果你有任何问题或需求，请提交[issue](https://github.com/mediaios/net-diagnosis/issues)
* 如果你要提交代码，欢迎提交 pull request
