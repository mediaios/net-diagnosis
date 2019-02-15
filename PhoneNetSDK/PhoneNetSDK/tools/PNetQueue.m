//
//  PNetQueue.m
//  UNetAnalysisSDK
//
//  Created by ethan on 2019/1/22.
//  Copyright © 2019 mediaios. All rights reserved.
//

#import "PNetQueue.h"

@interface PNetQueue()
+ (instancetype)shareInstance;

@property (nonatomic) dispatch_queue_t pingQueue;
@property (nonatomic) dispatch_queue_t traceQueue;

@end

@implementation PNetQueue

+ (instancetype)shareInstance
{
    static PNetQueue *unetQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unetQueue = [[self alloc] init];
    });
    return unetQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _pingQueue = dispatch_queue_create("pnet_ping_queue", DISPATCH_QUEUE_SERIAL);
        _traceQueue = dispatch_queue_create("pnet_trace_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (void)pnet_ping_sync:(dispatch_block_t)block
{
    dispatch_async([PNetQueue shareInstance].pingQueue, ^{
        block();
    });
}

+ (void)pnet_trace_async:(dispatch_block_t)block
{
    dispatch_async([PNetQueue shareInstance].traceQueue , ^{
        block();
    });
}
@end
