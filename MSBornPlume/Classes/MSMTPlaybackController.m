//
//  MSMTPlaybackController.m
//  Pods
//
//  Created by admin on 2020/2/17.
//

#import "MSMTPlaybackController.h"
#import "NSTimer+MSAssetAdd.h"

NS_ASSUME_NONNULL_BEGIN
///
/// 清晰度切换加载控制
///
///     当`definitionMediaPlayer`加载完成或失败后, 将会回调`completionHandler`
///
@interface MSDefinitionMediaPlayerLoader : NSObject
- (instancetype)initWithDefinitionMediaPlayer:(id<MSCodeShow>)definitionMediaPlayer
                    definitionMediaPlayerView:(UIView<MSCodeShowView> *)definitionMediaPlayerView
                                currentPlayer:(id<MSCodeShow>)currentPlayer
                            currentPlayerView:(UIView<MSCodeShowView> *)currentPlayerView
                            completionHandler:(void(^)(MSDefinitionMediaPlayerLoader *loader, BOOL isFinished))completionHandler;

@property (nonatomic, strong, readonly, nullable) id<MSCodeShow> definitionMediaPlayer;
@property (nonatomic, strong, readonly, nullable) UIView<MSCodeShowView> *definitionMediaPlayerView;
@property (nonatomic, strong, readonly, nullable) id<MSCodeShow> currentPlayer;
@property (nonatomic, strong, readonly, nullable) UIView<MSCodeShowView> *currentPlayerView;
- (void)cancel;
@end


@interface MSCodeShowTimeObserverItem : NSObject
- (instancetype)initWithInterval:(NSTimeInterval)interval player:(__weak id<MSCodeShow>)player currentTimeDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))currentTimeDidChangeExeBlock playableDurationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))playableDurationDidChangeExeBlock durationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval time))durationDidChangeExeBlock;
- (void)invalidate;
- (void)stop;
@end

@implementation MSCodeShowTimeObserverItem {
    void (^_currentTimeDidChangeExeBlock)(NSTimeInterval);
    void (^_playableDurationDidChangeExeBlock)(NSTimeInterval);
    void (^_durationDidChangeExeBlock)(NSTimeInterval);
    __weak id<MSCodeShow> _player;
    NSTimeInterval _interval;
    
    NSTimer *_timer;
    NSTimeInterval _currentTime;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval player:(__weak id<MSCodeShow>)player currentTimeDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))currentTimeDidChangeExeBlock playableDurationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))playableDurationDidChangeExeBlock durationDidChangeExeBlock:(nonnull void (^)(NSTimeInterval))durationDidChangeExeBlock {
    self = [super init];
    if ( self ) {
        _interval = interval;
        _player = player;
        _currentTimeDidChangeExeBlock = currentTimeDidChangeExeBlock;
        _playableDurationDidChangeExeBlock = playableDurationDidChangeExeBlock;
        _durationDidChangeExeBlock = durationDidChangeExeBlock;
        
        [self resumeOrPause];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resumeOrPause) name:MSCodeShowTimeControlStatusDidChangeNotification object:player];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(durationDidChange) name:MSCodeShowDurationDidChangeNotification object:_player];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playableDurationDidChange) name:MSCodeShowPlayableDurationDidChangeNotification object:_player];
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)invalidate {
    [_timer invalidate];
    _timer = nil;
}

- (void)durationDidChange {
    if ( _durationDidChangeExeBlock ) _durationDidChangeExeBlock(_player.duration);
}

- (void)playableDurationDidChange {
    if ( _playableDurationDidChangeExeBlock ) _playableDurationDidChangeExeBlock(_player.playableDuration);
}

- (void)resumeOrPause {
    if ( _player.timeControlStatus == MSPlumeStatePeached ) {
        [self invalidate];
    }
    else if ( _timer == nil ) {
        __weak typeof(self) _self = self;
        _timer = [NSTimer ms_timerWithTimeInterval:_interval repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
            __strong typeof(_self) self = _self;
            if ( !self ) { [timer invalidate]; return ; }
            [self _refresh];
        }];
        _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_interval];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    [self invalidate];
    if ( _playableDurationDidChangeExeBlock ) _playableDurationDidChangeExeBlock(0);
    if ( _currentTimeDidChangeExeBlock ) _currentTimeDidChangeExeBlock(0);
    if ( _durationDidChangeExeBlock ) _durationDidChangeExeBlock(0);
}
 
