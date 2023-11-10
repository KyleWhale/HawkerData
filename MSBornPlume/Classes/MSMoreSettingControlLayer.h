//
//  MSMoreSettingControlLayer.h
//  MSPlume_Example
//
//  Created by admin on 2019/7/19.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "MSEdgeControlLayerAdapters.h"
#import "MSControlLayerDefines.h"
@protocol MSMoreSettingControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN
extern MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Volume;
extern MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Brightness;
extern MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Rate;

@interface MSMoreSettingControlLayer : MSEdgeControlLayerAdapters<MSControlLayer>
@property (nonatomic, weak, nullable) id<MSMoreSettingControlLayerDelegate> delegate;
@end

@protocol MSMoreSettingControlLayerDelegate <NSObject>
- (void)tappedBlankAreaOnTheControlLayer:(id<MSControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
