//
//  MSPlumeURLAssetPrefetcher.m
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import "MSPlumeURLAssetPrefetcher.h"
#import "MSExecuteCodeLoader.h"
#define __SJPrefetchMaxCount  (3)

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumeURLAssetPrefetcher ()
@property (nonatomic, strong, readonly) NSMutableArray<MSPlumeURLAsset *> *m;
@end

@implementation MSPlumeURLAssetPrefetcher
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _maxCount = 3;
    _m = [NSMutableArray array];
    return self;
}
- (MSPrefetchIdentifier)prefetchAsset:(MSPlumeURLAsset *)asset {
    if ( asset ) {
        NSInteger idx = [self _indexOfAsset:asset];
        if ( idx == NSNotFound ) {
            if ( _m.count > _maxCount ) {
                [_m removeObjectAtIndex:0];
            }
            // load asset
            [MSExecuteCodeLoader loadPlayerForMedia:asset];
            [_m addObject:asset];
        }
    }
    return (NSInteger)asset;
}
- (MSPlumeURLAsset *_Nullable)assetForURL:(NSURL *)URL {
    if ( URL ) {
        for ( MSPlumeURLAsset *asset in _m ) {
            if ( [asset.mtSource isEqual:URL] )
                return asset;
        }
    }
    return nil;
}
- (MSPlumeURLAsset *_Nullable)assetForIdentifier:(MSPrefetchIdentifier)identifier {
    for ( MSPlumeURLAsset *asset in _m ) {
        if ( (NSInteger)asset == identifier )
            return asset;
    }
    return nil;
}
- (void)removeAsset:(MSPlumeURLAsset *)asset {
    NSInteger idx = [self _indexOfAsset:asset];
    if ( idx != NSNotFound )
        [_m removeObjectAtIndex:idx];
}
- (NSInteger)_indexOfAsset:(MSPlumeURLAsset *)asset {
    if (  asset ) {
        for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
            MSPlumeURLAsset *a = _m[i];
            if ( a == asset || [a.mtSource isEqual:asset.mtSource] ) {
                return i;
            }
        }
    }
    return NSNotFound;
}
@end
NS_ASSUME_NONNULL_END
