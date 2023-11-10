//
//  NSAttributedString+MSMake.h
//  AttributesFactory
//
//  Created by admin on 2019/4/12.
//  Copyright © 2019 SanJiang. All rights reserved.
//
//  Project: https://github.com/changsanjiang/MSAttributesFactory
//  Email:  changsanjiang@gmail.com
//

#import <Foundation/Foundation.h>
#import "MSUIKitAttributesDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSAttributedString (MSMake)
/**
 * - make attributed string:
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
+ (instancetype)ms_UIKitText:(void(^NS_NOESCAPE)(id<MSUIKitTextMakerProtocol> make))block;

- (CGSize)ms_textSize;
- (CGSize)ms_textSizeForRange:(NSRange)range;
- (CGSize)ms_textSizeForPreferredMaxLayoutWidth:(CGFloat)width;
- (CGSize)ms_textSizeForPreferredMaxLayoutHeight:(CGFloat)height;
@end
NS_ASSUME_NONNULL_END
