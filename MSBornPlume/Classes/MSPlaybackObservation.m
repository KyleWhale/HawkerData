//
//  MSPlaybackObservation.m
//  Pods
//
//  Created by admin on 2019/8/27.
//

#import "MSPlaybackObservation.h"
#import "MSBornPlumeConst.h"
#import "MSPlumePlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN
@implementation MSPlaybackObservation {
    NSMutableArray *_tokens;
}
- (instancetype)initWithPlayer:(__kindof MSBornPlume *)player {
    self = [super init];
    if ( self ) {
        _tokens = NSMutableArray.new;
        _player = player;
        
        __weak typeof(self) _self = self;
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeAssetStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.assetStatusDidChangeExeBlock ) self.assetStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlumeStateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.timeControlStatusDidChangeExeBlock ) self.timeControlStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlaybackDidFinishNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playbackDidFinishExeBlock ) self.playbackDidFinishExeBlock(self.player);
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            else if ( self.didPlayToEndTimeExeBlock && [(id)self.player valueForKey:@"finishedReason"] == MSFinishedReasonToEndTimePosition ) self.didPlayToEndTimeExeBlock(self.player);
            #pragma clang diagnostic pop
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeDefinitionSwitchStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.definitionSwitchStatusDidChangeExeBlock ) self.definitionSwitchStatusDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeCurrentTimeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.currentTimeDidChangeExeBlock ) self.currentTimeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.durationDidChangeExeBlock ) self.durationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlayableDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playableDurationDidChangeExeBlock ) self.playableDurationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePresentationSizeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.presentationSizeDidChangeExeBlock ) self.presentationSizeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlaybackTypeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playbackTypeDidChangeExeBlock ) self.playbackTypeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeScreenLockStateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.screenLockStateDidChangeExeBlock ) self.screenLockStateDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeMutedDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.mutedDidChangeExeBlock ) self.mutedDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeVolumeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playerVolumeDidChangeExeBlock ) self.playerVolumeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumeRateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.rateDidChangeExeBlock ) self.rateDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlaybackDidReplayNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.didReplayExeBlock ) self.didReplayExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlaybackWillSeekNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.willSeekToTimeExeBlock ) self.willSeekToTimeExeBlock(note.object, [(NSValue *)note.userInfo[MSPlumeNotificationUserInfoKeySeekTime] CMTimeValue]);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:MSPlumePlaybackDidSeekNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.didSeekToTimeExeBlock ) self.didSeekToTimeExeBlock(note.object, [(NSValue *)note.userInfo[MSPlumeNotificationUserInfoKeySeekTime] CMTimeValue]);
        }]];
    }
    return self;
}

- (void)dealloc {
    for ( id token in _tokens ) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
    }
}
@end
NS_ASSUME_NONNULL_END
