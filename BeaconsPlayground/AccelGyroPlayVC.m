//
//  AccelGyroPlayVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/6/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "AccelGyroPlayVC.h"
#import <CoreMotion/CoreMotion.h>

@interface AccelGyroPlayVC ()

@property (strong, nonatomic) CMMotionManager * motionManager;


//Basic accel and gyro
@property (unsafe_unretained, nonatomic) CGFloat prevAccelerationY;
@property (unsafe_unretained, nonatomic) CGFloat prevSpeedY;
@property (unsafe_unretained, nonatomic) CGFloat distanceTraveled;

@property (unsafe_unretained, nonatomic) CGFloat sumRotationZ;


//Compass
@property (strong, nonatomic) CLLocationManager * locationManager;


//Advanced motion stuff
@property (strong, nonatomic) CMAttitude * initialAttitude;


//@property (strong, nonatomic) CMDeviceMotion * deviceMotion;

@end

@implementation AccelGyroPlayVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAccelAndGyro];
//    [self statLocationManagerCompass];
//    [self startAdvancedMotionStuff];
}

- (void)startAccelAndGyro
{
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = .2;
    _motionManager.gyroUpdateInterval = .2;
    
    _prevAccelerationY = 0;
    _prevSpeedY = 0;
    _distanceTraveled = 0;
    _sumRotationZ = 0;
    
//    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//        [self outputAccelertionData:accelerometerData.acceleration];
//        if(error) {
//            NSLog(@"%@", error);
//        }
//    }];
    
//    [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
//        [self outputRotationData:gyroData.rotationRate];
//    }];
    
//    [_motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
//        [self outputMagnetometerData:magnetometerData];
//    }];
    
    NSLog(@"Start device motion");
    _motionManager.deviceMotionUpdateInterval = 0.5;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@",error.description);
        }
        NSLog(@">>> x:%.2f  y:%.2f  z:%.2f",motion.userAcceleration.x,motion.userAcceleration.y,motion.userAcceleration.z);
        
        CGFloat G = 9.81;
        _currentAccelYGL.text = [NSString stringWithFormat:@"Current acceleration y G: %.2f g",motion.userAcceleration.y];
        _currentAccelYL.text = [NSString stringWithFormat:@"Current acceleration y: %.2f m/s^2",G*motion.userAcceleration.y];
        
        CGFloat currentAccelerationY = 0;
        if (fabs(motion.userAcceleration.y) > 0.02)                //Ignore the noise
            currentAccelerationY = G*motion.userAcceleration.y;
//            CGFloat currentSpeedY = _prevSpeedY + (_prevAccelerationY + currentAccelerationY)/2 * _motionManager.accelerometerUpdateInterval;
        CGFloat currentSpeedY = currentAccelerationY/2 * _motionManager.accelerometerUpdateInterval;
        _prevAccelerationY = currentAccelerationY;
        _currentSpeedYL.text = [NSString stringWithFormat:@"Current speed y: %.2f m/s",currentSpeedY];
        
        //    _distanceTraveled += (_prevSpeedY + currentSpeedY)/2 * _motionManager.accelerometerUpdateInterval;
        _distanceTraveled += currentSpeedY * _motionManager.accelerometerUpdateInterval;
        _prevSpeedY = currentSpeedY;
        _distanceTraveledL.text = [NSString stringWithFormat:@"Distance traveled: %.2f m",_distanceTraveled];
        
        _currentAccelerationXL.text = [NSString stringWithFormat:@"Current acceleration x: %.2f",G*motion.userAcceleration.x];
        _currentAccelerationZL.text = [NSString stringWithFormat:@"Current acceleration z: %.2f",G*motion.userAcceleration.z];
        
    }];
}

- (void)startAdvancedMotionStuff
{
    _initialAttitude = nil;
    _initialEulerL.text = [NSString stringWithFormat:@"Initial Euler x:%.2f y:%.2f z:%.2f",_initialAttitude.pitch,_initialAttitude.roll,_initialAttitude.yaw];
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
        [self outputMotionData:data];
    }];
}

