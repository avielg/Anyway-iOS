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

enum AccidentMinorType: Int {
    case CAR_TO_CAR = -1 // Synthetic type
    case CAR_TO_OBJECT = -2 // Synthetic type
    case CAR_TO_PEDESTRIAN = 1
    case FRONT_TO_SIDE = 2
    case FRONT_TO_REAR = 3
    case SIDE_TO_SIDE = 4
    case FRONT_TO_FRONT = 5
    case WITH_STOPPED_CAR_NO_PARKING = 6
    case WITH_STOPPED_CAR_PARKING = 7
    case WITH_STILL_OBJECT = 8
    case OFF_ROAD_OR_SIDEWALK = 9
    case ROLLOVER = 10
    case SKID = 11
    case HIT_PASSSENGER_IN_CAR = 12
    case FALLING_OFF_MOVING_VEHICLE = 13
    case FIRE = 14
    case OTHER = 15
    case BACK_TO_FRONT = 17
    case BACK_TO_SIDE = 18
    case WITH_ANIMAL = 19
    case WITH_VEHICLE_LOAD = 20
}


func accidentMinorTypeToType(type: AccidentMinorType) -> AccidentType? {
    switch type {
        case .CAR_TO_PEDESTRIAN: return .CarToPedestrian
        case .FRONT_TO_SIDE: return .CarToCar
        case .FRONT_TO_REAR: return .CarToCar
        case .SIDE_TO_SIDE: return .CarToCar
        case .FRONT_TO_FRONT: return .CarToCar
        case .WITH_STOPPED_CAR_NO_PARKING: return .CarToCar
        case .WITH_STOPPED_CAR_PARKING: return .CarToCar
        case .WITH_STILL_OBJECT: return .CarToObject
        case .OFF_ROAD_OR_SIDEWALK: return .CarToObject
        case .ROLLOVER: return .CarToObject
        case .SKID: return .CarToObject
        case .HIT_PASSSENGER_IN_CAR: return .CarToCar
        case .FALLING_OFF_MOVING_VEHICLE: return .CarToObject
        case .FIRE: return .CarToObject
        case .OTHER: return .CarToObject
        case .BACK_TO_FRONT: return .CarToCar
        case .BACK_TO_SIDE: return .CarToCar
        case .WITH_ANIMAL: return .CarToPedestrian
        case .WITH_VEHICLE_LOAD: return .CarToCar
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

