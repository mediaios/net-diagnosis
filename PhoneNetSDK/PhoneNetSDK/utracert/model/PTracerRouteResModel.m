//
//  PTracerRouteResModel.m
//  PingDemo
//
//  Created by ethan on 07/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PTracerRouteResModel.h"

@implementation PTracerRouteResModel
- (instancetype)init:(NSInteger)hop
               count:(NSInteger)count {
    if (self = [super init]) {
        _ip = nil;
        _hop = hop;
        _durations = (NSTimeInterval*)calloc(count, sizeof(NSTimeInterval));
        _count = count;
        _status = Enum_Traceroute_Status_doing;
    }
    return self;
}

- (NSString*)description {
    NSMutableString *mutableStr = [NSMutableString string];
    for (int i = 0; i < _count; i++) {
        if (_durations[i] <= 0) {
            [mutableStr appendString:@"* "];
        }else{
            [mutableStr appendString:[NSString stringWithFormat:@" %.3fms",_durations[i] * 1000]];
        }
    }
    return [NSString stringWithFormat:@"seq:%d , dstIp:%@, routeIp:%@, durations:%@ , status:%d",(int)_hop,_dstIp,_ip,mutableStr,(int)_status];
}


- (void)dealloc {
    free(_durations);
}
@end
