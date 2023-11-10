//
//  MSUIKitTextMaker.m
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUIKitTextMaker.h"
#import <CoreText/CTStringAttributes.h>
#import "MSUTRegexHandler.h"
#import "MSUTRangeHandler.h"
#import "MSUTUtils.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSMutableAttributedString (MSUTExtended)
- (void)addAttributesForRecorder:(MSUTRecorder *)recorder range:(NSRange)range;
@end

@implementation NSMutableAttributedString (MSUTExtended)
- (void)addAttributesForRecorder:(MSUTRecorder *)recorder range:(NSRange)subrange {
    // text attributes
    NSDictionary<NSAttributedStringKey, id> *textAttributes = recorder.textAttributes;
    if ( textAttributes.count != 0 ) [self addAttributes:textAttributes range:subrange];

    // paragraph attributes
    NSRange styleRange = NSMakeRange(0, 0);
    NSParagraphStyle *style = subrange.location < self.length ? [self attribute:NSParagraphStyleAttributeName atIndex:subrange.location effectiveRange:&styleRange] : nil;
    NSParagraphStyle *paragraphAttributes = [recorder paragraphAttributesForStyle:MSUTRangeContains(styleRange, subrange) ? style : nil];
    [self addAttributes:@{NSParagraphStyleAttributeName : paragraphAttributes} range:subrange];
    
    // custom attributes
    NSDictionary<NSAttributedStringKey, id> *customAttributes = recorder.customAttributes;
    if ( customAttributes.count != 0 ) [self addAttributes:customAttributes range:subrange];
}
@end

@interface MSUIKitTextMaker ()
@property (nonatomic, strong, readonly) NSMutableArray<MSUTAttributes *> *uts;
@property (nonatomic, strong, readonly) NSMutableArray<MSUTAttributes *> *updates;
@property (nonatomic, strong, readonly) NSMutableArray<MSUTRegexHandler *> *regexs;
@property (nonatomic, strong, readonly) NSMutableArray<MSUTRangeHandler *> *ranges;
@end

@implementation MSUIKitTextMaker
@synthesize uts = _uts;
- (NSMutableArray<MSUTAttributes *> *)uts {
    if ( !_uts ) _uts = [NSMutableArray array];
    return _uts;
}
@synthesize updates = _updates;
- (NSMutableArray<MSUTAttributes *> *)updates {
    if ( !_updates ) _updates = [NSMutableArray array];
    return _updates;
}
@synthesize regexs = _regexs;
- (NSMutableArray<MSUTRegexHandler *> *)regexs {
    if ( !_regexs ) _regexs = [NSMutableArray array];
    return _regexs;
}
@synthesize ranges = _ranges;
- (NSMutableArray<MSUTRangeHandler *> *)ranges {
    if ( !_ranges ) _ranges = [NSMutableArray array];
    return _ranges;
}

