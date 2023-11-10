//
//  MSEdgeControlButtonItem.m
//  MSPlume
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018 admin. All rights reserved.
//

#import "MSEdgeControlButtonItem.h"
#import "MSEdgeControlButtonItemInternal.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const MSEdgeControlButtonItemPerformedActionNotification = @"MSEdgeControlButtonItemPerformedActionNotification";

@implementation MSEdgeControlButtonItem {
    MSButtonItemPlaceholderType _placeholderType;
    CGFloat _size;
    BOOL _isFrameLayout;
    NSMutableArray<MSEdgeControlButtonItemAction *> *_Nullable _actions;
    BOOL _innerHidden;
}
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(MSEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _title = title;
    if ( target != nil && action != NULL ) {
        [self addAction:[MSEdgeControlButtonItemAction actionWithTarget:target action:action]];
    }
    return self;
}
- (instancetype)initWithImage:(nullable id)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(MSEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _image = image;
    if ( target != nil && action != NULL ) {
        [self addAction:[MSEdgeControlButtonItemAction actionWithTarget:target action:action]];
    }
    return self;
}
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(MSEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _customView = customView;
    return self;
}
- (instancetype)initWithTag:(NSInteger)tag {
    self = [super init];
    if ( !self ) return nil;
    _tag = tag;
    _numberOfLines = 1;
    _alpha = 1;
    return self;
}

- (nullable NSArray<MSEdgeControlButtonItemAction *> *)actions {
    return _actions.count != 0 ? _actions : nil;
}

- (void)addAction:(MSEdgeControlButtonItemAction *)action {
    if ( action != nil ) {
        if ( _actions == nil ) {
            _actions = NSMutableArray.array;
        }
        [_actions addObject:action];
    }
}

- (void)removeAction:(MSEdgeControlButtonItemAction *)action {
    if ( action != nil )
        [_actions removeObject:action];
}

- (void)removeAllActions {
    [_actions removeAllObjects];
}

- (void)performActions {
    
    if (self.invalid) {
        return;
    }
    for ( MSEdgeControlButtonItemAction *action in _actions ) {
        if ( action.handler != nil ) {
            action.handler(action);
        }
        else if ( [action.target respondsToSelector:action.action] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [action.target performSelector:action.action withObject:self];
#pragma clang diagnostic pop
        }
    }
    [NSNotificationCenter.defaultCenter postNotificationName:MSEdgeControlButtonItemPerformedActionNotification object:self];
}

- (void)setInnerHidden:(BOOL)innerHidden {
    _innerHidden = innerHidden;
}
- (BOOL)isInnerHidden {
    return _innerHidden;
}

- (BOOL)isHidden {
    return _hidden || _innerHidden;
}
@end


@implementation MSEdgeControlButtonItem(Placeholder)
+ (instancetype)placeholderWithType:(MSButtonItemPlaceholderType)placeholderType tag:(MSEdgeControlButtonItemTag)tag {
    MSEdgeControlButtonItem *item = [[MSEdgeControlButtonItem alloc] initWithTag:tag];
    item->_placeholderType = placeholderType;
    if ( placeholderType == MSButtonItemPlaceholderType_49xFill ) item.fill = YES;
    return item;
}
+ (instancetype)placeholderWithSize:(CGFloat)size tag:(MSEdgeControlButtonItemTag)tag {
    MSEdgeControlButtonItem *item = [[MSEdgeControlButtonItem alloc] initWithTag:tag];
    item->_placeholderType = MSButtonItemPlaceholderType_49xSpecifiedSize;
    item.size = size;
    return item;
}
- (MSButtonItemPlaceholderType)placeholderType {
    return _placeholderType;
}
- (void)setSize:(CGFloat)size {
    _size = size;
}
- (CGFloat)size {
    return _size;
}
@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation MSEdgeControlButtonItem(MSDeprecated)
- (void)addTarget:(id)target action:(nonnull SEL)action {
    [self removeAllActions];
    [self addAction:[MSEdgeControlButtonItemAction actionWithTarget:target action:action]];
}

- (void)performAction {
    [self performActions];
}
@end
#pragma clang diagnostic pop

@implementation MSEdgeControlButtonItem(FrameLayout)
+ (instancetype)frameLayoutWithCustomView:(__kindof UIView *)customView tag:(MSEdgeControlButtonItemTag)tag {
    MSEdgeControlButtonItem *item = [[MSEdgeControlButtonItem alloc] initWithCustomView:customView tag:tag];
    item->_isFrameLayout = YES;
    return item;
}
- (BOOL)isFrameLayout {
    return _isFrameLayout;
}
@end

@implementation MSEdgeControlButtonItemAction
+ (instancetype)actionWithTarget:(id)target action:(SEL)action {
    return [[self alloc] initWithTarget:target action:action];
}

+ (instancetype)actionWithHandler:(void(^)(MSEdgeControlButtonItemAction *action))handler {
    return [[self alloc] initWithHandler:handler];
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if ( self ) {
        _target = target;
        _action = action;
    }
    return self;
}
- (instancetype)initWithHandler:(void(^)(MSEdgeControlButtonItemAction *action))handler {
    self = [super init];
    if ( self ) {
        _handler = handler;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
