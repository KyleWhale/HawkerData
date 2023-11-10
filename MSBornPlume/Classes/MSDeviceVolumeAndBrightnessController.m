//
//  MSDeviceVolumeAndBrightnessController.m
//  MSDeviceVolumeAndBrightnessController
//
//  Created by admin on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "MSDeviceVolumeAndBrightnessController.h"
#import "MSBornPlumeResourceLoader.h"
#import "MSBornPlumeConst.h"
#import "MSCharmView.h"
#import "MSDeviceVolumeAndBrightness.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "UIView+MSBornPlumeExtended.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<MSUIKit/NSObject+MSObserverHelper.h>)
#import <MSUIKit/NSObject+MSObserverHelper.h>
#import <MSUIKit/MSRunLoopTaskQueue.h>
#else
#import "NSObject+MSObserverHelper.h"
#import "MSRunLoopTaskQueue.h"
#endif
@protocol MSDeviceVolumeAndBrightnessPopupViewDataSource;

static NSNotificationName const MSDeviceVolumeDidChangeNotification = @"MSDeviceVolumeDidChangeNotification";
static NSNotificationName const MSDeviceBrightnessDidChangeNotification = @"MSDeviceBrightnessDidChangeNotification";

@interface MSDeviceVolumeAndBrightnessControllerObserver : NSObject<MSDeviceVolumeAndBrightnessControllerObserver>
- (instancetype)initWithMgr:(id<MSDeviceVolumeAndBrightnessController>)mgr;
@end

@implementation MSDeviceVolumeAndBrightnessControllerObserver {
    id _volumeDidChangeToken;
    id _brightnessDidChangeToken;
}
@synthesize volumeDidChangeExeBlock = _volumeDidChangeExeBlock;
@synthesize brightnessDidChangeExeBlock = _brightnessDidChangeExeBlock;

- (instancetype)initWithMgr:(id<MSDeviceVolumeAndBrightnessController>)mgr {
    self = [super init];
    if ( !self )
        return nil;
    __weak typeof(self) _self = self;
    _volumeDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:MSDeviceVolumeDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<MSDeviceVolumeAndBrightnessController> mgr = note.object;
        if ( self.volumeDidChangeExeBlock ) self.volumeDidChangeExeBlock(mgr, mgr.volume);
    }];
    
    _brightnessDidChangeToken = [NSNotificationCenter.defaultCenter addObserverForName:MSDeviceBrightnessDidChangeNotification object:mgr queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        id<MSDeviceVolumeAndBrightnessController> mgr = note.object;
        if ( self.brightnessDidChangeExeBlock ) self.brightnessDidChangeExeBlock(mgr, mgr.brightness);
    }];
    return self;
}

- (void)dealloc {
    if ( _volumeDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_volumeDidChangeToken];
    if ( _brightnessDidChangeToken ) [NSNotificationCenter.defaultCenter removeObserver:_brightnessDidChangeToken];
}
@end


#pragma mark - MSDeviceVolumeAndBrightnessPopupView

@interface MSDeviceVolumeAndBrightnessPopupView : UIView<MSDeviceVolumeAndBrightnessPopupView>
@property (nonatomic, strong) id<MSDeviceVolumeAndBrightnessPopupViewDataSource> dataSource;

- (void)refreshData;
@end

@interface MSDeviceVolumeAndBrightnessPopupView ()
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@end

@implementation MSDeviceVolumeAndBrightnessPopupView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)refreshData {
    _imageView.image = (_dataSource.progress > 0) ? _dataSource.image : (_dataSource.startImage ?: _dataSource.image);
    _progressView.progress = _dataSource.progress;
    _progressView.trackTintColor = _dataSource.trackColor;
    _progressView.progressTintColor = _dataSource.traceColor;
}

- (void)_setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    self.layer.cornerRadius = 5;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_imageView];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    _progressView.progress = 0.5;
    [self addSubview:_progressView];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.offset(0);
        make.width.equalTo(self.imageView.mas_height);
        make.height.offset(38);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(5);
        make.centerY.offset(0);
        make.right.offset(-12);
        make.height.offset(2);
        make.width.offset(100);
    }];
    
    [_imageView setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [_progressView setContentHuggingPriority:250 forAxis:UILayoutConstraintAxisHorizontal];
}
@end

@interface MSDeviceVolumeAndBrightnessPopupItem : NSObject<MSDeviceVolumeAndBrightnessPopupViewDataSource>
@property (nonatomic, strong, nullable) UIImage *startImage;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic) float progress;
@property (nonatomic, strong, null_resettable) UIColor *traceColor;
@property (nonatomic, strong, null_resettable) UIColor *trackColor;
@end
@implementation MSDeviceVolumeAndBrightnessPopupItem
- (UIColor *)traceColor {
    return _traceColor?:UIColor.whiteColor;
}

