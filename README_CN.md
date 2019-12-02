# iOS网络诊断SDK

## [README of English](https://github.com/mediaios/net-diagnosis)

## 介绍 

通过集成“iOS网络诊断sdk”，您可以轻松地在iOS上实现ping / traceroute /移动公共网络信息/端口扫描等网络诊断相关的功能。

利用该sdk开发的网络诊断app截图： 

<div align="center">
<img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_01.PNG" height="500px" alt="图片说明" ><img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_02.PNG" height="500px" alt="图片说明" > <img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_03.PNG" height="500px" alt="图片说明" >   
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_04.PNG" height="500px" alt="图片说明" ><img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_05.PNG" height="500px" alt="图片说明" > <img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_06.PNG" height="500px" alt="图片说明" >   
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_07.PNG" height="500px" alt="图片说明" ><img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_08.PNG" height="500px" alt="图片说明" ><img src="https://raw.githubusercontent.com/mediaios/img_bed/master/UNet_09.PNG" height="500px" alt="图片说明" >   
</div>

* [在App Store中下载 UNetState](https://apps.apple.com/us/app/unetstate/id1489314289?l=zh&ls=1)
* 欢迎 star & fork 

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

### UDP traceroute


在命令行中默认的traceroute命令发的是UDP的包(简称 udp traceroute)：

```
 _udpTraceroute = [PNUdpTraceroute start:ip complete:^(NSMutableString *res) {
                    // your processinig logic
                }];
```

### ICMP traceroute 

在mac的terminal中，输入`traceroute -I baidu.com` 就是采用ICMP协议的方式做traceroute. sdk中提供了这种功能：

```
 [[PhoneNetManager shareInstance] netStartTraceroute:@"www.baidu.com" tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp) {
     // your processing logic                
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

### 局域网ip扫描 

如果你要做局域网活跃ip扫描功能的话，那么利用该SDK你可以很快的监听到每个活跃的ip，并且SDK还会返回给你扫描进度。

具体步骤如下： 

1. 创建对象并设置代理`PNetMLanScannerDelegate`
2. 启动扫描,并通过其代理方法处理活跃的ip
3. 监听扫描进度(可选)

```
 PNetMLanScanner *lanScanner = [PNetMLanScanner shareInstance];
 lanScanner.delegate =  self;
 [lanScanner scan];
```

### 其它功能

* 设置SDK的日志级别
* 获取设备的公网ip信息
* 随着版本的迭代，会提供更多高级功能


## NetPinger-Example 

ios平台网络诊断APP(使用的是该SDK)，支持对ip和域名的ping,traceroute(udp,icmp协议)，支持tcp ping, 端口扫描，nslookup等功能。

直接进入到`Podfile`文件所在目录安装该SDK即可成功运行。

```
macdeiMac:NetPinger ethan$ pod install 
Analyzing dependencies
Downloading dependencies
Installing PhoneNetSDK (1.0.7)
Generating Pods project
Integrating client project

[!] Please close any current Xcode sessions and use `NetPinger.xcworkspace` for this project from now on.
Sending stats
Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
```


### 项目由来

在开发中，经常会遇到接口出问题(DNS解析出错等)所以需要检测手机终端到服务端的网络是不是通,所以就需要在手机中断`ping`一下，但是市场上的免费的网络检测工具大都有弹出广告影响体验(eg:iNetTools)，所以有必要自己开发一款网络剧检测app。 

### 实现

所有的功能都是利用该SDK提供的功能实现的，页面和图标主要是模仿MAC上的`NetWork Utility`,希望对你的应用提供有价值的参考。 


## 联系我们

* 如果你有任何问题或需求，请提交[issue](https://github.com/mediaios/net-diagnosis/issues)
* 如果你要提交代码，欢迎提交 pull request
* 欢迎 `star` & `fork`
