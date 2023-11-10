//
//  MSPlumeResource+MSSubtitlesAdd.m
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import "MSPlumeResource+MSSubtitlesAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation MSPlumeResource (MSSubtitlesAdd)
- (void)setSubtitles:(nullable NSArray<MSSubtitleItem *> *)subtitles {
    objc_setAssociatedObject(self, @selector(var_asubtitles), subtitles, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable NSArray<MSSubtitleItem *> *)subtitles {
    return objc_getAssociatedObject(self, _cmd);
}
@end
NS_ASSUME_NONNULL_END
