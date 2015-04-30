/*
 Copyright (c) 2014 Mathijs Vreeman
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MiBeaconTrilateration.h"
//#import "KalmanFilteredBeacon.h"
#import "RangedBeacon.h"

@implementation MiBeaconTrilateration

+ (RangedBeacon*)beaconWithBiggestDistanceFromArray:(NSArray*)beacons
{
    RangedBeacon * maxDistanceBeacon = nil;
    for (RangedBeacon * beacon in beacons)
    {
        if (!maxDistanceBeacon) maxDistanceBeacon = beacon;
        else
        {
            if (beacon.distance > maxDistanceBeacon.distance) maxDistanceBeacon = beacon;
        }
    }
    return maxDistanceBeacon;
}

+ (CGPoint)trilaterateLocationFromBeacons:(NSArray*)beacons
{
    NSString *error = @"";
    NSArray *coordinates;
    
    NSMutableArray * filteredBeacons = [[NSMutableArray alloc] init];
    for (RangedBeacon * beacon in beacons)
    {
        if (beacon.distance > 0) [filteredBeacons addObject:beacon];
    }
    
    if (filteredBeacons.count < 3) return CGPointMake(0,0);     //We need 3 beacons
    
    NSMutableArray * selectedBeacons = [[NSMutableArray alloc] init];   //Only 3. If there are more - we take the closest 3.
    for (RangedBeacon * beacon in filteredBeacons)
    {
        if (selectedBeacons.count == 3)
        {
            RangedBeacon * maxDistanceSelectedBeacon = [self beaconWithBiggestDistanceFromArray:selectedBeacons];
            if (beacon.distance < maxDistanceSelectedBeacon.distance)
            {
                [selectedBeacons removeObject:maxDistanceSelectedBeacon];
                [selectedBeacons addObject:beacon];
            }
        }
        else
        {
            [selectedBeacons addObject:beacon];
        }
    }
    
    for (RangedBeacon * beacon in selectedBeacons)
    {
        beacon.selectedForTrilateration = YES;
    }
    
    RangedBeacon * beacon1 = selectedBeacons[0];
    RangedBeacon * beacon2 = selectedBeacons[1];
    RangedBeacon * beacon3 = selectedBeacons[2];
    NSArray * beaconLocation1 = @[[NSNumber numberWithDouble:beacon1.coordinates.x] ,[NSNumber numberWithDouble:beacon1.coordinates.y]];
    NSArray * beaconLocation2 = @[[NSNumber numberWithDouble:beacon2.coordinates.x],[NSNumber numberWithDouble:beacon2.coordinates.y]];
    NSArray * beaconLocation3 = @[[NSNumber numberWithDouble:beacon3.coordinates.x],[NSNumber numberWithDouble:beacon3.coordinates.y]];
    
    // ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
    NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
    double temp = 0;
    for (int i = 0; i < [beaconLocation1 count]; i++) {
        double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
        double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double t = t1 - t2;
        temp += (t*t);
    }
    for (int i = 0; i < [beaconLocation1 count]; i++) {
        double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
        double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double exx = (t1 - t2)/sqrt(temp);
        [ex addObject:[NSNumber numberWithDouble:exx]];
    }
    
    // i = dot(ex, P3 - P1)
    NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [beaconLocation3 count]; i++) {
        double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
        double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double t3 = t1 - t2;
        [p3p1 addObject:[NSNumber numberWithDouble:t3]];
    }
    
    double ival = 0;
    for (int i = 0; i < [ex count]; i++) {
        double t1 = [[ex objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        ival += (t1*t2);
    }
    
    // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
    NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
    double p3p1i = 0;
    for (int  i = 0; i < [beaconLocation3 count]; i++) {
        double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
        double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double t = t1 - t2 -t3;
        p3p1i += (t*t);
    }
    for (int i = 0; i < [beaconLocation3 count]; i++) {
        double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
        double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
        [ey addObject:[NSNumber numberWithDouble:eyy]];
    }
    
    // ez = numpy.cross(ex,ey)
    // if 2-dimensional vector then ez = 0
    NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
    double ezx;
    double ezy;
    double ezz;
    if ([beaconLocation1 count] !=3){
        ezx = 0;
        ezy = 0;
        ezz = 0;
        
    }else{
        ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
        ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
        ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);
    }
    
    [ez addObject:[NSNumber numberWithDouble:ezx]];
    [ez addObject:[NSNumber numberWithDouble:ezy]];
    [ez addObject:[NSNumber numberWithDouble:ezz]];
    
    // d = numpy.linalg.norm(P2 - P1)
//    double d = sqrt(temp);
    double d = sqrt(temp);
    
    // j = dot(ey, P3 - P1)
    double jval = 0;
    for (int i = 0; i < [ey count]; i++) {
        double t1 = [[ey objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        jval += (t1*t2);
    }
    
    // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
    double xval = (pow(beacon1.distance,2) - pow(beacon2.distance,2) + pow(d,2))/(2*d);
//    double xval = 1;
    
    // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
    double yval = ((pow(beacon1.distance,2) - pow(beacon3.distance,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
//    double yval = 1;
    
    // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
    // if 2-dimensional vector then z = 0
    double zval;
    if ([beaconLocation1 count] !=3){
        zval = 0;
    }else{
//        zval = sqrt(pow(beacon1.accuracy,2) - pow(xval,2) - pow(yval,2));
        zval = 1;
    }
    
    // coord = P1 + x*ex + y*ey + z*ez
    NSMutableArray *trilateratedCoordinates = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [beaconLocation1 count]; i++) {
        double t1 = [[beaconLocation1 objectAtIndex:i] doubleValue];
        double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
        double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
        double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
        double triptx = t1+t2+t3+t4;
        [trilateratedCoordinates addObject:[NSNumber numberWithDouble:triptx]];
        if (isnan(triptx))
        {
            error = @"at least one of the calculated coordinates is NaN";
        }
    }
    coordinates = [trilateratedCoordinates copy];
    // if you want to store the used beacons to pass them on, uncomment line below
    //NSArray *usedBeacons = [[NSArray alloc] initWithObjects:beacon1, beacon2, beacon3, nil];

    return CGPointMake([coordinates[0] doubleValue], [coordinates[1] doubleValue]);
}


//INITIAL VERSION
//- (void)trilaterateWithBeacons:(NSArray *)beacons done:(void (^)(NSString *error, NSArray *coordinates))doneBlock
//{
//    NSString *error = @"";
//    NSArray *coordinates;
//    
//    // remove the beacons with negative accuracy from the array
//    NSMutableArray *useBeacons = [[NSMutableArray alloc] init];
//    useBeacons = [beacons mutableCopy];
//    
//    NSMutableArray *beaconsToRemove;
//    if (!beaconsToRemove) { beaconsToRemove = [[NSMutableArray alloc] init]; }
//    
//    for (CLBeacon *beacon in useBeacons) {
//        if (beacon.accuracy < 0) {
//            [beaconsToRemove addObject:beacon];
//        }
//    }
//    for (CLBeacon *beaconToRemove in beaconsToRemove) {
//        [useBeacons removeObject:beaconToRemove];
//    }
//    
//    // proceed if at least 3 useful beacons are left
//    if ([useBeacons count] > 2) {
//        // beacon 1 and two are always the two closest beacons
//        CLBeacon *beacon1 = [useBeacons objectAtIndex:0];
//        CLBeacon *beacon2 = [useBeacons objectAtIndex:1];
//        
//        // if more than 3 beacons found and the closest three share the same minor (y) or major (x), check if the 4th is different and if yes, use it. Better for trilateration. Not very useful to trilaterate with three beacons in line
//        
//        CLBeacon *tempBeacon3 = [useBeacons objectAtIndex:2];
//        CLBeacon *beacon3;
//        
//        if  ([useBeacons count] == 3) // if there are just three, trilaterate three closest beacons.
//        {
//            beacon3 = tempBeacon3;
//        }
//        else if ([useBeacons count] > 3) // check if it might be better to use the 4th beacon instead of the 3rd
//        {
//            CLBeacon *tempBeacon4 = [useBeacons objectAtIndex:3];
//            
//            // check if MAJORS of closest three are equal
//            if ([[tempBeacon3 major] integerValue] == [[beacon2 major] integerValue] == [[beacon1 major] integerValue])
//            {   // check if fourth closest beacon has a different major. if yes, use it instead of the 3rd one
//                if ([[tempBeacon4 major] integerValue] != [[tempBeacon3 major] integerValue])
//                {
//                    beacon3 = tempBeacon4;
//                }
//                else // use the closest 3. Result wil not be very good though
//                {
//                    beacon3 = tempBeacon3;
//                }
//            }
//            
//            // else, check if MINORS of closest three are equal
//            else if ([[tempBeacon3 minor] integerValue] == [[beacon2 minor] integerValue] == [[beacon1 minor] integerValue])
//            { // check if fourth closest beacon has a different minor. if yes, use it instead of the 3rd one
//                if ([[tempBeacon4 minor] integerValue] != [[tempBeacon3 minor] integerValue])
//                {
//                    beacon3 = tempBeacon4;
//                }
//                else //use the closest 3. Result wil not be very good though
//                {
//                    beacon3 = tempBeacon3;
//                }
//            }
//            
//            // if not, just trilaterate three closest beacons
//            else
//            {
//                beacon3 = tempBeacon3;
//            }
//        }
//        
//        // PROCEED TRILATERATION
//        
//        // get coordinates for each beacon, minor is used to identify
//        
//        NSBundle *bundle = [NSBundle mainBundle];
//        NSString *plistPath = [bundle pathForResource:@"beaconCoordinates" ofType:@"plist"];
//        NSDictionary *beaconCoordinates = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
//        
//        NSArray *beaconLocation1 = [beaconCoordinates objectForKey:[NSString stringWithFormat:@"%d", [beacon1.minor intValue]]];
//        NSArray *beaconLocation2 = [beaconCoordinates objectForKey:[NSString stringWithFormat:@"%d", [beacon2.minor intValue]]];
//        NSArray *beaconLocation3 = [beaconCoordinates objectForKey:[NSString stringWithFormat:@"%d", [beacon3.minor intValue]]];
//        
//        if (beaconLocation1 && beaconLocation2 && beaconLocation3)
//        {
//            
//            // ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
//            NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
//            double temp = 0;
//            for (int i = 0; i < [beaconLocation1 count]; i++) {
//                double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
//                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double t = t1 - t2;
//                temp += (t*t);
//            }
//            for (int i = 0; i < [beaconLocation1 count]; i++) {
//                double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
//                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double exx = (t1 - t2)/sqrt(temp);
//                [ex addObject:[NSNumber numberWithDouble:exx]];
//            }
//            
//            // i = dot(ex, P3 - P1)
//            NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
//            for (int i = 0; i < [beaconLocation3 count]; i++) {
//                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
//                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double t3 = t1 - t2;
//                [p3p1 addObject:[NSNumber numberWithDouble:t3]];
//            }
//            
//            double ival = 0;
//            for (int i = 0; i < [ex count]; i++) {
//                double t1 = [[ex objectAtIndex:i] doubleValue];
//                double t2 = [[p3p1 objectAtIndex:i] doubleValue];
//                ival += (t1*t2);
//            }
//            
//            // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
//            NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
//            double p3p1i = 0;
//            for (int  i = 0; i < [beaconLocation3 count]; i++) {
//                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
//                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
//                double t = t1 - t2 -t3;
//                p3p1i += (t*t);
//            }
//            for (int i = 0; i < [beaconLocation3 count]; i++) {
//                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
//                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
//                double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
//                [ey addObject:[NSNumber numberWithDouble:eyy]];
//            }
//            
//            // ez = numpy.cross(ex,ey)
//            // if 2-dimensional vector then ez = 0
//            NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
//            double ezx;
//            double ezy;
//            double ezz;
//            if ([beaconLocation1 count] !=3){
//                ezx = 0;
//                ezy = 0;
//                ezz = 0;
//                
//            }else{
//                ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
//                ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
//                ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);
//            }
//            
//            [ez addObject:[NSNumber numberWithDouble:ezx]];
//            [ez addObject:[NSNumber numberWithDouble:ezy]];
//            [ez addObject:[NSNumber numberWithDouble:ezz]];
//            
//            // d = numpy.linalg.norm(P2 - P1)
//            double d = sqrt(temp);
//            
//            // j = dot(ey, P3 - P1)
//            double jval = 0;
//            for (int i = 0; i < [ey count]; i++) {
//                double t1 = [[ey objectAtIndex:i] doubleValue];
//                double t2 = [[p3p1 objectAtIndex:i] doubleValue];
//                jval += (t1*t2);
//            }
//            
//            // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
//            double xval = (pow(beacon1.accuracy,2) - pow(beacon2.accuracy,2) + pow(d,2))/(2*d);
//            
//            // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
//            double yval = ((pow(beacon1.accuracy,2) - pow(beacon3.accuracy,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
//            
//            // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
//            // if 2-dimensional vector then z = 0
//            double zval;
//            if ([beaconLocation1 count] !=3){
//                zval = 0;
//            }else{
//                zval = sqrt(pow(beacon1.accuracy,2) - pow(xval,2) - pow(yval,2));
//            }
//            
//            // coord = P1 + x*ex + y*ey + z*ez
//            NSMutableArray *trilateratedCoordinates = [[NSMutableArray alloc] initWithCapacity:0];
//            for (int i = 0; i < [beaconLocation1 count]; i++) {
//                double t1 = [[beaconLocation1 objectAtIndex:i] doubleValue];
//                double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
//                double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
//                double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
//                double triptx = t1+t2+t3+t4;
//                [trilateratedCoordinates addObject:[NSNumber numberWithDouble:triptx]];
//                if (isnan(triptx))
//                {
//                    error = @"at least one of the calculated coordinates is NaN";
//                }
//            }
//            coordinates = [trilateratedCoordinates copy];
//            // if you want to store the used beacons to pass them on, uncomment line below
//            //NSArray *usedBeacons = [[NSArray alloc] initWithObjects:beacon1, beacon2, beacon3, nil];
//        }
//        else
//        {
//            error = @"one ore more beacons not specified in Plist";
//        }
//    }
//    else
//    {
//        error = @"need at least three beacons for trilateration";
//    }
//    
//    // callback
//    if (doneBlock != nil) {
//        doneBlock(error, coordinates);
//    }
//}

@end
