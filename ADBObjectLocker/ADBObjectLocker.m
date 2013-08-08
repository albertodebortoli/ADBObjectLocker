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

@interface NSObject (Locker)

@property (nonatomic, strong, readonly) NSMutableDictionary *lockedMethods;

@end

@implementation NSObject (Locker)

@dynamic lockedMethods;

- (NSMutableDictionary *)lockedMethods
{
    if(objc_getAssociatedObject(self, _cmd) == nil) {
        objc_setAssociatedObject(self, _cmd, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_ASSIGN);
    }
    
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation ADBObjectLocker

//TODO: Make this work with class methods
+ (void)lockMethodSelector:(SEL)methodSelector forObject:(id)obj
{
    // get the strings for the selectors
    NSString *origMethodSelectorString = NSStringFromSelector(methodSelector);
    NSString *swizzledMethodSelectorString = [NSString stringWithFormat:@"__swizzled_%@", origMethodSelectorString];

    // get the selectors
    SEL origSelector = methodSelector;
    SEL swizzledSelector = NSSelectorFromString(swizzledMethodSelectorString);
    
    // add the method to lock to the list of the object
    [[(NSObject *)obj lockedMethods] setObject:@YES forKey:origMethodSelectorString];
    
    // if the method has been already swizzled, return
    Method alreadySwizzled = class_getInstanceMethod([obj class], swizzledSelector);
    if (alreadySwizzled != nil) {
        return;
    }
    
    Method orig = class_getInstanceMethod([obj class], origSelector);
    
    // create a custom implementation to use for the to be swizzled method
    void (^implementingBlock)(id receiver, ...) = ^(id receiver, ...) {
        if ([[(NSObject *)receiver lockedMethods] objectForKey:origMethodSelectorString]) {
            NSLog(@"*** This method (%@) has been locked for the object %@. Not executing.", origMethodSelectorString, receiver);
        } else {

            //Build an invocation to call the original method
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[receiver methodSignatureForSelector:swizzledSelector]];
            
            //Fetch the arguments and add them to the invocation (the +/- 2 is for the hidden '_cmd' & 'self')
            va_list list;
            va_start(list, receiver);
            uint numberOfParameters = method_getNumberOfArguments(orig);
            for (int i = 0; i < numberOfParameters - 2; i++) {
                [invocation setArgument:&list[i] atIndex:i + 2];
            }
            
            [invocation setSelector:swizzledSelector];
            [invocation invokeWithTarget:receiver];
        }
    };
    
    // set implementation
    IMP newImp = imp_implementationWithBlock(implementingBlock);
    class_addMethod([obj class], swizzledSelector, newImp, method_getTypeEncoding(orig));
    Method new = class_getInstanceMethod([obj class], swizzledSelector);
    
    // swizzle the implementations
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
