//
//  MSEdgeControlButtonItemAdapterLayout.h
//  Pods
//
//  Created by admin on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import "MSEdgeControlButtonItem.h"
@class MSEdgeControlButtonItemLayoutAttributes;

typedef NS_ENUM(NSUInteger, MSAdapterLayoutType) {
    ///
    /// 垂直布局
    ///
    MSAdapterLayoutTypeVerticalLayout,
    
    ///
    /// 水平布局
    ///
    MSAdapterLayoutTypeHorizontalLayout,
    
    ///
    /// 帧布局(一层一层往上盖, 并居中显示)
    ///
    MSAdapterLayoutTypeFrameLayout,
} ;

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlButtonItemAdapterLayout : NSObject
- (instancetype)initWithLayoutType:(MSAdapterLayoutType)type;

@property (nonatomic, readonly) CGSize intrinsicContentSize;
@property (nonatomic) MSAdapterLayoutType layoutType;
@property (nonatomic, copy, nullable) NSArray<MSEdgeControlButtonItem *> *items;
@property (nonatomic) CGSize preferredMaxLayoutSize;
@property (nonatomic) CGSize itemFillSizeForFrameLayout;

- (void)prepareLayout;
- (nullable NSArray<MSEdgeControlButtonItemLayoutAttributes *> *)layoutAttributesForItems;
- (nullable MSEdgeControlButtonItemLayoutAttributes *)layoutAttributesForItemAtIndex:(NSInteger)index;
@end

@interface MSEdgeControlButtonItemLayoutAttributes : NSObject
+ (instancetype)layoutAttributesForItemWithIndex:(NSInteger)index;
@property (nonatomic) NSInteger index;
@property (nonatomic) CGRect frame;
@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint center;
@end
NS_ASSUME_NONNULL_END
