//
//  MSGestureControllerDefines.h
//  Pods
//
//  Created by admin on 2019/1/3.
//

#ifndef MSGestureControllerProtocol_h
#define MSGestureControllerProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, MSCharmGestureType) {
    /// 单击手势
    MSCharmGestureType_SingleTap,
    /// 双击手势
    MSCharmGestureType_DoubleTap,
    /// 移动手势
    MSCharmGestureType_Pan,
    /// 捏合手势
    MSCharmGestureType_Pinch,
    /// 长按手势
    MSCharmGestureType_LongPress,
};

typedef NS_OPTIONS(NSUInteger, MSCharmGestureTypeMask) {
    MSCharmGestureTypeMask_None,
    MSCharmGestureTypeMask_SingleTap   = 1 << MSCharmGestureType_SingleTap,
    MSCharmGestureTypeMask_DoubleTap   = 1 << MSCharmGestureType_DoubleTap,
    MSCharmGestureTypeMask_Pan_H       = 0x100, // 水平方向
    MSCharmGestureTypeMask_Pan_V       = 0x200, // 垂直方向
    MSCharmGestureTypeMask_Pan         = MSCharmGestureTypeMask_Pan_H | MSCharmGestureTypeMask_Pan_V,
    MSCharmGestureTypeMask_Pinch       = 1 << MSCharmGestureType_Pinch,
    MSCharmGestureTypeMask_LongPress   = 1 << MSCharmGestureType_LongPress,
    
    
    MSCharmGestureTypeMask_Default = MSCharmGestureTypeMask_SingleTap | MSCharmGestureTypeMask_DoubleTap | MSCharmGestureTypeMask_Pan | MSCharmGestureTypeMask_Pinch,
    MSCharmGestureTypeMask_All = MSCharmGestureTypeMask_Default | MSCharmGestureTypeMask_LongPress,
};

/// 移动方向
typedef NS_ENUM(NSUInteger, MSPanGestureMovingDirection) {
    MSPanGestureMovingDirection_H,
    MSPanGestureMovingDirection_V,
};
 
/// 移动手势触发时的位置
typedef NS_ENUM(NSUInteger, MSPanGestureTriggeredPosition) {
    MSPanGestureTriggeredPosition_Left,
    MSPanGestureTriggeredPosition_Right,
};

/// 移动手势的状态
typedef NS_ENUM(NSUInteger, MSPanGestureRecognizerState) {
    MSPanGestureRecognizerStateBegan,
    MSPanGestureRecognizerStateChanged,
    MSPanGestureRecognizerStateEnded,
};

/// 长按手势的状态
typedef NS_ENUM(NSUInteger, MSLongPressGestureRecognizerState) {
    MSLongPressGestureRecognizerStateBegan,
    MSLongPressGestureRecognizerStateChanged,
    MSLongPressGestureRecognizerStateEnded,
};

@protocol MSGestureController <NSObject>
@property (nonatomic) MSCharmGestureTypeMask supportedGestureTypes; ///< default value is .Default
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(id<MSGestureController> control, MSCharmGestureType type, CGPoint location);
@property (nonatomic, copy, nullable) void(^singleTapHandler)(id<MSGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^doubleTapHandler)(id<MSGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^panHandler)(id<MSGestureController> control, MSPanGestureTriggeredPosition position, MSPanGestureMovingDirection direction, MSPanGestureRecognizerState state, CGPoint translate);
@property (nonatomic, copy, nullable) void(^pinchHandler)(id<MSGestureController> control, CGFloat scale);
@property (nonatomic, copy, nullable) void(^longPressHandler)(id<MSGestureController> control, MSLongPressGestureRecognizerState state);

- (void)cancelGesture:(MSCharmGestureType)type;
- (UIGestureRecognizerState)stateOfGesture:(MSCharmGestureType)type;

@property (nonatomic, readonly) MSPanGestureMovingDirection movingDirection;
@property (nonatomic, readonly) MSPanGestureTriggeredPosition triggeredPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* MSGestureControllerProtocol_h */
