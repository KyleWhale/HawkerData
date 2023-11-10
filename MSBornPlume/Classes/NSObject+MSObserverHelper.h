//
//  NSObject+MSObserverHelper.h
//  TmpProject
//
//  Created by admin on 2017/12/8.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/MSObserverHelper
//
//  Contact:    changsanjiang@gmail.com
//
//  QQGroup:    719616775
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MSDeallockCallbackTask)(id obj);
typedef void(^MSKVOObservedChangeHandler)(id target, NSDictionary<NSKeyValueChangeKey,id> *_Nullable change);
typedef NSInteger MSKVOObserverToken;

/// - KVO -
/// Add Observer (autoremove) [target, keyPath, change]
extern MSKVOObserverToken
sjkvo_observe(id target, NSString *keyPath, MSKVOObservedChangeHandler handler);

/// Add Observer (autoremove) [target, keyPath, options, change]
extern MSKVOObserverToken __attribute__((overloadable))
sjkvo_observe(id target, NSString *keyPath, NSKeyValueObservingOptions options, MSKVOObservedChangeHandler handler);

/// Remove Observer
extern void
sjkvo_remove(id target, MSKVOObserverToken token);


/// - KVO -
@interface NSObject (MSKVOHelper)
/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)ms_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)ms_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;

/// Add an observer, you don't need to remove observer (autoremove)
/// 添加观察者, 无需移除 (将会自动移除)
- (void)ms_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end

/// - Notification -
@interface NSObject (MSNotificationHelper)
/// Autoremove
- (void)ms_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)sender usingBlock:(void(^)(id self, NSNotification *note))block;

/// Autoremove
- (void)ms_observeWithNotification:(NSNotificationName)notification target:(id _Nullable)sender queue:(NSOperationQueue *_Nullable)queue usingBlock:(void(^)(id self, NSNotification *note))block;
@end

/// - DeallocCallback -
@interface NSObject (MSDeallocCallback)
/// Add a task that will be executed when the object is destroyed
/// 添加一个任务, 当对象销毁时将会执行这些任务
- (void)ms_addDeallocCallbackTask:(MSDeallockCallbackTask)callback;
@end
NS_ASSUME_NONNULL_END
