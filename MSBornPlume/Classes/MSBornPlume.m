//
//  MSBornPlume.m
//  MSBornPlumeProject
//
//  Created by admin on 2018/2/2.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "MSBornPlume.h"
#import <objc/message.h>
#import "MSRotationManager.h"
#import "MSDeviceVolumeAndBrightnessController.h"
#import "MSDeviceVolumeAndBrightnessTargetViewContext.h"
#import "MSPlumeRegistrar.h"
#import "MSPlumePresentView.h"
#import "MSTimerControl.h"
#import "MSResourcePlaybackController.h"
#import "MSReachability.h"
#import "MSControlLayerAppearStateManager.h"
#import "MSFitOnScreenManager.h"
#import "MSFlipTransitionManager.h"
#import "MSCharmView.h"
#import "MSBornPlumeConst.h"
#import "MSSubtitlePopupController.h"
#import "MSPlumeResource+MSSubtitlesAdd.h"
#import "MSViewControllerManager.h"
#import "UIView+MSBornPlumeExtended.h"
#import "NSString+MSBornPlumeExtended.h"
#import "MSCharmViewInternal.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
typedef struct _SJCharmControlInfo {
    struct {
        CGFloat factor;
        NSTimeInterval offsetTime; ///< pan手势触发过程中的偏移量(secs)
    } pan;
    
    struct {
        CGFloat initialRate;
    } longPress;
    
    struct {
        MSCharmGestureTypeMask disabledGestures;
        CGFloat rateWhenLongPressGestureTriggered;
        BOOL allowHorizontalTriggeringOfPanGesturesInCells;
    } gestureController;

    struct {
        BOOL automaticallyHides;
        NSTimeInterval delayHidden;
    } placeholder;
    
    struct {
        BOOL isScrollAppeared;
        BOOL pausedWhenScrollDisappeared;
        BOOL hiddenPlayerViewWhenScrollDisappeared;
        BOOL resumePlaybackWhenScrollAppeared;
    } scrollControl;
    
    struct {
        BOOL disableBrightnessSetting;
        BOOL disableVolumeSetting;
    } deviceVolumeAndBrightness;
    
    struct {
        BOOL accurateSeeking;
        BOOL autoplayWhenSetNewAsset;
        BOOL resumePlaybackWhenAppDidEnterForeground;
        BOOL resumePlaybackWhenPlayerHasFinishedSeeking;
        BOOL isUserPaused;
    } playbackControl;
    
    struct {
        BOOL pausedToKeepAppearState;
    } controlLayer;
    
    struct {
        BOOL isEnabled;
    } audioSessionControl;
        
} _SJCharmControlInfo;

@interface MSBornPlume ()<MSPlumePresentViewDelegate, MSCharmViewDelegate>
@property (nonatomic) _SJCharmControlInfo *controlInfo;

/// - 管理对象: 监听 App在前台, 后台, 耳机插拔, 来电等的通知
@property (nonatomic, strong, readonly) MSPlumeRegistrar *registrar;

@property (nonatomic, strong) MSViewControllerManager *viewControllerManager;

@end

@implementation MSBornPlume {
    MSCharmView *_view;
    
    ///
    /// 视频画面的呈现层
    ///
    MSPlumePresentView *_presentView;
    
    MSPlumeRegistrar *_registrar;
    
    /// 当前资源是否播放过
    /// mpc => Media Playback Controller
    id<MSPlumeResourceObserver> _Nullable _mpc_assetObserver;
    
    /// device volume And brightness manager
    id<MSDeviceVolumeAndBrightnessController> _deviceVolumeAndBrightnessController;
    MSDeviceVolumeAndBrightnessTargetViewContext *_deviceVolumeAndBrightnessTargetViewContext;
    id<MSDeviceVolumeAndBrightnessControllerObserver> _deviceVolumeAndBrightnessControllerObserver;

    /// playback controller
    NSError *_Nullable _error;
    id<MSPlumePlaybackController> _playbackController;
    MSPlumeResource *_resource;
    
    /// control layer appear manager
    id<MSControlLayerAppearManager> _controlLayerAppearManager;
    id<MSControlLayerAppearManagerObserver> _controlLayerAppearManagerObserver;
    
    /// rotation manager
    id<MSRotationManager> _rotationManager;
    id<MSRotationManagerObserver> _rotationManagerObserver;
    
    /// Fit on screen manager
    id<MSFitOnScreenManager> _fitOnScreenManager;
    id<MSFitOnScreenManagerObserver> _fitOnScreenManagerObserver;
    
    /// Flip Transition manager
    id<MSFlipTransitionManager> _flipTransitionManager;
    
    /// Network status
    id<MSReachability> _reachability;
    id<MSReachabilityObserver> _reachabilityObserver;
        
    id<MSSubtitlePopupController> _Nullable _subtitlePopupController;
    
    AVAudioSessionCategory _mCategory;
    AVAudioSessionCategoryOptions _mCategoryOptions;
    AVAudioSessionSetActiveOptions _mSetActiveOptions;
}

+ (instancetype)shared {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"v0.0.1";
}

- (void)setSpGravity:(MSSPGravity)spGravity {
    self.playbackController.spGravity = spGravity;
}
- (MSSPGravity)spGravity {
    return self.playbackController.spGravity;
}

- (nullable __kindof UIViewController *)atViewController {
    return [_presentView lookupResponderForClass:UIViewController.class];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _controlInfo = (_SJCharmControlInfo *)calloc(1, sizeof(struct _SJCharmControlInfo));
    _controlInfo->placeholder.automaticallyHides = YES;
    _controlInfo->placeholder.delayHidden = 0.8;
    _controlInfo->scrollControl.pausedWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = YES;
    _controlInfo->playbackControl.autoplayWhenSetNewAsset = YES;
    _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking = YES;
    _controlInfo->gestureController.rateWhenLongPressGestureTriggered = 2.0;
    _controlInfo->audioSessionControl.isEnabled = YES;
    _controlInfo->pan.factor = 667;
    _mCategory = AVAudioSessionCategoryPlayback;
    _mSetActiveOptions = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    
    [self _setupViews];
    [self performSelectorOnMainThread:@selector(_prepare) withObject:nil waitUntilDone:NO];
    return self;
}

- (void)_prepare {
    [self fitOnScreenManager];
    if ( !self.onlyFitOnScreen ) [self rotationManager];
    [self controlLayerAppearManager];
    [self deviceVolumeAndBrightnessController];
    [self registrar];
    [self reachability];
    [self gestureController];
    [self _setupViewControllerManager];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    _deviceVolumeAndBrightnessTargetViewContext = [MSDeviceVolumeAndBrightnessTargetViewContext.alloc init];
    _deviceVolumeAndBrightnessTargetViewContext.isFullscreen = _rotationManager.isFullscreen;
    _deviceVolumeAndBrightnessTargetViewContext.isFitOnScreen = _fitOnScreenManager.isFitOnScreen;
    _deviceVolumeAndBrightnessController.targetViewContext = _deviceVolumeAndBrightnessTargetViewContext;
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    [NSNotificationCenter.defaultCenter postNotificationName:MSPlumePlaybackControllerWillDeallocateNotification object:_playbackController];
    [_presentView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    [_view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    free(_controlInfo);
}

- (void)playerViewWillMoveToWindow:(MSCharmView *)codeView {
    
}

///
/// 此处拦截父视图的Tap手势
///
- (nullable UIView *)codeView:(MSCharmView *)codeView hitTestForView:(nullable __kindof UIView *)view {

    if ( codeView.hidden || codeView.alpha < 0.01 || !codeView.isUserInteractionEnabled ) return nil;
    
    for ( UIGestureRecognizer *gesture in codeView.superview.gestureRecognizers ) {
        if ( [gesture isKindOfClass:UITapGestureRecognizer.class] && gesture.isEnabled ) {
            gesture.enabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                gesture.enabled = YES;
            });
        }
    }
    
    return view;
}

