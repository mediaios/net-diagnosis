//
//  NetworkCalculator.h
//  MMLanScanDemo
//
//  Created by mediaios on 2019/1/22.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNetworkCalculator : NSObject
+(NSArray*)getAllHostsForIP:(NSString*)ipAddress andSubnet:(NSString*)subnetMask;
@end
