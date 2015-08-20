//
//  SingleBeaconMeasurementStruct.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleBeaconMeasurementStruct : NSObject

@property (unsafe_unretained, nonatomic) int iterationCount;
@property (unsafe_unretained, nonatomic) double secondsFromMeasurementStart;
@property (unsafe_unretained, nonatomic) double filteredDistanceMeters;
@property (unsafe_unretained, nonatomic) double unfilteredDistanceMeters;

- (instancetype)initWithIterationCount:(int)iterationCount secondsFromMeasurementStart:(double)secondsFromMeasurementStart filteredDistanceMeters:(double)filteredDistanceMeters unfilteredDistanceMeters:(double)unfilteredDistanceMeters;

+ (NSDictionary*)toDictionary:(SingleBeaconMeasurementStruct*)measurementStruct;
+ (SingleBeaconMeasurementStruct*)fromDictionary:(NSDictionary*)json;

@end
