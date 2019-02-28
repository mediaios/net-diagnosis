//
//  PNetModel.h
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/15.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNError : NSObject

/**
 *  系统错误信息
 */
@property (nonatomic,readonly) NSError *error;


/**
 @brief 构造错误(参数错误，内部使用)
 
 @param desc 错误信息
 @return 错误实例
 */
+ (instancetype)errorWithInvalidArgument:(NSString *)desc;

/**
 @brief 构造错误(容器中的元素非法，内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)errorWithInvalidElements:(NSString *)desc;

/**
 @brief 构造错误(调用SDK中的方法时，条件不满足。内部使用)
 
 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)errorWithInvalidCondition:(NSString *)desc;

/**
 @brief 构造错误(内部使用)
 
 @param error 系统错误实例
 @return 错误实例
 */
+ (instancetype)errorWithError:(NSError *)error;
@end


@interface DomainLookUpRes : NSObject
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * ip;

+ (instancetype)instanceWithName:(NSString *)name address:(NSString *)address;
@end


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
