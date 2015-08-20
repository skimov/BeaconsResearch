//
//  ViewController.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 3/25/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "EstimoteMonitorVC.h"
//#import "ESTUtilityManager.h"

#import "KalmanFilterManager.h"
#import "KalmanFilteredBeacon.h"

//#import "MiBeaconTrilateration.h"
#import "IndoorMappingModel.h"
#import "DisplayMappingVC.h"

#import "Wall.h"

#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

@interface EstimoteMonitorVC ()

//Beacons
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;

//Filtering + trilateration
@property (strong, nonatomic) NSMutableArray * walls;
@property (strong, nonatomic) NSMutableArray * initialBeacons;
@property (strong, nonatomic) NSMutableArray * discoveredBeacons;
@property (unsafe_unretained, nonatomic) double standardDeviationOfMeasurementNoise;    //R
@property (strong, nonatomic) KalmanFilterManager * kalmanFilterManager;

//Visualization
@property (strong, nonatomic) DisplayMappingVC * displayVC;

//Additional UI
@property (strong, nonatomic) UIButton * turnRangingOnOffB;
@property (unsafe_unretained, nonatomic) BOOL rangingOn;

@end

@implementation EstimoteMonitorVC

#pragma mark - Init

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
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    [self startRangingBeacons];
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

//Action starts here

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initBeacons];                                 //Map beacons
    [self createEstimoteBeaconManagerWithRegion];       //Start with location manager first discover then ranging beacons
}
















#pragma mark - Authorize & start beacon ranging

- (void)beaconManager:(ESTBeaconManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus: %d",status);
//    if (self.scanType == ESTScanTypeBeacon)
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
//            [self.beaconManager startRangingBeaconsInRegion:self.region];
            [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.region];
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
//        [self.beaconManager startRangingBeaconsInRegion:self.region];
        [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:self.region];
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

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSLog(@"%@ - didDiscoverBeacons: %lu",[self.class description],(unsigned long)beacons.count);
    for (ESTBeacon * beacon in beacons)
    {
        NSLog(@"MAC addr: %@",beacon.macAddress);   //here
        NSLog(@"%@ - RSSI: %ld",[self.class description],(long)beacon.rssi);
        NSLog(@"Major: %d  minor: %d",beacon.major.intValue,beacon.minor.intValue);
        NSLog(@"Power: %f   measured power: %f",beacon.power.doubleValue,beacon.measuredPower.doubleValue);
        
        KalmanFilteredBeacon * discoveredBeacon = nil;
        for (KalmanFilteredBeacon * kfb in _initialBeacons)
        {
            if ([kfb.macAddr isEqualToString:beacon.macAddress])
            {
                discoveredBeacon = kfb;
                kfb.major = beacon.major;
                kfb.minor = beacon.minor;
                [_discoveredBeacons addObject:kfb];
                break;
            }
        }
        [_initialBeacons removeObject:discoveredBeacon];
    }
    
    if (_initialBeacons.count == 0)
    {
        _initialBeacons = nil;
        
        [self initDisplayVC];
        
        [self initFilterManager];
        
        [self.beaconManager stopEstimoteBeaconDiscovery];
        [self.beaconManager startRangingBeaconsInRegion:self.region];
        _rangingOn = YES;
        [self createRangingOnOffButton];
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    NSLog(@"%@ - didRangeBeacons: %lu",[self.class description],(unsigned long)beacons.count);
    
    for (ESTBeacon * beacon in beacons)
    {
//        NSLog(@"%@ - proximityUUID: %@",[self.class description],beacon.proximityUUID.UUIDString);
//        NSLog(@"%@ - RSSI: %ld",[self.class description],beacon.rssi);
        NSLog(@"Distance: %f",beacon.distance.doubleValue);
//        NSLog(@"Major: %d  minor: %d",beacon.major.intValue,beacon.minor.intValue);
    }
    
    [self performIterationWithBeacons:beacons];
}

- (void)performIterationWithBeacons:(NSArray*)beacons
{
    [_kalmanFilterManager newIterationWithBeacons:beacons];

//    [_map correctLocation:];
    [_displayVC visualizeIterationForBeacons:_kalmanFilterManager.currentIteration];
}




#pragma mark - Visualization

- (void)initDisplayVC
{
    IndoorMappingModel * map = [[IndoorMappingModel alloc] initWithBeacons:_discoveredBeacons walls:_walls];
    _discoveredBeacons = nil;
    _displayVC = [[DisplayMappingVC alloc] initWithModel:map];
    _displayVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width - 150, self.view.frame.size.height);
    
    __weak EstimoteMonitorVC *weakSelf = self;
    _displayVC.didTapMap = ^(CGPoint coordinates)
    {
        [weakSelf.kalmanFilterManager newIterationWithSimulatedPoint:coordinates];
        [weakSelf.displayVC visualizeIterationForBeacons:weakSelf.kalmanFilterManager.currentIteration];
    };
    
    [self addChildViewController:_displayVC];
    [self.view addSubview:_displayVC.view];
    [_displayVC didMoveToParentViewController:self];
}

- (void)initFilterManager
{
    _kalmanFilterManager = [[KalmanFilterManager alloc] initWithBeacons:_displayVC.mappedModel.beacons];
}






