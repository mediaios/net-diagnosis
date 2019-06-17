//
//  PReportPingModel.m
//  PingDemo
//
//  Created by mediaios on 01/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PReportPingModel.h"

@implementation PReportPingModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.totolPackets = [dict[@"totolPackets"] intValue];
        self.loss  = [dict[@"loss"] intValue];
        self.delay = [dict[@"delay"] floatValue];
        self.ttl   = [dict[@"ttl"] intValue];
        self.src_ip = dict[@"src_ip"];
        self.dst_ip = dict[@"dst_ip"];
    }
    return self;
}

+ (instancetype)uReporterPingmodelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSDictionary *)objConvertToDict
{
    return @{@"loss":@(self.loss),@"delay":@(self.delay),@"src_ip":self.src_ip,@"dst_ip":self.dst_ip,@"ttl":@(self.ttl)};
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"src_ip:%@ , dst_ip:%@ , totalPackets:%d , loss:%d , delay:%@ , ttl:%d ",self.src_ip,self.dst_ip,self.totolPackets,self.loss,[NSString stringWithFormat:@"%.3fms",self.delay],self.ttl];
}

@end
