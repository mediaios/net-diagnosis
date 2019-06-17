//
//  PNetTools.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/2/28.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNetTools : NSObject

+ (BOOL)validDomain:(NSString *)domain;

+ (NSInteger)currentTimestamp;
@end

NS_ASSUME_NONNULL_END
