//
//  NSObject+ARNBlackMagic.h
//  NSObject+ARNBlackMagic
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef id (^ARN_BMAddMethodBlock) (id blockSelf, ...);

typedef NS_ENUM (uintptr_t, ARN_BWAssociationPolicy) {
    ARN_BWAssociationPolicyAssign = 0,
    ARN_BWAssociationPolicyRetainNonatomic,
    ARN_BWAssociationPolicyCopyNonatomic,
    ARN_BWAssociationPolicyRetain,
    ARN_BWAssociationPolicyCopy
};

@interface NSObject (ARNBlackMagic)

// @see http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
+ (NSDictionary *)arn_bmProperties;

// Associate
+ (id)arn_bmGetAssociatedObjectWithTarget:(id)target key:(NSString *)key;
+ (void)arn_bmSetAssociatedObjectWithTarget:(id)target key:(NSString *)key value:(id)value policy:(ARN_BWAssociationPolicy)policy;

// Swizz 
- (void)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmSwizzInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

// Exchange
+ (void)arn_bmExchangeClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmExchangeInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

- (BOOL)arn_bmAddMethodWithSelectorName:(NSString *)selectorName impBlock:(ARN_BMAddMethodBlock)impBlock returnType:(const char *)returnType;

@end
