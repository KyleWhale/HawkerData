//
//  MSRunLoopTaskQueue.m
//  MSUIKit
//
//  Created by changsanjiang@gmail.com on 07/17/2018.
//  Copyright (c) 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "MSRunLoopTaskQueue.h"
#import "MSQueue.h"
#import <stdlib.h>

NS_ASSUME_NONNULL_BEGIN
@interface MSRunLoopTaskQueues : NSObject
- (void)addQueue:(MSRunLoopTaskQueue *)q;
- (void)removeQueue:(NSString *)name;
- (nullable MSRunLoopTaskQueue *)getQueue:(NSString *)name;
@end

@implementation MSRunLoopTaskQueues {
    NSMutableDictionary *_m;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _m = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addQueue:(MSRunLoopTaskQueue *)q {
    if ( !q ) return;
    [_m setValue:q forKey:q.name];
}

- (void)removeQueue:(NSString *)name {
    [_m removeObjectForKey:name];
}
- (nullable MSRunLoopTaskQueue *)getQueue:(NSString *)name {
    MSRunLoopTaskQueue *_Nullable q = _m[name];
    return q;
}
@end

#pragma mark -

typedef struct {
    CFRunLoopRef rlr;
    CFRunLoopMode mode;
    CFRunLoopObserverRef _Nullable obr;
} MSRunLoopObserverRef;

static NSString *const kSJRunLoopTaskMainQueue = @"com.MSRunLoopTaskQueue.main";

@interface MSRunLoopTaskQueue ()
@property (nonatomic, strong, readonly) MSQueue<MSRunLoopTaskHandler> *queue;
@property (nonatomic, readonly) MSRunLoopObserverRef observerRef;
@property (nonatomic) NSUInteger delayNum;
@property (nonatomic) NSUInteger countDown;
@property (nonatomic, weak, readonly) NSThread *onThread;
@end

@implementation MSRunLoopTaskQueue
static MSRunLoopTaskQueues *_queues;
/// 在当前的RunLoop中创建一个任务队列
///
/// - 请使用唯一的队列名称, 同名的队列将会被移除
/// - 调用destroy后, 该队列将会被移除
+ (MSRunLoopTaskQueue * _Nonnull (^)(NSString * _Nonnull))queue {
    return ^MSRunLoopTaskQueue *(NSString *name) {
        NSParameterAssert(name);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _queues = [MSRunLoopTaskQueues new];
        });
        MSRunLoopTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( !q ) {
            if ( name != kSJRunLoopTaskMainQueue ) {
                q = [[MSRunLoopTaskQueue alloc] initWithName:name runLoop:CFRunLoopGetCurrent() mode:kCFRunLoopCommonModes];
            }
            else {
                q = [[MSRunLoopTaskQueue alloc] initWithName:name runLoop:CFRunLoopGetMain() mode:kCFRunLoopCommonModes];
            }
            [_queues addQueue:q];
        }
        return q;
    };
}

/// 在mainRunLoop中创建的任务队列
///
/// - 调用destroy后, 再次获取该队列将会重新创建
+ (MSRunLoopTaskQueue *)main {
    return self.queue(kSJRunLoopTaskMainQueue);
}

/// 销毁某个队列
+ (void (^)(NSString * _Nonnull))destroy {
    return ^(NSString *name) {
        if ( name.length < 1 )
            return ;
        MSRunLoopTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( q ) q.destroy();
    };
}

- (instancetype)initWithName:(NSString *)name runLoop:(CFRunLoopRef)runLoop mode:(CFRunLoopMode)mode {
    self = [super init];
    if (self) {
        _name = name;
        _queue = MSQueue.queue;
        _observerRef = (MSRunLoopObserverRef){runLoop, mode, NULL};
        _onThread = (runLoop == CFRunLoopGetMain())?NSThread.mainThread:NSThread.currentThread;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    [_queue empty];
    [self _removeRunLoopObserver];
}

#pragma mark -

- (MSRunLoopTaskQueue * _Nullable (^)(CFRunLoopRef _Nonnull, CFRunLoopMode _Nonnull))update {
    return ^MSRunLoopTaskQueue *(CFRunLoopRef rlr, CFRunLoopMode mode) {
        [self _updateObserverRunLoop:rlr mode:mode];
        return self;
    };
}

- (MSRunLoopTaskQueue * _Nullable (^)(MSRunLoopTaskHandler _Nonnull))enqueue {
    return ^MSRunLoopTaskQueue *(MSRunLoopTaskHandler task) {
        [self.queue enqueue:task];
        [self _addRunLoopObserverIfNeeded];
        return self;
    };
}

- (MSRunLoopTaskQueue * _Nullable (^)(void))dequeue {
    return ^MSRunLoopTaskQueue *(void) {
        [self.queue dequeue];
        return self;
    };
}

- (MSRunLoopTaskQueue * _Nullable (^)(NSUInteger))delay {
    return ^MSRunLoopTaskQueue *(NSUInteger num) {
        self.delayNum = num;
        return self;
    };
}

- (MSRunLoopTaskQueue * _Nullable (^)(void))empty {
    return ^MSRunLoopTaskQueue *(void) {
        [self.queue empty];
        return self;
    };
}

- (void (^)(void))destroy {
    return ^ {
        [self.queue empty];
        [self _removeRunLoopObserver];
        [_queues removeQueue:self.name];
    };
}

- (NSInteger)count {
    return _queue.size;
}

#pragma mark -

- (void)_removeRunLoopObserver {
    if ( _observerRef.obr != NULL ) {
        CFRunLoopRemoveObserver(_observerRef.rlr, _observerRef.obr, _observerRef.mode);
        _observerRef.obr = NULL;
    }
}

- (void)_updateObserverRunLoop:(CFRunLoopRef)rlr mode:(CFRunLoopMode)mode {
    if ( _observerRef.rlr != rlr || _observerRef.mode != mode ) {
        _observerRef.rlr = rlr;
        _observerRef.mode = mode;
        
        if ( _observerRef.obr != nil ) {
            [self _removeRunLoopObserver];
            [self _addRunLoopObserverIfNeeded];
        }
    }
}

- (void)_addRunLoopObserverIfNeeded {
    if ( !_observerRef.obr && _queue.size != 0 ) {
        __weak typeof(self) _self = self;
        CFRunLoopObserverRef obr = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.queue.size == 0 ) {
                return;
            }
            
            if ( self.countDown > 0 ) {
                --self.countDown;
            }
            else {
                self.countDown = self.delayNum;
                __auto_type task = self.queue.dequeue;
                if ( task != nil ) task();
            }
        });
        CFRunLoopAddObserver(_observerRef.rlr, obr, _observerRef.mode);
        CFRelease(obr);
        _observerRef.obr = obr;
    }
}
@end
NS_ASSUME_NONNULL_END
