//
//  Beacon.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MappedBeacon : NSObject

@property (strong, nonatomic) NSString * macAddr;
@property (strong, nonatomic) NSNumber * major;
@property (strong, nonatomic) NSNumber * minor;
@property (unsafe_unretained, nonatomic) CGPoint coordinates;

@end
