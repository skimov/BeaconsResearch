//
//  IndoorMappingManager.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "IndoorMappingModel.h"

@interface IndoorMappingModel ()

@property (unsafe_unretained, nonatomic) CGFloat minX;
@property (unsafe_unretained, nonatomic) CGFloat minY;
@property (unsafe_unretained, nonatomic) CGFloat maxX;
@property (unsafe_unretained, nonatomic) CGFloat maxY;

@end

@implementation IndoorMappingModel

- (id)initWithBeacons:(NSArray*)beacons walls:(NSArray*)walls
{
    self = [super init];
    
    _beacons = beacons;
    _walls = walls;
    
    return self;
}

- (CGPoint)correctLocation:(CGPoint)location
{
    CGFloat x = (location.x > _minX) ? location.x : _minX;
    x = (location.x < _maxX) ? location.x : _maxX;
    CGFloat y = (location.y > _minY) ? location.y : _minY;
    y = (location.y > _maxY) ? location.y : _maxY;
    
    return CGPointMake(x,y);
}

@end