- (UIColor *)trackColor {
    return _trackColor?:[UIColor colorWithWhite:0.6 alpha:0.5];
}
@end

#pragma mark -

@interface MSDeviceVolumeAndBrightnessController ()<MSDeviceVolumeAndBrightnessObserver> {
    UIView *_sysVolumeView;
}
@end

@implementation MSDeviceVolumeAndBrightnessController
@synthesize target = _target;
@synthesize targetViewContext = _targetViewContext;

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _sysVolumeView = MSDeviceVolumeAndBrightness.shared.sysVolumeView;
    [MSDeviceVolumeAndBrightness.shared addObserver:self];
    [MSDeviceSystemVolumeViewDisplayManager.shared addController:self];
    return self;
}

- (void)dealloc {
    [MSDeviceVolumeAndBrightness.shared removeObserver:self];
    [MSDeviceSystemVolumeViewDisplayManager.shared removeController:self];
}

- (void)device:(MSDeviceVolumeAndBrightness *)device onVolumeChanged:(float)volume {
    [self _onVolumeChanged];
}

- (void)device:(MSDeviceVolumeAndBrightness *)device onBrightnessChanged:(float)brightness {
    [self _onBrightnessChanged];
}

- (id<MSDeviceVolumeAndBrightnessControllerObserver>)getObserver {
    return [[MSDeviceVolumeAndBrightnessControllerObserver alloc] initWithMgr:self];
}

- (void)onTargetViewMoveToWindow {
    [MSDeviceSystemVolumeViewDisplayManager.shared update];
}

- (void)onTargetViewContextUpdated {
    [MSDeviceSystemVolumeViewDisplayManager.shared update];
}

#pragma mark - volume

- (void)_onVolumeChanged {
    [self _showVolumeViewIfNeeded];
    [self _updateContentsForVolumeViewIfNeeded];
    [NSNotificationCenter.defaultCenter postNotificationName:MSDeviceVolumeDidChangeNotification object:self];
}

- (void)setVolume:(float)volume {
    MSDeviceVolumeAndBrightness.shared.volume = volume;
}

- (float)volume {
    return MSDeviceVolumeAndBrightness.shared.volume;
}

- (nullable UIView<MSDeviceVolumeAndBrightnessPopupView> *)volumeView {
    if ( _volumeView == nil ) {
        _volumeView = [MSDeviceVolumeAndBrightnessPopupView new];
        MSDeviceVolumeAndBrightnessPopupItem *model = [MSDeviceVolumeAndBrightnessPopupItem new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *muteImage = [MSBornPlumeResourceLoader imageNamed:@"mute"];
            UIImage *volumeImage = [MSBornPlumeResourceLoader imageNamed:@"volume"];
            dispatch_async(dispatch_get_main_queue(), ^{
                model.startImage = muteImage;
                model.image = volumeImage;
                [self->_volumeView refreshData];
            });
        });
        _volumeView.dataSource = model;
    }
    return _volumeView;
}

- (void)_showVolumeViewIfNeeded {
    if ( _sysVolumeView.superview == nil || !MSDeviceSystemVolumeViewDisplayManager.shared.automaticallyDisplaySystemVolumeView ) return;
    UIView *targetView = self.target;
    UIView *volumeView = self.volumeView;
    if ( targetView.window != nil && volumeView.superview != targetView ) {
        [targetView addSubview:volumeView];
        [volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideVolumeView) object:nil];
    [self performSelector:@selector(_hideVolumeView)
               withObject:nil
               afterDelay:1
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)_hideVolumeView {
    UIView *volumeView = self.volumeView;
    [volumeView removeFromSuperview];
}

- (void)_updateContentsForVolumeViewIfNeeded {
    if ( self.volumeView.superview == nil ) return;
    float volume = self.volume;
    self.volumeView.dataSource.progress = volume;
    [self.volumeView refreshData];
}

#pragma mark - brightness

- (void)_onBrightnessChanged {
    [self _showBrightnessView];
    [self _updateContentsForBrightnessViewIfNeeded];
    [NSNotificationCenter.defaultCenter postNotificationName:MSDeviceBrightnessDidChangeNotification object:self];
}

- (void)setBrightness:(float)brightness {
    MSDeviceVolumeAndBrightness.shared.brightness = brightness;
}

- (float)brightness {
    return MSDeviceVolumeAndBrightness.shared.brightness;
}

- (nullable UIView<MSDeviceVolumeAndBrightnessPopupView> *)brightnessView {
    if ( _brightnessView == nil ) {
        _brightnessView = [MSDeviceVolumeAndBrightnessPopupView new];
        
        MSDeviceVolumeAndBrightnessPopupItem *model = [MSDeviceVolumeAndBrightnessPopupItem new];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [MSBornPlumeResourceLoader imageNamed:@"brightness"];
            dispatch_async(dispatch_get_main_queue(), ^{
                model.startImage = image;
                model.image = image;
                [self->_brightnessView refreshData];
            });
        });
        _brightnessView.dataSource = model;
    }
    return _brightnessView;
}

