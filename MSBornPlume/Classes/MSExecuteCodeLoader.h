//
//  MSExecuteCodeLoader.h
//  Pods
//
//  Created by admin on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "MSPlumeResource.h"
#import "MSExecuteCode.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSExecuteCodeLoader : NSObject

+ (nullable MSExecuteCode *)loadPlayerForMedia:(MSPlumeResource *)media;

+ (void)clearPlayerForMedia:(MSPlumeResource *)media;

@end
NS_ASSUME_NONNULL_END
