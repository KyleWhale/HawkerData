//
//  UIViewController+MSBornPlumeExtended.m
//  MSBornPlume
//
//  Created by admin on 2019/11/23.
//

#import "UIViewController+MSBornPlumeExtended.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MSModalAction) {
    MSModalActionPresented = 0,
    MSModalActionDismissed = 1
};

@interface MSModalPresentationHandler : NSObject
@property (nonatomic, weak, nullable) UIViewController *modalViewController;
@property (nonatomic) NSTimeInterval transitionDuration;
@property (nonatomic, copy, nullable) MSPresentedAnimationHandler presentedAnimationHandler;
@property (nonatomic, copy, nullable) MSDismissedAnimationHandler dismissedAnimationHandler;
@end

@interface MSModalPresentationHandler ()<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property (nonatomic) MSModalAction state;
@end

@implementation MSModalPresentationHandler
- (void)setModalViewController:(nullable UIViewController *)modalViewController {
    _modalViewController = modalViewController;
    modalViewController.transitioningDelegate  = self;
    if (@available(iOS 16.0, *)) {
        modalViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else {
        // https://github.com/changsanjiang/MSBornPlume/pull/36
        // 16以下的系统, 如果当前界面是横屏,fitOn后是竖屏问题
        modalViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.state) {
        case MSModalActionPresented: {
            UIView *containerView = [transitionContext containerView];
            UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
            toView.frame = containerView.bounds;
            toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [containerView addSubview:toView];
            
            if ( self.presentedAnimationHandler ) self.presentedAnimationHandler(self.modalViewController, ^{
                [transitionContext completeTransition:YES];
            });
        }
            break;
        case MSModalActionDismissed: {
            if ( self.dismissedAnimationHandler ) self.dismissedAnimationHandler(self.modalViewController, ^{
                [transitionContext completeTransition:YES];
            });
        }
            break;
        default: break;
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.state = MSModalActionPresented;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.state = MSModalActionDismissed;
    return self;
}
@end

@implementation UIViewController (MSBornPlumeExtended)
static void *defautKey = &defautKey;

///
/// 设置转场时间, 设置呈现的动画及消失的动画
///
- (void)setTransitionDuration:(NSTimeInterval)dutaion presentedAnimation:(MSPresentedAnimationHandler)presentedAnimation dismissedAnimation:(MSDismissedAnimationHandler)dismissedAnimation {
    MSModalPresentationHandler *_Nullable handler = objc_getAssociatedObject(self, defautKey);
    if ( handler == nil ) {
        handler = MSModalPresentationHandler.alloc.init;
        objc_setAssociatedObject(self, defautKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    handler.modalViewController = self;
    handler.transitionDuration = dutaion;
    handler.presentedAnimationHandler = presentedAnimation;
    handler.dismissedAnimationHandler = dismissedAnimation;
}
@end
NS_ASSUME_NONNULL_END
