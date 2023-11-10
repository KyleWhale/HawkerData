//
//  MSEdgeControlLayer.m
//  MSPlume
//
//  Created by admin on 2018/10/24.
//  Copyright © 2018 admin. All rights reserved.
//

#if __has_include(<MSUIKit/MSAttributesFactory.h>)
#import <MSUIKit/MSAttributesFactory.h>
#else
#import "MSAttributesFactory.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#import <MSBornPlume/MSTimerControl.h>
#else
#import "MSBornPlume.h"
#import "MSTimerControl.h"
#endif

#import "MSEdgeControlLayer.h"
#import "MSPlumeResource+MSControlAdd.h"
#import "MSDraggingProgressPopupView.h"
#import "UIView+MSAnimationAdded.h"
#import "MSPlumeConfigurations.h"
#import "MSProgressSlider.h"
#import "MSLoadingView.h"
#import "MSDraggingObservation.h"
#import "MSScrollingTextMarqueeView.h"
#import "MSFullscreenModeStatusBar.h"
#import "MSSpeedupPlaybackPopupView.h"
#import "MSEdgeControlButtonItemInternal.h"
#import <objc/message.h>

#pragma mark - Top

@interface MSEdgeControlLayer ()<MSProgressSliderDelegate>
@property (nonatomic, weak, nullable) MSBornPlume *plume;

@property (nonatomic, strong, readonly) MSTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) MSProgressSlider *bottomProgressIndicator;

// 固定左上角的返回按钮. 设置`fixesBackItem`后显示
@property (nonatomic, strong, readonly) UIButton *fixedBackButton;
@property (nonatomic, strong, readonly) MSEdgeControlButtonItem *backItem;

@property (nonatomic, strong, nullable) id<MSReachabilityObserver> reachabilityObserver;
@property (nonatomic, strong, readonly) MSTimerControl *dateTimerControl API_AVAILABLE(ios(11.0)); // refresh date for custom status bar

@property (nonatomic) BOOL automaticallyFitOnScreen;
@end

@implementation MSEdgeControlLayer
@synthesize restarted = _restarted;
@synthesize draggingProgressPopupView = _draggingProgressPopupView;
@synthesize draggingObserver = _draggingObserver;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _bottomProgressIndicatorHeight = 1;
    _automaticallyPerformRotationOrFitOnScreen = YES;
    [self _setupView];
    self.autoAdjustTopSpacing = YES;
    self.hiddenBottomProgressIndicator = YES;
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

///
/// 切换器(player.switcher)重启该控制层
///
- (void)restartControlLayer {
    _restarted = YES;
    ms_view_makeAppear(self.plume_controlView, YES);
    [self _showOrHiddenLoadingView];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

///
/// 控制层退场
///
- (void)exitControlLayer {
    _restarted = NO;
    
    ms_view_makeDisappear(self.plume_controlView, YES, ^{
        if ( !self->_restarted ) [self.plume_controlView removeFromSuperview];
    });
    
    ms_view_makeDisappear(_topContainerView, YES);
    ms_view_makeDisappear(_leftContainerView, YES);
    ms_view_makeDisappear(_bottomContainerView, YES);
    ms_view_makeDisappear(_rightContainerView, YES);
    ms_view_makeDisappear(_draggingProgressPopupView, YES);
    ms_view_makeDisappear(_centerContainerView, YES);
}

#pragma mark - item actions

- (void)_fixedBackButtonWasTapped {
    [self.backItem performActions];
}

- (void)_backItemWasTapped {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)_lockItemWasTapped {
    self.plume.lockedScreen = !self.plume.isLockedScreen;
}

- (void)_playItemWasTapped {
    _plume.iPeached ? [self.plume start] : [self.plume pauseForUser];
}

- (void)_fullItemWasTapped {
    if ( _plume.onlyFitOnScreen || _automaticallyFitOnScreen ) {
        [_plume setFitOnScreen:!_plume.isFitOnScreen];
        return;
    }
    
    if ( _needsFitOnScreenFirst && !_plume.isFitOnScreen ) {
        [_plume setFitOnScreen:YES];
        return;
    }
    
    [_plume rotate];
}

- (void)_replayItemWasTapped {
    [_plume replay];
}

#pragma mark - slider delegate methods

- (void)sliderWillBeginDragging:(MSProgressSlider *)slider {
    if ( _plume.aspect != MSAssetStatusReadyToPlay ) {
        [slider cancelDragging];
        return;
    }
    else if ( _plume.canSeekToTime && !_plume.canSeekToTime(_plume) ) {
        [slider cancelDragging];
        return;
    }
    
    [self _willBeginDragging];
}

- (void)slider:(MSProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) [self _didMove:value];
}

- (void)sliderDidEndDragging:(MSProgressSlider *)slider {
    [self _endDragging];
}

#pragma mark - player delegate methods

- (UIView *)plume_controlView {
    return self;
}

- (void)installedControlViewToPlume:(__kindof MSBornPlume *)plume {
    _plume = plume;
    ms_view_makeDisappear(_topContainerView, NO);
    ms_view_makeDisappear(_leftContainerView, NO);
    ms_view_makeDisappear(_bottomContainerView, NO);
    ms_view_makeDisappear(_rightContainerView, NO);
    ms_view_makeDisappear(_centerContainerView, NO);
    
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomDurationItemIfNeeded];
    
    _reachabilityObserver = [plume.reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkSpeedDidChangeExeBlock = ^(id<MSReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateNetworkSpeedStrForLoadingView];
    };
}

///
/// 当播放器尝试自动隐藏控制层之前 将会调用这个方法
///
- (BOOL)controlLayerOfPlumeCanAutomaticallyDisappear:(__kindof MSBornPlume *)plume {
    MSEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Progress];
    if ( progressItem != nil && !progressItem.isHidden ) {
        MSProgressSlider *slider = progressItem.customView;
        return !slider.isDragging;
    }
    return YES;
}

