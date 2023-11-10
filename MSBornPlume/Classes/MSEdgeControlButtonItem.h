//
//  MSEdgeControlButtonItem.h
//  MSPlume
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSGestureControllerDefines.h"
typedef NSInteger MSEdgeControlButtonItemTag;
@class MSBornPlume, MSEdgeControlButtonItemAction;

typedef struct MSEdgeInsets {
    // 前后间距
    CGFloat front, rear;
} MSEdgeInsets;

UIKIT_STATIC_INLINE MSEdgeInsets MSEdgeInsetsMake(CGFloat front, CGFloat rear) {
    return (MSEdgeInsets){front, rear};
}

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSNotificationName const MSEdgeControlButtonItemPerformedActionNotification;

@interface MSEdgeControlButtonItem : NSObject
/// 49 * 49
- (instancetype)initWithImage:(nullable id)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(MSEdgeControlButtonItemTag)tag;

/// 49 * title.size.width
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(MSEdgeControlButtonItemTag)tag;

/// 49 * customView.size.width
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(MSEdgeControlButtonItemTag)tag;

- (instancetype)initWithTag:(MSEdgeControlButtonItemTag)tag;

@property (nonatomic) MSEdgeInsets insets; // 左右间隔, 默认{0, 0}
@property (nonatomic) MSEdgeControlButtonItemTag tag;
@property (nonatomic, strong, nullable) __kindof UIView *customView;
@property (nonatomic, strong, nullable) NSAttributedString *title;
@property (nonatomic) NSInteger numberOfLines; // default is 1.0
@property (nonatomic, strong, nullable) id image;
@property (nonatomic, getter=isHidden) BOOL hidden;
// default is false if invalid == true action can not be perform
@property (nonatomic, assign) BOOL invalid;
@property (nonatomic) CGFloat alpha;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@property (nonatomic) BOOL fill; // 当想要填充剩余空间时, 可以设置为`Yes`.

@property (nonatomic, readonly, nullable) NSArray<MSEdgeControlButtonItemAction *> *actions;
- (void)addAction:(MSEdgeControlButtonItemAction *)action;
- (void)removeAction:(MSEdgeControlButtonItemAction *)action;
- (void)removeAllActions;
- (void)performActions;
@end
typedef NS_ENUM(NSUInteger, MSButtonItemPlaceholderType) { 
    MSButtonItemPlaceholderType_Unknown,
    MSButtonItemPlaceholderType_49x49,              // 49 * 49
    MSButtonItemPlaceholderType_49xAutoresizing,    // 49 * 自适应大小
    MSButtonItemPlaceholderType_49xFill,            // 49 * 填充父视图剩余空间
    MSButtonItemPlaceholderType_49xSpecifiedSize,   // 49 * 指定尺寸(水平布局时, 49为高度, `指定尺寸`为宽度. 相反的, 垂直布局时, 49为宽度, `指定尺寸`为高度)
} ;
/// 占位Item
/// 先占好位置, 后更新属性
@interface MSEdgeControlButtonItem(Placeholder)
+ (instancetype)placeholderWithType:(MSButtonItemPlaceholderType)placeholderType tag:(MSEdgeControlButtonItemTag)tag;
+ (instancetype)placeholderWithSize:(CGFloat)size tag:(MSEdgeControlButtonItemTag)tag; // `placeholderType == MSButtonItemPlaceholderType_49xSpecifiedSize`
@property (nonatomic, readonly) MSButtonItemPlaceholderType placeholderType;
@property (nonatomic) CGFloat size;
@end



/// - 此分类只配合帧布局使用(MSAdapterItemsLayoutTypeFrameLayout), 其他布局无效
/// - 请设置`customView`的`bounds`
@interface MSEdgeControlButtonItem (FrameLayout)
+ (instancetype)frameLayoutWithCustomView:(__kindof UIView *)customView tag:(MSEdgeControlButtonItemTag)tag;
@property (nonatomic, readonly) BOOL isFrameLayout;
@end


@interface MSEdgeControlButtonItem (MSDeprecated)
- (void)addTarget:(id)target action:(nonnull SEL)action __deprecated_msg("use `addAction:`;");
- (void)performAction __deprecated_msg("use `performActions`;");
@end

#pragma mark - action

@interface MSEdgeControlButtonItemAction : NSObject
+ (instancetype)actionWithTarget:(id)target action:(SEL)action;
- (instancetype)initWithTarget:(id)target action:(SEL)action;

+ (instancetype)actionWithHandler:(void(^)(MSEdgeControlButtonItemAction *action))handler;
- (instancetype)initWithHandler:(void(^)(MSEdgeControlButtonItemAction *action))handler;

@property (nonatomic, weak, readonly, nullable) id target;
@property (nonatomic, readonly, nullable) SEL action;
@property (nonatomic, copy, readonly, nullable) void(^handler)(MSEdgeControlButtonItemAction *action);
@end
NS_ASSUME_NONNULL_END
