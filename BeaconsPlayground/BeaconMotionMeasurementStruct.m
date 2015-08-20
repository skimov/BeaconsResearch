//
//  BeaconMotionMeasurementStruct.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "BeaconMotionMeasurementStruct.h"

@implementation BeaconMotionMeasurementStruct

- (instancetype)initWithIterationCount:(int)iterationCount secondsFromMeasurementStart:(double)secondsFromMeasurementStart filteredCoordinate:(CGPoint)filteredCoordinate beaconsCoordinate:(CGPoint)beaconsCoordinate deadReckoningCoordinate:(CGPoint)deadReckoningCoordinate K:(double)K
{
    self = [super init];
    
    _iterationCount = iterationCount;
    _secondsFromMeasurementStart = secondsFromMeasurementStart;
    _filteredCoordinate = filteredCoordinate;
    _beaconsCoordinate = beaconsCoordinate;
    _deadReckoningCoordinate = deadReckoningCoordinate;
    _K = K;
    
    return self;
}

+ (NSDictionary*)toDictionary:(BeaconMotionMeasurementStruct*)measurementStruct
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:measurementStruct.iterationCount],@"Iteration Count",
            [NSNumber numberWithDouble:measurementStruct.secondsFromMeasurementStart],@"Seconds From Start",
            [NSNumber numberWithDouble:measurementStruct.filteredCoordinate.x],@"Filtered Coordinate X",
            [NSNumber numberWithDouble:measurementStruct.filteredCoordinate.y],@"Filtered Coordinate Y",
            
            [NSNumber numberWithDouble:measurementStruct.beaconsCoordinate.x],@"Beacons Coordinate X",
            [NSNumber numberWithDouble:measurementStruct.beaconsCoordinate.y],@"Beacons Coordinate Y",
            [NSNumber numberWithDouble:measurementStruct.deadReckoningCoordinate.x],@"Dead Reckoning Coordinate X",
            [NSNumber numberWithDouble:measurementStruct.deadReckoningCoordinate.y],@"Dead Reckoning Coordinate Y",
            
            [NSNumber numberWithDouble:measurementStruct.K],@"K",
            nil];
}

+ (BeaconMotionMeasurementStruct*)fromDictionary:(NSDictionary*)json
{
    BeaconMotionMeasurementStruct * measurementStruct = [[BeaconMotionMeasurementStruct alloc] init];
    measurementStruct.iterationCount = [[json objectForKey:@"Iteration Count"] intValue];
    measurementStruct.secondsFromMeasurementStart = [[json objectForKey:@"Seconds From Start"] doubleValue];
    measurementStruct.filteredCoordinate = CGPointMake([[json objectForKey:@"Filtered Coordinate X"] doubleValue], [[json objectForKey:@"Filtered Coordinate Y"] doubleValue]);
    
    measurementStruct.beaconsCoordinate = CGPointMake([[json objectForKey:@"Beacons Coordinate X"] doubleValue], [[json objectForKey:@"Beacons Coordinate Y"] doubleValue]);
    measurementStruct.deadReckoningCoordinate = CGPointMake([[json objectForKey:@"Dead Reckoning Coordinate X"] doubleValue], [[json objectForKey:@"Dead Reckoning Coordinate Y"] doubleValue]);

    measurementStruct.K = [[json objectForKey:@"K"] doubleValue];
    return measurementStruct;
}

@end
