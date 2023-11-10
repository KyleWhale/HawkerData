//
//  MSRotationDefines.h
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
 
FOUNDATION_EXPORT NSNotificationName const MSRotationManagerRotationNotification;
FOUNDATION_EXPORT NSNotificationName const MSRotationManagerTransitionNotification;

FOUNDATION_EXPORT BOOL MSRotationIsFullscreenOrientation(MSOrientation orientation);
FOUNDATION_EXPORT BOOL MSRotationIsSupportedOrientation(MSOrientation orientation, MSOrientationMask supportedOrientations);

NS_ASSUME_NONNULL_END