- (void)controlLayerNeedAppear:(__kindof MSBornPlume *)plume {
    if ( plume.isLockedScreen )
        return;
    
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)controlLayerNeedDisappear:(__kindof MSBornPlume *)plume {
    if ( plume.isLockedScreen )
        return;
    
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume prepareToPlay:(MSPlumeResource *)asset {
    _automaticallyFitOnScreen = NO;
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
}

- (void)plumePlaybackStatusDidChange:(__kindof MSBornPlume *)plume {
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateCurrentTimeForDraggingProgressPopupViewIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume durationDidChange:(NSTimeInterval)duration {
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume playableDurationDidChange:(NSTimeInterval)duration {
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume playbackTypeDidChange:(MSPlaybackType)playbackType {
    MSEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_CurrentTime];
    MSEdgeControlButtonItem *separatorItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Separator];
    MSEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_DurationTime];
    MSEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Progress];
    MSEdgeControlButtonItem *liveItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_LIVEText];
    switch ( playbackType ) {
        case MSPlaybackTypeLIVE: {
            currentTimeItem.innerHidden = YES;
            separatorItem.innerHidden = YES;
            durationTimeItem.innerHidden = YES;
            progressItem.innerHidden = YES;
            liveItem.innerHidden = NO;
        }
            break;
        case MSPlaybackTypeUnknown:
        case MSPlaybackTypeVOD:
        case MSPlaybackTypeFILE: {
            currentTimeItem.innerHidden = NO;
            separatorItem.innerHidden = NO;
            durationTimeItem.innerHidden = NO;
            progressItem.innerHidden = NO;
            liveItem.innerHidden = YES;
        }
            break;
    }
    [self.bottomAdapter reload];
    [self _showOrRemoveBottomProgressIndicator];
}

- (BOOL)canTriggerRotationOfPlume:(__kindof MSBornPlume *)plume {
    if ( _needsFitOnScreenFirst || _automaticallyFitOnScreen )
        return plume.isFitOnScreen;
    
    if ( _automaticallyFitOnScreen ) {
        if ( plume.isFitOnScreen ) return plume.allowsRotationInFitOnScreen;
        return NO;
    }
    
    return YES;
}

- (void)plume:(__kindof MSBornPlume *)plume willRotateView:(BOOL)isFull {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume didEndRotation:(BOOL)isFull {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

- (void)plume:(__kindof MSBornPlume *)plume willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

/// 是否可以触发播放器的手势
- (BOOL)plume:(__kindof MSBornPlume *)plume gestureRecognizerShouldTrigger:(MSCharmGestureType)type location:(CGPoint)location {
    MSEdgeControlButtonItemAdapter *adapter = nil;
    BOOL(^_locationInTheView)(UIView *) = ^BOOL(UIView *container) {
        return CGRectContainsPoint(container.frame, location) && !ms_view_isDisappeared(container);
    };
    
    if ( _locationInTheView(_topContainerView) ) {
        adapter = _topAdapter;
    }
    else if ( _locationInTheView(_bottomContainerView) ) {
        adapter = _bottomAdapter;
    }
    else if ( _locationInTheView(_leftContainerView) ) {
        adapter = _leftAdapter;
    }
    else if ( _locationInTheView(_rightContainerView) ) {
        adapter = _rightAdapter;
    }
    else if ( _locationInTheView(_centerContainerView) ) {
        adapter = _centerAdapter;
    }
    if ( !adapter ) return YES;
    
    CGPoint point = [self.plume_controlView convertPoint:location toView:adapter.view];
    if ( !CGRectContainsPoint(adapter.view.frame, point) ) return YES;
    
    MSEdgeControlButtonItem *_Nullable item = [adapter itemAtPoint:point];
    return item != nil ? (item.actions.count == 0)  : YES;
}

- (void)plume:(__kindof MSBornPlume *)plume panGestureTriggeredInTheHorizontalDirection:(MSPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case MSPanGestureRecognizerStateBegan:
            [self _willBeginDragging];
            break;
        case MSPanGestureRecognizerStateChanged:
            [self _didMove:progressTime];
            break;
        case MSPanGestureRecognizerStateEnded:
            [self _endDragging];
            break;
    }
}

- (void)plume:(__kindof MSBornPlume *)plume longPressGestureStateDidChange:(MSLongPressGestureRecognizerState)state {
    if ( [(id)self.speedupPlaybackPopupView respondsToSelector:@selector(layoutInRect:gestureState:playbackRate:)] ) {
        if ( state == MSLongPressGestureRecognizerStateBegan ) {
            if ( self.speedupPlaybackPopupView.superview != self ) {
                [self insertSubview:self.speedupPlaybackPopupView atIndex:0];
            }
        }
        [self.speedupPlaybackPopupView layoutInRect:self.frame gestureState:state playbackRate:plume.rate];
    }
    else {
        switch ( state ) {
            case MSLongPressGestureRecognizerStateChanged: break;
            case MSLongPressGestureRecognizerStateBegan: {
                if ( self.speedupPlaybackPopupView.superview != self ) {
                    [self insertSubview:self.speedupPlaybackPopupView atIndex:0];
                    [self.speedupPlaybackPopupView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.center.equalTo(self.topAdapter);
                    }];
                }
                self.speedupPlaybackPopupView.rate = plume.rateWhenLongPressGestureTriggered;
                [self.speedupPlaybackPopupView show];
            }
                break;
            case MSLongPressGestureRecognizerStateEnded: {
                [self.speedupPlaybackPopupView hidden];
            }
                break;
        }
    }
}

- (void)plume:(__kindof MSBornPlume *)plume presentationSizeDidChange:(CGSize)size {
    if ( _automaticallyPerformRotationOrFitOnScreen && !plume.iFurry && !plume.isFitOnScreen ) {
        _automaticallyFitOnScreen = size.width < size.height;
    }
}

/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof MSBornPlume *)plume {
    if ( ms_view_isDisappeared(_leftContainerView) ) {
        ms_view_makeAppear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl resume];
    }
    else {
        ms_view_makeDisappear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl interrupt];
    }
}

- (void)lockedPlume:(__kindof MSBornPlume *)plume {
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self.lockStateTappedTimerControl resume];
}

- (void)unlockedPlume:(__kindof MSBornPlume *)plume {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self.lockStateTappedTimerControl interrupt];
    [plume controlLayerNeedAppear];
}

