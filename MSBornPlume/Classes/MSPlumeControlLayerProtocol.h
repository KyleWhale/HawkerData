//
//  MSPlumeControlLayerProtocol.h
//  Project
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef MSPlumeControlLayerProtocol_h
#define MSPlumeControlLayerProtocol_h
#import <UIKit/UIKit.h>
#import "MSReachabilityDefines.h"
#import "MSPlumePlayStatusDefines.h"
#import "MSPlumePlaybackControllerDefines.h"
#import "MSGestureControllerDefines.h"

@protocol MSPlaybackInfoDelegate,
MSNetworkStatusControlDelegate,
MSLockScreenStateControlDelegate,
MSAppActivityControlDelegate,
MSVolumeBrightnessRateControlDelegate,
MSGestureControllerDelegate,
MSRotationControlDelegate,
MSFitOnScreenControlDelegate,
MSPlaybackControlDelegate;

@class MSBornPlume, MSPlumeResource;



@protocol MSPlumeControlLayerDataSource <NSObject>
@required
/// Please return to the control view of the control layer, which will be added to the player view.
/// 请返回控制层的根视图
/// 这个视图将会添加的播放器中
- (UIView *)plume_controlView;

@optional
/// This method will be called When installed control view of control layer to the video player.
/// 当安装好控制层后, 会回调这个方法
- (void)installedControlViewToPlume:(__kindof MSBornPlume *)plume;
@end


@protocol MSPlumeControlLayerDelegate <
    MSPlaybackInfoDelegate, 
    MSRotationControlDelegate,
    MSGestureControllerDelegate,
    MSNetworkStatusControlDelegate,
    MSVolumeBrightnessRateControlDelegate,
    MSLockScreenStateControlDelegate,
    MSAppActivityControlDelegate,
    MSFitOnScreenControlDelegate,
    MSPlaybackControlDelegate
>
@optional
/// This method will be called when the control layer needs to be appear.
/// You should do some appear work here.
/// 控制层需要显示. 你应该在这里做一些显示的工作
- (void)controlLayerNeedAppear:(__kindof MSBornPlume *)plume;

/// This method will be called when the control layer needs to be disappear.
/// You should do some disappear work here.
/// 控制层需要隐藏. 你应该在这个做一些隐藏的工作
- (void)controlLayerNeedDisappear:(__kindof MSBornPlume *)plume;

/// Asks the delegate if the control layer can automatically disappear.
/// 控制层是否可以自动隐藏
- (BOOL)controlLayerOfPlumeCanAutomaticallyDisappear:(__kindof MSBornPlume *)plume;

/// Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将出现时会回调这个方法
- (void)plumeWillAppearInScrollView:(__kindof MSBornPlume *)plume;

/// Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将消失时会回调这个方法
- (void)plumeWillDisappearInScrollView:(__kindof MSBornPlume *)plume;
@end


@protocol MSPlaybackControlDelegate <NSObject>
@optional
- (BOOL)canPerformPlayForPlume:(__kindof MSBornPlume *)plume;
- (BOOL)canPerformPauseForPlume:(__kindof MSBornPlume *)plume;
- (BOOL)canPerformStopForPlume:(__kindof MSBornPlume *)plume;
@end



@protocol MSPlaybackInfoDelegate <NSObject>
@optional

/// When the player is prepare to play a new asset, this method will be called.
/// 当播放器准备播放一个新的资源时, 会回调这个方法
- (void)plume:(__kindof MSBornPlume *)plume prepareToPlay:(MSPlumeResource *)asset;

///
/// 播放状态改变后的回调
///
///     以下状态发生变更时将会触发该回调
///     1.  timeControlStatus
///     2.  assetStatus
///     3.  播放完毕
///
- (void)plumePlaybackStatusDidChange:(__kindof MSBornPlume *)plume;

- (void)plume:(__kindof MSBornPlume *)plume currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)plume:(__kindof MSBornPlume *)plume durationDidChange:(NSTimeInterval)duration;
- (void)plume:(__kindof MSBornPlume *)plume playableDurationDidChange:(NSTimeInterval)duration;

