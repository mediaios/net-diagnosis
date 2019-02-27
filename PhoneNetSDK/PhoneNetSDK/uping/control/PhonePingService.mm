//
//  UCPingService.m
//  PingDemo
//
//  Created by ethan on 06/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "PhonePingService.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"


@interface PhonePingService()<PhonePingDelegate>
@property (nonatomic,strong) PhonePing *uPing;
@property (nonatomic,strong) NSMutableDictionary *pingResDic;
@property (nonatomic,copy,readonly) NetPingResultHandler pingResultHandler;

@end

@implementation PhonePingService

static PhonePingService *ucPingservice_instance = NULL;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableDictionary *)pingResDic
{
    if (!_pingResDic) {
        _pingResDic = [NSMutableDictionary dictionary];
    }
    return _pingResDic;
}

+ (instancetype)shareInstance
{
    if (ucPingservice_instance == NULL) {
        ucPingservice_instance = [[PhonePingService alloc] init];
    }
    return ucPingservice_instance;
}

- (void)uStopPing
{
    [self.uPing stopPing];
}

- (BOOL)uIsPing
{
    return [self.uPing isPing];
}

- (void)addPingResToPingResContainer:(PPingResModel *)pingItem andHost:(NSString *)host
{
    if (host == NULL || pingItem == NULL) {
        return;
    }
    
    NSMutableArray *pingItems = [self.pingResDic objectForKey:host];
    if (pingItems == NULL) {
        pingItems = [NSMutableArray arrayWithArray:@[pingItem]];
    }else{

        try {
            [pingItems addObject:pingItem];
        } catch (NSException *exception) {
            log4cplus_warn("PhoneNetPing", "func: %s, exception info: %s , line: %d",__func__,[exception.description UTF8String],__LINE__);
        }
    }
    
    [self.pingResDic setObject:pingItems forKey:host];
//        NSLog(@"%@",self.pingResDic);

    if (pingItem.status == PhoneNetPingStatusFinished) {
        NSArray *pingItems = [self.pingResDic objectForKey:host];
        NSDictionary *dict = [PPingResModel pingResultWithPingItems:pingItems];
//            NSLog(@"dict----res:%@, pingRes:%@",dict,self.pingResDic);
        PReportPingModel *reportPingModel = [PReportPingModel uReporterPingmodelWithDict:dict];
        
        NSString *pingSummary = [NSString stringWithFormat:@"%d packets transmitted , loss:%d , delay:%0.3fms , ttl:%d",reportPingModel.totolPackets,reportPingModel.loss,reportPingModel.delay,reportPingModel.ttl];
        self.pingResultHandler(pingSummary);
        
        [self removePingResFromPingResContainerWithHostName:host];
    }
}

- (void)removePingResFromPingResContainerWithHostName:(NSString *)host
{
    if (host == NULL) {
        return;
    }
    [self.pingResDic removeObjectForKey:host];
}

- (void)startPingHost:(NSString *)host packetCount:(int)count resultHandler:(NetPingResultHandler)handler
{
    if (_uPing) {
        _uPing = nil;
        _uPing = [[PhonePing alloc] init];

    }else{
        _uPing = [[PhonePing alloc] init];
    }
    _pingResultHandler = handler;
    _uPing.delegate = self;
    [_uPing startPingHosts:host packetCount:count];
    
}

#pragma mark-UCPingDelegate
- (void)pingResultWithUCPing:(PhonePing *)ucPing pingResult:(PPingResModel *)pingRes pingStatus:(PhoneNetPingStatus)status
{

    [self addPingResToPingResContainer:pingRes andHost:pingRes.IPAddress];
    
    if (status == PhoneNetPingStatusFinished) {
        return;
    }
    
    NSString *pingDetail = [NSString stringWithFormat:@"%d bytes form %@: icmp_seq=%d ttl=%d time=%.3fms",(int)pingRes.dateBytesLength,pingRes.IPAddress,(int)pingRes.ICMPSequence,(int)pingRes.timeToLive,pingRes.timeMilliseconds];
    _pingResultHandler(pingDetail);
}


@end
