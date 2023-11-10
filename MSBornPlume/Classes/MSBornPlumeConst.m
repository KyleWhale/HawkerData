//
//  MSBornPlumeConst.m
//  Pods
//
//  Created by admin on 2019/8/6.
//

#import "MSBornPlumeConst.h"
#import "MSPlumePlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN

NSInteger const MSCharmViewTag = 0xFFFFFFF0;
NSInteger const MSPresentViewTag = 0xFFFFFFF1;

@implementation MSCharmZIndexes
+ (instancetype)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] _init];
    });
    return instance;
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {
        _textPopupViewZIndex = -10;
        _promptingPopupViewZIndex = -20;
        _controlLayerViewZIndex = -30;
        _danmakuViewZIndex = -40;
        _placeholderImageViewZIndex = -50;
        _subtitleViewZIndex = -70;
        _playbackViewZIndex = -80;
    }
    return self;
}
@end

///
/// assetStatus 改变的通知
///
NSNotificationName const MSPlumeAssetStatusDidChangeNotification = @"MSPlumeAssetStatusDidChangeNotification";

///
/// 切换清晰度状态 改变的通知
///
NSNotificationName const MSPlumeDefinitionSwitchStatusDidChangeNotification = @"MSPlumeDefinitionSwitchStatusDidChangeNotification";

///
/// 播放资源将要改变前发出的通知
///
NSNotificationName const MSPlumeResourceWillChangeNotification = @"MSPlumeResourceWillChangeNotification";
///
/// 播放资源改变后发出的通知
///
NSNotificationName const MSPlumeResourceDidChangeNotification = @"MSPlumeResourceDidChangeNotification";




///
/// 播放器收到App进入后台的通知后发出的通知
///
NSNotificationName const MSPlumeApplicationDidEnterBackgroundNotification = @"MSPlumeApplicationDidEnterBackgroundNotification";
///
/// 播放器收到App进入前台的通知后发出的通知
///
NSNotificationName const MSPlumeApplicationWillEnterForegroundNotification = @"MSPlumeApplicationWillEnterForegroundNotification";
///
/// 播放器收到App将要关闭的通知后发出的通知
///
NSNotificationName const MSPlumeApplicationWillTerminateNotification = @"MSPlumeApplicationWillTerminateNotification";

///
/// 播放器的playbackController将要进行销毁前的通知
///
NSNotificationName const MSPlumePlaybackControllerWillDeallocateNotification = @"MSPlumePlaybackControllerWillDeallocateNotification"; ///< 注意: object 为 MSMTPlaybackController 的对象


///
/// timeControlStatus 改变的通知
///
NSNotificationName const MSPlumePlumeStateDidChangeNotification = @"MSPlumePlumeStateDidChangeNotification";

///
/// 播放完毕后发出的通知
///
NSNotificationName const MSPlumePlaybackDidFinishNotification = @"MSPlumePlaybackDidFinishNotification";

///
/// 执行replay发出的通知
///
NSNotificationName const MSPlumePlaybackDidReplayNotification = @"MSPlumePlaybackDidReplayNotification";
///
/// 执行stop前发出的通知
///
NSNotificationName const MSPlumePlaybackWillStopNotification = @"MSPlumePlaybackWillStopNotification";
///
/// 执行stop后发出的通知
///
NSNotificationName const MSPlumePlaybackDidStopNotification = @"MSPlumePlaybackDidStopNotification";
///
/// 执行refresh前发出的通知
///
NSNotificationName const MSPlumePlaybackWillRefreshNotification = @"MSPlumePlaybackWillRefreshNotification";
///
/// 执行refresh后发出的通知
///
NSNotificationName const MSPlumePlaybackDidRefreshNotification = @"MSPlumePlaybackDidRefreshNotification";
///
/// 执行seek前发出的通知
///
NSNotificationName const MSPlumePlaybackWillSeekNotification = @"MSPlumePlaybackWillSeekNotification";
///
/// 执行seek后发出的通知
///
NSNotificationName const MSPlumePlaybackDidSeekNotification = @"MSPlumePlaybackDidSeekNotification";



///
/// 当前播放时间 改变的通知
///
NSNotificationName const MSPlumeCurrentTimeDidChangeNotification = @"MSPlumeCurrentTimeDidChangeNotification";

///
/// 获取到播放时长的通知
///
NSNotificationName const MSPlumeDurationDidChangeNotification = @"MSPlumeDurationDidChangeNotification";

///
/// 缓冲时长 改变的通知
///
NSNotificationName const MSPlumePlayableDurationDidChangeNotification = @"MSPlumePlayableDurationDidChangeNotification";

///
/// 获取到视频宽高的通知
///
NSNotificationName const MSPlumePresentationSizeDidChangeNotification = @"MSPlumePresentationSizeDidChangeNotification";

///
/// 获取到播放类型的通知
///
NSNotificationName const MSPlumePlaybackTypeDidChangeNotification = @"MSPlumePlaybackTypeDidChangeNotification";

///
/// 锁屏状态 改变的通知
///
NSNotificationName const MSPlumeScreenLockStateDidChangeNotification = @"MSPlumeScreenLockStateDidChangeNotification";

///
/// 静音状态 改变的通知
///
NSNotificationName const MSPlumeMutedDidChangeNotification = @"MSPlumeMutedDidChangeNotification";

///
/// 音量 改变的通知
///
NSNotificationName const MSPlumeVolumeDidChangeNotification = @"MSPlumeVolumeDidChangeNotification";

///
/// 调速 改变的通知
///
NSNotificationName const MSPlumeRateDidChangeNotification = @"MSPlumeRateDidChangeNotification";


MSWaitingReason const MSWaitingToMinimizeStallsReason = @"AVPlayerWaitingToMinimizeStallsReason";
MSWaitingReason const MSWaitingWhileEvaluatingBufferingRateReason = @"AVPlayerWaitingWhileEvaluatingBufferingRateReason";
MSWaitingReason const MSWaitingWithNoAssetToPlayReason = @"AVPlayerWaitingWithNoItemToPlayReason";

MSFinishedReason const MSFinishedReasonToEndTimePosition = @"MSFinishedReasonToEndTimePosition";
MSFinishedReason const MSFinishedReasonToTrialEndPosition = @"MSFinishedReasonToTrialEndPosition";

NSString *const MSPlumeNotificationUserInfoKeySeekTime = @"time";
NS_ASSUME_NONNULL_END
