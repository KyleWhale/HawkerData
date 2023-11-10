//
//  UIView+MSAnimationAdded.m
//  MSPlume
//
//  Created by admin on 2018/10/23.
//  Copyright © 2018 admin. All rights reserved.
//

#import "UIView+MSAnimationAdded.h"
#import <objc/message.h>
#import "MSPlumeConfigurations.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIView (MSAnimationAdded)
- (void)setSjv_disappeared:(BOOL)sjv_disappeared {
    objc_setAssociatedObject(self, @selector(sjv_disappeared), @(sjv_disappeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sjv_disappeared {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSjv_disappearDirection:(MSViewDisappearAnimation)sjv_disappearDirection {
    objc_setAssociatedObject(self, @selector(sjv_disappearDirection), @(sjv_disappearDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MSViewDisappearAnimation)sjv_disappearDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)sjv_disapear {
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch ( self.sjv_disappearDirection ) {
        case MSViewDisappearAnimation_None: break;
        case MSViewDisappearAnimation_Top: {
            transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
        }
            break;
        case MSViewDisappearAnimation_Left: {
            transform = CGAffineTransformMakeTranslation(-self.bounds.size.width, 0);
        }
            break;
        case MSViewDisappearAnimation_Bottom: {
            transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        }
            break;
        case MSViewDisappearAnimation_Right: {
            transform = CGAffineTransformMakeTranslation(self.bounds.size.width, 0);
        }
            break;
        case MSViewDisappearAnimation_HorizontalScaling: {
            transform = CGAffineTransformMakeScale(0.001, 1);
        }
            break;
        case MSViewDisappearAnimation_VerticalScaling: {
            transform = CGAffineTransformMakeScale(1, 0.001);
        }
            break;
    }
    self.transform = transform;
    self.alpha = 0.001;
    self.sjv_disappeared = YES;
}

- (void)sjv_appear { 
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1;
    self.sjv_disappeared = NO;
}
@end

#pragma mark -

BOOL ms_view_isDisappeared(UIView *view) {
    if ( !view )
        return NO;
    return view.sjv_disappeared;
}
void __attribute__((overloadable))
ms_view_makeAppear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( !view ) return;
    ms_view_makeAppear(@[view], animated, completionHandler);
}
void __attribute__((overloadable))
ms_view_makeDisappear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( !view ) return;
    ms_view_makeDisappear(@[view], animated, completionHandler);
}
void ms_view_initializes(UIView *view) {
    view.alpha = 0.001;
}

void __attribute__((overloadable)) ms_view_makeAppear(UIView *view, BOOL animated) {
    ms_view_makeAppear(view, animated, nil);
}
void __attribute__((overloadable)) ms_view_makeDisappear(UIView *view, BOOL animated) {
    ms_view_makeDisappear(view, animated, nil);
}
void __attribute__((overloadable)) ms_view_initializes(NSArray<UIView *> *views) {
    for ( UIView *view in views ) {
        ms_view_initializes(view);
    }
}

void __attribute__((overloadable))
ms_view_makeAppear(NSArray<UIView *> *views, BOOL animated) {
    ms_view_makeAppear(views, animated, nil);
}
void
ms_view_makeAppear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( views.count == 0 ) return;
    for ( UIView *view in views ) {
        view.sjv_disappeared = NO;
        [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
            if ( animated ) {
                [UIView animateWithDuration:MSPlumeConfigurations.shared.animationDuration animations:^{
                    [view sjv_appear];
                } completion:^(BOOL finished) {
                    if ( view == views.lastObject && completionHandler ) completionHandler();
                }];
            }
            else {
                [view sjv_appear];
                if ( view == views.lastObject && completionHandler ) completionHandler();
            }
        }];
    }
}

void __attribute__((overloadable))
ms_view_makeDisappear(NSArray<UIView *> *views, BOOL animated) {
    ms_view_makeDisappear(views, animated, nil);
}
void
ms_view_makeDisappear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void)) {
    if ( views.count == 0 ) return;
    for ( UIView *view in views ) {
        view.sjv_disappeared = YES;
        [UIView animateWithDuration:0 animations:^{} completion:^(BOOL finished) {
            if ( animated ) {
                [UIView animateWithDuration:MSPlumeConfigurations.shared.animationDuration animations:^{
                    [view sjv_disapear];
                } completion:^(BOOL finished) {
                    if ( view == views.lastObject && completionHandler ) completionHandler();
                }];
            }
            else {
                [view sjv_disapear];
                if ( view == views.lastObject && completionHandler ) completionHandler();
            }
        }];
    }
}
NS_ASSUME_NONNULL_END
