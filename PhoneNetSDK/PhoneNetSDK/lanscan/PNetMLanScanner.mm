//
//  PNetMLanScanner.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNetMLanScanner.h"
#import "PReportPingModel.h"
#import "PNetInfoTool.h"
#import "PNetModel.h"
#import "PNetworkCalculator.h"
#import "PNSamplePing.h"
#import "PhoneNetSDKConst.h"
#include "log4cplus_pn.h"

@interface PNetMLanScanner()<PNSamplePingDelegate>
@property (nonatomic,assign) int cursor;
@property (nonatomic,copy) NSArray *ipList;
@property (nonatomic,strong) NSMutableArray *activedIps;
@property (nonatomic,strong) PNSamplePing *samplePing;
@end

@implementation PNetMLanScanner


- (NSMutableArray *)activedIps
{
    if (!_activedIps) {
        _activedIps = [NSMutableArray array];
    }
    return _activedIps;
}

- (PNSamplePing *)samplePing
{
    if (!_samplePing) {
        _samplePing = [[PNSamplePing alloc] init];
        _samplePing.delegate = self;
    }
    return _samplePing;
}

- (instancetype)init
{
    if (self = [super init]) {
        _cursor = 0;
        [self addObserver:self forKeyPath:@"cursor" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

static PNetMLanScanner *lanScanner_instance = nil;
+ (instancetype)shareInstance
{
    if (!lanScanner_instance) {
        lanScanner_instance = [[PNetMLanScanner alloc] init];
    }
    return lanScanner_instance;
}

- (void)scan
{
    PNetInfoTool *phoneNetTool = [PNetInfoTool shareInstance];
    [phoneNetTool refreshNetInfo];
    if ([phoneNetTool.pGetNetworkType isEqualToString:@"WIFI"]) {
        PDeviceNetInfo *device = [PDeviceNetInfo deviceNetInfo];
        
        NSString *ip = device.wifiIPV4;
        NSString *netMask = device.wifiNetmask;
        if (ip && netMask) {
            log4cplus_debug("PhoneNetSDK-LanScanner", "now device ip :%s , netMask:%s \n",[ip UTF8String],[netMask UTF8String]);
            _ipList = [PNetworkCalculator getAllHostsForIP:ip andSubnet:netMask];
            if (!_ipList && _ipList.count <= 0) {
                log4cplus_error("PhoneNetSDK-LanScanner", "caculating the ip list in the current LAN failed...\n");
                return;
            }
            log4cplus_debug("PhoneNetSDK-LanScanner", "scan ip %s begin...",[self.ipList[self.cursor] UTF8String]);
            [self.samplePing startPingIp:self.ipList[self.cursor] packetCount:3];
            self.cursor++;
        }
    }
}

#pragma mark - PNSamplePingDelegate
- (void)simplePing:(PNSamplePing *)samplePing didTimeOut:(NSString *)ip
{
    
}

- (void)simplePing:(PNSamplePing *)samplePing receivedPacket:(NSString *)ip
{
    log4cplus_debug("PhoneNetSDK-LanScanner", " %s  active",[ip UTF8String]);
    [self.delegate scanMLan:self activeIp:ip];
}

- (void)simplePing:(PNSamplePing *)samplePing pingError:(NSException *)exception
{
    
}

- (void)simplePing:(PNSamplePing *)samplePing finished:(NSString *)ip
{
    
    _samplePing = nil;
    _samplePing = [[PNSamplePing alloc] init];
    _samplePing.delegate = self;
    if (self.cursor < self.ipList.count) {
        [_samplePing startPingIp:self.ipList[self.cursor] packetCount:2];
    }
    self.cursor++;
}

- (void)resetPropertys
{
    _cursor = 0;
    _ipList = nil;
    _activedIps = nil;
    log4cplus_debug("PhoneNetSDK-LanScanner", "reseter propertys...\n");
}

#pragma mark - use KVO to observer progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    float newCursor = [[change objectForKey:@"new"] floatValue];
    if ([keyPath isEqualToString:@"cursor"]) {
        float percent = self.ipList.count == 0 ? 0.0f : ((float)newCursor/self.ipList.count);
        [self.delegate scanMlan:self percent:percent];
        log4cplus_debug("PhoneNetSDK-LanScanner", "percent: %f  \n",percent);
        if (newCursor == self.ipList.count) {
            log4cplus_debug("PhoneNetSDK-LanScanner", "finish MLAN scan...\n");
            [self.delegate finishedScanMlan:self];
            [self removeObserver:self forKeyPath:@"cursor"];
            [self resetPropertys];
        }
    }
}
@end