- (void)presentViewDidLayoutSubviews:(MSPlumePresentView *)presentView {
        
}

- (void)presentViewDidMoveToWindow:(MSPlumePresentView *)presentView {
    if ( _deviceVolumeAndBrightnessController != nil ) [_deviceVolumeAndBrightnessController onTargetViewMoveToWindow];
}

#pragma mark -

- (void)_handleSingleTap:(CGPoint)location {
    
    if ( self.isLockedScreen ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(tappedPlayerOnTheLockedState:)] ) {
            [self.controlLayerDelegate tappedPlayerOnTheLockedState:self];
        }
    }
    else {
        [self.controlLayerAppearManager switchAppearState];
    }
}

- (void)_handleDoubleTap:(CGPoint)location {
    
    self.iPeached ? [self start] : [self pauseForUser];
}

- (void)_handlePan:(MSPanGestureTriggeredPosition)position direction:(MSPanGestureMovingDirection)direction state:(MSPanGestureRecognizerState)state translate:(CGPoint)translate {
    switch ( state ) {
        case MSPanGestureRecognizerStateBegan: {
            switch ( direction ) {
                    /// 水平
                case MSPanGestureMovingDirection_H: {
                    if ( self.duration == 0 ) {
                        [_presentView cancelGesture:MSCharmGestureType_Pan];
                        return;
                    }
                    
                    self.controlInfo->pan.offsetTime = self.currentTime;
                }
                    break;
                    /// 垂直
                case MSPanGestureMovingDirection_V: { }
                    break;
            }
        }
            break;
        case MSPanGestureRecognizerStateChanged: {
            switch ( direction ) {
                    /// 水平
                case MSPanGestureMovingDirection_H: {
                    NSTimeInterval duration = self.duration;
                    NSTimeInterval previous = self.controlInfo->pan.offsetTime;
                    CGFloat tlt = translate.x;
                    CGFloat add = tlt / self.controlInfo->pan.factor * self.duration;
                    CGFloat offsetTime = previous + add;
                    if ( offsetTime > duration ) offsetTime = duration;
                    else if ( offsetTime < 0 ) offsetTime = 0;
                    self.controlInfo->pan.offsetTime = offsetTime;
                }
                    break;
                    /// 垂直
                case MSPanGestureMovingDirection_V: {
                    CGFloat value = translate.y * 0.005;
                    switch ( position ) {
                            /// brightness
                        case MSPanGestureTriggeredPosition_Left: {
                            float old = self.deviceVolumeAndBrightnessController.brightness;
                            float new = old - value;
                            NSLog(@"brightness.set: old: %lf, new: %lf", old, new);
                            self.deviceVolumeAndBrightnessController.brightness = new;
                        }
                            break;
                            /// volume
                        case MSPanGestureTriggeredPosition_Right: {
                            self.deviceVolumeAndBrightnessController.volume -= value;
                        }
                            break;
                    }
                }
                    break;
            }
        }
            break;
        case MSPanGestureRecognizerStateEnded: {
            switch ( direction ) {
                case MSPanGestureMovingDirection_H: { }
                    break;
                case MSPanGestureMovingDirection_V: { }
                    break;
            }
        }
            break;
    }
    
    if ( direction == MSPanGestureMovingDirection_H ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:panGestureTriggeredInTheHorizontalDirection:progressTime:)] ) {
            [self.controlLayerDelegate plume:self panGestureTriggeredInTheHorizontalDirection:state progressTime:self.controlInfo->pan.offsetTime];
        }
    }
}

- (void)_handlePinch:(CGFloat)scale {
    self.spGravity = scale > 1 ?AVLayerVideoGravityResizeAspectFill:AVLayerVideoGravityResizeAspect;
}

- (void)_handleLongPress:(MSLongPressGestureRecognizerState)state {
    switch ( state ) {
        case MSLongPressGestureRecognizerStateBegan:
            self.controlInfo->longPress.initialRate = self.rate;
        case MSLongPressGestureRecognizerStateChanged:
            self.rate = self.rateWhenLongPressGestureTriggered;
            break;
        case MSLongPressGestureRecognizerStateEnded:
            self.rate = self.controlInfo->longPress.initialRate;
            break;
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:longPressGestureStateDidChange:)] ) {
        [self.controlLayerDelegate plume:self longPressGestureStateDidChange:state];
    }
}

#pragma mark -

- (void)setControlLayerDataSource:(nullable id<MSPlumeControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.plume_controlView.clipsToBounds = YES;
    
    // install
    UIView *controlView = _controlLayerDataSource.plume_controlView;
    controlView.layer.zPosition = MSCharmZIndexes.shared.controlLayerViewZIndex;
    controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controlView.frame = self.presentView.bounds;
    [self.presentView addSubview:controlView];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToPlume:)] ) {
        [self.controlLayerDataSource installedControlViewToPlume:self];
    }
}

#pragma mark -

- (void)_setupRotationManager:(id<MSRotationManager>)rotationManager {
    _rotationManager = rotationManager;
    _rotationManagerObserver = nil;
    
    if ( rotationManager == nil || self.onlyFitOnScreen )
        return;
    
    self.viewControllerManager.rotationManager = rotationManager;
    
    rotationManager.superview = self.view;
    rotationManager.target = self.presentView;
    __weak typeof(self) _self = self;
    rotationManager.shouldTriggerRotation = ^BOOL(id<MSRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( mgr.isFullscreen == NO ) {
            if ( !self.view.superview ) return NO;
        }
        if ( self.isLockedScreen ) return NO;
        
        if ( self.isFitOnScreen )
            return self.allowsRotationInFitOnScreen;
        
        if ( self.viewControllerManager.isViewDisappeared ) return NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(canTriggerRotationOfPlume:)] ) {
            if ( ![self.controlLayerDelegate canTriggerRotationOfPlume:self] )
                return NO;
        }
        if ( self.atViewController.presentedViewController ) return NO;
        if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) ) return NO;
        return YES;
    };
    
    _rotationManagerObserver = [rotationManager getObserver];
    _rotationManagerObserver.onRotatingChanged = ^(id<MSRotationManager>  _Nonnull mgr, BOOL isRotating) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self->_deviceVolumeAndBrightnessTargetViewContext.isFullscreen = mgr.isFullscreen;
        [self->_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
        
        if ( isRotating ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:willRotateView:)] ) {
                [self.controlLayerDelegate plume:self willRotateView:mgr.isFullscreen];
            }
            
            [self controlLayerNeedDisappear];
        }
        else {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:didEndRotation:)] ) {
                [self.controlLayerDelegate plume:self didEndRotation:mgr.isFullscreen];
            }
            
            if ( mgr.isFullscreen ) {
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }
            else {
                [UIView animateWithDuration:0.25 animations:^{
                    [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
                }];
            }
        }
    };
    
    _rotationManagerObserver.onTransitioningChanged = ^(id<MSRotationManager>  _Nonnull mgr, BOOL isTransitioning) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:onRotationTransitioningChanged:)] ) {
            [self.controlLayerDelegate plume:self onRotationTransitioningChanged:isTransitioning];
        }
    };
}

