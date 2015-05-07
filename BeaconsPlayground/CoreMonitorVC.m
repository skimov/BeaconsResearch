//
//  CoreMonitorVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 5/7/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "CoreMonitorVC.h"
#import "CSMBeaconRegion.h"

#define kUniqueRegionIdentifier @"EstimoteSampleRegion" //TODO: later
#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

@interface CoreMonitorVC ()

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (strong, nonatomic) CLBeaconRegion * region;

@end

@implementation CoreMonitorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startBeaconRanging];
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
