//
//  DisplayMappingVC.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "DisplayMappingVC.h"
#import "RangedBeacon.h"
#import "MiBeaconTrilateration.h"

#import "Wall.h"
#import <QuartzCore/QuartzCore.h>

@interface DisplayMappingVC ()

@end

@implementation DisplayMappingVC

#pragma mark - Init

- (instancetype)initWithModel:(IndoorMappingModel*)model
{
    self = [super init];
    
    _mappedModel = model;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self precalculateVisualizationParamsForBeacons:_mappedModel.beacons];
//    [self displayWalls:_mappedModel.walls];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self precalculateVisualizationParamsForBeacons:_mappedModel.beacons];
//    [self displayWalls:_mappedModel.walls];
}


- (void)precalculateVisualizationParamsForBeacons:(NSArray*)beacons
{
    NSLog(@"visualizeBeacons: %d",(int)beacons.count);
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    
    for (MappedBeacon * beacon in beacons)
    {
        CGPoint coordinates = beacon.coordinates;
        if (coordinates.x > maxX) maxX = coordinates.x;
        if (coordinates.y > maxY) maxY = coordinates.y;
    }
    NSLog(@"max x: %f   max y: %f",maxX,maxY);
    
    CGFloat areaProportion = maxY/maxX;
    NSLog(@"Proportion| area: %f",areaProportion);
    
    
    CGFloat maxWidth = self.view.frame.size.width - 40;
    CGFloat maxHeight = self.view.frame.size.height - 40;
    NSLog(@"Screen display size: %f %f",maxWidth,maxHeight);
    CGFloat maxScreenX = 0;
    CGFloat maxScreenY = 0;
    if (areaProportion > 1)         //Bigger Y
    {
        maxScreenY = maxHeight;
        maxScreenX = maxHeight / areaProportion;
    }
    else if (areaProportion < 1)    //Bigger X
    {
        maxScreenX = maxWidth;
        maxScreenY = maxWidth * areaProportion;
    }
    NSLog(@"Screen| max x: %.2f   max y: %.2f",maxScreenX,maxScreenY);
    
    _displayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,maxScreenX,maxScreenY)];
    _displayView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_displayView];
    _displayView.center = self.view.center;
//    _displayView.center = CGPointMake(self.view.center.x + (self.view.frame.size.width - _displayView.frame.size.width)/2, self.view.center.y);
    
    
//    _infoTV = [[UITextView alloc] initWithFrame:CGRectMake(10,10,_displayView.frame.origin.x-10-30,self.view.frame.size.height-10)];
//    _infoTV.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:_infoTV];
    
    _screenToAreaProportion = maxScreenX/maxX;
    NSLog(@"Screen to area proportion: %.2f",_screenToAreaProportion);
    
    for (MappedBeacon * beacon in beacons)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
        imageView.image = [UIImage imageNamed:@"beacon.png"];
        imageView.center = CGPointMake(beacon.coordinates.x*_screenToAreaProportion, beacon.coordinates.y*_screenToAreaProportion);
        [_displayView addSubview:imageView];
    }
    
    _locationIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    _locationIV.center = _displayView.center;
//    _locationIV.frame = CGRectMake(_displayView.frame.size.width, _displayView.frame.size.height, 50, 50);
    _locationIV.center = CGPointMake(2.25*_screenToAreaProportion, 6.25*_screenToAreaProportion);   //Hardcode to be initially in the center
    NSLog(@"Initial location IV center: %.2f %.2f",_locationIV.center.x,_locationIV.center.y);
//    _locationIV.image = [UIImage imageNamed:@"aim.png"];
    _locationIV.image = [UIImage imageNamed:@"arrow.png"];
    [_displayView addSubview:_locationIV];
    
    //To tap and simulate location
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapDisplayView:)];
    [_displayView addGestureRecognizer:tapGestureRecognizer];
}

- (void)displayWalls:(NSArray*)walls
{
    for (Wall * wall in walls)
    {
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(wall.startPoint.x*_screenToAreaProportion, wall.startPoint.y*_screenToAreaProportion)];
        [path addLineToPoint:CGPointMake(wall.endPoint.x*_screenToAreaProportion, wall.endPoint.y*_screenToAreaProportion)];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
        shapeLayer.lineWidth = 3.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [_displayView.layer addSublayer:shapeLayer];
    }
}

- (void)doTapDisplayView:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:recognizer.view];
    NSLog(@"TAP POINT - x: %f   y: %f",point.x,point.y);
    CGPoint absolutePoint = CGPointMake(point.x/_screenToAreaProportion, point.y/_screenToAreaProportion);
    NSLog(@"TAP ABSOLUTE POINT - x: %f   y: %f",absolutePoint.x,absolutePoint.y);

    if (_didTapMap)
    {
        _didTapMap(absolutePoint);
    }
//    [_kalmanFilterManager newIterationWithSimulatedPoint:absolutePoint];
//    [self visualizeIteration];
}



#pragma mark - Process

- (void)visualizeIterationForBeacons:(NSArray*)beacons
{
    _infoTV.text = @"";
    for (RangedBeacon * beacon in beacons)
    {
        if (beacon.selectedForTrilateration) _infoTV.text = [_infoTV.text stringByAppendingString:@">"];
            
        _infoTV.text = [_infoTV.text stringByAppendingString:[NSString stringWithFormat:@"x:%f-y:%f -> %f (%f)\n",beacon.coordinates.x,beacon.coordinates.y,beacon.distance,beacon.unfilteredDistance]];
    }
    
    //Perform trilateration and show user location
    CGPoint location = [MiBeaconTrilateration trilaterateLocationFromBeacons:beacons];
    CGPoint screenLocation = CGPointMake(location.x*_screenToAreaProportion, location.y*_screenToAreaProportion);
    _locationIV.center = screenLocation;
    NSLog(@"LOCATION: %f %f",location.x,location.y);
    NSLog(@"SCREEN LOCATION: %f %f",screenLocation.x,screenLocation.y);
}



#pragma mark - Dead Reckoning

- (CGPoint)oldLocationInMeters
{
    return CGPointMake(_locationIV.center.x/_screenToAreaProportion, _locationIV.center.y/_screenToAreaProportion);
}

- (void)visualizeIterationForCoordinate:(CGPoint)coordinate
{
    NSLog(@"visualizeIterationForCoordinate");
    CGPoint screenLocation = CGPointMake(coordinate.x*_screenToAreaProportion, coordinate.y*_screenToAreaProportion);
    NSLog(@"LOCATION: %f %f",coordinate.x,coordinate.y);
    NSLog(@"SCREEN LOCATION: %f %f",screenLocation.x,screenLocation.y);
    _locationIV.center = screenLocation;
}

- (void)setPositionAngle:(CGFloat)angle
{
//    NSLog(@"%@ - setPositionAngle: %f",[self.class description],angle);
//    _locationIV.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
//    _locationIV.transform = CGAffineTransformIdentity;
    _locationIV.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);  //This one should work
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
