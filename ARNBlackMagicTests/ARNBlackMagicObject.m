//
//  ARNBlackMagicObject.m
//  ARNBlackMagic
//
//  Created by Airin on 2014/04/25.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "ARNBlackMagicObject.h"
#import "NSObject+ARNBlackMagic.h"

@implementation ARNBlackMagicObject

- (void)dealloc
{
    NSLog(@"dealloc : %@ ////////////////////////", NSStringFromClass([self class]));
}

- (instancetype)init
{
    if (!(self = [super init])) { return nil; }

    return self;
}

+ (void)testBlockClassMethod
{
    
}

- (void)testBlockInstanceMethod
{
}

+ (NSString *)testClassMethodA
{
    return @"class A";
}

+ (NSString *)testClassMethodB
{
    return @"class B";
}

- (NSString *)testInstanceMethodA
{
    return @"instance A";
}

- (NSString *)testInstanceMethodB
{
    return @"instance B";
}

- (void)testSnedMessage1
{
    self.testString = @"OK";
}

- (NSString *)testSnedMessage2
{
    return @"OK";
}

- (NSString *)testSnedMessage3:(NSString *)text
{
    return text;
}

- (NSString *)testSnedMessage4:(NSString *)text nextText:(NSString *)nextText
{
    return [NSString stringWithFormat:@"%@%@", text, nextText];
}

+ (NSString *)testSnedClassMessage1
{
    return @"OK";
}

+ (NSString *)testSnedClassMessage2:(NSString *)text
{
    return text;
}

+ (NSString *)testSnedClassMessage3:(NSString *)text nextText:(NSString *)nextText
{
    return [NSString stringWithFormat:@"%@%@", text, nextText];
}

- (void)testAddingWithString:(NSString *)aString number:(NSNumber *)number integerValue:(NSInteger)integerValue
{
    NSLog(@"call Origin testAddingWithString");
}

@end
