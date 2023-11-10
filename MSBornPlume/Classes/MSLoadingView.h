//
//  MSLoadingView.h
//  Pods
//
//  Created by admin on 2019/11/27.
//

#import "MSLoadingViewDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSLoadingView : UIView<MSLoadingView>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic) BOOL showsNetworkSpeed;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END
