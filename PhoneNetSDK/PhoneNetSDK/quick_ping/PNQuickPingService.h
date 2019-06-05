//
//  PNQuickPingService.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPingResModel.h"
#import "PReportPingModel.h"

NS_ASSUME_NONNULL_BEGIN
@class PNQuickPingService;
@protocol PNQuickPingServiceDelegate  <NSObject>

@optional
- (void)pingFinishedWithQuickPingService:(PNQuickPingService *)ucPing;
- (void)oneIpPingItemWithQuickPingService:(PNQuickPingService *)ucPing pingResult:(PReportPingModel *)pingRes;


@end



@interface PNQuickPingService : NSObject
@property (nonatomic,strong) id<PNQuickPingServiceDelegate> delegate;

+ (instancetype)shareInstance;
- (void)startPingAddressList:(NSArray *)addressList;

- (void)stop;
- (BOOL)isPing;

@end

NS_ASSUME_NONNULL_END
