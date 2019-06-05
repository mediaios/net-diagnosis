//
//  PNetMLanScanner.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNetMLanScanner.h"
//#import "PNQuickPingService.h"
#import "PReportPingModel.h"
#import "PNetInfoTool.h"
#import "PNetModel.h"
#import "PNetworkCalculator.h"
#import "PNSamplePing.m"

@interface PNetMLanScanner()<PNSamplePingDelegate>
@property (nonatomic,assign) int index;
@property (nonatomic,copy) NSArray *arrayList;
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

- (void)start
{
    _index = 0;
    PNetInfoTool *phoneNetTool = [PNetInfoTool shareInstance];
    [phoneNetTool refreshNetInfo];
    if ([phoneNetTool.pGetNetworkType isEqualToString:@"WIFI"]) {
        PDeviceNetInfo *device = [PDeviceNetInfo deviceNetInfo];
        
        NSString *ip = device.wifiIPV4;
        NSString *netMask = device.wifiNetmask;
        if (ip && netMask) {
            _arrayList = [PNetworkCalculator getAllHostsForIP:ip andSubnet:netMask];
            if (!_arrayList && _arrayList.count <= 0) {
                NSLog(@"计算ip列表失败...");
                return;
            }
            NSLog(@"qizhang---debug--netmask:%@----ip :%@",netMask,ip);
            NSLog(@"qizhang---debug---iplist: %@",_arrayList);
            [self.samplePing startPingHosts:self.arrayList[_index] packetCount:3];
            _index++;
//            [PNQuickPingService shareInstance].delegate = self;
//            NSString *array1 = [arrayList objectAtIndex:0];
//            arrayList = @[@"192.168.187.1"];
//            [[PNQuickPingService shareInstance] startPingAddressList:@[_arrayList[_index]]];
//            _index++;
            // 192.168.187.1
            
            
        }
        
    }
    
   
}

#pragma mark - PNSamplePingDelegate
- (void)simplePing:(PNSamplePing *)samplePing didTimeOut:(NSString *)ip
{
    
}

- (void)simplePing:(PNSamplePing *)samplePing receivedPacket:(NSString *)ip
{
    NSLog(@"qizhang--debug----activited ip : %@",ip);
}

- (void)simplePing:(PNSamplePing *)samplePing pingError:(NSException *)exception
{
    
}

- (void)simplePing:(PNSamplePing *)samplePing finished:(NSString *)ip
{
    NSLog(@"qizhang--debug----finished : %@",ip);
    _samplePing = nil;
    _samplePing = [[PNSamplePing alloc] init];
    _samplePing.delegate = self;
    if (self.index < self.arrayList.count) {
        [_samplePing startPingHosts:self.arrayList[self.index] packetCount:2];
    }
    _index++;
}


//#pragma mark - PNQuickPingServiceDelegate
//- (void)pingFinishedWithQuickPingService:(PNQuickPingService *)ucPing
//{
//    [[PNQuickPingService shareInstance] startPingAddressList:@[_arrayList[_index]]];
//    _index++;
//    NSLog(@"%@",ucPing);
//}
//
//- (void)oneIpPingItemWithQuickPingService:(PNQuickPingService *)ucPing pingResult:(PReportPingModel *)pingRes
//{
//    NSLog(@"%@",pingRes);
//}

@end
