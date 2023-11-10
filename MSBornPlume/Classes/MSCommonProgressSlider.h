//
//  MSCommonProgressSlider.h
//  MSProgressSlider
//
//  Created by admin on 2017/11/20.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSProgressSlider.h"

/*!
 *  two view each on the left and right.
 *  You can adjust the spacing by setting `spacing`.
 *
 *  两个视图, 分别在左边和右边.
 *  你可以设置`spacing`, 来调整他们之间的间距.
 **/
@interface MSCommonProgressSlider : UIView

// default is 4.
@property (nonatomic, assign, readwrite) float spacing;

@property (nonatomic, strong, readonly) UIView *leftContainerView;
@property (nonatomic, strong, readonly) MSProgressSlider *slider;
@property (nonatomic, strong, readonly) UIView *rightContainerView;

@end