- (void)plume:(MSBornPlume *)plume reachabilityChanged:(MSNetworkStatus)status {
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
    if ( _disabledPromptingWhenNetworkStatusChanges ) return;
    if ( [self.plume.auspicious isFileURL] ) return; // return when is local video.
}

#pragma mark -

- (NSString *)stringForSeconds:(NSInteger)secs {
    return _plume ? [_plume stringForSeconds:secs] : @"";
}

#pragma mark -

- (void)setHiddenBackButtonWhenOrientationIsPortrait:(BOOL)hiddenBackButtonWhenOrientationIsPortrait {
    if ( _hiddenBackButtonWhenOrientationIsPortrait != hiddenBackButtonWhenOrientationIsPortrait ) {
        _hiddenBackButtonWhenOrientationIsPortrait = hiddenBackButtonWhenOrientationIsPortrait;
        [self _updateAppearStateForFixedBackButtonIfNeeded];
        [self _reloadTopAdapterIfNeeded];
    }
}

- (void)setFixesBackItem:(BOOL)fixesBackItem {
    if ( fixesBackItem == _fixesBackItem )
        return;
    _fixesBackItem = fixesBackItem;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_fixesBackItem ) {
            [self.plume_controlView addSubview:self.fixedBackButton];
            [self->_fixedBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.equalTo(self.topAdapter.view);
                make.width.equalTo(self.topAdapter.view.mas_height);
            }];
            
            [self _updateAppearStateForFixedBackButtonIfNeeded];
            [self _reloadTopAdapterIfNeeded];
        }
        else {
            if ( self->_fixedBackButton ) {
                [self->_fixedBackButton removeFromSuperview];
                self->_fixedBackButton = nil;
                
                // back item
                [self _reloadTopAdapterIfNeeded];
            }
        }
    });
}

- (void)setHiddenBottomProgressIndicator:(BOOL)hiddenBottomProgressIndicator {
    if ( hiddenBottomProgressIndicator != _hiddenBottomProgressIndicator ) {
        _hiddenBottomProgressIndicator = hiddenBottomProgressIndicator;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _showOrRemoveBottomProgressIndicator];
        });
    }
}

- (void)setBottomProgressIndicatorHeight:(CGFloat)bottomProgressIndicatorHeight {
    if ( bottomProgressIndicatorHeight != _bottomProgressIndicatorHeight ) {
        
        _bottomProgressIndicatorHeight = bottomProgressIndicatorHeight;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _updateLayoutForBottomProgressIndicator];
        });
    }
}

- (void)setLoadingView:(nullable UIView<MSLoadingView> *)loadingView {
    if ( loadingView != _loadingView ) {
        [_loadingView removeFromSuperview];
        _loadingView = loadingView;
        if ( loadingView != nil ) {
            [self.plume_controlView addSubview:loadingView];
            [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }
    }
}

- (void)setDraggingProgressPopupView:(nullable __kindof UIView<MSDraggingProgressPopupView> *)draggingProgressPopupView {
    _draggingProgressPopupView = draggingProgressPopupView;
    [self _updateForDraggingProgressPopupView];
}

- (void)setTitleView:(nullable __kindof UIView<MSScrollingTextMarqueeView> *)titleView {
    _titleView = titleView;
    [self _reloadTopAdapterIfNeeded];
}

- (void)setCustomStatusBar:(UIView<MSFullscreenModeStatusBar> *)customStatusBar NS_AVAILABLE_IOS(11.0) {
    if ( customStatusBar != _customStatusBar ) {
        [_customStatusBar removeFromSuperview];
        _customStatusBar = customStatusBar;
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)setShouldShowsCustomStatusBar:(BOOL (^)(MSEdgeControlLayer * _Nonnull))shouldShowsCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    _shouldShowsCustomStatusBar = shouldShowsCustomStatusBar;
    [self _updateAppearStateForCustomStatusBar];
}

- (void)setSpeedupPlaybackPopupView:(UIView<MSSpeedupPlaybackPopupView> *)speedupPlaybackPopupView {
    if ( _speedupPlaybackPopupView != speedupPlaybackPopupView ) {
        [_speedupPlaybackPopupView removeFromSuperview];
        _speedupPlaybackPopupView = speedupPlaybackPopupView;
    }
}

#pragma mark - setup view

- (void)_setupView {
    [self _addItemsToTopAdapter];
    [self _addItemsToLeftAdapter];
    [self _addItemsToBottomAdapter];
    [self _addItemsToRightAdapter];
    [self _addItemsToCenterAdapter];
    
    self.topContainerView.sjv_disappearDirection = MSViewDisappearAnimation_Top;
    self.leftContainerView.sjv_disappearDirection = MSViewDisappearAnimation_Left;
    self.bottomContainerView.sjv_disappearDirection = MSViewDisappearAnimation_Bottom;
    self.rightContainerView.sjv_disappearDirection = MSViewDisappearAnimation_Right;
    self.centerContainerView.sjv_disappearDirection = MSViewDisappearAnimation_None;
    
    ms_view_initializes(@[self.topContainerView, self.leftContainerView,
                          self.bottomContainerView, self.rightContainerView]);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resetControlLayerAppearIntervalForItemIfNeeded:) name:MSEdgeControlButtonItemPerformedActionNotification object:nil];
    
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(configurationsDidUpdate:) name:MSPlumeConfigurationsDidUpdateNotification object:nil];
}

