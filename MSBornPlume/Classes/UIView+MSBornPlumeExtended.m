//
//  UIView+MSBornPlumeExtended.m
//  MSBornPlume
//
//  Created by admin on 2019/11/22.
//

#import "UIView+MSBornPlumeExtended.h"

NS_ASSUME_NONNULL_BEGIN
@implementation UIView (MSBornPlumeExtended)
///
/// 子视图是否显示中
///
- (BOOL)isViewAppeared:(UIView *_Nullable)childView insets:(UIEdgeInsets)insets {
    if ( !childView ) return NO;
    return !CGRectIsEmpty([self intersectionWithView:childView insets:insets]);
}

///
/// 两者在window上的交叉点
///
- (CGRect)intersectionWithView:(UIView *)view insets:(UIEdgeInsets)insets {
    if ( view == nil || view.window == nil || self.window == nil ) return CGRectZero;
    CGRect rect1 = [view convertRect:view.bounds toView:self.window];
    CGRect rect2 = [self convertRect:self.bounds toView:self.window];
    rect2 = UIEdgeInsetsInsetRect(rect2, insets);

    CGRect intersection = CGRectIntersection(rect1, rect2);
    return (CGRectIsEmpty(intersection) || CGRectIsNull(intersection)) ? CGRectZero : intersection;
}

///
/// 寻找响应者
///
- (__kindof UIResponder *_Nullable)lookupResponderForClass:(Class)cls {
    __kindof UIResponder *_Nullable next = self.nextResponder;
    while ( next != nil && [next isKindOfClass:cls] == NO ) {
        next = next.nextResponder;
    }
    return next;
}

///
/// 寻找实现了该协议的视图, 包括自己
///
- (__kindof UIView *_Nullable)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag {
    if ( [self conformsToProtocol:protocol] && self.tag == tag ) {
        return self;
    }
    
    for ( UIView *subview in self.subviews ) {
        UIView *target = [subview viewWithProtocol:protocol tag:tag];
        if ( target != nil ) return target;
    }
    return nil;
}


///
/// 对应视图是否在window中显示
///
- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol tag:(NSInteger)tag insets:(UIEdgeInsets)insets {
   return [self isViewAppeared:[self viewWithProtocol:protocol tag:tag] insets:insets];
}

- (void)setMs_x:(CGFloat)ms_x {
    CGRect frame = self.frame;
    frame.origin.x = ms_x;
    self.frame = frame;
}

- (CGFloat)ms_x {
    return self.frame.origin.x;
}

- (void)setMs_y:(CGFloat)ms_y {
    CGRect frame = self.frame;
    frame.origin.y = ms_y;
    self.frame = frame;
}

- (CGFloat)ms_y {
    return self.frame.origin.y;
}

- (void)setMs_w:(CGFloat)ms_w {
    CGRect frame = self.frame;
    frame.size.width = ms_w;
    self.frame = frame;
}

- (CGFloat)ms_w {
    return self.frame.size.width;
}

- (void)setMs_h:(CGFloat)ms_h {
    CGRect frame = self.frame;
    frame.size.height = ms_h;
    self.frame = frame;
}

- (CGFloat)ms_h {
    return self.frame.size.height;
}

- (void)setMs_size:(CGSize)ms_size {
    CGRect frame = self.frame;
    frame.size = ms_size;
    self.frame = frame;
}

- (CGSize)ms_size {
    return self.frame.size;
}
@end

@implementation NSObject (MSBornPlumeExtended)
- (__kindof UIView *_Nullable)subviewForSelector:(SEL)selector {
    if ( [self respondsToSelector:selector] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return nil;
}
@end

NS_ASSUME_NONNULL_END
