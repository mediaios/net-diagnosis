//
//  PNSamplePing.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPingResModel.h"
#import "PhoneNetDiagnosisHelper.h"

NS_ASSUME_NONNULL_BEGIN
@class PNSamplePing;
@protocol PNSamplePingDelegate <NSObject>

@optional
- (void)simplePing:(PNSamplePing *)samplePing didTimeOut:(NSString *)ip;
- (void)simplePing:(PNSamplePing *)samplePing receivedPacket:(NSString *)ip;
- (void)simplePing:(PNSamplePing *)samplePing pingError:(NSException *)exception;
- (void)simplePing:(PNSamplePing *)samplePing finished:(NSString *)ip;

@end



@interface PNSamplePing : NSObject

@property (nonatomic,weak) id<PNSamplePingDelegate> delegate;

- (void)startPingIp:(NSString *)ip packetCount:(int)count;

- (void)stopPing;
- (BOOL)isPing;
@end

NS_ASSUME_NONNULL_END
