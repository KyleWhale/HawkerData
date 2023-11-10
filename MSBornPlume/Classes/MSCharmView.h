//
//  MSCharmView.h
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import <UIKit/UIKit.h>

@protocol MSCharmViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSCharmView : UIView
@property (nonatomic, strong, readonly, nullable) UIView *presentView;
@property (nonatomic, weak, nullable) id<MSCharmViewDelegate> delegate;
@end

@protocol MSCharmViewDelegate <NSObject>
- (void)playerViewWillMoveToWindow:(MSCharmView *)codeView;
- (nullable UIView *)codeView:(MSCharmView *)codeView hitTestForView:(nullable __kindof UIView *)view;
@end
NS_ASSUME_NONNULL_END
