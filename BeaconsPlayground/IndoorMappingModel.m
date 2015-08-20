//
//  IndoorMappingManager.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "IndoorMappingModel.h"
#import "RangedBeacon.h"

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
    
    _minX = 99999;
    _minY = 99999;
    _maxX = -99999;
    _maxY = -99999;
    
    for (RangedBeacon * beacon in beacons)
    {
        if (_minX > beacon.coordinates.x) _minX = beacon.coordinates.x;
        if (_minY > beacon.coordinates.y) _minY = beacon.coordinates.y;
        if (_maxX < beacon.coordinates.x) _maxX = beacon.coordinates.x;
        if (_maxY < beacon.coordinates.y) _maxY = beacon.coordinates.y;
    }
    
    NSLog(@"> %f %f %f %f",_minX,_minY,_maxX,_maxY);
    
    return self;
}

- (CGPoint)correctLocation:(CGPoint)location
{
    CGFloat x = fmax(location.x, _minX);
    x = fmin(x,_maxX);
//    CGFloat x = (location.x > _minX) ? location.x : _minX;
//    x = (location.x < _maxX) ? location.x : _maxX;
    CGFloat y = fmax(location.y, _minY);
    y = fmin(y,_maxY);
//    CGFloat y = (location.y > _minY) ? location.y : _minY;
//    y = (location.y > _maxY) ? location.y : _maxY;
    
    return CGPointMake(x,y);
}

@end
