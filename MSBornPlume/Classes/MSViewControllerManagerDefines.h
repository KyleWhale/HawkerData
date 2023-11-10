//
//  MSViewControllerManagerDefines.h
//  Pods
//
//  Created by admin on 2019/11/23.
//

#ifndef MSViewControllerManagerDefines_h
#define MSViewControllerManagerDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol MSViewControllerManager <NSObject>
@property (nonatomic, readonly, getter=isViewDisappeared) BOOL viewDisappeared;
@property (nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle;
@property (nonatomic, readonly) BOOL prefersStatusBarHidden;

- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)showStatusBar;
- (void)hiddenStatusBar;
- (void)setNeedsStatusBarAppearanceUpdate;
@end
NS_ASSUME_NONNULL_END
#endif /* MSViewControllerManagerDefines_h */
