//
//  MSUTRegexHandler.m
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUTRegexHandler.h"
#import "MSUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@implementation MSUTRegexHandler
- (instancetype)initWithRegex:(NSString *)regex {
    self = [super init];
    if ( !self ) return nil;
    _recorder = [MSUTRegexRecorder new];
    _recorder.regex = regex;
    return self;
}

- (void (^)(void (^ _Nonnull)(NSMutableAttributedString *attrStr, NSTextCheckingResult * _Nonnull)))handler {
    return ^(void(^block)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result)) {
        self.recorder.handler = block;
    };
}
- (void (^)(void (^ _Nonnull)(id<MSUIKitTextMakerProtocol> _Nonnull)))replaceWithText {
    return ^(void(^block)(id<MSUIKitTextMakerProtocol> make)) {
        self.recorder.replaceWithText = block;
    };
}
- (id<MSUTAttributesProtocol>  _Nonnull (^)(NSString * _Nonnull))replaceWithString {
    return ^id<MSUTAttributesProtocol>(NSString *string) {
        MSUTAttributes *attr = [MSUTAttributes new];
        attr.recorder->string = string;
        self.recorder.utOfReplaceWithString = attr;
        return attr;
    };
}
- (void (^)(void (^ _Nonnull)(id<MSUTAttributesProtocol> _Nonnull)))update {
    return ^(void(^block)(id<MSUTAttributesProtocol> make)) {
        self.recorder.update = block;
    };
}
- (id<MSUTRegexHandlerProtocol>  _Nonnull (^)(NSMatchingOptions))matchingOptions {
    return ^id<MSUTRegexHandlerProtocol>(NSMatchingOptions ops) {
        self.recorder.matchingOptions = ops;
        return self;
    };
}
- (id<MSUTRegexHandlerProtocol>  _Nonnull (^)(NSRegularExpressionOptions))regularExpressionOptions {
    return ^id<MSUTRegexHandlerProtocol>(NSRegularExpressionOptions ops) {
        self.recorder.regularExpressionOptions = ops;
        return self;
    };
}
@end

@implementation MSUTRegexRecorder
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _matchingOptions = NSMatchingWithoutAnchoringBounds;
    return self;
}
@end
NS_ASSUME_NONNULL_END