- (void)_clearRotationManager {
    _viewControllerManager.rotationManager = nil;
    _rotationManagerObserver = nil;
    _rotationManager = nil;
}

#pragma mark -

- (void)_setupFitOnScreenManager:(id<MSFitOnScreenManager>)fitOnScreenManager {
    _fitOnScreenManager = fitOnScreenManager;
    _fitOnScreenManagerObserver = nil;
    
    if ( fitOnScreenManager == nil ) return;
    
    self.viewControllerManager.fitOnScreenManager = fitOnScreenManager;
    
    _fitOnScreenManagerObserver = [fitOnScreenManager getObserver];
    __weak typeof(self) _self = self;
    _fitOnScreenManagerObserver.fitOnScreenWillBeginExeBlock = ^(id<MSFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self->_deviceVolumeAndBrightnessTargetViewContext.isFitOnScreen = mgr.isFitOnScreen;
        [self->_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
        
        if ( self->_rotationManager != nil ) {
            self->_rotationManager.superview = mgr.isFitOnScreen ? self.fitOnScreenManager.superviewInFitOnScreen : self.view;
        }
        [self controlLayerNeedDisappear];
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:willFitOnScreen:)] ) {
            [self.controlLayerDelegate plume:self willFitOnScreen:mgr.isFitOnScreen];
        }
    };
    
    _fitOnScreenManagerObserver.fitOnScreenDidEndExeBlock = ^(id<MSFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:didCompleteFitOnScreen:)] ) {
            [self.controlLayerDelegate plume:self didCompleteFitOnScreen:mgr.isFitOnScreen];
        }
        
        [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
    };
}


#pragma mark -

- (void)_setupControlLayerAppearManager:(id<MSControlLayerAppearManager>)controlLayerAppearManager {
    _controlLayerAppearManager = controlLayerAppearManager;
    _controlLayerAppearManagerObserver = nil;
    
    if ( controlLayerAppearManager == nil ) return;
    
    self.viewControllerManager.controlLayerAppearManager = controlLayerAppearManager;
    
    __weak typeof(self) _self = self;
    _controlLayerAppearManager.canAutomaticallyDisappear = ^BOOL(id<MSControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;

        if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerOfPlumeCanAutomaticallyDisappear:)] ) {
            if ( ![self.controlLayerDelegate controlLayerOfPlumeCanAutomaticallyDisappear:self] ) {
                return NO;
            }
        }
        
        if ( self.canAutomaticallyDisappear && !self.canAutomaticallyDisappear(self) ) {
            return NO;
        }
        return YES;
    };
    
    _controlLayerAppearManagerObserver = [_controlLayerAppearManager getObserver];
    _controlLayerAppearManagerObserver.onAppearChanged = ^(id<MSControlLayerAppearManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( mgr.isAppeared ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
                [self.controlLayerDelegate controlLayerNeedAppear:self];
            }
        }
        else {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
                [self.controlLayerDelegate controlLayerNeedDisappear:self];
            }
        }
        
        if ( !self.iFurry || self.isRotating ) {
            [UIView animateWithDuration:0 animations:^{
            } completion:^(BOOL finished) {
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
    };
}

#pragma mark -

- (MSPlumeRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [MSPlumeRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willTerminate = ^(MSPlumeRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _postNotification:MSPlumeApplicationWillTerminateNotification];
    };
    return _registrar;
}

#pragma mark -

- (void)_setupViews {
    _view = [MSCharmView new];
    _view.tag = MSCharmViewTag;
    _view.delegate = self;
    _view.backgroundColor = [UIColor blackColor];
    
    _presentView = [MSPlumePresentView new];
    _presentView.tag = MSPresentViewTag;
    _presentView.frame = _view.bounds;
    _presentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _presentView.placeholderImageView.layer.zPosition = MSCharmZIndexes.shared.placeholderImageViewZIndex;
    _presentView.delegate = self;
    [self _configGestureController:_presentView];
    [_view addSubview:_presentView];
    _view.presentView = _presentView;
}

- (void)_setupViewControllerManager {
    if ( _viewControllerManager == nil ) _viewControllerManager = MSViewControllerManager.alloc.init;
    _viewControllerManager.fitOnScreenManager = _fitOnScreenManager;
    _viewControllerManager.rotationManager = _rotationManager;
    _viewControllerManager.controlLayerAppearManager = _controlLayerAppearManager;
    _viewControllerManager.presentView = self.presentView;
    _viewControllerManager.lockedScreen = self.isLockedScreen;
    
    if ( [_rotationManager isKindOfClass:MSRotationManager.class] ) {
        MSRotationManager *mgr = _rotationManager;
        mgr.actionForwarder = _viewControllerManager;
    }
}

- (void)_postNotification:(NSNotificationName)name {
    [self _postNotification:name userInfo:nil];
}

- (void)_postNotification:(NSNotificationName)name userInfo:(nullable NSDictionary *)userInfo {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self userInfo:userInfo];
}

- (void)_showOrHiddenPlaceholderImageViewIfNeeded {
    if ( _playbackController.isReadyForDisplay ) {
        if ( _controlInfo->placeholder.automaticallyHides ) {
            NSTimeInterval delay = _resource.original != nil ? 0 : _controlInfo->placeholder.delayHidden;
            BOOL animated = _resource.original == nil;
            [self.presentView hidePlaceholderImageViewAnimated:animated delay:delay];
        }
    }
    else {
        [self.presentView setPlaceholderImageViewHidden:NO animated:NO];
    }
}

