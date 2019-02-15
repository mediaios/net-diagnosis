//
//  PNetModel.h
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/15.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDeviceNetInfo : NSObject
@property (nonatomic,readonly) NSString *netType;
@property (nonatomic,readonly) NSString *wifiSSID;
@property (nonatomic,readonly) NSString *wifiBSSID;
@property (nonatomic,readonly) NSString *wifiIPV4;
@property (nonatomic,readonly) NSString *wifiNetmask;
@property (nonatomic,readonly) NSString *wifiIPV6;
@property (nonatomic,readonly) NSString *cellIPV4;

+ (instancetype)deviceNetInfo;
@end


@interface PIpInfoModel : NSObject
@property (nonatomic,readonly) NSString *ip;
@property (nonatomic,readonly) NSString *city;
@property (nonatomic,readonly) NSString *region;
@property (nonatomic,readonly) NSString *country;
@property (nonatomic,readonly) NSString *location;
@property (nonatomic,readonly) NSString *org;

+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToDict;
@end

@interface NetWorkInfo : NSObject
@property (nonatomic,strong) PDeviceNetInfo *deviceNetInfo;
@property (nonatomic,strong) PIpInfoModel   *ipInfoModel;
@end


NS_ASSUME_NONNULL_END
