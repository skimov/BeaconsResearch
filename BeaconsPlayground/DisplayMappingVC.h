//
//  DisplayMappingVC.h
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 4/22/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndoorMappingModel.h"

@interface DisplayMappingVC : UIViewController

@property (strong, nonatomic) UIView * displayView;
@property (strong, nonatomic) UITextView * infoTV;
@property (unsafe_unretained, nonatomic) CGFloat screenToAreaProportion;
@property (strong, nonatomic) UIImageView * locationIV;

@property (strong, nonatomic) void(^didTapMap)(CGPoint coordinates);

@property (strong, nonatomic) IndoorMappingModel * mappedModel;
- (instancetype)initWithModel:(IndoorMappingModel*)model;

- (void)precalculateVisualizationParamsForBeacons:(NSArray*)beacons;
- (void)displayWalls:(NSArray*)walls;
- (void)visualizeIterationForBeacons:(NSArray*)beacons;

//Testing for DR
- (CGPoint)oldLocationInMeters;
- (void)visualizeIterationForCoordinate:(CGPoint)coordinate;
- (void)setPositionAngle:(CGFloat)angle;

@end
