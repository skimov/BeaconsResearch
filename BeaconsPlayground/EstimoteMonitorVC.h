//
//  ViewController.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 3/25/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "ESTBeaconManager.h"
#import "ESTBeacon.h"

@interface EstimoteMonitorVC : UIViewController <CLLocationManagerDelegate, ESTBeaconManagerDelegate>


@end

