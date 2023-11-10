//
//  MSUIKitAttributesDefines.h
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#ifndef MSUIKitAttributesDefines_h
#define MSUIKitAttributesDefines_h
#import <UIKit/UIKit.h>
@protocol   MSUIKitTextMakerProtocol,
            MSUTAttributesProtocol,
            MSUTImageAttributesProtocol,
            MSUTRegexHandlerProtocol,
            MSUTRangeHandlerProtocol,
            MSUTStroke,
            MSUTDecoration,
            MSUTImageAttachment;

NS_ASSUME_NONNULL_BEGIN
@protocol MSUIKitTextMakerProtocol <MSUTAttributesProtocol>
/**
 * - Append a `string` to the text.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"String 1").font([UIFont boldSystemFontOfSize:14]);
 *   }];
 *
 *   // It's equivalent to below code.
 *
 *   NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
 *   NSAttributedString *text1 = [[NSAttributedString alloc] initWithString:@"String 1" attributes:attributes];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTAttributesProtocol>(^append)(NSString *str);

typedef void(^MSUTAppendImageHandler)(id<MSUTImageAttachment> make);
/**
 * - Append an `image attachment` to the text.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.appendImage(^(id<MSUTImageAttachment>  _Nonnull make) {
 *           make.image = [UIImage imageNamed:@"image"];
 *           make.bounds = CGRectMake(0, 0, 50, 50);
 *       });
 *   }];
 *
 *   // It's equivalent to below code.
 *
 *   NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
 *   attachment.image = [UIImage imageNamed:@"image"];
 *   attachment.bounds = CGRectMake(0, 0, 50, 50);
 *   NSAttributedString *text1 = [NSAttributedString attributedStringWithAttachment:attachment];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTAttributesProtocol>(^appendImage)(NS_NOESCAPE MSUTAppendImageHandler block);

/**
 * - Append a `subtext` to the text.
 *
 * \code
 *   NSAttributedString *subtext = _label.attributedText;
 *
 *   NSAttributedString *text = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.appendText(subtext);
 *   }];
 *
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTAttributesProtocol>(^appendText)(NSAttributedString *subtext);

/**
 * - Update the attributes for the specified range of `text`.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"String 1");
 *       make.update(NSMakeRange(0, 1)).font([UIFont boldSystemFontOfSize:20]);
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTAttributesProtocol>(^update)(NSRange range);

/**
 * - Use regular to process `text`.
 *
 * \code
 *    NSAttributedString *text1 = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Replace `123` with `oOo`.
 *       make.regex(@"123").replaceWithString(@"oOo").font([UIFont boldSystemFontOfSize:20]);
 *   }];
 *
 *    NSAttributedString *text2 = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Replace `123` with `oOo`.
 *       make.regex(@"123").replaceWithText(^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *           make.append(@"oOo").font([UIFont boldSystemFontOfSize:20]);
 *       });
 *   }];
 *
 *    NSAttributedString *text3 = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 4 123 123");
 *       // Update the attributes of the matched text.
 *       make.regex(@"123").update(^(id<MSUTAttributesProtocol>  _Nonnull make) {
 *           make.font([UIFont boldSystemFontOfSize:20]).textColor([UIColor redColor]);
 *       });
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTRegexHandlerProtocol>(^regex)(NSString *regularExpression);

/**
 * - Edit the subtext for the specified range of `text`.
 *
 * \code
 *    NSAttributedString *text = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *       make.append(@"123 123 M 123 123").font([UIFont boldSystemFontOfSize:20]);
 *       // Update the attributes for the specified range of `text`.
 *       make.range(NSMakeRange(0, 1)).update(^(id<MSUTAttributesProtocol>  _Nonnull make) {
 *           make.font([UIFont boldSystemFontOfSize:20]).textColor([UIColor orangeColor]);
 *       });
 *
 *       // Replace the subtext for the specified range of `text`.
 *       make.range(NSMakeRange(1, 1)).replaceWithString(@"O").textColor([UIColor purpleColor]);
 *
 *       // Replace the subtext for the specified range of `text`.
 *       make.range(NSMakeRange(2, 1)).replaceWithText(^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
 *           make.append(@"S").font([UIFont boldSystemFontOfSize:24]).textColor([UIColor greenColor]);
 *       });
 *   }];
 * \endcode
 */
@property (nonatomic, copy, readonly) id<MSUTRangeHandlerProtocol>(^range)(NSRange range);
@end

typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTFontAttribute)(UIFont *font);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTColorAttribute)(UIColor *color);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTKernAttribute)(CGFloat kern);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTShadowAttribute)(void(^)(NSShadow *make));
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTStrokeAttribute)(void(^block)(id<MSUTStroke> make));
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTDecorationAttribute)(void(^)(id<MSUTDecoration> make));
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTBaseLineOffsetAttribute)(CGFloat offset);

typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTLineSpacingAttribute)(CGFloat lineSpacing);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTParagraphSpacingAttribute)(CGFloat paragraphSpacing);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTAlignmentAttribute)(NSTextAlignment alignment);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTFirstLineHeadIndentAttribute)(CGFloat firstLineHeadIndent);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTHeadIndentAttribute)(CGFloat headIndent);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTTailIndentAttribute)(CGFloat tailIndent);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTLineBreakModeAttribute)(NSLineBreakMode lineBreakMode);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTMinimumLineHeightAttribute)(CGFloat minimumLineHeight);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTMaximumLineHeightAttribute)(CGFloat maximumLineHeight);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTBaseWritingDirectionAttribute)(NSWritingDirection baseWritingDirection);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTLineHeightMultipleAttribute)(CGFloat lineHeightMultiple);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTParagraphSpacingBeforeAttribute)(CGFloat paragraphSpacingBefore);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTHyphenationFactorAttribute)(float hyphenationFactor);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTTabStopsAttribute)(NSArray<NSTextTab *> *tabStops);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTDefaultTabIntervalAttribute)(CGFloat defaultTabInterval);
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTAllowsDefaultTighteningForTruncationAttribute)(BOOL allowsDefaultTighteningForTruncation) API_AVAILABLE(ios(9.0));
typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTLineBreakStrategyAttribute)(NSLineBreakStrategy lineBreakStrategy) API_AVAILABLE(ios(9.0));

typedef id<MSUTAttributesProtocol>_Nonnull(^MSUTSetAttribute)(id _Nullable value, NSString *forKey);

@protocol MSUTAttributesProtocol
// text attributes
@property (nonatomic, copy, readonly) MSUTFontAttribute font;
@property (nonatomic, copy, readonly) MSUTColorAttribute textColor;
@property (nonatomic, copy, readonly) MSUTColorAttribute backgroundColor;
@property (nonatomic, copy, readonly) MSUTKernAttribute kern;
@property (nonatomic, copy, readonly) MSUTShadowAttribute shadow;
@property (nonatomic, copy, readonly) MSUTStrokeAttribute stroke;
@property (nonatomic, copy, readonly) MSUTDecorationAttribute underLine;
@property (nonatomic, copy, readonly) MSUTDecorationAttribute strikethrough;
@property (nonatomic, copy, readonly) MSUTBaseLineOffsetAttribute baseLineOffset;

// paragraph attributes
@property (nonatomic, copy, readonly) MSUTLineSpacingAttribute lineSpacing;
@property (nonatomic, copy, readonly) MSUTParagraphSpacingAttribute paragraphSpacing;
@property (nonatomic, copy, readonly) MSUTAlignmentAttribute alignment;
@property (nonatomic, copy, readonly) MSUTFirstLineHeadIndentAttribute firstLineHeadIndent;
@property (nonatomic, copy, readonly) MSUTHeadIndentAttribute headIndent;
@property (nonatomic, copy, readonly) MSUTTailIndentAttribute tailIndent;
@property (nonatomic, copy, readonly) MSUTLineBreakModeAttribute lineBreakMode;
@property (nonatomic, copy, readonly) MSUTMinimumLineHeightAttribute minimumLineHeight;
@property (nonatomic, copy, readonly) MSUTMaximumLineHeightAttribute maximumLineHeight;
@property (nonatomic, copy, readonly) MSUTBaseWritingDirectionAttribute baseWritingDirection;
@property (nonatomic, copy, readonly) MSUTLineHeightMultipleAttribute lineHeightMultiple;
@property (nonatomic, copy, readonly) MSUTParagraphSpacingBeforeAttribute paragraphSpacingBefore;
@property (nonatomic, copy, readonly) MSUTHyphenationFactorAttribute hyphenationFactor;
@property (nonatomic, copy, readonly) MSUTTabStopsAttribute tabStops;
@property (nonatomic, copy, readonly) MSUTDefaultTabIntervalAttribute defaultTabInterval;
@property (nonatomic, copy, readonly) MSUTAllowsDefaultTighteningForTruncationAttribute allowsDefaultTighteningForTruncation API_AVAILABLE(ios(9.0));
@property (nonatomic, copy, readonly) MSUTLineBreakStrategyAttribute lineBreakStrategy API_AVAILABLE(ios(9.0));

// custom attributes
@property (nonatomic, copy, readonly) MSUTSetAttribute set; // 添加或删除自定义的attribute
@end

@protocol MSUTRangeHandlerProtocol
@property (nonatomic, copy, readonly) void(^update)(void(^)(id<MSUTAttributesProtocol> make));
@property (nonatomic, copy, readonly) void(^replaceWithText)(void(^)(id<MSUIKitTextMakerProtocol> make));
@property (nonatomic, copy, readonly) id<MSUTAttributesProtocol>(^replaceWithString)(NSString *string);
@end

@protocol MSUTRegexHandlerProtocol <MSUTRangeHandlerProtocol>
@property (nonatomic, copy, readonly) void(^handler)(void(^)(NSMutableAttributedString *attrStr, NSTextCheckingResult *result));

@property (nonatomic, copy, readonly) id<MSUTRegexHandlerProtocol>(^regularExpressionOptions)(NSRegularExpressionOptions ops);
@property (nonatomic, copy, readonly) id<MSUTRegexHandlerProtocol>(^matchingOptions)(NSMatchingOptions ops);
@end

@protocol MSUTStroke
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) float width;
@end

@protocol MSUTDecoration
@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic) NSUnderlineStyle style;
@end

typedef enum : NSUInteger {
    MSUTVerticalAlignmentDefault = 0,
    MSUTVerticalAlignmentCenter = 1,
} MSUTVerticalAlignment;

@protocol MSUTImageAttachment <NSObject>
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) MSUTVerticalAlignment alignment; ///< Text为统一的字体时生效
@property (nonatomic) CGRect bounds;
@end
NS_ASSUME_NONNULL_END
#endif /* MSUIKitAttributesDefines_h */
