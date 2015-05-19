//
//  PNTimeTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/15/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"


@interface PNTimeTests : XCTestCase

@end

@implementation PNTimeTests {
    
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    
    // Init PubNub
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

#pragma mark - Tests


- (void)testTimetoken {
    
    clock_t start = clock();

    // First timetoken
    GCDGroup *group = [GCDGroup group];
    [group enter];
    
    __block long _timetoken1;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken1 = [[result.data objectForKey:@"tt"] longLongValue];
        [group leave];
    }];
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:10]) {
        
        NSLog(@"Timeout fired");
    }
    
    // Second timetoken
    [group enter];
    
    __block long _timetoken2;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken2 = [[result.data objectForKey:@"tt"] longLongValue];
        [group leave];
    }];
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:10]) {
        
        NSLog(@"Timeout fired");
    }

    clock_t finish = clock();
    
    // Check that during the test and the difference between the timetokens obtained in 0.5сек ... 1сек
    double duringClock = (double)(finish - start) / 100000;
    double duringTimetoken = (double)(_timetoken2 - _timetoken1) / 10000000;
    XCTAssertTrue(0.5 < (duringClock - duringTimetoken) < 1, @"Error");
}

#pragma mark - private methods

// For the future
- (BOOL)checkResult:(PNResult *)result andStatus:(PNStatus *)status {
    
    if ((result && status) || (!result && !status)) {
        
        XCTFail(@"Error");
    } else if (result) {
        
        NSLog(@"!!! %@", [result.data objectForKey:@"tt"]);
    } else if (status) {
        
        NSLog(@"!!! %@", status);
    }
    
    return YES;
}
@end