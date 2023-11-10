//
//  CALayer+MSBornPlumeExtended.m
//  MSBornPlume
//
//  Created by admin on 2019/11/22.
//

#import "CALayer+MSBornPlumeExtended.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@interface MSExtendedAnimationDelegate : NSObject<CAAnimationDelegate>
@property (nonatomic, copy, nullable) MSAnimationDidStartHandler startHandler;
@property (nonatomic, copy, nullable) MSAnimationDidStopHandler stopHandler;
@end

@implementation MSExtendedAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim {
    if ( _startHandler ) _startHandler(anim);
    _startHandler = nil;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ( _stopHandler ) _stopHandler(anim, flag);
    _stopHandler = nil;
}
@end

@implementation CALayer (MSBornPlumeExtended)

///
/// 暂停动画
///
- (void)pauseAnimation {
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

///
/// 恢复动画
///
- (void)resumeAnimation {
    CFTimeInterval pausedTime = [self timeOffset];
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.beginTime = timeSincePause;
}

static void *defaultKey = &defaultKey;

///
/// 添加动画及设置动画开始的回调
///
- (void)addAnimation:(CAAnimation *)anim startHandler:(MSAnimationDidStartHandler)startHandler {
    [self addAnimation:anim startHandler:startHandler stopHandler:nil];
}

///
/// 添加动画及设置动画停止的回调
///
- (void)addAnimation:(CAAnimation *)anim stopHandler:(MSAnimationDidStopHandler)stopHandler {
    [self addAnimation:anim startHandler:nil stopHandler:stopHandler];
}


///
/// 添加动画及设置动画开始,停止的回调
///
- (void)addAnimation:(CAAnimation *)anim startHandler:(nullable MSAnimationDidStartHandler)startHandler stopHandler:(nullable MSAnimationDidStopHandler)stopHandler {
    MSExtendedAnimationDelegate *delegate = objc_getAssociatedObject(self, defaultKey);
    if ( delegate == nil ) {
        delegate = MSExtendedAnimationDelegate.new;
        objc_setAssociatedObject(self, defaultKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    delegate.startHandler = startHandler;
    delegate.stopHandler = stopHandler;
    anim.delegate = delegate;
    [self addAnimation:anim forKey:nil];
}
@end
NS_ASSUME_NONNULL_END
