//
//  MeasurementWriter.m
//  BeaconsPlayground
//
//  Created by Stanislav Kimov on 8/20/15.
//  Copyright (c) 2015 Stanislav Kimov. All rights reserved.
//

#import "MeasurementWriter.h"

@implementation MeasurementWriter

+ (MeasurementWriter*)sharedInstance
{
    static MeasurementWriter *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
        {
            sharedInstance = [[MeasurementWriter alloc] init];
        }
        
        return sharedInstance;
    }
}




- (NSString*)getDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString*)getPathForFileWithName:(NSString*)name
{
    NSString *documentsDirectory = [self getDocumentsDirectory];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,name];
    return filePath;
}



- (BOOL)measurementFileExistsWithName:(NSString*)name
{
    NSString * filePath = [self getPathForFileWithName:name];
    NSFileManager * filemgr = [NSFileManager defaultManager];
    return [filemgr fileExistsAtPath:filePath];
}

- (void)createMeasurementFileWithName:(NSString*)name
{
    NSLog(@"%@ - createMeasurementFileWithName: %@",[self.class description],name);
    NSString * filePath = [self getPathForFileWithName:name];
    NSLog(@"Measurement file path: %@",filePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    [filemgr createFileAtPath:filePath contents:nil attributes:nil];
}

- (void)removeMeasurementFileWithName:(NSString*)name
{
    NSString * filePath = [self getPathForFileWithName:name];
    NSFileManager * filemgr = [NSFileManager defaultManager];
    [filemgr removeItemAtPath:filePath error:nil];
}

- (unsigned long long)getSizeOfMeasuerementFileWithName:(NSString*)name
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSDictionary * attrs = [fileManager attributesOfItemAtPath:[self getPathForFileWithName:name] error: NULL];
    return [attrs fileSize];
}



- (void)append:(NSString*)toWrite toMeasurementFileWithName:(NSString*)name
{
    NSLog(@"%@ - appendToMeasurementFile: %@",[self.class description],toWrite);
    NSString * filePath = [self getPathForFileWithName:name];
    NSLog(@"File path: %@",filePath);
    NSFileHandle * myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (myHandle == nil)
    {
        NSLog(@"Failed to open file");
        return;
    }
    
    NSData * theData = [toWrite dataUsingEncoding:NSUTF8StringEncoding];
    unsigned long long fsize = [myHandle seekToEndOfFile];
    unsigned long endFileStringSize = sizeof([@"\n]" dataUsingEncoding:NSUTF8StringEncoding]);
    unsigned long offset = fsize-endFileStringSize;
    if (endFileStringSize > fsize) offset = 0;
//    [myHandle seekToFileOffset:offset];
    [myHandle seekToFileOffset:fsize];
    [myHandle writeData:theData];
    
    [myHandle closeFile];
}




- (void)writeIterationWithSingleBeaconMeasurement:(SingleBeaconMeasurementStruct*)measurementStruct toFileWithName:(NSString*)name
{
    NSDictionary * measurementDictionary = [SingleBeaconMeasurementStruct toDictionary:measurementStruct];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:measurementDictionary options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = @"";
    if (! jsonData)
    {
        NSLog(@"Json error: %@", error.localizedDescription);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString * measurementString = @"";
    if ([self getSizeOfMeasuerementFileWithName:name] > 0)
    {
        measurementString = @",";
    }
    measurementString = [measurementString stringByAppendingString:jsonString];
    
    [self append:measurementString toMeasurementFileWithName:name];
}

- (void)writeIterationWithBeaconMotionMeasurement:(BeaconMotionMeasurementStruct*)measurementStruct toFileWithName:(NSString*)name
{
    NSDictionary * measurementDictionary = [BeaconMotionMeasurementStruct toDictionary:measurementStruct];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:measurementDictionary options:(NSJSONWritingOptions)NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = @"";
    if (! jsonData)
    {
        NSLog(@"Json error: %@", error.localizedDescription);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString * measurementString = @"";
    if ([self getSizeOfMeasuerementFileWithName:name] > 0)
    {
        measurementString = @",\n";
    }
    measurementString = [measurementString stringByAppendingString:jsonString];
    
    [self append:measurementString toMeasurementFileWithName:name];
}

@end
