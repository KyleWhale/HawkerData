//
//  MSControlLayerAppearManagerDefines.h
//  MSBornPlume
//
//  Created by admin on 2018/12/31.
//

#ifndef MSControlLayerAppearManagerProtocol_h
#define MSControlLayerAppearManagerProtocol_h
#import <UIKit/UIKit.h>
@protocol MSControlLayerAppearManagerObserver;

NS_ASSUME_NONNULL_BEGIN
@protocol MSControlLayerAppearManager
- (id<MSControlLayerAppearManagerObserver>)getObserver;
@property (nonatomic, getter=isDisabled) BOOL disabled;         ///< 是否禁用显示管理类
@property (nonatomic) NSTimeInterval interval;                  ///< 控制层隐藏间隔, 默认5s

/// Appear state
@property (nonatomic, readonly) BOOL isAppeared;
- (void)switchAppearState;
- (void)needAppear;
- (void)needDisappear;

- (void)resume;
- (void)keepAppearState;
- (void)keepDisappearState;

@property (nonatomic, copy, nullable) BOOL(^canAutomaticallyDisappear)(id<MSControlLayerAppearManager> mgr);
@end

@protocol MSControlLayerAppearManagerObserver
@property (nonatomic, copy, nullable) void(^onAppearChanged)(id<MSControlLayerAppearManager> mgr);
@end
NS_ASSUME_NONNULL_END
#endif /* MSControlLayerAppearManagerProtocol_h */
