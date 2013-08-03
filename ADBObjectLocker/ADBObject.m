//
//  ADBObject.m
//  ADBObjectLocker
//
//  Created by Alberto De Bortoli on 03/08/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import "ADBObject.h"

@implementation ADBObject

- (void)m1:(NSString *)v1;
{
    NSLog(@"%@ in %@: arg is %@", NSStringFromSelector(_cmd), self, v1);
}

- (void)m2:(NSNumber *)v1;
{
    NSLog(@"%@ in %@: args is %@", NSStringFromSelector(_cmd), self, v1);
}

@end
