//
//  MSPlumeResourcePrefetcher.m
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import "MSPlumeResourcePrefetcher.h"
#import "MSExecuteCodeLoader.h"
#define __SJPrefetchMaxCount  (3)

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumeResourcePrefetcher ()
@property (nonatomic, strong, readonly) NSMutableArray<MSPlumeResource *> *m;
@end

@implementation MSPlumeResourcePrefetcher
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
- (MSPrefetchIdentifier)prefetchAsset:(MSPlumeResource *)asset {
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
- (MSPlumeResource *_Nullable)assetForURL:(NSURL *)URL {
    if ( URL ) {
        for ( MSPlumeResource *asset in _m ) {
            if ( [asset.mtSource isEqual:URL] )
                return asset;
        }
    }
    return nil;
}
- (MSPlumeResource *_Nullable)assetForIdentifier:(MSPrefetchIdentifier)identifier {
    for ( MSPlumeResource *asset in _m ) {
        if ( (NSInteger)asset == identifier )
            return asset;
    }
    return nil;
}
- (void)removeAsset:(MSPlumeResource *)asset {
    NSInteger idx = [self _indexOfAsset:asset];
    if ( idx != NSNotFound )
        [_m removeObjectAtIndex:idx];
}
- (NSInteger)_indexOfAsset:(MSPlumeResource *)asset {
    if (  asset ) {
        for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
            MSPlumeResource *a = _m[i];
            if ( a == asset || [a.mtSource isEqual:asset.mtSource] ) {
                return i;
            }
        }
    }
    return NSNotFound;
}
@end
NS_ASSUME_NONNULL_END
