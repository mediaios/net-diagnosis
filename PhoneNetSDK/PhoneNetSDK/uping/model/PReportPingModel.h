//
//  PReportPingModel.h
//  PingDemo
//
//  Created by mediaios on 01/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PReportPingModel : NSObject

@property (nonatomic,assign) int totolPackets;
@property (nonatomic,assign) int loss;
@property (nonatomic,assign) float delay;
@property (nonatomic,assign) int ttl;
@property (nonatomic,copy)   NSString *src_ip;
@property (nonatomic,copy)   NSString *dst_ip;


- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)uReporterPingmodelWithDict:(NSDictionary *)dict;
- (NSDictionary *)objConvertToDict;
@end


