//
//  AVAsset+MSResourceExport.h
//  MSPlume
//
//  Created by admin on 2018/2/2.
//  Copyright © 2019 admin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AVAsset (MSResourceExport)
// - preview images -
- (void)ms_generatePreviewImagesWithMaxItemSize:(CGSize)itemSize
                                          count:(NSUInteger)count
                              completionHandler:(void(^)(AVAsset *a, NSArray<UIImage *> *_Nullable images, NSError *_Nullable error))block;

- (void)ms_cancelGeneratePreviewImages;

// - export -
/// preset name default is `AVAssetExportPresetMediumQuality`.
- (void)ms_exportWithStartTime:(NSTimeInterval)secs0
                      duration:(NSTimeInterval)secs1
                        toFile:(NSURL *)fileURL
                    presetName:(nullable NSString *)presetName
                      progress:(nullable void(^)(AVAsset *a, float progress))progressBlock
                       success:(nullable void(^)(AVAsset *a, AVAsset * __nullable sandboxAsset, NSURL * __nullable fileURL, UIImage * __nullable thumbImage))successBlock
                       failure:(nullable void(^)(AVAsset *a, NSError * __nullable error))failureBlock;

- (void)ms_cancelExportOperation;

// - screenshot -
- (UIImage * __nullable)ms_screenshotWithTime:(CMTime)time;

- (void)ms_screenshotWithTime:(NSTimeInterval)time
            completionHandler:(void(^)(AVAsset *a, UIImage * __nullable images, NSError *__nullable error))block;

- (void)ms_screenshotWithTime:(NSTimeInterval)time
                         size:(CGSize)size
            completionHandler:(void(^)(AVAsset *a, UIImage * __nullable image, NSError *__nullable error))block;

- (void)ms_cancelScreenshotOperation;

// - GIF -
/// interval: The interval at which the image is captured, Recommended setting 0.1f.
- (void)ms_generateGIFWithBeginTime:(NSTimeInterval)beginTime
                           duration:(NSTimeInterval)duration
                       imageMaxSize:(CGSize)size
                           interval:(float)interval
                             toFile:(NSURL *)fileURL
                           progress:(void(^)(AVAsset *a, float progress))progressBlock
                            success:(void(^)(AVAsset *a, UIImage *GIFImage, UIImage *thumbnailImage))successBlock
                            failure:(void(^)(AVAsset *a, NSError *error))failureBlock;
- (void)ms_cancelGenerateGIFOperation;
@end
NS_ASSUME_NONNULL_END
