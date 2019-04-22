//
//  MainItemInfo.h
//  NetPinger
//
//  Created by mediaios on 2018/10/17.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainItemInfo : NSObject
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString * funcName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)mainItempInfoWithDict:(NSDictionary *)dict;
@end