- (void)_configGestureController:(id<MSGestureController>)gestureController {
    
    __weak typeof(self) _self = self;
    gestureController.gestureRecognizerShouldTrigger = ^BOOL(id<MSGestureController>  _Nonnull control, MSCharmGestureType type, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isRotating )
            return NO;
        
        if ( type != MSCharmGestureType_SingleTap && self.isLockedScreen )
            return NO;
        
        if ( MSCharmGestureType_Pan == type ) {
            switch ( control.movingDirection ) {
                case MSPanGestureMovingDirection_H: {
                    if ( self.playbackType == MSPlaybackTypeLIVE )
                        return NO;
                    
                    if ( self.duration <= 0 )
                        return NO;
                    
                    if ( self.canSeekToTime != nil && !self.canSeekToTime(self) )
                        return NO;
                }
                    break;
                case MSPanGestureMovingDirection_V: {
                    switch ( control.triggeredPosition ) {
                            /// Brightness
                        case MSPanGestureTriggeredPosition_Left: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting )
                                return NO;
                        }
                            break;
                            /// Volume
                        case MSPanGestureTriggeredPosition_Right: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableVolumeSetting || self.isMuted )
                                return NO;
                        }
                            break;
                    }
                }
            }
        }
        
        if ( type == MSCharmGestureType_LongPress ) {
            if ( self.aspect != MSAssetStatusReadyToPlay || self.iPeached )
                return NO;
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:gestureRecognizerShouldTrigger:location:)] ) {
            if ( ![self.controlLayerDelegate plume:self gestureRecognizerShouldTrigger:type location:location] )
                return NO;
        }
        
        if ( self.gestureRecognizerShouldTrigger && !self.gestureRecognizerShouldTrigger(self, type, location) ) {
            return NO;
        }
        return YES;
    };
    
    gestureController.singleTapHandler = ^(id<MSGestureController>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleSingleTap:location];
    };
    
    gestureController.doubleTapHandler = ^(id<MSGestureController>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleDoubleTap:location];
    };
    
    gestureController.panHandler = ^(id<MSGestureController>  _Nonnull control, MSPanGestureTriggeredPosition position, MSPanGestureMovingDirection direction, MSPanGestureRecognizerState state, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePan:position direction:direction state:state translate:translate];
    };
    
    gestureController.pinchHandler = ^(id<MSGestureController>  _Nonnull control, CGFloat scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePinch:scale];
    };
    
    gestureController.longPressHandler = ^(id<MSGestureController>  _Nonnull control, MSLongPressGestureRecognizerState state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _handleLongPress:state];
    };
}

@end

@implementation MSBornPlume (AudioSession)
- (void)setAudioSessionControlEnabled:(BOOL)audioSessionControlEnabled {
    _controlInfo->audioSessionControl.isEnabled = audioSessionControlEnabled;
}

- (BOOL)isAudioSessionControlEnabled {
    return _controlInfo->audioSessionControl.isEnabled;
}

- (void)setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options {
    _mCategory = category;
    _mCategoryOptions = options;
    
    NSError *error = nil;
    if ( ![AVAudioSession.sharedInstance setCategory:_mCategory withOptions:_mCategoryOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
}

- (void)setActiveOptions:(AVAudioSessionSetActiveOptions)options {
    _mSetActiveOptions = options;
    NSError *error = nil;
    if ( ![AVAudioSession.sharedInstance setActive:YES withOptions:_mSetActiveOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
}
@end

@implementation MSBornPlume (Placeholder)
- (UIView<MSPlumePresentView> *)presentView {
    return _presentView;
}

- (void)setAutomaticallyHidesPlaceholderImageView:(BOOL)isHidden {
    _controlInfo->placeholder.automaticallyHides = isHidden;
}
- (BOOL)automaticallyHidesPlaceholderImageView {
    return _controlInfo->placeholder.automaticallyHides;
}


- (void)setDelayInSecondsForHiddenPlaceholderImageView:(NSTimeInterval)delayHidden {
    _controlInfo->placeholder.delayHidden = delayHidden;
}
- (NSTimeInterval)delayInSecondsForHiddenPlaceholderImageView {
    return _controlInfo->placeholder.delayHidden;
}
@end


#pragma mark -

@implementation MSBornPlume (VideoFlipTransition)
- (void)setFlipTransitionManager:(id<MSFlipTransitionManager> _Nullable)flipTransitionManager {
    _flipTransitionManager = flipTransitionManager;
}
- (id<MSFlipTransitionManager>)flipTransitionManager {
    if ( _flipTransitionManager )
        return _flipTransitionManager;
    
    _flipTransitionManager = [[MSFlipTransitionManager alloc] initWithTarget:self.playbackController.codeView];
    return _flipTransitionManager;
}

- (id<MSFlipTransitionManagerObserver>)flipTransitionObserver {
    id<MSFlipTransitionManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.flipTransitionManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark - 控制
@implementation MSBornPlume (Playback)
- (void)setPlaybackController:(nullable __kindof id<MSPlumePlaybackController>)playbackController {
    if ( _playbackController != nil ) {
        [_playbackController.codeView removeFromSuperview];
        [NSNotificationCenter.defaultCenter postNotificationName:MSPlumePlaybackControllerWillDeallocateNotification object:_playbackController];
    }
    _playbackController = playbackController;
    [self _playbackControllerDidChange];
}

- (__kindof id<MSPlumePlaybackController>)playbackController {
    if ( _playbackController ) return _playbackController;
    _playbackController = [MSResourcePlaybackController new];
    [self _playbackControllerDidChange];
    return _playbackController;
}

- (void)_playbackControllerDidChange {
    if ( !_playbackController )
        return;
    
    _playbackController.delegate = self;
    
    if ( _playbackController.codeView.superview != self.presentView ) {
        _playbackController.codeView.frame = self.presentView.bounds;
        _playbackController.codeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _playbackController.codeView.layer.zPosition = MSCharmZIndexes.shared.playbackViewZIndex;
        [_presentView addSubview:_playbackController.codeView];
    }
    
    _flipTransitionManager.target = _playbackController.codeView;
}

- (MSPlaybackObservation *)playbackObserver {
    MSPlaybackObservation *obs = objc_getAssociatedObject(self, _cmd);
    if ( obs == nil ) {
        obs = [[MSPlaybackObservation alloc] initWithPlayer:self];
        objc_setAssociatedObject(self, _cmd, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obs;
}

- (MSPlaybackType)playbackType {
    return _playbackController.playbackType;
}

#pragma mark -

- (NSError *_Nullable)error {
    return _playbackController.error;
}

- (MSAssetStatus)aspect {
    return _playbackController.assetStatus;
}

- (MSPlumeState)plumeState {
    return _playbackController.timeControlStatus;
}

- (BOOL)iPeached { return self.plumeState == MSPlumeStatePeached; }
- (BOOL)iPluming { return self.plumeState == MSPlumeStatePluming; }
- (BOOL)isBuffering { return self.plumeState == MSPlumeStateWaiting && self.reasonForWaitingToPlay == MSWaitingToMinimizeStallsReason; }
- (BOOL)isEvaluating { return self.plumeState == MSPlumeStateWaiting && self.reasonForWaitingToPlay == MSWaitingWhileEvaluatingBufferingRateReason; }
- (BOOL)isNoAssetToPlay { return self.plumeState == MSPlumeStateWaiting && self.reasonForWaitingToPlay == MSWaitingWithNoAssetToPlayReason; }

- (BOOL)isPlaybackFailed {
    return self.aspect == MSAssetStatusFailed;
}

- (nullable MSWaitingReason)reasonForWaitingToPlay {
    return _playbackController.reasonForWaitingToPlay;
}

- (BOOL)isPlaybackFinished {
    return _playbackController.isPlaybackFinished;
}

- (nullable MSFinishedReason)finishedReason {
    return _playbackController.finishedReason;
}

- (BOOL)iPlumed {
    return _playbackController.isPlayed;
}

- (BOOL)isReplayed {
    return _playbackController.isReplayed;
}

- (BOOL)isUserPaused {
    return _controlInfo->playbackControl.isUserPaused;
}

- (NSTimeInterval)currentTime {
    return self.playbackController.currentTime;
}

- (NSTimeInterval)duration {
    return self.playbackController.duration;
}

- (NSTimeInterval)playableDuration {
    return self.playbackController.playableDuration;
}

- (NSTimeInterval)durationWatched {
    return self.playbackController.durationWatched;
}

- (NSString *)stringForSeconds:(NSInteger)secs {
    return [NSString stringWithCurrentTime:secs duration:self.duration];
}

#pragma mark -
// 1.
- (void)setResource:(nullable MSPlumeResource *)resource {
    
    [self _postNotification:MSPlumeResourceWillChangeNotification];
    
    _resource = resource;
    
    [self _postNotification:MSPlumeResourceDidChangeNotification];
      
    //
    // prepareToPlay
    //
    self.playbackController.media = resource;
    [self _updateAssetObservers];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:prepareToPlay:)] ) {
        [self.controlLayerDelegate plume:self prepareToPlay:resource];
    }
    
    if ( resource == nil ) {
        [self stop];
        return;
    }

    if ( resource.subtitles != nil || _subtitlePopupController != nil ) {
        self.subtitlePopupController.subtitles = resource.subtitles;
    }
    
    [(MSMTPlaybackController *)self.playbackController prepareToPlay];
    [self _tryToPlayIfNeeded];
}
- (nullable MSPlumeResource *)resource {
    return _resource;
}

- (void)_tryToPlayIfNeeded {
    if ( self.registrar.state == MSPlumeAppState_Background && self.isPausedInBackground )
        return;
    if ( _controlInfo->playbackControl.autoplayWhenSetNewAsset == NO )
        return;
    
    [self start];
}

- (void)_updateAssetObservers {

    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
}

- (void)refresh {
    if ( !self.resource ) return;
    [self _postNotification:MSPlumePlaybackWillRefreshNotification];
    [_playbackController refresh];
    [self start];
    [self _postNotification:MSPlumePlaybackDidRefreshNotification];
}

- (void)setPlayerVolume:(float)playerVolume {
    self.playbackController.volume = playerVolume;
}

- (float)playerVolume {
    return self.playbackController.volume;
}

- (void)setMuted:(BOOL)muted {
    self.playbackController.muted = muted;
}

- (BOOL)isMuted {
    return self.playbackController.muted;
}

- (void)setAutoplayWhenSetNewAsset:(BOOL)autoplayWhenSetNewAsset {
    _controlInfo->playbackControl.autoplayWhenSetNewAsset = autoplayWhenSetNewAsset;
}
- (BOOL)autoplayWhenSetNewAsset {
    return _controlInfo->playbackControl.autoplayWhenSetNewAsset;
}

- (void)setPausedInBackground:(BOOL)pausedInBackground {
    self.playbackController.pauseWhenAppDidEnterBackground = pausedInBackground;
}
- (BOOL)isPausedInBackground {
    return self.playbackController.pauseWhenAppDidEnterBackground;
}

- (void)setResumePlaybackWhenAppDidEnterForeground:(BOOL)resumePlaybackWhenAppDidEnterForeground {
    _controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground = resumePlaybackWhenAppDidEnterForeground;
}
- (BOOL)resumePlaybackWhenAppDidEnterForeground {
    return _controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground;
}

- (void)setCanPlayAnAsset:(nullable BOOL (^)(__kindof MSBornPlume * _Nonnull))canPlayAnAsset {
    objc_setAssociatedObject(self, @selector(canPlayAnAsset), canPlayAnAsset, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable BOOL (^)(__kindof MSBornPlume * _Nonnull))canPlayAnAsset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResumePlaybackWhenPlayerHasFinishedSeeking:(BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking = resumePlaybackWhenPlayerHasFinishedSeeking;
}
- (BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    return _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking;
}

- (void)start {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPlayForPlume:)] ) {
        if ( ![self.controlLayerDelegate canPerformPlayForPlume:self] )
            return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) )
        return;
    
    if ( self.registrar.state == MSPlumeAppState_Background && self.isPausedInBackground ) return;

    _controlInfo->playbackControl.isUserPaused = NO;
    
    if ( self.aspect == MSAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    if (_controlInfo->audioSessionControl.isEnabled) {
        NSError *error = nil;
        if ( ![AVAudioSession.sharedInstance setCategory:_mCategory withOptions:_mCategoryOptions error:&error] ) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        if ( ![AVAudioSession.sharedInstance setActive:YES withOptions:_mSetActiveOptions error:&error] ) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
    }

    [_playbackController play];

    [self.controlLayerAppearManager resume];
}

- (void)peach {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPauseForPlume:)] ) {
        if ( ![self.controlLayerDelegate canPerformPauseForPlume:self] )
            return;
    }
    
    [_playbackController pause];
}