@synthesize fixedBackButton = _fixedBackButton;
- (UIButton *)fixedBackButton {
    if ( _fixedBackButton ) return _fixedBackButton;
    _fixedBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fixedBackButton setImage:MSPlumeConfigurations.shared.resources.backImage forState:UIControlStateNormal];
    [_fixedBackButton addTarget:self action:@selector(_fixedBackButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    return _fixedBackButton;
}

@synthesize bottomProgressIndicator = _bottomProgressIndicator;
- (MSProgressSlider *)bottomProgressIndicator {
    if ( _bottomProgressIndicator ) return _bottomProgressIndicator;
    _bottomProgressIndicator = [MSProgressSlider new];
    _bottomProgressIndicator.pan.enabled = NO;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    _bottomProgressIndicator.round = NO;
    id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
    UIColor *traceColor = sources.bottomIndicatorTraceColor ?: sources.progressTraceColor;
    UIColor *trackColor = sources.bottomIndicatorTrackColor ?: sources.progressTrackColor;
    _bottomProgressIndicator.traceImageView.backgroundColor = traceColor;
    _bottomProgressIndicator.trackImageView.backgroundColor = trackColor;
    _bottomProgressIndicator.frame = CGRectMake(0, self.bounds.size.height - _bottomProgressIndicatorHeight, self.bounds.size.width, _bottomProgressIndicatorHeight);
    _bottomProgressIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return _bottomProgressIndicator;
}

@synthesize loadingView = _loadingView;
- (UIView<MSLoadingView> *)loadingView {
    if ( _loadingView == nil ) {
        [self setLoadingView:[MSLoadingView.alloc initWithFrame:CGRectZero]];
    }
    return _loadingView;
}

- (__kindof UIView<MSDraggingProgressPopupView> *)draggingProgressPopupView {
    if ( _draggingProgressPopupView == nil ) {
        [self setDraggingProgressPopupView:[MSDraggingProgressPopupView.alloc initWithFrame:CGRectZero]];
    }
    return _draggingProgressPopupView;
}

- (id<MSDraggingObservation>)draggingObserver {
    if ( _draggingObserver == nil ) {
        _draggingObserver = [MSDraggingObservation new];
    }
    return _draggingObserver;
}

@synthesize lockStateTappedTimerControl = _lockStateTappedTimerControl;
- (MSTimerControl *)lockStateTappedTimerControl {
    if ( _lockStateTappedTimerControl ) return _lockStateTappedTimerControl;
    _lockStateTappedTimerControl = [[MSTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _lockStateTappedTimerControl.exeBlock = ^(MSTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        ms_view_makeDisappear(self.leftContainerView, YES);
        [control interrupt];
    };
    return _lockStateTappedTimerControl;
}

@synthesize titleView = _titleView;
- (UIView<MSScrollingTextMarqueeView> *)titleView {
    if ( _titleView == nil ) {
        [self setTitleView:[MSScrollingTextMarqueeView.alloc initWithFrame:CGRectZero]];
    }
    return _titleView;
}

@synthesize speedupPlaybackPopupView = _speedupPlaybackPopupView;
- (UIView<MSSpeedupPlaybackPopupView> *)speedupPlaybackPopupView {
    if ( _speedupPlaybackPopupView == nil ) {
        _speedupPlaybackPopupView = [MSSpeedupPlaybackPopupView.alloc initWithFrame:CGRectZero];
    }
    return _speedupPlaybackPopupView;
}

@synthesize customStatusBar = _customStatusBar;
- (UIView<MSFullscreenModeStatusBar> *)customStatusBar {
    if ( _customStatusBar == nil ) {
        [self setCustomStatusBar:[MSFullscreenModeStatusBar.alloc initWithFrame:CGRectZero]];
    }
    return _customStatusBar;
}

@synthesize shouldShowsCustomStatusBar = _shouldShowsCustomStatusBar;
- (BOOL (^)(MSEdgeControlLayer * _Nonnull))shouldShowsCustomStatusBar {
    if ( _shouldShowsCustomStatusBar == nil ) {
        BOOL is_iPhoneXSeries = _screen.is_iPhoneXSeries;
        [self setShouldShowsCustomStatusBar:^BOOL(MSEdgeControlLayer * _Nonnull controlLayer) {
            if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ) return NO;
            
            if ( controlLayer.plume.isFitOnScreen ) return NO;
            if ( controlLayer.plume.rotationManager.isRotating ) return NO;
            
            BOOL isFullscreen = controlLayer.plume.iFurry;
            if ( isFullscreen == NO ) {
                CGRect bounds = UIScreen.mainScreen.bounds;
                if ( bounds.size.width > bounds.size.height )
                    isFullscreen = CGRectEqualToRect(controlLayer.bounds, bounds);
            }
            
            BOOL shouldShow = NO;
            if ( isFullscreen ) {
                ///
                /// 13 以后, 全屏后显示自定义状态栏
                ///
                if ( @available(iOS 13.0, *) ) {
                    shouldShow = YES;
                }
                ///
                /// 11 仅 iPhone X 显示自定义状态栏
                ///
                else if ( @available(iOS 11.0, *) ) {
                    shouldShow = is_iPhoneXSeries;
                }
            }
            return shouldShow;
        }];
    }
    return _shouldShowsCustomStatusBar;
}

@synthesize dateTimerControl = _dateTimerControl;
- (MSTimerControl *)dateTimerControl {
    if ( _dateTimerControl == nil ) {
        _dateTimerControl = MSTimerControl.alloc.init;
        _dateTimerControl.interval = 1;
        __weak typeof(self) _self = self;
        _dateTimerControl.exeBlock = ^(MSTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.customStatusBar.isHidden ? [control interrupt] : [self _reloadCustomStatusBarIfNeeded];
        };
    }
    return _dateTimerControl;
}

- (void)_addItemsToTopAdapter {
    MSEdgeControlButtonItem *backItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSEdgeControlLayerTopItem_Back];
    backItem.resetsAppearIntervalWhenPerformingItemAction = NO;
    [backItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_backItemWasTapped)]];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    MSEdgeControlButtonItem *titleItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49xFill tag:MSEdgeControlLayerTopItem_Title];
    [self.topAdapter addItem:titleItem];
    
    [self.topAdapter reload];
}

- (void)_addItemsToLeftAdapter {
    MSEdgeControlButtonItem *lockItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSEdgeControlLayerLeftItem_Lock];
    [lockItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_lockItemWasTapped)]];
    [self.leftAdapter addItem:lockItem];
    
    [self.leftAdapter reload];
}

