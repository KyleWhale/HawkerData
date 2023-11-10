//
//  MSDeviceVolumeAndBrightnessControllerDefines.h
//  MSDeviceVolumeAndBrightnessController
//
//  Created by admin on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDeviceVolumeAndBrightnessControllerDefines.h"
@protocol MSDeviceVolumeAndBrightnessPopupView, MSDeviceVolumeAndBrightnessPopupViewDataSource;

NS_ASSUME_NONNULL_BEGIN
@interface MSDeviceVolumeAndBrightnessController : NSObject<MSDeviceVolumeAndBrightnessController>
@property (nonatomic, strong, nullable) UIView<MSDeviceVolumeAndBrightnessPopupView> *brightnessView;
@property (nonatomic, strong, nullable) UIView<MSDeviceVolumeAndBrightnessPopupView> *volumeView;
@end


#pragma mark -

@protocol MSDeviceVolumeAndBrightnessPopupViewDataSource <NSObject>
/// 起始状态(progress == 0)
@property (nonatomic, strong, nullable) UIImage *startImage;
/// 普通状态
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float progress;
@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;
@end

@protocol MSDeviceVolumeAndBrightnessPopupView <NSObject>
@property (nonatomic, strong) id<MSDeviceVolumeAndBrightnessPopupViewDataSource> dataSource;

- (void)refreshData;
@end



#pragma mark -

/// 系统音量条的显示管理
@interface MSDeviceSystemVolumeViewDisplayManager : NSObject
+ (instancetype)shared;

/// 是否自动控制系统音量条显示, default value is YES;
///
///     如需直接使用系统音量条, 请设置 NO 关闭自动控制;
///
@property (nonatomic) BOOL automaticallyDisplaySystemVolumeView;


// internal methods

- (void)update;
- (void)addController:(nullable id<MSDeviceVolumeAndBrightnessController>)controller;
- (void)removeController:(nullable id<MSDeviceVolumeAndBrightnessController>)controller;
@end
NS_ASSUME_NONNULL_END