- (void)_refresh {
    NSTimeInterval currentTime = _player.currentTime;
    if ( _currentTime != currentTime ) {
        _currentTime = currentTime;
        if ( _currentTimeDidChangeExeBlock ) _currentTimeDidChangeExeBlock(currentTime);
    }
}
@end

@interface MSCodeShowContentView : UIView
@property (nonatomic, strong, nullable) UIView <MSCodeShowView> *view;
@end

@implementation MSCodeShowContentView
- (void)setView:(nullable UIView<MSCodeShowView> *)view {
    if ( _view ) [_view removeFromSuperview];
    _view = view;
    if ( view != nil ) {
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
    }
}
@end

@interface MSMTPlaybackController () {
    MSCodeShowContentView *_playerView;
}
@property (nonatomic) MSPlumeState timeControlStatus;
@property (nonatomic, nullable) MSWaitingReason reasonForWaitingToPlay;
@property (nonatomic, strong, nullable) id<MSCodeShow> currentPlayer;
@property (nonatomic, strong, nullable) id periodicTimeObserver;
@end

@implementation MSMTPlaybackController
@synthesize pauseWhenAppDidEnterBackground = _pauseWhenAppDidEnterBackground;
@synthesize periodicTimeInterval = _periodicTimeInterval;
@synthesize minBufferedDuration = _minBufferedDuration;
@synthesize delegate = _delegate;
@synthesize volume = _volume;
@synthesize rate = _rate;
@synthesize muted = _muted;
@synthesize media = _media;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _rate = 1;
        _volume = 1;
        _pauseWhenAppDidEnterBackground = YES;
        _periodicTimeInterval = 0.5;
        [self _initObservations];
    }
    return self;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d - %s", (int)__LINE__, __func__);
#endif
    [_playerView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerWithMedia:(MSPlumeResource *)media completionHandler:(void(^)(id<MSCodeShow> _Nullable player))completionHandler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil];
}

- (UIView<MSCodeShowView> *)playerViewWithPlayer:(id<MSCodeShow>)player {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil];
}

- (void)receivedApplicationDidBecomeActiveNotification { }

- (void)receivedApplicationWillResignActiveNotification { }

- (void)receivedApplicationWillEnterForegroundNotification { }

- (void)receivedApplicationDidEnterBackgroundNotification {
    if ( self.pauseWhenAppDidEnterBackground )
        [self pause];
}

- (void)prepareToPlay {
    if ( _media == nil ) return;
    
    MSPlumeResource *media = _media;
    __weak typeof(self) _self = self;
    [self playerWithMedia:media completionHandler:^(id<MSCodeShow>  _Nullable player) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.media != media ) return;
        if ( player == nil ) return;
        player.trialEndPosition = media.trialEndPosition;
        self.currentPlayer = player;
        self.currentPlayerView = [self playerViewWithPlayer:player];
    }];
}

#pragma mark -

- (void)pause {
    self.timeControlStatus = MSPlumeStatePeached;
    [self.currentPlayer pause];
}

