//
//  MSBornPlumeResourceLoader.m
//  MSDeviceVolumeAndBrightnessController
//
//  Created by admin on 2017/12/10.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "MSBornPlumeResourceLoader.h"
#import <UIKit/UIImage.h>

NS_ASSUME_NONNULL_BEGIN
@implementation MSBornPlumeResourceLoader
+ (NSBundle *)bundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"MSBornPlumeResources" ofType:@"bundle"]];
    });
    return bundle;
}

+ (nullable UIImage *)imageNamed:(NSString *)name {
    if ( 0 == name.length )
        return nil;
    NSString *path = [self.bundle pathForResource:name ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data scale:3.0];
    return image;
}

@end
NS_ASSUME_NONNULL_END
