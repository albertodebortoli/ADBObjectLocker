//
//  ADBObjectLocker.h
//  ADBObjectLocker
//
//  Created by Alberto De Bortoli on 03/08/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	Locker for instance methods.
 */
@interface ADBObjectLocker : NSObject

/**
 *	Lock a method on a specific instance to avoid execution.
 *
 *	@param	methodSelector	The selector of the method to lock.
 *	@param	obj	The instance object.
 */
+ (void)lockMethodSelector:(SEL)methodSelector forObject:(id)obj;

/**
 *	Unlock a method on a specific instance to avoid execution.
 *
 *	@param	methodSelector	The selector of the method to lock.
 *	@param	obj	The instance object.
 */
+ (void)unlockMethodSelector:(SEL)methodSelector forObject:(id)obj;

@end