- (void)_addItemsToBottomAdapter {
    // 播放按钮
    MSEdgeControlButtonItem *playItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSEdgeControlLayerBottomItem_Play];
    [playItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_playItemWasTapped)]];
    [self.bottomAdapter addItem:playItem];
    
    MSEdgeControlButtonItem *liveItem = [[MSEdgeControlButtonItem alloc] initWithTag:MSEdgeControlLayerBottomItem_LIVEText];
    liveItem.innerHidden = YES;
    [self.bottomAdapter addItem:liveItem];
    
    // 当前时间
    MSEdgeControlButtonItem *currentTimeItem = [MSEdgeControlButtonItem placeholderWithSize:8 tag:MSEdgeControlLayerBottomItem_CurrentTime];
    [self.bottomAdapter addItem:currentTimeItem];
    
    // 时间分隔符
    MSEdgeControlButtonItem *separatorItem = [[MSEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"/ ").font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }] target:nil action:NULL tag:MSEdgeControlLayerBottomItem_Separator];
    [self.bottomAdapter addItem:separatorItem];
    
    // 全部时长
    MSEdgeControlButtonItem *durationTimeItem = [MSEdgeControlButtonItem placeholderWithSize:8 tag:MSEdgeControlLayerBottomItem_DurationTime];
    [self.bottomAdapter addItem:durationTimeItem];
    
    // 播放进度条
    MSProgressSlider *slider = [MSProgressSlider new];
    slider.trackHeight = 3;
    slider.delegate = self;
    slider.tap.enabled = YES;
    slider.showsBufferProgress = YES;
    __weak typeof(self) _self = self;
    slider.tappedExeBlock = ^(MSProgressSlider * _Nonnull slider, CGFloat location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.plume.canSeekToTime && self.plume.canSeekToTime(self.plume) == NO ) {
            return;
        }
        
        if ( self.plume.aspect != MSAssetStatusReadyToPlay ) {
            return;
        }
    
        [self.plume seekToTime:location completionHandler:nil];
    };
    MSEdgeControlButtonItem *progressItem = [[MSEdgeControlButtonItem alloc] initWithCustomView:slider tag:MSEdgeControlLayerBottomItem_Progress];
    progressItem.insets = MSEdgeInsetsMake(8, 8);
    progressItem.fill = YES;
    [self.bottomAdapter addItem:progressItem];

    // 全屏按钮
    MSEdgeControlButtonItem *fullItem = [MSEdgeControlButtonItem placeholderWithType:MSButtonItemPlaceholderType_49x49 tag:MSEdgeControlLayerBottomItem_Full];
    fullItem.resetsAppearIntervalWhenPerformingItemAction = NO;
    [fullItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_fullItemWasTapped)]];
    [self.bottomAdapter addItem:fullItem];

    [self.bottomAdapter reload];
}

- (void)_addItemsToRightAdapter {
    
}

- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    MSEdgeControlButtonItem *replayItem = [MSEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:MSEdgeControlLayerCenterItem_Replay];
    [replayItem addAction:[MSEdgeControlButtonItemAction actionWithTarget:self action:@selector(_replayItemWasTapped)]];
    [self.centerAdapter addItem:replayItem];
    [self.centerAdapter reload];
}


#pragma mark - appear state

- (void)_updateAppearStateForContainerViews {
    [self _updateAppearStateForTopContainerView];
    [self _updateAppearStateForLeftContainerView];
    [self _updateAppearStateForBottomContainerView];
    [self _updateAppearStateForRightContainerView];
    [self _updateAppearStateForCenterContainerView];
    if (@available(iOS 11.0, *)) {
        [self _updateAppearStateForCustomStatusBar];
    }
}

- (void)_updateAppearStateForTopContainerView {
    if ( 0 == _topAdapter.numberOfItems ) {
        ms_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _plume.isLockedScreen ) {
        ms_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _plume.isControlLayerAppeared ) {
        ms_view_makeAppear(_topContainerView, YES);
    }
    else {
        ms_view_makeDisappear(_topContainerView, YES);
    }
}

- (void)_updateAppearStateForLeftContainerView {
    if ( 0 == _leftAdapter.numberOfItems ) {
        ms_view_makeDisappear(_leftContainerView, YES);
        return;
    }
    
    /// 锁屏状态下显示
    if ( _plume.isLockedScreen ) {
        ms_view_makeAppear(_leftContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _plume.isControlLayerAppeared ) {
        ms_view_makeAppear(_leftContainerView, YES);
    }
    else {
        ms_view_makeDisappear(_leftContainerView, YES);
    }
}

/// 更新显示状态
- (void)_updateAppearStateForBottomContainerView {
    if ( 0 == _bottomAdapter.numberOfItems ) {
        ms_view_makeDisappear(_bottomContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _plume.isLockedScreen ) {
        ms_view_makeDisappear(_bottomContainerView, YES);
//        ms_view_makeAppear(_bottomProgressIndicator, YES);
        return;
    }
    
    /// 是否显示
    if ( _plume.isControlLayerAppeared ) {
        ms_view_makeAppear(_bottomContainerView, YES);
//        ms_view_makeDisappear(_bottomProgressIndicator, YES);
    }
    else {
        ms_view_makeDisappear(_bottomContainerView, YES);
//        ms_view_makeAppear(_bottomProgressIndicator, YES);
    }
}

/// 更新显示状态
- (void)_updateAppearStateForRightContainerView {
    if ( 0 == _rightAdapter.numberOfItems ) {
        ms_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _plume.isLockedScreen ) {
        ms_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _plume.isControlLayerAppeared ) {
        ms_view_makeAppear(_rightContainerView, YES);
    }
    else {
        ms_view_makeDisappear(_rightContainerView, YES);
    }
}

- (void)_updateAppearStateForCenterContainerView {
    if ( 0 == _centerAdapter.numberOfItems ) {
        ms_view_makeDisappear(_centerContainerView, YES);
        return;
    }
    
    ms_view_makeAppear(_centerContainerView, YES);
}

- (void)_updateAppearStateForBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator == nil )
        return;
    
    BOOL hidden = (_plume.isControlLayerAppeared && !_plume.isLockedScreen) || (_plume.isRotating);
    
    hidden ? ms_view_makeDisappear(_bottomProgressIndicator, NO) :
             ms_view_makeAppear(_bottomProgressIndicator, NO);
}

