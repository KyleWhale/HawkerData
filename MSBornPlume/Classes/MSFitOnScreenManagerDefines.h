//
//  MSFitOnScreenManagerDefines.h
//  MSBornPlume
//
//  Created by admin on 2018/12/31.
//

#ifndef MSFitOnScreenManagerProtocol_h
#define MSFitOnScreenManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol MSFitOnScreenManagerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol MSFitOnScreenManager <NSObject>
- (instancetype)initWithTarget:(__strong UIView *)target targetSuperview:(__strong UIView *)superview;
- (id<MSFitOnScreenManagerObserver>)getObserver;

@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) NSTimeInterval duration;

///
/// 是否已充满屏幕
///
@property (nonatomic, getter=isFitOnScreen) BOOL fitOnScreen;
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated;
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(id<MSFitOnScreenManager> mgr))completionHandler;

@property (nonatomic, strong, readonly) UIView *superviewInFitOnScreen;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@protocol MSFitOnScreenManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^fitOnScreenWillBeginExeBlock)(id<MSFitOnScreenManager> mgr);
@property (nonatomic, copy, nullable) void(^fitOnScreenDidEndExeBlock)(id<MSFitOnScreenManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* MSFitOnScreenManagerProtocol_h */
