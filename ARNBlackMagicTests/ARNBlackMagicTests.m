//
//  ARNBlackMagicTests.m
//  ARNBlackMagicTests
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARNBlackMagicObject.h"
#import "NSObject+ARNBlackMagic.h"

@interface ARNBlackMagicTests : XCTestCase

@end

@implementation ARNBlackMagicTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testProperties
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    NSDictionary *dict = [[objA class] arn_bmProperties];
    NSLog(@"dict : %@", dict);
    
    XCTAssertTrue(dict.count == 5, @"testProperties error");
    
    XCTAssertTrue([dict[@"testObj"] isEqualToString:@"id"], @"testProperties error");
    XCTAssertTrue([dict[@"count"] isEqualToString:@"q"], @"testProperties error");
    XCTAssertTrue([dict[@"testBOOL"] isEqualToString:@"B"], @"testProperties error");
    XCTAssertTrue([dict[@"testString"] isEqualToString:@"NSString"], @"testProperties error");
    XCTAssertTrue([dict[@"testArray"] isEqualToString:@"NSArray"], @"testProperties error");
}

@end
