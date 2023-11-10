//
//  MSRotationFullscreenNavigationController.m
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationFullscreenNavigationController.h"
 
@implementation MSRotationFullscreenNavigationController {
    __weak id<MSRotationFullscreenNavigationControllerDelegate> _ms_delegate;
}
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(nullable id<MSRotationFullscreenNavigationControllerDelegate>)delegate {
    self = [super initWithRootViewController:rootViewController];
    if ( self ) {
        _ms_delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden { }

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated { }

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}
- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( self.viewControllers.count < 1 ) {
        [super pushViewController:viewController animated:animated];
    }
    else if ( [_ms_delegate respondsToSelector:@selector(pushViewController:animated:)] ) {
        [_ms_delegate pushViewController:viewController animated:animated];
    }
}
@end

