//
//  PNetQueue.h
//  UNetAnalysisSDK
//
//  Created by mediaios on 2019/1/22.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNetQueue : NSObject

+ (void)pnet_ping_async:(dispatch_block_t)block;
+ (void)pnet_trace_async:(dispatch_block_t)block;
+ (void)pnet_async:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
