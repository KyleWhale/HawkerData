//
//  MSRotationManager_iOS_9_15.m
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationManager_iOS_9_15.h"
#import "MSRotationFullscreenViewController.h"
#import "MSRotationManagerInternal.h"
#import "MSRotationDefines.h"
#import "UIView+MSBornPlumeExtended.h"
@class MSRotationFullscreenViewController_iOS_9_15;

API_DEPRECATED("deprecated!", ios(9.0, 16.0)) @protocol MSRotationFullscreenViewControllerDelegate_iOS_9_15 <MSRotationFullscreenViewControllerDelegate>
- (BOOL)shouldAutorotateForRotationFullscreenViewController:(MSRotationFullscreenViewController_iOS_9_15 *)viewController;
- (void)rotationFullscreenViewController:(MSRotationFullscreenViewController_iOS_9_15 *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
@end

API_DEPRECATED("deprecated!", ios(9.0, 16.0)) @interface MSRotationFullscreenViewController_iOS_9_15 : MSRotationFullscreenViewController
@property (nonatomic, strong, readonly) UIView *playerSuperview;
@property (nonatomic, weak, nullable) id<MSRotationFullscreenViewControllerDelegate_iOS_9_15> delegate;
@end

@implementation MSRotationFullscreenViewController_iOS_9_15
@dynamic delegate;
 
- (void)viewDidLoad {
    [super viewDidLoad];
    _playerSuperview = [UIView.alloc initWithFrame:CGRectZero];
    _playerSuperview.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_playerSuperview];
}

- (BOOL)shouldAutorotate {
    return [self.delegate shouldAutorotateForRotationFullscreenViewController:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.delegate rotationFullscreenViewController:self viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
@end

@interface MSRotationManager_iOS_9_15 ()<MSRotationFullscreenViewControllerDelegate_iOS_9_15> {
    void(^_completionHandler)(MSRotationManager *mgr);
}
@property (nonatomic, strong, readonly) MSRotationFullscreenViewController_iOS_9_15 *rotationFullscreenViewController;
@end

@implementation MSRotationManager_iOS_9_15

@synthesize rotationFullscreenViewController = _rotationFullscreenViewController;
- (MSRotationFullscreenViewController_iOS_9_15 *)rotationFullscreenViewController {
    if ( _rotationFullscreenViewController == nil ) {
        _rotationFullscreenViewController = [MSRotationFullscreenViewController_iOS_9_15.alloc init];
    }
    return _rotationFullscreenViewController;
}
 
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return (self.target.superview == self.rotationFullscreenViewController.playerSuperview) &&
          [self.rotationFullscreenViewController.playerSuperview pointInside:[self.window convertPoint:point toView:self.rotationFullscreenViewController.playerSuperview] withEvent:event];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)rotateToOrientation:(MSOrientation)orientation animated:(BOOL)animated complete:(void (^)(MSRotationManager * _Nonnull))completionHandler {
#ifdef DEBUG
    if ( !animated ) {
        NSAssert(false, @"暂不支持关闭动画!");
    }
#endif
    _completionHandler = completionHandler;
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
}

- (void)rotationBegin {
    if ( self.window.isHidden ) [self.window makeKeyAndVisible];
    self.currentOrientation = self.deviceOrientation;
    [super rotationBegin];
    [UIView animateWithDuration:0.0 animations:^{ } completion:^(BOOL finished) {
        [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)rotationEnd {
    if ( !self.window.isHidden && ![self isFullscreen] ) {
        [self.superview.window makeKeyAndVisible];
        self.window.hidden = YES;
    }
    [super rotationEnd];
    if ( _completionHandler != nil ) {
        _completionHandler(self);
        _completionHandler = nil;
    }
}

#pragma mark -

- (BOOL)shouldAutorotateForRotationFullscreenViewController:(MSRotationFullscreenViewController_iOS_9_15 *)viewController {
    if ( [self allowsRotation] ) {
        if ( !self.rotating ) [self rotationBegin];
        return YES;
    }
    return NO;
}

- (void)rotationFullscreenViewController:(MSRotationFullscreenViewController_iOS_9_15 *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self transitionBegin];
    if ( self.currentOrientation != MSOrientation_Portrait ) {
        if ( self.target.superview != self.rotationFullscreenViewController.playerSuperview ) {
            CGRect frame = [self.target convertRect:self.target.bounds toView:self.target.window];
            self.rotationFullscreenViewController.playerSuperview.frame = frame; // t1
            
            self.target.frame = (CGRect){0, 0, frame.size};
            self.target.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.rotationFullscreenViewController.playerSuperview addSubview:self.target]; // t2
            [self.target layoutIfNeeded];
        }
        
        [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.rotationFullscreenViewController.playerSuperview.frame = (CGRect){CGPointZero, size};
                [self.target layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self transitionEnd];
                [self rotationEnd];
            }];
        }];
    }
    else {
        [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
            [self _fixNavigationBarLayout];
            [UIView animateWithDuration:0.3 animations:^{
                self.rotationFullscreenViewController.playerSuperview.frame = [self.superview convertRect:self.superview.bounds toView:self.superview.window];
                [self.target layoutIfNeeded];
            } completion:^(BOOL finished) {
                UIView *snapshot = [self.target snapshotViewAfterScreenUpdates:NO];
                snapshot.frame = self.superview.bounds;
                snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.superview addSubview:snapshot];
                [UIView animateWithDuration:0.0 animations:^{ /* preparing */ } completion:^(BOOL finished) {
                    self.target.frame = self.superview.bounds;
                    self.target.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [self.superview addSubview:self.target];
                    [self.target layoutIfNeeded];
                    [snapshot removeFromSuperview];
                    [self transitionEnd];
                    [self rotationEnd];
                }];
            }];
        }];
    }
}

- (void)_fixNavigationBarLayout {
    if ( self.currentOrientation == MSOrientation_Portrait ) {
        UINavigationController *nav = [self.superview lookupResponderForClass:UINavigationController.class];
        [nav viewDidAppear:NO];
        [nav.navigationBar layoutSubviews];
    }
}

@end
