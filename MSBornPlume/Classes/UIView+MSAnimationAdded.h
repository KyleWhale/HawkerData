//
//  UIView+MSAnimationAdded.h
//  MSPlume
//
//  Created by admin on 2018/10/23.
//  Copyright © 2018 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 视图
typedef NS_ENUM(NSUInteger, MSViewDisappearAnimation) {
    MSViewDisappearAnimation_None,
    MSViewDisappearAnimation_Top,
    MSViewDisappearAnimation_Left,
    MSViewDisappearAnimation_Bottom,
    MSViewDisappearAnimation_Right,
    MSViewDisappearAnimation_HorizontalScaling, // 水平缩放
    MSViewDisappearAnimation_VerticalScaling,   // 垂直缩放
} ;

NS_ASSUME_NONNULL_BEGIN
extern BOOL
ms_view_isDisappeared(UIView *view);

extern void
ms_view_initializes(UIView *view);
extern void __attribute__((overloadable))
ms_view_initializes(NSArray<UIView *> *views);

extern void
ms_view_makeAppear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void));
extern void __attribute__((overloadable))
ms_view_makeAppear(UIView *view, BOOL animated);
extern void __attribute__((overloadable))
ms_view_makeAppear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void));
extern void __attribute__((overloadable))
ms_view_makeAppear(NSArray<UIView *> *views, BOOL animated);

extern void
ms_view_makeDisappear(NSArray<UIView *> *views, BOOL animated, void(^_Nullable completionHandler)(void));
extern void __attribute__((overloadable))
ms_view_makeDisappear(UIView *view, BOOL animated);
extern void __attribute__((overloadable))
ms_view_makeDisappear(UIView *view, BOOL animated, void(^_Nullable completionHandler)(void));
extern void __attribute__((overloadable))
ms_view_makeDisappear(NSArray<UIView *> *views, BOOL animated);

@interface UIView (MSAnimationAdded)
@property (nonatomic) MSViewDisappearAnimation sjv_disappearDirection;
@property (nonatomic, readonly) BOOL sjv_disappeared;

- (void)sjv_disapear; // Animatable. 可动画的
- (void)sjv_appear; // Animatable. 可动画的
@end
NS_ASSUME_NONNULL_END
