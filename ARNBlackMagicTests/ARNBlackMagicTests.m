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

static const char *testStringKey = "testAssociateString";
static const char *testBoolKey = "testAssociateBool";

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

- (void)testMethodCtypesWithReturnType
{
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:nil parameter:nil] ,"v0@0") == 0, @"testMethodCtypesWithReturnType error");
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:@encode(BOOL) parameter:nil] ,"B0@0") == 0, @"testMethodCtypesWithReturnType error");
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:@encode(int) parameter:nil] ,"i0@0") == 0, @"testMethodCtypesWithReturnType error");
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:@encode(id) parameter:@encode(Rect), nil], "@0@0:{Rect=ssss}0") == 0, @"testMethodCtypesWithReturnType error");
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:@encode(NSMutableArray *) parameter:@encode(NSNumber *), @encode(NSInteger), nil] ,"@0@0:@0:q0") == 0, @"testMethodCtypesWithReturnType error");
    XCTAssertTrue(strcmp([[self class] arn_bmMethodCtypesWithReturnType:@encode(NSString *) parameter:@encode(NSObject *), @encode(int), @encode(float), nil], "@0@0:@0:i0:f0") == 0, @"testMethodCtypesWithReturnType error");
}

- (void)testSendMessage
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertNil(objA.testString, @"testSendMessage error");
    
    [[self class] arn_bmSendMessageWithTarget:objA selectorName:@"testSnedMessage1" parameter: nil];
    
    XCTAssertTrue([objA.testString isEqualToString:@"OK"], @"testSendMessage error");
    
    XCTAssertTrue([[[self class] arn_bmSendMessageWithTarget:objA selectorName:@"testSnedMessage2" parameter: nil] isEqualToString:@"OK"], @"testSendMessage error");
    
    NSString *str1 = [[self class] arn_bmSendMessageWithTarget:objA selectorName:@"testSnedMessage3:" parameter:@"OK", nil];
    XCTAssertTrue([str1 isEqualToString:@"OK"], @"testSendMessage error");
    
    NSString *str2 = [[self class] arn_bmSendMessageWithTarget:objA selectorName:@"testSnedMessage4:nextText:" parameter:@"OK", @"OK", nil];
    XCTAssertTrue([str2 isEqualToString:@"OKOK"], @"testSendMessage error");
    
    XCTAssertTrue([[[self class] arn_bmSendMessageWithTarget:[ARNBlackMagicObject class] selectorName:@"testSnedClassMessage1" parameter: nil] isEqualToString:@"OK"], @"testSendMessage error");
    
    NSString *str3 = [[self class] arn_bmSendMessageWithTarget:[ARNBlackMagicObject class] selectorName:@"testSnedClassMessage2:" parameter:@"OK", nil];
    XCTAssertTrue([str3 isEqualToString:@"OK"], @"testSendMessage error");
    
    NSString *str4 = [[self class] arn_bmSendMessageWithTarget:[ARNBlackMagicObject class] selectorName:@"testSnedClassMessage3:nextText:" parameter:@"OK", @"OK", nil];
    XCTAssertTrue([str4 isEqualToString:@"OKOK"], @"testSendMessage error");
}

- (void)testAssociate
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertNil([objA arn_bmAssociatedObjectWithKey:&testStringKey], @"testAssociate error");
    
    [objA arn_bmSetAssociatedObjectWithKey:&testStringKey value:@"testA" policy:ARN_BWAssociationPolicyCopyNonatomic];
    
    XCTAssertTrue([[objA arn_bmAssociatedObjectWithKey:&testStringKey] isEqualToString:@"testA"], @"testAssociate error");
    
    [objA arn_bmSetAssociatedObjectWithKey:&testStringKey value:@"testB" policy:ARN_BWAssociationPolicyCopyNonatomic];
    
    XCTAssertTrue([[objA arn_bmAssociatedObjectWithKey:&testStringKey] isEqualToString:@"testB"], @"testAssociate error");
    
    [objA arn_bmSetAssociatedObjectWithKey:&testStringKey value:nil policy:ARN_BWAssociationPolicyAssign];
    
    XCTAssertNil([objA arn_bmAssociatedObjectWithKey:&testStringKey], @"testAssociate error");
    
    [objA arn_bmSetAssociatedObjectWithKey:&testBoolKey value:@(YES) policy:ARN_BWAssociationPolicyAssign];
    XCTAssertTrue([[objA arn_bmAssociatedObjectWithKey:&testBoolKey] boolValue], @"testAssociate error");
    [objA arn_bmSetAssociatedObjectWithKey:&testBoolKey value:@(NO) policy:ARN_BWAssociationPolicyAssign];
    XCTAssertTrue(![[objA arn_bmAssociatedObjectWithKey:&testBoolKey] boolValue], @"testAssociate error");
}

