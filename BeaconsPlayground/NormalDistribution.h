//
//  NormalDistribution.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/16/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NormalDistribution : NSObject

//+ (CGFloat)doIt;
//+ (CGPoint)doItDouble;
+ (CGFloat)valueFromMean:(CGFloat)mean covariance:(CGFloat)covariance;
+ (CGPoint)pointFromMean:(CGFloat)mean covariance:(CGFloat)covariance;
+ (CGPoint)pointFromMeanPoint:(CGPoint)mean covariancePoint:(CGPoint)covariance;

@end
