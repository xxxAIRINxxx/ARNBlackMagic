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

+ (id)arn_bmGetAssociatedObjectWithTarget:(id)target key:(NSString *)key
{
    if (!target || !key) { return nil; }
    
    const char *keyCString = [key cStringUsingEncoding:[NSString defaultCStringEncoding]];
    return objc_getAssociatedObject(target, (const void *)keyCString);
}

+ (void)arn_bmSetAssociatedObjectWithTarget:(id)target key:(NSString *)key value:(id)value policy:(ARN_BWAssociationPolicy)policy
{
    if (!target || !key) { return; }
    
    if (policy == ARN_BWAssociationPolicyAssign) {
        policy = OBJC_ASSOCIATION_ASSIGN;
    } else if (policy == ARN_BWAssociationPolicyRetainNonatomic) {
        policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    } else if (policy == ARN_BWAssociationPolicyCopyNonatomic) {
        policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
    } else if (policy == ARN_BWAssociationPolicyRetain) {
        policy = OBJC_ASSOCIATION_RETAIN;
    } else if (policy == ARN_BWAssociationPolicyCopy) {
        policy = OBJC_ASSOCIATION_COPY;
    } else {
        return;
    }
    const char *keyCString = [key cStringUsingEncoding:[NSString defaultCStringEncoding]];
    objc_setAssociatedObject(target, (const void *)keyCString, value, policy);
}

- (void)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector
{
    if (!fromSelector || !toSelector) { return; }
    
    Method fromMethod = class_getClassMethod([self class], fromSelector);
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

// is bug fixing...
- (BOOL)arn_bmAddMethodWithSelectorName:(NSString *)selectorName impBlock:(ARN_BMAddMethodBlock)impBlock returnType:(const char *)returnType
{
    if (!selectorName || !impBlock) { return NO; }
    
    if (!returnType) {
        returnType = @encode(typeof(void));
    }
    
    SEL dynamicSelector = NSSelectorFromString(selectorName);
    IMP dynamicImp = imp_implementationWithBlock(impBlock);
    
    IMP oldImp = class_getMethodImplementation([self class], dynamicSelector);
    if (oldImp != NULL) {
        imp_removeBlock(oldImp);
    }
    
    return class_addMethod([self class], dynamicSelector, dynamicImp, returnType);
}




























@end
