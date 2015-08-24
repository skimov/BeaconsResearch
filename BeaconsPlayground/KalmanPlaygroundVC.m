//
//  KalmanPlaygroundVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/2/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "KalmanPlaygroundVC.h"
//Kalman - 1D, for each beacon
//#import "KalmanBeaconFilterManager.h"
//#import "KalmanFilteredBeacon.h"
//Model
#import "Wall.h"
#import "RangedBeacon.h"
//Visualization
#import "IndoorMappingModel.h"
#import "DisplayMappingVC.h"
//Dead reckoning
#import <CoreMotion/CoreMotion.h>
//Kalman - 2D location (beacons + dead reckoning)
#import "KalmanBeaconMotionFilter.h"

#import "MiBeaconTrilateration.h"
#import "NormalDistribution.h"

#import "MeasurementWriter.h"
#import "BeaconMotionMeasurementStruct.h"

//To check for nan in trilateration
#include <math.h>

//Accumulate several beacons responses
#import "PointStruct.h"

#define kStepDistance 0.5

@interface KalmanPlaygroundVC ()

///Beacons
//SDK stuff.
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;

//Mine. Keeping the variables and parameters for the system.
@property (strong, nonatomic) NSMutableArray * walls;
@property (unsafe_unretained, nonatomic) CGPoint initialPosition;
@property (strong, nonatomic) NSMutableArray * initialBeacons;
@property (strong, nonatomic) NSMutableArray * discoveredBeacons;
@property (unsafe_unretained, nonatomic) double standardDeviationOfMeasurementNoise;    //R
@property (unsafe_unretained, nonatomic) double standardDeviationOfProcessNoise;    //Q
//@property (strong, nonatomic) KalmanBeaconFilterManager * kalmanFilterManager;

@property (strong, nonatomic) KalmanBeaconMotionFilter * kalmanBeaconMotionFilter;
@property (unsafe_unretained, nonatomic) CGPoint lastTrilaterationPoint;

//Viualization classes.
@property (strong, nonatomic) IndoorMappingModel * map;
@property (strong, nonatomic) DisplayMappingVC * displayVC;
@property (unsafe_unretained, nonatomic) BOOL initializedMap;

//Additional UI.
@property (strong, nonatomic) UIButton * turnRangingOnOffB;
@property (unsafe_unretained, nonatomic) BOOL rangingOn;
@property (strong, nonatomic) UIButton * turnDeadReckoningOnOffB;
@property (unsafe_unretained, nonatomic) BOOL deadReckoningOn;
@property (strong, nonatomic) UILabel * stepsCountL;

///Dead reckoning.
@property (strong, nonatomic) CMMotionManager * motionManager;
@property (strong, nonatomic) CMAttitude * initialAttitude;
@property (unsafe_unretained, nonatomic) CGFloat rotationZ;

@property (unsafe_unretained, nonatomic) CGPoint deadReckoningDeltaCoord;

//DR stuff later to be moved to kind of motion manager (or not, if lazy)
//@property (unsafe_unretained, nonatomic) Coor

//Measurement
@property (strong, nonatomic) NSDate * experimentStartDate;
@property (unsafe_unretained, nonatomic) int iterationCount;
@property (strong, nonatomic) NSString * measurementFileName;

//For an approach one iteration = 1 step. Accumulating beacons points.
//Or every N beacon signals. Or every N seconds.
@property (unsafe_unretained, nonatomic) int intermediateBeaconsSignalsCount;
@property (strong, nonatomic) NSMutableArray * intermediateBeaconsSignalsArrMu;

@end

@implementation KalmanPlaygroundVC

#pragma mark - Init

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MeasurementWriter sharedInstance];
    
    _measurementFileName = @"2D Experiment Square 1.txt";
    [[MeasurementWriter sharedInstance] createMeasurementFileWithName:_measurementFileName];
    
    NSLog(@"Measurement file exists: %d",[[MeasurementWriter sharedInstance] measurementFileExistsWithName:_measurementFileName]);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initBeacons];                                 //Map beacons
    
    
    [self createEstimoteBeaconManagerWithRegion];       //Start with location manager first discover then ranging beacons
    
    ///TESTING!!
