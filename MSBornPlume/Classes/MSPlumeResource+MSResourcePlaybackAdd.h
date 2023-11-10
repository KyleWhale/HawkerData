//
//  MSPlumeResource+MSResourcePlaybackAdd.h
//  Project
//
//  Created by admin on 2018/8/12.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "MSPlumeResource.h"
#import <AVFoundation/AVFoundation.h>
#import "MSPlumeModel.h"
#import "MSPlumePlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumeResource (MSResourcePlaybackAdd)
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                               playModel:(__kindof MSPlumeModel *)playModel;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                           startPosition:(NSTimeInterval)startPosition
                               playModel:(__kindof MSPlumeModel *)playModel;

- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                    playModel:(__kindof MSPlumeModel *)playModel;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                startPosition:(NSTimeInterval)startPosition
                                    playModel:(__kindof MSPlumeModel *)playModel;

- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                                playModel:(__kindof MSPlumeModel *)playModel;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                            startPosition:(NSTimeInterval)startPosition
                                playModel:(__kindof MSPlumeModel *)playModel;

@property (nonatomic, strong, nullable) __kindof AVAsset *avAsset;
@property (nonatomic, strong, nullable) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong, nullable) AVPlayer *avPlayer;

- (nullable instancetype)initWithOtherAsset:(MSPlumeResource *)otherAsset
                                  playModel:(nullable __kindof MSPlumeModel *)playModel;

@property (nonatomic, strong, readonly, nullable) MSPlumeResource *original;
- (nullable MSPlumeResource *)originAsset __deprecated_msg("ues `original`");
@end
NS_ASSUME_NONNULL_END
