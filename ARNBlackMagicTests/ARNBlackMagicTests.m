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
#import <objc/message.h>

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

- (void)testAssociate
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    NSString *testStringKey = @"testAssociateString";
    NSString *testBoolKey = @"testAssociateBool";
    
    XCTAssertNil([[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testStringKey], @"testAssociate error");
    
    [[objA class] arn_bmSetAssociatedObjectWithTarget:objA key:testStringKey value:@"testA" policy:ARN_BWAssociationPolicyCopyNonatomic];
    
    XCTAssertTrue([[[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testStringKey] isEqualToString:@"testA"], @"testAssociate error");
    
    [[objA class] arn_bmSetAssociatedObjectWithTarget:objA key:testStringKey value:@"testB" policy:ARN_BWAssociationPolicyCopyNonatomic];
    
    XCTAssertTrue([[[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testStringKey] isEqualToString:@"testB"], @"testAssociate error");
    
    [[objA class] arn_bmSetAssociatedObjectWithTarget:objA key:testStringKey value:nil policy:ARN_BWAssociationPolicyAssign];
    
    XCTAssertNil([[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testStringKey], @"testAssociate error");
    
    
    [[objA class] arn_bmSetAssociatedObjectWithTarget:objA key:testBoolKey value:@(YES) policy:ARN_BWAssociationPolicyAssign];
    XCTAssertTrue([[[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testBoolKey] boolValue], @"testAssociate error");
    [[objA class] arn_bmSetAssociatedObjectWithTarget:objA key:testBoolKey value:@(NO) policy:ARN_BWAssociationPolicyAssign];
    XCTAssertTrue(![[[objA class] arn_bmGetAssociatedObjectWithTarget:objA key:testBoolKey] boolValue], @"testAssociate error");
}

- (void)testSwizzClass
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"class A"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
    
    [[objA class] arn_bmSwizzClassMethodFromSelector:@selector(testClassMethodA) toSelector:@selector(testClassMethodB)];
    
    XCTAssertThrows([[objA class] testClassMethodA], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
    
    [[objA class] arn_bmSwizzClassMethodFromSelector:@selector(testClassMethodA) toSelector:@selector(testInstanceMethodA)];
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"instance A"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
}

- (void)testSwizzInstance
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertTrue([[objA testInstanceMethodA] isEqualToString:@"instance A"], @"testSwizzInstance error");
    XCTAssertTrue([[objA testInstanceMethodB] isEqualToString:@"instance B"], @"testSwizzInstance error");
    
    [objA arn_bmSwizzInstanceMethodFromSelector:@selector(testInstanceMethodA) toSelector:@selector(testInstanceMethodB)];
    
    XCTAssertTrue([[objA testInstanceMethodA] isEqualToString:@"instance B"], @"testSwizzInstance error");
    XCTAssertTrue([[objA testInstanceMethodB] isEqualToString:@"instance B"], @"testSwizzInstance error");
    
    [objA arn_bmSwizzInstanceMethodFromSelector:@selector(testInstanceMethodA) toSelector:@selector(testClassMethodA)];
    
    XCTAssertThrows([objA testInstanceMethodA], @"testSwizzInstance error");
    XCTAssertTrue([[objA testInstanceMethodB] isEqualToString:@"instance B"], @"testSwizzInstance error");
}

- (void)testExchangeClass
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"class A"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
    
    [[objA class] arn_bmExchangeClassMethodFromSelector:@selector(testClassMethodA) toSelector:@selector(testClassMethodB)];
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"class B"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class A"], @"testSwizzClass error");
    
    [[objA class] arn_bmExchangeClassMethodFromSelector:@selector(testClassMethodB) toSelector:@selector(testClassMethodA)];
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"class A"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
}

// is bug fixing...
- (void)testAddMethod
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    NSString *testSelectorString = @"testSelectorWithString:";
    XCTAssertTrue([objA arn_bmAddMethodWithSelectorName:testSelectorString impBlock:^id (id blockSelf, ...) {
        va_list args;
        va_start(args, blockSelf);
        
        ARNBlackMagicObject *selfObj = blockSelf;
        
        NSString *retrunString = nil;
        while (selfObj) {
            retrunString = va_arg(args, typeof (NSString *));
        }
        
        va_end(args);
        
        return retrunString;
    } returnType:@encode(NSString *)], @"testAddMerthod error");

    NSString *testString = objc_msgSend(objA, NSSelectorFromString(testSelectorString), @"testOK");
    XCTAssertTrue([testString isEqualToString:@"testOK"], @"testAddMerthod error");
}

@end
