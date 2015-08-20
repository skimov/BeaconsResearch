//
//  BeaconMotionMeasurementStruct.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BeaconMotionMeasurementStruct : NSObject

@property (unsafe_unretained, nonatomic) int iterationCount;
@property (unsafe_unretained, nonatomic) double secondsFromMeasurementStart;
@property (unsafe_unretained, nonatomic) CGPoint filteredCoordinate;

@property (unsafe_unretained, nonatomic) CGPoint beaconsCoordinate;
@property (unsafe_unretained, nonatomic) CGPoint deadReckoningCoordinate;
@property (unsafe_unretained, nonatomic) double K;


- (instancetype)initWithIterationCount:(int)iterationCount secondsFromMeasurementStart:(double)secondsFromMeasurementStart filteredCoordinate:(CGPoint)filteredCoordinate beaconsCoordinate:(CGPoint)beaconsCoordinate deadReckoningCoordinate:(CGPoint)deadReckoningCoordinate K:(double)K;

+ (NSDictionary*)toDictionary:(BeaconMotionMeasurementStruct*)measurementStruct;
+ (BeaconMotionMeasurementStruct*)fromDictionary:(NSDictionary*)json;

@end
