//
//  MSControlLayerIdentifiers.h
//  MSPlume
//
//  Created by BlueDancer on 2020/12/31.
//

#import "MSControlLayerDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 以下标识是默认存在的控制层标识
/// - 可以像下面这样扩展您的标识, 将相应的控制层加入到switcher(切换器)中, 通过switcher进行切换.
/// - MSControlLayerIdentifier YourControlLayerIdentifier;
/// - 当然, 也可以直接将已存在控制层, 替换成您的控制层.
extern MSControlLayerIdentifier const MSControlLayer_Edge;                              ///< 默认的边缘控制层
extern MSControlLayerIdentifier const MSControlLayer_Clips;                             ///< 默认的剪辑层
extern MSControlLayerIdentifier const MSControlLayer_More;                              ///< 默认的更多设置控制层
extern MSControlLayerIdentifier const MSControlLayer_LoadFailed;                        ///< 默认加载失败时显示的控制层
extern MSControlLayerIdentifier const MSControlLayer_NotReachableAndPlaybackStalled;    ///< 默认加载失败时显示的控制层
extern MSControlLayerIdentifier const MSControlLayer_SwitchVideoDefinition;             ///< 默认的切换视频清晰度控制层

NS_ASSUME_NONNULL_END
