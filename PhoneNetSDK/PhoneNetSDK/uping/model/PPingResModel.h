//
//  UPingResModel.h
//  PingDemo
//
//  Created by mediaios on 31/07/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PhoneNetPingStatus) {
    PhoneNetPingStatusDidStart,
    PhoneNetPingStatusDidFailToSendPacket,
    PhoneNetPingStatusDidReceivePacket,
    PhoneNetPingStatusDidReceiveUnexpectedPacket,
    PhoneNetPingStatusDidTimeout,
    PhoneNetPingStatusError,
    PhoneNetPingStatusFinished,
};

@interface PPingResModel : NSObject

@property(nonatomic) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;
@property(nonatomic) NSUInteger dateBytesLength;
@property(nonatomic) float     timeMilliseconds;
@property(nonatomic) NSInteger  timeToLive;
@property(nonatomic) NSInteger   tracertCount;
@property(nonatomic) NSInteger  ICMPSequence;
@property(nonatomic) PhoneNetPingStatus status;

+ (NSDictionary *)pingResultWithPingItems:(NSArray *)pingItems;

@end