- (void)plume:(__kindof MSBornPlume *)plume playbackTypeDidChange:(MSPlaybackType)playbackType;
- (void)plume:(__kindof MSBornPlume *)plume presentationSizeDidChange:(CGSize)size;
@end



@protocol MSVolumeBrightnessRateControlDelegate <NSObject>
@optional
- (void)plume:(__kindof MSBornPlume *)plume muteChanged:(BOOL)mute;
- (void)plume:(__kindof MSBornPlume *)plume volumeChanged:(float)volume;
- (void)plume:(__kindof MSBornPlume *)plume brightnessChanged:(float)brightness;
- (void)plume:(__kindof MSBornPlume *)plume rateChanged:(float)rate;
@end


@protocol MSRotationControlDelegate <NSObject>
@optional
/// Whether trigger rotation of video player
- (BOOL)canTriggerRotationOfPlume:(__kindof MSBornPlume *)plume;

/// Call it when player will rotate, `isFull` if YES, then full screen.
/// 当播放器将要旋转的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)plume:(__kindof MSBornPlume *)plume willRotateView:(BOOL)isFull;

/// When rotated player, this method will be called.
/// 当播放器旋转完成的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)plume:(__kindof MSBornPlume *)plume didEndRotation:(BOOL)isFull;

- (void)plume:(__kindof MSBornPlume *)plume onRotationTransitioningChanged:(BOOL)isTransitioning;
@end


/// v1.3.1 新增
/// 全屏但不旋转
@protocol MSFitOnScreenControlDelegate <NSObject>
@optional
///  When `fitOnScreen` of player will change, this method will be called;
/// 当播放器即将全屏(但不旋转)时, 这个方法将会被调用
- (void)plume:(__kindof MSBornPlume *)plume willFitOnScreen:(BOOL)isFitOnScreen;
- (void)plume:(__kindof MSBornPlume *)plume didCompleteFitOnScreen:(BOOL)isFitOnScreen;
@end



@protocol MSGestureControllerDelegate <NSObject>
@optional
/// Asks the delegate if gesture should trigger in the video player.
/// 是否可以触发某个手势
- (BOOL)plume:(__kindof MSBornPlume *)plume gestureRecognizerShouldTrigger:(MSCharmGestureType)type location:(CGPoint)location;

- (void)plume:(__kindof MSBornPlume *)plume panGestureTriggeredInTheHorizontalDirection:(MSPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime;

- (void)plume:(__kindof MSBornPlume *)plume longPressGestureStateDidChange:(MSLongPressGestureRecognizerState)state;
@end



@protocol MSNetworkStatusControlDelegate <NSObject>
@optional
/// 网络状态变更
/// 当网络状态变更时, 会回调这个方法
- (void)plume:(__kindof MSBornPlume *)plume reachabilityChanged:(MSNetworkStatus)status;
@end



@protocol MSLockScreenStateControlDelegate <NSObject>
@optional
/// This Tap gesture triggered when player locked screen.
/// If player locked(plume.lockedScreen == YES), When the user tapped on the player this method will be called.
/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof MSBornPlume *)plume;

/// Call it when set plume.lockedScreen == YES.
/// 当设置 plume.lockedScreen == YES 时, 这个方法将会调用
- (void)lockedPlume:(__kindof MSBornPlume *)plume;

/// Call it when set plume.lockedScreen == NO.
/// 当设置 plume.lockedScreen == NO 时, 这个方法将会调用
- (void)unlockedPlume:(__kindof MSBornPlume *)plume;
@end

@protocol MSAppActivityControlDelegate <NSObject>
@optional
- (void)applicationWillEnterForegroundWithPlume:(__kindof MSBornPlume *)plume;
- (void)applicationDidBecomeActiveWithPlume:(__kindof MSBornPlume *)plume;
- (void)applicationWillResignActiveWithPlume:(__kindof MSBornPlume *)plume;
- (void)applicationDidEnterBackgroundWithPlume:(__kindof MSBornPlume *)plume;
@end
#endif /* MSPlumeControlLayerProtocol_h */
