//
//  NormalDistribution.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/16/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "NormalDistribution.h"

@implementation NormalDistribution

//http://stackoverflow.com/a/15186722
//+ (CGFloat)doIt
//{
//    double u =(double)(random() %UINT32_MAX + 1)/UINT32_MAX; //for precision
//    double v =(double)(random() %UINT32_MAX + 1)/UINT32_MAX; //for precision
//    double x = sqrt(-2*log(u))*cos(2*M_PI*v);   //or sin(2*pi*v)
//    double y = x * sigmaValue + averageValue;
//    return y;
//}

//+ (CGFloat)doIt
//{
//    return [self doItDouble].x;
//}
//
////http://stackoverflow.com/a/12948538
////Using Box-Muller Transform to turn from 2d uniform distribution to 2d gaussian distribution
//+ (CGPoint)doItDouble
//{
//    double u1 = (double)arc4random() / UINT32_MAX; // uniform distribution
//    double u2 = (double)arc4random() / UINT32_MAX; // uniform distribution
//    NSLog(@"doItDouble uniform: %f %f",u1,u2);
//    double f1 = sqrt(-2 * log(u1));
//    double f2 = 2 * M_PI * u2;
//    double g1 = f1 * cos(f2); // gaussian distribution
//    double g2 = f1 * sin(f2); // gaussian distribution
//    NSLog(@"doItDouble gaussian: %f %f",g1,g2);
//    return CGPointMake(g1, g2);
//}

+ (CGFloat)valueFromMean:(CGFloat)mean covariance:(CGFloat)covariance
{
    return [self pointFromMeanPoint:CGPointMake(mean,mean) covariancePoint:CGPointMake(covariance,covariance)].x;
}

+ (CGPoint)pointFromMean:(CGFloat)mean covariance:(CGFloat)covariance
{
    return [self pointFromMeanPoint:CGPointMake(mean,mean) covariancePoint:CGPointMake(covariance,covariance)];
}

+ (CGPoint)pointFromMeanPoint:(CGPoint)mean covariancePoint:(CGPoint)covariance
{
//    NSLog(@"valueFromMean: %.2f-%.2f  covariance: %.2f-%.2f",mean.x,mean.y,covariance.x,covariance.y);
    //Get it from -1 to 1
    double u1 = (double)arc4random() / UINT32_MAX; // uniform distribution
    double u2 = (double)arc4random() / UINT32_MAX; // uniform distribution
//    NSLog(@"valueFromMean-covariance uniform: %.2f %.2f",u1,u2);
    double f1 = sqrt(-2 * log(u1));
    double f2 = 2 * M_PI * u2;
    double g1 = f1 * cos(f2); // gaussian distribution
    double g2 = f1 * sin(f2); // gaussian distribution
//    NSLog(@"valueFromMean-covariance gaussian: %.2f %.2f",g1,g2);
    
    g1 = g1 * covariance.x;
    g1 = g1 + mean.x;
    g2 = g2 * covariance.y;
    g2 = g2 + mean.y;
//    NSLog(@"valueFromMean-covariance gaussian with mean + deviation: %.2f %.2f",g1,g2);
    
    return CGPointMake(g1, g2);
}

//+ (CGPoint)valueFromMean:(CGFloat)mean covariance:(CGFloat)covariance
//{
//    NSLog(@"valueFromMean: %f  covariance: %f",mean,covariance);
//    //Get it from -1 to 1
//    double u1 = (double)arc4random() / UINT32_MAX; // uniform distribution
//    double u2 = (double)arc4random() / UINT32_MAX; // uniform distribution
//    u1 = 2*u1 - 1;
//    u2 = 2*u2 - 1;
//    NSLog(@"valueFromMean-covariance uniform: %f %f",u1,u2);
//    double f1 = sqrt(-2 * log(u1));
//    double f2 = 2 * M_PI * u2;
//    double g1 = f1 * cos(f2); // gaussian distribution
//    double g2 = f1 * sin(f2); // gaussian distribution
//    NSLog(@"valueFromMean-covariance gaussian: %f %f",g1,g2);
//    return CGPointMake(g1, g2);
//}

@end
