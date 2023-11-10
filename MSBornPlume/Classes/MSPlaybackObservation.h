//
//  MSPlaybackObservation.h
//  Pods
//
//  Created by admin on 2019/8/27.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVTime.h>
@class MSBornPlume;

NS_ASSUME_NONNULL_BEGIN

@interface MSPlaybackObservation : NSObject
- (instancetype)initWithPlayer:(__kindof MSBornPlume *)player;

///
/// 播放状态改变后的回调
///
///     该block集合里以下3种回调
///     1.  timeControlStatusDidChangeExeBlock(播放控制改变的时候)
///     2.  assetStatusDidChangeExeBlock(资源状态改变的时候)
///     3.  playbackDidFinishExeBlock(播放完毕的时候)
///
@property (nonatomic, copy, nullable) void(^playbackStatusDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 播放完毕的回调
///
@property (nonatomic, copy, nullable) void(^playbackDidFinishExeBlock)(__kindof MSBornPlume *player);

///
/// 资源状态改变的回调
///
@property (nonatomic, copy, nullable) void(^assetStatusDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 播放控制改变的回调
///
@property (nonatomic, copy, nullable) void(^timeControlStatusDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 调用seek之前的回调
///
@property (nonatomic, copy, nullable) void(^willSeekToTimeExeBlock)(__kindof MSBornPlume *player, CMTime time);

///
/// 调用seek之后的回调
///
@property (nonatomic, copy, nullable) void(^didSeekToTimeExeBlock)(__kindof MSBornPlume *player, CMTime time);

///
/// 调用了重播的回调
///
@property (nonatomic, copy, nullable) void(^didReplayExeBlock)(__kindof MSBornPlume *player);

///
/// 切换清晰度状态改变的回调
///
@property (nonatomic, copy, nullable) void(^definitionSwitchStatusDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 当前时间改变的回调
///
@property (nonatomic, copy, nullable) void(^currentTimeDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 播放时长改变的回调
///
@property (nonatomic, copy, nullable) void(^durationDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 缓冲时长改变的回调
///
@property (nonatomic, copy, nullable) void(^playableDurationDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 获取到 video presentation size 时的回调
///
@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 获取到文件类型的回调
///
@property (nonatomic, copy, nullable) void(^playbackTypeDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 锁屏状态改变的回调
///
@property (nonatomic, copy, nullable) void(^screenLockStateDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 播放器的静音状态改变的回调
///
@property (nonatomic, copy, nullable) void(^mutedDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 播放器的声音改变的回调
///
@property (nonatomic, copy, nullable) void(^playerVolumeDidChangeExeBlock)(__kindof MSBornPlume *player);

///
/// 调速的回调
///
@property (nonatomic, copy, nullable) void(^rateDidChangeExeBlock)(__kindof MSBornPlume *player);

@property (nonatomic, weak, readonly, nullable) __kindof MSBornPlume *player;

///
/// 播放完毕的回调
///
///         现在不仅仅有播放至结束的位置了, 还会有播放至试看结束, 由于该属性仅能表示第一种情况, 故不推荐使用了.
///
@property (nonatomic, copy, nullable) void(^didPlayToEndTimeExeBlock)(__kindof MSBornPlume *player) __deprecated_msg("use `playbackDidFinishExeBlock`");

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
