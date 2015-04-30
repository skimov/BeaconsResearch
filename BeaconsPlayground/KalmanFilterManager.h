//
//  KalmanFilterManager.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/1/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KalmanFilteredBeacon.h"
#import "ESTBeacon.h"

@interface KalmanFilterManager : NSObject

//@property (unsafe_unretained, nonatomic) double R;

@property (strong, nonatomic) NSMutableArray * lastIteration;
@property (strong, nonatomic) NSMutableArray * currentIteration;

//- (id)initWithBeacons:(NSArray*)beacons standardDeviationOfMeasurementNoise:(double)R;
- (id)initWithBeacons:(NSArray *)beacons;

- (void)newIterationWithBeacons:(NSArray*)beacons;
- (void)newIterationWithSimulatedPoint:(CGPoint)point;

@end
