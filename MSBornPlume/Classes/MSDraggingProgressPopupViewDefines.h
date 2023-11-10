//
//  MSDraggingProgressPopupViewDefines.h
//  Pods
//
//  Created by admin on 2019/11/27.
//

#ifndef MSDraggingProgressPopupViewDefines_h
#define MSDraggingProgressPopupViewDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MSDraggingProgressPopupViewStyle) {
    MSDraggingProgressPopupViewStyleNormal,
    MSDraggingProgressPopupViewStyleFullscreen,
    MSDraggingProgressPopupViewStyleFitOnScreen
};

@protocol MSDraggingProgressPopupView <NSObject>
@property (nonatomic) MSDraggingProgressPopupViewStyle style;
@property (nonatomic) NSTimeInterval dragTime;  ///< 拖拽到的时间
@property (nonatomic) NSTimeInterval currentTime;   ///< 当前播放到的时间
@property (nonatomic) NSTimeInterval duration;      ///< 播放时长

///
/// 当需要显示预览时, 可以返回NO, 管理类将会设置previewImage
///
@property (nonatomic, readonly, getter=isPreviewImageHidden) BOOL previewImageHidden;
@property (nonatomic, strong, nullable) UIImage *previewImage;
@end
NS_ASSUME_NONNULL_END

#endif /* MSDraggingProgressPopupViewDefines_h */
