//
//  MSFitOnScreenManager.m
//  MSBornPlume
//
//  Created by admin on 2018/12/31.
//

#import "MSFitOnScreenManager.h"
#import "UIViewController+MSBornPlumeExtended.h"

NS_ASSUME_NONNULL_BEGIN
static NSNotificationName const MSFitOnScreenManagerTransitioningValueDidChangeNotification = @"MSFitOnScreenManagerTransitioningValueDidChange";

@interface MSFitOnScreenManagerObserver : NSObject<MSFitOnScreenManagerObserver>
- (instancetype)initWithManager:(id<MSFitOnScreenManager>)manager;
@end

@implementation MSFitOnScreenManagerObserver
@synthesize fitOnScreenWillBeginExeBlock = _fitOnScreenWillBeginExeBlock;
@synthesize fitOnScreenDidEndExeBlock = _fitOnScreenDidEndExeBlock;

- (instancetype)initWithManager:(id<MSFitOnScreenManager>)manager {
    self = [super init];
    if ( !self )
        return nil;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(transitioningValueDidChange:) name:MSFitOnScreenManagerTransitioningValueDidChangeNotification object:manager];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)transitioningValueDidChange:(NSNotification *)note {
    id<MSFitOnScreenManager> mgr = note.object;
    if ( mgr.isTransitioning ) {
        if ( _fitOnScreenWillBeginExeBlock )
            _fitOnScreenWillBeginExeBlock(mgr);
    }
    else {
        if ( _fitOnScreenDidEndExeBlock )
            _fitOnScreenDidEndExeBlock(mgr);
    }
}
@end

#pragma mark -

@interface MSFitOnScreenModeViewController : UIViewController
@end

@implementation MSFitOnScreenModeViewController
- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end

@interface MSFitOnScreenModeNavigationController : UINavigationController
@property (nonatomic, weak, nullable) id<MSViewControllerManager> viewControllerManager;
@end

@implementation MSFitOnScreenModeNavigationController
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
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}
- (BOOL)prefersStatusBarHidden {
    return _viewControllerManager.prefersStatusBarHidden;
}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}
@end

#pragma mark -

@interface MSFitOnScreenManager ()
@property (nonatomic, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) BOOL innerFitOnScreen;
@property (nonatomic, strong, readonly) UIView *target;
@property (nonatomic, strong, readonly) UIView *superview;
@property (nonatomic, strong, readonly) MSFitOnScreenModeNavigationController *viewController;
@end

@implementation MSFitOnScreenManager
@synthesize duration = _duration;
- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview {
    self = [super init];
    if ( !self )
        return nil;
    _target = target;
    _superview = superview;
    _duration = 0.3;
    return self;
}

- (id<MSFitOnScreenManagerObserver>)getObserver {
    return [[MSFitOnScreenManagerObserver alloc] initWithManager:self];
}

- (BOOL)isFitOnScreen {
    return _innerFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void (^)(id<MSFitOnScreenManager>))completionHandler {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.isTransitioning ) return;
        if ( fitOnScreen == self.isFitOnScreen ) { if ( completionHandler ) completionHandler(self); return; }
        self.innerFitOnScreen = fitOnScreen;
        self.transitioning = YES;
        if ( fitOnScreen ) {
            UIViewController *top = [self topMostController];
            if ( !animated ) [self _presentedAnimationWithDuration:0 completionHandler:nil];
            [top presentViewController:self.viewController animated:animated completion:^{
                if ( completionHandler ) completionHandler(self);
            }];
        }
        else {
            if ( !animated ) [self _dismissedAnimationWithDuration:0 completionHandler:nil];
            [self.viewController dismissViewControllerAnimated:animated completion:^{
                if ( completionHandler ) completionHandler(self);
            }];
        } 
    });
}

- (UIView *)superviewInFitOnScreen {
    return self.viewController.view;
}

- (UIViewController *)topMostController {
    UIViewController *topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while( topController.presentedViewController != nil ) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void)setInnerFitOnScreen:(BOOL)innerFitOnScreen {
    if ( innerFitOnScreen == _innerFitOnScreen )
        return;
    _innerFitOnScreen = innerFitOnScreen;
}

- (void)setTransitioning:(BOOL)transitioning {
    _transitioning = transitioning;
    [NSNotificationCenter.defaultCenter postNotificationName:MSFitOnScreenManagerTransitioningValueDidChangeNotification object:self];
}

- (void)setViewControllerManager:(nullable id<MSViewControllerManager>)viewControllerManager {
    self.viewController.viewControllerManager = viewControllerManager;
}

- (nullable id<MSViewControllerManager>)viewControllerManager {
    return self.viewController.viewControllerManager;
}

@synthesize viewController = _viewController;
- (MSFitOnScreenModeNavigationController *)viewController {
    if ( _viewController == nil ) {
        MSFitOnScreenModeViewController *vc = MSFitOnScreenModeViewController.alloc.init;
        _viewController = [MSFitOnScreenModeNavigationController.alloc initWithRootViewController:vc];
        NSTimeInterval duration = self.duration;
        __weak typeof(self) _self = self;
        [_viewController setTransitionDuration:duration presentedAnimation:^(__kindof UIViewController * _Nonnull vc, MSAnimationCompletionHandler  _Nonnull completion) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _presentedAnimationWithDuration:duration completionHandler:completion];
        } dismissedAnimation:^(__kindof UIViewController * _Nonnull vc, MSAnimationCompletionHandler  _Nonnull completion) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _dismissedAnimationWithDuration:duration completionHandler:completion];
        }];
    }
    return _viewController;
}

- (void)_presentedAnimationWithDuration:(NSTimeInterval)duration completionHandler:(nullable MSAnimationCompletionHandler)completion {
    CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
    self.target.frame = frame;
    [self.viewController.view addSubview:self.target];
    [UIView animateWithDuration:duration animations:^{
        self.target.frame = self.viewController.view.bounds;
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ( completion != nil ) completion();
        self.transitioning = NO;
    }];
}

- (void)_dismissedAnimationWithDuration:(NSTimeInterval)duration completionHandler:(nullable MSAnimationCompletionHandler)completion {
    CGRect frame = [self.superview convertRect:self.superview.bounds toView:UIApplication.sharedApplication.keyWindow];
    [UIView animateWithDuration:duration animations:^{
        self.target.frame = frame;
        [self.target layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.target.frame = self.superview.bounds;
        [self.superview addSubview:self.target];
        if ( completion != nil ) completion();
        self.transitioning = NO;
    }];
}
@end
NS_ASSUME_NONNULL_END
