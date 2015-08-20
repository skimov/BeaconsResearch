//
//  SingleBeaconMeasurementStruct.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "SingleBeaconMeasurementStruct.h"

@implementation SingleBeaconMeasurementStruct

- (instancetype)initWithIterationCount:(int)iterationCount secondsFromMeasurementStart:(double)secondsFromMeasurementStart filteredDistanceMeters:(double)filteredDistanceMeters unfilteredDistanceMeters:(double)unfilteredDistanceMeters
{
    self = [super init];
    
    _iterationCount = iterationCount;
    _secondsFromMeasurementStart = secondsFromMeasurementStart;
    _filteredDistanceMeters = filteredDistanceMeters;
    _unfilteredDistanceMeters = unfilteredDistanceMeters;
    
    return self;
}

+ (NSDictionary*)toDictionary:(SingleBeaconMeasurementStruct*)measurementStruct
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:measurementStruct.iterationCount],@"Iteration Count",
            [NSNumber numberWithDouble:measurementStruct.secondsFromMeasurementStart],@"Seconds From Start",
            [NSNumber numberWithDouble:measurementStruct.filteredDistanceMeters],@"Filtered Distance",
            [NSNumber numberWithDouble:measurementStruct.unfilteredDistanceMeters],@"Unfiltered Distance",
            nil];
}

+ (SingleBeaconMeasurementStruct*)fromDictionary:(NSDictionary*)json
{
    SingleBeaconMeasurementStruct * measurementStruct = [[SingleBeaconMeasurementStruct alloc] init];
    measurementStruct.iterationCount = [[json objectForKey:@"Iteration Count"] intValue];
    measurementStruct.secondsFromMeasurementStart = [[json objectForKey:@"Seconds From Start"] doubleValue];
    measurementStruct.filteredDistanceMeters = [[json objectForKey:@"Filtered Distance"] doubleValue];
    measurementStruct.unfilteredDistanceMeters = [[json objectForKey:@"Unfiltered Distance"] doubleValue];
    return measurementStruct;
}

@end
