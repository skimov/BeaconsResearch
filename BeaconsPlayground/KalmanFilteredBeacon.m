//
//  KalmanFilteredBeacon.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/1/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "KalmanFilteredBeacon.h"

@implementation KalmanFilteredBeacon

//- (id)initWithPredictedVal:(double)predictedVal predictedErrorCovariance:(double)predictedErrorCovariance standardDeviationOfMeasurementNoise:(double)R measuredValue:(double)measuredVal macAddr:(NSString*)macAddr coordinates:(CGPoint)coordinates
//{
//    self = [super init];
//    
//    _measuredVal = measuredVal;
//    
//    _predictedVal = predictedVal;
//    _predictedErrorCovariance = predictedErrorCovariance;
//    _R = R;
//    
//    //Just 4 the 1st iteration
//    _correctedVal = _predictedVal;
//    _correctedErrorCovariance = _predictedErrorCovariance;
//    
//    self.macAddr = macAddr;
//    self.coordinates = coordinates;
//    
//    return self;
//}

- (id)initWithPredictedVal:(double)predictedVal predictedErrorCovariance:(double)predictedErrorCovariance standardDeviationOfMeasurementNoise:(double)R measuredValue:(double)measuredVal major:(int)major minor:(int)minor coordinates:(CGPoint)coordinates
{
    self = [super init];
    
    _measuredVal = measuredVal;
    
    _predictedVal = predictedVal;
    _predictedErrorCovariance = predictedErrorCovariance;
    _R = R;
    
    //Just 4 the 1st iteration
    _correctedVal = _predictedVal;
    _correctedErrorCovariance = _predictedErrorCovariance;
    
    self.major = [NSNumber numberWithInt:major];
    self.minor = [NSNumber numberWithInt:minor];
    self.coordinates = coordinates;
    
    return self;
}

- (id)initWithPrevIteration:(KalmanFilteredBeacon*)prevIteration measuredValue:(double)measuredVal
{
    self = [super init];
    
//    self.macAddr = prevIteration.macAddr;
    self.major = prevIteration.major;
    self.minor = prevIteration.minor;
    self.coordinates = prevIteration.coordinates;
    
    if (measuredVal > 0) _measuredVal = measuredVal;    //If measured val < 0 it means no value. So we just use an old one.
    else _measuredVal = _correctedVal;
    
    _predictedVal = prevIteration.correctedVal;
    _predictedErrorCovariance = prevIteration.correctedErrorCovariance;
    _R = prevIteration.R;
    
    return self;
}

- (void)performCorrection
{
    NSLog(@"performCorrection");
    NSLog(@"predicted err cov: %f   E: %f",_predictedErrorCovariance,_R);
    _K = _predictedErrorCovariance/(_predictedErrorCovariance + _R);
    NSLog(@"K: %f",_K);
    NSLog(@"val| predicted: %f   measured: %f",_predictedVal,_measuredVal);
    
    _correctedVal = _predictedVal + _K * (_measuredVal - _predictedVal);
    _correctedErrorCovariance = (1 - _K) * _predictedErrorCovariance;
    NSLog(@"corrected val: %f   cec: %f",_correctedVal,_correctedErrorCovariance);
    
    self.unfilteredDistance = _measuredVal;
    self.distance = _correctedVal;
}

@end
