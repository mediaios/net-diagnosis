//
//  PhonePing.h
//  PingDemo
//
//  Created by ethan on 03/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPingResModel.h"
#import "PhoneNetDiagnosisHelper.h"

@class PhonePing;

@protocol PhonePingDelegate  <NSObject>

@optional
- (void)pingResultWithUCPing:(PhonePing *)ucPing pingResult:(PPingResModel *)pingRes pingStatus:(PhoneNetPingStatus)status;


@end

@interface PhonePing : NSObject

@property (nonatomic,strong) id<PhonePingDelegate> delegate;

- (void)startPingHosts:(NSString *)host packetCount:(int)count;

- (void)stopPing;
- (BOOL)isPing;
@end
