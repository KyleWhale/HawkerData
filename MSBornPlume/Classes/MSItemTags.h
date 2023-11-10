//
//  MSItemTags.h
//  MSPlume
//
//  Created by BlueDancer on 2020/12/31.
//

#import "MSEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - MSEdgeControlLayer

// top adapter items
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerTopItem_Back;             // 返回按钮
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerTopItem_Title;            // 标题
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerTopItem_More;             // More


// left adapter items
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerLeftItem_Lock;            // 锁屏按钮

// right adapter items
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerRightItem_Clips;         // GIF/导出/截屏

// bottom adapter items
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_Play;          // 播放按钮
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_CurrentTime;   // 当前时间
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_DurationTime;  // 全部时长
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_Separator;     // 时间分隔符(斜杠/)
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_Progress;      // 播放进度条
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_Full;          // 全屏按钮
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_LIVEText;      // 实时直播
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerBottomItem_Definition;    // 清晰度

// center adapter items
extern MSEdgeControlButtonItemTag const MSEdgeControlLayerCenterItem_Replay;        // 重播按钮

NS_ASSUME_NONNULL_END
