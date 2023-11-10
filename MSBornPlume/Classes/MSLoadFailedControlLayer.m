//
//  MSLoadFailedControlLayer.m
//  MSPlume
//
//  Created by admin on 2018/10/27.
//  Copyright © 2018 admin. All rights reserved.
//

#import "MSLoadFailedControlLayer.h"
#import "MSPlumeConfigurations.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSLoadFailedControlLayer ()
@end

@implementation MSLoadFailedControlLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _updateSettings];
    return self;
}

- (void)_updateSettings {
    id<MSPlumeControlLayerResources> resources = MSPlumeConfigurations.shared.resources;
    id<MSPlumeLocalizedStrings> strings = MSPlumeConfigurations.shared.localizedStrings;
    [self.reloadView.button setTitle:strings.reload forState:UIControlStateNormal];
    self.reloadView.backgroundColor = resources.playFailedButtonBackgroundColor;
    self.promptLabel.text = strings.playbackFailedPrompt;
}
@end
NS_ASSUME_NONNULL_END
