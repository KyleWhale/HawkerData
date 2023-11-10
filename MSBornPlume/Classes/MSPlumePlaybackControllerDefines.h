//
//  MSPlumePlaybackController.h
//  Project
//
//  Created by admin on 2018/8/10.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef MSMTPlaybackProtocol_h
#define MSMTPlaybackProtocol_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MSPlumePlayStatusDefines.h"

@protocol MSPlumePlaybackControllerDelegate, MSMTModelProtocol;

typedef AVLayerVideoGravity MSSPGravity;

typedef struct {
    BOOL isSeeking;
    CMTime time;
} MSSeekingInfo;

NS_ASSUME_NONNULL_BEGIN
@protocol MSPlumePlaybackController<NSObject>
@required
@property (nonatomic) NSTimeInterval periodicTimeInterval; // default value is 0.5
@property (nonatomic) NSTimeInterval minBufferedDuration; // default value is 8.0
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, weak, nullable) id<MSPlumePlaybackControllerDelegate> delegate;

@property (nonatomic, readonly) MSPlaybackType playbackType;
@property (nonatomic, strong, readonly) __kindof UIView *codeView;
@property (nonatomic, strong, nullable) id<MSMTModelProtocol> media;
@property (nonatomic, strong) MSSPGravity spGravity; // default value is AVLayerVideoGravityResizeAspect

// - status -
@property (nonatomic, readonly) MSAssetStatus assetStatus;
@property (nonatomic, readonly) MSPlumeState timeControlStatus;
@property (nonatomic, readonly, nullable) MSWaitingReason reasonForWaitingToPlay;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic, readonly) NSTimeInterval durationWatched; // 已观看的时长
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic, getter=isMuted) BOOL muted;

@property (nonatomic, readonly) BOOL isPlayed;                      ///< 当前media是否调用过play
@property (nonatomic, readonly, getter=isReplayed) BOOL replayed;   ///< 当前media是否调用过replay
@property (nonatomic, readonly) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, readonly, nullable) MSFinishedReason finishedReason;      ///< 播放结束的reason
- (void)prepareToPlay;
- (void)replay;
- (void)refresh;
- (void)play;
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ __nullable)(BOOL))completionHandler;
- (nullable UIImage *)screenshot;

@end

/// screenshot`
@protocol MSMTPlaybackScreenshotController
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(id<MSPlumePlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;
@end


/// export
@protocol MSMTPlaybackExportController
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<MSPlumePlaybackController> controller, float progress))progress
                 completion:(void(^)(id<MSPlumePlaybackController> controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(id<MSPlumePlaybackController> controller, NSError * __nullable error))failure;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(id<MSPlumePlaybackController> controller, float progress))progressBlock
                      completion:(void(^)(id<MSPlumePlaybackController> controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(id<MSPlumePlaybackController> controller, NSError *error))failure;

- (void)cancelExportOperation;
- (void)cancelGenerateGIFOperation;
@end


/// delegate
@protocol MSPlumePlaybackControllerDelegate<NSObject>

@optional
#pragma mark -
- (void)playbackController:(id<MSPlumePlaybackController>)controller assetStatusDidChange:(MSAssetStatus)status;
- (void)playbackController:(id<MSPlumePlaybackController>)controller timeControlStatusDidChange:(MSPlumeState)status;
#pragma mark -


// - new -
- (void)playbackController:(id<MSPlumePlaybackController>)controller volumeDidChange:(float)volume;
- (void)playbackController:(id<MSPlumePlaybackController>)controller rateDidChange:(float)rate;
- (void)playbackController:(id<MSPlumePlaybackController>)controller mutedDidChange:(BOOL)isMuted;

- (void)playbackController:(id<MSPlumePlaybackController>)controller playbackDidFinish:(MSFinishedReason)reason;
- (void)playbackController:(id<MSPlumePlaybackController>)controller durationDidChange:(NSTimeInterval)duration;
- (void)playbackController:(id<MSPlumePlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)playbackController:(id<MSPlumePlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;
- (void)playbackController:(id<MSPlumePlaybackController>)controller playbackTypeDidChange:(MSPlaybackType)playbackType;
- (void)playbackController:(id<MSPlumePlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration;
- (void)playbackControllerIsReadyForDisplay:(id<MSPlumePlaybackController>)controller;
- (void)playbackController:(id<MSPlumePlaybackController>)controller didReplay:(id<MSMTModelProtocol>)media;

- (void)playbackController:(id<MSPlumePlaybackController>)controller willSeekToTime:(CMTime)time;
- (void)playbackController:(id<MSPlumePlaybackController>)controller didSeekToTime:(CMTime)time;

- (void)applicationWillEnterForegroundWithPlaybackController:(id<MSPlumePlaybackController>)controller;
- (void)applicationDidBecomeActiveWithPlaybackController:(id<MSPlumePlaybackController>)controller;
- (void)applicationWillResignActiveWithPlaybackController:(id<MSPlumePlaybackController>)controller;
- (void)applicationDidEnterBackgroundWithPlaybackController:(id<MSPlumePlaybackController>)controller;

@end


/// media
@protocol MSMTModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mtSource;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* MSMTPlaybackProtocol_h */
