//
//  MSEdgeControlLayer.h
//  MSPlume
//
//  Created by admin on 2018/10/24.
//  Copyright © 2018 admin. All rights reserved.
//

#import "MSEdgeControlLayerAdapters.h"
#import "MSDraggingProgressPopupViewDefines.h"
#import "MSDraggingObservationDefines.h"
#import "MSControlLayerDefines.h"
#import "MSLoadingViewDefines.h"
#import "MSScrollingTextMarqueeViewDefines.h"
#import "MSFullscreenModeStatusBarDefines.h"
#import "MSSpeedupPlaybackPopupViewDefines.h"
#import "MSItemTags.h"

#pragma mark - 边缘控制层

@protocol MSEdgeControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlLayer : MSEdgeControlLayerAdapters<MSControlLayer>

///
/// loading 视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) __kindof UIView<MSLoadingView> *loadingView;

///
/// 拖拽进度视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) __kindof UIView<MSDraggingProgressPopupView> *draggingProgressPopupView;

///
/// 拖拽进度观察者
///
///     拖拽开始, 移动, 完成的回调
///
@property (nonatomic, strong, readonly) id<MSDraggingObservation> draggingObserver;

///
/// 标题视图
///
///     当需要自定义时, 可以实现指定的协议赋值给该控制层
///
@property (nonatomic, strong, null_resettable) __kindof UIView<MSScrollingTextMarqueeView> *titleView;

///
/// 长按手势触发加速播放时弹出的视图
///
@property (nonatomic, strong, null_resettable) UIView<MSSpeedupPlaybackPopupView> *speedupPlaybackPopupView;

///
/// 是否竖屏时隐藏标题
///
@property (nonatomic, getter=isHiddenTitleItemWhenOrientationIsPortrait) BOOL hiddenTitleItemWhenOrientationIsPortrait;

///
/// 是否竖屏时隐藏返回按钮
///
@property (nonatomic, getter=isHiddenBackButtonWhenOrientationIsPortrait) BOOL hiddenBackButtonWhenOrientationIsPortrait;

///
/// 是否将返回按钮固定
///
@property (nonatomic) BOOL fixesBackItem;

///
/// 是否禁止网络状态变化提示
///
@property (nonatomic, getter=isDisabledPromptingWhenNetworkStatusChanges) BOOL disabledPromptingWhenNetworkStatusChanges;

///
/// 是否隐藏底部进度条
///
@property (nonatomic, getter=isHiddenBottomProgressIndicator) BOOL hiddenBottomProgressIndicator;

///
/// 底部进度条高度. default value is 1.0
///
@property (nonatomic) CGFloat bottomProgressIndicatorHeight;

///
/// 自定义状态栏, 当 shouldShowsCustomStatusBar 返回YES, 将会显示该状态栏
///
@property (nonatomic, strong, null_resettable) UIView<MSFullscreenModeStatusBar> *customStatusBar NS_AVAILABLE_IOS(11.0);

///
/// 是否应该显示自定义状态栏
///
@property (nonatomic, copy, null_resettable) BOOL(^shouldShowsCustomStatusBar)(MSEdgeControlLayer *controlLayer) NS_AVAILABLE_IOS(11.0);

///
/// 是否自动选择`Rotation(旋转)`或`FitOnScreen(充满全屏)`
///
/// - Rotation(旋转): 播放器视图将会在横屏(全屏)与竖屏(小屏)之间切换
///
/// - FitOnScreen(充满全屏): 播放器视图将会在竖屏全屏与竖屏小屏之间切换
///
///     当视频`宽 > 高`时, 将执行 Rotation 相关方法.
///     当视频`宽 < 高`时, 将执行 FitOnScreen 相关方法.
///
@property (nonatomic) BOOL automaticallyPerformRotationOrFitOnScreen;

///
/// 处于小屏时, 当点击全屏按钮后, 是否先竖屏撑满全屏.
///
@property (nonatomic) BOOL needsFitOnScreenFirst;

@property (nonatomic, weak, nullable) id<MSEdgeControlLayerDelegate> delegate;
@end


@protocol MSEdgeControlLayerDelegate <NSObject>
- (void)backItemWasTappedForControlLayer:(id<MSControlLayer>)controlLayer;
@end


@interface MSEdgeControlButtonItem (MSControlLayerExtended)
///
/// 点击item时是否重置控制层的显示间隔
///
///     default value is YES
///
@property (nonatomic) BOOL resetsAppearIntervalWhenPerformingItemAction;
@end
NS_ASSUME_NONNULL_END
