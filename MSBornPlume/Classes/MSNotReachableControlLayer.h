//
//  MSNotReachableControlLayer.h
//  MSPlume
//
//  Created by admin on 2019/1/15.
//  Copyright © 2019 admin. All rights reserved.
//

#import "MSEdgeControlLayerAdapters.h"
#import "MSControlLayerDefines.h"

#pragma mark - 无网状态下显示的控制层

@protocol MSNotReachableControlLayerDelegate;
@class MSButtonContainerView;

NS_ASSUME_NONNULL_BEGIN
extern MSEdgeControlButtonItemTag const MSNotReachableControlLayerTopItem_Back;


@interface MSNotReachableControlLayer : MSEdgeControlLayerAdapters<MSControlLayer>
@property (nonatomic, weak, nullable) id<MSNotReachableControlLayerDelegate> delegate;
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) MSButtonContainerView *reloadView;
@property (nonatomic) BOOL hiddenBackButtonWhenOrientationIsPortrait;
@end


@interface MSButtonContainerView : UIView
- (instancetype)initWithEdgeInsets:(UIEdgeInsets)insets;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, getter=isRoundedRect) BOOL roundedRect;
@property (nonatomic, strong, readonly) UIButton *button;
@end


@protocol MSNotReachableControlLayerDelegate <NSObject>
- (void)backItemWasTappedForControlLayer:(id<MSControlLayer>)controlLayer;
- (void)reloadItemWasTappedForControlLayer:(id<MSControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
