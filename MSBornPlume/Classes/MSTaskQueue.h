//
//  MSTaskQueue.h
//  Pods
//
//  Created by admin on 2019/2/28.
//

#import <Foundation/Foundation.h>
typedef void(^MSTaskHandler)(void);

NS_ASSUME_NONNULL_BEGIN
@interface MSTaskQueue : NSObject
@property (class, nonatomic, copy, readonly) MSTaskQueue *(^queue)(NSString *name);
@property (class, nonatomic, copy, readonly) MSTaskQueue *main;
@property (class, nonatomic, copy, readonly) void(^destroy)(NSString *name);

/// 每执行一次任务, 延迟多少秒
@property (nonatomic, copy, readonly) MSTaskQueue *_Nullable(^delay)(NSTimeInterval secs);
/// enqueue, Add a task to the queue.
///
/// - This task will be autoexecuted.
@property (nonatomic, copy, readonly) MSTaskQueue *_Nullable(^enqueue)(MSTaskHandler task);
/// dequeue, This method will delete the first task in the queue.
///
/// - The first task will not be executed.
@property (nonatomic, copy, readonly) MSTaskQueue *_Nullable(^dequeue)(void);
/// empty the tasks in the queue.
@property (nonatomic, copy, readonly) MSTaskQueue *_Nullable(^empty)(void);
/// destroy queue.
@property (nonatomic, copy, readonly) void(^destroy)(void);

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, readonly) NSInteger count;
@end
NS_ASSUME_NONNULL_END
