//
//  MSBornPlumeConst.h
//  Pods
//
//  Created by admin on 2019/8/6.
//

#import <Foundation/Foundation.h>

/**
 用于记录常量和一些未来可能提供的通知.
 */

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const MSCharmViewTag;
extern NSInteger const MSPresentViewTag;


@interface MSCharmZIndexes : NSObject
+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic) NSInteger textPopupViewZIndex;
@property (nonatomic) NSInteger promptingPopupViewZIndex;
@property (nonatomic) NSInteger controlLayerViewZIndex;
@property (nonatomic) NSInteger danmakuViewZIndex;
@property (nonatomic) NSInteger placeholderImageViewZIndex;
@property (nonatomic) NSInteger subtitleViewZIndex;
@property (nonatomic) NSInteger playbackViewZIndex;
@end

// - Playback Notifications -


extern NSNotificationName const MSPlumeAssetStatusDidChangeNotification;
extern NSNotificationName const MSPlumeDefinitionSwitchStatusDidChangeNotification;

extern NSNotificationName const MSPlumeResourceWillChangeNotification;
extern NSNotificationName const MSPlumeResourceDidChangeNotification;

extern NSNotificationName const MSPlumeApplicationDidEnterBackgroundNotification;
extern NSNotificationName const MSPlumeApplicationWillEnterForegroundNotification;
extern NSNotificationName const MSPlumeApplicationWillTerminateNotification;

extern NSNotificationName const MSPlumePlaybackControllerWillDeallocateNotification; ///< 注意: 发送对象变为了`MSMTPlaybackController`(目前只此一个, 其他都为player对象)

extern NSNotificationName const MSPlumePlumeStateDidChangeNotification;
extern NSNotificationName const MSPlumePlaybackDidFinishNotification;         // 播放完毕后发出的通知
extern NSNotificationName const MSPlumePlaybackDidReplayNotification;         // 执行replay发出的通知
extern NSNotificationName const MSPlumePlaybackWillStopNotification;          // 执行stop前发出的通知
extern NSNotificationName const MSPlumePlaybackDidStopNotification;           // 执行stop后发出的通知
extern NSNotificationName const MSPlumePlaybackWillRefreshNotification;       // 执行refresh前发出的通知
extern NSNotificationName const MSPlumePlaybackDidRefreshNotification;        // 执行refresh后发出的通知
extern NSNotificationName const MSPlumePlaybackWillSeekNotification;          // 执行seek前发出的通知
extern NSNotificationName const MSPlumePlaybackDidSeekNotification;           // 执行seek后发出的通知

extern NSNotificationName const MSPlumeCurrentTimeDidChangeNotification;
extern NSNotificationName const MSPlumeDurationDidChangeNotification;
extern NSNotificationName const MSPlumePlayableDurationDidChangeNotification;
extern NSNotificationName const MSPlumePresentationSizeDidChangeNotification;
extern NSNotificationName const MSPlumePlaybackTypeDidChangeNotification;

extern NSNotificationName const MSPlumeRateDidChangeNotification;
extern NSNotificationName const MSPlumeMutedDidChangeNotification;
extern NSNotificationName const MSPlumeVolumeDidChangeNotification;
extern NSNotificationName const MSPlumeScreenLockStateDidChangeNotification;

extern NSString *const MSPlumeNotificationUserInfoKeySeekTime;
NS_ASSUME_NONNULL_END
