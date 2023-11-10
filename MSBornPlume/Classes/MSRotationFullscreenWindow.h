//
//  MSRotationFullscreenWindow.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSRotationManager.h"
@protocol MSRotationFullscreenWindowDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationFullscreenWindow : UIWindow
- (instancetype)initWithFrame:(CGRect)frame delegate:(nullable id<MSRotationFullscreenWindowDelegate>)delegate;
- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene delegate:(nullable id<MSRotationFullscreenWindowDelegate>)delegate API_AVAILABLE(ios(13.0));

@property (nonatomic, weak, nullable) MSRotationManager *rotationManager;

@end

@protocol MSRotationFullscreenWindowDelegate <NSObject>
- (BOOL)window:(MSRotationFullscreenWindow *)window pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event;
@end
NS_ASSUME_NONNULL_END