//    if (!_map)                  //Only the 1st time to create the map with the beacons and the walls
//    {
//        _map = [[IndoorMappingModel alloc] initWithBeacons:_initialBeacons walls:_walls];
//        [self initDisplayVC];
//        [_displayVC displayWalls:_walls];
//        [self createRangingOnOffButton];
//        [self createDeadReckoningOnOffButton];
//    }
//    _kalmanBeaconMotionFilter = [[KalmanBeaconMotionFilter alloc] initWithPosition:_initialPosition errorCovariance:1 covarianceOfProcessNoise:_standardDeviationOfProcessNoise covarianceOfMeasurementNoise:_standardDeviationOfMeasurementNoise];
//    _lastTrilaterationPoint = _initialPosition;
}

- (void)initBeacons
{
    _walls = [[NSMutableArray alloc] init];
    _discoveredBeacons = [[NSMutableArray alloc] init];
    _initialBeacons = [[NSMutableArray alloc] init];
    //TODO: calibrate these params
//    _standardDeviationOfMeasurementNoise = 0.5;
//    _standardDeviationOfProcessNoise = 0.5;
    _standardDeviationOfMeasurementNoise = 0.1;
    _standardDeviationOfProcessNoise = 0.1;
    
    
    //Init beacons with coordinates, major and minor values here:
//    KalmanFilteredBeacon * beacon1 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 major:1 minor:1 coordinates:CGPointMake(0, 6.75)];
    
    RangedBeacon * beacon1 = [[RangedBeacon alloc] initWithMajor:1 minor:10 coordinates:CGPointMake(0, 6.75)];
    [_initialBeacons addObject:beacon1];
//    RangedBeacon * beacon1 = [[RangedBeacon alloc] initWithMajor:8661 minor:30611 coordinates:CGPointMake(0, 6.75)];
//    [_initialBeacons addObject:beacon1];
    Wall * wall1 = [[Wall alloc] initWithStart:CGPointMake(0, 0) end:CGPointMake(0, 13.5)];
    [_walls addObject:wall1];
    
    
//    KalmanFilteredBeacon * beacon2 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 major:1 minor:2 coordinates:CGPointMake(2.25, 13.5)];
    
    RangedBeacon * beacon2 = [[RangedBeacon alloc] initWithMajor:1 minor:20 coordinates:CGPointMake(2.25, 0)];
    [_initialBeacons addObject:beacon2];
//    RangedBeacon * beacon2 = [[RangedBeacon alloc] initWithMajor:28360 minor:57119 coordinates:CGPointMake(2.25, 0)];
    [_initialBeacons addObject:beacon2];
    Wall * wall2 = [[Wall alloc] initWithStart:CGPointMake(4.5, 0) end:CGPointMake(0, 0)];
    [_walls addObject:wall2];
    
    
//    KalmanFilteredBeacon * beacon3 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 major:1 minor:3 coordinates:CGPointMake(4.5, 6.75)];
    
    RangedBeacon * beacon3 = [[RangedBeacon alloc] initWithMajor:1 minor:30 coordinates:CGPointMake(4.5, 6.75)];
    [_initialBeacons addObject:beacon3];
//    RangedBeacon * beacon3 = [[RangedBeacon alloc] initWithMajor:16127 minor:61009 coordinates:CGPointMake(4.5, 6.75)];
    [_initialBeacons addObject:beacon3];
    Wall * wall3 = [[Wall alloc] initWithStart:CGPointMake(4.5, 13.5) end:CGPointMake(4.5, 0)];
    [_walls addObject:wall3];
    
    
//    KalmanFilteredBeacon * beacon4 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 major:1 minor:4 coordinates:CGPointMake(2.25, 0)];
    
    RangedBeacon * beacon4 = [[RangedBeacon alloc] initWithMajor:1 minor:40 coordinates:CGPointMake(2.25, 13.5)];
    [_initialBeacons addObject:beacon4];
//    RangedBeacon * beacon4 = [[RangedBeacon alloc] initWithMajor:58254 minor:5350 coordinates:CGPointMake(2.25, 13.5)];
    [_initialBeacons addObject:beacon4];
    Wall * wall4 = [[Wall alloc] initWithStart:CGPointMake(0, 13.5) end:CGPointMake(4.5, 13.5)];
    [_walls addObject:wall4];
    
    _initialPosition = CGPointMake(2.25, 6.75);
    
}

