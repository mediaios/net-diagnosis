//
//  PTracerRouteResModel.h
//  PingDemo
//
//  Created by mediaios on 07/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum Enum_Traceroute_Status
{
    Enum_Traceroute_Status_doing = 0,
    Enum_Traceroute_Status_finish
}Enum_Traceroute_Status;


@interface PTracerRouteResModel : NSObject

@property (readonly) NSInteger hop;
@property NSString* ip;
@property NSTimeInterval* durations; //ms
@property (readonly) NSInteger count; //ms
@property (nonatomic,assign) Enum_Traceroute_Status status;
@property (nonatomic,copy) NSString *dstIp;


- (instancetype)init:(NSInteger)hop
               count:(NSInteger)count;
@end