-(void)statLocationManagerCompass
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    _locationManager.desiredAccuracy= kCLLocationAccuracyBestForNavigation;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [_locationManager requestWhenInUseAuthorization]; // Add This Line
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

#pragma mark - Output accel + gyro

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    CGFloat G = 9.81;
    _currentAccelYGL.text = [NSString stringWithFormat:@"Current acceleration y G: %.2f g",acceleration.y];
    _currentAccelYL.text = [NSString stringWithFormat:@"Current acceleration y: %.2f m/s^2",G*acceleration.y];
    
    CGFloat currentAccelerationY = 0;
    if (fabs(acceleration.y) > 0.02)                //Ignore the noise
        currentAccelerationY = G*acceleration.y;
//    CGFloat currentSpeedY = _prevSpeedY + (_prevAccelerationY + currentAccelerationY)/2 * _motionManager.accelerometerUpdateInterval;
    CGFloat currentSpeedY = currentAccelerationY/2 * _motionManager.accelerometerUpdateInterval;
    _prevAccelerationY = currentAccelerationY;
    _currentSpeedYL.text = [NSString stringWithFormat:@"Current speed y: %.2f m/s",currentSpeedY];
    
    
//    _distanceTraveled += (_prevSpeedY + currentSpeedY)/2 * _motionManager.accelerometerUpdateInterval;
    _distanceTraveled += currentSpeedY/2 * _motionManager.accelerometerUpdateInterval;
    _prevSpeedY = currentSpeedY;
    _distanceTraveledL.text = [NSString stringWithFormat:@"Distance traveled: %.2f m",_distanceTraveled];
    
    _currentAccelerationXL.text = [NSString stringWithFormat:@"Current acceleration x: %.2f",G*acceleration.x];
    _currentAccelerationZL.text = [NSString stringWithFormat:@"Current acceleration z: %.2f",G*acceleration.z];
}

-(void)outputRotationData:(CMRotationRate)rotation
{
//    NSLog(@"Rotation z: %f",rotation.z);
    _currentRotationZL.text = [NSString stringWithFormat:@"Current rotation z: %.2f r/s",rotation.z];
    if (fabs(rotation.z) > 0.05)   //Threshold for the noise
        _sumRotationZ += self.motionManager.gyroUpdateInterval*rotation.z;
    _sumRotationZL.text = [NSString stringWithFormat:@"Sum rotation z: %.2fr",_sumRotationZ];
}

- (void)outputMotionData:(CMDeviceMotion*)data
{
    if (!_initialAttitude)
        _initialAttitude = _motionManager.deviceMotion.attitude;
    
    _currentEulerL.text = [NSString stringWithFormat:@"Current Euler x:%.2f y:%.2f z:%.2f",data.attitude.pitch,data.attitude.roll,data.attitude.yaw];
    
    //Translate the attitude
    [data.attitude multiplyByInverseOfAttitude:_initialAttitude];
    _deltaEulerL.text = [NSString stringWithFormat:@"Delta Euler x:%.2f y:%.2f z:%.2f",data.attitude.pitch,data.attitude.roll,data.attitude.yaw];
    
    //Calculate magnitude of the change from our initial attitude
    //Magnitude from attitude
    CGFloat magnitude = sqrt(pow(data.attitude.roll, 2.0f) + pow(data.attitude.yaw, 2.0f) + pow(data.attitude.pitch, 2.0f));
    _magnitudeL.text = [NSString stringWithFormat:@"Magnitude: %.2f",magnitude];
}


#pragma mark - Compass through magnetometer in CoreLocation

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat headingDegrees = newHeading.magneticHeading; //in degrees
    CGFloat headingRadians = (headingDegrees*M_PI/180); //assuming needle points to top of iphone. convert to radians
    
    _compassDegreesL.text = [NSString stringWithFormat:@"Compass degrees: %.2f",headingDegrees];
    _compassRadiansL.text = [NSString stringWithFormat:@"Compass radians: %.2f",headingRadians];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
