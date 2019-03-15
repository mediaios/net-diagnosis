//
//  PNTcpPing.m
//  PhoneNetSDK
//
//  Created by ethan on 2019/3/11.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNTcpPing.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>

#include <netinet/in.h>
#include <netinet/tcp.h>

@interface PNTcpPingResult()

- (instancetype)init:(NSString *)ip
                loss:(NSUInteger)loss
               count:(NSUInteger)count
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime;

@end

@implementation PNTcpPingResult

- (instancetype)init:(NSString *)ip
                loss:(NSUInteger)loss
               count:(NSUInteger)count
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime
{
    if (self = [super init]) {
        _ip = ip;
        _loss = loss;
        _count = count;
        _max_time = maxTime;
        _avg_time = avgTime;
        _min_time = minTime;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"TCP conn loss=%lu,  min/avg/max = %.2f/%.2f/%.2fms",(unsigned long)self.loss,self.min_time,self.avg_time,self.max_time];
}

@end


@interface PNTcpPing()
{
    struct sockaddr_in addr;
}
@property (nonatomic,readonly) NSString  *host;
@property (nonatomic,readonly) NSUInteger port;
@property (nonatomic,readonly) NSUInteger count;
@property (copy,readonly) PNTcpPingHandler complete;
@property (atomic) BOOL isStop;

@property (nonatomic,copy) NSMutableString *pingDetails;
@end

@implementation PNTcpPing

- (instancetype)init:(NSString *)host
                port:(NSUInteger)port
               count:(NSUInteger)count
            complete:(PNTcpPingHandler)complete
{
    if (self = [super init]) {
        _host = host;
        _port = port;
        _count = count;
        _complete = complete;
        _isStop = NO;
    }
    return self;
}

+ (instancetype)start:(NSString * _Nonnull)host
             complete:(PNTcpPingHandler _Nonnull)complete
{
    return [[self class] start:host port:80 count:3 complete:complete];
}

+ (instancetype)start:(NSString * _Nonnull)host
                 port:(NSUInteger)port
                count:(NSUInteger)count
             complete:(PNTcpPingHandler _Nonnull)complete
{
    PNTcpPing *tcpPing = [[PNTcpPing alloc] init:host port:port count:count complete:complete];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [tcpPing sendAndRec];
    });
    return tcpPing;
}

- (BOOL)isTcpPing
{
    return !_isStop;
}
- (void)stopTcpPing
{
    _isStop = YES;
}

- (void)sendAndRec
{
    _pingDetails = [NSMutableString stringWithString:@"\n"];
    NSString *ip = [self convertDomainToIp:_host];
    if (ip == NULL) {
        return;
    }
    NSTimeInterval *intervals = (NSTimeInterval *)malloc(sizeof(NSTimeInterval) * _count);
    int index = 0;
    int r = 0;
    int loss = 0;
    do {
        NSDate *t_begin = [NSDate date];
        r = [self connect:&addr];
        NSTimeInterval conn_time = [[NSDate date] timeIntervalSinceDate:t_begin];
        intervals[index] = conn_time * 1000;
        if (r == 0) {
//            NSLog(@"connected to %s:%lu, %f ms\n",inet_ntoa(addr.sin_addr), (unsigned long)_port, conn_time * 1000);
            [_pingDetails appendString:[NSString stringWithFormat:@"conn to %@:%lu,  %.2f ms \n",ip,_port,conn_time * 1000]];
        } else {
            NSLog(@"connect failed to %s:%lu, %f ms, error %d\n",inet_ntoa(addr.sin_addr), (unsigned long)_port, conn_time * 1000, r);
            [_pingDetails appendString:[NSString stringWithFormat:@"connect failed to %s:%lu, %f ms, error %d\n",inet_ntoa(addr.sin_addr), (unsigned long)_port, conn_time * 1000, r]];
            loss++;
        }
        _complete(_pingDetails);
        if (index < _count && !_isStop && r == 0) {
            usleep(1000*100);
        }
    } while (++index < _count && !_isStop &&  r == 0);
    
    NSInteger code = r;
    if (_isStop) {
        code = -5;
    }else{
        _isStop = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNTcpPingResult *pingRes  = [self constPingRes:code ip:ip durations:intervals loss:loss count:index];
        [self.pingDetails appendString:pingRes.description];
        self.complete(self.pingDetails);
        free(intervals);
    });
}

- (int)connect:(struct sockaddr_in *)addr{
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == -1) {
        return errno;
    }
    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on));
    
    struct timeval timeout;
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout));
    
    if (connect(sock, (struct sockaddr *)addr, sizeof(struct sockaddr)) < 0) {
        int err = errno;
        close(sock);
        return err;
    }
    close(sock);
    return 0;
}

- (NSString *)convertDomainToIp:(NSString *)host
{
    const char *hostaddr = [host UTF8String];
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    if (hostaddr == NULL) {
        hostaddr = "\0";
    }
    addr.sin_addr.s_addr = inet_addr(hostaddr);
    
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *remoteHost = gethostbyname(hostaddr);
        if (remoteHost == NULL || remoteHost->h_addr == NULL) {
            [_pingDetails appendString:[NSString stringWithFormat:@"access %@ DNS error..\n",host]];
            _complete(_pingDetails);
            return NULL;
        }
        addr.sin_addr = *(struct in_addr *)remoteHost->h_addr;
        return [NSString stringWithFormat:@"%s",inet_ntoa(addr.sin_addr)];
    }
    return host;
}

- (PNTcpPingResult *)constPingRes:(NSInteger)code
                               ip:(NSString *)ip
                        durations:(NSTimeInterval *)durations
                             loss:(NSUInteger)loss
                            count:(NSUInteger)count
{
    if (code != 0 && code != -5) {
        return [[PNTcpPingResult alloc] init:ip loss:1 count:1 max:0 min:0 avg:0];
    }
    
    NSTimeInterval max = 0;
    NSTimeInterval min = 10000000;
    NSTimeInterval sum = 0;
    for (int i= 0; i < count; i++) {
        if (durations[i] > max) {
            max = durations[i];
        }
        if (durations[i] < min) {
            min = durations[i];
        }
        sum += durations[i];
    }
    
    NSTimeInterval avg = sum/count;
    return [[PNTcpPingResult alloc] init:ip loss:loss count:count max:max min:min avg:avg];
}
@end