- (void)createEstimoteBeaconManagerWithRegion
{
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.returnAllRangedBeaconsAtOnce = YES;
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    //    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID major:1 minor:10 identifier:@"EstimoteSampleRegion" ];
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    [self startRangingBeacons];
}



#pragma mark - Authorize & start beacon ranging

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus: %d",status);
    _rangingOn = YES;
    [self startRangingBeacons];
}

-(void)startRangingBeacons
{
    NSLog(@"startRangingBeacons");
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             */
            NSLog(@"iOS < 8");
            _rangingOn = YES;
            [self.beaconManager startRangingBeaconsInRegion:self.region];
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            [self.beaconManager requestAlwaysAuthorization];
        }
    }
    else if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)//kCLAuthorizationStatusAuthorized)
    {
        NSLog(@"authorized");
        _rangingOn = YES;
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}



#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [errorView show];
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
//    NSLog(@"%@ - didRangeBeacons: %lu\n-------------------",[self.class description],(unsigned long)beacons.count);
    
//    if (!_initializedMap)
    if (!_map)                  //Only the 1st time to create the map with the beacons and the walls
    {
        _map = [[IndoorMappingModel alloc] initWithBeacons:_initialBeacons walls:_walls];
        [self initDisplayVC];
        [_displayVC displayWalls:_walls];
        [self createRangingOnOffButton];
        [self createDeadReckoningOnOffButton];
//        _initializedMap = YES;
    }
    
    for (ESTBeacon * beacon in beacons)
    {
//        NSLog(@"%@ - proximityUUID: %@",[self.class description],beacon.proximityUUID.UUIDString);
//        NSLog(@"%@ - RSSI: %ld",[self.class description],beacon.rssi);
//        NSLog(@"Distance: %f",beacon.distance.doubleValue);
//        NSLog(@"Major: %d  minor: %d",beacon.major.intValue,beacon.minor.intValue);
        
//        KalmanFilteredBeacon * discoveredBeacon = nil;
//        for (KalmanFilteredBeacon * kfb in _initialBeacons)
        RangedBeacon * discoveredBeacon = nil;
        for (RangedBeacon * iteratedBeacon in _initialBeacons)
        {
            if ( (iteratedBeacon.major.integerValue == beacon.major.integerValue) && (iteratedBeacon.minor.integerValue == beacon.minor.integerValue) )
            {
                discoveredBeacon = iteratedBeacon;
//                kfb.major = beacon.major;
//                kfb.minor = beacon.minor;
                [_discoveredBeacons addObject:iteratedBeacon];
                break;
            }
        }
        [_initialBeacons removeObject:discoveredBeacon];
    }
    
    if (!_kalmanBeaconMotionFilter)
    {
        if (_discoveredBeacons.count >= 3)
        {
            _kalmanBeaconMotionFilter = [[KalmanBeaconMotionFilter alloc] initWithPosition:_initialPosition errorCovariance:1 covarianceOfProcessNoise:_standardDeviationOfProcessNoise covarianceOfMeasurementNoise:_standardDeviationOfMeasurementNoise];
            _lastTrilaterationPoint = _initialPosition;
            
            _experimentStartDate = [NSDate date];
            _iterationCount = 0;
        }
    }
    else
    {
        [self performIterationWithBeacons:beacons];
    }
    
//    if (!_kalmanFilterManager)      //Init filter manager when discovered at least 3 beacons. So can perform trilateration.
//    {
//        if (_discoveredBeacons.count >= 3)
//        {
//            _kalmanFilterManager = [[KalmanBeaconFilterManager alloc] initWithBeacons:_map.beacons];
//        }
//    }
//    else
//    {
//        ///ACHTUNG: just to test
////        [self performIterationWithBeacons:beacons];
//    }
}

