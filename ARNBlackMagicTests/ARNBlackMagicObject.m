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

@end
