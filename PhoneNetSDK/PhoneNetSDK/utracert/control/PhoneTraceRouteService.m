//
//  PhoneTraceRouteService.m
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PhoneTraceRouteService.h"

@interface PhoneTraceRouteService()<PhoneTraceRouteDelegate>
@property (nonatomic,strong) PhoneTraceRoute *ucTraceroute;
@property (nonatomic,copy,readonly) NetTracerouteResultHandler tracertResultHandler;
@end

@implementation PhoneTraceRouteService

static PhoneTraceRouteService *ucTraceRouteService_instance = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)shareInstance
{
    if (ucTraceRouteService_instance == NULL) {
        ucTraceRouteService_instance = [[PhoneTraceRouteService alloc] init];
    }
    return ucTraceRouteService_instance;
}

- (void)uStopTracert
{
    [self.ucTraceroute stopTracert];
}

- (BOOL)uIsTracert
{
    return [self.ucTraceroute isTracert];
}

- (void)startTracerouteHost:(NSString *)host resultHandler:(NetTracerouteResultHandler)handler
{
    if (_ucTraceroute) {
        _ucTraceroute = nil;
    }
    _tracertResultHandler = handler;
    _ucTraceroute = [[PhoneTraceRoute alloc] init];
    _ucTraceroute.delegate = self;
    [_ucTraceroute startTracerouteHost:host];
}

#pragma mark -PhoneTraceRouteDelegate
- (void)tracerouteWithUCTraceRoute:(PhoneTraceRoute *)ucTraceRoute tracertResult:(PTracerRouteResModel *)tracertRes
{
    NSMutableString *tracertTimeoutRes = [NSMutableString string];
    NSMutableString *mutableDurations = [NSMutableString string];
    for (int i = 0; i < tracertRes.count; i++) {
        if (tracertRes.durations[i] <= 0) {
            [tracertTimeoutRes appendString:@" *"];
        }else{
            [mutableDurations appendString:[NSString stringWithFormat:@" %.3fms",tracertRes.durations[i] * 1000]];
        }
    }
    NSMutableString *tracertDetail = [NSMutableString string];
    if (tracertTimeoutRes.length > 0) {
        [tracertDetail appendString:[NSString stringWithFormat:@"%d %@",(int)tracertRes.hop,tracertTimeoutRes]];
        _tracertResultHandler(tracertDetail,tracertRes.dstIp);
        return;
    }
    
    NSString *tracertNormalDetail = [NSString stringWithFormat:@"%d  %@(%@) %@",(int)tracertRes.hop,tracertRes.ip,tracertRes.ip,mutableDurations];
    [tracertDetail appendString:tracertNormalDetail];
    _tracertResultHandler(tracertDetail,tracertRes.dstIp);
    
}

- (void)tracerouteFinishedWithUCTraceRoute:(PhoneTraceRoute *)ucTraceRoute
{
    
}

@end