- (void)addInitialCoordinatesToRangedBeacons:(NSArray*)beacons
{
    for (RangedBeacon * beacon in beacons)
    {
        for (RangedBeacon * initialBeacon in _discoveredBeacons)
        {
            if ( ([beacon.major intValue] == [initialBeacon.major intValue]) && ([beacon.minor intValue] == [initialBeacon.minor intValue]) )
            {
                beacon.coordinates = initialBeacon.coordinates;
                break;
            }
        }
    }
}

- (void)performIterationWithBeacons:(NSArray*)beacons
{
    NSLog(@"%@ - performIterationWithBeacons: %ld",[self.class description],beacons.count);
    
    //ESTBeacons to RangedBeacons
    NSMutableArray * rangedBeacons = [[NSMutableArray alloc] init];
    for (ESTBeacon * beacon in beacons)
    {
        RangedBeacon * rangedBeacon = [[RangedBeacon alloc] initWithEstimoteBeacon:beacon];
        [rangedBeacons addObject:rangedBeacon];
    }
    [self addInitialCoordinatesToRangedBeacons:rangedBeacons];
    
    for (RangedBeacon * beacon in rangedBeacons)
    {
        NSLog(@">>> %.2f %.2f - %.2f - %d %d",beacon.coordinates.x,beacon.coordinates.y,beacon.distance,beacon.major.intValue,beacon.minor.intValue);
    }
    
    CGPoint currentLocationByDR = CGPointMake(_lastTrilaterationPoint.x + _deadReckoningDeltaCoord.x, _lastTrilaterationPoint.y + _deadReckoningDeltaCoord.y);
    CGPoint unfilteredTrilateratedFromBeaconsPoint = [MiBeaconTrilateration trilaterateLocationFromBeacons:rangedBeacons];
    if ( (unfilteredTrilateratedFromBeaconsPoint.x == 0) && (unfilteredTrilateratedFromBeaconsPoint.y == 0) )
    {
        NSLog(@"Skipping step. Not enough beacon signals for trilateration.");
        unfilteredTrilateratedFromBeaconsPoint = _lastTrilaterationPoint;
    }
    if (isnan(unfilteredTrilateratedFromBeaconsPoint.x) || isnan(unfilteredTrilateratedFromBeaconsPoint.y))
    {
        NSLog(@"Skipping step. Bad trilateration.");
        unfilteredTrilateratedFromBeaconsPoint = _lastTrilaterationPoint;
    }
    NSLog(@"Previous location: %.2f %.2f",_lastTrilaterationPoint.x,_lastTrilaterationPoint.y);
    NSLog(@"Delta trilateration: %.2f %.2f",_deadReckoningDeltaCoord.x,_deadReckoningDeltaCoord.y);
    NSLog(@"Dead reckoning predicted position: %.2f %.2f",currentLocationByDR.x,currentLocationByDR.y);
    NSLog(@"Unfiltered trilaterated position: %.2f %.2f",unfilteredTrilateratedFromBeaconsPoint.x,unfilteredTrilateratedFromBeaconsPoint.y);
    
//    [_kalmanBeaconMotionFilter performPredictionWithPoint:currentLocationByDR];
    [_kalmanBeaconMotionFilter performPredictionWithPoint:_deadReckoningDeltaCoord];
    [_kalmanBeaconMotionFilter performCorrectionWithMeasuredLocation:unfilteredTrilateratedFromBeaconsPoint];
    _lastTrilaterationPoint = [_kalmanBeaconMotionFilter getCurrentPosition];
    _deadReckoningDeltaCoord = CGPointMake(0, 0);
    NSLog(@"Filtered new coordinate: %.2f %.2f",_lastTrilaterationPoint.x,_lastTrilaterationPoint.y);
    
    //Fix the position to account for walls
    _lastTrilaterationPoint = [_map correctLocation:_lastTrilaterationPoint];
    _kalmanBeaconMotionFilter.currentPosition = [[KBMMatrix alloc] initWithPoint:_lastTrilaterationPoint];
    NSLog(@"Filtered new coordinate corrected for walls: %.2f %.2f",_lastTrilaterationPoint.x,_lastTrilaterationPoint.y);
    
    [_displayVC visualizeIterationForCoordinate:_lastTrilaterationPoint];
    [_displayVC setPositionAngle:_rotationZ];
    
    NSTimeInterval secondsFromStart = [[NSDate date] timeIntervalSinceDate:_experimentStartDate];
    _iterationCount++;
    BeaconMotionMeasurementStruct * measurementStruct = [[BeaconMotionMeasurementStruct alloc] initWithIterationCount:_iterationCount secondsFromMeasurementStart:secondsFromStart filteredCoordinate:_lastTrilaterationPoint beaconsCoordinate:unfilteredTrilateratedFromBeaconsPoint deadReckoningCoordinate:currentLocationByDR K:_kalmanBeaconMotionFilter.kalmanGain.xVal];
    [[MeasurementWriter sharedInstance] writeIterationWithBeaconMotionMeasurement:measurementStruct toFileWithName:_measurementFileName];
}

