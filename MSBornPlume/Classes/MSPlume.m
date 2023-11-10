//
//  MSPlume.m
//  MSPlumeProject
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "MSPlume.h"
#import "UIView+MSAnimationAdded.h"
#import <objc/message.h>

#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#import <MSBornPlume/MSBornPlumeConst.h>
#import <MSBornPlume/MSReachability.h>
#import <MSBornPlume/UIView+MSBornPlumeExtended.h>
#import <MSBornPlume/NSTimer+MSAssetAdd.h>
#else
#import "MSReachability.h"
#import "MSBornPlume.h"
#import "MSBornPlumeConst.h"
#import "UIView+MSBornPlumeExtended.h"
#import "NSTimer+MSAssetAdd.h"
#endif

#if __has_include(<MSUIKit/MSAttributesFactory.h>)
#import <MSUIKit/MSAttributesFactory.h>
#else
#import "MSAttributesFactory.h"
#endif

#import "MSEdgeControlButtonItemInternal.h"

NS_ASSUME_NONNULL_BEGIN
#define MSEdgeControlLayerShowsMoreItemNotification @"MSEdgeControlLayerShowsMoreItemNotification"
#define MSEdgeControlLayerIsEnabledClipsNotification @"MSEdgeControlLayerIsEnabledClipsNotification"

