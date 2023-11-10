//
//  MSRotationObserver.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSRotationObserver : NSObject<MSRotationManagerObserver>
- (instancetype)initWithManager:(MSRotationManager *)manager;

@property (nonatomic, copy, nullable) void(^onRotatingChanged)(id<MSRotationManager> mgr, BOOL isRotating);
@property (nonatomic, copy, nullable) void(^onTransitioningChanged)(id<MSRotationManager> mgr, BOOL isTransitioning);
@end
NS_ASSUME_NONNULL_END
