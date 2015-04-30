//
//  IndoorMappingManager.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IndoorMappingModel : NSObject

@property (strong, nonatomic) NSArray * beacons;
@property (strong, nonatomic) NSArray * walls;

- (id)initWithBeacons:(NSArray*)beacons walls:(NSArray*)walls;

- (CGPoint)correctLocation:(CGPoint)location;

@end
