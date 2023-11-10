//
//  MSSubtitleItem.h
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import <Foundation/Foundation.h>
#import "MSSubtitlePopupControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSSubtitleItem : NSObject<MSSubtitleItem>
- (instancetype)initWithContent:(NSAttributedString *)content range:(MSTimeRange)range;
- (instancetype)initWithContent:(NSAttributedString *)content start:(NSTimeInterval)start end:(NSTimeInterval)end;

@property (nonatomic, copy, readonly) NSAttributedString *content;
@property (nonatomic, readonly) MSTimeRange range;
@end
NS_ASSUME_NONNULL_END
