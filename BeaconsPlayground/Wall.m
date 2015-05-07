//
//  Wall.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "Wall.h"

@implementation Wall

- (instancetype)initWithStart:(CGPoint)start end:(CGPoint)end
{
    self = [super init];
    
    _startPoint = start;
    _endPoint = end;
    
    return self;
}

- (instancetype)initWithStart:(CGPoint)start end:(CGPoint)end insidePoint:(CGPoint)insidePoint
{
    self = [self initWithStart:start end:end];
    
    _insidePoint = insidePoint;
    
    return self;
}

@end
