//
//  MSControlLayerDefines.h
//  Pods
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 admin. All rights reserved.
//

#ifndef MSControlLayerDefines_h
#define MSControlLayerDefines_h
#if __has_include(<MSBornPlume/MSBornPlume.h>)
#import <MSBornPlume/MSPlumeControlLayerProtocol.h>
#else
#import "MSPlumeControlLayerProtocol.h"
#endif
@protocol MSControlLayerRestartProtocol, MSControlLayerExitProtocol;
typedef long MSControlLayerIdentifier;

NS_ASSUME_NONNULL_BEGIN
///
/// 控制层协议
///
@protocol MSControlLayer <
    MSPlumeControlLayerDataSource,
    MSPlumeControlLayerDelegate,
    MSControlLayerRestartProtocol,
    MSControlLayerExitProtocol
>
@end

///
/// 启用控制层协议
///
///     切换器(switcher)切换控制层时, 该方法将会被调用
///
@protocol MSControlLayerRestartProtocol <NSObject>
@property (nonatomic, readonly) BOOL restarted; // 是否已重新启用
- (void)restartControlLayer;
@end

///
/// 退出控制层
///
///     切换器(switcher)切换控制层时, 该方法将会被调用
///
@protocol MSControlLayerExitProtocol <NSObject>
- (void)exitControlLayer;
@end
NS_ASSUME_NONNULL_END

#endif /* MSControlLayerDefines_h */
