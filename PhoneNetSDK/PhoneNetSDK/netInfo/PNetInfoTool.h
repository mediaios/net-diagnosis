//
//  PNetInfoTool.h
//  PhoneNetSDK
//
//  Created by ethan on 2018/10/16.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNetInfoTool : NSObject


+ (instancetype)shareInstance;
- (void)refreshNetInfo;

#pragma mark - for wifi
- (NSString*)pGetNetworkType;
- (NSString *)pGetSSID;
- (NSString *)pGetBSSID;
- (NSString *)pGetWifiIpv4;
- (NSString *)pGetSubNetMask;
- (NSString *)pGetWifiIpv6;
- (NSString *)pGetCellIpv4;


@end
