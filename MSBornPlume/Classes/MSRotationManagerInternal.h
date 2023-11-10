//
//  MSRotationManagerInternal.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationManager.h"
#import "MSRotationFullscreenViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationManager(Internal)<MSRotationFullscreenViewControllerDelegate>
- (instancetype)_init;
- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;
- (__kindof MSRotationFullscreenViewController *)rotationFullscreenViewController;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (BOOL)allowsRotation NS_REQUIRES_SUPER;
- (void)onDeviceOrientationChanged:(MSOrientation)deviceOrientation;
- (void)rotateToOrientation:(MSOrientation)orientation animated:(BOOL)animated complete:(void(^ _Nullable)(MSRotationManager *mgr))completionHandler;

@property (nonatomic, strong, readonly) UIWindow *window;
@property (nonatomic, readonly, getter=isForcedRotation) BOOL forcedRotation;
@property (nonatomic, readonly) MSOrientation deviceOrientation;
@property (nonatomic) MSOrientation currentOrientation;
- (void)rotationBegin NS_REQUIRES_SUPER;
- (void)rotationEnd NS_REQUIRES_SUPER;
- (void)transitionBegin NS_REQUIRES_SUPER;
- (void)transitionEnd NS_REQUIRES_SUPER;
@end
NS_ASSUME_NONNULL_END
