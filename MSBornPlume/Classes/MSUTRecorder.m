//
//  MSUTRecorder.m
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "MSUTRecorder.h"
#import <CoreText/CTStringAttributes.h>
#import "MSUTUtils.h"

NS_ASSUME_NONNULL_BEGIN
@implementation MSUTStroke
@end
@implementation MSUTDecoration
@end
@implementation MSUTImageAttachment
@end
@implementation MSUTReplace
@end

@implementation MSUTRecorder

static NSArray<NSAttributedStringKey> *MSUT_Keys;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray<NSAttributedStringKey> *m = @[
            NSFontAttributeName,
            NSForegroundColorAttributeName,
            NSBackgroundColorAttributeName,
            NSKernAttributeName,
            NSShadowAttributeName,
            NSStrokeColorAttributeName,
            NSStrokeWidthAttributeName,
            NSUnderlineStyleAttributeName,
            NSUnderlineColorAttributeName,
            NSStrikethroughStyleAttributeName,
            NSStrikethroughColorAttributeName,
            NSBaselineOffsetAttributeName,
            NSParagraphStyleAttributeName,
        ].mutableCopy;
        
        if (@available(iOS 11.0, *)) {
            [m addObject:(__bridge NSString *)kCTBaselineOffsetAttributeName];
        }
        
        MSUT_Keys = m.copy;
    });
}


- (void)setValue:(nullable id)value forAttributeKey:(NSString *)key {
    if ( key == nil ) return;
    if ( _customAttributes == nil ) {
        _customAttributes = NSMutableDictionary.dictionary;
    }
    _customAttributes[key] = value;
}

- (void)setValuesForAttributeKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    if ( keyedValues.count == 0 ) return;
    if ( _customAttributes == nil ) {
        _customAttributes = NSMutableDictionary.dictionary;
    }
    [_customAttributes setValuesForKeysWithDictionary:keyedValues];
}

- (NSDictionary<NSAttributedStringKey, id> *)textAttributes {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    attrs[NSForegroundColorAttributeName] = textColor;
    if ( backgroundColor != nil ) attrs[NSBackgroundColorAttributeName] = backgroundColor;
    if ( kern != nil ) attrs[NSKernAttributeName] = kern;
    if ( shadow != nil ) attrs[NSShadowAttributeName] = shadow;
    if ( stroke != nil ) {
        attrs[NSStrokeColorAttributeName] = stroke.color;
        attrs[NSStrokeWidthAttributeName] = @(stroke.width);
    }
    if ( underLine != nil ) {
        attrs[NSUnderlineStyleAttributeName] = @(underLine.style);
        attrs[NSUnderlineColorAttributeName] = underLine.color;
    }
    if ( strikethrough != nil ) {
        attrs[NSStrikethroughStyleAttributeName] = @(strikethrough.style);
        attrs[NSStrikethroughColorAttributeName] = strikethrough.color;
    }
    if ( @available(iOS 14.0, *) ) {
        attrs[NSBaselineOffsetAttributeName] = @(baseLineOffset.doubleValue);
        attrs[(__bridge NSString *)kCTBaselineOffsetAttributeName] = attrs[NSBaselineOffsetAttributeName];
    }
    else if ( baseLineOffset != nil ) {
        attrs[NSBaselineOffsetAttributeName] = baseLineOffset;
        if ( @available(iOS 11.0, *) ) {
            attrs[(__bridge NSString *)kCTBaselineOffsetAttributeName] = attrs[NSBaselineOffsetAttributeName];
        }
    }
    return attrs;
}

