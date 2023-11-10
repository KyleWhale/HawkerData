//
//  MSRotationDefines.m
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationDefines.h"

NSNotificationName const MSRotationManagerRotationNotification = @"MSRotationManagerRotationNotification";
NSNotificationName const MSRotationManagerTransitionNotification = @"MSRotationManagerTransitionNotification";

BOOL
MSRotationIsFullscreenOrientation(MSOrientation orientation) {
    switch (orientation) {
        case MSOrientation_Portrait:
            return NO;
        case MSOrientation_LandscapeLeft:
        case MSOrientation_LandscapeRight:
            return YES;
    }
    return NO;
}

BOOL
MSRotationIsSupportedOrientation(MSOrientation orientation, MSOrientationMask supportedOrientations) {
    return supportedOrientations & (1 << orientation);
}
