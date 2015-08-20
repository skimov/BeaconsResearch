//
//  KalmanFilterManager.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/1/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "KalmanBeaconFilterManager.h"

@implementation KalmanBeaconFilterManager

//- (id)initWithBeacons:(NSArray*)beacons standardDeviationOfMeasurementNoise:(double)R
//{
//    self = [super init];
//    
//    _lastIteration = nil;
//    _currentIteration = [[NSMutableArray alloc] init];
//    for (ESTBeacon * beacon in beacons)
//    {
//        //TODO: check if we need to somehow modify rssi as measured value
//        //Neverming we use distances here. Problematically to get the distance from rssi.
//        KalmanFilteredBeacon * filteredBeacon = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:R measuredValue:beacon.rssi macAddr:beacon.macAddress];
//        
//        [_currentIteration addObject:filteredBeacon];
//    }
//    
//    return self;
//}

- (id)initWithBeacons:(NSArray *)beacons
{
    self = [super init];
    
    _lastIteration = nil;
    _currentIteration = [[NSMutableArray alloc] init];
    for (KalmanFilteredBeacon * beacon in beacons)
    {
        [_currentIteration addObject:beacon];
    }
    
    return self;
}

//Recursively perform iteration. Calculate next values based on previous values.
- (void)newIterationWithBeacons:(NSArray*)beacons
{
    _lastIteration = [NSMutableArray arrayWithArray:_currentIteration];
    NSMutableArray * processedLastIterationBeacons = [[NSMutableArray alloc] init]; //This one to keep track of all processed beacons in this iteration, and then remove them from last iteration. All unprocessed ones from prev iteration will be added to the current one in the unchanged state.
    _currentIteration = [[NSMutableArray alloc] init];
    for (ESTBeacon * beacon in beacons)
    {
        KalmanFilteredBeacon * filteredBeacon = nil;
//        NSLog(@"Beacon mac: %@",filteredBeacon.macAddr);
        for (KalmanFilteredBeacon * iteratedFilteredBeacon in _lastIteration)
        {
//            NSLog(@"Kalman filtered beacon mac: %@",iteratedFilteredBeacon.macAddr);
//            if ([iteratedFilteredBeacon.macAddr isEqualToString:beacon.macAddress])
            if ( (iteratedFilteredBeacon.major.integerValue == beacon.major.integerValue) && (iteratedFilteredBeacon.minor.integerValue == beacon.minor.integerValue) )
            {
                filteredBeacon = iteratedFilteredBeacon;
                break;
            }
        }
        
        if (!filteredBeacon) continue;
        NSLog(@"DISTANCE: %f",beacon.distance.doubleValue);
        KalmanFilteredBeacon * newFilteredBeacon = [[KalmanFilteredBeacon alloc] initWithPrevIteration:filteredBeacon measuredValue:beacon.distance.doubleValue];
        
        [newFilteredBeacon performCorrection];
        NSLog(@"Corrected value: %f",newFilteredBeacon.correctedVal);
        [_currentIteration addObject:newFilteredBeacon];
        [processedLastIterationBeacons addObject:filteredBeacon];
    }
    
    //This one to process the case when some beacon is not returned for some iteration.
    //Actually have to think more about that.
    //For example do we just use the old values for the skipped beacon next iteration. Or just recreate it from scratch next time it is spotted.
    //I say we keep the old values. Because if we lost a beacon somewhere - we find it back when we return back, supposedly around the place where it was lost. And even if not - it will be fixed in some iterations, maybe still better than start from 0.
    [_lastIteration removeObjectsInArray:processedLastIterationBeacons];
    for (KalmanFilteredBeacon * skippedBeacon in _lastIteration)
    {
        [_currentIteration addObject:skippedBeacon];
    }
}



- (float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (void)newIterationWithSimulatedPoint:(CGPoint)point
{
    _lastIteration = [NSMutableArray arrayWithArray:_currentIteration];
    _currentIteration = [[NSMutableArray alloc] init];
    for (KalmanFilteredBeacon * prevIterationBeacon in _lastIteration)
    {
        CGFloat distance = [self distanceFrom:point to:prevIterationBeacon.coordinates];
        NSLog(@"SIMULATED DISTANCE TO BEACON: %f",distance);
        KalmanFilteredBeacon * newFilteredBeacon = [[KalmanFilteredBeacon alloc] initWithPrevIteration:prevIterationBeacon measuredValue:distance];
        [newFilteredBeacon performCorrection];
        [_currentIteration addObject:newFilteredBeacon];
    }
}





@end
