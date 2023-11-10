//
//  MSPlume.h
//  MSPlumeProject
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/MSBornPlume
//  GitHub:     https://github.com/changsanjiang/MSPlume
//
//  Email:      changsanjiang@gmail.com
//  QQGroup:    930508201
//

#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#else
#import "MSBornPlume.h"
#endif
#import "MSControlLayerIdentifiers.h"
#import "MSPlumeConfigurations.h"
#import "MSPlumeResource+MSControlAdd.h"
#import "MSControlLayerSwitcher.h"

#import "MSEdgeControlLayer.h"
#import "MSMoreSettingControlLayer.h"
#import "MSLoadFailedControlLayer.h"
#import "MSNotReachableControlLayer.h"
#import "MSPlumeResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSPlume : MSBornPlume

///
/// 使用默认的控制层
///
+ (instancetype)shared;

///
/// A lightweight player with simple functions.
///
/// 一个具有简单功能的播放器.
///
+ (instancetype)lightweightCode;

- (instancetype)init;

///
/// v2.0.8
///
/// 新增: 控制层 切换器, 管理控制层的切换
///
@property (nonatomic, strong, readonly) MSControlLayerSwitcher *switcher;

// - 以下为各种状态下的播放器控制层, 均为懒加载 -

///
/// 默认的边缘控制层
///
///         当需要在竖屏隐藏返回按钮时, 可以设置`player.defaultEdgeControlLayer.hiddenBackButtonWhenOrientationIsPortrait = YES`
///         更多配置, 请前往该控制层头文件查看
///
@property (nonatomic, strong, readonly) MSEdgeControlLayer *defaultAdapter;

///
/// 默认的无网状态下显示的控制层
///
@property (nonatomic, strong, readonly) MSNotReachableControlLayer *defaultNotReachableControlLayer;

///
/// 默认的`more setting`控制层(调整音量/亮度/速率)
///
@property (nonatomic, strong, readonly) MSMoreSettingControlLayer *defaultMoreSettingControlLayer;

///
/// 默认的加载失败或播放出错时显示的控制层
///
@property (nonatomic, strong, readonly) MSLoadFailedControlLayer *defaultLoadFailedControlLayer;


- (instancetype)_init;
+ (NSString *)version;
@end

@interface MSPlume (CommonSettings)
///
/// Note: The `block` runs on the sub thread.
///
/// \code
///    MSPlume.updateResources(^(id<MSPlumeControlLayerResources>  _Nonnull resources) {
///        resources.placeholder = [UIImage imageNamed:@"placeholder"];
///        resources.progressThumbSize = 8;
///        resources.progressTrackColor = [UIColor colorWithWhite:0.8 alpha:1];
///        resources.progressBufferColor = [UIColor whiteColor];
///    });
/// \endcode
@property (class, nonatomic, copy, readonly) void(^updateResources)(void(^block)(id<MSPlumeControlLayerResources> resources));
@property (class, nonatomic, copy, readonly) void(^updateLocalizedStrings)(void(^block)(id<MSPlumeLocalizedStrings> strings));
@property (class, nonatomic, copy, readonly) void(^setLocalizedStrings)(NSBundle *bundle);
///
/// Note: The `block` runs on the sub thread.
///
/// \code
///     MSPlume.update(^(MSPlumeConfigurations * _Nonnull commonSettings) {
///         // 注意, 该block将在子线程执行
///         configs.resources.backImage = [UIImage imageNamed:@"icon_back"];
///         configs.resources.placeholder = [UIImage imageNamed:@"placeholder"];
///         configs.resources.progressTrackColor = [UIColor colorWithWhite:0.4 alpha:1];
///     });
/// \endcode
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(MSPlumeConfigurations *configs));
@end
 

@interface MSPlume (RotationOrFitOnScreen)
///
/// 当视频`宽 > 高`时, 将执行 Rotation(旋转至横屏全屏) 相关方法.
///
/// 当视频`宽 < 高`时, 将执行 FitOnScreen(竖屏全屏) 相关方法.
///
///     - Rotation: 播放器视图将会在横屏(全屏)与竖屏(小屏)之间切换
///
///     - FitOnScreen: 播放器视图将会在竖屏全屏与竖屏小屏之间切换
///
@property (nonatomic) BOOL automaticallyPerformRotationOrFitOnScreen;

///
/// 处于小屏时, 当点击全屏按钮后, 是否先竖屏撑满全屏.
///
@property (nonatomic) BOOL needsFitOnScreenFirst;

@end


@interface MSEdgeControlLayer (MSPlumeExtended)
///
/// 是否在Top栏上显示`more item`(三个点). default value is YES
///
/// 如果需要关闭, 可以设置: player.defaultEdgeControlLayer.showsMoreItem = NO;
///
@property (nonatomic) BOOL showsMoreItem;

///
/// 是否开启剪辑功能
///         - 默认是NO
///         - 不支持剪辑m3u8(如果开启, 将会自动隐藏剪辑按钮)
///
@property (nonatomic, getter=isEnabledClips) BOOL enabledClips;

@end

@interface MSPlume (MSExtendedControlLayerSwitcher)

///
/// 切换控制层
///
- (void)switchControlLayerForIdentifier:(MSControlLayerIdentifier)identifier;
@end
NS_ASSUME_NONNULL_END
