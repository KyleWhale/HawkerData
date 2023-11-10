//
//  MSSubtitleItem.m
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import "MSSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN
@implementation MSSubtitleItem
- (instancetype)initWithContent:(NSAttributedString *)content range:(MSTimeRange)range {
    self = [super init];
    if ( self ) {
        _content = content.copy;
        _range = range;
    }
    return self;
}

- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end {
    return [self initWithContent:content range:MSMakeTimeRange(start, end - start)];
}
@end
NS_ASSUME_NONNULL_END
