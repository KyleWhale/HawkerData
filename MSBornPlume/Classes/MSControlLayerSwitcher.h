//
//  MSControlLayerSwitcher.h
//  MSPlumeProject
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSControlLayerDefines.h"
#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#else
#import "MSBornPlume.h"
#endif
@protocol MSControlLayerSwitcherObserver, MSControlLayerSwitcherDelegate;

NS_ASSUME_NONNULL_BEGIN
extern MSControlLayerIdentifier MSControlLayer_Uninitialized;

/// - 控制层切换器 switcher -
///
/// - 使用示例请查看`MSPlume`的`init`方法.
@protocol MSControlLayerSwitcher <NSObject>
- (instancetype)initWithPlayer:(__weak MSBornPlume *)player;

/// 切换控制层
///
/// - 将当前的控制层切换为指定标识的控制层
- (void)switchControlLayerForIdentifier:(MSControlLayerIdentifier)identifier;
- (BOOL)switchToPreviousControlLayer;

/// 添加或替换原有控制层
///
/// - 控制层将在第一次切换时创建, 该控制层只会被创建一次
- (void)addControlLayerForIdentifier:(MSControlLayerIdentifier)identifier
                         lazyLoading:(nullable id<MSControlLayer>(^)(MSControlLayerIdentifier identifier))loading;

/// 删除控制层
- (void)deleteControlLayerForIdentifier:(MSControlLayerIdentifier)identifier;

/// 是否已存在
- (BOOL)containsControlLayer:(MSControlLayerIdentifier)identifier;

/// 获取某个控制层
///
/// - 如果不存在, 将返回 nil
- (nullable id<MSControlLayer>)controlLayerForIdentifier:(MSControlLayerIdentifier)identifier;

/// 获取一个切换器观察者
///
/// - 你需要对它强引用, 否则会被释放
- (id<MSControlLayerSwitcherObserver>)getObserver;

/// 当`switchControlLayerForIdentifier:`无对应的控制层时, 该block将会被调用
@property (nonatomic, copy, nullable) id<MSControlLayer> _Nullable (^resolveControlLayer)(MSControlLayerIdentifier identifier);

@property (nonatomic, weak, nullable) id<MSControlLayerSwitcherDelegate> delegate;
@property (nonatomic, readonly) MSControlLayerIdentifier previousIdentifier;
@property (nonatomic, readonly) MSControlLayerIdentifier currentIdentifier;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end


@interface MSControlLayerSwitcher : NSObject<MSControlLayerSwitcher>

@end

@protocol MSControlLayerSwitcherDelegate <NSObject>
@optional
- (BOOL)switcher:(id<MSControlLayerSwitcher>)switcher shouldSwitchToControlLayer:(MSControlLayerIdentifier)identifier;
- (nullable id<MSControlLayer>)switcher:(id<MSControlLayerSwitcher>)switcher controlLayerForIdentifier:(MSControlLayerIdentifier)identifier;
@end

// - observer -
@protocol MSControlLayerSwitcherObserver <NSObject>
@property (nonatomic, copy, nullable) void(^playerWillBeginSwitchControlLayer)(id<MSControlLayerSwitcher> switcher, id<MSControlLayer> controlLayer);
@property (nonatomic, copy, nullable) void(^playerDidEndSwitchControlLayer)(id<MSControlLayerSwitcher> switcher, id<MSControlLayer> controlLayer);
@end
NS_ASSUME_NONNULL_END
