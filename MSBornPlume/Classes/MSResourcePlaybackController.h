//
//  MSResourcePlaybackController.h
//  Pods
//
//  Created by admin on 2020/2/18.
//

#import "MSMTPlaybackController.h"
#import "MSExecuteCode.h"
#import "MSExecuteCodeLayerView.h"

NS_ASSUME_NONNULL_BEGIN
@interface MSResourcePlaybackController : MSMTPlaybackController

@property (nonatomic, strong, readonly, nullable) MSExecuteCode *currentPlayer;
@property (nonatomic, strong, readonly, nullable) MSExecuteCodeLayerView *currentPlayerView;
@property (nonatomic) BOOL accurateSeeking;

@end

@interface MSResourcePlaybackController (MSResourcePlaybackAdd)<MSMTPlaybackExportController, MSMTPlaybackScreenshotController>

@end
NS_ASSUME_NONNULL_END
