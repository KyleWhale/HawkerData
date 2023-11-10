//
//  MSEdgeControlButtonItemInternal.h
//  Pods
//
//  Created by admin on 2022/7/14.
//

#import "MSEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlButtonItem (MSInternal)
@property (nonatomic, getter=isInnerHidden) BOOL innerHidden; // 是否被sdk内部设置隐藏了;
@end
NS_ASSUME_NONNULL_END
