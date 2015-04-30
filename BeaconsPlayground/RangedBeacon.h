//
//  RangedBeacon.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "MappedBeacon.h"

@interface RangedBeacon : MappedBeacon

@property (unsafe_unretained, nonatomic) BOOL selectedForTrilateration;
@property (unsafe_unretained, nonatomic) CGFloat unfilteredDistance;    //4 observation
@property (unsafe_unretained, nonatomic) CGFloat distance;

@end