@implementation MSEdgeControlLayer (MSPlumeExtended)
- (void)setShowsMoreItem:(BOOL)showsMoreItem {
    if ( showsMoreItem != self.showsMoreItem ) {
        objc_setAssociatedObject(self, @selector(showsMoreItem), @(showsMoreItem), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [NSNotificationCenter.defaultCenter postNotificationName:MSEdgeControlLayerShowsMoreItemNotification object:self];
    }
}

- (BOOL)showsMoreItem {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setEnabledClips:(BOOL)enabledClips {
    if ( enabledClips != self.isEnabledClips ) {
        objc_setAssociatedObject(self, @selector(isEnabledClips), @(enabledClips), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [NSNotificationCenter.defaultCenter postNotificationName:MSEdgeControlLayerIsEnabledClipsNotification object:self];
    }
}

- (BOOL)isEnabledClips {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

@interface MSPlume ()<MSMoreSettingControlLayerDelegate, MSNotReachableControlLayerDelegate, MSEdgeControlLayerDelegate>

@property (nonatomic, strong, readonly) id<MSControlLayerAppearManagerObserver> ms_appearManagerObserver;
@property (nonatomic, strong, readonly) id<MSControlLayerSwitcherObserver> ms_switcherObserver;

@property (nonatomic, strong, nullable) MSEdgeControlButtonItem *moreItem;
@property (nonatomic, strong, nullable) MSEdgeControlButtonItem *clipsItem;
@property (nonatomic, strong, nullable) MSEdgeControlButtonItem *definitionItem;

/// 用于断网之后(当网络恢复后使播放器自动恢复播放)
@property (nonatomic, strong, nullable) id<MSReachabilityObserver> ms_reachabilityObserver;
@property (nonatomic, strong, nullable) NSTimer *ms_timeoutTimer;
@property (nonatomic) BOOL ms_isTimeout;
@end

@implementation MSPlume
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
}

+ (NSString *)version {
    return @"v3.4.3";
}

+ (instancetype)shared {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [self _init];
    if ( !self ) return nil;
    [self.switcher switchControlLayerForIdentifier:MSControlLayer_Edge];   // 切换到添加的控制层
    self.defaultAdapter.showsMoreItem = YES;                      // 显示更多按钮
    return self;
}

// v2.4.0 之后删除了旧的lightweightPlayer控制层, 迁移至 defaultEdgeControlLayer
+ (instancetype)lightweightCode {
    MSPlume *plume = [[MSPlume alloc] _init];
    MSEdgeControlLayer *controlLayer = plume.defaultAdapter;
    controlLayer.hiddenBottomProgressIndicator = NO;
    controlLayer.topContainerView.sjv_disappearDirection =
    controlLayer.leftContainerView.sjv_disappearDirection =
    controlLayer.bottomContainerView.sjv_disappearDirection =
    controlLayer.rightContainerView.sjv_disappearDirection = MSViewDisappearAnimation_None;
    [controlLayer.topAdapter reload];
    [plume.switcher switchControlLayerForIdentifier:MSControlLayer_Edge];
    return plume;
}

- (instancetype)_init {
    self = [super init];
    if ( !self ) return nil;
    [self _observeNotifies];
    [self _initializeSwitcher];
    [self _initializeSwitcherObserver];
    [self _initializeSettingsObserver];
    [self _initializeAppearManagerObserver];
    [self _initializeReachabilityObserver];
    [self _configurationsDidUpdate];
    return self;
}

///
/// 点击了控制层右上角的更多按钮(三个点)
///
- (void)_moreItemWasTapped:(MSEdgeControlButtonItem *)moreItem {
    [self.switcher switchControlLayerForIdentifier:MSControlLayer_More];
}

///
/// 点击了返回按钮
///
- (void)_backButtonWasTapped {
    if ( self.iFurry && ![self _whetherToSupportOnlyOneOrientation] ) {
        [self rotate];
    }
    else if ( self.isFitOnScreen ) {
        self.fitOnScreen = NO;
    }
    else {
        UIViewController *vc = [self.view lookupResponderForClass:UIViewController.class];
        [vc.view endEditing:YES];
        if ( vc.navigationController.viewControllers.count > 1 ) {
            [vc.navigationController popViewControllerAnimated:YES];
        }
        else {
            vc.presentingViewController ? [vc dismissViewControllerAnimated:YES completion:nil] :
                                          [vc.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
///
/// 点击了控制层空白区域
///
- (void)tappedBlankAreaOnTheControlLayer:(id<MSControlLayer>)controlLayer {
    [self.switcher switchToPreviousControlLayer];
}

///
/// 点击了控制层上的返回按钮
///
- (void)backItemWasTappedForControlLayer:(id<MSControlLayer>)controlLayer {
    [self _backButtonWasTapped];
}

///
/// 点击了控制层上的刷新按钮
///
- (void)reloadItemWasTappedForControlLayer:(id<MSControlLayer>)controlLayer {
    [self refresh];
    [self.switcher switchControlLayerForIdentifier:MSControlLayer_Edge];
}

#pragma mark -

@synthesize defaultAdapter = _defaultAdapter;
- (MSEdgeControlLayer *)defaultAdapter {
    if ( !_defaultAdapter ) {
        _defaultAdapter = [MSEdgeControlLayer new];
        _defaultAdapter.delegate = self;
    }
    return _defaultAdapter;
}

@synthesize defaultMoreSettingControlLayer = _defaultMoreSettingControlLayer;
- (MSMoreSettingControlLayer *)defaultMoreSettingControlLayer {
    if ( !_defaultMoreSettingControlLayer ) {
        _defaultMoreSettingControlLayer = [MSMoreSettingControlLayer new];
        _defaultMoreSettingControlLayer.delegate = self;
    }
    return _defaultMoreSettingControlLayer;
}

@synthesize defaultLoadFailedControlLayer = _defaultLoadFailedControlLayer;
- (MSLoadFailedControlLayer *)defaultLoadFailedControlLayer {
    if ( !_defaultLoadFailedControlLayer ) {
        _defaultLoadFailedControlLayer = [MSLoadFailedControlLayer new];
        _defaultLoadFailedControlLayer.delegate = self;
    }
    return _defaultLoadFailedControlLayer;
}

@synthesize defaultNotReachableControlLayer = _defaultNotReachableControlLayer;
- (MSNotReachableControlLayer *)defaultNotReachableControlLayer {
    if ( !_defaultNotReachableControlLayer ) {
        _defaultNotReachableControlLayer = [[MSNotReachableControlLayer alloc] initWithFrame:self.view.bounds];
        _defaultNotReachableControlLayer.delegate = self;
    }
    return _defaultNotReachableControlLayer;
}

#pragma mark -

// - initialize -

- (void)_observeNotifies {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:MSPlumePlumeStateDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resumeOrStopTimeoutTimer) name:MSPlumePlumeStateDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:MSPlumeAssetStatusDidChangeNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_switchControlLayerIfNeeded) name:MSPlumePlaybackDidFinishNotification object:self];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_configurationsDidUpdate) name:MSPlumeConfigurationsDidUpdateNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_showsMoreItemWithNote:) name:MSEdgeControlLayerShowsMoreItemNotification object:nil];
}

- (void)_initializeSwitcher {
    _switcher = [[MSControlLayerSwitcher alloc] initWithPlayer:self];
    __weak typeof(self) _self = self;
    _switcher.resolveControlLayer = ^id<MSControlLayer> _Nullable(MSControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        if ( identifier == MSControlLayer_Edge )
            return self.defaultAdapter;
        else if ( identifier == MSControlLayer_NotReachableAndPlaybackStalled )
            return self.defaultNotReachableControlLayer;
        else if ( identifier == MSControlLayer_More )
            return self.defaultMoreSettingControlLayer;
        else if ( identifier == MSControlLayer_LoadFailed )
            return self.defaultLoadFailedControlLayer;
        return nil;
    };
}

- (void)_initializeSwitcherObserver {
    _ms_switcherObserver = [_switcher getObserver];
    __weak typeof(self) _self = self;
    _ms_switcherObserver.playerWillBeginSwitchControlLayer = ^(id<MSControlLayerSwitcher>  _Nonnull switcher, id<MSControlLayer>  _Nonnull controlLayer) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [controlLayer respondsToSelector:@selector(setHiddenBackButtonWhenOrientationIsPortrait:)] ) {
            [(MSEdgeControlLayer *)controlLayer setHiddenBackButtonWhenOrientationIsPortrait:self.defaultAdapter.isHiddenBackButtonWhenOrientationIsPortrait];
        }
    };
}

