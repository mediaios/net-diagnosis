//
//  MainItemInfo.m
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import "MainItemInfo.h"

@implementation MainItemInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.funcName = dict[@"funcName"];
        self.icon = dict[@"icon"];
    }
    return self;
}
+ (instancetype)mainItempInfoWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