//- (void)performIterationWithBeacons:(NSArray*)beacons
//{
//    [_kalmanFilterManager newIterationWithBeacons:beacons];
//    
//    //    [_map correctLocation:];
//    [_displayVC visualizeIterationForBeacons:_kalmanFilterManager.currentIteration];
//}


#pragma mark - Dead Reckoning (Motion)

- (void)startAdvancedMotionStuff
{
    _initialAttitude = nil;
//    _initialEulerL.text = [NSString stringWithFormat:@"Initial Euler x:%.2f y:%.2f z:%.2f",_initialAttitude.pitch,_initialAttitude.roll,_initialAttitude.yaw];
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = .2;
    _motionManager.gyroUpdateInterval = .2;
    [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
        if (!_initialAttitude)
            _initialAttitude = _motionManager.deviceMotion.attitude;
        
        //Translate the attitude
        [data.attitude multiplyByInverseOfAttitude:_initialAttitude];
        _rotationZ = data.attitude.yaw;
//        NSLog(@"Current rotation z: %.2f",_rotationZ);
        [_displayVC setPositionAngle:_rotationZ];
    }];
    
    //Pedometer
    [[Pedometer sharedIntance] SetDelegate:self];
    [[Pedometer sharedIntance] start];
}

- (void)stopAdvancedMotionStuff
{
    [_motionManager stopDeviceMotionUpdates];
    _motionManager = nil;
    _initialAttitude = nil;
    [[Pedometer sharedIntance] stop];
}

- (void)DidStep:(NSNumber*)step
{
    [_stepsCountL setText:[NSString stringWithFormat:@"%.0f steps", step.doubleValue]];
//    CGPoint oldPoint = [_displayVC oldLocationInMeters];
    CGPoint oldPoint = _deadReckoningDeltaCoord;
    //TODO: check this formula
    CGFloat newX = oldPoint.x + kStepDistance * cos(M_PI_2-_rotationZ);
    CGFloat newY = oldPoint.y - kStepDistance * cos(_rotationZ);
    CGPoint newPoint = CGPointMake(newX, newY);
    _deadReckoningDeltaCoord = newPoint;
//    [_displayVC visualizeIterationForCoordinate:newPoint];
    [_displayVC visualizeIterationForCoordinate:CGPointMake(_lastTrilaterationPoint.x + _deadReckoningDeltaCoord.x, _lastTrilaterationPoint.y + _deadReckoningDeltaCoord.y)];
    [_displayVC setPositionAngle:_rotationZ];
}

#pragma mark - Visualization

//- (void)mapDiscoveredBeacons:(NSArray*)beacons
//{
//    _map = [[IndoorMappingModel alloc] initWithBeacons:_discoveredBeacons walls:_walls];
//    //    _map.beacons = _discoveredBeacons;
//    //    _map.walls = _walls;
//}

