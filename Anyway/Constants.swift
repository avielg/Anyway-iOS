//
//  Constants.swift
//  Anyway
//
//  Created by Aviel Gross on 8/10/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation

let fallbackStartLocationCoordinate = CLLocationCoordinate2D(latitude: 32.158091269627874, longitude: 34.88087036877948)

enum Severity: Int {
    case Fatal = 1, Severe, Light, Various
}

enum AccidentType: Int {
    case CarToCar = -1
    case CarToObject = -2
    case CarToPedestrian = 1
}

var ACCIDENT_TYPE_CAR_TO_CAR = -1; // Synthetic type
var ACCIDENT_TYPE_CAR_TO_OBJECT = -2; // Synthetic type
var ACCIDENT_TYPE_CAR_TO_PEDESTRIAN = 1;
var ACCIDENT_TYPE_FRONT_TO_SIDE = 2;
var ACCIDENT_TYPE_FRONT_TO_REAR = 3;
var ACCIDENT_TYPE_SIDE_TO_SIDE = 4;
var ACCIDENT_TYPE_FRONT_TO_FRONT = 5;
var ACCIDENT_TYPE_WITH_STOPPED_CAR_NO_PARKING = 6;
var ACCIDENT_TYPE_WITH_STOPPED_CAR_PARKING = 7;
var ACCIDENT_TYPE_WITH_STILL_OBJECT = 8;
var ACCIDENT_TYPE_OFF_ROAD_OR_SIDEWALK = 9;
var ACCIDENT_TYPE_ROLLOVER = 10;
var ACCIDENT_TYPE_SKID = 11;
var ACCIDENT_TYPE_HIT_PASSSENGER_IN_CAR = 12;
var ACCIDENT_TYPE_FALLING_OFF_MOVING_VEHICLE = 13;
var ACCIDENT_TYPE_FIRE = 14;
var ACCIDENT_TYPE_OTHER = 15;
var ACCIDENT_TYPE_BACK_TO_FRONT = 17;
var ACCIDENT_TYPE_BACK_TO_SIDE = 18;
var ACCIDENT_TYPE_WITH_ANIMAL = 19;
var ACCIDENT_TYPE_WITH_VEHICLE_LOAD = 20;



func accidentMinorTypeToType(type: Int) -> AccidentType? {
    switch type {
        case ACCIDENT_TYPE_CAR_TO_PEDESTRIAN: return .CarToPedestrian;
        case ACCIDENT_TYPE_FRONT_TO_SIDE: return .CarToCar;
        case ACCIDENT_TYPE_FRONT_TO_REAR: return .CarToCar;
        case ACCIDENT_TYPE_SIDE_TO_SIDE: return .CarToCar;
        case ACCIDENT_TYPE_FRONT_TO_FRONT: return .CarToCar;
        case ACCIDENT_TYPE_WITH_STOPPED_CAR_NO_PARKING: return .CarToCar;
        case ACCIDENT_TYPE_WITH_STOPPED_CAR_PARKING: return .CarToCar;
        case ACCIDENT_TYPE_WITH_STILL_OBJECT: return .CarToObject;
        case ACCIDENT_TYPE_OFF_ROAD_OR_SIDEWALK: return .CarToObject;
        case ACCIDENT_TYPE_ROLLOVER: return .CarToObject;
        case ACCIDENT_TYPE_SKID: return .CarToObject;
        case ACCIDENT_TYPE_HIT_PASSSENGER_IN_CAR: return .CarToCar;
        case ACCIDENT_TYPE_FALLING_OFF_MOVING_VEHICLE: return .CarToObject;
        case ACCIDENT_TYPE_FIRE: return .CarToObject;
        case ACCIDENT_TYPE_OTHER: return .CarToObject;
        case ACCIDENT_TYPE_BACK_TO_FRONT: return .CarToCar;
        case ACCIDENT_TYPE_BACK_TO_SIDE: return .CarToCar;
        case ACCIDENT_TYPE_WITH_ANIMAL: return .CarToPedestrian;
        case ACCIDENT_TYPE_WITH_VEHICLE_LOAD: return .CarToCar;
    default: return nil
    }
}