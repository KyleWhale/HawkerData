//
//  MSPlumeResource.m
//  MSPlumeProject
//
//  Created by admin on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "MSPlumeResource.h"
#import <objc/message.h>
#if __has_include(<MSUIKit/NSObject+MSObserverHelper.h>)
#import <MSUIKit/NSObject+MSObserverHelper.h>
#else
#import "NSObject+MSObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumeResourceObserver : NSObject<MSPlumeResourceObserver>
- (instancetype)initWithAsset:(MSPlumeResource *)asset;
@end
@implementation MSPlumeResourceObserver
@synthesize playModelDidChangeExeBlock = _playModelDidChangeExeBlock;

- (instancetype)initWithAsset:(MSPlumeResource *)asset {
    self = [super init];
    if ( !self ) return nil;
    [asset ms_addObserver:self forKeyPath:@"playModel"];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( _playModelDidChangeExeBlock ) _playModelDidChangeExeBlock(object);
}
@end

@implementation MSPlumeResource
@synthesize mtSource = _mtSource;

- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof MSPlumeModel *)playModel {
    if ( !URL ) return nil;
    self = [super init];
    if ( !self ) return nil;
    _mtSource = URL;
    _startPosition = startPosition;
    _playModel = playModel?:[MSPlumeModel new];
    _iSpecial = [_mtSource.pathExtension containsString:@"m3u8"];
    return self;
}
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition {
    return [self initWithSource:URL startPosition:startPosition playModel:[MSPlumeModel new]];
}
- (nullable instancetype)initWithSource:(NSURL *)URL playModel:(__kindof MSPlumeModel *)playModel {
    return [self initWithSource:URL startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithSource:(NSURL *)URL {
    return [self initWithSource:URL startPosition:0];
}
- (void)setMediaURL:(nullable NSURL *)mtSource {
    _mtSource = mtSource;
    _iSpecial = [mtSource.pathExtension containsString:@"m3u8"];
}
- (MSPlumeModel *)playModel {
    if ( _playModel )
        return _playModel;
    return _playModel = [MSPlumeModel new];
}
- (id<MSPlumeResourceObserver>)getObserver {
    return [[MSPlumeResourceObserver alloc] initWithAsset:self];
}
@end
NS_ASSUME_NONNULL_END