- (void)initDisplayVC
{
    _displayVC = [[DisplayMappingVC alloc] init];
    _displayVC.mappedModel = _map;
    _displayVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width - 100, self.view.frame.size.height);
    
    __weak KalmanPlaygroundVC *weakSelf = self;
    _displayVC.didTapMap = ^(CGPoint coordinates)   //Simulate iteration with beacons. Just returns a location for now.
    {
        [weakSelf performIterationWithSimulatedPoint:coordinates];
        
//        CGPoint covarianceForSimulatedLocation = CGPointMake(1.0, 1.0);
//        CGPoint coordinateWithNoise = [NormalDistribution pointFromMeanPoint:coordinates covariancePoint:covarianceForSimulatedLocation];
//        NSLog(@"Tapped coordinate: %f %f  + noise: %f %f",coordinates.x,coordinates.y,coordinateWithNoise.x,coordinateWithNoise.y);
//        
//        [weakSelf.kalmanBeaconMotionFilter performPredictionWithPoint:CGPointMake(weakSelf.lastTrilaterationPoint.x + weakSelf.deadReckoningDeltaCoord.x, weakSelf.lastTrilaterationPoint.y + weakSelf.deadReckoningDeltaCoord.y)];
//        [weakSelf.kalmanBeaconMotionFilter performCorrectionWithMeasuredLocation:coordinateWithNoise];
//        
//        weakSelf.lastTrilaterationPoint = [weakSelf.kalmanBeaconMotionFilter getCurrentPosition];
//        weakSelf.deadReckoningDeltaCoord = CGPointMake(0, 0);
//        
//        [weakSelf.displayVC visualizeIterationForCoordinate:weakSelf.lastTrilaterationPoint];
//        [weakSelf.displayVC setPositionAngle:weakSelf.rotationZ];
        
        //Old
//        [weakSelf.kalmanFilterManager newIterationWithSimulatedPoint:coordinates];
//        [weakSelf.displayVC visualizeIterationForBeacons:weakSelf.kalmanFilterManager.currentIteration];
    };
    
    [self addChildViewController:_displayVC];
    [self.view addSubview:_displayVC.view];
    [_displayVC didMoveToParentViewController:self];
//    _displayVC.view.center = self.view.center;
    
//    NSLog(@"Initial beacons: %d  map beacons: %d",_initialBeacons.count,_map.beacons.count);
    [_displayVC precalculateVisualizationParamsForBeacons:_displayVC.mappedModel.beacons];
    [_displayVC displayWalls:_displayVC.mappedModel.walls];
//    [_displayVC precalculateVisualizationParamsForBeacons:_map.beacons];
}

//- (void)initFilterManager
//{
//    _kalmanFilterManager = [[KalmanFilterManager alloc] initWithBeacons:_map.beacons];
//}

#pragma mark - to simulate beacons + noise by tap

