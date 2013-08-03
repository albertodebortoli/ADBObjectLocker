ADBObjectLocker
===============

##General Notes

Prototype. Idea. Maybe pointless. Maybe just cool mental gymnastic. Maybe I should just drink less beer. Class to handle lock on specific methods for specific instances.


##The idea

All of us wrote something like the following sooner or later in our lives:


``` objective-c
- (void)doSomething {
    if (_isAlreadyDoingSomething) {
        return;
    }
  
    _isAlreadyDoingSomething = YES
    // do something
    _isAlreadyDoingSomething = NO;
}
```

Maybe with some thread safety. Well…

- I want the logic of the `if` statement out of there.
- I don't want the class to be aware of that check.
- I want someone else to decide if a method on a specific instance can be executed or not.
- I wnat someone else to lock a specific method for a specific instance.
- I don't want to queue the calls from different callers (different thread).
- I don't want to simulate a `NSLock`, `pthread_mutex_t` or `@synchronized` block.

I'm gonna do this with runtime, introspection, reflection, method swizzling.

Yeah, cool Objective-C stuff.

##Usage

I want to do something like this:

``` objective-c
ADBObject *o1 = [[ADBObject alloc] init];
ADBObject *o2 = [[ADBObject alloc] init];

[o1 m1:@""]; // execute
[o2 m1:@""]; // execute
[o1 m2:@""]; // execute
[o2 m2:@""]; // execute

[ADBObjectLocker lockMethodSelector:@selector(m1:) forObject:o1];
[ADBObjectLocker lockMethodSelector:@selector(m2:) forObject:o2];

[o1 m1:@""]; // does not execute
[o2 m1:@""]; // execute
[o1 m2:@""]; // execute
[o2 m2:@""]; // does not execute

[ADBObjectLocker unlockMethodSelector:@selector(m1:) forObject:o1];
[ADBObjectLocker unlockMethodSelector:@selector(m2:) forObject:o2];

[o1 m1:@""]; // execute
[o2 m1:@""]; // execute
[o1 m2:@""]; // execute
[o2 m2:@""]; // execute

```

##To Do
- Handle passed argument correctly to swizzled method.
- Handle arbitrary number of arguments in methods to be locked.