- (id<MSUTAttributesProtocol>  _Nonnull (^)(NSString * _Nonnull))append {
    return ^id<MSUTAttributesProtocol>(NSString *str) {
        MSUTAttributes *ut = [MSUTAttributes new];
        ut.recorder->string = str;
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<MSUTAttributesProtocol>  _Nonnull (^)(NSRange))update {
    return ^id<MSUTAttributesProtocol>(NSRange range) {
        MSUTAttributes *ut = [MSUTAttributes new];
        ut.recorder->range = range;
        [self.updates addObject:ut];
        return ut;
    };
}
- (id<MSUTAttributesProtocol>  _Nonnull (^)(void (^ _Nonnull)(id<MSUTImageAttachment> _Nonnull)))appendImage {
    return ^id<MSUTAttributesProtocol>(void(^block)(id<MSUTImageAttachment> make)) {
        MSUTAttributes *ut = [MSUTAttributes new];
        MSUTImageAttachment *attachment = [MSUTImageAttachment new];
        ut.recorder->attachment = attachment;
        block(attachment);
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<MSUTAttributesProtocol>  _Nonnull (^)(NSAttributedString * _Nonnull))appendText {
    return ^id<MSUTAttributesProtocol>(NSAttributedString *attrStr) {
        MSUTAttributes *ut = [MSUTAttributes new];
        ut.recorder->attrStr = [attrStr mutableCopy];
        [ut.recorder setValuesForAttributedString:attrStr];
        [self.uts addObject:ut];
        return ut;
    };
}
- (id<MSUTRegexHandlerProtocol>  _Nonnull (^)(NSString * _Nonnull))regex {
    return ^id<MSUTRegexHandlerProtocol>(NSString *regex) {
        MSUTRegexHandler *handler = [[MSUTRegexHandler alloc] initWithRegex:regex];
        [self.regexs addObject:handler];
        return handler;
    };
}
- (id<MSUTRangeHandlerProtocol>  _Nonnull (^)(NSRange))range {
    return ^id<MSUTRangeHandlerProtocol>(NSRange range) {
        MSUTRangeHandler *handler = [[MSUTRangeHandler alloc] initWithRange:range];
        [self.ranges addObject:handler];
        return handler;
    };
}
- (NSMutableAttributedString *)install {
    // default values
    MSUTRecorder *recorder = self.recorder;
    if ( recorder->font == nil ) recorder->font = [UIFont systemFontOfSize:14];
    if ( recorder->textColor == nil ) recorder->textColor = [UIColor blackColor];

    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    [self _appendUTAttributesToResultIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    [self _executeRangeHandlersIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    [self _executeRegexHandlersIfNeeded:result];
    [self _executeUpdateHandlersIfNeeded:result];
    return result;
}

- (void)_appendUTAttributesToResultIfNeeded:(NSMutableAttributedString *)result {
    if ( _uts ) {
        for ( MSUTAttributes *ut in _uts ) {
            id _Nullable current = [self _convertToUIKitTextForUTAttributes:ut];
            if ( current != nil ) {
                [result appendAttributedString:current];
            }
        }
        _uts = nil;
    }
}

- (NSMutableAttributedString *_Nullable)_convertToUIKitTextForUTAttributes:(MSUTAttributes *)attr {
    NSMutableAttributedString *_Nullable current = nil;
    MSUTRecorder *recorder = attr.recorder;
    if      ( recorder->string != nil ) {
        current = [[NSMutableAttributedString alloc] initWithString:recorder->string];
    }
    else if ( recorder->attrStr != nil ) {
        current = recorder->attrStr;
    }
    else if ( recorder->attachment != nil ) {
        MSUTVerticalAlignment alignment = recorder->attachment.alignment;
        UIImage *image = recorder->attachment.image;
        CGRect bounds = recorder->attachment.bounds;
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = recorder->attachment.image;
        attachment.bounds = [self _adjustVerticalOffsetOfImageAttachmentForBounds:bounds imageSize:image.size alignment:alignment commonFont:self.recorder->font];
        current = [NSAttributedString attributedStringWithAttachment:attachment].mutableCopy;
    }

    if ( current != nil ) {
        [recorder setValuesForCommonRecorder:self.recorder];
        [current addAttributesForRecorder:recorder range:MSUTGetTextRange(current)];
    }
    return current;
}

- (void)_executeRangeHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _ranges ) {
        for ( MSUTRangeHandler *handler in _ranges ) {
            MSUTRangeRecorder *recorder = handler.recorder;
            if ( MSUTRangeContains(MSUTGetTextRange(result), recorder.range) ) {
                if      ( recorder.utOfReplaceWithString != nil ) {
                    [self _executeReplaceWithString:result ut:recorder.utOfReplaceWithString inRange:recorder.range];
                }
                else if ( recorder.replaceWithText != nil ) {
                    [self _executeReplaceWithText:result handler:recorder.replaceWithText inRange:recorder.range];
                }
                else if ( recorder.update != nil ) {
                    [self _appendUpdateHandlerToUpdates:recorder.update inRange:recorder.range];
                }
            }
        }
        _ranges = nil;
    }
}

- (void)_executeRegexHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _regexs ) {
        for ( MSUTRegexHandler *handler in _regexs ) {
            NSString *string = result.string;
            NSRange resultRange = NSMakeRange(0, result.length);
            MSUTRegexRecorder *recorder = handler.recorder;
            if ( recorder.regex.length < 1 )
                continue;
            
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:recorder.regex options:recorder.regularExpressionOptions error:nil];
            NSMutableArray<NSTextCheckingResult *> *results = [NSMutableArray new];
            [regular enumerateMatchesInString:string options:recorder.matchingOptions range:resultRange usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                if ( result ) [results addObject:result];
            }];
            
            [results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange range = obj.range;
                if ( recorder.update != nil ) {
                    [self _appendUpdateHandlerToUpdates:recorder.update inRange:range];
                }
                else if ( recorder.utOfReplaceWithString != nil ) {
                    [self _executeReplaceWithString:result ut:recorder.utOfReplaceWithString inRange:range];
                }
                else if ( recorder.replaceWithText != nil ) {
                    [self _executeReplaceWithText:result handler:recorder.replaceWithText inRange:range];
                }
                else if ( recorder.handler != nil ) {
                    recorder.handler(result, obj);
                }
            }];
        }
        _regexs = nil;
    }
}

