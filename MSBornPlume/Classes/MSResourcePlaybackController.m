//
//  MSResourcePlaybackController.m
//  Pods
//
//  Created by admin on 2020/2/18.
//

#import "MSResourcePlaybackController.h"
#import "MSExecuteCodeLoader.h"
#import "MSExecuteCode.h"
#import "MSExecuteCodeLayerView.h"
#import "MSPlumeResource+MSResourcePlaybackAdd.h"
#import "AVAsset+MSResourceExport.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSResourcePlaybackController ()

// https://github.com/changsanjiang/MSPlume/issues/339
@property (nonatomic) BOOL needsToRefresh_fix339 API_AVAILABLE(ios(14.0));

@end

@implementation MSResourcePlaybackController
@dynamic currentPlayer;
@dynamic currentPlayerView;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_playbackTypeDidChange:) name:MSCodeShowPlaybackTypeDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_playerViewReadyForDisplay:) name:MSCodeShowViewReadyForDisplayNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_rateDidChange:) name:MSCodeShowRateDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_volumeDidChange:) name:MSCodeShowVolumeDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_mutedDidChange:) name:MSCodeShowMutedDidChangeNotification object:nil];
        if (@available(iOS 14.2, *)) {
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_assetStatusDidChange:) name:MSCodeShowAssetStatusDidChangeNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

- (void)playerWithMedia:(MSPlumeResource *)media completionHandler:(void (^)(id<MSCodeShow> _Nullable))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MSExecuteCode *player = [MSExecuteCodeLoader loadPlayerForMedia:media];
        player.minBufferedDuration = self.minBufferedDuration;
        player.accurateSeeking = self.accurateSeeking;
        
        if ( (player.isPlayed && media.original == nil) || player.isPlaybackFinished ) {
            [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ( completionHandler ) completionHandler(player);
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( completionHandler ) completionHandler(player);
            });
        }
    });
}

- (UIView<MSCodeShowView> *)playerViewWithPlayer:(MSExecuteCode *)player {
    MSExecuteCodeLayerView *view = [MSExecuteCodeLayerView.alloc initWithFrame:CGRectZero];
    view.layer.player = player.avPlayer;
    return view;
}

- (void)receivedApplicationDidBecomeActiveNotification {

    if ( @available(iOS 14.0, *) ) {
        if ( self.media.iSpecial ) {
            if ( self.pauseWhenAppDidEnterBackground ||
                 // fix: https://github.com/changsanjiang/MSPlume/issues/535
                 self.timeControlStatus == MSPlumeStatePeached ) {
                if ( self.timeControlStatus == MSPlumeStatePeached ) {
                    self.needsToRefresh_fix339 = YES;
                    return;
                }
            }
        }
        
    }
    
    MSExecuteCodeLayerView *view = self.currentPlayerView;
    view.layer.player = self.currentPlayer.avPlayer;
    
    // fix: https://github.com/changsanjiang/MSPlume/issues/395
    if ( self.currentPlayerView.isReadyForDisplay ) {
        [self.currentPlayerView setScreenshot:nil];
    }
}
 
- (void)receivedApplicationDidEnterBackgroundNotification {
    
    if ( self.pauseWhenAppDidEnterBackground ) {
        [self pause];
    }
    else {
        [self _removePlayerForLayerIfNeeded];
    }
}

- (void)receivedApplicationWillResignActiveNotification {
    
    if ( self.pauseWhenAppDidEnterBackground && self.assetStatus == MSAssetStatusReadyToPlay /*fix #430 */ )
        [self.currentPlayerView setScreenshot:self.screenshot];
    
    // 修复 14.0 后台播放失效的问题
    if ( @available(iOS 14.0, *) ) {
        [self _removePlayerForLayerIfNeeded];
    }
}

