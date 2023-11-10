//
//  MSPlumePresentView.h
//  MSPlumeProject
//
//  Created by admin on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPlumePresentViewDefines.h"
#import "MSGestureControllerDefines.h"
@protocol MSPlumePresentViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumePresentView : UIView<MSPlumePresentView, MSGestureController>
@property (nonatomic, weak, nullable) id<MSPlumePresentViewDelegate> delegate;
@end

@protocol MSPlumePresentViewDelegate <NSObject>
@optional
- (void)presentViewDidLayoutSubviews:(MSPlumePresentView *)presentView;
- (void)presentViewDidMoveToWindow:(MSPlumePresentView *)presentView;
@end
NS_ASSUME_NONNULL_END
