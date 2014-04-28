//
//  ARNBlackMagicObject.h
//  ARNBlackMagic
//
//  Created by Airin on 2014/04/25.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNBlackMagicObject : NSObject

@property (nonatomic, strong) id        testObj;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL      testBOOL;
@property (nonatomic, copy) NSString   *testString;
@property (nonatomic, copy) NSArray    *testArray;

+ (NSString *)testClassMethodA;
+ (NSString *)testClassMethodB;

- (NSString *)testInstanceMethodA;
- (NSString *)testInstanceMethodB;

@end