- (void)_updateAppearStateForCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    BOOL shouldShow = self.shouldShowsCustomStatusBar(self);
    if ( shouldShow ) {
        if ( self.customStatusBar.superview == nil ) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIDevice.currentDevice.batteryMonitoringEnabled = YES;
            });
            
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryStateDidChangeNotification object:nil];
            
            self.customStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self.topContainerView addSubview:self.customStatusBar];
        }
        CGFloat containerW = self.topContainerView.frame.size.width;
        CGFloat statusBarW = self.topAdapter.frame.size.width;
        CGFloat startX = (containerW - statusBarW) * 0.5;
        self.customStatusBar.frame = CGRectMake(startX, 0, self.topAdapter.bounds.size.width, 20);
    }
    
    _customStatusBar.hidden = !shouldShow;
    _customStatusBar.isHidden ? [self.dateTimerControl interrupt] : [self.dateTimerControl resume];
}

#pragma mark - update items

- (void)_reloadAdaptersIfNeeded {
    [self _reloadTopAdapterIfNeeded];
    [self _reloadLeftAdapterIfNeeded];
    [self _reloadBottomAdapterIfNeeded];
    [self _reloadRightAdapterIfNeeded];
    [self _reloadCenterAdapterIfNeeded];
}

- (void)_reloadTopAdapterIfNeeded {
    if ( ms_view_isDisappeared(_topContainerView) ) return;
    id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
    BOOL isFullscreen = _plume.iFurry;
    BOOL isFitOnScreen = _plume.isFitOnScreen;
    BOOL isSmallscreen = !isFullscreen && !isFitOnScreen;

    // back item
    {
        MSEdgeControlButtonItem *backItem = [self.topAdapter itemForTag:MSEdgeControlLayerTopItem_Back];
        if ( backItem != nil ) {
            if ( _fixesBackItem ) {
                if ( !isFullscreen && _hiddenBackButtonWhenOrientationIsPortrait )
                    backItem.innerHidden = YES;
                else
                    backItem.innerHidden = NO;
            }
            else {
                if ( isFullscreen || isFitOnScreen )
                    backItem.innerHidden = NO;
                else if ( _hiddenBackButtonWhenOrientationIsPortrait )
                    backItem.innerHidden = YES;
            }

            if ( backItem.hidden == NO ) {
                backItem.alpha = 1.0;
                backItem.image = _fixesBackItem ? nil : sources.backImage;
            }
            else {
                backItem.alpha = 0;
                backItem.image = nil;
            }
        }
    }
    
    // title item
    {
        MSEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:MSEdgeControlLayerTopItem_Title];
        if ( titleItem != nil ) {
            if ( self.isHiddenTitleItemWhenOrientationIsPortrait && isSmallscreen ) {
                titleItem.innerHidden = YES;
            }
            else {
                if ( titleItem.customView != self.titleView )
                    titleItem.customView = self.titleView;
                MSPlumeResource *asset = _plume.resource.original ?: _plume.resource;
                NSAttributedString *_Nullable attributedTitle = asset.attributedTitle;
                self.titleView.attributedText = attributedTitle;
                titleItem.innerHidden = (attributedTitle.length == 0);
            }

            if ( titleItem.hidden == NO ) {
                // margin
                NSInteger atIndex = [_topAdapter indexOfItemForTag:MSEdgeControlLayerTopItem_Title];
                CGFloat left  = [_topAdapter isHiddenWithRange:NSMakeRange(0, atIndex)] ? 16 : 0;
                CGFloat right = [_topAdapter isHiddenWithRange:NSMakeRange(atIndex, _topAdapter.numberOfItems)] ? 16 : 0;
                titleItem.insets = MSEdgeInsetsMake(left, right);
            }
        }
    }
    
    [_topAdapter reload];
}

- (void)_reloadLeftAdapterIfNeeded {
    if ( ms_view_isDisappeared(_leftContainerView) ) return;
    
    BOOL isFullscreen = _plume.iFurry;
    BOOL isLockedScreen = _plume.isLockedScreen;
    BOOL showsLockItem = isFullscreen && !_plume.rotationManager.isRotating;

    MSEdgeControlButtonItem *lockItem = [self.leftAdapter itemForTag:MSEdgeControlLayerLeftItem_Lock];
    if ( lockItem != nil ) {
        lockItem.innerHidden = !showsLockItem;
        if ( showsLockItem ) {
            id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
            lockItem.image = isLockedScreen ? sources.lockImage : sources.unlockImage;
        }
    }
    
    [_leftAdapter reload];
}

- (void)_reloadBottomAdapterIfNeeded {
    if ( ms_view_isDisappeared(_bottomContainerView) ) return;
    
    id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
    id<MSPlumeLocalizedStrings> strings = MSPlumeConfigurations.shared.localizedStrings;
    
    // play item
    {
        MSEdgeControlButtonItem *playItem = [self.bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Play];
        if ( playItem != nil && playItem.hidden == NO ) {
            playItem.image = _plume.iPeached ? sources.playImage : sources.pauseImage;
        }
    }
    
    // progress item
    {
        MSEdgeControlButtonItem *progressItem = [self.bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Progress];
        if ( progressItem != nil && progressItem.hidden == NO ) {
            MSProgressSlider *slider = progressItem.customView;
            slider.traceImageView.backgroundColor = sources.progressTraceColor;
            slider.trackImageView.backgroundColor = sources.progressTrackColor;
            slider.bufferProgressColor = sources.progressBufferColor;
            slider.trackHeight = sources.progressTrackHeight;
            slider.loadingColor = sources.loadingLineColor;
            
            if ( sources.progressThumbImage ) {
                slider.thumbImageView.image = sources.progressThumbImage;
            }
            else if ( sources.progressThumbSize ) {
                [slider setThumbCornerRadius:sources.progressThumbSize * 0.5 size:CGSizeMake(sources.progressThumbSize, sources.progressThumbSize) thumbBackgroundColor:sources.progressThumbColor];
            }
        }
    }
    
    // full item
    {
        MSEdgeControlButtonItem *fullItem = [self.bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Full];
        if ( fullItem != nil && fullItem.hidden == NO ) {
            BOOL isFullscreen = _plume.iFurry;
            BOOL isFitOnScreen = _plume.isFitOnScreen;
            fullItem.image = (isFullscreen || isFitOnScreen) ? sources.smallScreenImage : sources.fullscreenImage;
        }
    }
    
    // live text
    {
        MSEdgeControlButtonItem *liveItem = [self.bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_LIVEText];
        if ( liveItem != nil && liveItem.hidden == NO ) {
            liveItem.title = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(strings.liveBroadcast);
                make.font(sources.titleLabelFont);
                make.textColor(sources.titleLabelColor);
                make.shadow(^(NSShadow * _Nonnull make) {
                    make.shadowOffset = CGSizeMake(0, 0.5);
                    make.shadowColor = UIColor.blackColor;
                });
            }];
        }
    }
    
    [_bottomAdapter reload];
}

