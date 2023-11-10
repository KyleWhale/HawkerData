//
//  MSTimerControl.h
//  MSPlumeProject
//
//  Created by admin on 2017/12/6.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MSTimerControl : NSObject

/// default is 3;
@property (nonatomic) NSTimeInterval interval;

@property (nonatomic, copy, nullable) void(^exeBlock)(MSTimerControl *control);

- (void)resume;

- (void)interrupt;

@end
NS_ASSUME_NONNULL_END