#pragma mark - Ranging on/off

- (void)createRangingOnOffButton
{
    _turnRangingOnOffB = [UIButton buttonWithType:UIButtonTypeSystem];
    _turnRangingOnOffB.frame = CGRectMake(_displayVC.view.frame.origin.x + _displayVC.view.frame.size.width + 20, 100, 100, 50);
    [_turnRangingOnOffB addTarget:self action:@selector(turnRangingOnOff) forControlEvents:UIControlEventTouchUpInside];
    [self setRangingOnOffButtonTitle];
    [self.view addSubview:_turnRangingOnOffB];
}

- (void)setRangingOnOffButtonTitle
{
    if (_rangingOn) [_turnRangingOnOffB setTitle:@"TURN OFF" forState:UIControlStateNormal];
    else [_turnRangingOnOffB setTitle:@"TURN ON" forState:UIControlStateNormal];
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


//- (void)precalculateVisualizationParamsForBeacons:(NSArray*)beacons
//{
//    NSLog(@"visualizeBeacons: %d",(int)beacons.count);
//    CGFloat maxX = 0;
//    CGFloat maxY = 0;
//
//    for (KalmanFilteredBeacon * beacon in beacons)
//    {
//        CGPoint coordinates = beacon.coordinates;
//        if (coordinates.x > maxX) maxX = coordinates.x;
//        if (coordinates.y > maxY) maxY = coordinates.y;
//    }
//    NSLog(@"max x: %f   max y: %f",maxX,maxY);
//
//    CGFloat areaProportion = maxY/maxX;
//    NSLog(@"Proportion| area: %f",areaProportion);
//
//
//    CGFloat maxWidth = self.view.frame.size.width;
//    CGFloat maxHeight = self.view.frame.size.height - 40;
//    NSLog(@"Screen display size: %f %f",maxWidth,maxHeight);
//    CGFloat maxScreenX = 0;
//    CGFloat maxScreenY = 0;
//    if (areaProportion > 1)         //Bigger Y
//    {
//        maxScreenY = maxHeight;
//        maxScreenX = maxHeight / areaProportion;
//    }
//    else if (areaProportion < 1)    //Bigger X
//    {
//        maxScreenX = maxWidth;
//        maxScreenY = maxWidth * areaProportion;
//    }
//    NSLog(@"Screen| max x: %f   max y: %f",maxScreenX,maxScreenY);
//
//    _displayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,maxScreenX,maxScreenY)];
//    _displayView.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:_displayView];
//    _displayView.center = self.view.center;
//
//
//    _infoTV = [[UITextView alloc] initWithFrame:CGRectMake(10,10,_displayView.frame.origin.x-10-30,self.view.frame.size.height-10)];
//    _infoTV.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:_infoTV];
//
//    _screenToAreaProportion = maxScreenX/maxX;
//    NSLog(@"Screen to area proportion: %f",_screenToAreaProportion);
//
//    for (KalmanFilteredBeacon * beacon in beacons)
//    {
//        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
//        imageView.image = [UIImage imageNamed:@"beacon.png"];
//        imageView.center = CGPointMake(beacon.coordinates.x*_screenToAreaProportion, beacon.coordinates.y*_screenToAreaProportion);
//        [_displayView addSubview:imageView];
//    }
//
//    _locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    _locationIV.center = _displayView.center;
//    _locationIV.image = [UIImage imageNamed:@"aim.png"];
//    [_displayView addSubview:_locationIV];
//
//    //To tap and simulate location
//    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapDisplayView:)];
//    [_displayView addGestureRecognizer:tapGestureRecognizer];
//}


//- (void)visualizeIteration
//{
//    _infoTV.text = @"";
//    for (KalmanFilteredBeacon * beacon in _kalmanFilterManager.currentIteration)
//    {
//        _infoTV.text = [_infoTV.text stringByAppendingString:[NSString stringWithFormat:@"x:%f-y:%f -> %f\n",beacon.coordinates.x,beacon.coordinates.y,beacon.correctedVal]];
//    }
//
//    //Perform trilateration and show user location
//    CGPoint location = [MiBeaconTrilateration trilaterateLocationFromBeacons:_kalmanFilterManager.currentIteration];
//    CGPoint screenLocation = CGPointMake(location.x*_screenToAreaProportion, location.y*_screenToAreaProportion);
//    _locationIV.center = screenLocation;
//    NSLog(@"LOCATION: %f %f",location.x,location.y);
//    NSLog(@"SCREEN LOCATION: %f %f",screenLocation.x,screenLocation.y);
//}


//- (void)doTapDisplayView:(UITapGestureRecognizer *)recognizer
//{
//    CGPoint point = [recognizer locationInView:recognizer.view];
//    NSLog(@"TAP POINT - x: %f   y: %f",point.x,point.y);
//    CGPoint absolutePoint = CGPointMake(point.x/_screenToAreaProportion, point.y/_screenToAreaProportion);
//    NSLog(@"TAP ABSOLUTE POINT - x: %f   y: %f",absolutePoint.x,absolutePoint.y);
//
//    [_kalmanFilterManager newIterationWithSimulatedPoint:absolutePoint];
//
//    [self visualizeIteration];
//}


