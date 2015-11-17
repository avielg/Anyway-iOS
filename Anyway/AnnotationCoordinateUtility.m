//
//  AnnotationCoordinateUtility.m
//  Anyway
//
//  Created by Aviel Gross on 2/23/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

#import "AnnotationCoordinateUtility.h"

@implementation AnnotationCoordinateUtility

+ (NSArray *)groupForCoodinate:(CLLocationCoordinate2D)coord fromAnnotations:(NSArray *)annotations {
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    NSValue *value = [self valueFromCoordinate:coord];
    return coordinateValuesToAnnotations[value];
}

+ (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations {
    
    NSDictionary *coordinateValuesToAnnotations = [self groupAnnotationsByLocationValue:annotations];
    
    for (NSValue *coordinateValue in coordinateValuesToAnnotations.allKeys) {
        NSMutableArray *outletsAtLocation = coordinateValuesToAnnotations[coordinateValue];
        if (outletsAtLocation.count > 1) {
            CLLocationCoordinate2D coordinate;
            [coordinateValue getValue:&coordinate];
            [self repositionAnnotations:outletsAtLocation toAvoidClashAtCoordination:coordinate circleDistanceDelta:13];
        }
    }
}

+ (NSValue *)valueFromCoordinate:(CLLocationCoordinate2D)coord {
    return [NSValue valueWithBytes:&coord objCType:@encode(CLLocationCoordinate2D)];
}

+ (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (id<MKAnnotation> pin in annotations) {
        
        //Change coord to NSObject key
        CLLocationCoordinate2D coordinate = pin.coordinate;
        NSValue *coordinateValue = [self valueFromCoordinate:coordinate];
        
        //Get all the values of this coord object key
        NSMutableArray *annotationsAtLocation = result[coordinateValue];
        
        //If none - create an array with this annotations inside
        if (!annotationsAtLocation) {
            annotationsAtLocation = [NSMutableArray array];
            result[coordinateValue] = annotationsAtLocation;
        }
        
        //If any - add this annotation to the array
        [annotationsAtLocation addObject:pin];
    }
    return result;
}

+ (void)repositionAnnotations:(NSArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate circleDistanceDelta:(double)delta {
    
    double distance = delta * annotations.count / 2.0;
    double radiansBetweenAnnotations = (M_PI * 2) / annotations.count;
    
    for (int i = 0; i < annotations.count; i++) {
        
        double heading = radiansBetweenAnnotations * i;
        CLLocationCoordinate2D newCoordinate = [self calculateCoordinateFrom:coordinate onBearing:heading atDistance:distance];
        
        id <MKAnnotation> annotation = annotations[i];
        
        [annotation setCoordinate:newCoordinate];
        //annotation.coordinate = newCoordinate;
    }
}

+ (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate  onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    double coordinateLatitudeInRadians = coordinate.latitude * M_PI / 180;
    double coordinateLongitudeInRadians = coordinate.longitude * M_PI / 180;
    
    double distanceComparedToEarth = distanceInMetres / 6378100;
    
    double resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
    double resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
    
    CLLocationCoordinate2D result;
    result.latitude = resultLatitudeInRadians * 180 / M_PI;
    result.longitude = resultLongitudeInRadians * 180 / M_PI;
    return result;
}

@end
