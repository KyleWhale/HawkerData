//
//  MSFitOnScreenManager.h
//  MSBornPlume
//
//  Created by admin on 2018/12/31.
//

#import <Foundation/Foundation.h>
#import "MSFitOnScreenManagerDefines.h"
#import "MSViewControllerManagerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSFitOnScreenManager : NSObject<MSFitOnScreenManager>
@property (nonatomic, weak, nullable) id<MSViewControllerManager> viewControllerManager;
@end
NS_ASSUME_NONNULL_END

