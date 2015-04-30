//
//  IndoorMappingManager.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "IndoorMappingModel.h"
#import "MappedBeacon.h"

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
    _minX = INFINITY;
    _minY = INFINITY;
    _maxX = 0;
    _maxY = 0;
    for (MappedBeacon * beacon in _beacons)
    {
        if (beacon.coordinates.x >_maxX) _maxX = beacon.coordinates.x;
        if (beacon.coordinates.y >_maxY) _maxY = beacon.coordinates.y;
        if (beacon.coordinates.x <_minX) _minX = beacon.coordinates.x;
        if (beacon.coordinates.y <_minY) _minY = beacon.coordinates.y;
    }
    
    NSLog(@">>>>>>> %f %f %f %f",_minX,_minY,_maxX,_maxY);
    
    _walls = walls;
    
    return self;
}

- (CGPoint)correctLocation:(CGPoint)location
{
    CGFloat x = (location.x > _minX) ? location.x : _minX;
    x = (x < _maxX) ? x : _maxX;
    CGFloat y = (location.y > _minY) ? location.y : _minY;
    y = (y < _maxY) ? y : _maxY;
    
    //TODO: correct for walls
    
    return CGPointMake(x,y);
}

@end