- (float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (void)performIterationWithSimulatedPoint:(CGPoint)point
{
    for (RangedBeacon * beacon in _initialBeacons)
    {
        beacon.distance = [self distanceFrom:point to:beacon.coordinates];
        NSLog(@"Simulated distance without noise: %.2f",beacon.distance);
//        CGFloat measurementDeviation = 0.5;
//        beacon.distance = [NormalDistribution valueFromMean:beacon.distance covariance:measurementDeviation];    //Adding deviation for distance
//        NSLog(@"Simulated distance: %.2f  for major: %.2f  minor: %.2f",beacon.distance,[beacon.major doubleValue],[beacon.minor doubleValue]);
    }
//    CGPoint trilateratedPoint = [MiBeaconTrilateration trilaterateLocationFromBeacons:_initialBeacons];
//    [_displayVC visualizeIterationForCoordinate:trilateratedPoint];
    [self performIterationWithBeacons:_initialBeacons];
}


#pragma mark - Gather values from several beacon signals, and then count the average

- (void)addPointToAccumulateBeaconsSignals:(CGPoint)point
{
    if (!_intermediateBeaconsSignalsArrMu)
    {
        _intermediateBeaconsSignalsArrMu = [[NSMutableArray alloc] init];
        _intermediateBeaconsSignalsCount = 0;
    }
    
    PointStruct * pointStruct = [[PointStruct alloc] initWithPoint:point];
    [_intermediateBeaconsSignalsArrMu addObject:pointStruct];
    _intermediateBeaconsSignalsCount++;
}

- (CGPoint)getAccumulatedBeaconsSignal
{
    CGFloat deltaX = 0;
    CGFloat deltaY = 0;
    
    for (PointStruct * point in _intermediateBeaconsSignalsArrMu)
    {
        deltaX += point.xCoord;
        deltaY += point.yCoord;
    }
    
    deltaX = deltaX/_intermediateBeaconsSignalsCount;
    deltaY = deltaY/_intermediateBeaconsSignalsCount;
    
    return CGPointMake(deltaX, deltaY);
}

- (CGPoint)pointWithOneStepToPoint:(CGPoint)stepToPoint fromPoint:(CGPoint)stepFromPoint
{
    CGFloat distance = [self distanceFrom:stepFromPoint to:stepToPoint];
    CGFloat proportion = kStepDistance/distance;
    
    CGFloat deltaX = (stepToPoint.x - stepFromPoint.x)*proportion;
    CGFloat deltaY = (stepToPoint.y - stepFromPoint.y)*proportion;
    
    CGPoint finalPoint = CGPointMake(stepFromPoint.x + deltaX, stepFromPoint.y + deltaY);
    return finalPoint;
}

#pragma mark - UI

- (void)createRangingOnOffButton
{
    _turnRangingOnOffB = [UIButton buttonWithType:UIButtonTypeSystem];
    _turnRangingOnOffB.frame = CGRectMake(_displayVC.view.frame.origin.x + _displayVC.view.frame.size.width, 50, 100, 50);
    [_turnRangingOnOffB addTarget:self action:@selector(turnRangingOnOff) forControlEvents:UIControlEventTouchUpInside];
    [self setRangingOnOffButtonTitle];
    [self.view addSubview:_turnRangingOnOffB];
}

- (void)setRangingOnOffButtonTitle
{
    if (_rangingOn) [_turnRangingOnOffB setTitle:@"TURN R OFF" forState:UIControlStateNormal];
    else [_turnRangingOnOffB setTitle:@"TURN R ON" forState:UIControlStateNormal];
}

- (void)turnRangingOnOff
{
    if (_rangingOn)
    {
        [_beaconManager stopRangingBeaconsInRegion:_region];
        _rangingOn = NO;
    }
    else
    {
        [_beaconManager startRangingBeaconsInRegion:_region];
        _rangingOn = YES;
    }
    [self setRangingOnOffButtonTitle];
}

- (void)createDeadReckoningOnOffButton
{
    _turnDeadReckoningOnOffB = [UIButton buttonWithType:UIButtonTypeSystem];
    _turnDeadReckoningOnOffB.frame = CGRectMake(_turnRangingOnOffB.frame.origin.x, _turnRangingOnOffB.frame.origin.y + _turnRangingOnOffB.frame.size.height, 100, 50);
    [_turnDeadReckoningOnOffB addTarget:self action:@selector(turnDeadReckoningOnOff) forControlEvents:UIControlEventTouchUpInside];
    [self setDeadReckoningOnOffButtonTitle];
    [self.view addSubview:_turnDeadReckoningOnOffB];
    
    _stepsCountL = [[UILabel alloc] initWithFrame:CGRectMake(_turnDeadReckoningOnOffB.frame.origin.x, _turnDeadReckoningOnOffB.frame.origin.y + _turnDeadReckoningOnOffB.frame.size.height, 100, 50)];
    [self.view addSubview:_stepsCountL];
}

- (void)setDeadReckoningOnOffButtonTitle
{
    if (_deadReckoningOn) [_turnDeadReckoningOnOffB setTitle:@"TURN DR OFF" forState:UIControlStateNormal];
    else [_turnDeadReckoningOnOffB setTitle:@"TURN DR ON" forState:UIControlStateNormal];
}

- (void)turnDeadReckoningOnOff
{
    if (_deadReckoningOn)
    {
        [self stopAdvancedMotionStuff];
        _deadReckoningOn = NO;
    }
    else
    {
        [self startAdvancedMotionStuff];
        _deadReckoningOn = YES;
    }
    [self setDeadReckoningOnOffButtonTitle];
}


#pragma mark - Dealloc

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.beaconManager stopEstimoteBeaconDiscovery];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
