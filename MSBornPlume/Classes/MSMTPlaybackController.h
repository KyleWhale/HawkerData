//
//  MSMTPlaybackController.h
//  Pods
//
//  Created by admin on 2020/2/17.
//

#import <Foundation/Foundation.h>
#import "MSPlumePlaybackControllerDefines.h"
#import "MSPlumeResource.h"
@protocol MSCodeShow, MSCodeShowView;

NS_ASSUME_NONNULL_BEGIN
@interface MSMTPlaybackController : NSObject<MSPlumePlaybackController>
@property (nonatomic, strong, nullable) MSPlumeResource *media;
///
/// 当前的播放器
///
@property (nonatomic, strong, readonly, nullable) id<MSCodeShow> currentPlayer;
@property (nonatomic, strong, readonly, nullable) __kindof UIView<MSCodeShowView> *currentPlayerView;

///
/// 子类返回
///
///     第三方播放器需实现`<MSCodeShow>`协议
///
- (void)playerWithMedia:(MSPlumeResource *)media completionHandler:(void(^)(id<MSCodeShow> _Nullable player))completionHandler;

///
/// 子类返回
///
- (UIView<MSCodeShowView> *)playerViewWithPlayer:(id<MSCodeShow>)player;

///
/// 以下方法在接收到通知后执行
///
- (void)receivedApplicationDidBecomeActiveNotification;
- (void)receivedApplicationWillResignActiveNotification;
- (void)receivedApplicationWillEnterForegroundNotification;
- (void)receivedApplicationDidEnterBackgroundNotification;

@end

///
/// 当播放器状态改变时, 需发送相应的通知
///
/// player
extern NSNotificationName const MSCodeShowAssetStatusDidChangeNotification;
extern NSNotificationName const MSCodeShowTimeControlStatusDidChangeNotification;
extern NSNotificationName const MSCodeShowPresentationSizeDidChangeNotification;
extern NSNotificationName const MSCodeShowPlaybackDidFinishNotification;
extern NSNotificationName const MSCodeShowDidReplayNotification;
extern NSNotificationName const MSCodeShowDurationDidChangeNotification;
extern NSNotificationName const MSCodeShowPlayableDurationDidChangeNotification;
extern NSNotificationName const MSCodeShowRateDidChangeNotification;
extern NSNotificationName const MSCodeShowVolumeDidChangeNotification;
extern NSNotificationName const MSCodeShowMutedDidChangeNotification;

/// view
extern NSNotificationName const MSCodeShowViewReadyForDisplayNotification;

@protocol MSCodeShowView <NSObject>
@property (nonatomic) MSSPGravity spGravity;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;
@end

@protocol MSCodeShow <NSObject>
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, readonly, nullable) MSWaitingReason reasonForWaitingToPlay;
@property (nonatomic, readonly) MSPlumeState timeControlStatus;
@property (nonatomic, readonly) MSAssetStatus assetStatus;
@property (nonatomic, readonly) MSSeekingInfo seekingInfo;
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly) BOOL isReplayed; ///< 是否调用过`replay`方法
@property (nonatomic, readonly) BOOL isPlayed; ///< 是否调用过`play`方法
@property (nonatomic, readonly) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, readonly, nullable) MSFinishedReason finishedReason;      ///< 播放结束的reason
@property (nonatomic) NSTimeInterval trialEndPosition;                          ///< 试用结束的位置, 单位秒
@property (nonatomic) float rate;
@property (nonatomic) float volume;
@property (nonatomic, getter=isMuted) BOOL muted;

- (void)seekToTime:(CMTime)time completionHandler:(nullable void (^)(BOOL finished))completionHandler;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;    
@property (nonatomic, readonly) NSTimeInterval playableDuration;

- (void)play;
- (void)pause;

- (void)replay;
- (void)report;

- (nullable UIImage *)screenshot;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/// 这个通知是可选的(如果可以获取到playbacType, 请发送该通知)
extern NSNotificationName const MSCodeShowPlaybackTypeDidChangeNotification;

NS_ASSUME_NONNULL_END