#pragma mark -

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    if ( self.media.trialEndPosition != 0 && CMTimeGetSeconds(time) >= self.media.trialEndPosition ) {
        time = CMTimeMakeWithSeconds(self.media.trialEndPosition * 0.98, NSEC_PER_SEC);
    }
    [self.currentPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (NSTimeInterval)durationWatched {
    NSTimeInterval time = 0;
    for ( AVPlayerItemAccessLogEvent *event in self.currentPlayer.avPlayer.currentItem.accessLog.events) {
        if ( event.durationWatched <= 0 ) continue;
        time += event.durationWatched;
    }
    return time;
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _accurateSeeking = accurateSeeking;
    self.currentPlayer.accurateSeeking = accurateSeeking;
}

- (void)setMinBufferedDuration:(NSTimeInterval)minBufferedDuration {
    [super setMinBufferedDuration:minBufferedDuration];
    self.currentPlayer.minBufferedDuration = minBufferedDuration;
}

- (void)refresh {
    if ( self.media != nil ) [MSExecuteCodeLoader clearPlayerForMedia:self.media];
    if ( @available(iOS 14.0, *) ) {
        self.needsToRefresh_fix339 = NO;
    }
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    [super refresh];
}

- (void)play {
    [super play];
}

- (void)stop {
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    if ( @available(iOS 14.0, *) ) {
        self.needsToRefresh_fix339 = NO;
    }
    [super stop];
}

- (MSPlaybackType)playbackType {
    return self.currentPlayer.playbackType;
}

#pragma mark -

- (void)_av_playbackTypeDidChange:(NSNotification *)note {
    if ( note.object == self.currentPlayer ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeDidChange:)] ) {
            [self.delegate playbackController:self playbackTypeDidChange:self.playbackType];
        }
    }
}

- (void)_av_playerViewReadyForDisplay:(NSNotification *)note {
    if ( self.currentPlayerView == note.object ) {
        if ( self.currentPlayerView.isReadyForDisplay ) {
            [self.currentPlayerView setScreenshot:nil];
        }
    }
}

- (void)_av_rateDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.rate != self.currentPlayer.rate ) {
        self.rate = self.currentPlayer.rate;
    }
}

- (void)_av_volumeDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.volume != self.currentPlayer.volume ) {
        self.volume = self.currentPlayer.volume;
    }
}

- (void)_av_mutedDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.isMuted != self.currentPlayer.isMuted ) {
        self.muted = self.currentPlayer.isMuted;
    }
}

- (void)_av_assetStatusDidChange:(NSNotification *)note API_AVAILABLE(ios(14.2)) {
    
}

- (void)_removePlayerForLayerIfNeeded {
    if ( self.pauseWhenAppDidEnterBackground )
        return;
    
    MSExecuteCodeLayerView *view = self.currentPlayerView;
    view.layer.player = nil;
}
@end


@implementation MSResourcePlaybackController (MSResourcePlaybackAdd)
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(MSResourcePlaybackController *controller, UIImage * __nullable image, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset ms_screenshotWithTime:time size:size completionHandler:^(AVAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, image, error);
    }];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(MSResourcePlaybackController *controller, float progress))progressBlock
                 completion:(void(^)(MSResourcePlaybackController *controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completionBlock
                    failure:(void(^)(MSResourcePlaybackController *controller, NSError * __nullable error))failureBlock {
    [self cancelExportOperation];
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset ms_exportWithStartTime:beginTime duration:duration toFile:exportURL presetName:presetName progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionBlock ) completionBlock(self, fileURL, thumbImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failureBlock ) failureBlock(self, error);
    }];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(MSResourcePlaybackController *controller, float progress))progressBlock
                      completion:(void(^)(MSResourcePlaybackController *controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(MSResourcePlaybackController *controller, NSError *error))failure {
    [self cancelGenerateGIFOperation];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset ms_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:maximumSize interval:interval toFile:gifSavePath progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, UIImage * _Nonnull GIFImage, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, GIFImage, thumbnailImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelExportOperation {
    [self.currentPlayer.avPlayer.currentItem.asset ms_cancelExportOperation];
}
- (void)cancelGenerateGIFOperation {
    [self.currentPlayer.avPlayer.currentItem.asset ms_cancelGenerateGIFOperation];
}
@end

NS_ASSUME_NONNULL_END
