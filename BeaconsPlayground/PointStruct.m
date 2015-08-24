//
//  PointStruct.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/24/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "PointStruct.h"

@implementation PointStruct

- (instancetype)initWithPoint:(CGPoint)point
{
    self = [super init];
    
    _xCoord = point.x;
    _yCoord = point.y;
    
    return self;
}

@end
