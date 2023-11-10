//
//  MSQueue.h
//  Pods
//
//  Created by admin on 2019/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface MSQueue<__covariant ObjectType> : NSObject
+ (instancetype)queue;

@property (nonatomic, readonly) NSInteger size;

@property (nonatomic, strong, readonly, nullable) ObjectType firstObject;
@property (nonatomic, strong, readonly, nullable) ObjectType lastObject;

- (void)enqueue:(ObjectType)obj;
- (nullable ObjectType)dequeue;
- (void)empty;
@end

@interface MSSafeQueue<__covariant ObjectType> : MSQueue

@end
NS_ASSUME_NONNULL_END
