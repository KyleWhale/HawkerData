//
//  MSEdgeControlLayerAdapters.h
//  MSPlume
//
//  Created by admin on 2018/10/20.
//  Copyright © 2018 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPlumeControlMaskView.h"
#import "MSEdgeControlButtonItemAdapter.h"

NS_ASSUME_NONNULL_BEGIN
struct MS_Screen {
    CGFloat max;
    CGFloat min;
    BOOL is_iPhoneXSeries;
};

@interface MSEdgeControlLayerAdapters : UIView {
    @protected
    MSEdgeControlButtonItemAdapter *_Nullable _topAdapter;
    MSEdgeControlButtonItemAdapter *_Nullable _leftAdapter;
    MSEdgeControlButtonItemAdapter *_Nullable _bottomAdapter;
    MSEdgeControlButtonItemAdapter *_Nullable _rightAdapter;
    MSEdgeControlButtonItemAdapter *_Nullable _centerAdapter;
    
    MSPlumeControlMaskView *_Nullable _topContainerView;
    MSPlumeControlMaskView *_Nullable _bottomContainerView;
    UIView *_Nullable _leftContainerView;
    UIView *_Nullable _rightContainerView;
    UIView *_Nullable _centerContainerView;
    
    struct MS_Screen _screen;
}

@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *topAdapter;    // lazy load
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *leftAdapter;   // lazy load
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *bottomAdapter; // lazy load
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *rightAdapter;  // lazy load
@property (nonatomic, strong, readonly) MSEdgeControlButtonItemAdapter *centerAdapter; // lazy load


@property (nonatomic, strong, readonly) MSPlumeControlMaskView *topContainerView;
@property (nonatomic, strong, readonly) MSPlumeControlMaskView *bottomContainerView;
@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) UIView *rightContainerView;
@property (nonatomic, strong, readonly) UIView *centerContainerView;


/// default is YES.
@property (nonatomic) BOOL autoAdjustTopSpacing; // 自动调整顶部间距, 让出状态栏

/// default is Yes.
@property (nonatomic) BOOL autoAdjustLayoutWhenDeviceIsIPhoneXSeries; // 自动调整布局, 如果是iPhone X

#ifdef DEBUG
@property (nonatomic) BOOL showBackgroundColor;
#endif

// - default is 49.
@property (nonatomic) CGFloat topHeight;
@property (nonatomic) CGFloat leftWidth;
@property (nonatomic) CGFloat bottomHeight;
@property (nonatomic) CGFloat rightWidth;

// - default is 4.
@property (nonatomic) CGFloat topMargin;
// - default is 0.
@property (nonatomic) CGFloat leftMargin;
@property (nonatomic) CGFloat bottomMargin;
@property (nonatomic) CGFloat rightMargin;
@end
NS_ASSUME_NONNULL_END
