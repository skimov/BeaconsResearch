//
//  CoreMonitorVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 5/7/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "CoreMonitorVC.h"

#import "KalmanFilterManager.h"
#import "KalmanFilteredBeacon.h"

//#import "MiBeaconTrilateration.h"
#import "IndoorMappingModel.h"
#import "DisplayMappingVC.h"

#import "Wall.h"

#define kUniqueRegionIdentifier @"EstimoteSampleRegion"
#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

@interface CoreMonitorVC ()

@property (strong, nonatomic) CBPeripheral * bManager;

//Beacons
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (strong, nonatomic) CLBeaconRegion * region;

//Filtering + trilateration
@property (strong, nonatomic) NSMutableArray * walls;
@property (strong, nonatomic) NSMutableArray * initialBeacons;
@property (strong, nonatomic) NSMutableArray * discoveredBeacons;
@property (unsafe_unretained, nonatomic) double standardDeviationOfMeasurementNoise;    //R
@property (strong, nonatomic) KalmanFilterManager * kalmanFilterManager;

//Visualiztion
@property (strong, nonatomic) DisplayMappingVC * displayVC;

//Additional UI
@property (strong, nonatomic) UIButton * turnRangingOnOffB;
@property (unsafe_unretained, nonatomic) BOOL rangingOn;

@end

@implementation CoreMonitorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBeacons];
    [self startBeaconRanging];
}

- (void)initBeacons
{
    _walls = [[NSMutableArray alloc] init];
    _discoveredBeacons = [[NSMutableArray alloc] init];
    _initialBeacons = [[NSMutableArray alloc] init];
    _standardDeviationOfMeasurementNoise = 0.1;
    
    KalmanFilteredBeacon * beacon1 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 macAddr:@"d950779321d5" coordinates:CGPointMake(0, 6.75)];
    [_initialBeacons addObject:beacon1];
    Wall * wall1 = [[Wall alloc] initWithStart:CGPointMake(0, 0) end:CGPointMake(0, 13.5) insidePoint:CGPointMake(1, 1)];
    [_walls addObject:wall1];
    
    KalmanFilteredBeacon * beacon2 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 macAddr:@"ca09df1f6ec8" coordinates:CGPointMake(2.25, 13.5)];
    [_initialBeacons addObject:beacon2];
    Wall * wall2 = [[Wall alloc] initWithStart:CGPointMake(0, 13.5) end:CGPointMake(4.5, 13.5) insidePoint:CGPointMake(1, 1)];
    [_walls addObject:wall2];
    
    KalmanFilteredBeacon * beacon3 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 macAddr:@"d330ee513eff" coordinates:CGPointMake(4.5, 6.75)];
    [_initialBeacons addObject:beacon3];
    Wall * wall3 = [[Wall alloc] initWithStart:CGPointMake(4.5, 13.5) end:CGPointMake(4.5, 0) insidePoint:CGPointMake(1, 1)];
    [_walls addObject:wall3];
    
    KalmanFilteredBeacon * beacon4 = [[KalmanFilteredBeacon alloc] initWithPredictedVal:0 predictedErrorCovariance:1 standardDeviationOfMeasurementNoise:_standardDeviationOfMeasurementNoise measuredValue:0 macAddr:@"c77cd105e38e" coordinates:CGPointMake(2.25, 0)];
    [_initialBeacons addObject:beacon4];
    Wall * wall4 = [[Wall alloc] initWithStart:CGPointMake(4.5, 0) end:CGPointMake(0, 0) insidePoint:CGPointMake(1, 1)];
    [_walls addObject:wall4];
}

#pragma mark - CLLocationManager Helpers

- (void)startBeaconRanging
{
    // initialize new location manager
    if (!self.locationManager)
    {
        self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // begin region ranging
    [self.locationManager startRangingBeaconsInRegion:self.region];
    NSLog(@"It's like we started ranging a region here.");
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed");
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"Did range beacons region");
    
    for (CLBeacon * beacon in beacons)
    {
        NSLog(@"%@ - proximityUUID: %@",[self.class description],beacon.proximityUUID.UUIDString);
        NSLog(@"%@ - RSSI: %d",[self.class description],(int)beacon.rssi);
        NSLog(@"Distance: %f",beacon.accuracy);
        NSLog(@"Major: %d  minor: %d",beacon.major.intValue,beacon.minor.intValue);
    
    
//        KalmanFilteredBeacon * discoveredBeacon = nil;
//        for (KalmanFilteredBeacon * kfb in _initialBeacons)
//        {
//            if ([kfb.macAddr isEqualToString:beacon.macAddress])
//            {
//                discoveredBeacon = kfb;
//                kfb.major = beacon.major;
//                kfb.minor = beacon.minor;
//                [_discoveredBeacons addObject:kfb];
//                break;
//            }
//        }
//        [_initialBeacons removeObject:discoveredBeacon];
//
//        if (_initialBeacons.count == 0)
//        {
//            _initialBeacons = nil;
//            
//            [self initDisplayVC];
//            
//            [self initFilterManager];
//            
//            [self.beaconManager stopEstimoteBeaconDiscovery];
//            [self.beaconManager startRangingBeaconsInRegion:self.region];
//            _rangingOn = YES;
//            [self createRangingOnOffButton];
//        }
        
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed to range beacons region");
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // current location usage is required to use this demo app
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [[[UIAlertView alloc] initWithTitle:@"Current Location Required"
                                    message:@"Please re-enable Core Location to run this Demo.  The app will now exit."
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
