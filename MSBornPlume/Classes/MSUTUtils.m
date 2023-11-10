//
//  MSUTUtils.m
//  LWZAudioModule-LWZAudioModule
//
//  Created by BlueDancer on 2020/12/2.
//

#import "MSUTUtils.h"
 
BOOL
MSUTRangeContains(NSRange main, NSRange sub) {
    return (main.location <= sub.location) && (main.location + main.length >= sub.location + sub.length);
}

NSRange
MSUTGetTextRange(NSAttributedString *text) {
    return NSMakeRange(0, text.length);
}