- (void)pauseForUser {
    _controlInfo->playbackControl.isUserPaused = YES;
    [self peach];
}

- (void)stop {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformStopForPlume:)] ) {
        if ( ![self.controlLayerDelegate canPerformStopForPlume:self] )
            return;
    }
    
    [self _postNotification:MSPlumePlaybackWillStopNotification];

    _controlInfo->playbackControl.isUserPaused = NO;
    _subtitlePopupController.subtitles = nil;
    _resource = nil;
    [_playbackController stop];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    [self _postNotification:MSPlumePlaybackDidStopNotification];
}

- (void)replay {
    if ( !self.resource ) return;
    if ( self.aspect == MSAssetStatusFailed ) {
        [self refresh];
        return;
    }

    _controlInfo->playbackControl.isUserPaused = NO;
    [_playbackController replay];
}

- (void)setCanSeekToTime:(BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))canSeekToTime {
    objc_setAssociatedObject(self, @selector(canSeekToTime), canSeekToTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))canSeekToTime {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _controlInfo->playbackControl.accurateSeeking = accurateSeeking;
}
- (BOOL)accurateSeeking {
    return _controlInfo->playbackControl.accurateSeeking;
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(secs) ) {
        return;
    }
    
    if ( secs > self.playbackController.duration ) {
        secs = self.playbackController.duration * 0.98;
    }
    else if ( secs < 0 ) {
        secs = 0;
    }
    
    [self seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC)
     toleranceBefore:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
      toleranceAfter:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
   completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    if ( self.canSeekToTime && !self.canSeekToTime(self) ) {
        return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( self.aspect != MSAssetStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    __weak typeof(self) _self = self;
    [self.playbackController seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( finished && self.controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking ) {
            [self start];
        }
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)setRate:(float)rate {
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( _playbackController.rate == rate )
        return;
    
    self.playbackController.rate = rate;
}

- (float)rate {
    return self.playbackController.rate;
}

#pragma mark - MSPlumePlaybackControllerDelegate

- (void)playbackController:(id<MSPlumePlaybackController>)controller assetStatusDidChange:(MSAssetStatus)status {
 
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plumePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate plumePlaybackStatusDidChange:self];
    }
    
    [self _postNotification:MSPlumeAssetStatusDidChangeNotification];
    
#ifdef MSDEBUG
    [self showLog_AssetStatus];
#endif
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller timeControlStatusDidChange:(MSPlumeState)status {
    
    BOOL isBuffering = self.isBuffering || self.aspect == MSAssetStatusPreparing;
    isBuffering && !self.resource.mtSource.isFileURL ? [self.reachability startRefresh] : [self.reachability stopRefresh];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plumePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate plumePlaybackStatusDidChange:self];
    }

    [self _postNotification:MSPlumePlumeStateDidChangeNotification];
        
    if ( status == MSPlumeStatePeached && self.pausedToKeepAppearState ) {
        [self.controlLayerAppearManager keepAppearState];
    }
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller volumeDidChange:(float)volume {
    [self _postNotification:MSPlumeVolumeDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller rateDidChange:(float)rate {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:rateChanged:)] ) {
        [self.controlLayerDelegate plume:self rateChanged:rate];
    }
    
    [self _postNotification:MSPlumeRateDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller mutedDidChange:(BOOL)isMuted {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:muteChanged:)] ) {
        [self.controlLayerDelegate plume:self muteChanged:isMuted];
    }
    [self _postNotification:MSPlumeMutedDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller durationDidChange:(NSTimeInterval)duration {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:durationDidChange:)] ) {
        [self.controlLayerDelegate plume:self durationDidChange:duration];
    }
    
    [self _postNotification:MSPlumeDurationDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime {
    _subtitlePopupController.currentTime = currentTime;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:currentTimeDidChange:)] ) {
        [self.controlLayerDelegate plume:self currentTimeDidChange:currentTime];
    }
    
    [self _postNotification:MSPlumeCurrentTimeDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller playbackDidFinish:(MSFinishedReason)reason {
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plumePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate plumePlaybackStatusDidChange:self];
    }
    
    [self _postNotification:MSPlumePlaybackDidFinishNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize {
    
    if ( self.presentationSizeDidChangeExeBlock )
        self.presentationSizeDidChangeExeBlock(self);
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:presentationSizeDidChange:)] ) {
        [self.controlLayerDelegate plume:self presentationSizeDidChange:presentationSize];
    }
    
    [self _postNotification:MSPlumePresentationSizeDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller playbackTypeDidChange:(MSPlaybackType)playbackType {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:playbackTypeDidChange:)] ) {
        [self.controlLayerDelegate plume:self playbackTypeDidChange:playbackType];
    }
    
    [self _postNotification:MSPlumePlaybackTypeDidChangeNotification];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration {
    if ( controller.duration == 0 ) return;

    if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:playableDurationDidChange:)] ) {
        [self.controlLayerDelegate plume:self playableDurationDidChange:playableDuration];
    }
    
    [self _postNotification:MSPlumePlayableDurationDidChangeNotification];
}

