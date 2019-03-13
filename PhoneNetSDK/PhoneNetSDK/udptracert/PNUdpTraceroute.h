//
//  PNUdpTraceroute.h
//  PhoneNetSDK
//
//  Created by ethan on 2019/3/13.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PNUdpTracerouteHandler)(NSMutableString *);


@interface PNUdpTraceroute : NSObject

/**
 @brief start udp traceroute.

 @discussion The default max TTL is 30, each route sends 3 udp packets. If there are five routes continuously losing 3 udp packets, the traceroute is terminated.
 
 @param host ip or domain
 @param complete udp traceroute result callback
 @return a `PNUdpTraceroute` instance.
 */
+ (instancetype)start:(NSString * _Nonnull)host
             complete:(PNUdpTracerouteHandler _Nonnull)complete;


/**
 @brief start udp traceroute.
 
 @discussion Use the max ttl you set to do traceroute

 @param host ip or domain
 @param maxTtl the max ttl
 @param complete udp traceroute result callback
 @return a `PNUdpTraceroute` instance.
 */
+ (instancetype)start:(NSString * _Nonnull)host
               maxTtl:(NSUInteger)maxTtl
             complete:(PNUdpTracerouteHandler _Nonnull)complete;


/**
 @brief get now is doing udp traceroute or not.

 @return YES: is doing; NO: is not doing
 */
- (BOOL)isDoingUdpTraceroute;


/**
 @brief stop udp traceroute
 */
- (void)stopUdpTraceroute;

@end

