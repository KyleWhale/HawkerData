//
//  MSLoadingViewDefines.h
//  Pods
//
//  Created by admin on 2019/11/27.
//

#ifndef MSLoadingViewDefines_h
#define MSLoadingViewDefines_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MSLoadingView <NSObject>
@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic) BOOL showsNetworkSpeed;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;
@end
NS_ASSUME_NONNULL_END

#endif /* MSLoadingViewDefines_h */
