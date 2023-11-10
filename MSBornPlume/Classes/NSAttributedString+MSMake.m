//
//  NSAttributedString+MSMake.m
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "NSAttributedString+MSMake.h"
#import "MSUIKitTextMaker.h"

NS_ASSUME_NONNULL_BEGIN
@implementation NSAttributedString (MSMake)
+ (instancetype)ms_UIKitText:(void(^NS_NOESCAPE)(id<MSUIKitTextMakerProtocol> make))block {
    MSUIKitTextMaker *maker = [MSUIKitTextMaker new];
    block(maker);
    return maker.install;
}

- (CGSize)ms_textSize {
    return [self ms_textSizeForPreferredMaxLayoutWidth:CGFLOAT_MAX];
}
- (CGSize)ms_textSizeForRange:(NSRange)range {
    if ( range.length < 1 || range.length > self.length )
        return CGSizeZero;
    return ms_textSize([self attributedSubstringFromRange:range], CGFLOAT_MAX, CGFLOAT_MAX);
}
- (CGSize)ms_textSizeForPreferredMaxLayoutWidth:(CGFloat)width {
    return ms_textSize(self, width, CGFLOAT_MAX);
}
- (CGSize)ms_textSizeForPreferredMaxLayoutHeight:(CGFloat)height {
    return ms_textSize(self, CGFLOAT_MAX, height);
}
 
static CGSize
ms_textSize(NSAttributedString *attrStr, CGFloat width, CGFloat height) {
    if ( attrStr.length < 1 )
        return CGSizeZero;
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end
NS_ASSUME_NONNULL_END
