//
//  IndoorMappingManager.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "IndoorMappingModel.h"
#import "MappedBeacon.h"
#import "Wall.h"

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

- (BOOL)point:(CGPoint)c isLeftOfLineWithStart:(CGPoint)a end:(CGPoint)b
{
    return ((b.x - a.x)*(c.y - a.y) - (b.y - a.y)*(c.x - a.x)) > 0;
}

- (CGPoint)projectPoint:(CGPoint)point toLineWithStart:(CGPoint)lineStart end:(CGPoint)lineEnd
{
//    NSLog(@"Project point: %f %f",point.x,point.y);
//    NSLog(@"To line: %f %f - %f %f",lineStart.x,lineStart.y,lineEnd.x,lineEnd.y);
    CGFloat m = (CGFloat)(lineEnd.y - lineStart.y) / (lineEnd.x - lineStart.x + 0.0000001); //In case of zero + very small value, not to create a black hole.
    CGFloat b = (CGFloat)lineStart.y - (m * lineStart.x);
    
    CGFloat x = (m * point.y + point.x - m * b) / (m * m + 1);
    CGFloat y = (m * m * point.y + m * point.x + b) / (m * m + 1);
    
//    NSLog(@"m:%f b:%f x:%f y:%f",m,b,x,y);
//    NSLog(@"Projected: %f %f to -> %f %f",point.x,point.y,x,y);
    return CGPointMake(x, y);
}

- (CGPoint)correctLocation:(CGPoint)location
{
//    NSLog(@"Correct location: %f %f",location.x,location.y);
    CGFloat x = location.x;
    CGFloat y = location.y;
    
    //Very rough first correction for values completely outside the bounds.
    x = (location.x > _minX) ? location.x : _minX;
    x = (x < _maxX) ? x : _maxX;
    y = (location.y > _minY) ? location.y : _minY;
    y = (y < _maxY) ? y : _maxY;
    
    //Correct for walls
    CGPoint currentCorrectedLocation = CGPointMake(x, y);
    for (Wall * wall in _walls)
    {
        //Check for each wall if point lies on the right side.
        if ([self point:currentCorrectedLocation isLeftOfLineWithStart:wall.startPoint end:wall.endPoint] != [self point:wall.insidePoint isLeftOfLineWithStart:wall.startPoint end:wall.endPoint])
        {
            currentCorrectedLocation = [self projectPoint:currentCorrectedLocation toLineWithStart:wall.startPoint end:wall.endPoint];
        }
    }
    
    return currentCorrectedLocation;
}

@end
