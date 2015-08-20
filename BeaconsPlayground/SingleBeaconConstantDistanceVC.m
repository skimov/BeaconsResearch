//
//  SingleBeaconConstantDistanceVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/3/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "SingleBeaconConstantDistanceVC.h"
#import "KalmanBeaconFilterManager.h"
#import "KalmanFilteredBeacon.h"

@interface SingleBeaconConstantDistanceVC ()

//Beacons
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;

@property (unsafe_unretained, nonatomic) double standardDeviationOfMeasurementNoise;    //R
@property (strong, nonatomic) KalmanBeaconFilterManager * kalmanFilterManager;

@property (strong, nonatomic) KalmanFilteredBeacon * singleBeacon;

@end

@implementation SingleBeaconConstantDistanceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _standardDeviationOfMeasurementNoise = 0.5;

    _singleBeacon = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:0.5 measuredValue:0 major:8661 minor:30611 coordinates:CGPointMake(0, 6.75)];
//    _singleBeacon = [[RangedBeacon alloc] initWithMajor:8661 minor:30611 coordinates:CGPointMake(0, 6.75)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //TODO: init a single beacon
    //
    
    [self createEstimoteBeaconManagerWithRegion];       //Start with location manager first discover then ranging beacons
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
    NSLog(@"%@ - didRangeBeacons: %lu\n-------------------",[self.class description],(unsigned long)beacons.count);
    
    ESTBeacon * rangedSingleEstBeacon = nil;
    for (ESTBeacon * beacon in beacons)
    {
        //        NSLog(@"%@ - proximityUUID: %@",[self.class description],beacon.proximityUUID.UUIDString);
        NSLog(@"%@ - RSSI: %ld",[self.class description],beacon.rssi);
        NSLog(@"Distance: %f",beacon.distance.doubleValue);
        NSLog(@"Major: %d  minor: %d",beacon.major.intValue,beacon.minor.intValue);
        
        if ( (_singleBeacon.major.integerValue == beacon.major.integerValue) && (_singleBeacon.minor.integerValue == beacon.minor.integerValue) )
        {
            rangedSingleEstBeacon = beacon;
            break;
        }
    }
    
    if (rangedSingleEstBeacon)
    {
        if (!_kalmanFilterManager)      //Init filter manager when discovered our beacon the 1st time.
        {
            _kalmanFilterManager = [[KalmanBeaconFilterManager alloc] initWithBeacons:@[rangedSingleEstBeacon]];
        }
        [_kalmanFilterManager newIterationWithBeacons:@[rangedSingleEstBeacon]];    //Perform iteration with Kalman filter
        
        KalmanFilteredBeacon * beaconAfterIteration = _kalmanFilterManager.currentIteration[0];
        NSLog(@"%@",[NSString stringWithFormat:@"x:%f-y:%f -> %f (%f)\n",beaconAfterIteration.coordinates.x,beaconAfterIteration.coordinates.y,beaconAfterIteration.distance,beaconAfterIteration.unfilteredDistance]);
    }
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
