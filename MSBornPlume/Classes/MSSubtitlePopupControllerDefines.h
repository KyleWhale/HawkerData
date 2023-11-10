//
//  MSSubtitlePopupControllerDefines.h
//  Pods
//
//  Created by admin on 2019/11/8.
//

#ifndef MSSubtitlePopupControllerDefines_h
#define MSSubtitlePopupControllerDefines_h
#include <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MSSubtitleItem;
@class UIColor;

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    NSTimeInterval start;
    NSTimeInterval duration;
} MSTimeRange;

static inline MSTimeRange
MSMakeTimeRange(NSTimeInterval start, NSTimeInterval duration) {
    return (MSTimeRange){start, duration};
}

static inline BOOL
MSTimeRangeContainsTime(NSTimeInterval time, MSTimeRange range) {
    return (!(time < range.start) && (time - range.start) < range.duration) ? YES : NO;
}

@protocol MSSubtitlePopupController <NSObject>

///
/// 设置未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<id<MSSubtitleItem>> *subtitles;

///
/// 内容可显示几行
///
///     default value is 0
///
@property (nonatomic) NSInteger numberOfLines;

/// 设置内边距
///
///     default value is zero
///
@property (nonatomic) UIEdgeInsets contentInsets;

@property (nonatomic, strong, readonly) UIView *view;

///
/// 以下属性由播放器维护, 开发者无需设置
///
@property (nonatomic) NSTimeInterval currentTime;
@end


@protocol MSSubtitleItem <NSObject>
- (instancetype)initWithContent:(NSAttributedString *)content range:(MSTimeRange)range;
- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end;
@property (nonatomic, copy, readonly) NSAttributedString *content;
@property (nonatomic, readonly) MSTimeRange range;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END

#endif /* MSSubtitlePopupControllerDefines_h */
