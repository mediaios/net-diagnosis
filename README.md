# iOS network diagnostics sdk

## [阅读中文文档](https://github.com/mediaios/net-diagnosis/blob/master/README_CN.md)

## Introduction


By ingegrating `iOS network diagnostics sdk` you can easily do ping/traceroute/mobile public network information/port scanning on IPhone.

Take a screenshot of the network diagnostic app developed with this sdk:

<div align="center">
<img src="https://ws1.sinaimg.cn/large/006tNc79gy1g25emxxojfj30d70stgos.jpg" height="500px" alt="图片说明" ><img src="https://ws1.sinaimg.cn/large/006tNc79gy1g25eq0wtczj30d80sj75p.jpg" height="500px" alt="图片说明" > <img src="https://ws4.sinaimg.cn/large/006tNc79gy1g25erdx9fqj30d50sqgom.jpg" height="500px" alt="图片说明" >   
</div>

<div align="center">
<img src="https://ws1.sinaimg.cn/large/006tNc79gy1g25f78yxwvj30d50sp41b.jpg" height="500px" alt="图片说明" ><img src="https://ws3.sinaimg.cn/large/006tNc79gy1g25f4z3p2qj30da0ss0uc.jpg" height="500px" alt="图片说明" > <img src="https://ws3.sinaimg.cn/large/006tNc79gy1g25f5ezjpuj30da0svmyb.jpg" height="500px" alt="图片说明" >   
</div>

## Environment

* iOS >= 9.0
* Xcode >= 7.0
* Setting `Enable Bitcode` to `NO`

## Installation and use

### Pod dependency 

Add the following dependencies to your project's `Podfile`:

```
pod 'PhoneNetSDK'
```

### Quick start

Import the SDK header file to the project:

```
#import <PhoneNetSDK/PhoneNetSDK.h>
```

In addition, you need to add `-lc++`,`-ObjC`,`$(inherited)` to the project's `Build Setting`->`other link flags`. As shown below:

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

The default traceroute command on the command line sends a UDP packet (referred to as udp traceroute):

```
 _udpTraceroute = [PNUdpTraceroute start:ip complete:^(NSMutableString *res) {
                    // your processinig logic
                }];
```

### ICMP traceroute

In the terminal of mac, enter `traceroute -I baidu.com` to use the ICMP protocol to do traceroute. This function is provided in sdk:

```
 [[PhoneNetManager shareInstance] netStartTraceroute:@"www.baidu.com" tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp) {
     // your processing logic                
  }];
```

### nslookup 

```
[[PhoneNetManager shareInstance] netLookupDomain:@"www.google.com" completeHandler:^(NSMutableArray<DomainLookUpRes *> * _Nullable lookupRes, PNError * _Nullable sdkError) {
	// your processing logic
}];
```

### port scan

```
[[PhoneNetManager shareInstance] netPortScan:@"www.baidu.com" beginPort:8000 endPort:9000 completeHandler:^(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError) {
	// your processing logic    
}];
```

### Ohter functions

* Setting SDK log level
* Get device public ip info 


## Contact us 

* If you have any questions or need any feature, please submit [issue](https://github.com/mediaios/net-diagnosis/issues)
* If you want to contribute, please submit pull request

