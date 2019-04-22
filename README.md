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

* [NetPinger source code](https://github.com/mediaios/net-diagnosis/tree/master/NetPinger)
* Welcome star & fork 

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

## NetPinger-Example

Ios platform network diagnostic APP (using the SDK), support ping and domain name ping, traceroute (udp, icmp protocol), support tcp ping, port scan, nslookup and other functions.

Simply go to the directory where the `Podfile` file is located and install the SDK to run successfully.


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

### Project origin

In development, you often encounter problems with the interface (DNS resolution error, etc.), so you need to detect whether the mobile terminal to the server's network is not connected, so you need to interrupt `ping` on the mobile phone, but the free network detection tool on the market. Most have pop-up ads affecting the experience (eg: iNetTools), so it is necessary to develop a web drama detection app.

### Implementation

All functions are implemented using the functions provided by the SDK. The pages and icons are mainly imitating the `NetWork Utility` on the MAC, and hope to provide a valuable reference for your application.


## Contact us 

* If you have any questions or need any feature, please submit [issue](https://github.com/mediaios/net-diagnosis/issues)
* If you want to contribute, please submit pull request
* Welcome `star` & `fork`

