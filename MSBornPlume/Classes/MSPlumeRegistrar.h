//
//  MSPlumeRegistrar.h
//  MSPlumeProject
//
//  Created by admin on 2017/12/5.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MSPlumeAppState) {
    MSPlumeAppState_Active,
    MSPlumeAppState_Inactive,
    MSPlumeAppState_Background, // 从前台进入后台
};

@interface MSPlumeRegistrar : NSObject

@property (nonatomic, readonly) MSPlumeAppState state;

@property (nonatomic, copy, nullable) void(^willResignActive)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^willEnterForeground)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^didEnterBackground)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^willTerminate)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(MSPlumeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^audioSessionInterruption)(MSPlumeRegistrar *registrar);

@end

NS_ASSUME_NONNULL_END
