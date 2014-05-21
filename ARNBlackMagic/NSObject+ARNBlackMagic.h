//
//  NSObject+ARNBlackMagic.h
//  NSObject+ARNBlackMagic
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^ARN_BMAddMethodBlock) (id receiver, ...);

typedef NS_ENUM (uintptr_t, ARN_BWAssociationPolicy) {
    ARN_BWAssociationPolicyAssign = 0,
    ARN_BWAssociationPolicyRetainNonatomic,
    ARN_BWAssociationPolicyCopyNonatomic,
    ARN_BWAssociationPolicyRetain,
    ARN_BWAssociationPolicyCopy
};

@interface NSObject (ARNBlackMagic)

+ (const char *)arn_bmMethodCtypesWithReturnType:(const char *)returnType parameter:(const char *)parameter, ... NS_REQUIRES_NIL_TERMINATION;

+ (id)arn_bmSendMessageWithTarget:(id)target selectorName:(NSString *)selectorName parameter:(id)parameter, ... NS_REQUIRES_NIL_TERMINATION;

// Associate
- (id)arn_bmAssociatedObjectWithKey:(const void *)key;
- (void)arn_bmSetAssociatedObjectWithKey:(const void *)key value:(id)value policy:(ARN_BWAssociationPolicy)policy;

// Swizz 
- (void)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmSwizzInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmSwizzClassMethodWithSelector:(SEL)selector impBlock:(id)impBlock;
- (void)arn_bmSwizzInstanceMethodWithSelector:(SEL)selector impBlock:(id)impBlock;

// Exchange
+ (void)arn_bmExchangeClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmExchangeInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

- (BOOL)arn_bmAddClassMethodWithSelectorName:(NSString *)selectorName impBlock:(id)impBlock returnType:(const char *)returnType;

// Debug
+ (void)arn_bmLoggingAllMethodWithTargetClass:(Class)targetClass;

// @see http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
+ (NSDictionary *)arn_bmProperties;

@end