- (NSParagraphStyle *)paragraphAttributesForStyle:(nullable NSParagraphStyle *)style {
#define MSUT_SET_ATTRIBUTE_VALUE(__attr__, __value__) if ( __attr__ != nil ) m.__attr__ = __attr__.__value__;
    NSMutableParagraphStyle *m = (style ?: [NSParagraphStyle defaultParagraphStyle]).mutableCopy;
    MSUT_SET_ATTRIBUTE_VALUE(lineSpacing, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(paragraphSpacing, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(alignment, integerValue);
    MSUT_SET_ATTRIBUTE_VALUE(firstLineHeadIndent, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(headIndent, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(tailIndent, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(lineBreakMode, integerValue);
    MSUT_SET_ATTRIBUTE_VALUE(minimumLineHeight, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(maximumLineHeight, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(baseWritingDirection, integerValue);
    MSUT_SET_ATTRIBUTE_VALUE(lineHeightMultiple, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(paragraphSpacingBefore, doubleValue);
    MSUT_SET_ATTRIBUTE_VALUE(hyphenationFactor, floatValue);
    MSUT_SET_ATTRIBUTE_VALUE(tabStops, copy);
    MSUT_SET_ATTRIBUTE_VALUE(defaultTabInterval, doubleValue);
    if ( @available(iOS 9.0, *) ) {
        MSUT_SET_ATTRIBUTE_VALUE(allowsDefaultTighteningForTruncation, boolValue);
        MSUT_SET_ATTRIBUTE_VALUE(lineBreakStrategy, integerValue);
    }
    return m.copy;
#undef MSUT_SET_ATTRIBUTE_VALUE
}

- (NSDictionary<NSAttributedStringKey, id> *)customAttributes {
    return _customAttributes.copy;
}

- (void)setValuesForCommonRecorder:(MSUTRecorder *)recorder {
#define MSUT_SET_ATTRIBUTE_COMMON_VALUE(__attr__) if ( __attr__ == nil ) __attr__ = recorder->__attr__;
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(_customAttributes);
    
    // text attributes
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(font);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(textColor);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(backgroundColor);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(kern);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(shadow);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(stroke);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(underLine);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(strikethrough);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(baseLineOffset);
    
    // paragraph attributes
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(lineSpacing);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(paragraphSpacing);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(alignment);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(firstLineHeadIndent);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(headIndent);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(tailIndent);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(lineBreakMode);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(minimumLineHeight);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(maximumLineHeight);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(baseWritingDirection);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(lineHeightMultiple);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(paragraphSpacingBefore);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(hyphenationFactor);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(tabStops);
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(defaultTabInterval);
    if ( @available(iOS 9.0, *) ) {
        MSUT_SET_ATTRIBUTE_COMMON_VALUE(allowsDefaultTighteningForTruncation);
        MSUT_SET_ATTRIBUTE_COMMON_VALUE(lineBreakStrategy);
    }
    
    // custom attributes
    MSUT_SET_ATTRIBUTE_COMMON_VALUE(_customAttributes);
#undef MSUT_SET_ATTRIBUTE_COMMON_VALUE
}

- (void)setValuesForAttributedString:(NSAttributedString *)attributedString {
    NSMutableDictionary<NSAttributedStringKey, id> *attrs = [[self _getGlobalAttributesForAttributedString:attributedString] mutableCopy];
    if ( attrs.count != 0 ) {
        
        // text attributes
        font = attrs[NSFontAttributeName];
        textColor = attrs[NSForegroundColorAttributeName];
        backgroundColor = attrs[NSBackgroundColorAttributeName];
        kern = attrs[NSKernAttributeName];
        shadow = attrs[NSShadowAttributeName];
        UIColor *strokeColor = attrs[NSStrokeColorAttributeName];
        NSNumber *strokeWidth = attrs[NSStrokeWidthAttributeName];
        if ( strokeColor != nil || strokeWidth != nil ) {
            stroke = MSUTStroke.alloc.init;
            stroke.color = strokeColor;
            stroke.width = strokeWidth.floatValue;
        }
        
        UIColor *underLineColor = attrs[NSUnderlineColorAttributeName];
        NSNumber *underLineStyle = attrs[NSUnderlineStyleAttributeName];
        if ( underLineColor != nil || underLineStyle != nil ) {
            underLine = MSUTDecoration.alloc.init;
            underLine.color = underLineColor;
            underLine.style = underLineStyle.integerValue;
        }
        
        UIColor *strikethroughColor = attrs[NSStrikethroughColorAttributeName];
        NSNumber *strikethroughStyle = attrs[NSStrikethroughStyleAttributeName];
        if ( strikethroughColor != nil || strikethroughStyle != nil ) {
            strikethrough = MSUTDecoration.alloc.init;
            strikethrough.color = strikethroughColor;
            strikethrough.style = strikethroughStyle.integerValue;
        }
        baseLineOffset = attrs[NSBaselineOffsetAttributeName];
        
        // paragraph attributes
        NSParagraphStyle *paragraphAttributes = attrs[NSParagraphStyleAttributeName];
        if ( paragraphAttributes != nil ) {
#define MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(__attr__) if ( paragraphAttributes.__attr__ != 0 ) __attr__ = @(paragraphAttributes.__attr__);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineSpacing);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(paragraphSpacing);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(alignment);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(firstLineHeadIndent);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(headIndent);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(tailIndent);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineBreakMode);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(minimumLineHeight);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(maximumLineHeight);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(baseWritingDirection);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineHeightMultiple);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(paragraphSpacingBefore);
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(hyphenationFactor);
            tabStops = paragraphAttributes.tabStops;
            MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(defaultTabInterval);
            if ( @available(iOS 9.0, *) ) {
                MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(allowsDefaultTighteningForTruncation);
                MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber(lineBreakStrategy);
            }
#undef MSUT_SET_PARAGRAPH_ATTRIBUTE_NSNumber
        }
        
        // custom attributes
        [attrs removeObjectsForKeys:MSUT_Keys];
        [self setValuesForAttributeKeysWithDictionary:attrs];
    }
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)_getGlobalAttributesForAttributedString:(NSAttributedString *)attributedString {
    NSRange textRange = MSUTGetTextRange(attributedString);
    NSRange longestEffectiveRange;
    NSDictionary<NSAttributedStringKey, id> *attrs = [attributedString attributesAtIndex:0 longestEffectiveRange:&longestEffectiveRange inRange:textRange];
    if ( MSUTRangeContains(longestEffectiveRange, textRange) ) {
        return attrs;
    }
    
    NSDictionary<NSAttributedStringKey, id> *next = nil;
    while ( attrs.count != 0 && NSMaxRange(longestEffectiveRange) != NSMaxRange(textRange) ) {
        next = [attributedString attributesAtIndex:NSMaxRange(longestEffectiveRange) effectiveRange:&longestEffectiveRange];
        
        NSMutableDictionary<NSAttributedStringKey, id> *tmp = [attrs mutableCopy];
        [attrs enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ( ![obj isEqual:next[key]] )
                tmp[key] = nil;
        }];
        attrs = tmp.copy;
    }
    return attrs;
}
@end
NS_ASSUME_NONNULL_END
