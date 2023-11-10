//
//  MSExecuteCodeLayerView.h
//  Pods
//
//  Created by admin on 2020/2/19.
//

#import <UIKit/UIKit.h>
#import "MSMTPlaybackController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSExecuteCodeLayerView : UIView<MSCodeShowView>
@property (nonatomic, strong, readonly) AVPlayerLayer *layer;
- (void)setScreenshot:(nullable UIImage *)image;
@end

NS_ASSUME_NONNULL_END