- (void)_reloadRightAdapterIfNeeded {
//    if ( ms_view_isDisappeared(_rightContainerView) ) return;
    
}

- (void)_reloadCenterAdapterIfNeeded {
    if ( ms_view_isDisappeared(_centerContainerView) ) return;
    
    MSEdgeControlButtonItem *replayItem = [self.centerAdapter itemForTag:MSEdgeControlLayerCenterItem_Replay];
    if ( replayItem != nil ) {
        replayItem.innerHidden = !_plume.isPlaybackFinished;
        if ( replayItem.hidden == NO && replayItem.title == nil ) {
            id<MSPlumeControlLayerResources> resources = MSPlumeConfigurations.shared.resources;
            id<MSPlumeLocalizedStrings> strings = MSPlumeConfigurations.shared.localizedStrings;
            UILabel *textLabel = replayItem.customView;
            textLabel.attributedText = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
                make.alignment(NSTextAlignmentCenter).lineSpacing(6);
                make.font(resources.replayTitleFont);
                make.textColor(resources.replayTitleColor);
                if ( resources.replayImage != nil ) {
                    make.appendImage(^(id<MSUTImageAttachment>  _Nonnull make) {
                        make.image = resources.replayImage;
                    });
                }
                if ( strings.replay.length != 0 ) {
                    if ( resources.replayImage != nil ) make.append(@"\n");
                    make.append(strings.replay);
                }
            }];
            textLabel.bounds = (CGRect){CGPointZero, [textLabel.attributedText ms_textSize]};
        }
    }
    
    [_centerAdapter reload];
}

- (void)_updateContentForBottomCurrentTimeItemIfNeeded {
    if ( ms_view_isDisappeared(_bottomContainerView) )
        return;
    NSString *currentTimeStr = [_plume stringForSeconds:_plume.currentTime];
    MSEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_CurrentTime];
    if ( currentTimeItem != nil && currentTimeItem.isHidden == NO ) {
        currentTimeItem.title = [self _textForTimeString:currentTimeStr];
        [_bottomAdapter updateContentForItemWithTag:MSEdgeControlLayerBottomItem_CurrentTime];
    }
}

- (void)_updateContentForBottomDurationItemIfNeeded {
    MSEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_DurationTime];
    if ( durationTimeItem != nil && durationTimeItem.isHidden == NO ) {
        durationTimeItem.title = [self _textForTimeString:[_plume stringForSeconds:_plume.duration]];
        [_bottomAdapter updateContentForItemWithTag:MSEdgeControlLayerBottomItem_DurationTime];
    }
}

- (void)_reloadSizeForBottomTimeLabel {
    // 00:00
    // 00:00:00
    NSString *ms = @"00:00";
    NSString *hms = @"00:00:00";
    NSString *durationTimeStr = [_plume stringForSeconds:_plume.duration];
    NSString *format = (durationTimeStr.length == ms.length)?ms:hms;
    CGSize formatSize = [[self _textForTimeString:format] ms_textSize];
    
    MSEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_CurrentTime];
    MSEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_DurationTime];
    
    if ( !durationTimeItem && !currentTimeItem ) return;
    currentTimeItem.size = formatSize.width;
    durationTimeItem.size = formatSize.width;
    [_bottomAdapter reload];
}

- (void)_updateContentForBottomProgressSliderItemIfNeeded {
    if ( !ms_view_isDisappeared(_bottomContainerView) ) {
        MSEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:MSEdgeControlLayerBottomItem_Progress];
        if ( progressItem != nil && !progressItem.isHidden ) {
            MSProgressSlider *slider = progressItem.customView;
            slider.maxValue = _plume.duration ? : 1;
            if ( !slider.isDragging ) slider.value = _plume.currentTime;
            slider.bufferProgress = _plume.playableDuration / slider.maxValue;
        }
    }
}

- (void)_updateContentForBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator != nil && !ms_view_isDisappeared(_bottomProgressIndicator) ) {
        _bottomProgressIndicator.value = _plume.currentTime;
        _bottomProgressIndicator.maxValue = _plume.duration ? : 1;
    }
}

- (void)_updateCurrentTimeForDraggingProgressPopupViewIfNeeded {
    if ( !ms_view_isDisappeared(_draggingProgressPopupView) )
        _draggingProgressPopupView.currentTime = _plume.currentTime;
}

- (void)_updateAppearStateForFixedBackButtonIfNeeded {
    if ( !_fixesBackItem )
        return;
    BOOL isFitOnScreen = _plume.isFitOnScreen;
    BOOL isFullscreen = _plume.iFurry;
    BOOL isLockedScreen = _plume.isLockedScreen;
    if ( isLockedScreen ) {
        _fixedBackButton.hidden = YES;
    }
    else if ( _hiddenBackButtonWhenOrientationIsPortrait && !isFullscreen ) {
        _fixedBackButton.hidden = YES;
    }
    else {
        _fixedBackButton.hidden = !isFitOnScreen && !isFullscreen;
    }
}

- (void)_updateNetworkSpeedStrForLoadingView {
    if ( !_plume || !self.loadingView.isAnimating )
        return;
    
    if ( self.loadingView.showsNetworkSpeed && !_plume.auspicious.isFileURL ) {
        self.loadingView.networkSpeedStr = [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
            id<MSPlumeControlLayerResources> resources = MSPlumeConfigurations.shared.resources;
            make.font(resources.loadingNetworkSpeedTextFont);
            make.textColor(resources.loadingNetworkSpeedTextColor);
            make.alignment(NSTextAlignmentCenter);
            make.append(self.plume.reachability.networkSpeedStr);
        }];
    }
    else {
        self.loadingView.networkSpeedStr = nil;
    }
}

