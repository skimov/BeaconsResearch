//
//  KalmanPlaygroundVC.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/2/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeaconManager.h"
#import "Pedometer.h"

@interface KalmanPlaygroundVC : UIViewController <ESTBeaconManagerDelegate, PedoMeterDelegate>

@end
