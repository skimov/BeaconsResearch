//
//  RangedBeacon.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "RangedBeacon.h"

@implementation RangedBeacon

- (id)initWithMajor:(int)major minor:(int)minor coordinates:(CGPoint)coordinates
{
    self = [super init];
    
    self.major = [NSNumber numberWithInt:major];
    self.minor = [NSNumber numberWithInt:minor];
    self.coordinates = coordinates;
    
    return self;
}

- (instancetype)initWithEstimoteBeacon:(ESTBeacon*)estimoteBeacon
{
    self = [super init];
    
    self.major = estimoteBeacon.major;
    self.minor = estimoteBeacon.minor;
    self.distance = [estimoteBeacon.distance doubleValue];
    
    return self;
}

@end
