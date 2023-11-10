//
//  MSFlipTransitionManager.h
//  MSPlumeProject
//
//  Created by admin on 2018/2/2.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "MSFlipTransitionManager.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const MSFlipTransitionManagerTransitioningValueDidChangeNotification = @"MSFlipTransitionManagerTransitioningValueDidChange";

@interface MSFlipTransitionManagerObserver : NSObject<MSFlipTransitionManagerObserver>
- (instancetype)initWithManager:(id<MSFlipTransitionManager>)mgr;
@end

@implementation MSFlipTransitionManagerObserver
@synthesize flipTransitionDidStopExeBlock = _flipTransitionDidStopExeBlock;
@synthesize flipTransitionDidStartExeBlock = _flipTransitionDidStartExeBlock;

- (instancetype)initWithManager:(id<MSFlipTransitionManager>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(transitioningValueDidChange:) name:MSFlipTransitionManagerTransitioningValueDidChangeNotification object:mgr];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)transitioningValueDidChange:(NSNotification *)note {
    id<MSFlipTransitionManager> mgr = note.object;
    if ( mgr.isTransitioning ) {
        if ( _flipTransitionDidStartExeBlock )
            _flipTransitionDidStartExeBlock(mgr);
    }
    else {
        if ( _flipTransitionDidStopExeBlock )
            _flipTransitionDidStopExeBlock(mgr);
    }
}
@end

@interface MSFlipTransitionManager ()<CAAnimationDelegate>
@property (nonatomic) MSViewFlipTransition innerFlipTransition;
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@end

@implementation MSFlipTransitionManager {
    void(^_Nullable _completionHandler)(id<MSFlipTransitionManager> mgr);
}
@synthesize target = _target;
@synthesize duration = _duration;

- (instancetype)initWithTarget:(UIView *)target {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _duration = 1.0;
    return self;
}

- (id<MSFlipTransitionManagerObserver>)getObserver {
    return [[MSFlipTransitionManagerObserver alloc] initWithManager:self];
}

- (MSViewFlipTransition)flipTransition {
    return _innerFlipTransition;
}

- (void)setFlipTransition:(MSViewFlipTransition)flipTransition {
    [self setFlipTransition:flipTransition animated:YES];
}

- (void)setFlipTransition:(MSViewFlipTransition)t animated:(BOOL)animated {
    [self setFlipTransition:t animated:animated completionHandler:nil];
}

- (void)setFlipTransition:(MSViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(id<MSFlipTransitionManager> mgr))completionHandler {
    if ( t == _innerFlipTransition )
        return;
    
    if ( self.isTransitioning )
        return;
    
    _innerFlipTransition = t;
    self.transitioning = YES;
    
    CATransform3D transform = CATransform3DIdentity;
    switch ( t ) {
        case MSViewFlipTransition_Identity: {
            transform = CATransform3DIdentity;
        }
            break;
        case MSViewFlipTransition_Horizontally: {
            transform = CATransform3DConcat(CATransform3DMakeRotation(M_PI, 0, 1, 0), CATransform3DMakeTranslation(0, 0, -10000));
        }
            break;
    }

    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.fromValue = [NSValue valueWithCATransform3D:_target.layer.transform];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:transform];
    rotationAnimation.duration = _duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    [_target.layer addAnimation:rotationAnimation forKey:nil];
    _target.layer.transform = transform;
    _completionHandler = completionHandler;
}

- (void)animationDidStart:(CAAnimation *)anim { }

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.transitioning = NO;
    
    if ( _completionHandler ) {
        _completionHandler(self);
        _completionHandler = nil;
    }
}

- (void)setTransitioning:(BOOL)transitioning {
    _transitioning = transitioning;
    [NSNotificationCenter.defaultCenter postNotificationName:MSFlipTransitionManagerTransitioningValueDidChangeNotification object:self];
}
@end
NS_ASSUME_NONNULL_END
