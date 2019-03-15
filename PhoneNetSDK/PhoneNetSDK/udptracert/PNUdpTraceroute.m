//
//  PNUdpTraceroute.m
//  PhoneNetSDK
//
//  Created by ethan on 2019/3/13.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNUdpTraceroute.h"
#include <AssertMacros.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>

#import <netinet/in.h>
#import <netinet/tcp.h>

#import <sys/select.h>
#import <sys/time.h>

#import "PNetQueue.h"


#define  kUpdTracertSendIcmpPacketTimes            3   // 对一个中间节点，发送3个udp包
#define  kUdpTracertMaxTTL                        30   // Max 30 hops（最多30跳）

@interface PNUdpTracerouteDetail:NSObject
@property (readonly) NSUInteger seq;   // 第几跳
@property (nonatomic,copy) NSString * routeIp;  // 中间路由ip
@property (nonatomic) NSTimeInterval *durations;   // 存储时间
@property (readonly) NSUInteger sendTimes;  // 每个路由发几个包

@end


@implementation PNUdpTracerouteDetail

- (instancetype)init:(NSUInteger)seq
           sendTimes:(NSUInteger)sendTimes
{
    if (self = [super init]) {
        _routeIp = nil;
        _seq = seq;
        _durations = (NSTimeInterval *)calloc(sendTimes, sizeof(NSTimeInterval));
        _sendTimes = sendTimes;
    }
    return self;
}

- (NSString*)description {
    NSMutableString* routeDetail = [[NSMutableString alloc] initWithCapacity:20];
    [routeDetail appendFormat:@"%ld\t", (long)_seq];
    if (_routeIp == nil) {
        [routeDetail appendFormat:@" \t"];
    } else {
        [routeDetail appendFormat:@"%@\t", _routeIp];
    }
    for (int i = 0; i < _sendTimes; i++) {
        if (_durations[i] <= 0) {
            [routeDetail appendFormat:@"*\t"];
        } else {
            [routeDetail appendFormat:@"%.3f ms\t", _durations[i] * 1000];
        }
    }
    return routeDetail;
}

- (void)dealloc
{
    free(_durations);
}

@end



@interface PNUdpTraceroute()
{
    int socket_send;
    int socket_recv;
    struct sockaddr_in remote_addr;
}

@property (nonatomic,copy) NSString *host;
@property (atomic) BOOL isStop;
@property (readonly) NSInteger maxTtl;
@property (nonatomic,copy) PNUdpTracerouteHandler complete;
@property (nonatomic,strong) NSMutableString *traceDetails;

@end

@implementation PNUdpTraceroute


- (instancetype)init:(NSString *)host
              maxTtl:(NSUInteger)maxTtl
            complete:(PNUdpTracerouteHandler)complete
{
    if (self = [super init]) {
        _host = host == nil ? @"" : host;
        _maxTtl = maxTtl;
        _complete = complete;
        _isStop = NO;
    }
    return self;
}

- (void)settingUHostSocketAddressWithHost:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&remote_addr, 0, sizeof(remote_addr));
    remote_addr.sin_len = sizeof(remote_addr);
    remote_addr.sin_addr.s_addr = inet_addr(hostaddr);
    remote_addr.sin_family = AF_INET;
    remote_addr.sin_port = htons(30006);
    if (remote_addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
//            NSLog(@"access DNS error..");
            [_traceDetails appendString:@"access DNS error..\n"];
            _complete(_traceDetails);
            return;
        }
        
        remote_addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
        NSString *remoteIp = [NSString stringWithFormat:@"%s",inet_ntoa(remote_addr.sin_addr)];
        [_traceDetails appendString:[NSString stringWithFormat:@"traceroute to %@ \n",remoteIp]];
//        NSLog(@"traceroute to  %@",remoteIp);
    }
    socket_recv = socket(AF_INET,SOCK_DGRAM,IPPROTO_ICMP);
    socket_send = socket(AF_INET, SOCK_DGRAM, 0);
}

