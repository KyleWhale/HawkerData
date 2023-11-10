//
//  MSRotationManagerDefines.h
//  Pods
//
//  Created by admin on 2018/9/19.
//

#ifndef MSRotationManagerProtocol_h
#define MSRotationManagerProtocol_h

#import <UIKit/UIKit.h>
@protocol MSRotationManager, MSRotationManagerObserver;
@class MSPlumeModel;
/**
 视图方向
 
 - MSOrientation_Portrait:       竖屏
 - MSOrientation_LandscapeLeft:  全屏, Home键在右侧
 - MSOrientation_LandscapeRight: 全屏, Home键在左侧
 */
typedef NS_ENUM(NSUInteger, MSOrientation) {
    MSOrientation_Portrait = UIDeviceOrientationPortrait,
    MSOrientation_LandscapeLeft = UIDeviceOrientationLandscapeLeft,
    MSOrientation_LandscapeRight = UIDeviceOrientationLandscapeRight,
};

typedef NS_OPTIONS(NSUInteger, MSOrientationMask) {
    MSOrientationMaskPortrait = 1 << MSOrientation_Portrait,
    MSOrientationMaskLandscapeLeft = 1 << MSOrientation_LandscapeLeft,
    MSOrientationMaskLandscapeRight = 1 << MSOrientation_LandscapeRight,
    MSOrientationMaskAll = MSOrientationMaskPortrait | MSOrientationMaskLandscapeLeft | MSOrientationMaskLandscapeRight,
};

NS_ASSUME_NONNULL_BEGIN
@protocol MSRotationManager<NSObject>
- (id<MSRotationManagerObserver>)getObserver;


@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(id<MSRotationManager> mgr);

///
/// 是否禁止自动旋转
/// - 该属性只会禁止自动旋转, 当调用 rotate 等方法还是可以旋转的
/// - 默认为 false
///
@property (nonatomic, getter=isDisabledAutorotation) BOOL disabledAutorotation;

///
/// 自动旋转时, 所支持的方法
/// - 默认为 .all
///
@property (nonatomic) MSOrientationMask autorotationSupportedOrientations;

///
/// 旋转
/// - Animated
///
- (void)rotate;

///
/// 旋转到指定方向
///
- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated;

///
/// 旋转到指定方向
///
- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<MSRotationManager> mgr))completionHandler;

///
/// 当前的方向
///
@property (nonatomic, readonly) MSOrientation currentOrientation;

///
/// 是否全屏
/// - landscapeRight 或者 landscapeLeft 即为全屏
///
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly, getter=isRotating) BOOL rotating; // 是否正在旋转
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning; // 是否正在进行转场

///
/// 以下属性由播放器维护
///
@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
@end

@protocol MSRotationManagerProtocol <MSRotationManager> @end

@protocol MSRotationManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^onRotatingChanged)(id<MSRotationManager> mgr, BOOL isRotating);
@property (nonatomic, copy, nullable) void(^onTransitioningChanged)(id<MSRotationManager> mgr, BOOL isTransitioning);
@end
NS_ASSUME_NONNULL_END
#endif
