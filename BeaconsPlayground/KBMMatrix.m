//
//  KalmanMotionMatrix.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/13/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "KBMMatrix.h"

@implementation KBMMatrix

- (instancetype)initWithConst:(CGFloat)constVal
{
    self = [super init];
    
    _xVal = constVal;
    _yVal = constVal;
    
    return self;
}

- (instancetype)initWithPoint:(CGPoint)point
{
    self = [super init];
    
    _xVal = point.x;
    _yVal = point.y;
    
    return self;
}

- (KBMMatrix*)multiplyBy:(KBMMatrix*)b
{
    return [[KBMMatrix alloc] initWithPoint:CGPointMake(_xVal * b.xVal, _yVal * b.yVal)];
//    _xVal *= b.xVal;
//    _yVal *= b.yVal;
//    return self;
}

- (KBMMatrix*)add:(KBMMatrix*)b
{
    NSLog(@"%@ - add: %.2f %.2f + %.2f %.2f",[self.class description],_xVal,_yVal,b.xVal,b.yVal);
    return [[KBMMatrix alloc] initWithPoint:CGPointMake(_xVal + b.xVal, _yVal + b.yVal)];
//    _xVal += b.xVal;
//    _yVal += b.yVal;
//    return self;
}

- (KBMMatrix*)subtract:(KBMMatrix*)b
{
    return [[KBMMatrix alloc] initWithPoint:CGPointMake(_xVal - b.xVal, _yVal - b.yVal)];
//    _xVal -= b.xVal;
//    _yVal -= b.yVal;
//    return self;
}

@end
