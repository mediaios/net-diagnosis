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

/**
 @brief Show active ip in LAN

 @param scanner  The instance of `PNetMLanScanner`
 @param ip Active ip (Accessible device ip)
 */
- (void) scanMLan:(PNetMLanScanner *)scanner activeIp:(NSString *)ip;


/**
 @brief Show the percentage of scan progress, which is a decimal of 0-1

 @param scanner The instance of `PNetMLanScanner`
 @param percent The percentage of scan progress
 */
- (void) scanMlan:(PNetMLanScanner *)scanner percent:(float)percent;

/**
 @brief Scan all ip ends in the LAN

 @param scanner The instance of `PNetMLanScanner`
 */
- (void) finishedScanMlan:(PNetMLanScanner *)scanner;

@end

@interface PNetMLanScanner : NSObject

@property (nonatomic,weak) id<PNetMLanScannerDelegate> delegate;


/**
 @brief Get a `PNetMLanScanner` instance

 @return A `PNetMLanScanner` instance
 */
+ (instancetype)shareInstance;


/**
 @brief Start scanning ip in the LAN
 */
- (void)scan;


/**
 @brief Stop lan scanning
 */
- (void)stop;


/**
 @brief Get the status of the current LAN ip scan

 @return YES: scanning; NO: is not scanning
 */
- (BOOL)isScanning;

@end

NS_ASSUME_NONNULL_END
