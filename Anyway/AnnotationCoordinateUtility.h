//
//  AnnotationCoordinateUtility.h
//  Anyway
//
//  Created by Aviel Gross on 2/23/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface AnnotationCoordinateUtility : NSObject
/*
 Take [Annotation] and mutate everything that needed
 */
+ (void)mutateCoordinatesOfClashingAnnotations:(NSArray *)annotations;


/*
 @return [NSValue:Annotation] of all points in given coordinate grouped by coordinates
 */
+ (NSDictionary *)groupAnnotationsByLocationValue:(NSArray *)annotations;

/*
 @return [Annotation] of all points in given coordinate
 */
+ (NSArray *)groupForCoodinate:(CLLocationCoordinate2D)coord fromAnnotations:(NSArray *)annotations;

/*
 @param annotations [Annotation] at the same coordinate
 */
+ (void)repositionAnnotations:(NSArray *)annotations toAvoidClashAtCoordination:(CLLocationCoordinate2D)coordinate circleDistanceDelta:(double)delta;
@end
