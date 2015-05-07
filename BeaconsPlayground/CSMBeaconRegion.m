//
//  CSMBeaconRegion.m
//  iBeacons_Demo
//
//  Created by Christopher Mann on 9/16/13.
//  Copyright (c) 2013 Christopher Mann. All rights reserved.
//

#import "CSMBeaconRegion.h"
//#import "CSMAppDelegate.h"
#define kUniqueRegionIdentifier @"EstimoteSampleRegion" //TODO: later
#define ESTIMOTE_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]

static CSMBeaconRegion *_sharedInstance = nil;

@implementation CSMBeaconRegion

+ (instancetype)targetRegion {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CSMBeaconRegion alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    
    // initialize a new CLBeaconRegion with application-specific UUID and human-readable identifier
    self = [super initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:kUniqueRegionIdentifier];
    
    if (self)
    {
        self.notifyEntryStateOnDisplay = YES;     // only notify user if app is active
        self.notifyOnEntry = YES;                 // don't notify user on region entrance
        self.notifyOnExit = YES;                 // notify user on region exit
    }
    return self;
}

@end
