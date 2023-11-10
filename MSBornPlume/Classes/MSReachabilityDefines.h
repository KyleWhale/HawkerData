//
//  MSReachabilityDefines
//  Project
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef MSNetworkStatus_h
#define MSNetworkStatus_h
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol MSReachabilityObserver;
/**
 This enumeration lists the three state values of the network.
 It is used to identify the current network state. You can obtain the current network state as follows:
 
 这个枚举列出了网络的3种状态值, 用来标识当前的网络状态, 你可以像下面这样获取当前的网络状态:
 ```
 _plume.networkStatus;
 ```
 */
typedef NS_ENUM(NSInteger, MSNetworkStatus) {
    MSNetworkStatus_NotReachable = 0,
    MSNetworkStatus_ReachableViaWWAN = 1,
    MSNetworkStatus_ReachableViaWiFi = 2
};


@protocol MSReachability <NSObject>
- (id<MSReachabilityObserver>)getObserver;

@property (nonatomic, readonly) MSNetworkStatus networkStatus;

@property (nonatomic, strong, readonly) NSString *networkSpeedStr;

- (void)startRefresh;
- (void)stopRefresh;
@end

@protocol MSReachabilityObserver <NSObject>
@property (nonatomic, copy, nullable) void(^networkStatusDidChangeExeBlock)(id<MSReachability> r);
@property (nonatomic, copy, nullable) void(^networkSpeedDidChangeExeBlock)(id<MSReachability> r);
@end
NS_ASSUME_NONNULL_END
#endif /* MSNetworkStatus_h */
