//
//  MSRotationFullscreenViewController.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/14.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MSRotationFullscreenViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationFullscreenViewController : UIViewController
@property (nonatomic, weak, nullable) id<MSRotationFullscreenViewControllerDelegate> delegate;
@end

@protocol MSRotationFullscreenViewControllerDelegate <NSObject>
- (UIStatusBarStyle)preferredStatusBarStyleForRotationFullscreenViewController:(MSRotationFullscreenViewController *)viewController;
- (BOOL)prefersStatusBarHiddenForRotationFullscreenViewController:(MSRotationFullscreenViewController *)viewController;
@end
NS_ASSUME_NONNULL_END
