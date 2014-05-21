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

+ (void)testBlockClassMethod;
- (void)testBlockInstanceMethod;

+ (NSString *)testClassMethodA;
+ (NSString *)testClassMethodB;

- (NSString *)testInstanceMethodA;
- (NSString *)testInstanceMethodB;

- (void)testSnedMessage1;
- (NSString *)testSnedMessage2;
- (NSString *)testSnedMessage3:(NSString *)text;
- (NSString *)testSnedMessage4:(NSString *)text nextText:(NSString *)nextText;

+ (NSString *)testSnedClassMessage1;
+ (NSString *)testSnedClassMessage2:(NSString *)text;
+ (NSString *)testSnedClassMessage3:(NSString *)text nextText:(NSString *)nextText;


@end
