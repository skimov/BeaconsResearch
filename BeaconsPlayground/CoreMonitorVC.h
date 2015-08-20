//
//  CoreMonitorVC.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 5/7/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//Apparently even with core bluetooth we can't get a mac address for the beacons. Estimote SDK can do it through CB, but it takes some more trouble, so we're using Estimote SDK for beacons mac addresses now.
//But
@interface CoreMonitorVC : UIViewController <CLLocationManagerDelegate, CBCentralManagerDelegate>

@end
