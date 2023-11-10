//
//  MSMoreSettingControlLayer.m
//  MSPlume_Example
//
//  Created by admin on 2019/7/19.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "MSMoreSettingControlLayer.h"
#import "UIView+MSAnimationAdded.h"
#import "MSButtonProgressSlider.h"
#import "MSPlumeConfigurations.h"

#if __has_include(<MSUIKit/MSAttributesFactory.h>)
#import <MSUIKit/MSAttributesFactory.h>
#else
#import "MSAttributesFactory.h"
#endif

#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSBornPlume.h>
#else
#import "MSBornPlume.h"
#endif

NS_ASSUME_NONNULL_BEGIN
MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Volume = 10000;
MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Brightness = 10001;
MSEdgeControlButtonItemTag const MSMoreSettingControlLayerItem_Rate = 10002;

@interface MSMoreSettingControlLayer ()<MSProgressSliderDelegate>
@property (nonatomic, weak, nullable) MSBornPlume *plume;
@end

@implementation MSMoreSettingControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (UIView *)plume_controlView {
    return self;
}

- (void)installedControlViewToPlume:(__kindof MSBornPlume *)plume {
    _plume = plume;
    
    ms_view_initializes(self.rightContainerView);
    
    [self layoutIfNeeded];
    
    ms_view_makeDisappear(self.rightContainerView, NO);
}

- (void)exitControlLayer {
    _restarted = NO;
    
    ms_view_makeDisappear(self.rightContainerView, YES);
    ms_view_makeDisappear(self.plume_controlView, YES, ^{
        if ( !self->_restarted ) [self.plume_controlView removeFromSuperview];
    });
}

- (void)restartControlLayer {
    _restarted = YES;
    
    if ( self.plume.iFurry )
        [self.plume needHiddenStatusBar];
    [self _refreshValueForSliderItems];
    ms_view_makeAppear(self.plume_controlView, YES);
    ms_view_makeAppear(self.rightContainerView, YES);
}

- (void)controlLayerNeedAppear:(__kindof MSBornPlume *)plume { }

- (void)controlLayerNeedDisappear:(__kindof MSBornPlume *)plume { }

- (BOOL)plume:(__kindof MSBornPlume *)plume gestureRecognizerShouldTrigger:(MSCharmGestureType)type location:(CGPoint)location {
    if ( type == MSCharmGestureType_SingleTap ) {
        if ( !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
            if ( [self.delegate respondsToSelector:@selector(tappedBlankAreaOnTheControlLayer:)] ) {
                [self.delegate tappedBlankAreaOnTheControlLayer:self];
            }
        }
    }
    else if ( type == MSCharmGestureType_Pan && !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
        return plume.gestureController.movingDirection == MSPanGestureMovingDirection_V;
    }
    else if ( type == MSCharmGestureType_DoubleTap )
        return YES;
    
    return NO;
}

- (BOOL)canTriggerRotationOfPlume:(__kindof MSBornPlume *)plume {
    return NO;
}

- (void)plume:(__kindof MSBornPlume *)plume volumeChanged:(float)volume {
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Volume value:volume];
}

- (void)plume:(__kindof MSBornPlume *)plume brightnessChanged:(float)brightness {
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Brightness value:brightness];
}

- (void)plume:(__kindof MSBornPlume *)plume rateChanged:(float)rate {
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Rate value:rate];
}

#pragma mark -

- (void)sliderWillBeginDragging:(MSProgressSlider *)slider { }

- (void)slider:(MSProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) {
        if ( slider.tag == MSMoreSettingControlLayerItem_Volume ) {
            _plume.deviceVolumeAndBrightnessController.volume = slider.value;
        }
        else if ( slider.tag == MSMoreSettingControlLayerItem_Brightness ) {
            _plume.deviceVolumeAndBrightnessController.brightness = slider.value;
        }
        else {
            _plume.rate = slider.value;
        }
    }
}

- (void)sliderDidEndDragging:(MSProgressSlider *)slider { }

#pragma mark -

