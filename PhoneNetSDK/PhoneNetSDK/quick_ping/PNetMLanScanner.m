//
//  PNetMLanScanner.m
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import "PNetMLanScanner.h"
#import "PNQuickPingService.h"
#import "PReportPingModel.h"
#import "PNetInfoTool.h"
#import "PNetModel.h"
#import "PNetworkCalculator.h"

@interface PNetMLanScanner()<PNQuickPingServiceDelegate>
@property (nonatomic,assign) int index;
@property (nonatomic,copy) NSArray *arrayList;
@end

@implementation PNetMLanScanner


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
            [PNQuickPingService shareInstance].delegate = self;
//            NSString *array1 = [arrayList objectAtIndex:0];
//            arrayList = @[@"192.168.187.1"];
            [[PNQuickPingService shareInstance] startPingAddressList:@[_arrayList[_index]]];
            _index++;
            // 192.168.187.1
            
            
        }
        
    }
    
   
}

#pragma mark - PNQuickPingServiceDelegate
- (void)pingFinishedWithQuickPingService:(PNQuickPingService *)ucPing
{
    [[PNQuickPingService shareInstance] startPingAddressList:@[_arrayList[_index]]];
    _index++;
    NSLog(@"%@",ucPing);
}

- (void)oneIpPingItemWithQuickPingService:(PNQuickPingService *)ucPing pingResult:(PReportPingModel *)pingRes
{
    NSLog(@"%@",pingRes);
}

@end
