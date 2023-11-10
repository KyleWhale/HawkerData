//
//  MSUTRangeHandler.m
//  AttributesFactory
//
//  Created by admin on 2019/4/13.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUTRangeHandler.h"
#import "MSUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@implementation MSUTRangeHandler
- (instancetype)initWithRange:(NSRange)range {
    self = [super init];
    if ( !self ) return nil;
    _recorder = [[MSUTRangeRecorder alloc] init];
    _recorder.range = range;
    return self;
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
@end

@implementation MSUTRangeRecorder
@end
NS_ASSUME_NONNULL_END
