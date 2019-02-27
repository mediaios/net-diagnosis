# iOS network diagnostics sdk

## [阅读中文文档](https://github.com/mediaios/net-diagnosis/blob/master/README_CN.md)

## Introduction


By ingegrating `iOS network diagnostics sdk` you can easily do ping/traceroute/mobile public network information/port scanning on IPhone.

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

### traceroute

```
 [[PhoneNetManager shareInstance] netStartTraceroute:@"www.baidu.com" tracerouteResultHandler:^(NSString * _Nullable tracertRes, NSString * _Nullable destIp) {
     // your processing logic                
  }];
```

### Ohter functions

* Setting SDK log level
* Get device public ip info 


## Contact us 

* If you have any questions or need any feature, please submit [issue](https://github.com/mediaios/net-diagnosis/issues)
* If you want to contribute, please submit pull request

