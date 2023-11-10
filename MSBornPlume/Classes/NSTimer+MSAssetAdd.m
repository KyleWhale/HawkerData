//
//  NSTimer+MSAssetAdd.m
//  MSPlumeAssetCarrier
//
//  Created by admin on 2018/5/21.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "NSTimer+MSAssetAdd.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
@implementation NSTimer (MSAssetAdd)
+ (void)ms_exeUsingBlock:(NSTimer *)timer {
    if ( timer.ms_usingBlock != nil ) timer.ms_usingBlock(timer);
}

+ (NSTimer *)ms_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats {
    return [self ms_timerWithTimeInterval:interval repeats:repeats usingBlock:nil];
}

+ (NSTimer *)ms_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats usingBlock:(void(^_Nullable)(NSTimer *timer))usingBlock {
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(ms_exeUsingBlock:) userInfo:nil repeats:repeats];
    timer.ms_usingBlock = usingBlock;
    return timer;
}

- (void)setMs_usingBlock:(void (^_Nullable)(NSTimer * _Nonnull))ms_usingBlock {
    objc_setAssociatedObject(self, @selector(ms_usingBlock), ms_usingBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^_Nullable)(NSTimer * _Nonnull))ms_usingBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)ms_fire {
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}
@end

@implementation NSTimer (MSDeprecated)
+ (NSTimer *)assetAdd_timerWithTimeInterval:(NSTimeInterval)ti
                                      block:(void(^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats {
    return [self ms_timerWithTimeInterval:ti repeats:repeats usingBlock:block];
}

- (void)assetAdd_fire {
    [self ms_fire];
}
@end
NS_ASSUME_NONNULL_END
