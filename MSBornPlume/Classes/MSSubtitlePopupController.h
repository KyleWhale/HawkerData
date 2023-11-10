//
//  MSSubtitlePopupController.h
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import "MSSubtitlePopupControllerDefines.h"
#import "MSSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSSubtitlePopupController : NSObject<MSSubtitlePopupController>

///
/// 设置未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<MSSubtitleItem *> *subtitles;

///
/// 内容可显示几行
///
///     default value is 0
///
@property (nonatomic) NSInteger numberOfLines;

///
/// 设置内边距
///
///     default value is zero
///
@property (nonatomic) UIEdgeInsets contentInsets;

@end
NS_ASSUME_NONNULL_END
