//
//  MSRotationObserver.m
//  MSPlume_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "MSRotationObserver.h"
#import "MSRotationDefines.h"

@implementation MSRotationObserver
- (instancetype)initWithManager:(MSRotationManager *)manager {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onRotation:) name:MSRotationManagerRotationNotification object:manager];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onTransition:) name:MSRotationManagerTransitionNotification object:manager];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onRotation:(NSNotification *)note {
    BOOL isRotating = [(MSRotationManager *)note.object isRotating];
    if ( _onRotatingChanged != nil ) _onRotatingChanged(note.object, isRotating);
}

- (void)onTransition:(NSNotification *)note {
    BOOL isTransitioning = [(MSRotationManager *)note.object isTransitioning];
    if ( _onTransitioningChanged != nil ) _onTransitioningChanged(note.object, isTransitioning);
}
@end
