//
//  MSDeviceVolumeAndBrightness.h
//  MSBornPlume
//
//  Created by 蓝舞者 on 2022/10/14.
//

#import <UIKit/UIKit.h>
@protocol MSDeviceVolumeAndBrightnessObserver;

NS_ASSUME_NONNULL_BEGIN
@interface MSDeviceVolumeAndBrightness : NSObject
+ (instancetype)shared;

@property (nonatomic, strong, readonly) UIView *sysVolumeView;

@property (nonatomic) float volume;
@property (nonatomic) float brightness;

- (void)addObserver:(id<MSDeviceVolumeAndBrightnessObserver>)observer;
- (void)removeObserver:(id<MSDeviceVolumeAndBrightnessObserver>)observer;
@end

@protocol MSDeviceVolumeAndBrightnessObserver <NSObject>
@optional
- (void)device:(MSDeviceVolumeAndBrightness *)device onVolumeChanged:(float)volume;
- (void)device:(MSDeviceVolumeAndBrightness *)device onBrightnessChanged:(float)brightness;
@end
NS_ASSUME_NONNULL_END
