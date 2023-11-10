//
//  MSFlipTransitionManagerDefines.h
//  Pods
//
//  Created by admin on 2018/12/31.
//

#ifndef MSFlipTransitionManagerProtocol_h
#define MSFlipTransitionManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol MSFlipTransitionManagerObserver;

typedef NS_ENUM(NSUInteger, MSViewFlipTransition) {
    MSViewFlipTransition_Identity,
    MSViewFlipTransition_Horizontally, // 水平翻转
};

NS_ASSUME_NONNULL_BEGIN
@protocol MSFlipTransitionManager <NSObject>
- (instancetype)initWithTarget:(__strong UIView *)target;
- (id<MSFlipTransitionManagerObserver>)getObserver;

@property (nonatomic, readonly, getter=isTransitioning) BOOL transitioning;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic) MSViewFlipTransition flipTransition;
- (void)setFlipTransition:(MSViewFlipTransition)t animated:(BOOL)animated;
- (void)setFlipTransition:(MSViewFlipTransition)t animated:(BOOL)animated completionHandler:(void(^_Nullable)(id<MSFlipTransitionManager> mgr))completionHandler;

@property (nonatomic, strong, nullable) UIView *target;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new  NS_UNAVAILABLE;
@end


@protocol MSFlipTransitionManagerObserver <NSObject>
@property (nonatomic, copy, nullable) void(^flipTransitionDidStartExeBlock)(id<MSFlipTransitionManager> mgr);
@property (nonatomic, copy, nullable) void(^flipTransitionDidStopExeBlock)(id<MSFlipTransitionManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* MSFlipTransitionManagerProtocol_h */
