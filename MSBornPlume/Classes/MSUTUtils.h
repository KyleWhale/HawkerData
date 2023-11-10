//
//  MSUTUtils.h
//  LWZAudioModule-LWZAudioModule
//
//  Created by BlueDancer on 2020/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT BOOL
MSUTRangeContains(NSRange main, NSRange sub);

FOUNDATION_EXPORT NSRange
MSUTGetTextRange(NSAttributedString *text);

NS_ASSUME_NONNULL_END
