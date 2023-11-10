//
//  MSEdgeControlButtonItemView.h
//  MSPlume
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSEdgeControlButtonItemView : UIControl
@property (nonatomic, strong, nullable) MSEdgeControlButtonItem *item;

- (void)reloadItemIfNeeded;
@end
NS_ASSUME_NONNULL_END