- (void)testSwizzClass
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    XCTAssertTrue([[[objA class] testClassMethodA] isEqualToString:@"class A"], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
    
    [objA arn_bmSwizzClassMethodFromSelector:@selector(testClassMethodA) toSelector:@selector(testClassMethodB)];
    
    XCTAssertThrows([[objA class] testClassMethodA], @"testSwizzClass error");
    XCTAssertTrue([[[objA class] testClassMethodB] isEqualToString:@"class B"], @"testSwizzClass error");
    
    [objA arn_bmSwizzClassMethodFromSelector:@selector(testClassMethodA) toSelector:@selector(testInstanceMethodA)];
    
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

- (void)testSwizzClassBlock
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    [[objA class] arn_bmLoggingAllMethodWithTargetClass:[objA class]];
    
    [objA arn_bmSwizzClassMethodWithSelector:@selector(testBlockClassMethod) impBlock:^id (id set, NSString *str) {
        return str;
    }];
    
    [[objA class] arn_bmLoggingAllMethodWithTargetClass:[objA class]];
    
    NSString *str1 = [[objA class] arn_bmSendMessageWithTarget:[objA class] selectorName:@"testBlockClassMethod" parameter:@"classTest1",nil];
    XCTAssertTrue([str1  isEqualToString:@"classTest1"], @"testSwizzClassBlock error");
    
    [objA arn_bmSwizzClassMethodWithSelector:@selector(testBlockClassMethod) impBlock:^id (id set, NSString *str, NSNumber *number) {
        return [NSString stringWithFormat:@"%@%d", str, number.intValue];
    }];
    
    [[objA class] arn_bmLoggingAllMethodWithTargetClass:[objA class]];
    
//     str1 = [[objA class] arn_bmSendMessageWithTarget:[objA class] selectorName:@"testBlockClassMethod" parameter:@"classTest",@2, nil];
//    XCTAssertTrue([str1  isEqualToString:@"classTest2"], @"testSwizzClassBlock error");
}

- (void)testSwizzInstanceBlock
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    [[objA class] arn_bmLoggingAllMethodWithTargetClass:[objA class]];
    
    [objA arn_bmSwizzInstanceMethodWithSelector:@selector(testBlockInstanceMethod) impBlock:^id (id set, NSString *str) {
        return str;
    }];
    
    [[objA class] arn_bmLoggingAllMethodWithTargetClass:[objA class]];
    
    NSString *str1 = [[objA class] arn_bmSendMessageWithTarget:objA selectorName:@"testBlockInstanceMethod" parameter:@"instanceTest1",nil];
    XCTAssertTrue([str1  isEqualToString:@"instanceTest1"], @"testSwizzInstanceBlock error");
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
- (void)testAddClassMethod
{
    ARNBlackMagicObject *objA = ARNBlackMagicObject.new;
    
    NSString *testSelectorString = @"testSelectorWithString:";
    XCTAssertTrue([objA arn_bmAddClassMethodWithSelectorName:testSelectorString impBlock:^id (NSString *aString) {
        return aString;
    } returnType:@encode(NSString *)], @"testAddMerthod error");

    return;
    NSString *testString = [[self class] arn_bmSendMessageWithTarget:[ARNBlackMagicObject class] selectorName:testSelectorString parameter:@"testOK", nil];
    XCTAssertTrue([testString isEqualToString:@"testOK"], @"testAddMerthod error");
}

@end