- (void)play {
    if ( self.assetStatus == MSAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    // no item to play
    if ( self.currentPlayer == nil ) {
        self.reasonForWaitingToPlay = MSWaitingWithNoAssetToPlayReason;
        self.timeControlStatus = MSPlumeStateWaiting;
    }
    // play
    else {
        self.reasonForWaitingToPlay = MSWaitingWhileEvaluatingBufferingRateReason;
        self.timeControlStatus = MSPlumeStateWaiting;
        self.isPlaybackFinished ? [self.currentPlayer replay] : [self.currentPlayer play];
        if ( self.currentPlayer.rate != self.rate ) self.currentPlayer.rate = self.rate;
        [self _toEvaluating];
    }
}

- (void)replay {
    if ( self.assetStatus == MSAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    if ( self.currentPlayer == nil ) {
        return;
    }
    
    self.reasonForWaitingToPlay = MSWaitingWhileEvaluatingBufferingRateReason;
    self.timeControlStatus = MSPlumeStateWaiting;
    [self.currentPlayer replay];
    [self _toEvaluating];
}

- (void)stop {
    [self.currentPlayerView removeFromSuperview];
    _playerView.view = nil;
    self.currentPlayer = nil;
    _media = nil;
    [_periodicTimeObserver stop];
    [self _removePeriodicTimeObserver];
    if ( self.timeControlStatus != MSPlumeStatePeached )
        self.timeControlStatus = MSPlumeStatePeached;
}

- (void)refresh {
    if ( self.currentPlayer.isPlayed && self.duration != 0 && self.currentTime != 0 )
        self.media.startPosition = self.currentTime;
    self.currentPlayer = nil;
    [self prepareToPlay];
    [self play];
}

- (nullable UIImage *)screenshot {
    return [self.currentPlayer screenshot];
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    [self seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    if ( [self.delegate respondsToSelector:@selector(playbackController:willSeekToTime:)] ) {
        [self.delegate playbackController:self willSeekToTime:time];
    }
    __weak typeof(self) _self = self;
    [self.currentPlayer seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(finished);
        if ( [self.delegate respondsToSelector:@selector(playbackController:didSeekToTime:)] ) {
            [self.delegate playbackController:self didSeekToTime:time];
        }
    }];
}

- (MSAssetStatus)assetStatus {
    return self.currentPlayer.assetStatus;
}

- (NSTimeInterval)currentTime {
    return _currentPlayer.seekingInfo.isSeeking ? CMTimeGetSeconds(_currentPlayer.seekingInfo.time) : _currentPlayer.currentTime;
}

- (NSTimeInterval)duration {
    return _currentPlayer.duration;
}

- (NSTimeInterval)durationWatched {
    return 0;
}

- (nullable NSError *)error {
    return _currentPlayer.error;
}

- (BOOL)isPlayed {
    return _currentPlayer.isPlayed;
}

- (BOOL)isReplayed {
    return _currentPlayer.isReplayed;
}

- (BOOL)isPlaybackFinished {
    return _currentPlayer.isPlaybackFinished;
}

- (nullable MSFinishedReason)finishedReason {
    return _currentPlayer.finishedReason;
}

- (NSTimeInterval)playableDuration {
    return _currentPlayer.playableDuration;
}

- (MSPlaybackType)playbackType {
    return MSPlaybackTypeUnknown;
}

- (MSCodeShowContentView *)codeView {
    if ( _playerView == nil ) {
        _playerView = [MSCodeShowContentView.alloc initWithFrame:CGRectZero];
    }
    return _playerView;
}

- (BOOL)isReadyForDisplay {
    return self.currentPlayerView.isReadyForDisplay;
}

- (CGSize)presentationSize {
    return _currentPlayer.presentationSize;
}

@synthesize spGravity = _spGravity;
- (void)setSpGravity:(MSSPGravity)spGravity {
    _spGravity = spGravity ? : AVLayerVideoGravityResizeAspect;
    self.currentPlayerView.spGravity = self.spGravity;
}
- (MSSPGravity)spGravity {
    if ( _spGravity == nil )
        return AVLayerVideoGravityResizeAspect;
    return _spGravity;
}

- (void)setMedia:(nullable MSPlumeResource *)media {
    if ( _media != nil ) [self stop];
    _media = media;
}

- (void)setPeriodicTimeInterval:(NSTimeInterval)periodicTimeInterval {
    _periodicTimeInterval = periodicTimeInterval;
    [self _removePeriodicTimeObserver];
    [self _addPeriodicTimeObserver];
}
 
- (void)setRate:(float)rate {
    _rate = rate;
    if ( self.timeControlStatus != MSPlumeStatePeached ) _currentPlayer.rate = rate;
    if ( [self.delegate respondsToSelector:@selector(playbackController:rateDidChange:)] ) {
        [self.delegate playbackController:self rateDidChange:rate];
    }
}

- (void)setVolume:(float)volume {
    _volume = volume;
    _currentPlayer.volume = volume;
    if ( [self.delegate respondsToSelector:@selector(playbackController:volumeDidChange:)] ) {
        [self.delegate playbackController:self volumeDidChange:volume];
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    _currentPlayer.muted = muted;
    if ( [self.delegate respondsToSelector:@selector(playbackController:mutedDidChange:)] ) {
        [self.delegate playbackController:self mutedDidChange:muted];
    }
}

- (void)setCurrentPlayer:(nullable id<MSCodeShow>)currentPlayer {
    _currentPlayer = currentPlayer;
    if ( currentPlayer != nil ) {
        currentPlayer.volume = self.volume;
        currentPlayer.muted = self.muted;
        if ( self.timeControlStatus != MSPlumeStatePeached ) currentPlayer.rate = self.rate;
        [self _addPeriodicTimeObserver];
        [currentPlayer report];
    }
}

- (void)setCurrentPlayerView:(__kindof UIView<MSCodeShowView> * _Nullable)currentPlayerView {
    currentPlayerView.spGravity = self.spGravity;
    _playerView.view = currentPlayerView;
}
- (nullable __kindof UIView<MSCodeShowView> *)currentPlayerView {
    return _playerView.view;
}

- (void)setTimeControlStatus:(MSPlumeState)timeControlStatus {
    if ( timeControlStatus == MSPlumeStatePeached ) _reasonForWaitingToPlay = nil;
    _timeControlStatus = timeControlStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].idleTimerDisabled = (timeControlStatus != MSPlumeStatePeached);
        if ( [self.delegate respondsToSelector:@selector(playbackController:timeControlStatusDidChange:)] ) {
            [self.delegate playbackController:self timeControlStatusDidChange:timeControlStatus];
        }
    });
}