- (void)playbackControllerIsReadyForDisplay:(id<MSPlumePlaybackController>)controller {
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller willSeekToTime:(CMTime)time {
    [self _postNotification:MSPlumePlaybackWillSeekNotification userInfo:@{
        MSPlumeNotificationUserInfoKeySeekTime : [NSValue valueWithCMTime:time]
    }];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller didSeekToTime:(CMTime)time {
    [self _postNotification:MSPlumePlaybackDidSeekNotification userInfo:@{
        MSPlumeNotificationUserInfoKeySeekTime : [NSValue valueWithCMTime:time]
    }];
}

- (void)playbackController:(id<MSPlumePlaybackController>)controller didReplay:(id<MSMTModelProtocol>)media {
    [self _postNotification:MSPlumePlaybackDidReplayNotification];
}

- (void)applicationDidBecomeActiveWithPlaybackController:(id<MSPlumePlaybackController>)controller {
    BOOL canPlay = self.resource != nil &&
                   self.iPeached &&
                   self.controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground &&
                  !self.vc_isDisappeared;
    if ( canPlay ) [self start];

    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidBecomeActiveWithPlume:)] ) {
        [self.controlLayerDelegate applicationDidBecomeActiveWithPlume:self];
    }
}

- (void)applicationWillResignActiveWithPlaybackController:(id<MSPlumePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationWillResignActiveWithPlume:)] ) {
        [self.controlLayerDelegate applicationWillResignActiveWithPlume:self];
    }
}

- (void)applicationWillEnterForegroundWithPlaybackController:(id<MSPlumePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidEnterBackgroundWithPlume:)] ) {
        [self.controlLayerDelegate applicationDidEnterBackgroundWithPlume:self];
    }
    [self _postNotification:MSPlumeApplicationWillEnterForegroundNotification];
}

- (void)applicationDidEnterBackgroundWithPlaybackController:(id<MSPlumePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidEnterBackgroundWithPlume:)] ) {
        [self.controlLayerDelegate applicationDidEnterBackgroundWithPlume:self];
    }
    [self _postNotification:MSPlumeApplicationDidEnterBackgroundNotification];
}

@end


#pragma mark - Network

@implementation MSBornPlume (Network)

- (void)setReachability:(id<MSReachability> _Nullable)reachability {
    _reachability = reachability;
    [self _needUpdateReachabilityProperties];
}

- (id<MSReachability>)reachability {
    if ( _reachability )
        return _reachability;
    _reachability = [MSReachability shared];
    [self _needUpdateReachabilityProperties];
    return _reachability;
}

- (void)_needUpdateReachabilityProperties {
    if ( _reachability == nil ) return;
    
    _reachabilityObserver = [_reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<MSReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:reachabilityChanged:)] ) {
            [self.controlLayerDelegate plume:self reachabilityChanged:r.networkStatus];
        }
    };
}

- (id<MSReachabilityObserver>)reachabilityObserver {
    id<MSReachabilityObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.reachability getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark -

@implementation MSBornPlume (DeviceVolumeAndBrightness)

- (void)setDeviceVolumeAndBrightnessController:(id<MSDeviceVolumeAndBrightnessController> _Nullable)deviceVolumeAndBrightnessController {
    _deviceVolumeAndBrightnessController = deviceVolumeAndBrightnessController;
    [self _configDeviceVolumeAndBrightnessController:self.deviceVolumeAndBrightnessController];
}

- (id<MSDeviceVolumeAndBrightnessController>)deviceVolumeAndBrightnessController {
    if ( _deviceVolumeAndBrightnessController )
        return _deviceVolumeAndBrightnessController;
    _deviceVolumeAndBrightnessController = [MSDeviceVolumeAndBrightnessController.alloc init];
    [self _configDeviceVolumeAndBrightnessController:_deviceVolumeAndBrightnessController];
    return _deviceVolumeAndBrightnessController;
}

- (void)_configDeviceVolumeAndBrightnessController:(id<MSDeviceVolumeAndBrightnessController>)mgr {
    mgr.targetViewContext = _deviceVolumeAndBrightnessTargetViewContext;
    mgr.target = self.presentView;
    _deviceVolumeAndBrightnessControllerObserver = [mgr getObserver];
    __weak typeof(self) _self = self;
    _deviceVolumeAndBrightnessControllerObserver.volumeDidChangeExeBlock = ^(id<MSDeviceVolumeAndBrightnessController>  _Nonnull mgr, float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:volumeChanged:)] ) {
            [self.controlLayerDelegate plume:self volumeChanged:volume];
        }
    };
    
    _deviceVolumeAndBrightnessControllerObserver.brightnessDidChangeExeBlock = ^(id<MSDeviceVolumeAndBrightnessController>  _Nonnull mgr, float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(plume:brightnessChanged:)] ) {
            [self.controlLayerDelegate plume:self brightnessChanged:brightness];
        }
    };
    
    [mgr onTargetViewMoveToWindow];
    [mgr onTargetViewContextUpdated];
}

