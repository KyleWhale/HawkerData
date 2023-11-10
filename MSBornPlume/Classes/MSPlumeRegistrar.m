//
//  MSPlumeRegistrar.m
//  MSPlumeProject
//
//  Created by admin on 2017/12/5.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "MSPlumeRegistrar.h"
#import <AVFoundation/AVFoundation.h>
#if __has_include(<MSUIKit/NSObject+MSObserverHelper.h>)
#import <MSUIKit/NSObject+MSObserverHelper.h>
#else
#import "NSObject+MSObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@implementation MSPlumeRegistrar
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self ms_observeWithNotification:AVAudioSessionRouteChangeNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            NSDictionary *interuptionDict = note.userInfo;
            NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
            switch (routeChangeReason) {
                case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
                    if ( self.newDeviceAvailable ) self.newDeviceAvailable(self);
                }
                    break;
                case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
                    if ( self.oldDeviceUnavailable ) self.oldDeviceUnavailable(self);
                }
                    break;
                case AVAudioSessionRouteChangeReasonCategoryChange: {
                    if ( self.categoryChange ) self.categoryChange(self);
                }
                    break;
            }
        }];

        [self ms_observeWithNotification:UIApplicationWillResignActiveNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.willResignActive ) self.willResignActive(self);
        }];
        
        [self ms_observeWithNotification:UIApplicationDidBecomeActiveNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.didBecomeActive ) self.didBecomeActive(self);
        }];
        
        [self ms_observeWithNotification:UIApplicationWillEnterForegroundNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.willEnterForeground ) self.willEnterForeground(self);
        }];
        
        [self ms_observeWithNotification:UIApplicationWillTerminateNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.willTerminate ) self.willTerminate(self);
        }];
        
        [self ms_observeWithNotification:UIApplicationDidEnterBackgroundNotification target:nil usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            if ( self.didEnterBackground ) self.didEnterBackground(self);
        }];
        
        [self ms_observeWithNotification:AVAudioSessionInterruptionNotification target:[AVAudioSession sharedInstance] usingBlock:^(MSPlumeRegistrar *_Nonnull self, NSNotification * _Nonnull note) {
            NSDictionary *info = note.userInfo;
            if( (AVAudioSessionInterruptionType)[info[AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan ) {
                if ( self.audioSessionInterruption ) self.audioSessionInterruption(self);
            }
        }];
    }); 
    return self;
}

- (MSPlumeAppState)state {
    return UIApplication.sharedApplication.applicationState;
}
@end
NS_ASSUME_NONNULL_END
