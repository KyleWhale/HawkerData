//
//  MSNotReachableControlLayer.m
//  MSPlume
//
//  Created by admin on 2019/1/15.
//  Copyright © 2019 admin. All rights reserved.
//

#import "MSNotReachableControlLayer.h"
#import "UIView+MSAnimationAdded.h"
#import "MSPlumeConfigurations.h"

#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#else
#import "MSBornPlume.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#import "MSEdgeControlButtonItemInternal.h"

NS_ASSUME_NONNULL_BEGIN
MSEdgeControlButtonItemTag const MSNotReachableControlLayerTopItem_Back = 10000;

@interface MSButtonContainerView ()

@end

@implementation MSButtonContainerView
- (instancetype)initWithEdgeInsets:(UIEdgeInsets)insets {
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _insets = insets;
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(insets);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( _roundedRect ) self.layer.cornerRadius = self.bounds.size.height * 0.5;
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).mas_offset(insets);
    }];
}
@end

@interface MSNotReachableControlLayer ()

@end

@implementation MSNotReachableControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)backItemWasTapped:(MSEdgeControlButtonItem *)item {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)reloadButtonWasTapped {
    if ( [self.delegate respondsToSelector:@selector(reloadItemWasTappedForControlLayer:)] ) {
        [self.delegate reloadItemWasTappedForControlLayer:self];
    }
}

#pragma mark -

- (void)restartControlLayer {
    _restarted = YES;
    ms_view_makeAppear(self.plume_controlView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    ms_view_makeDisappear(self.plume_controlView, YES, ^{
        if ( !self->_restarted ) [self.plume_controlView removeFromSuperview];
    });
}

- (UIView *)plume_controlView {
    return self;
}

- (void)installedControlViewToPlume:(__kindof MSBornPlume *)plume {
    [self _updateItems:plume];
}

- (BOOL)plume:(__kindof MSBornPlume *)plume gestureRecognizerShouldTrigger:(MSCharmGestureType)type location:(CGPoint)location {
    return NO;
}

- (void)controlLayerNeedAppear:(__kindof MSBornPlume *)plume {}
- (void)controlLayerNeedDisappear:(__kindof MSBornPlume *)plume {}

- (void)plume:(__kindof MSBornPlume *)plume onRotationTransitioningChanged:(BOOL)isTransitioning {
    if ( isTransitioning ) [self _updateItems:plume];
}

- (void)plume:(__kindof MSBornPlume *)plume willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateItems:plume];
}

- (void)_updateItems:(__kindof MSBornPlume *)plume {
    MSEdgeControlButtonItem *backItem = [_topAdapter itemForTag:MSNotReachableControlLayerTopItem_Back];
    BOOL isFitOnScreen = plume.isFitOnScreen;
    BOOL isFull = plume.iFurry;
    
    if ( backItem ) {
        if ( isFull || isFitOnScreen )
            backItem.innerHidden = NO;
        else {
            if ( _hiddenBackButtonWhenOrientationIsPortrait )
                backItem.innerHidden = YES;
        }
    }
    [_topAdapter reload];
}

#pragma mark -

- (void)_setupView {
    self.backgroundColor = [UIColor blackColor];
    
    id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
    id<MSPlumeLocalizedStrings> strings = MSPlumeConfigurations.shared.localizedStrings;
    
    MSEdgeControlButtonItem *backItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSNotReachableControlLayerTopItem_Back];
    [backItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(backItemWasTapped:)]];
    backItem.image = sources.backImage;
    [self.topAdapter addItem:backItem];
    [self.topAdapter reload];

    _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _promptLabel.text = strings.noNetworkPrompt;
    _promptLabel.font = [UIFont systemFontOfSize:14];
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.numberOfLines = 0;
    [self addSubview:_promptLabel];
    [_promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(20);
        make.right.mas_lessThanOrEqualTo(-20);
        make.centerX.offset(0);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    _reloadView = [[MSButtonContainerView alloc] initWithEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [_reloadView.button addTarget:self action:@selector(reloadButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    _reloadView.roundedRect = YES;
    [_reloadView.button setTitle:strings.reload forState:UIControlStateNormal];
    _reloadView.button.titleLabel.font = [UIFont systemFontOfSize:14];
    _reloadView.backgroundColor = [UIColor redColor];
    _reloadView.backgroundColor = sources.noNetworkButtonBackgroundColor;
    [self addSubview:_reloadView];
    [_reloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel.mas_bottom).offset(20);
        make.centerX.offset(0);
    }];
}

@end
NS_ASSUME_NONNULL_END
