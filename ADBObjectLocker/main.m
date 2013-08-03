//
//  main.m
//  ADBObjectLocker
//
//  Created by Alberto De Bortoli on 03/08/2013.
//  Copyright (c) 2013 Alberto De Bortoli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADBObjectLocker.h"
#import "ADBObject.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        ADBObject *o1 = [[ADBObject alloc] init];
        ADBObject *o2 = [[ADBObject alloc] init];
        
        [o1 m1:@"one"];
        [o2 m1:@"two"];
        
        [ADBObjectLocker lockMethodSelector:@selector(m1:) forObject:o1];
        
        [o1 m1:@"three"];
        [o2 m1:@"four"];
        
        //
        
        [o1 m2:@5];
        [o2 m2:@6];
        
        [ADBObjectLocker lockMethodSelector:@selector(m2:) forObject:o1];
        
        [o1 m2:@7];
        [o2 m2:@8];
    }
}