- (void)_updateContentsForBrightnessViewIfNeeded {
    if (self.brightnessView.superview == nil ) return;
    float brightness = self.brightness;
    self.brightnessView.dataSource.progress = brightness;
    [self.brightnessView refreshData];
}

- (void)_showBrightnessView {
    UIView *targetView = self.target;
    UIView *brightnessView = self.brightnessView;
    
    if ( targetView != nil && brightnessView.superview != targetView ) {
        [targetView addSubview:brightnessView];
        [brightnessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
        }];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideBrightnessView) object:nil];
    [self performSelector:@selector(_hideBrightnessView)
               withObject:nil
               afterDelay:1
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)_hideBrightnessView {
    UIView *brightnessView = self.brightnessView;
    [brightnessView removeFromSuperview];
}
@end


@implementation MSDeviceSystemVolumeViewDisplayManager {
    NSHashTable<id<MSDeviceVolumeAndBrightnessController>> *mControllers;
    UIView *mSysVolumeView;
}

+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _automaticallyDisplaySystemVolumeView = YES;
        mControllers = NSHashTable.weakObjectsHashTable;
        mSysVolumeView = MSDeviceVolumeAndBrightness.shared.sysVolumeView;
        [self _makeHidingForSysVolumeView];
    }
    return self;
}

- (void)addController:(nullable id<MSDeviceVolumeAndBrightnessController>)controller {
    [mControllers addObject:controller];
}

- (void)removeController:(nullable id<MSDeviceVolumeAndBrightnessController>)controller {
    [mControllers removeObject:controller];
}

- (void)update {
//    1. 未显示或不在keyWindow中时则略过
//    2. 根据状态确定是否显示系统音量条
//       2.1 处于 fullscreen or fitOnScreen 隐藏系统条
//       2.2 小屏状态
//           2.2.1 在cell中播放, 显示系统条
//           2.2.2 小浮窗模式, 显示系统条
//           2.2.3 画中画模式, 显示系统条
//           2.2.x 常规模式隐藏系统条
    BOOL needsShowing = YES;
    if ( _automaticallyDisplaySystemVolumeView ) {
        for ( id<MSDeviceVolumeAndBrightnessController> controller in mControllers ) {
            UIView *targetView = controller.target;
            UIWindow *targetViewWindow = targetView.window;
            UIWindow *appKeyWindow = UIApplication.sharedApplication.keyWindow;
            if ( targetViewWindow == nil || targetViewWindow != appKeyWindow ) {
                // 1. 未显示或不在keyWindow中时则略过
                continue;
            }
            
            id<MSDeviceVolumeAndBrightnessTargetViewContext> ctx = controller.targetViewContext;
            // 2.1
            if ( ctx.isFullscreen || ctx.isFitOnScreen ) {
                needsShowing = NO;
                [self _makeHidingForSysVolumeView];
                break;
            }
            // 2.2
            else {
                // 2.2.1
                if ( ctx.isPlayOnScrollView ) {
                    needsShowing = NO;
                    [self _makeShowingForSysVolumeView];
                    break;
                }
                // 2.2.2
                if ( ctx.isFloatingMode ) {
                    needsShowing = NO;
                    [self _makeShowingForSysVolumeView];
                    break;
                }
                // 2.2.x
                needsShowing = NO;
                [self _makeHidingForSysVolumeView];
            }
        }
    }
    if ( needsShowing ) [self _makeShowingForSysVolumeView];
}

#pragma mark - mark

// 隐藏系统音量条
- (void)_makeHidingForSysVolumeView {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if ( mSysVolumeView.superview != window ) [window addSubview:mSysVolumeView];
}

// 显示系统音量条
- (void)_makeShowingForSysVolumeView {
    if ( mSysVolumeView.superview != nil ) [mSysVolumeView removeFromSuperview];
}
@end
