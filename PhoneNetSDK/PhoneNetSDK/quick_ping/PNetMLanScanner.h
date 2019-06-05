//
//  PNetMLanScanner.h
//  PhoneNetSDK
//
//  Created by mediaios on 2019/6/5.
//  Copyright © 2019年 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PNetMLanScanner;
@protocol PNetMLanScannerDelegate <NSObject>

@optional
- (void) scanMLan:(PNetMLanScanner *)scanner activeIp:(NSString *)ip;
- (void) finishedScanMlan:(PNetMLanScanner *)scanner;

@end

@interface PNetMLanScanner : NSObject

@property (nonatomic,weak) id<PNetMLanScannerDelegate> delegate;

- (void)start;

@end

NS_ASSUME_NONNULL_END
