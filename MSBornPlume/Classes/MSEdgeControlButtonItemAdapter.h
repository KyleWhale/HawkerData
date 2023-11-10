//
//  MSEdgeControlButtonItemAdapter.h
//  Pods
//
//  Created by admin on 2019/12/9.
//

#import <UIKit/UIKit.h>
#import "MSEdgeControlButtonItemAdapterLayout.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlButtonItemAdapter : UIView
- (instancetype)initWithFrame:(CGRect)frame layoutType:(MSAdapterLayoutType)type;

///
/// 刷新
///
- (void)reload;
- (void)updateContentForItemWithTag:(MSEdgeControlButtonItemTag)tag;

///
/// 布局方式
///
/// - 注意: 修改后, 记得调用刷新
///
@property (nonatomic) MSAdapterLayoutType layoutType;

@property (nonatomic) CGSize itemFillSizeForFrameLayout;

///
/// 获取
///
- (nullable MSEdgeControlButtonItem *)itemAtIndex:(NSInteger)index;
- (nullable MSEdgeControlButtonItem *)itemForTag:(MSEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItemForTag:(MSEdgeControlButtonItemTag)tag;
- (NSInteger)indexOfItem:(MSEdgeControlButtonItem *)item;
- (nullable NSArray<MSEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range;
- (BOOL)isHiddenWithRange:(NSRange)range; // 此范围的items是否已隐藏
- (BOOL)itemContainsPoint:(CGPoint)point; // 某个点是否在item中
- (nullable MSEdgeControlButtonItem *)itemAtPoint:(CGPoint)point;
- (BOOL)containsItem:(MSEdgeControlButtonItem *)item;

///
/// 添加
///
/// - 注意: 添加后, 记得调用刷新
///
- (void)addItem:(MSEdgeControlButtonItem *)item;
- (void)addItemsFromArray:(NSArray<MSEdgeControlButtonItem *> *)items;
- (void)insertItem:(MSEdgeControlButtonItem *)item atIndex:(NSInteger)index;
- (void)insertItem:(MSEdgeControlButtonItem *)item frontItem:(MSEdgeControlButtonItemTag)tag;
- (void)insertItem:(MSEdgeControlButtonItem *)item rearItem:(MSEdgeControlButtonItemTag)tag;

///
/// 删除
///
/// - 注意: 删除后, 记得调用刷新
///
- (void)removeItemAtIndex:(NSInteger)index;
- (void)removeItemForTag:(MSEdgeControlButtonItemTag)tag;
- (void)removeAllItems;

///
/// 交换位置
///
/// - 注意: 交换后, 记得调用刷新
///
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2;
- (void)exchangeItemForTag:(MSEdgeControlButtonItemTag)tag1 withItemForTag:(MSEdgeControlButtonItemTag)tag2;

///
/// 获取当前 item 对应视图
///
- (nullable UIView *)viewForItemAtIndex:(NSInteger)idx;
- (nullable UIView *)viewForItemForTag:(MSEdgeControlButtonItemTag)tag;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;

///
/// item的数量
///
@property (nonatomic, readonly) NSInteger numberOfItems;


//
// 以下为兼容老的adapter
//
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *view;
@property (nonatomic, readonly) NSInteger itemCount;
@end


typedef MSEdgeControlButtonItemAdapter MSEdgeControlLayerItemAdapter;
NS_ASSUME_NONNULL_END
