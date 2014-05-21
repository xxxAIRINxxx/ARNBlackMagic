//
//  NSObject+ARNBlackMagic.m
//  NSObject+ARNBlackMagic
//
//  Created by Airin on 2014/04/24.
//  Copyright (c) 2014 Airin. All rights reserved.
//

#import "NSObject+ARNBlackMagic.h"
#import <objc/message.h>

#define PARAS(fmt, ...) fmt , ## __VA_ARGS__

#if !__has_feature(objc_arc)
    #error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - Block

// @see http://www.opensource.apple.com/source/libclosure/libclosure-53/Block_private.h?txt

struct BlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void         *rest[1];
};

struct BlockLayout {
    void                   *isa;
    volatile int            flags; // contains ref count
    int                     reserved;
    void                    (*invoke)(void *, ...);
    struct BlockDescriptor *descriptor;
    // imported variables
};

// Flags of Block
enum {
    BLOCK_DEALLOCATING     =      (0x0001), // runtime
    BLOCK_REFCOUNT_MASK    =     (0xfffe), // runtime
    BLOCK_NEEDS_FREE       =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR         =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC            =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL        =         (1 << 28), // compiler
    BLOCK_USE_STRET        =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE    =    (1 << 30) // compiler
};

const char *ARNBlockGetObjCTypes(id _block)
{
    // Get descriptor of block
    struct BlockDescriptor *descriptor;
    struct BlockLayout     *block;
    block      = (__bridge struct BlockLayout *)_block;
    descriptor = block->descriptor;

    // Get index of rest
    int index = 0;
    if (block->flags & BLOCK_HAS_COPY_DISPOSE) {
        index += 2;
    }

    return descriptor->rest[index];
}

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - ARNBlackMagic

@implementation NSObject (ARNBlackMagic)

+ (NSDictionary *)arn_bmProperties
{
    unsigned int     outCount;
    unsigned int     i;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);

    if (!outCount) {
        return nil;
    }

    NSMutableDictionary *dic = NSMutableDictionary.new;
    for (i = 0; i < outCount; ++i) {
        objc_property_t property     = props[i];
        const char     *propertyName = property_getName(property);
        if (propertyName) {
            const char *propertyType       = getPropertyType(property);
            NSString   *propertyNameString = [NSString stringWithCString:propertyName encoding:[NSString defaultCStringEncoding]];
            NSString   *propertyTypeString = [NSString stringWithCString:propertyType encoding:[NSString defaultCStringEncoding]];
            dic[propertyNameString] = propertyTypeString;
        }
    }
    free(props);

    return dic;
}

+ (id)arn_bmSendMessageWithTarget:(id)target selectorName:(NSString *)selectorName parameter:(id)parameter, ...NS_REQUIRES_NIL_TERMINATION
{
    if (!target || !selectorName) { return nil; }

    NSMutableArray *parameters = [NSMutableArray array];
    id              aParameter;
    va_list         args;
    aParameter = parameter;
    va_start(args, parameter);

    while (aParameter) {
        [parameters addObject:aParameter];
        aParameter = va_arg(args, id);
    }
    va_end(args);

    if (parameters.count == 0) {
        return objc_msgSend(target, NSSelectorFromString(selectorName));
    }
    if (parameters.count == 1) {
        return objc_msgSend(target, NSSelectorFromString(selectorName), parameters[0]);
    }
    if (parameters.count == 2) {
        return objc_msgSend(target, NSSelectorFromString(selectorName), parameters[0], parameters[1]);
    }
    if (parameters.count == 3) {
        return objc_msgSend(target, NSSelectorFromString(selectorName), parameters[0], parameters[1], parameters[2]);
    }
    if (parameters.count == 4) {
        return objc_msgSend(target, NSSelectorFromString(selectorName), parameters[0], parameters[1], parameters[2], parameters[3]);
    }
    if (parameters.count == 5) {
        return objc_msgSend(target, NSSelectorFromString(selectorName), parameters[0], parameters[1], parameters[2], parameters[3], parameters[4]);
    }
    
    // BUG : replaceMethod をしても type Stringが変わらないので実行出来ない
    SEL                selector   = NSSelectorFromString(selectorName);
    NSMethodSignature *signature  = [target methodSignatureForSelector:selector];
    NSInvocation      *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:target];
    for (int i = 0; i < parameters.count; ++i) {
        id para = parameters[i];
        [invocation setArgument:&para atIndex:i + 2];
    }
    [invocation invoke];
    id returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

