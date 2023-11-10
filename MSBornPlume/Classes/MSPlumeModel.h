//
//  MSPlumeModel.h
//  MSPlumeAssetCarrier
//
//  Created by admin on 2018/6/28.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MSPlumeModelPlayerSuperview, MSPlumeModelNestedView;

NS_ASSUME_NONNULL_BEGIN
@interface MSPlumeModel: NSObject

//@property (nonatomic, nullable) SEL superviewSelector;
//@property (nonatomic, strong, nullable) __kindof MSPlumeModel *nextPlumeModel;
//@property (nonatomic, nullable) SEL scrollViewSelector;
//@property (nonatomic) UIEdgeInsets playableAreaInsets;

- (instancetype)init;

@end
NS_ASSUME_NONNULL_END
