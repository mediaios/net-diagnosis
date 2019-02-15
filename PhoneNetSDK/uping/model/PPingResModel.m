//
//  UPingResModel.m
//  PingDemo
//
//  Created by ethan on 31/07/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PPingResModel.h"

@implementation PPingResModel

- (NSString *)description {
    return [NSString stringWithFormat:@"ICMPSequence:%d , originalAddress:%@ , IPAddress:%@ , dateBytesLength:%d , timeMilliseconds:%.3fms , timeToLive:%d , tracertCount:%d , status：%d",(int)_ICMPSequence,_originalAddress,_IPAddress,(int)_dateBytesLength,_timeMilliseconds,(int)_timeToLive,(int)_tracertCount,(int)_status];
}

+ (NSDictionary *)pingResultWithPingItems:(NSArray *)pingItems
{
    
    NSString *address = [pingItems.firstObject originalAddress];
    NSString *dst     = [pingItems.firstObject IPAddress];
    __block NSInteger receivedCount = 0, allCount = 0;
    __block NSInteger ttlSum = 0;
    __block double    timeSum = 0;
    [pingItems enumerateObjectsUsingBlock:^(PPingResModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.status != PhoneNetPingStatusFinished && obj.status != PhoneNetPingStatusError) {
            allCount ++;
            if (obj.status == PhoneNetPingStatusDidReceivePacket) {
                receivedCount ++;
                ttlSum += obj.timeToLive;
                timeSum += obj.timeMilliseconds;
            }
        }
    }];
    
    float lossPercent = (allCount - receivedCount) / MAX(1.0, allCount) * 100;
    double avgTime = 0; NSInteger avgTTL = 0;
    int allPacketCount = (int)allCount;
    if (receivedCount > 0) {
        avgTime = timeSum/receivedCount;
        avgTTL = ttlSum/receivedCount;
    }else{
        avgTime = 0;
        avgTTL = 0;
    }
    //        NSLog(@"address:%@ ,loss:%f,ttl:%ld, time:%f",address,lossPercent,avgTTL,avgTime);
    
    if (address == NULL) {
        address = @"null";
    }
    
    NSDictionary *dict = @{@"src_ip":address,@"dst_ip":dst,@"totolPackets":[NSNumber numberWithInt:allPacketCount], @"loss":[NSNumber numberWithFloat:lossPercent],@"delay":[NSNumber  numberWithDouble:avgTime],@"ttl":[NSNumber numberWithLong:avgTTL]};
    return dict;
    
    return NULL;
}
@end
