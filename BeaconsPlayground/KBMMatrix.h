//
//  KalmanMotionMatrix.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/13/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KBMMatrix : NSObject

@property (unsafe_unretained, nonatomic) CGFloat xVal;
@property (unsafe_unretained, nonatomic) CGFloat yVal;

- (instancetype)initWithConst:(CGFloat)constVal;
- (instancetype)initWithPoint:(CGPoint)point;

- (KBMMatrix*)multiplyBy:(KBMMatrix*)b;
- (KBMMatrix*)add:(KBMMatrix*)b;
- (KBMMatrix*)subtract:(KBMMatrix*)b;

@end