- (const char *)typeStringWithBlock:(id)block
{
    NSMethodSignature *blockSignature = [NSMethodSignature signatureWithObjCTypes:ARNBlockGetObjCTypes(block)];
    
    NSMutableString *objCTypes = [NSMutableString stringWithFormat:@"%@@:", [NSString stringWithCString:[blockSignature methodReturnType] encoding:NSUTF8StringEncoding]];
    for (NSInteger i = 2; i < [blockSignature numberOfArguments]; i++) {
        [objCTypes appendString:[NSString stringWithCString:[blockSignature getArgumentTypeAtIndex:i] encoding:NSUTF8StringEncoding]];
    }
    NSLog(@"%s", [objCTypes UTF8String]);
    
    return [objCTypes UTF8String];
}

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - Associative

- (id)arn_bmAssociatedObjectWithKey:(const void *)key
{
    if (!key) { return nil; }

    return objc_getAssociatedObject(self, key);
}

- (void)arn_bmSetAssociatedObjectWithKey:(const void *)key value:(id)value policy:(ARN_BWAssociationPolicy)policy
{
    if (!key) { return; }

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

    objc_setAssociatedObject(self, key, value, policy);
}

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - Method Swizzling

- (BOOL)arn_bmSwizzClassMethodFromSelector:(SEL)fromSelector toClassMethod:(BOOL)toClassMethod toSelector:(SEL)toSelector
{
    return [self arn_bmSwizzMethodFromSelector:fromSelector toSelector:toSelector fromClassMethod:YES toClassMethod:toClassMethod];
}

- (BOOL)arn_bmSwizzInstanceMethodFromSelector:(SEL)fromSelector toClassMethod:(BOOL)toClassMethod toSelector:(SEL)toSelector
{
    return [self arn_bmSwizzMethodFromSelector:fromSelector toSelector:toSelector fromClassMethod:NO toClassMethod:toClassMethod];
}

- (BOOL)arn_bmSwizzMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector fromClassMethod:(BOOL)fromClassMethod toClassMethod:(BOOL)toClassMethod
{
    if (!fromSelector || !toSelector) { return NO; }
    
    Class fromClass;
    Class toClass;
    Method fromMethod;
    if (fromClassMethod) {
        fromClass = object_getClass([self class]);
        fromMethod = class_getClassMethod(fromClass, fromSelector);
    } else {
        fromClass = [self class];
        fromMethod = class_getInstanceMethod(fromClass, fromSelector);
    }
    if (toClassMethod) {
        toClass = object_getClass([self class]);
    } else {
        toClass = [self class];
    }
    
    IMP toImp = class_getMethodImplementation(toClass, toSelector);
    
    if (fromMethod == NULL || toImp == NULL) { return NO; }
    
    method_setImplementation(fromMethod, toImp);
    
    return YES;
}

- (BOOL)arn_bmSwizzClassMethodWithSelector:(SEL)selector impBlock:(id)impBlock
{
    return [self arn_bmReplaceMethodWithSelector:selector class:object_getClass([self class]) impBlock:impBlock];
}

- (BOOL)arn_bmSwizzInstanceMethodWithSelector:(SEL)selector impBlock:(id)impBlock
{
    return [self arn_bmReplaceMethodWithSelector:selector class:[self class] impBlock:impBlock];
}

- (BOOL)arn_bmReplaceMethodWithSelector:(SEL)selector class:(Class)class impBlock:(id)impBlock
{
    if (!selector || !impBlock) { return NO; }

    class_replaceMethod(class, selector, imp_implementationWithBlock(impBlock), [self typeStringWithBlock:impBlock]);

    return YES;
}

+ (BOOL)arn_bmExchangeClassMethodFromSelector:(SEL)fromSelector toClassMethod:(BOOL)toClassMethod toSelector:(SEL)toSelector
{
    return [self arn_bmExchangeMethodFromSelector:fromSelector toSelector:toSelector fromClassMethod:YES toClassMethod:toClassMethod];
}

