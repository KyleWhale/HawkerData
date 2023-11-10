//
//  MSPlumePlayStatusDefines.h
//  MSPlumeProject
//
//  Created by admin on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#ifndef MSPlumePlayStatusDefines_h
#define MSPlumePlayStatusDefines_h
@class MSBornPlume;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, MSPlaybackType) {
    MSPlaybackTypeUnknown,
    MSPlaybackTypeLIVE,
    MSPlaybackTypeVOD,
    MSPlaybackTypeFILE
};

typedef NS_ENUM(NSInteger, MSAssetStatus) {
    ///
    /// 未知状态
    ///
    MSAssetStatusUnknown,
    
    ///
    /// 准备中
    ///
    MSAssetStatusPreparing,
    
    ///
    /// 当前资源可随时进行播放(播放控制请查看`timeControlStatus`)
    ///
    MSAssetStatusReadyToPlay,
    
    ///
    /// 发生错误
    ///
    MSAssetStatusFailed
};

typedef NS_ENUM(NSInteger, MSPlumeState) {
    ///
    /// 暂停状态(已调用暂停或未执行任何操作的状态)
    ///
    MSPlumeStatePeached,
    
    ///
    /// 播放状态(已调用播放), 当前正在缓冲或正在评估能否播放. 可以通过`reasonForWaitingToPlay`来获取原因, UI层可以根据原因来控制loading视图的状态.
    ///
    MSPlumeStateWaiting,
    
    ///
    /// 播放状态(已调用播放), 当前播放器正在播放
    ///
    MSPlumeStatePluming
};


#pragma mark -


typedef NSString *MSWaitingReason;

///
/// 缓冲中, UI层建议显示loading视图 
///
extern MSWaitingReason const MSWaitingToMinimizeStallsReason;

///
/// 正在评估能否播放, 处于此状态时, 不建议UI层显示loading视图
///
extern MSWaitingReason const MSWaitingWhileEvaluatingBufferingRateReason;

///
/// 未设置资源
///
extern MSWaitingReason const MSWaitingWithNoAssetToPlayReason;


#pragma mark -


typedef NSString *MSFinishedReason;

///
/// 正常播放完毕
///
extern MSFinishedReason const MSFinishedReasonToEndTimePosition;
///
/// 播放到了试看结束的位置
///
extern MSFinishedReason const MSFinishedReasonToTrialEndPosition;


#pragma mark -


///
/// 清晰度的切换状态
///
typedef NS_ENUM(NSInteger, MSDefinitionSwitchStatus) {
    MSDefinitionSwitchStatusUnknown,
    MSDefinitionSwitchStatusSwitching,
    MSDefinitionSwitchStatusFinished,
    MSDefinitionSwitchStatusFailed,
};
NS_ASSUME_NONNULL_END
#endif /* MSPlumePlayStatusDefines_h */
