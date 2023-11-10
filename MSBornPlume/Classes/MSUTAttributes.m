//
//  MSUTAttributes.m
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUTAttributes.h"

NS_ASSUME_NONNULL_BEGIN
#define MSUT_BLOCK_SET_ATTRIBUTE_Obj(__type__, __attr__) \
    ^id<MSUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = __attr__; \
        return self; \
    }

#define MSUT_BLOCK_SET_ATTRIBUTE_Obj_copy(__type__, __attr__) \
    ^id<MSUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = __attr__.copy; \
        return self; \
    }


#define MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(__type__, __attr__) \
    ^id<MSUTAttributesProtocol>(__type__ __attr__) { \
        self.recorder->__attr__ = @(__attr__); \
        return self; \
    }

#define MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(__attr__) MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(CGFloat, __attr__)


@implementation MSUTAttributes
@synthesize recorder = _recorder;
- (MSUTRecorder *)recorder {
    if ( !_recorder ) {
        _recorder = [[MSUTRecorder alloc] init];
    }
    return _recorder;
}

- (MSUTFontAttribute)font {
    return MSUT_BLOCK_SET_ATTRIBUTE_Obj(UIFont *, font);
}

- (MSUTColorAttribute)textColor {
    return MSUT_BLOCK_SET_ATTRIBUTE_Obj(UIColor *, textColor);
}

///
/// Thanks @donggelaile
/// https://github.com/changsanjiang/MSAttributesFactory/issues/9
///
- (MSUTKernAttribute)kern {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(kern);
}

- (MSUTShadowAttribute)shadow {
    return ^id<MSUTAttributesProtocol>(void(^block)(NSShadow *make)) {
        NSShadow *_Nullable shadow = self.recorder->shadow;
        if ( !shadow ) {
            self.recorder->shadow = shadow = [NSShadow new];
        }
        block(shadow);
        return self;
    };
}

- (MSUTColorAttribute)backgroundColor {
    return MSUT_BLOCK_SET_ATTRIBUTE_Obj(UIColor *, backgroundColor);
}

- (MSUTStrokeAttribute)stroke {
    return ^id<MSUTAttributesProtocol>(void(^block)(id<MSUTStroke> stroke)) {
        MSUTStroke *_Nullable stroke = self.recorder->stroke;
        if ( !stroke ) {
            self.recorder->stroke = stroke = [MSUTStroke new];
        }
        block(stroke);
        return self;
    };
}

- (MSUTDecorationAttribute)underLine {
    return ^id<MSUTAttributesProtocol>(void(^block)(id<MSUTDecoration> decoration)) {
        MSUTDecoration *_Nullable decoration = self.recorder->underLine;
        if ( !decoration ) {
            self.recorder->underLine = decoration = [MSUTDecoration new];
        }
        block(decoration);
        return self;
    };
}

- (MSUTDecorationAttribute)strikethrough {
    return ^id<MSUTAttributesProtocol>(void(^block)(id<MSUTDecoration> decoration)) {
        MSUTDecoration *_Nullable decoration = self.recorder->strikethrough;
        if ( !decoration ) {
            self.recorder->strikethrough = decoration = [MSUTDecoration new];
        }
        block(decoration);
        return self;
    };
}
//typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTBaseLineOffsetAttribute)(double offset);
//#define MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(__attr__) MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(CGFloat, __attr__)
//#define MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(__type__, __attr__) \
//    ^id<MSUTAttributesProtocol>(__type__ __attr__) { \
//        self.recorder->__attr__ = @(__attr__); \
//        return self; \
//    }

- (MSUTBaseLineOffsetAttribute)baseLineOffset {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(baseLineOffset);
}

#pragma mark - mark


- (MSUTLineSpacingAttribute)lineSpacing {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(lineSpacing);
}

- (MSUTParagraphSpacingAttribute)paragraphSpacing {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(paragraphSpacing);
}

- (MSUTAlignmentAttribute)alignment {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSTextAlignment, alignment);
}

- (MSUTFirstLineHeadIndentAttribute)firstLineHeadIndent {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(firstLineHeadIndent);
}

- (MSUTHeadIndentAttribute)headIndent {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(headIndent);
}

- (MSUTTailIndentAttribute)tailIndent {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(tailIndent);
}

- (MSUTLineBreakModeAttribute)lineBreakMode {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSLineBreakMode, lineBreakMode);
}

- (MSUTMinimumLineHeightAttribute)minimumLineHeight {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(minimumLineHeight);
}

- (MSUTMaximumLineHeightAttribute)maximumLineHeight {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(maximumLineHeight);
}

- (MSUTBaseWritingDirectionAttribute)baseWritingDirection {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSWritingDirection, baseWritingDirection);
}

- (MSUTLineHeightMultipleAttribute)lineHeightMultiple {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(lineHeightMultiple);
}

- (MSUTParagraphSpacingBeforeAttribute)paragraphSpacingBefore {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(paragraphSpacingBefore);
}

- (MSUTHyphenationFactorAttribute)hyphenationFactor {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(float, hyphenationFactor);
}

- (MSUTTabStopsAttribute)tabStops {
    return MSUT_BLOCK_SET_ATTRIBUTE_Obj_copy(NSArray<NSTextTab *> *, tabStops);
}

- (MSUTDefaultTabIntervalAttribute)defaultTabInterval {
    return MSUT_BLOCK_SET_ATTRIBUTE_CGFloat(defaultTabInterval);
}

- (MSUTAllowsDefaultTighteningForTruncationAttribute)allowsDefaultTighteningForTruncation API_AVAILABLE(ios(9.0)) {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(BOOL, allowsDefaultTighteningForTruncation);
}

- (MSUTLineBreakStrategyAttribute)lineBreakStrategy API_AVAILABLE(ios(9.0)) {
    return MSUT_BLOCK_SET_ATTRIBUTE_NSNumber(NSLineBreakStrategy, lineBreakStrategy);
}

- (MSUTSetAttribute)set {
    return ^id<MSUTAttributesProtocol>(id _Nullable value, NSString *forKey) {
        [self.recorder setValue:value forAttributeKey:forKey];
        return self;
    };
}
@end
#undef MSUT_BLOCK_SET_ATTRIBUTE_CGFloat
#undef MSUT_BLOCK_SET_ATTRIBUTE_NSNumber
#undef MSUT_BLOCK_SET_ATTRIBUTE_Obj_copy
#undef MSUT_BLOCK_SET_ATTRIBUTE_Obj
NS_ASSUME_NONNULL_END
