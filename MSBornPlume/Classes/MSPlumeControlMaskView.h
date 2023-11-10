//
//  MSPlumeControlMaskView.h
//  MSPlumeProject
//
//  Created by admin on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 style

 - MSMaskStyle_bottom:  从上到下的颜色 浅->深
 - MSMaskStyle_top:     从上到下的颜色 深->浅
 */
typedef NS_ENUM(NSUInteger, MSMaskStyle) {
    MSMaskStyle_bottom,
    MSMaskStyle_top,
};

@interface MSPlumeControlMaskView : UIView

- (instancetype)initWithStyle:(MSMaskStyle)style;

- (void)cleanColors;
@end

NS_ASSUME_NONNULL_END
