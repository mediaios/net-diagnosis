//
//  PhoneNetSDKTests.m
//  PhoneNetSDKTests
//
//  Created by mediaios on 2018/10/15.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PhoneNetSDK/PhoneNetSDK.h>


@interface PhoneNetSDKTests : XCTestCase
@end

@implementation PhoneNetSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testping
{
    
}

- (void)testDomainLookup
{
    [[PhoneNetManager shareInstance] netLookupDomain:@"www.google.com" completeHandler:^(NSMutableArray<DomainLookUpRes *> * _Nullable lookupRes, PNError * _Nullable sdkError) {
        if (sdkError) {
            NSLog(@"%@",sdkError.error.description);
        }else{
            for (DomainLookUpRes *res in lookupRes) {
                NSLog(@"%@->%@",res.name,res.ip);
            }
        }
    }];
}

- (void)testPortScan
{
    [[PhoneNetManager shareInstance] netPortScan:@"www.baidu.com" beginPort:8000 endPort:9000 completeHandler:^(NSString * _Nullable port, BOOL isOpen, PNError * _Nullable sdkError) {
        if (sdkError) {
            NSLog(@"正在扫描---%@",port);
        }else{
            if (isOpen) {
                NSLog(@"正在扫描---%@ ,已打开",port);
            }else{
                NSLog(@"正在扫描---%@",port);
            }
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
