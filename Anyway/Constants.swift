//
//  Constants.swift
//  Anyway
//
//  Created by Aviel Gross on 8/10/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation

let fallbackStartLocationCoordinate = CLLocationCoordinate2D(latitude: 32.158091269627874, longitude: 34.88087036877948)

struct Color {
    static var red = UIColor(red:0.856, green:0.123, blue:0.168, alpha:1)
    static var orange = UIColor(red:1, green:0.626, blue:0, alpha:1)
    static var yellow = UIColor(red:1, green:0.853, blue:0, alpha:1)
    static var blue = UIColor(red:0, green:0.526, blue:0.808, alpha:1)
}

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

/**
 Accident Providing Organization
 
 - CBS:    הלמ״ס
            raw can be 1 or 3
 - Ihud:   איחוד והצלה
             raw can be 2
 
 */
enum Provider {
    case CBS
    case Ihud
    
    init?(_ raw: Int) {
        switch raw {
        case 1,3: self = CBS
        case 2: self = Ihud
        default: return nil
        }
    }
    
    var name: String {
        switch self {
        case .CBS: return "הלשכה המרכזית לסטטיסטיקה"
        case .Ihud: return "איחוד הצלה"
        }
    }
    
    var logo: String {
        switch self {
        case .CBS: return "cbs"
        case .Ihud: return "ihud"
        }
    }
    
    var url: String {
        switch self {
        case .CBS: return "http://www.cbs.gov.il"
        case .Ihud: return "http://www.1221.org.il"
        }
    }
    
}

