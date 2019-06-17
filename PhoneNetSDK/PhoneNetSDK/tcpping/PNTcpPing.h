//
//  PNTcpPing.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/3/11.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNTcpPingResult : NSObject
@property (readonly) NSString *ip;
@property (readonly) NSUInteger loss;
@property (readonly) NSUInteger count;  
@property (readonly) NSTimeInterval max_time;
@property (readonly) NSTimeInterval avg_time;
@property (readonly) NSTimeInterval min_time;

@end

typedef void (^PNTcpPingHandler)(NSMutableString *);

@interface PNTcpPing : NSObject


/**
 @brief start TCP ping
 
 @discussion the default port is 80

 @param host domain or ip
 @param complete tcp ping callback
 @return `PNTcpPing` instance
 */
+ (instancetype)start:(NSString * _Nonnull)host
             complete:(PNTcpPingHandler _Nonnull)complete;


/**
 @brief start TCP ping

 @param host domain or ip
 @param port port number
 @param count ping times
 @param complete tcp ping callback
 @return `PNTcpPing` instance
 */
+ (instancetype)start:(NSString * _Nonnull)host
                 port:(NSUInteger)port
                count:(NSUInteger)count
             complete:(PNTcpPingHandler _Nonnull)complete;


/**
 @brief check is doing tcp ping now.

 @return YES: is doing; NO: is not doing
 */
- (BOOL)isTcpPing;


/**
 @brief stop tcp ping
 */
- (void)stopTcpPing;


@end


