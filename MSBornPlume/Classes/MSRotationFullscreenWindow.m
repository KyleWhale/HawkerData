//
//  MSRotationFullscreenWindow.m
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationFullscreenWindow.h"

@implementation MSRotationFullscreenWindow {
    __weak id<MSRotationFullscreenWindowDelegate> _ms_delegate;
    CGRect _ms_old_bounds;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(nullable id<MSRotationFullscreenWindowDelegate>)delegate {
    self = [super initWithFrame:frame];
    if ( self ) {
        _ms_delegate = delegate;
        [self _setup];
    }
    return self;
}

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene delegate:(nullable id<MSRotationFullscreenWindowDelegate>)delegate API_AVAILABLE(ios(13.0)) {
    self = [super initWithWindowScene:windowScene];
    if ( self ) {
        _ms_delegate = delegate;
        [self _setup];
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    rootViewController.view.frame = self.bounds;
    rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_setup {
    self.frame = UIScreen.mainScreen.bounds;
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event {
    return [_ms_delegate window:self pointInside:point withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 如果是大屏转大屏 就不需要修改了
    
    if ( !CGRectEqualToRect(_ms_old_bounds, self.bounds) ) {
        _ms_old_bounds = self.bounds;

        UIView *superview = self;
        if ( @available(iOS 13.0, *) ) {
            superview = self.subviews.firstObject;
        }

        [UIView performWithoutAnimation:^{
            for ( UIView *view in superview.subviews ) {
                if ( view != self.rootViewController.view && [view isMemberOfClass:UIView.class] ) {
                    view.backgroundColor = UIColor.clearColor;
                    for ( UIView *subview in view.subviews ) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
            }
        }];
    }
}
@end
