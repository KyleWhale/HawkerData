//
//  MSControlLayerSwitcher.m
//  MSPlumeProject
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "MSControlLayerSwitcher.h"

NS_ASSUME_NONNULL_BEGIN
MSControlLayerIdentifier MSControlLayer_Uninitialized = LONG_MAX;
static NSString *const MSCharmSwitchControlLayerUserInfoKey = @"MSCharmSwitchControlLayerUserInfoKey";
static NSNotificationName const MSCharmWillBeginSwitchControlLayerNotification = @"MSCharmWillBeginSwitchControlLayerNotification";
static NSNotificationName const MSCharmDidEndSwitchControlLayerNotification = @"MSCharmDidEndSwitchControlLayerNotification";

@interface MSControlLayerSwitcherObserver : NSObject<MSControlLayerSwitcherObserver>
- (instancetype)initWithSwitcher:(id<MSControlLayerSwitcher>)switcher;
@end

@implementation MSControlLayerSwitcherObserver
@synthesize playerWillBeginSwitchControlLayer = _playerWillBeginSwitchControlLayer;
@synthesize playerDidEndSwitchControlLayer = _playerDidEndSwitchControlLayer;
- (instancetype)initWithSwitcher:(id<MSControlLayerSwitcher>)switcher {
    self = [super init];
    if ( !self ) return nil; 
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willBeginSwitchControlLayer:) name:MSCharmWillBeginSwitchControlLayerNotification object:switcher];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEndSwitchControlLayer:) name:MSCharmDidEndSwitchControlLayerNotification object:switcher];
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)willBeginSwitchControlLayer:(NSNotification *)note {
    if ( self.playerWillBeginSwitchControlLayer ) self.playerWillBeginSwitchControlLayer(note.object, note.userInfo[MSCharmSwitchControlLayerUserInfoKey]);
}

- (void)didEndSwitchControlLayer:(NSNotification *)note {
    if ( self.playerDidEndSwitchControlLayer ) self.playerDidEndSwitchControlLayer(note.object, note.userInfo[MSCharmSwitchControlLayerUserInfoKey]);
}
@end

@interface MSControlLayerSwitcher ()
@property (nonatomic, weak, nullable) MSBornPlume *plume;
@property (nonatomic, strong, readonly) NSMutableDictionary *map;
@end

@implementation MSControlLayerSwitcher
@synthesize currentIdentifier = _currentIdentifier;
@synthesize previousIdentifier = _previousIdentifier;
@synthesize delegate = _delegate;
@synthesize resolveControlLayer = _resolveControlLayer;

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (instancetype)initWithPlayer:(__weak MSBornPlume *)plume {
    self = [super init];
    if ( !self ) return nil;
    _plume = plume;
    _map = [NSMutableDictionary dictionary];
    _previousIdentifier = MSControlLayer_Uninitialized;
    _currentIdentifier = MSControlLayer_Uninitialized;
    return self;
}

- (id<MSControlLayerSwitcherObserver>)getObserver {
    return [[MSControlLayerSwitcherObserver alloc] initWithSwitcher:self];
}

- (void)switchControlLayerForIdentifier:(MSControlLayerIdentifier)identifier {
    if ( [self.delegate respondsToSelector:@selector(switcher:shouldSwitchToControlLayer:)] ) {
        if ( ![self.delegate switcher:self shouldSwitchToControlLayer:identifier] )
            return;
    }

    id<MSControlLayer> _Nullable oldValue = (id)self.plume.controlLayerDataSource;
    id<MSControlLayer> _Nullable newValue = [self controlLayerForIdentifier:identifier];
    if ( !newValue && _resolveControlLayer ) {
        newValue = _resolveControlLayer(identifier);
        [self addControlLayerForIdentifier:identifier lazyLoading:^id<MSControlLayer> _Nonnull(MSControlLayerIdentifier identifier) {
            return newValue;
        }];
    }
    NSParameterAssert(newValue); if ( !newValue ) return;
    if ( oldValue == newValue )
        return;
    
    // - begin -
    [NSNotificationCenter.defaultCenter postNotificationName:MSCharmWillBeginSwitchControlLayerNotification object:self userInfo:newValue?@{MSCharmSwitchControlLayerUserInfoKey:newValue}:nil];

    [oldValue exitControlLayer];
    _plume.controlLayerDataSource = nil;
    _plume.controlLayerDelegate = nil;

    // update identifiers
    _previousIdentifier = _currentIdentifier;
    _currentIdentifier = identifier;

    _plume.controlLayerDataSource = newValue;
    _plume.controlLayerDelegate = newValue;
    [newValue restartControlLayer];
    
    // - end -
    [NSNotificationCenter.defaultCenter postNotificationName:MSCharmDidEndSwitchControlLayerNotification object:self userInfo:@{MSCharmSwitchControlLayerUserInfoKey:newValue}];
}

- (BOOL)switchToPreviousControlLayer {
    if ( self.previousIdentifier == MSControlLayer_Uninitialized ) return NO;
    if ( !self.plume ) return NO;
    [self switchControlLayerForIdentifier:self.previousIdentifier];
    return YES;
}

- (void)addControlLayerForIdentifier:(MSControlLayerIdentifier)identifier
                         lazyLoading:(nullable id<MSControlLayer>(^)(MSControlLayerIdentifier identifier))loading {
#ifdef DEBUG
    NSParameterAssert(loading);
#endif
    
    [self.map setObject:loading forKey:@(identifier)];
    if ( self.currentIdentifier == identifier ) {
        [self switchControlLayerForIdentifier:identifier];
    }
}

- (void)deleteControlLayerForIdentifier:(MSControlLayerIdentifier)identifier {
    [self.map removeObjectForKey:@(identifier)];
}

- (nullable id<MSControlLayer>)controlLayerForIdentifier:(MSControlLayerIdentifier)identifier {
    if ( [self.delegate respondsToSelector:@selector(switcher:controlLayerForIdentifier:)] ) {
        id<MSControlLayer> controlLayer = [self.delegate switcher:self controlLayerForIdentifier:identifier];
        if ( controlLayer != nil )
            return controlLayer;
    }
    
    id _Nullable controlLayerOrBlock = self.map[@(identifier)];
    if ( !controlLayerOrBlock )
        return nil;
    
    // loaded
    if ( [controlLayerOrBlock conformsToProtocol:@protocol(MSControlLayer)] ) {
        return controlLayerOrBlock;
    }
    
    // lazy loading
    id<MSControlLayer> controlLayer = ((id<MSControlLayer>(^)(MSControlLayerIdentifier))controlLayerOrBlock)(identifier);
    if (controlLayer) {
        [self.map setObject:controlLayer forKey:@(identifier)];
        return controlLayer;
    }
    return nil;
}

- (BOOL)containsControlLayer:(MSControlLayerIdentifier)identifier {
    return [self controlLayerForIdentifier:identifier] != nil;
}
@end
NS_ASSUME_NONNULL_END
