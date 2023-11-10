//
//  MSPlumeURLAsset.h
//  MSPlumeProject
//
//  Created by 畅三江 on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPlumeModel.h"
#import "MSPlumePlaybackControllerDefines.h"

@protocol MSPlumeURLAssetObserver;

NS_ASSUME_NONNULL_BEGIN

@interface MSPlumeURLAsset : NSObject<MSMTModelProtocol>
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof MSPlumeModel *)playModel;
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition;
- (nullable instancetype)initWithSource:(NSURL *)URL playModel:(__kindof MSPlumeModel *)playModel;
- (nullable instancetype)initWithSource:(NSURL *)URL;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;

@property (nonatomic, strong, null_resettable) MSPlumeModel *playModel;
- (id<MSPlumeURLAssetObserver>)getObserver;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic) BOOL iSpecial;
@end


@protocol MSPlumeURLAssetObserver <NSObject>
@property (nonatomic, copy, nullable) void(^playModelDidChangeExeBlock)(MSPlumeURLAsset *asset);
@end
NS_ASSUME_NONNULL_END
