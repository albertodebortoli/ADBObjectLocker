//
//  ADBObjectLocker.m
//  ADBObjectLocker
//
//  Created by Alberto De Bortoli on 03/08/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBObjectLocker.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <objc/objc-class.h>

@interface NSObject (Locker)

@property (nonatomic, strong) NSMutableDictionary *lockedMethods;

@end

NSString const *kLockedMethods = @"lockedMethods";

@implementation NSObject (Locker)

@dynamic lockedMethods;

- (NSMutableDictionary *)lockedMethods
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kLockedMethods));
}

- (void)setLockedMethods:(NSMutableDictionary *)lockedMethods
{
    [self willChangeValueForKey:@"lockedMethods"];
    objc_setAssociatedObject(self, (__bridge const void *)(kLockedMethods), lockedMethods, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"lockedMethods"];
}

@end

@implementation ADBObjectLocker

+ (void)lockMethodSelector:(SEL)methodSelector forObject:(id)obj
{
    // get the strings for the selectors
    NSString *origMethodSelectorString = NSStringFromSelector(methodSelector);
    NSString *swizzledMethodSelectorString = [NSString stringWithFormat:@"__swizzled_%@", origMethodSelectorString];

    // get the selectors
    SEL origSelector = methodSelector;
    SEL swizzledSelector = NSSelectorFromString(swizzledMethodSelectorString);

    // create an empty dictionary if missing
    if ([(NSObject *)obj lockedMethods] == nil) {
        [obj setLockedMethods:[NSMutableDictionary dictionary]];
    }
    
    // add the method to lock to the list of the object
    [[(NSObject *)obj lockedMethods] setObject:@YES forKey:origMethodSelectorString];
    
    // if the method has been already swizzled, return
    Method alreadySwizzled = class_getInstanceMethod([obj class], swizzledSelector);
    if (alreadySwizzled != nil) {
        return;
    }
    
    // create a custom implementation to use for the to be swizzled method
    void (^implementingBlock)(id s, SEL _c, id o) = ^(id s, SEL _c, id o) {
        if ([[(NSObject *)s lockedMethods] objectForKey:origMethodSelectorString]) {
            NSLog(@"*** This method (%@) has been locked for the object %@. Not executing.", origMethodSelectorString, s);
            return;
        }
        
        // can't use va_list here, it seems impossible to handle arbitrary number of arguments
        // worse, passed o parameter is wrong.
        objc_msgSend(s, swizzledSelector, o);
    };

    // create association
    objc_setAssociatedObject(obj, (__bridge const void *)(swizzledMethodSelectorString), [implementingBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // set implementation
    IMP newImp = imp_implementationWithBlock(implementingBlock);
    class_addMethod([obj class], swizzledSelector, newImp, [swizzledMethodSelectorString UTF8String]);
    Method swizzledMethod = class_getInstanceMethod([obj class], swizzledSelector);
    method_setImplementation(swizzledMethod, newImp);

    // swizzle the implementations
    Method orig = class_getInstanceMethod([obj class], origSelector);
    Method new = class_getInstanceMethod([obj class], swizzledSelector);
    method_exchangeImplementations(orig, new);
}

+ (void)unlockMethodSelector:(SEL)methodSelector forObject:(id)obj
{
    // we must not swizzle the method back here, otherwise all the instance that are still locked will be unlocked
    
    //    NSString *origMethodSelectorString = NSStringFromSelector(methodSelector);
    //    NSString *swizzledMethodSelectorString = [NSString stringWithFormat:@"__swizzled_%@", origMethodSelectorString];
    //    SEL swizzledSelector = NSSelectorFromString(swizzledMethodSelectorString);
    //
    //    Method orig = class_getInstanceMethod([obj class], methodSelector);
    //    Method new = class_getInstanceMethod([obj class], swizzledSelector);
    //
    //    method_exchangeImplementations(orig, new);
    
    NSString *origMethodSelectorString = NSStringFromSelector(methodSelector);
    [[(NSObject *)obj lockedMethods] removeObjectForKey:origMethodSelectorString];
}

@end
