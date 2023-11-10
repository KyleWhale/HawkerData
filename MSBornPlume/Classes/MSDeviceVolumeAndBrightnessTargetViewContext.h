//
//  MSDeviceVolumeAndBrightnessTargetViewContext.h
//  MSBornPlume
//
//  Created by 蓝舞者 on 2022/11/2.
//

#import "MSDeviceVolumeAndBrightnessControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSDeviceVolumeAndBrightnessTargetViewContext : NSObject<MSDeviceVolumeAndBrightnessTargetViewContext>
@property (nonatomic) BOOL isFullscreen;
@property (nonatomic) BOOL isFitOnScreen;
@property (nonatomic) BOOL isPlayOnScrollView;
@property (nonatomic) BOOL isScrollAppeared;
@property (nonatomic) BOOL isFloatingMode; // 是否进入了小浮窗模式
@end
NS_ASSUME_NONNULL_END
