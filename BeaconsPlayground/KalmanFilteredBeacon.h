//
//  KalmanFilteredBeacon.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/1/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RangedBeacon.h"

@interface KalmanFilteredBeacon : RangedBeacon

@property (unsafe_unretained, nonatomic) double measuredVal;

@property (unsafe_unretained, nonatomic) double predictedVal;
@property (unsafe_unretained, nonatomic) double predictedErrorCovariance;

@property (unsafe_unretained, nonatomic) double correctedVal;
@property (unsafe_unretained, nonatomic) double correctedErrorCovariance;

@property (unsafe_unretained, nonatomic) double K;   //Kalman coef
@property (unsafe_unretained, nonatomic) double R;   //the standard deviation of the measurement noise

- (id)initWithPredictedVal:(double)predictedVal predictedErrorCovariance:(double)predictedErrorCovariance standardDeviationOfMeasurementNoise:(double)R measuredValue:(double)measuredVal macAddr:(NSString*)macAddr coordinates:(CGPoint)coordinates;
- (id)initWithPrevIteration:(KalmanFilteredBeacon*)prevIteration measuredValue:(double)measuredVal;

- (void)performCorrection;

@end
