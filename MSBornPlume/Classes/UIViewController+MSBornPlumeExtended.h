//
//  UIViewController+MSBornPlumeExtended.h
//  MSBornPlume
//
//  Created by admin on 2019/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MSAnimationCompletionHandler)(void);
typedef void(^MSPresentedAnimationHandler)(__kindof UIViewController *vc, MSAnimationCompletionHandler completion);
typedef void(^MSDismissedAnimationHandler)(__kindof UIViewController *vc, MSAnimationCompletionHandler completion);

@interface UIViewController (MSBornPlumeExtended)

- (void)setTransitionDuration:(NSTimeInterval)dutaion presentedAnimation:(MSPresentedAnimationHandler)presentedAnimation dismissedAnimation:(MSDismissedAnimationHandler)dismissedAnimation;

@end
NS_ASSUME_NONNULL_END
