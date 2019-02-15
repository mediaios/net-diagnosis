//
//  PNetModel.m
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/15.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNetModel.h"
#import "PNetInfoTool.h"

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

