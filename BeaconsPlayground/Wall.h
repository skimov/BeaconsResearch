//
//  Wall.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Wall : NSObject

@property (unsafe_unretained, nonatomic) CGPoint startPoint;
@property (unsafe_unretained, nonatomic) CGPoint endPoint;

@property (unsafe_unretained, nonatomic) CGPoint insidePoint;   //Distance 1m from the center inside the room. To show the direction. Can be changed later for something better (maybe).

- (instancetype)initWithStart:(CGPoint)start end:(CGPoint)end;

@end
