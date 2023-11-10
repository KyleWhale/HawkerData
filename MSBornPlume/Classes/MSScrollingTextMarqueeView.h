//
//  MSScrollingTextMarqueeView.h
//  MSPlume_Example
//
//  Created by admin on 2019/12/7.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSScrollingTextMarqueeViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSScrollingTextMarqueeView : UIView<MSScrollingTextMarqueeView>
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@property (nonatomic) CGFloat margin;

@property (nonatomic, readonly, getter=isScrolling) BOOL scrolling;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, getter=isCentered) BOOL centered;
@end
NS_ASSUME_NONNULL_END
