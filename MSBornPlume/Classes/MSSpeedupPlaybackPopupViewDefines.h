//
//  MSSpeedupPlaybackPopupViewDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/2/21.
//

#ifndef MSSpeedupPlaybackPopupViewDefines_h
#define MSSpeedupPlaybackPopupViewDefines_h

#import <UIKit/UIKit.h>
#import "MSGestureControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@protocol MSSpeedupPlaybackPopupView <NSObject>
@property (nonatomic) CGFloat rate;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
- (void)show;
- (void)hidden;

@optional
- (void)layoutInRect:(CGRect)rect gestureState:(MSLongPressGestureRecognizerState)state playbackRate:(CGFloat)rate;
@end
NS_ASSUME_NONNULL_END
#endif /* MSSpeedupPlaybackPopupViewDefines_h */
