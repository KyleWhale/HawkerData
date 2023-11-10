//
//  MSRotationManager.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationManagerDefines.h"
@protocol MSRotationActionForwarder;

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationManager : NSObject<MSRotationManager>
+ (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;
+ (instancetype)rotationManager;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id<MSRotationManagerObserver>)getObserver;

@property (nonatomic, copy, nullable) BOOL(^shouldTriggerRotation)(id<MSRotationManager> mgr);
@property (nonatomic, getter=isDisabledAutorotation) BOOL disabledAutorotation;
@property (nonatomic) MSOrientationMask autorotationSupportedOrientations;

- (void)rotate;
- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated;
- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated completionHandler:(nullable void(^)(id<MSRotationManager> mgr))completionHandler;

@property (nonatomic, readonly) MSOrientation currentOrientation;
@property (nonatomic, readonly) BOOL isFullscreen;
@property (nonatomic, readonly, getter=isRotating) BOOL rotating;
@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic, weak, nullable) UIView *superview;
@property (nonatomic, weak, nullable) UIView *target;
@property (nonatomic, weak, nullable) id<MSRotationActionForwarder> actionForwarder;
@end

@protocol MSRotationActionForwarder <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIStatusBarStyle)preferredStatusBarStyle;
- (BOOL)prefersStatusBarHidden;
@end
NS_ASSUME_NONNULL_END


#pragma mark - fix safe area

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, MSSafeAreaInsetsMask) {
    MSSafeAreaInsetsMaskNone = 0,
    MSSafeAreaInsetsMaskTop = 1 << 0,
    MSSafeAreaInsetsMaskLeft = 1 << 1,
    MSSafeAreaInsetsMaskBottom = 1 << 2,
    MSSafeAreaInsetsMaskRight = 1 << 3,
    
    MSSafeAreaInsetsMaskHorizontal = MSSafeAreaInsetsMaskLeft | MSSafeAreaInsetsMaskRight,
    MSSafeAreaInsetsMaskVertical = MSSafeAreaInsetsMaskTop | MSSafeAreaInsetsMaskRight,
    MSSafeAreaInsetsMaskAll = MSSafeAreaInsetsMaskHorizontal | MSSafeAreaInsetsMaskVertical
} API_DEPRECATED("deprecated!", ios(13.0, 16.0)) ;


API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @interface UIViewController (MSRotationSafeAreaFixing)
/// 禁止调整哪些方向的安全区
@property (nonatomic) MSSafeAreaInsetsMask disabledAdjustSafeAreaInsetsMask;
@end
NS_ASSUME_NONNULL_END
