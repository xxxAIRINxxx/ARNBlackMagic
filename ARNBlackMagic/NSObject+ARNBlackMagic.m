//
//  NSObject+ARNBlackMagic.m
//  NSObject+ARNBlackMagic
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "NSObject+ARNBlackMagic.h"
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer;
    char *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) -4] bytes];
        }
    }
    return "";
}

@implementation NSObject (ARNBlackMagic)


+ (NSDictionary *)arn_bmProperties
{
    unsigned int outCount;
    unsigned int i;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    
    if (!outCount) {
        return nil;
    }
    
    NSMutableDictionary *dic = NSMutableDictionary.new;
    for (i = 0; i < outCount; ++i) {
        objc_property_t property = props[i];
        const char *propertyName = property_getName(property);
        if (propertyName) {
            const char *propertyType = getPropertyType(property);
            NSString *propertyNameString = [NSString stringWithCString:propertyName encoding:[NSString defaultCStringEncoding]];
            NSString *propertyTypeString =[NSString stringWithCString:propertyType encoding:[NSString defaultCStringEncoding]];
            dic[propertyNameString] = propertyTypeString;
        }
    }
    free(props);
    
    return dic;
}

- (void)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    if (!fromSelector || !toSelector) { return; }
    
    Method fromMethod = class_getInstanceMethod([self class], fromSelector);
    IMP toImp = class_getMethodImplementation([self class], toSelector);
    
    if (fromMethod == NULL || toImp == NULL) { return; }
    
    method_setImplementation(fromMethod, toImp);
}

- (void)arn_bmSwizzInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    if (!fromSelector || !toSelector) { return; }
    
    Method fromMethod = class_getInstanceMethod([self class], fromSelector);
    IMP toImp = class_getMethodImplementation([self class], toSelector);
    
    if (fromMethod == NULL || toImp == NULL) { return; }
    
    method_setImplementation(fromMethod, toImp);
}


+ (void)arn_bmExchangeClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    if (!fromSelector || !toSelector) { return; }
    
    Method fromMethod = class_getClassMethod([self class], fromSelector);
    Method toMethod = class_getClassMethod([self class], toSelector);
    
    if (fromMethod == NULL || toMethod == NULL) { return; }
    
    method_exchangeImplementations(fromMethod, toMethod);
}

- (void)arn_bmExchangeInstanceMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    if (!fromSelector || !toSelector) { return; }
    
    Method fromMethod = class_getInstanceMethod([self class], fromSelector);
    Method toMethod = class_getInstanceMethod([self class], toSelector);
    
    if (fromMethod == NULL || toMethod == NULL) { return; }
    
    method_exchangeImplementations(fromMethod, toMethod);
}
































@end
