//
//  MSPresentationQueue.h
//  Pods
//
//  Created by BlueDancer on 2020/5/8.
//

#import <UIKit/UIKit.h>
@protocol MSPresentViewProtocol;

typedef enum : NSUInteger {
    /// 可抛弃的
    MSPresentationPriorityDroppable,
    /// 必须呈现的, 优先级高的将优先呈现
    MSPresentationPriorityLow,
    /// 必须呈现的, 优先级高的将优先呈现
    MSPresentationPriorityNormal,
    /// 必须呈现的, 优先级高的将优先呈现
    MSPresentationPriorityHigh,
    /// 必须呈现的, 此选项将优先呈现
    MSPresentationPriorityVeryHigh
} MSPresentationPriority;

NS_ASSUME_NONNULL_BEGIN
@interface MSPresentationQueue : NSObject

/// 在`sourceView`上呈现`presentView`
/// 只有前一个`presentView`消失后, 才会继续后续的任务
/// 如果`sourceView`释放了, 则后续相关的任务将不会执行
+ (void)enqueueToPresent:(UIView<MSPresentViewProtocol> *)presentView sourceView:(UIView *)sourceView;

@end

@protocol MSPresentViewProtocol <NSObject>
@property (nonatomic, readonly) MSPresentationPriority priority;
- (void)showInSourceView:(UIView *)source dismissedCallback:(void(^)(void))callback;
@end
NS_ASSUME_NONNULL_END