- (void)_executeReplaceWithString:(NSMutableAttributedString *)result ut:(id<MSUTAttributesProtocol>)ut inRange:(NSRange)range {
    if ( MSUTRangeContains(MSUTGetTextRange(result), range) ) {
        MSUTAttributes *uta = (id)ut;
        [self _setSubtextCommonValuesToRecorder:uta.recorder inRange:range result:result];
        id _Nullable subtext = [self _convertToUIKitTextForUTAttributes:uta];
        if ( subtext ) {
            [result replaceCharactersInRange:range withAttributedString:subtext];
        }
    }
}

- (void)_executeReplaceWithText:(NSMutableAttributedString *)result handler:(void(^)(id<MSUIKitTextMakerProtocol> maker))handler inRange:(NSRange)range {
    if ( MSUTRangeContains(MSUTGetTextRange(result), range) ) {
        MSUIKitTextMaker *maker = [MSUIKitTextMaker new];
        [maker.recorder setValuesForCommonRecorder:self.recorder];
        [self _setSubtextCommonValuesToRecorder:maker.recorder inRange:range result:result];
        handler(maker);
        [result replaceCharactersInRange:range withAttributedString:maker.install];
    }
}

- (void)_executeUpdateHandlersIfNeeded:(NSMutableAttributedString *)result {
    if ( _updates ) {
        NSRange resultRange = NSMakeRange(0, result.length);
        for ( MSUTAttributes *ut in _updates ) {
            MSUTRecorder *recorder = ut.recorder;
            NSRange range = recorder->range;
            if ( MSUTRangeContains(resultRange, range) ) {
                [recorder setValuesForCommonRecorder:self.recorder];
                [result addAttributesForRecorder:recorder range:range];
            }
        }
        _updates = nil;
    }
}

- (void)_appendUpdateHandlerToUpdates:(void(^)(id<MSUTAttributesProtocol>))handler inRange:(NSRange)range {
    MSUTAttributes *ut = [MSUTAttributes new];
    ut.recorder->range = range;
    handler(ut);
    [self.updates addObject:ut];
}

- (void)_setSubtextCommonValuesToRecorder:(MSUTRecorder *)recorder inRange:(NSRange)range result:(NSAttributedString *)result {
    if ( MSUTRangeContains(MSUTGetTextRange(result), range) ) {
        NSAttributedString *subtext = [result attributedSubstringFromRange:range];
        NSDictionary<NSAttributedStringKey, id> *dict = [subtext attributesAtIndex:0 effectiveRange:NULL];
        recorder->font = dict[NSFontAttributeName];
        recorder->textColor = dict[NSForegroundColorAttributeName];
    }
}

- (CGRect)_adjustVerticalOffsetOfImageAttachmentForBounds:(CGRect)bounds imageSize:(CGSize)imageSize alignment:(MSUTVerticalAlignment)alignment commonFont:(UIFont *)font {
    switch ( alignment ) {
        case MSUTVerticalAlignmentCenter: {
            if ( CGSizeEqualToSize(CGSizeZero, bounds.size) ) {
                bounds.size = imageSize;
            }
            
            CGFloat fontHeight = font.lineHeight;
            CGFloat centerline = fontHeight * 0.5 - ABS(font.descender);
            bounds.origin.y = centerline - imageSize.height * 0.5;
        }
            break;
        case MSUTVerticalAlignmentDefault: { }
            break;
    }
    return bounds;
}
@end
NS_ASSUME_NONNULL_END