- (void)_setupView {
    self.rightContainerView.sjv_disappearDirection = MSViewDisappearAnimation_Right;
    
    CGFloat max = MAX(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    self.rightWidth = floor(max * 0.382);
    
    CGFloat height = 60;
    
    {
        MSEdgeControlButtonItem *volumeItem = [MSEdgeControlButtonItem placeholderWithSize:height tag:MSMoreSettingControlLayerItem_Volume];
        MSButtonProgressSlider *progressView = MSButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = volumeItem.tag;
        volumeItem.customView = progressView;
        [self.rightAdapter addItem:volumeItem];
    }
    
    {
        MSEdgeControlButtonItem *brightnessItem = [MSEdgeControlButtonItem placeholderWithSize:height tag:MSMoreSettingControlLayerItem_Brightness];
        MSButtonProgressSlider *progressView = MSButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = brightnessItem.tag;
        brightnessItem.customView = progressView;
        [self.rightAdapter addItem:brightnessItem];
    }
    
    {
        MSEdgeControlButtonItem *rateItem = [MSEdgeControlButtonItem placeholderWithSize:height tag:MSMoreSettingControlLayerItem_Rate];
        MSButtonProgressSlider *progressView = MSButtonProgressSlider.new;
        progressView.slider.delegate = self;
        progressView.slider.tag = rateItem.tag;
        progressView.slider.maxValue = MSPlumeConfigurations.shared.resources.moreSliderMaxRateValue;
        progressView.slider.minValue = MSPlumeConfigurations.shared.resources.moreSliderMinRateValue;
        rateItem.customView = progressView;
        [self.rightAdapter addItem:rateItem];
    }
    
    [self _refreshSettings];
    [self.rightAdapter reload];
}

- (void)_refreshValueForSliderItems {
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Volume value:_plume.deviceVolumeAndBrightnessController.volume];
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Brightness value:_plume.deviceVolumeAndBrightnessController.brightness];
    [self _setSliderValueForItemTag:MSMoreSettingControlLayerItem_Rate value:_plume.rate];
}

- (void)_setSliderValueForItemTag:(MSEdgeControlButtonItemTag)itemTag value:(float)value {
    MSEdgeControlButtonItem *item = [self.rightAdapter itemForTag:itemTag];
    MSButtonProgressSlider *progressView = item.customView;
    if ( !progressView.slider.isDragging )
        progressView.slider.value = value;
}

- (void)_refreshSettings {
    id<MSPlumeControlLayerResources> sources = MSPlumeConfigurations.shared.resources;
    self.rightContainerView.backgroundColor = sources.moreControlLayerBackgroundColor;
    
    __auto_type _configProgressView = ^(MSButtonProgressSlider *progressView, UIImage *left, UIImage *right) {
        [progressView.rightBtn setImage:right forState:UIControlStateNormal];
        [progressView.leftBtn setImage:left forState:UIControlStateNormal];

        progressView.slider.traceImageView.backgroundColor = sources.moreSliderTraceColor;
        progressView.slider.trackImageView.backgroundColor = sources.moreSliderTrackColor;
        progressView.slider.trackHeight = sources.moreSliderTrackHeight;
        
        if ( sources.moreSliderThumbImage == nil ) {
            CGSize size = CGSizeMake(sources.moreSliderThumbSize, sources.moreSliderThumbSize);
            CGFloat radius = sources.moreSliderThumbSize * 0.5;
            [progressView.slider setThumbCornerRadius:radius size:size thumbBackgroundColor:sources.moreSliderTraceColor];
        }
        else {
            progressView.slider.thumbImageView.image = sources.moreSliderThumbImage;
        }
    };
    MSEdgeControlButtonItem *volumeItem = [self.rightAdapter itemForTag:MSMoreSettingControlLayerItem_Volume];
    _configProgressView(volumeItem.customView, sources.moreSliderMinVolumeImage, sources.moreSliderMaxVolumeImage);
    
    MSEdgeControlButtonItem *brightness = [self.rightAdapter itemForTag:MSMoreSettingControlLayerItem_Brightness];
    _configProgressView(brightness.customView, sources.moreSliderMinBrightnessImage, sources.moreSliderMaxBrightnessImage);
    
    MSEdgeControlButtonItem *rateItem = [self.rightAdapter itemForTag:MSMoreSettingControlLayerItem_Rate];
    _configProgressView(rateItem.customView, sources.moreSliderMinRateImage, sources.moreSliderMaxRateImage);
}
@end
NS_ASSUME_NONNULL_END
