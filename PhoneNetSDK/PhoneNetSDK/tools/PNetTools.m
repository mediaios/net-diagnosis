//
//  PNetTools.m
//  PhoneNetSDK
//
//  Created by ethan on 2019/2/28.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import "PNetTools.h"

@implementation PNetTools

//
+ (BOOL)validDomain:(NSString *)domain
{
    BOOL result = NO;
    NSString *regex = @"^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [pred evaluateWithObject:domain];
    return result;
}
@end
