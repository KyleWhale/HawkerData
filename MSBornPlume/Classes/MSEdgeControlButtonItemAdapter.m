//
//  MSEdgeControlButtonItemAdapter.m
//  Pods
//
//  Created by admin on 2019/12/9.
//

#import "MSEdgeControlButtonItemAdapter.h"
#import "MSEdgeControlButtonItemAdapterLayout.h"
#import "MSEdgeControlButtonItemView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlButtonItemAdapter ()
@property (nonatomic, strong, readonly) NSMutableArray<MSEdgeControlButtonItemView *> *views;
@property (nonatomic, strong, readonly) NSMutableArray<MSEdgeControlButtonItem *> *items;
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapterLayout *layout;
@end

@implementation MSEdgeControlButtonItemAdapter
- (instancetype)initWithFrame:(CGRect)frame layoutType:(MSAdapterLayoutType)type {
    self = [super init];
    if ( self ) {
        _views = NSMutableArray.array;
        _items = NSMutableArray.array;
        _layoutType = type;
        _layout = [MSEdgeControlButtonItemAdapterLayout.alloc initWithLayoutType:type];
    }
    return self;
}

///
/// 刷新
///
- (void)reload {
    [self _reload];
}

- (void)updateContentForItemWithTag:(MSEdgeControlButtonItemTag)tag {
    __auto_type _Nullable item = [self itemForTag:tag];
    if ( item != nil ) {
        for ( MSEdgeControlButtonItemView *view in _views ) {
            if ( view.item == item ) {
                [view reloadItemIfNeeded];
                break;
            }
        }
    }
}

///
/// 获取
///
- (nullable MSEdgeControlButtonItem *)itemAtIndex:(NSInteger)index {
    if ( index < _items.count && index >= 0 ) {
        return [_items objectAtIndex:index];
    }
    return nil;
}

- (nullable MSEdgeControlButtonItem *)itemForTag:(MSEdgeControlButtonItemTag)tag {
    NSInteger index = [self indexOfItemForTag:tag];
    return index != NSNotFound ? _items[index] : nil;
}

- (NSInteger)indexOfItemForTag:(MSEdgeControlButtonItemTag)tag {
    NSInteger index = NSNotFound;
    for ( NSInteger idx = 0 ; idx < _items.count ; ++ idx ) {
        if ( _items[idx].tag == tag ) {
            index = idx;
            break;
        }
    }
    return index;
}

- (NSInteger)indexOfItem:(MSEdgeControlButtonItem *)item {
    return [_items indexOfObject:item];
}

- (nullable NSArray<MSEdgeControlButtonItem *> *)itemsWithRange:(NSRange)range {
    return NSMaxRange(range) <= _items.count  ? [_items subarrayWithRange:range] : nil;
}

- (BOOL)isHiddenWithRange:(NSRange)range {
    for ( MSEdgeControlButtonItem *item in [self itemsWithRange:range] ) {
        if ( item.isHidden == NO )
            return NO;
    }
    return YES;
}

- (BOOL)itemContainsPoint:(CGPoint)point {
    return [self itemAtPoint:point] != nil;
}

- (nullable MSEdgeControlButtonItem *)itemAtPoint:(CGPoint)point {
    for ( MSEdgeControlButtonItemLayoutAttributes *attr in [_layout layoutAttributesForItems] ) {
        if ( CGRectContainsPoint(attr.frame, point) ) {
            MSEdgeControlButtonItem *_Nullable item = [self itemAtIndex:attr.index];
            if ( item.isHidden == NO && item.alpha > 0.01 )
                return item;
        }
    }
    return nil;
}

- (BOOL)containsItem:(MSEdgeControlButtonItem *)item {
    return item != nil ? [_items containsObject:item] : NO;
}

///
/// 添加
///
/// - 注意: 添加后, 记得调用刷新
///
- (void)addItem:(MSEdgeControlButtonItem *)item {
    if ( item != nil ) [_items addObject:item];
}

- (void)addItemsFromArray:(NSArray<MSEdgeControlButtonItem *> *)items {
    if ( items != nil ) [_items addObjectsFromArray:items];
}

- (void)insertItem:(MSEdgeControlButtonItem *)item atIndex:(NSInteger)index {
    if ( item != nil ) {
        if ( index >= _items.count ) index = _items.count;
        else if ( index < 0 ) index = 0;
        [_items insertObject:item atIndex:index];
    }
}

- (void)insertItem:(MSEdgeControlButtonItem *)item frontItem:(MSEdgeControlButtonItemTag)tag {
    [self insertItem:item atIndex:[self indexOfItemForTag:tag] + 1];
}

- (void)insertItem:(MSEdgeControlButtonItem *)item rearItem:(MSEdgeControlButtonItemTag)tag {
    [self insertItem:item atIndex:[self indexOfItemForTag:tag]];
}

