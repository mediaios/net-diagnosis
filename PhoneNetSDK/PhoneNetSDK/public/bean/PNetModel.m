//
//  PNetModel.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/15.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNetModel.h"
#import "PNetInfoTool.h"


static  NSString *domain = @"mediaios.sdk";
static const int KPNInvalidArguments = -2;
static const int KPNInvalidElements  = -3;
static const int KPNInvalidCondition = -4;

@implementation PNError

- (instancetype)initWithSysError:(NSError *)error
{
    if (self = [super init]) {
        _error = error;
    }
    return self;
}

+ (instancetype)errorWithInvalidArgument:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KPNInvalidArguments userInfo:@{@"error":desc}];
    return [[self alloc] initWithSysError:error];
}

+ (instancetype)errorWithInvalidElements:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KPNInvalidElements userInfo:@{@"error":desc}];
    return [[self alloc] initWithSysError:error];
}

+ (instancetype)errorWithInvalidCondition:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KPNInvalidCondition userInfo:@{@"error":desc}];
    return [[self alloc] initWithSysError:error];
}

+ (instancetype)errorWithError:(NSError *)error
{
    return [[self alloc] initWithSysError:error];
}

@end


@implementation DomainLookUpRes

- (instancetype)initWithName:(NSString *)name address:(NSString *)address
{
    if (self = [super init]) {
        _name = name;
        _ip = address;
    }
    return self;
}

+ (instancetype)instanceWithName:(NSString *)name address:(NSString *)address
{
    return [[self alloc] initWithName:name address:address];
}

@end


@implementation PDeviceNetInfo

- (instancetype)init
{
    if (self = [super init]) {
        PNetInfoTool *phoneNetTool = [PNetInfoTool shareInstance];
        [phoneNetTool refreshNetInfo];
        _netType = [phoneNetTool pGetNetworkType];
        _wifiSSID = [phoneNetTool pGetSSID];
        _wifiBSSID = [phoneNetTool pGetBSSID];
        _wifiIPV4 = [phoneNetTool pGetWifiIpv4];
        _wifiIPV6 = [phoneNetTool pGetWifiIpv6];
        _wifiNetmask = [phoneNetTool pGetSubNetMask];
        _cellIPV4 = [phoneNetTool pGetCellIpv4];
    }
    return self;
}

+ (instancetype)deviceNetInfo
{
    return [[self alloc] init];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"netType:%@ , wifiSSID:%@ , wifiBSSID:%@, wifiIPV4:%@, wifiIPV6:%@, wifiNetmask:%@, cellIPV4:%@",self.netType,self.wifiSSID,self.wifiBSSID,self.wifiIPV4,self.wifiIPV6,self.wifiNetmask,self.cellIPV4];
}

@end


@implementation PIpInfoModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        if (dict[@"ip"]) {
            _ip =        dict[@"ip"];
        }
        if (dict[@"city"]) {
            _city =      dict[@"city"];
        }
        if (dict[@"region"]) {
            _region =    dict[@"region"];
        }
        if (dict[@"country"]) {
            _country =   dict[@"country"];
        }
        if (dict[@"loc"]) {
            _location =  dict[@"loc"];
        }
        if (dict[@"org"]) {
            _org      =  dict[@"org"];
        }
        
    }
    return self;
}

+ (instancetype)uIpInfoModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    return @{@"ip":self.ip,@"city":self.city,@"region":self.region,@"country":self.country,@"location":self.location,@"org":self.org};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ip:%@ , city:%@ , region:%@ , country:%@ , location:%@ , org:%@",self.ip,self.city,self.region,self.country,self.location,self.org];
}
@end

@implementation NetWorkInfo

@end

