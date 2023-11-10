//
//  MSScrollingTextMarqueeViewDefines.h
//  Pods
//
//  Created by admin on 2019/12/7.
//

#ifndef MSScrollingTextMarqueeViewDefines_h
#define MSScrollingTextMarqueeViewDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
///
/// 滚动标题
///
@protocol MSScrollingTextMarqueeView <NSObject>
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;
@property (nonatomic) CGFloat margin;

@property (nonatomic, readonly, getter=isScrolling) BOOL scrolling;
@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled; ///< default value is YES
@property (nonatomic, getter=isCentered) BOOL centered; ///< default value is NO. 标题太短无法滚动时, 是否居中显示
@end
NS_ASSUME_NONNULL_END

#endif /* MSScrollingTextMarqueeViewDefines_h */