- (void)_initializeSettingsObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_configurationsDidUpdate) name:MSPlumeConfigurationsDidUpdateNotification object:nil];
}

- (void)_configurationsDidUpdate {
    if ( self.presentView.placeholderImageView.image == nil )
        self.presentView.placeholderImageView.image = MSPlumeConfigurations.shared.resources.placeholder;
    
    if ( _moreItem != nil )
        _moreItem.image = MSPlumeConfigurations.shared.resources.moreImage;
    
    if ( _clipsItem != nil )
        _clipsItem.image = MSPlumeConfigurations.shared.resources.clipsImage;
}

// 播放器当前是否只支持一个方向
- (BOOL)_whetherToSupportOnlyOneOrientation {
    if ( self.rotationManager.autorotationSupportedOrientations == MSOrientationMaskPortrait ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == MSOrientationMaskLandscapeLeft ) return YES;
    if ( self.rotationManager.autorotationSupportedOrientations == MSOrientationMaskLandscapeRight ) return YES;
    return NO;
}

- (void)_resumeOrStopTimeoutTimer {
    if ( self.isBuffering || self.isEvaluating ) {
        if ( MSReachability.shared.networkStatus == MSNetworkStatus_NotReachable && _ms_timeoutTimer == nil ) {
            __weak typeof(self) _self = self;
            _ms_timeoutTimer = [NSTimer ms_timerWithTimeInterval:3 repeats:YES usingBlock:^(NSTimer * _Nonnull timer) {
                [timer invalidate];
                __strong typeof(_self) self = _self;
                if ( !self ) return;
#ifdef DEBUG
                NSLog(@"%d \t %s \t 网络超时, 切换到无网控制层!", (int)__LINE__, __func__);
#endif
                self.ms_isTimeout = YES;
                [self _switchControlLayerIfNeeded];
            }];
            [_ms_timeoutTimer ms_fire];
            [NSRunLoop.mainRunLoop addTimer:_ms_timeoutTimer forMode:NSRunLoopCommonModes];
        }
    }
    else if ( _ms_timeoutTimer != nil ) {
        [_ms_timeoutTimer invalidate];
        _ms_timeoutTimer = nil;
        self.ms_isTimeout = NO;
    }

}

- (void)_switchControlLayerIfNeeded {
    // 资源出错时
    // - 发生错误时, 切换到加载失败控制层
    //
    if ( self.aspect == MSAssetStatusFailed ) {
        [self.switcher switchControlLayerForIdentifier:MSControlLayer_LoadFailed];
    }
    // 当处于缓冲状态时
    // - 当前如果没有网络, 则切换到无网空制层
    //
    else if ( self.ms_isTimeout ) {
        [self.switcher switchControlLayerForIdentifier:MSControlLayer_NotReachableAndPlaybackStalled];
    }
    else {
        if ( self.switcher.currentIdentifier == MSControlLayer_LoadFailed ||
             self.switcher.currentIdentifier == MSControlLayer_NotReachableAndPlaybackStalled ) {
            [self.switcher switchControlLayerForIdentifier:MSControlLayer_Edge];
        }
    }
}

- (void)_initializeAppearManagerObserver {
    _ms_appearManagerObserver = [self.controlLayerAppearManager getObserver];
    
    __weak typeof(self) _self = self;
    _ms_appearManagerObserver.onAppearChanged = ^(id<MSControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        // refresh edge button items
        if ( self.switcher.currentIdentifier == MSControlLayer_Edge ) {
            [self _updateAppearStateForMoteItemIfNeeded];
            [self _updateAppearStateForClipsItemIfNeeded];
        }
    };
}

- (void)_initializeReachabilityObserver {
    _ms_reachabilityObserver = [self.reachability getObserver];
    __weak typeof(self) _self = self;
    _ms_reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<MSReachability>  _Nonnull r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( r.networkStatus == MSNetworkStatus_NotReachable ) {
            [self _resumeOrStopTimeoutTimer];
        }
        else if ( self.switcher.currentIdentifier == MSControlLayer_NotReachableAndPlaybackStalled ) {
#ifdef DEBUG
            NSLog(@"%d \t %s \t 网络恢复, 将刷新资源, 使播放器恢复播放!", (int)__LINE__, __func__);
#endif
            [self refresh];
        }
    };
}
 
