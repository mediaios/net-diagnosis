//
//  PhoneNetSDKTests.m
//  PhoneNetSDKTests
//
//  Created by ethan on 2018/10/15.
//  Copyright © 2018 mediaios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PhoneNetSDK/PhoneNetSDK.h>


@interface PhoneNetSDKTests : XCTestCase
@property (nonatomic,strong) PNDomainLookup *domainLookup;
@end

@implementation PhoneNetSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _domainLookup = [[PNDomainLookup alloc] init];
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


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
