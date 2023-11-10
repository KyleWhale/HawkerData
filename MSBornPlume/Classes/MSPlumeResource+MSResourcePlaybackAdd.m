//
//  MSPlumeResource+MSResourcePlaybackAdd.m
//  Project
//
//  Created by admin on 2018/8/12.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "MSPlumeResource+MSResourcePlaybackAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation MSPlumeResource (MSResourcePlaybackAdd)
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset {
    return [self initWithAVAsset:asset playModel:[MSPlumeModel new]];
}
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset playModel:(__kindof MSPlumeModel *)playModel {
    return [self initWithAVAsset:asset startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset startPosition:(NSTimeInterval)startPosition playModel:(__kindof MSPlumeModel *)playModel {
    if ( asset == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avAsset = asset;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}

- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem {
    return [self initWithAVPlayerItem:playerItem playModel:MSPlumeModel.new];
}
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem playModel:(__kindof MSPlumeModel *)playModel {
    return [self initWithAVPlayerItem:playerItem startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem startPosition:(NSTimeInterval)startPosition playModel:(__kindof MSPlumeModel *)playModel {
    if ( playerItem == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avPlayerItem = playerItem;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}

- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player {
    return [self initWithAVPlayer:player playModel:MSPlumeModel.new];
}
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player playModel:(__kindof MSPlumeModel *)playModel {
    return [self initWithAVPlayer:player startPosition:0 playModel:MSPlumeModel.new];
}
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player startPosition:(NSTimeInterval)startPosition playModel:(__kindof MSPlumeModel *)playModel {
    if ( player == nil ) return nil;
    self = [super init];
    if ( self ) {
        self.avPlayer = player;
        self.playModel = playModel;
        self.startPosition = startPosition;
    }
    return self;
}
- (void)setAvAsset:(__kindof AVAsset * _Nullable)avAsset {
    objc_setAssociatedObject(self, @selector(avAsset), avAsset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable __kindof AVAsset *)avAsset {
    if ( self.original != nil ) return self.original.avAsset;
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAvPlayerItem:(AVPlayerItem * _Nullable)avPlayerItem {
    objc_setAssociatedObject(self, @selector(avPlayerItem), avPlayerItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPlayerItem *)avPlayerItem {
    if ( self.original != nil ) return self.original.avPlayerItem;
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAvPlayer:(AVPlayer * _Nullable)avPlayer {
    objc_setAssociatedObject(self, @selector(avPlayer), avPlayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable AVPlayer *)avPlayer {
    if ( self.original != nil ) return self.original.avPlayer;
    return objc_getAssociatedObject(self, _cmd);
}

- (nullable instancetype)initWithOtherAsset:(MSPlumeResource *)otherAsset playModel:(nullable __kindof MSPlumeModel *)playModel {
    if ( !otherAsset ) return nil;
    self = [super init];
    if ( self ) {
        MSPlumeResource *curr = otherAsset;
        while ( curr.original != nil && curr != curr.original ) {
            curr = curr.original;
        }
        self.original = curr;
        self.mtSource = curr.mtSource;
        self.playModel = playModel?:[MSPlumeModel new];
    }
    return self;
}

- (void)setOriginal:(MSPlumeResource * _Nullable)original {
    objc_setAssociatedObject(self, @selector(original), original, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable MSPlumeResource *)original {
    return objc_getAssociatedObject(self, _cmd);
}
- (nullable MSPlumeResource *)originAsset __deprecated_msg("ues `original`") {
    return self.original;
}
@end
NS_ASSUME_NONNULL_END