#pragma mark -

- (void)_toEvaluating {
    if ( self.assetStatus == MSAssetStatusFailed ) {
        self.timeControlStatus = MSPlumeStatePeached;
    }
    
    if ( self.currentPlayer.isPlaybackFinished ) {
        self.timeControlStatus = MSPlumeStatePeached;
    }
    
    if ( self.timeControlStatus == MSPlumeStatePeached && self.currentPlayer.timeControlStatus != MSPlumeStatePluming ) {
        return;
    }
    
    // 处于准备|失败中
    if ( self.currentPlayer.assetStatus != MSAssetStatusReadyToPlay )
        return;

    if ( self.reasonForWaitingToPlay == MSWaitingWithNoAssetToPlayReason )
        [self.currentPlayer play];
    
    if ( self.timeControlStatus != self.currentPlayer.timeControlStatus ||
         self.reasonForWaitingToPlay != self.currentPlayer.reasonForWaitingToPlay ) {
        self.reasonForWaitingToPlay = self.currentPlayer.reasonForWaitingToPlay;
        self.timeControlStatus = self.currentPlayer.timeControlStatus;
    }
}

- (void)_addPeriodicTimeObserver {
    __weak typeof(self) _self = self;
    _periodicTimeObserver = [MSCodeShowTimeObserverItem.alloc initWithInterval:_periodicTimeInterval player:self.currentPlayer currentTimeDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:currentTimeDidChange:)] ) {
            [self.delegate playbackController:self currentTimeDidChange:time];
        }
    } playableDurationDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:playableDurationDidChange:)] ) {
            [self.delegate playbackController:self playableDurationDidChange:time];
        }
    } durationDidChangeExeBlock:^(NSTimeInterval time) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.delegate respondsToSelector:@selector(playbackController:durationDidChange:)] ) {
            [self.delegate playbackController:self durationDidChange:time];
        }
    }];
}

- (void)_removePeriodicTimeObserver {
    [_periodicTimeObserver invalidate];
    _periodicTimeObserver = nil;
}