- (id<MSDeviceVolumeAndBrightnessControllerObserver>)deviceVolumeAndBrightnessObserver {
    id<MSDeviceVolumeAndBrightnessControllerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.deviceVolumeAndBrightnessController getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting = disableBrightnessSetting;
}
- (BOOL)disableBrightnessSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting = disableVolumeSetting;
}
- (BOOL)disableVolumeSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting;
}

@end



#pragma mark -

@implementation MSBornPlume (Life)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    [self.viewControllerManager viewDidAppear];
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    [self.viewControllerManager viewWillDisappear];
}
- (void)vc_viewDidDisappear {
    [self.viewControllerManager viewDidDisappear];
    [self peach];
}
- (BOOL)vc_prefersStatusBarHidden {
    return self.viewControllerManager.prefersStatusBarHidden;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    return self.viewControllerManager.preferredStatusBarStyle;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    vc_isDisappeared ?  [self.viewControllerManager viewWillDisappear] :
                        [self.viewControllerManager viewDidAppear];
}
- (BOOL)vc_isDisappeared {
    return self.viewControllerManager.isViewDisappeared;
}

- (void)needShowStatusBar {
    [self.viewControllerManager showStatusBar];
}

- (void)needHiddenStatusBar {
    [self.viewControllerManager hiddenStatusBar];
}
@end

#pragma mark - Gesture

@implementation MSBornPlume (Gesture)

- (id<MSGestureController>)gestureController {
    return _presentView;
}

- (void)setGestureRecognizerShouldTrigger:(BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull, MSCharmGestureType, CGPoint))gestureRecognizerShouldTrigger {
    objc_setAssociatedObject(self, @selector(gestureRecognizerShouldTrigger), gestureRecognizerShouldTrigger, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull, MSCharmGestureType, CGPoint))gestureRecognizerShouldTrigger {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAllowHorizontalTriggeringOfPanGesturesInCells:(BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    _controlInfo->gestureController.allowHorizontalTriggeringOfPanGesturesInCells = allowHorizontalTriggeringOfPanGesturesInCells;
}

- (BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    return _controlInfo->gestureController.allowHorizontalTriggeringOfPanGesturesInCells;
}

- (void)setRateWhenLongPressGestureTriggered:(CGFloat)rateWhenLongPressGestureTriggered {
    _controlInfo->gestureController.rateWhenLongPressGestureTriggered = rateWhenLongPressGestureTriggered;
}
- (CGFloat)rateWhenLongPressGestureTriggered {
    return _controlInfo->gestureController.rateWhenLongPressGestureTriggered;
}

- (void)setOffsetFactorForHorizontalPanGesture:(CGFloat)offsetFactorForHorizontalPanGesture {
    NSAssert(offsetFactorForHorizontalPanGesture != 0, @"The factor can't be set to 0!");
    _controlInfo->pan.factor = offsetFactorForHorizontalPanGesture;
}
- (CGFloat)offsetFactorForHorizontalPanGesture {
    return _controlInfo->pan.factor;
}
@end


#pragma mark - 控制层

@implementation MSBornPlume (ControlLayer)
/// 控制层需要显示
- (void)controlLayerNeedAppear {
    [self.controlLayerAppearManager needAppear];
}

/// 控制层需要隐藏
- (void)controlLayerNeedDisappear {
    [self.controlLayerAppearManager needDisappear];
}

- (void)setControlLayerAppearManager:(id<MSControlLayerAppearManager> _Nullable)controlLayerAppearManager {
    [self _setupControlLayerAppearManager:controlLayerAppearManager];
}

- (id<MSControlLayerAppearManager>)controlLayerAppearManager {
    if ( _controlLayerAppearManager == nil ) {
        [self _setupControlLayerAppearManager:MSControlLayerAppearStateManager.alloc.init];
    }
    return _controlLayerAppearManager;
}

- (id<MSControlLayerAppearManagerObserver>)controlLayerAppearObserver {
    id<MSControlLayerAppearManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.controlLayerAppearManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setCanAutomaticallyDisappear:(BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))canAutomaticallyDisappear {
    objc_setAssociatedObject(self, @selector(canAutomaticallyDisappear), canAutomaticallyDisappear, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))canAutomaticallyDisappear {
    return objc_getAssociatedObject(self, _cmd);
}

/// 控制层是否显示
- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared {
    controlLayerAppeared ? [self.controlLayerAppearManager needAppear] :
                           [self.controlLayerAppearManager needDisappear];
}
- (BOOL)isControlLayerAppeared {
    return self.controlLayerAppearManager.isAppeared;
}

/// 暂停时是否保持控制层一直显示
- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    _controlInfo->controlLayer.pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return _controlInfo->controlLayer.pausedToKeepAppearState;
}
@end



#pragma mark - 充满屏幕

@implementation MSBornPlume (FitOnScreen)

- (void)setFitOnScreenManager:(id<MSFitOnScreenManager> _Nullable)fitOnScreenManager {
    [self _setupFitOnScreenManager:fitOnScreenManager];
}

- (id<MSFitOnScreenManager>)fitOnScreenManager {
    if ( _fitOnScreenManager == nil ) {
        [self _setupFitOnScreenManager:[[MSFitOnScreenManager alloc] initWithTarget:self.presentView targetSuperview:self.view]];
    }
    return _fitOnScreenManager;
}

