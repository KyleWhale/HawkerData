//
//  MSTaskQueue.m
//  Pods
//
//  Created by admin on 2019/2/28.
//

#import "MSTaskQueue.h"
#import "MSQueue.h"
#import <stdlib.h>

NS_ASSUME_NONNULL_BEGIN
@interface MSTaskQueues : NSObject
- (void)addQueue:(MSTaskQueue *)q;
- (void)removeQueue:(NSString *)name;
- (nullable MSTaskQueue *)getQueue:(NSString *)name;
@end

@implementation MSTaskQueues {
    NSMutableDictionary *_m;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _m = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addQueue:(MSTaskQueue *)q {
    if ( !q ) return;
    [_m setValue:q forKey:q.name];
}

- (void)removeQueue:(NSString *)name {
    [_m removeObjectForKey:name];
}
- (nullable MSTaskQueue *)getQueue:(NSString *)name {
    MSTaskQueue *_Nullable q = _m[name];
    return q;
}
@end

#pragma mark -

@interface MSTaskQueue ()
@property (nonatomic, strong, readonly) MSQueue<MSTaskHandler> *queue;
@property (nonatomic) NSTimeInterval delaySecs;
@property BOOL isDelaying;
@end

@implementation MSTaskQueue
static MSTaskQueues *_queues;

+ (MSTaskQueue * _Nonnull (^)(NSString * _Nonnull))queue {
    return ^MSTaskQueue *(NSString *name) {
        NSParameterAssert(name);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _queues = [MSTaskQueues new];
        });
        MSTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( !q ) {
            q = [[MSTaskQueue alloc] initWithName:name];
            [_queues addQueue:q];
        }
        return q;
    };
}

+ (MSTaskQueue *)main {
    static NSString *const kSJTaskMainQueue = @"com.MSTaskQueue.main";
    return self.queue(kSJTaskMainQueue);
}

/// 销毁某个队列
+ (void (^)(NSString * _Nonnull))destroy {
    return ^(NSString *name) {
        if ( name.length < 1 )
            return ;
        MSTaskQueue *_Nullable q = [_queues getQueue:name];
        if ( q ) q.destroy();
    };
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _queue = MSQueue.queue;
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
#endif
    [_queue empty];
}

#pragma mark -

- (MSTaskQueue * _Nullable (^)(MSTaskHandler _Nonnull))enqueue {
    return ^MSTaskQueue *(MSTaskHandler task) {
        [self.queue enqueue:task];
        [self _performNextTaskIfNeeded];
        return self;
    };
}

- (MSTaskQueue * _Nullable (^)(void))dequeue {
    return ^MSTaskQueue *(void) {
        [self.queue dequeue];
        return self;
    };
}

- (MSTaskQueue * _Nullable (^)(NSTimeInterval secs))delay {
    return ^MSTaskQueue *(NSTimeInterval secs) {
        self.delaySecs = secs;
        return self;
    };
}

- (MSTaskQueue * _Nullable (^)(void))empty {
    return ^MSTaskQueue *(void) {
        [self _cancelPreviousPerformRequests];
        [self.queue empty];
        return self;
    };
}

- (void (^)(void))destroy {
    return ^ {
        [self _cancelPreviousPerformRequests];
        self.empty();
        [_queues removeQueue:self->_name];
    };
}

- (NSInteger)count {
    return self.queue.size;
}
#pragma mark -
- (void)_performNextTaskIfNeeded {
    if ( _isDelaying || self.queue.size == 0 ) return;
    
    _isDelaying = YES;
    [self performSelector:@selector(_performTask:) withObject:self.queue.dequeue afterDelay:_delaySecs];
}

- (void)_performTask:(MSTaskHandler)task {
    !task?:task();
    _isDelaying = NO;
    [self _performNextTaskIfNeeded];
}

- (void)_cancelPreviousPerformRequests {
    if ( _isDelaying ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_performTask:) object:nil];
        _isDelaying = NO;
    }
}
@end
NS_ASSUME_NONNULL_END
