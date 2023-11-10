//
//  MSReachabilityObserver.h
//  Project
//
//  Created by admin on 2018/12/28.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSReachabilityDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSReachability : NSObject<MSReachability>
+ (instancetype)shared;
@end
NS_ASSUME_NONNULL_END
