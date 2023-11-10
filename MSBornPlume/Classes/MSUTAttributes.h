//
//  MSUTAttributes.h
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSUIKitAttributesDefines.h"
#import "MSUTRecorder.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSUTAttributes : NSObject<MSUTAttributesProtocol>
@property (nonatomic, strong, readonly) MSUTRecorder *recorder;
@end
NS_ASSUME_NONNULL_END
