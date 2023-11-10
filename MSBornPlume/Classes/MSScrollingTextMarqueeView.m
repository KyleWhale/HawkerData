//
//  MSScrollingTextMarqueeView.m
//  MSPlume_Example
//
//  Created by admin on 2019/12/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "MSScrollingTextMarqueeView.h"
#if __has_include(<MSUIKit/NSAttributedString+MSMake.h>)
#import <MSUIKit/NSAttributedString+MSMake.h>
#else
#import "NSAttributedString+MSMake.h"
#endif
#if __has_include(<MSBornPlume/CALayer+MSBornPlumeExtended.h>)
#import <MSBornPlume/CALayer+MSBornPlumeExtended.h>
#import <MSBornPlume/UIView+MSBornPlumeExtended.h>
#else
#import "CALayer+MSBornPlumeExtended.h"
#import "UIView+MSBornPlumeExtended.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@interface MSScrollingTextMarqueeView () {
    CGRect _previousBounds;
}
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UILabel *leftLabel;
@property (nonatomic, strong, readonly) UILabel *rightLabel;
@property (nonatomic, strong, readonly) CAGradientLayer *fadeMaskLayer;
@property (nonatomic, getter=isScrolling) BOOL scrolling;
@end

@implementation MSScrollingTextMarqueeView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        [self _init];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    _margin = 28;
    _scrollEnabled = YES;
    self.clipsToBounds = YES;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reset) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self _setupViews];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    if ( ![self.attributedText isEqual:attributedText] ) {
        _leftLabel.attributedText = attributedText;
        _leftLabel.ms_w = self.isScrollEnabled ? attributedText.ms_textSize.width : self.ms_w;
        _leftLabel.ms_h = self.ms_h;
        if ( self.isScrollEnabled ) [self _reset];
    }
}

- (nullable NSAttributedString *)attributedText {
    return _leftLabel.attributedText;
}

- (void)setMargin:(CGFloat)margin {
    if ( margin != _margin ) {
        _margin = margin;
        if ( self.isScrollEnabled ) [self _reset];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    if ( scrollEnabled != _scrollEnabled ) {
        _scrollEnabled = scrollEnabled;
        [self _reset];
    }
}

#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    if ( !CGRectEqualToRect(_previousBounds, bounds) ) {
        _previousBounds = bounds;
        _fadeMaskLayer.frame = bounds;
        _leftLabel.ms_h = self.ms_h;
        _rightLabel.ms_h = self.ms_h;
        _contentView.ms_h = self.ms_h;
        if ( !_scrollEnabled ) _leftLabel.ms_w = bounds.size.width;
        [self _reset];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self _reset];
}

#pragma mark -

- (void)_setupViews {
    self.userInteractionEnabled = NO;
    
    _contentView = [UIView.alloc initWithFrame:CGRectZero];
    [self addSubview:_contentView];
    
    _leftLabel = [UILabel.alloc initWithFrame:CGRectZero];
    [_contentView addSubview:_leftLabel];
    
    _rightLabel = [UILabel.alloc initWithFrame:CGRectZero];
    [_contentView addSubview:_rightLabel];
    
    _fadeMaskLayer = CAGradientLayer.layer;
    _fadeMaskLayer.startPoint = CGPointMake(0, 0.5);
    _fadeMaskLayer.endPoint = CGPointMake(1, 0.5);
    [self _setFadeMasks];
    self.layer.mask = _fadeMaskLayer;
}

- (BOOL)_shouldScroll {
    return _scrollEnabled && _leftLabel.attributedText != nil && _leftLabel.ms_w > self.ms_w && self.ms_h != 0;
}

- (void)_reset {
    [_contentView.layer removeAllAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if ( [self _shouldScroll] ) {
        [self _prepareForAnimation];
        if ( self.window != nil ) {
            [self _startAnimationIfNeededAfterDelay:2];
        }
    }
    else {
        [self _prepareForNormalState];
    }
}

- (void)_prepareForAnimation {
    [self _setRightFadeMask];
    
    if ( _centered ) {
        _leftLabel.ms_x = 0;
    }
    
    _rightLabel.hidden = NO;
    _rightLabel.attributedText = _leftLabel.attributedText;
    _rightLabel.ms_x = _leftLabel.ms_w + _margin;
    _rightLabel.ms_w = _leftLabel.ms_w;
    
    _contentView.ms_w = CGRectGetMaxX(_rightLabel.frame);
}

- (void)_prepareForNormalState {
    [self _removeFadeMasks];
    
    _rightLabel.hidden = YES;
    
    if ( _centered ) {
        _leftLabel.ms_x = self.ms_w * 0.5 - _leftLabel.ms_w * 0.5;
    }
}

- (void)_startAnimationIfNeededAfterDelay:(NSTimeInterval)seconds {
    if ( ![self _shouldScroll] ) return;
    
    // - 静止2秒
    // - 2秒后开始滚动, 如此循环
    [self performSelector:@selector(_startAnimation) withObject:self afterDelay:seconds inModes:@[NSRunLoopCommonModes]];
}

- (void)_startAnimation {
    CGFloat pointDuration = 0.02;
    CGFloat points = _leftLabel.ms_w + _margin;
    CABasicAnimation *step1 = [CABasicAnimation animationWithKeyPath:@"transform"];
    step1.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    step1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-points, 0, 0)];
    step1.duration = points * pointDuration;
    step1.repeatCount = 1;
    [self _setFadeMasks];
    __weak typeof(self) _self = self;
    _scrolling = YES;
    [_contentView.layer addAnimation:step1 stopHandler:^(CAAnimation * _Nonnull anim, BOOL isFinished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self.scrolling = NO;
        [self _startAnimationIfNeededAfterDelay:2];
    }];
    
    NSTimeInterval step2 = _leftLabel.ms_w * pointDuration;
    [self performSelector:@selector(_setRightFadeMask) withObject:nil afterDelay:step2 inModes:@[NSRunLoopCommonModes]];
}

- (void)_setFadeMasks {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor
    ];
    _fadeMaskLayer.locations = @[@0, @0.1, @0.9, @1];
    [CATransaction commit];
}

- (void)_setRightFadeMask {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:0.05].CGColor
    ];
    _fadeMaskLayer.locations = @[@0.9, @1];
    [CATransaction commit];
}

- (void)_removeFadeMasks {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _fadeMaskLayer.colors = @[
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor
    ];
    _fadeMaskLayer.locations = @[@0, @1];
    [CATransaction commit];
}
@end
NS_ASSUME_NONNULL_END
