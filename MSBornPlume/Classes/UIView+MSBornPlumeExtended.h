//
//  UIView+MSBornPlumeExtended.h
//  MSBornPlume
//
//  Created by admin on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (MSBornPlumeExtended)

- (BOOL)isViewAppeared:(UIView *_Nullable)childView insets:(UIEdgeInsets)insets;

- (CGRect)intersectionWithView:(UIView *)view insets:(UIEdgeInsets)insets;

- (__kindof UIResponder *_Nullable)lookupResponderForClass:(Class)cls;

- (__kindof UIView *_Nullable)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag;

- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol tag:(NSInteger)tag insets:(UIEdgeInsets)insets;

@property (nonatomic) CGFloat ms_x;
@property (nonatomic) CGFloat ms_y;
@property (nonatomic) CGFloat ms_w;
@property (nonatomic) CGFloat ms_h;
@property (nonatomic) CGSize ms_size;
@end

@interface NSObject (MSBornPlumeExtended)
- (__kindof UIView *_Nullable)subviewForSelector:(SEL)selector;
@end
NS_ASSUME_NONNULL_END