///
/// 删除
///
/// - 注意: 删除后, 记得调用刷新
///
- (void)removeItemAtIndex:(NSInteger)index {
    if ( index < 0 ) return;
    if ( index >= _items.count ) return;
    [_items removeObjectAtIndex:index];
}

- (void)removeItemForTag:(MSEdgeControlButtonItemTag)tag {
    [self removeItemAtIndex:[self indexOfItemForTag:tag]];
}

- (void)removeAllItems {
    [_items removeAllObjects];
}

///
/// 交换位置
///
/// - 注意: 交换后, 记得调用刷新
///
- (void)exchangeItemAtIndex:(NSInteger)idx1 withItemAtIndex:(NSInteger)idx2 {
    if ( idx1 == idx2 ) return;
    if ( idx1 < 0 || idx1 >= _items.count ) return;
    if ( idx2 < 0 || idx2 >= _items.count ) return;
    [_items exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)exchangeItemForTag:(MSEdgeControlButtonItemTag)tag1 withItemForTag:(MSEdgeControlButtonItemTag)tag2 {
    [self exchangeItemAtIndex:[self indexOfItemForTag:tag1] withItemAtIndex:[self indexOfItemForTag:tag2]];
}

- (nullable UIView *)viewForItemAtIndex:(NSInteger)idx {
    if ( idx != NSNotFound ) {
        return _views[idx];
    }
    return nil;
}

- (nullable UIView *)viewForItemForTag:(MSEdgeControlButtonItemTag)tag {
    return [self viewForItemAtIndex:[self indexOfItemForTag:tag]];
}

#pragma mark -

- (void)_reload {
    NSArray<MSEdgeControlButtonItem *> *items = _items.copy;
    _layout.layoutType = _layoutType;
    _layout.items = items;
    _layout.itemFillSizeForFrameLayout = _itemFillSizeForFrameLayout;
    _layout.preferredMaxLayoutSize = self.bounds.size;
    [_layout prepareLayout];
    
    //
    // 移除多余的视图
    //
    if ( items.count < _views.count ) {
        NSRange range = NSMakeRange(items.count, _views.count - items.count);
        NSArray<UIView *> *uselessViews = [_views subarrayWithRange:range];
        [uselessViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( obj.superview == self ) [obj removeFromSuperview];
        }];
        [_views removeObjectsInRange:range];
    }
    //
    // 补充新增的视图
    //
    else if ( items.count > _views.count ) {
        for ( NSInteger i = _views.count ; i < items.count ; ++ i ) {
            MSEdgeControlButtonItemView *view = [MSEdgeControlButtonItemView.alloc initWithFrame:CGRectZero];
            [_views addObject:view];
            [self addSubview:view];
        }
    }

    //
    // 刷新视图
    //
    for ( MSEdgeControlButtonItemLayoutAttributes *attr in [_layout layoutAttributesForItems] ) {
        MSEdgeControlButtonItemView *view = [_views objectAtIndex:attr.index];
        view.item = [items objectAtIndex:attr.index];
        view.frame = attr.frame;
        [view reloadItemIfNeeded];
    }
    
    //
    // 填充size
    //
    if ( _layoutType == MSAdapterLayoutTypeFrameLayout ) {
        if ( self.superview != nil && !CGSizeEqualToSize(self.layout.intrinsicContentSize, self.bounds.size) ) {
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_offset(self.layout.intrinsicContentSize).priority(MASLayoutPriorityRequired);
            }];
        }
    }
}

- (NSInteger)numberOfItems {
    return _items.count;
}

#pragma mark -

- (void)setItemFillSizeForFrameLayout:(CGSize)itemFillSizeForFrameLayout {
    _itemFillSizeForFrameLayout = itemFillSizeForFrameLayout;
    if ( _layoutType == MSAdapterLayoutTypeFrameLayout ) {
        [self reload];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _layoutType != MSAdapterLayoutTypeFrameLayout ) {
        if ( !CGSizeEqualToSize(_layout.preferredMaxLayoutSize, self.bounds.size) ) {
            [self reload];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    MSEdgeControlButtonItem *_Nullable item = [self itemAtPoint:point];
    if ( item != nil ) {
        NSInteger index = [self indexOfItem:item];
        MSEdgeControlButtonItemView *view = _views[index];
        if ( index != NSNotFound ) return [view pointInside:[self convertPoint:point toView:view] withEvent:event];
    }
    return [super pointInside:point withEvent:event];
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    MSEdgeControlButtonItem *_Nullable item = [self itemAtPoint:point];
    if ( item != nil ) {
        NSInteger index = [self indexOfItem:item];
        MSEdgeControlButtonItemView *view = _views[index];
        if ( index != NSNotFound ) return [view hitTest:[self convertPoint:point toView:view] withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}


#pragma mark -

- (MSEdgeControlButtonItemAdapter *)view {
    return self;
}

- (NSInteger)itemCount {
    return self.numberOfItems;
}
@end
NS_ASSUME_NONNULL_END
