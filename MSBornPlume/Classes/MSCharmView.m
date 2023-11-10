//
//  MSCharmView.m
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import "MSCharmView.h"
#import "MSCharmViewInternal.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSCharmView ()
@property (nonatomic, strong, nullable) UIView *presentView;
@end

@implementation MSCharmView

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *_Nullable view = [super hitTest:point withEvent:event];
    
    if ( [self.delegate respondsToSelector:@selector(codeView:hitTestForView:)] ) {
        return [self.delegate codeView:self hitTestForView:view];
    }
    
    return view;
}

- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self.window != nil ) {
            if ( [self.delegate respondsToSelector:@selector(playerViewWillMoveToWindow:)] ) {
                [self.delegate playerViewWillMoveToWindow:self];
            }
        }
    });
}
@end
NS_ASSUME_NONNULL_END
