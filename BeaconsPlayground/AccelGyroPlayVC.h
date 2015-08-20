//
//  AccelGyroPlayVC.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/6/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AccelGyroPlayVC : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentAccelYGL;
@property (weak, nonatomic) IBOutlet UILabel *currentAccelYL;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedYL;
@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledL;

@property (weak, nonatomic) IBOutlet UILabel *currentRotationZL;
@property (weak, nonatomic) IBOutlet UILabel *sumRotationZL;

@property (weak, nonatomic) IBOutlet UILabel *currentAccelerationXL;
@property (weak, nonatomic) IBOutlet UILabel *currentAccelerationZL;

@property (weak, nonatomic) IBOutlet UILabel *compassDegreesL;
@property (weak, nonatomic) IBOutlet UILabel *compassRadiansL;

@property (weak, nonatomic) IBOutlet UILabel *initialEulerL;
@property (weak, nonatomic) IBOutlet UILabel *currentEulerL;
@property (weak, nonatomic) IBOutlet UILabel *deltaEulerL;
@property (weak, nonatomic) IBOutlet UILabel *magnitudeL;

@end
