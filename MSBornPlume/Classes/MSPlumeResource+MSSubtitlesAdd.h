//
//  MSPlumeResource+MSSubtitlesAdd.h
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import "MSPlumeResource.h"
#import "MSSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSPlumeResource (MSSubtitlesAdd)
///
/// 未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<MSSubtitleItem *> *subtitles;

@end

NS_ASSUME_NONNULL_END
