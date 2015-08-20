//
//  KalmanBeaconMotionFilter.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/13/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "KalmanBeaconMotionFilter.h"
#import "NormalDistribution.h"

@implementation KalmanBeaconMotionFilter

- (instancetype)initWithPosition:(CGPoint)position errorCovariance:(CGFloat)errorCovariance covarianceOfProcessNoise:(CGFloat)covarianceOfProcessNoise covarianceOfMeasurementNoise:(CGFloat)covarianceOfMeasurementNoise
{
    self = [super init];
    
    _currentPosition = [[KBMMatrix alloc] initWithPoint:position];
    _currentErrorCovariance = [[KBMMatrix alloc] initWithConst:errorCovariance];
    _covarianceOfProcessNoise = [[KBMMatrix alloc] initWithConst:covarianceOfProcessNoise];
    _covarianceOfMeasurementNoise = [[KBMMatrix alloc] initWithConst:covarianceOfMeasurementNoise];
    
    return self;
}

- (void)performPredictionWithPoint:(CGPoint)distanceMoved
{
    NSLog(@"%@ - performPredictionWithPoint: %.2f %.2f",[self.class description],distanceMoved.x,distanceMoved.y);
    NSLog(@"Current position: %.2f %.2f",_currentPosition.xVal,_currentPosition.yVal);
    
    //TODO: imlpement normal distribution and add process noise (need to init it's value)
    _processNoise = [[KBMMatrix alloc] initWithConst:[NormalDistribution valueFromMean:0 covariance:_covarianceOfProcessNoise.xVal]];
    NSLog(@"Process noise: %.2f %.2f",_processNoise.xVal,_processNoise.yVal);
    
    _estimatedPosition = [[_currentPosition add:[[KBMMatrix alloc] initWithPoint:distanceMoved]] add:_processNoise];
//    _estimatedPosition = [_currentPosition add:[[KBMMatrix alloc] initWithPoint:distanceMoved]];
    ///>>> BOOLSHIT
    NSLog(@"Estimated position: %.2f %.2f",_estimatedPosition.xVal,_estimatedPosition.yVal);
    
    _estimatedErrorCovariance = [_currentErrorCovariance add:_covarianceOfProcessNoise];
    NSLog(@"Estimated error covariance: %.2f %.2f",_estimatedErrorCovariance.xVal,_estimatedErrorCovariance.yVal);
}

- (void)performCorrectionWithMeasuredLocation:(CGPoint)measuredLocation
{
    NSLog(@"%@ - performCorrectionWithMeasuredLocation: %.2f %.2f",[self.class description],measuredLocation.x,measuredLocation.y);
    _measuredPosition = [[KBMMatrix alloc] initWithPoint:measuredLocation];
    
    //Cheating a bit here,  but our 2D matrices hold 2 same values anyways, cause x,y vector influences both coordinates in the same manner.
    CGFloat K = _estimatedErrorCovariance.xVal/(_estimatedErrorCovariance.xVal + _covarianceOfMeasurementNoise.xVal);
    _kalmanGain = [[KBMMatrix alloc] initWithConst:K];
    NSLog(@"K: %.2f",_kalmanGain.xVal);
    
    //TODO: implement normal distribution to add measurement noise
    _measurementNoise = [[KBMMatrix alloc] initWithConst:[NormalDistribution valueFromMean:0 covariance:_covarianceOfMeasurementNoise.xVal]];
    NSLog(@"Measurement noise: %.2f %.2f",_measurementNoise.xVal,_measurementNoise.yVal);
    KBMMatrix * measurementResidual = [[_measuredPosition add:_measurementNoise] subtract:_estimatedPosition];
    NSLog(@"Measurement residual: %.2f %.2f",measurementResidual.xVal,measurementResidual.yVal);
    
    ///>>> BOOOLSHIT
    _correctedPosition = [_estimatedPosition add:[_kalmanGain multiplyBy:measurementResidual]];
    NSLog(@"Corrected position: %.2f %.2f",_correctedPosition.xVal,_correctedPosition.yVal);
    _correctedErrorCovariance = [[[[KBMMatrix alloc] initWithConst:1] subtract:_kalmanGain] multiplyBy:_estimatedErrorCovariance];
    NSLog(@"Corrected error covariance: %.2f %.2f",_correctedErrorCovariance.xVal,_correctedErrorCovariance.yVal);
    
    _currentPosition = _correctedPosition;
    _currentErrorCovariance = _correctedErrorCovariance;
}

- (CGPoint)getCurrentPosition
{
    return CGPointMake(_currentPosition.xVal, _currentPosition.yVal);
}

@end