- (void)sendAndRec
{
    _traceDetails = [NSMutableString stringWithString:@"\n"];
    [self settingUHostSocketAddressWithHost:_host];
    int ttl = 1;
    in_addr_t ip = 0;
    static NSUInteger conuntinueUnreachableRoutes = 0;
    
    // 如果连续5个路由节点无响应，则终止traceroute.
    do {
        int t  = setsockopt(socket_send, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
        if (t < 0) {
            NSLog(@"error %s\n",strerror(t));
        }
        PNUdpTracerouteDetail *trace = [self sendData:ttl ip:&ip];
        if (trace.routeIp == nil) {
            conuntinueUnreachableRoutes++;
        }else{
            conuntinueUnreachableRoutes = 0;
        }
        
    } while (++ttl <= _maxTtl && ip != remote_addr.sin_addr.s_addr && !_isStop && conuntinueUnreachableRoutes < 5);
    
    close(socket_send);
    close(socket_recv);
    
    if (!_isStop) {
        _isStop = YES;
    }
    
    [_traceDetails appendString:@"udp traceroute complete...\n"];
    _complete(_traceDetails);
//    NSLog(@"udp traceroute complete...");
}


- (PNUdpTracerouteDetail *)sendData:(int)ttl ip:(in_addr_t *)ipOut
{
    int err = 0;
    struct sockaddr_in storageAddr;
    socklen_t n = sizeof(struct sockaddr);
    static char msg[24] = {0};
    char buff[100];
    
    PNUdpTracerouteDetail *trace = [[PNUdpTracerouteDetail alloc] init:ttl sendTimes:kUpdTracertSendIcmpPacketTimes];
    for (int i = 0; i < 3; i++) {
        NSDate* startTime = [NSDate date];
        ssize_t sent = sendto(socket_send, msg, sizeof(msg), 0, (struct sockaddr*)&remote_addr, sizeof(struct sockaddr));
        if (sent != sizeof(msg)) {
            NSLog(@"error %s",strerror(err));
            break;
        }
        
        struct timeval tv;
        tv.tv_sec = 3;
        tv.tv_usec = 0;
        
        fd_set readfds;
        FD_ZERO(&readfds);  // 初始化套接字集合（清空套接字集合） ,将readfds清零使集合中不含任何fd
        FD_SET(socket_recv,&readfds); // 将readfds加入set集合
        
        /*
         https://zhidao.baidu.com/question/315963155.html
         在编程的过程中，经常会遇到许多阻塞的函数，好像read和网络编程时使用的recv, recvfrom函数都是阻塞的函数，当函数不能成功执行的时候，程序就会一直阻塞在这里，无法执行下面的代码。这是就需要用到非阻塞的编程方式，使用selcet函数就可以实现非阻塞编程。
         selcet函数是一个轮循函数，即当循环询问文件节点，可设置超时时间，超时时间到了就跳过代码继续往下执行。
         Select的函数格式：
         int select(int maxfdp,fd_set *readfds,fd_set *writefds,fd_set *errorfds,struct timeval*timeout);
         select函数有5个参数
         第一个是所有文件节点的最大值加1,如果我有三个文件节点1、4、6,那第一个参数就为7（6+1）
         第二个是可读文件节点集，类型为fd_set。通过FD_ZERO(&readfd);初始化节点集；然后通过FD_SET(fd, &readfd);把需要监听是否可读的节点加入节点集
         第三个是可写文件节点集中，类型为fd_set。操作方法和第二个参数一样。
         第四个参数是检查节点错误集。
         第五个参数是超时参数，类型为struct timeval，然后可以设置超时时间，分别可设置秒timeout.tv_sec和微秒timeout.tv_usec。
         */
        select(socket_recv + 1, &readfds, NULL, NULL,&tv);
        if (FD_ISSET(socket_recv,&readfds) > 0) {
            ssize_t res = recvfrom(socket_recv, buff, sizeof(buff), 0, (struct sockaddr*)&storageAddr, &n);
            if (res < 0) {
                err = errno;
                NSLog(@"recv error %s\n",strerror(err));
                break;
            }else{
                NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
                char ip[16] = {0}; // 存放ip地址
                inet_ntop(AF_INET, &storageAddr.sin_addr.s_addr, ip, sizeof(ip));
                *ipOut = storageAddr.sin_addr.s_addr;
                NSString *routeIp = [NSString stringWithFormat:@"%s",ip];
                trace.routeIp = routeIp;
                trace.durations[i] = duration;
            }
        }

    }
//    NSLog(@"%@",trace);
    
    [_traceDetails appendString:trace.description];
    [_traceDetails appendString:@"\n"];
    _complete(_traceDetails);
    return trace;
}

+ (instancetype)start:(NSString * _Nonnull)host
             complete:(PNUdpTracerouteHandler _Nonnull)complete
{
    PNUdpTraceroute *udpTrace  = [[PNUdpTraceroute alloc] init:host maxTtl:kUdpTracertMaxTTL complete:complete];
    [PNetQueue pnet_async:^{
         [udpTrace sendAndRec];
    }];
    return udpTrace;
}

+ (instancetype)start:(NSString * _Nonnull)host
               maxTtl:(NSUInteger)maxTtl
             complete:(PNUdpTracerouteHandler _Nonnull)complete
{
    PNUdpTraceroute *udpTrace  = [[PNUdpTraceroute alloc] init:host maxTtl:maxTtl complete:complete];
    [PNetQueue pnet_async:^{
        [udpTrace sendAndRec];
    }];
    return udpTrace;
}

- (void)stopUdpTraceroute
{
    _isStop = YES;
}

- (BOOL)isDoingUdpTraceroute
{
    return !_isStop;
}

@end