- (void)_reloadCustomStatusBarIfNeeded NS_AVAILABLE_IOS(11.0) {
    if ( ms_view_isDisappeared(_customStatusBar) )
        return;
    _customStatusBar.networkStatus = _plume.reachability.networkStatus;
    _customStatusBar.date = NSDate.date;
    _customStatusBar.batteryState = UIDevice.currentDevice.batteryState;
    _customStatusBar.batteryLevel = UIDevice.currentDevice.batteryLevel;
}

#pragma mark -

- (void)_updateForDraggingProgressPopupView {
    MSDraggingProgressPopupViewStyle style = MSDraggingProgressPopupViewStyleNormal;
    if ( !_plume.resource.iSpecial &&
         [_plume.playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        if ( _plume.iFurry ) {
            style = MSDraggingProgressPopupViewStyleFullscreen;
        }
        else if ( _plume.isFitOnScreen ) {
            style = MSDraggingProgressPopupViewStyleFitOnScreen;
        }
    }
    _draggingProgressPopupView.style = style;
    _draggingProgressPopupView.duration = _plume.duration ?: 1;
    _draggingProgressPopupView.currentTime = _plume.currentTime;
    _draggingProgressPopupView.dragTime = _plume.currentTime;
}

- (nullable NSAttributedString *)_textForTimeString:(NSString *)timeStr {
    id<MSPlumeControlLayerResources> resources = MSPlumeConfigurations.shared.resources;
    return [NSAttributedString ms_UIKitText:^(id<MSUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(timeStr).font(resources.timeLabelFont).textColor(resources.timeLabelColor).alignment(NSTextAlignmentCenter);
    }];
}

/// 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
- (void)_resetControlLayerAppearIntervalForItemIfNeeded:(NSNotification *)note {
    MSEdgeControlButtonItem *item = note.object;
    if ( item.resetsAppearIntervalWhenPerformingItemAction ) {
        if ( [_topAdapter containsItem:item] ||
             [_leftAdapter containsItem:item] ||
             [_bottomAdapter containsItem:item] ||
             [_rightAdapter containsItem:item] )
            [_plume controlLayerNeedAppear];
    }
}

- (void)_showOrRemoveBottomProgressIndicator {
    if ( _hiddenBottomProgressIndicator || _plume.playbackType == MSPlaybackTypeLIVE ) {
        if ( _bottomProgressIndicator ) {
            [_bottomProgressIndicator removeFromSuperview];
            _bottomProgressIndicator = nil;
        }
    }
    else {
        if ( !_bottomProgressIndicator ) {
            [self.plume_controlView addSubview:self.bottomProgressIndicator];
            [self _updateLayoutForBottomProgressIndicator];
        }
    }
}

- (void)_updateLayoutForBottomProgressIndicator {
    if ( _bottomProgressIndicator == nil ) return;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    _bottomProgressIndicator.frame = CGRectMake(0, self.bounds.size.height - _bottomProgressIndicatorHeight, self.bounds.size.width, _bottomProgressIndicatorHeight);
}

- (void)_showOrHiddenLoadingView {
    if ( _plume == nil || _plume.resource == nil ) {
        [self.loadingView stop];
        return;
    }
    
    if ( _plume.iPeached ) {
        [self.loadingView stop];
    }
    else if ( _plume.aspect == MSAssetStatusPreparing ) {
        [self.loadingView start];
    }
    else if ( _plume.aspect == MSAssetStatusFailed ) {
        [self.loadingView stop];
    }
    else if ( _plume.aspect == MSAssetStatusReadyToPlay ) {
        self.plume.reasonForWaitingToPlay == MSWaitingToMinimizeStallsReason ? [self.loadingView start] : [self.loadingView stop];
    }
}

- (void)_willBeginDragging {
    [self.plume_controlView addSubview:self.draggingProgressPopupView];
    [self _updateForDraggingProgressPopupView];
    [_draggingProgressPopupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    ms_view_initializes(_draggingProgressPopupView);
    ms_view_makeAppear(_draggingProgressPopupView, NO);
    
    if ( _draggingObserver.willBeginDraggingExeBlock )
        _draggingObserver.willBeginDraggingExeBlock(_draggingProgressPopupView.dragTime);
}

- (void)_didMove:(NSTimeInterval)progressTime {
    _draggingProgressPopupView.dragTime = progressTime;
    // 是否生成预览图
    if ( _draggingProgressPopupView.isPreviewImageHidden == NO ) {
        __weak typeof(self) _self = self;
        [_plume screenshotWithTime:progressTime size:CGSizeMake(_draggingProgressPopupView.frame.size.width, _draggingProgressPopupView.frame.size.height) completion:^(MSBornPlume * _Nonnull plume, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressPopupView setPreviewImage:image];
        }];
    }
    
    if ( _draggingObserver.didMoveExeBlock )
        _draggingObserver.didMoveExeBlock(_draggingProgressPopupView.dragTime);
}

- (void)_endDragging {
    NSTimeInterval time = _draggingProgressPopupView.dragTime;
    if ( _draggingObserver.willEndDraggingExeBlock )
        _draggingObserver.willEndDraggingExeBlock(time);
    
    [_plume seekToTime:time completionHandler:nil];

    ms_view_makeDisappear(_draggingProgressPopupView, YES, ^{
        if ( ms_view_isDisappeared(self->_draggingProgressPopupView) ) {
            [self->_draggingProgressPopupView removeFromSuperview];
        }
    });
    
    if ( _draggingObserver.didEndDraggingExeBlock )
        _draggingObserver.didEndDraggingExeBlock(time);
}

@end


@implementation MSEdgeControlButtonItem (MSControlLayerExtended)
- (void)setResetsAppearIntervalWhenPerformingItemAction:(BOOL)resetsAppearIntervalWhenPerformingItemAction {
    objc_setAssociatedObject(self, @selector(resetsAppearIntervalWhenPerformingItemAction), @(resetsAppearIntervalWhenPerformingItemAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)resetsAppearIntervalWhenPerformingItemAction {
    id result = objc_getAssociatedObject(self, _cmd);
    return result == nil ? YES : [result boolValue];
}
@end