- (void)_initObservations {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerAssetStatusDidChange:) name:MSCodeShowAssetStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerTimeControlStatusDidChange:) name:MSCodeShowTimeControlStatusDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playbackDidFinish:) name:MSCodeShowPlaybackDidFinishNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPresentationSizeDidChange:) name:MSCodeShowPresentationSizeDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerViewReadyForDisplay:) name:MSCodeShowViewReadyForDisplayNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerDidReplay:) name:MSCodeShowDidReplayNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(audioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_receivedApplicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_receivedApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_receivedApplicationWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_receivedApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)_receivedApplicationDidBecomeActiveNotification {
    [self receivedApplicationDidBecomeActiveNotification];
    if ( [self.delegate respondsToSelector:@selector(applicationDidBecomeActiveWithPlaybackController:)] ) {
        [self.delegate applicationDidBecomeActiveWithPlaybackController:self];
    }
}

- (void)_receivedApplicationWillResignActiveNotification {
    [self receivedApplicationWillResignActiveNotification];
    if ( [self.delegate respondsToSelector:@selector(applicationWillResignActiveWithPlaybackController:)] ) {
        [self.delegate applicationWillResignActiveWithPlaybackController:self];
    }
}

- (void)_receivedApplicationWillEnterForegroundNotification {
    [self receivedApplicationWillEnterForegroundNotification];
    if ( [self.delegate respondsToSelector:@selector(applicationWillEnterForegroundWithPlaybackController:)] ) {
        [self.delegate applicationWillEnterForegroundWithPlaybackController:self];
    }
}

- (void)_receivedApplicationDidEnterBackgroundNotification {
    [self receivedApplicationDidEnterBackgroundNotification];
    if ( [self.delegate respondsToSelector:@selector(applicationDidEnterBackgroundWithPlaybackController:)] ) {
        [self.delegate applicationDidEnterBackgroundWithPlaybackController:self];
    }
}

- (void)playerAssetStatusDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( [self.delegate respondsToSelector:@selector(playbackController:assetStatusDidChange:)] ) {
                [self.delegate playbackController:self assetStatusDidChange:self.assetStatus];
            }
        });
    }
}

- (void)playerTimeControlStatusDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
    }
}

- (void)playbackDidFinish:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        [self _toEvaluating];
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackDidFinish:)] ) {
            [self.delegate playbackController:self playbackDidFinish:self.finishedReason];
        }
    }
}

- (void)playerPresentationSizeDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:presentationSizeDidChange:)] ) {
            [self.delegate playbackController:self presentationSizeDidChange:self.presentationSize];
        }
    }
}

- (void)playerViewReadyForDisplay:(NSNotification *)note {
    if ( self.currentPlayerView == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackControllerIsReadyForDisplay:)] ) {
            [self.delegate playbackControllerIsReadyForDisplay:self];
        }
    }
}

- (void)playerDidReplay:(NSNotification *)note {
    if ( self.currentPlayer == note.object ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:didReplay:)] ) {
            [self.delegate playbackController:self didReplay:self.media];
        }
    }
}

- (void)audioSessionInterruption:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = note.userInfo;
        if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
            [self pause];
        }
    });
}

- (void)audioSessionRouteChange:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *interuptionDict = note.userInfo;
        NSInteger reason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        if ( reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable ) {
            [self pause];
        }
    });
}

@end

#pragma mark -


@interface MSDefinitionMediaPlayerLoader () {
    void(^_completionHandler)(MSDefinitionMediaPlayerLoader *loader, BOOL isFinished);
    BOOL _isSeeking;
}
@end

