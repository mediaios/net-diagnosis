//
//  PNQuickPing.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPingResModel.h"
#import "PhoneNetDiagnosisHelper.h"

NS_ASSUME_NONNULL_BEGIN
@class PNQuickPing;
@protocol PNQuickPingDelegate  <NSObject>

@optional
- (void)oneIpPingFinishedWithQuickPing:(PNQuickPing *)ucPing;
- (void)oneIpPingItemWithQuickPing:(PNQuickPing *)ucPing pingResult:(PPingResModel *)pingRes pingStatus:(PhoneNetPingStatus)status;


@end


@interface PNQuickPing : NSObject

@property (nonatomic,strong) id<PNQuickPingDelegate> delegate;

- (void)startPingHost:(NSArray *)hostList;

- (void)stop;
- (BOOL)isPing;

@end

NS_ASSUME_NONNULL_END
