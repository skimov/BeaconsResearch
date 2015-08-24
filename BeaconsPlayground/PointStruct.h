//
//  PointStruct.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/24/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PointStruct : NSObject

@property (unsafe_unretained, nonatomic) CGFloat xCoord;
@property (unsafe_unretained, nonatomic) CGFloat yCoord;

- (instancetype)initWithPoint:(CGPoint)point;

@end
