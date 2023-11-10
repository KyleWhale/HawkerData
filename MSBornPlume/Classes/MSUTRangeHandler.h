//
//  MSUTRangeHandler.h
//  AttributesFactory
//
//  Created by admin on 2019/4/13.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUIKitAttributesDefines.h"
@class MSUTRangeRecorder;

NS_ASSUME_NONNULL_BEGIN
@interface MSUTRangeHandler : NSObject<MSUTRangeHandlerProtocol>
- (instancetype)initWithRange:(NSRange)range;
@property (nonatomic, strong, readonly) MSUTRangeRecorder *recorder;
@end

@interface MSUTRangeRecorder : NSObject
@property (nonatomic) NSRange range;
@property (nonatomic, strong, nullable) id<MSUTAttributesProtocol> utOfReplaceWithString;
@property (nonatomic, copy, nullable) void(^replaceWithText)(id<MSUIKitTextMakerProtocol> make);
@property (nonatomic, copy, nullable) void(^update)(id<MSUTAttributesProtocol> make);
@end
NS_ASSUME_NONNULL_END