- (BOOL)arn_bmExchangeInstanceMethodFromSelector:(SEL)fromSelector toClassMethod:(BOOL)toClassMethod toSelector:(SEL)toSelector
{
    return [self arn_bmExchangeMethodFromSelector:fromSelector toSelector:toSelector fromClassMethod:NO toClassMethod:toClassMethod];
}

- (BOOL)arn_bmExchangeMethodFromSelector:(SEL)fromSelector toSelector:(SEL)toSelector fromClassMethod:(BOOL)fromClassMethod toClassMethod:(BOOL)toClassMethod
{
    if (!fromSelector || !toSelector) { return NO; }
    
    Class fromClass;
    Class toClass;
    Method fromMethod;
    Method toMethod;
    if (fromClassMethod) {
        fromClass = object_getClass([self class]);
        fromMethod = class_getClassMethod(fromClass, fromSelector);
    } else {
        fromClass = [self class];
        fromMethod = class_getInstanceMethod(fromClass, fromSelector);
    }
    if (toClassMethod) {
        toClass = object_getClass([self class]);
        toMethod   = class_getClassMethod(toClass, toSelector);
    } else {
        toClass = [self class];
        toMethod   = class_getInstanceMethod(toClass, toSelector);
    }
    
    if (fromMethod == NULL || toMethod == NULL) { return NO; }
    
    method_exchangeImplementations(fromMethod, toMethod);
    
    return YES;
}

- (BOOL)arn_bmAddClassMethodWithSelectorName:(NSString *)selectorName impBlock:(id)impBlock
{
    return [self arn_bmAddMethodWithSelectorName:selectorName class:object_getClass([self class]) impBlock:impBlock];
}

- (BOOL)arn_bmAddInstanceMethodWithSelectorName:(NSString *)selectorName impBlock:(id)impBlock
{
    return [self arn_bmAddMethodWithSelectorName:selectorName class:[self class] impBlock:impBlock];
}

- (BOOL)arn_bmAddMethodWithSelectorName:(NSString *)selectorName class:(Class)class impBlock:(id)impBlock
{
    if (!selectorName || !impBlock) { return NO; }
    
    NSLog(@"%s", ARNBlockGetObjCTypes(impBlock));
    
    SEL dynamicSelector = NSSelectorFromString(selectorName);
    
    IMP oldImp = class_getMethodImplementation(class, dynamicSelector);
    if (oldImp != NULL) {
        imp_removeBlock(oldImp);
    }
    
    class_addMethod(class, dynamicSelector, imp_implementationWithBlock(impBlock), [self typeStringWithBlock:impBlock]);
    
    return YES;
}

// not fixed...
- (BOOL)arn_bmAppendBlockForSelector:(SEL)selector appendBlock:(id)appendBlock needCallOriginalMethod:(BOOL)needCallOriginalMethod
{
    if (!selector || !appendBlock) { return NO; }
    
    Method fromMethod = class_getInstanceMethod([self class], selector);
    
    method_setImplementation(fromMethod, imp_implementationWithBlock(appendBlock));
    
    return YES;
}

// -------------------------------------------------------------------------------------------------------------------------------//
#pragma mark - Debug

+ (void)arn_bmLoggingAllMethodWithTargetClass:(Class)targetClass
{
    unsigned int count           = 0;
    Method      *classMethodList = class_copyMethodList(object_getClass(targetClass), &count);
    NSLog(@"\n");
    NSLog(@"Class Method List : %@", targetClass);
    for (unsigned int i = 0; i < count; i++) {
        NSLog(@"%3d: %@    %s", i, NSStringFromSelector(method_getName(classMethodList[i])), method_getTypeEncoding(classMethodList[i]));
    }
    NSLog(@"\n");
    free(classMethodList);

    count = 0;
    Method *instanceMethodList = class_copyMethodList(targetClass, &count);
    NSLog(@"\n");
    NSLog(@"Instance Method List : %@", targetClass);
    for (unsigned int i = 0; i < count; i++) {
        NSLog(@"%3d: %@    %s", i, NSStringFromSelector(method_getName(instanceMethodList[i])), method_getTypeEncoding(instanceMethodList[i]));
    }
    NSLog(@"\n");
    free(instanceMethodList);
}

static const char *getPropertyType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    char        buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer;
    char *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

@end
