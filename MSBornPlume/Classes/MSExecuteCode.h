//
//  MSExecuteCode.h
//  Pods
//
//  Created by admin on 2020/2/18.
//

#import "MSMTPlaybackController.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSExecuteCode : NSObject<MSCodeShow>
- (instancetype)initWithAVPlayer:(AVPlayer *)player startPosition:(NSTimeInterval)time;

@property (nonatomic) NSTimeInterval trialEndPosition;
@property (nonatomic, strong, readonly) AVPlayer *avPlayer;
@property (nonatomic, readonly) MSPlaybackType playbackType;
@property (nonatomic) NSTimeInterval minBufferedDuration;
@property (nonatomic) BOOL accurateSeeking;

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler;
@end
NS_ASSUME_NONNULL_END
