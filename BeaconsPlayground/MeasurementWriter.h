//
//  MeasurementWriter.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleBeaconMeasurementStruct.h"
#import "BeaconMotionMeasurementStruct.h"

@interface MeasurementWriter : NSObject

+ (MeasurementWriter *)sharedInstance;

- (BOOL)measurementFileExistsWithName:(NSString*)name;
- (void)createMeasurementFileWithName:(NSString*)name;
- (void)removeMeasurementFileWithName:(NSString*)name;

- (void)writeIterationWithSingleBeaconMeasurement:(SingleBeaconMeasurementStruct*)measurementStruct toFileWithName:(NSString*)name;
- (void)writeIterationWithBeaconMotionMeasurement:(BeaconMotionMeasurementStruct*)measurementStruct toFileWithName:(NSString*)name;

@end
