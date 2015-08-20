//
//  KalmanBeaconMotionFilter.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/13/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KBMMatrix.h"

@interface KalmanBeaconMotionFilter : NSObject

//Position
@property (strong, nonatomic) KBMMatrix * currentPosition;
@property (strong, nonatomic) KBMMatrix * estimatedPosition;
@property (strong, nonatomic) KBMMatrix * measuredPosition;
@property (strong, nonatomic) KBMMatrix * correctedPosition;

//Error covariance
@property (strong, nonatomic) KBMMatrix * currentErrorCovariance;
@property (strong, nonatomic) KBMMatrix * estimatedErrorCovariance;
@property (strong, nonatomic) KBMMatrix * correctedErrorCovariance;

//Covariance
@property (strong, nonatomic) KBMMatrix * covarianceOfProcessNoise;
@property (strong, nonatomic) KBMMatrix * processNoise;
@property (strong, nonatomic) KBMMatrix * covarianceOfMeasurementNoise;
@property (strong, nonatomic) KBMMatrix * measurementNoise;

//Gain
@property (strong, nonatomic) KBMMatrix * kalmanGain;

- (instancetype)initWithPosition:(CGPoint)position errorCovariance:(CGFloat)errorCovariance covarianceOfProcessNoise:(CGFloat)covarianceOfProcessNoise covarianceOfMeasurementNoise:(CGFloat)covarianceOfMeasurementNoise;

- (void)performPredictionWithPoint:(CGPoint)distanceMoved;
- (void)performCorrectionWithMeasuredLocation:(CGPoint)measuredLocation;
- (CGPoint)getCurrentPosition;

@end
