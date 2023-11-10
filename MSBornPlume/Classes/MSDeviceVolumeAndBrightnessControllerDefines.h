//
//  MSDeviceVolumeAndBrightnessControllerProtocol.h
//  Pods
//
//  Created by admin on 2019/1/5.
//

#ifndef MSDeviceVolumeAndBrightnessControllerProtocol_h
#define MSDeviceVolumeAndBrightnessControllerProtocol_h
#import <UIKit/UIKit.h>
@protocol MSDeviceVolumeAndBrightnessTargetViewContext, MSDeviceVolumeAndBrightnessControllerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol MSDeviceVolumeAndBrightnessController <NSObject>
- (id<MSDeviceVolumeAndBrightnessControllerObserver>)getObserver;
@property (nonatomic) float volume; // device volume
@property (nonatomic) float brightness; // device brightness

/// 以下属性由播放器自动维护
///
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, strong, nullable) id<MSDeviceVolumeAndBrightnessTargetViewContext> targetViewContext;

- (void)onTargetViewMoveToWindow;
- (void)onTargetViewContextUpdated;
@end

/// TargetView 当前环境
@protocol MSDeviceVolumeAndBrightnessTargetViewContext <NSObject>
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly) BOOL isFitOnScreen;
@property (nonatomic, readonly) BOOL isPlayOnScrollView;
@property (nonatomic, readonly) BOOL isScrollAppeared;
@property (nonatomic, readonly) BOOL isFloatingMode;    // 小窗口悬浮模式
@end

@protocol MSDeviceVolumeAndBrightnessControllerObserver
@property (nonatomic, copy, nullable) void(^volumeDidChangeExeBlock)(id<MSDeviceVolumeAndBrightnessController> mgr, float volume);
@property (nonatomic, copy, nullable) void(^brightnessDidChangeExeBlock)(id<MSDeviceVolumeAndBrightnessController> mgr, float brightness);
@end
NS_ASSUME_NONNULL_END
#endif /* MSDeviceVolumeAndBrightnessControllerProtocol_h */
