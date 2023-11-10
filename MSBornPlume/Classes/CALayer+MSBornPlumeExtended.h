//
//  CALayer+MSBornPlumeExtended.h
//  MSBornPlume
//
//  Created by admin on 2019/11/22.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MSAnimationDidStartHandler)(__kindof CAAnimation *anim);
typedef void(^MSAnimationDidStopHandler)(__kindof CAAnimation *anim, BOOL isFinished);

@interface CALayer (MSBornPlumeExtended)

- (void)pauseAnimation;

- (void)resumeAnimation;

- (void)addAnimation:(CAAnimation *)anim startHandler:(MSAnimationDidStartHandler)startHandler;
- (void)addAnimation:(CAAnimation *)anim stopHandler:(MSAnimationDidStopHandler)stopHandler;
- (void)addAnimation:(CAAnimation *)anim startHandler:(nullable MSAnimationDidStartHandler)startHandler stopHandler:(nullable MSAnimationDidStopHandler)stopHandler;
@end
NS_ASSUME_NONNULL_END
