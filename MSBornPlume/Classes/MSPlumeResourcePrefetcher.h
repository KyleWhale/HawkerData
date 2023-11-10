//
//  MSPlumeResourcePrefetcher.h
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import <Foundation/Foundation.h>
#import "MSPlumeResource.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSInteger MSPrefetchIdentifier;

/// - 资源 预加载 -
///
/// 最多预加载`prefetcher.maxCount`个. 当超出时, 将会移除先前的.
///
/// \code
///    // - 1. 进行预加载
///    - (void)prefetchDemo {
///        NSURL *URL = [NSURL URLWithString:@"..."];
///        MSPlumeResource *asset = [[MSPlumeResource alloc] initWithSource:URL];
///        [MSPlumeResourcePrefetcher.shared prefetchAsset:asset];
///    }
///
///    // - 2. 从`Prefetcher`中获取, 如果为空, 则创建一个新的资源进行播放
///    - (void)playDemo {
///        NSURL *URL = [NSURL URLWithString:@"..."];
///        MSPlumeResource *asset = [MSPlumeResourcePrefetcher.shared assetForURL:URL];
///        if ( !asset ) {
///            asset = [[MSPlumeResource alloc] initWithSource:URL];
///        }
///        _player.resource = asset;
///    }
/// \endcode
@interface MSPlumeResourcePrefetcher : NSObject
+ (instancetype)shared;
@property (nonatomic) NSUInteger maxCount; // default value is 3;

- (MSPrefetchIdentifier)prefetchAsset:(MSPlumeResource *)asset;
- (MSPlumeResource *_Nullable)assetForURL:(NSURL *)URL;
- (MSPlumeResource *_Nullable)assetForIdentifier:(MSPrefetchIdentifier)identifier;
- (void)removeAsset:(MSPlumeResource *)asset;
@end
NS_ASSUME_NONNULL_END