- (void)_updateAppearStateForMoteItemIfNeeded {
    if ( _moreItem != nil ) {
        BOOL isHidden = NO;
        // 如果已经显示, 则小屏的时候隐藏;
        if ( !self.moreItem.isHidden ) isHidden = !self.iFurry;
        else isHidden = !(self.iFurry && !self.rotationManager.isRotating);
        
        if ( isHidden != self.moreItem.isHidden ) {
            self.moreItem.innerHidden = isHidden;
            [self.defaultAdapter.topAdapter reload];
        }
    }
}

- (void)_showsMoreItemWithNote:(NSNotification *)note {
    if ( self.defaultAdapter == note.object ) {
        if ( self.defaultAdapter.showsMoreItem ) {
            if ( _moreItem == nil ) {
                _moreItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSEdgeControlLayerTopItem_More];
                _moreItem.image = MSPlumeConfigurations.shared.resources.moreImage;
                [_moreItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_moreItemWasTapped:)]];
                [_defaultAdapter.topAdapter addItem:_moreItem];
            }
            [self _updateAppearStateForMoteItemIfNeeded];
        }
        else {
            _defaultMoreSettingControlLayer = nil;
            _moreItem = nil;
            [_defaultAdapter.topAdapter removeItemForTag:MSEdgeControlLayerTopItem_More];
            [_defaultAdapter.topAdapter reload];
            [self.switcher deleteControlLayerForIdentifier:MSControlLayer_More];
        }
    }
}

- (void)_updateAppearStateForClipsItemIfNeeded {
    if ( _clipsItem != nil ) {
        // clips item
        // M3u8 暂时无法剪辑
        // 小屏或者 M3U8的时候 自动隐藏
        BOOL isUnsupportedFormat = self.resource.iSpecial;
        BOOL isHidden = (self.resource == nil) || !self.iFurry || isUnsupportedFormat;
        if ( isHidden != _clipsItem.isHidden ) {
            _clipsItem.innerHidden = isHidden;
            [_defaultAdapter.rightAdapter reload];
        }
    }
}

@end


@implementation MSPlume (CommonSettings)
+ (void (^)(void (^ _Nonnull)(MSPlumeConfigurations * _Nonnull)))update {
    return MSPlumeConfigurations.update;
}

+ (void (^)(NSBundle * _Nonnull))setLocalizedStrings {
    return ^(NSBundle *bundle) {
        MSPlumeConfigurations.update(^(MSPlumeConfigurations * _Nonnull configs) {
            [configs.localizedStrings setFromBundle:bundle];
        });
    };
}

+ (void (^)(void (^ _Nonnull)(id<MSPlumeLocalizedStrings> _Nonnull)))updateLocalizedStrings {
    return ^(void(^block)(id<MSPlumeLocalizedStrings> strings)) {
        MSPlumeConfigurations.update(^(MSPlumeConfigurations * _Nonnull configs) {
            block(configs.localizedStrings);
        });
    };
}

+ (void (^)(void (^ _Nonnull)(id<MSPlumeControlLayerResources> _Nonnull)))updateResources {
    return ^(void(^block)(id<MSPlumeControlLayerResources> resources)) {
        MSPlumeConfigurations.update(^(MSPlumeConfigurations * _Nonnull configs) {
            block(configs.resources);
        });
    };
}
@end

@implementation MSPlume (RotationOrFitOnScreen)
- (void)setAutomaticallyPerformRotationOrFitOnScreen:(BOOL)automaticallyPerformRotationOrFitOnScreen {
    self.defaultAdapter.automaticallyPerformRotationOrFitOnScreen = automaticallyPerformRotationOrFitOnScreen;
}
- (BOOL)automaticallyPerformRotationOrFitOnScreen {
    return self.defaultAdapter.automaticallyPerformRotationOrFitOnScreen;
}

- (void)setNeedsFitOnScreenFirst:(BOOL)needsFitOnScreenFirst {
    self.defaultAdapter.needsFitOnScreenFirst = needsFitOnScreenFirst;
}
- (BOOL)needsFitOnScreenFirst {
    return self.defaultAdapter.needsFitOnScreenFirst;
}
@end


@implementation MSPlume (MSExtendedControlLayerSwitcher)
- (void)switchControlLayerForIdentifier:(MSControlLayerIdentifier)identifier {
    [self.switcher switchControlLayerForIdentifier:identifier];
}
@end

NS_ASSUME_NONNULL_END
