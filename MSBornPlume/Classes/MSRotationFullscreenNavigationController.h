//
//  MSRotationFullscreenNavigationController.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MSRotationFullscreenNavigationControllerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationFullscreenNavigationController : UINavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(nullable id<MSRotationFullscreenNavigationControllerDelegate>)delegate;
@end


@protocol MSRotationFullscreenNavigationControllerDelegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
NS_ASSUME_NONNULL_END