@implementation MSDefinitionMediaPlayerLoader
- (instancetype)initWithDefinitionMediaPlayer:(id<MSCodeShow>)definitionMediaPlayer
                    definitionMediaPlayerView:(UIView<MSCodeShowView> *)definitionMediaPlayerView
                                currentPlayer:(id<MSCodeShow>)currentPlayer
                            currentPlayerView:(UIView<MSCodeShowView> *)currentPlayerView
                            completionHandler:(void(^)(MSDefinitionMediaPlayerLoader *loader, BOOL isFinished))completionHandler {
    self = [super init];
    if ( self ) {
        _definitionMediaPlayer = definitionMediaPlayer;
        _definitionMediaPlayerView = definitionMediaPlayerView;
        
        _currentPlayer = currentPlayer;
        _currentPlayerView = currentPlayerView;
        
        _completionHandler = completionHandler;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:MSCodeShowAssetStatusDidChangeNotification object:definitionMediaPlayer];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_statusDidChange) name:MSCodeShowViewReadyForDisplayNotification object:definitionMediaPlayerView];

        UIView *superview = currentPlayerView.superview;
        definitionMediaPlayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        definitionMediaPlayerView.frame = superview.bounds;
        [superview insertSubview:definitionMediaPlayerView atIndex:0];

        _definitionMediaPlayer.muted = YES;
        [_definitionMediaPlayer play];
        
        [self _statusDidChange];
    }
    return self;
}

- (void)_statusDidChange {
    switch ( _definitionMediaPlayer.assetStatus ) {
        case MSAssetStatusUnknown:
        case MSAssetStatusPreparing:
            break;
        case MSAssetStatusReadyToPlay: {
            if ( _definitionMediaPlayerView.isReadyForDisplay && _isSeeking == NO ) {
                [self _seekToCurPos];
            }
        }
            break;
        case MSAssetStatusFailed:
            [self _didCompleteLoad:NO];
            break;
    }
}

- (void)_seekToCurPos {
    _isSeeking = YES;
    __weak typeof(self) _self = self;
    [_definitionMediaPlayer seekToTime:CMTimeMakeWithSeconds(_currentPlayer.currentTime, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _didCompleteLoad:finished];
    }];
}

- (void)_didCompleteLoad:(BOOL)result {
    if ( result ) {
        [_definitionMediaPlayerView removeFromSuperview];
        _definitionMediaPlayer.muted = NO;
    }
    else {
        [_definitionMediaPlayerView removeFromSuperview];
        [_definitionMediaPlayer pause];
        _definitionMediaPlayer = nil;
    }
    if ( _completionHandler ) _completionHandler(self, result);
    _completionHandler = nil;
}

- (void)cancel {
    _completionHandler = nil;
    [_definitionMediaPlayerView removeFromSuperview];
    _definitionMediaPlayer = nil;
}
@end

NSNotificationName const MSCodeShowAssetStatusDidChangeNotification = @"MSCodeShowAssetStatusDidChangeNotification";
NSNotificationName const MSCodeShowTimeControlStatusDidChangeNotification = @"MSCodeShowTimeControlStatusDidChangeNotification";
NSNotificationName const MSCodeShowPresentationSizeDidChangeNotification = @"MSCodeShowPresentationSizeDidChangeNotification";
NSNotificationName const MSCodeShowPlaybackDidFinishNotification = @"MSCodeShowPlaybackDidFinishNotification";
NSNotificationName const MSCodeShowDidReplayNotification = @"MSCodeShowDidReplayNotification";
NSNotificationName const MSCodeShowDurationDidChangeNotification = @"MSCodeShowDurationDidChangeNotification";
NSNotificationName const MSCodeShowPlayableDurationDidChangeNotification = @"MSCodeShowPlayableDurationDidChangeNotification";
NSNotificationName const MSCodeShowRateDidChangeNotification = @"MSCodeShowRateDidChangeNotification";
NSNotificationName const MSCodeShowVolumeDidChangeNotification = @"MSCodeShowVolumeDidChangeNotification";
NSNotificationName const MSCodeShowMutedDidChangeNotification = @"MSCodeShowMutedDidChangeNotification";


NSNotificationName const MSCodeShowViewReadyForDisplayNotification = @"MSCodeShowViewReadyForDisplayNotification";
NSNotificationName const MSCodeShowPlaybackTypeDidChangeNotification = @"MSCodeShowPlaybackTypeDidChangeNotification";
NS_ASSUME_NONNULL_END