- (id<MSFitOnScreenManagerObserver>)fitOnScreenObserver {
    id<MSFitOnScreenManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.fitOnScreenManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setOnlyFitOnScreen:(BOOL)onlyFitOnScreen {
    objc_setAssociatedObject(self, @selector(onlyFitOnScreen), @(onlyFitOnScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( onlyFitOnScreen ) {
        [self _clearRotationManager];
    }
    else {
        [self rotationManager];
    }
}

- (BOOL)onlyFitOnScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isFitOnScreen {
    return self.fitOnScreenManager.isFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof MSBornPlume *player))completionHandler {
    NSAssert(!self.iFurry, @"横屏全屏状态下, 无法执行竖屏全屏!");
    
    __weak typeof(self) _self = self;
    [self.fitOnScreenManager setFitOnScreen:fitOnScreen animated:animated completionHandler:^(id<MSFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(self);
    }];
}
@end


#pragma mark - 屏幕旋转

@implementation MSBornPlume (Rotation)

- (void)setRotationManager:(nullable id<MSRotationManager>)rotationManager {
    [self _setupRotationManager:rotationManager];
}

- (nullable id<MSRotationManager>)rotationManager {
    if ( _rotationManager == nil && !self.onlyFitOnScreen ) {
        MSRotationManager *defaultManager = [MSRotationManager rotationManager];
        defaultManager.actionForwarder = self.viewControllerManager;
        [self _setupRotationManager:defaultManager];
    }
    return _rotationManager;
}

- (id<MSRotationManagerObserver>)rotationObserver {
    id<MSRotationManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.rotationManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setShouldTriggerRotation:(BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))shouldTriggerRotation {
    objc_setAssociatedObject(self, @selector(shouldTriggerRotation), shouldTriggerRotation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof MSBornPlume * _Nonnull))shouldTriggerRotation {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAllowsRotationInFitOnScreen:(BOOL)allowsRotationInFitOnScreen {
    objc_setAssociatedObject(self, @selector(allowsRotationInFitOnScreen), @(allowsRotationInFitOnScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)allowsRotationInFitOnScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)rotate {
    [self.rotationManager rotate];
}

- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated {
    [self.rotationManager rotate:orientation animated:animated];
}

- (void)rotate:(MSOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof MSBornPlume *player))block {
    __weak typeof(self) _self = self;
    [self.rotationManager rotate:orientation animated:animated completionHandler:^(id<MSRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self);
    }];
}

- (BOOL)isRotating {
    return _rotationManager.isRotating;
}

- (BOOL)iFurry {
    return _rotationManager.isFullscreen;
}

- (UIInterfaceOrientation)currentOrientation {
    return (NSInteger)_rotationManager.currentOrientation;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    if ( lockedScreen != self.isLockedScreen ) {
        self.viewControllerManager.lockedScreen = lockedScreen;
        objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if      ( lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(lockedPlume:)] ) {
            [self.controlLayerDelegate lockedPlume:self];
        }
        else if ( !lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(unlockedPlume:)] ) {
            [self.controlLayerDelegate unlockedPlume:self];
        }
        
        [self _postNotification:MSPlumeScreenLockStateDidChangeNotification];
    }
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end



@implementation MSBornPlume (Screenshot)

- (void)setPresentationSizeDidChangeExeBlock:(void (^_Nullable)(__kindof MSBornPlume * _Nonnull))presentationSizeDidChangeExeBlock {
    objc_setAssociatedObject(self, @selector(presentationSizeDidChangeExeBlock), presentationSizeDidChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof MSBornPlume * _Nonnull))presentationSizeDidChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGSize)videoPresentationSize {
    return _playbackController.presentationSize;
}

- (UIImage * __nullable)screenshot {
    return [_playbackController screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof MSBornPlume *plume, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof MSBornPlume *plume, UIImage * __nullable image, NSError *__nullable error))block {
    if ( [_playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        __weak typeof(self) _self = self;
        [(id<MSMTPlaybackScreenshotController>)_playbackController screenshotWithTime:time size:size completion:^(id<MSPlumePlaybackController>  _Nonnull controller, UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                if ( block ) block(self, image, error);
            });
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"MSBornPlume<%p>.playbackController does not implement the screenshot method", self]}];
        if ( block ) block(self, nil, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}
@end


#pragma mark - 输出

@implementation MSBornPlume (Export)

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof MSBornPlume *plume, float progress))progressBlock
                 completion:(void(^)(__kindof MSBornPlume *plume, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof MSBornPlume *plume, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(exportWithBeginTime:duration:presetName:progress:completion:failure:)] ) {
        __weak typeof(self) _self = self;
        [(id<MSMTPlaybackExportController>)_playbackController exportWithBeginTime:beginTime duration:duration presetName:presetName progress:^(id<MSPlumePlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<MSPlumePlaybackController>  _Nonnull controller, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, fileURL, thumbImage);
        } failure:^(id<MSPlumePlaybackController>  _Nonnull controller, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"MSBornPlume<%p>.playbackController does not implement the exportWithBeginTime:endTime:presetName:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelExportOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelExportOperation)] ) {
        [(id<MSMTPlaybackExportController>)_playbackController cancelExportOperation];
    }
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof MSBornPlume *plume, float progress))progressBlock
                      completion:(void(^)(__kindof MSBornPlume *plume, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof MSBornPlume *plume, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure:)] ) {
        NSURL *filePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"MSGeneratedGif.gif"]];
        __weak typeof(self) _self = self;
        [(id<MSMTPlaybackExportController>)_playbackController generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.1f gifSavePath:filePath progress:^(id<MSPlumePlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<MSPlumePlaybackController>  _Nonnull controller, UIImage * _Nonnull imageGIF, UIImage * _Nonnull screenshot) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, imageGIF, screenshot, filePath);
        } failure:^(id<MSPlumePlaybackController>  _Nonnull controller, NSError * _Nonnull error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"MSBornPlume<%p>.playbackController does not implement the generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelGenerateGIFOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelGenerateGIFOperation)] ) {
        [(id<MSMTPlaybackExportController>)_playbackController cancelGenerateGIFOperation];
    }
}
@end

@implementation MSBornPlume (Subtitles)
- (void)setSubtitlePopupController:(nullable id<MSSubtitlePopupController>)subtitlePopupController {
    [_subtitlePopupController.view removeFromSuperview];
    _subtitlePopupController = subtitlePopupController;
    if ( subtitlePopupController != nil ) {
        subtitlePopupController.view.layer.zPosition = MSCharmZIndexes.shared.subtitleViewZIndex;
        [self.presentView addSubview:subtitlePopupController.view];
        [subtitlePopupController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_greaterThanOrEqualTo(self.subtitleHorizontalMinMargin);
            make.right.mas_lessThanOrEqualTo(-self.subtitleHorizontalMinMargin);
            make.centerX.offset(0);
            make.bottom.offset(-self.subtitleBottomMargin);
        }];
    }
}

- (id<MSSubtitlePopupController>)subtitlePopupController {
    if ( _subtitlePopupController == nil ) {
        self.subtitlePopupController = MSSubtitlePopupController.alloc.init;
    }
    return _subtitlePopupController;
}

- (void)setSubtitleBottomMargin:(CGFloat)subtitleBottomMargin {
    objc_setAssociatedObject(self, @selector(subtitleBottomMargin), @(subtitleBottomMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlePopupController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-subtitleBottomMargin);
    }];
}
- (CGFloat)subtitleBottomMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}

- (void)setSubtitleHorizontalMinMargin:(CGFloat)subtitleHorizontalMinMargin {
    objc_setAssociatedObject(self, @selector(subtitleHorizontalMinMargin), @(subtitleHorizontalMinMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlePopupController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(subtitleHorizontalMinMargin);
        make.right.mas_lessThanOrEqualTo(-subtitleHorizontalMinMargin);
    }];
}
- (CGFloat)subtitleHorizontalMinMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}
@end

#pragma mark -

@implementation MSBornPlume (Deprecated)
- (void)playWithURL:(NSURL *)URL {
    self.auspicious = URL;
}
- (void)setAuspicious:(nullable NSURL *)assetURL {
    self.resource = [[MSPlumeResource alloc] initWithSource:assetURL];
}

- (nullable NSURL *)auspicious {
    return self.resource.mtSource;
}

- (BOOL)isPlayedToEndTime {
    return self.isPlaybackFinished && self.finishedReason == MSFinishedReasonToEndTimePosition;
}

@end
NS_ASSUME_NONNULL_END
