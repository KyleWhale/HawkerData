//
//  MSUTRegexHandler.h
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUIKitAttributesDefines.h"
@class MSUTRegexRecorder;

NS_ASSUME_NONNULL_BEGIN
@interface MSUTRegexHandler : NSObject<MSUTRegexHandlerProtocol>
- (instancetype)initWithRegex:(NSString *)regex;
@property (nonatomic, strong, readonly) MSUTRegexRecorder *recorder;
@end

@interface MSUTRegexRecorder : NSObject
@property (nonatomic) NSRegularExpressionOptions regularExpressionOptions;
@property (nonatomic) NSMatchingOptions matchingOptions;
@property (nonatomic, strong, nullable) id<MSUTAttributesProtocol> utOfReplaceWithString;
@property (nonatomic, copy, nullable) NSString *regex;
@property (nonatomic, copy, nullable) void(^replaceWithText)(id<MSUIKitTextMakerProtocol> make);
@property (nonatomic, copy, nullable) void(^update)(id<MSUTAttributesProtocol> make);
@property (nonatomic, copy, nullable) void(^handler)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result);
@end
NS_ASSUME_NONNULL_END
