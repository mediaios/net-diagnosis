//
//  PhoneTraceRouteService.h
//  PingDemo
//
//  Created by ethan on 08/08/2018.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneTraceRoute.h"
#import "PTracerRouteResModel.h"
#import "PhoneNetManager.h"

@interface PhoneTraceRouteService : NSObject

+ (instancetype)shareInstance;


/*!
 @discussion
 Start traceroute a set of host addresses

 @param host ip or doman
 @param handler traceroute results
 */
- (void)startTracerouteHost:(NSString *)host resultHandler:(NetTracerouteResultHandler)handler;

- (void)uStopTracert;
- (BOOL)uIsTracert;
@end
