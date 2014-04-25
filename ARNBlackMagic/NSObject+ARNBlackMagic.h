//
//  NSObject+ARNBlackMagic.h
//  NSObject+ARNBlackMagic
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ARNBlackMagic)

// @see http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
+ (NSDictionary *)arn_bmProperties;

// Swizz 
- (void)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmSwizzInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

// Exchange
+ (void)arn_bmExchangeClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;
- (void)arn_bmExchangeInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector;

@end
