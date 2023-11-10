//
//  MSViewControllerManager.h
//  MSBornPlume
//
//  Created by admin on 2019/11/23.
//

#import "MSViewControllerManagerDefines.h"
#import "MSFitOnScreenManagerDefines.h"
#import "MSRotationManagerDefines.h"
#import "MSControlLayerAppearManagerDefines.h"
#import "MSPlumePresentViewDefines.h"
#import "MSRotationManager.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSViewControllerManager : NSObject<MSViewControllerManager, MSRotationActionForwarder>
@property (nonatomic, weak, nullable) id<MSFitOnScreenManager> fitOnScreenManager;
@property (nonatomic, weak, nullable) id<MSRotationManager> rotationManager;
@property (nonatomic, weak, nullable) id<MSControlLayerAppearManager> controlLayerAppearManager;
@property (nonatomic, weak, nullable) UIView<MSPlumePresentView> *presentView;
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;
@end
NS_ASSUME_NONNULL_END
