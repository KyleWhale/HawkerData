//
//  MSSubtitlePopupController.m
//  MSBornPlume
//
//  Created by admin on 2019/11/8.
//

#import "MSSubtitlePopupController.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface MSSubtitlePopupController ()
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@end

@implementation MSSubtitlePopupController
@synthesize subtitles = _subtitles;
@synthesize numberOfLines = _numberOfLines;
@synthesize contentInsets = _contentInsets;
@synthesize currentTime = _currentTime;
@synthesize view = _view;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        [self _setupView];
    }
    return self;
}

- (UIView *)view {
    return _containerView;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    self.subtitleLabel.numberOfLines = numberOfLines;
}
- (NSInteger)numberOfLines {
    return self.subtitleLabel.numberOfLines;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self.subtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(contentInsets.top);
        make.left.offset(contentInsets.left);
        make.bottom.offset(-contentInsets.bottom);
        make.right.offset(-contentInsets.right);
    }];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    MSSubtitleItem *_Nullable item = [self _itemAtTime:currentTime];
    CGFloat alpha = (item == nil) ? 0.001 : 1;
    if ( alpha != self.containerView.alpha ) {
        [UIView animateWithDuration:0.25 animations:^{
            self.containerView.alpha = (item == nil) ? 0.001 : 1;
        }];
    }
    if ( item != nil && item.content != self.subtitleLabel.attributedText )
        self.subtitleLabel.attributedText = item.content;
}

#pragma mark -

- (nullable MSSubtitleItem *)_itemAtTime:(NSTimeInterval)time {
    for ( MSSubtitleItem *item in _subtitles ) {
        if ( MSTimeRangeContainsTime(time, item.range) ) {
            return item;
        }
    }
    return nil;
}

- (void)_setupView {
    _containerView = [UIView.alloc initWithFrame:CGRectZero];
    _subtitleLabel = [UILabel.alloc initWithFrame:CGRectZero];
    _subtitleLabel.numberOfLines = 0;
    [_containerView addSubview:_subtitleLabel];
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}
@end
NS_ASSUME_NONNULL_END
