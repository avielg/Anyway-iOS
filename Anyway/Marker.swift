//
//  Marker.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit
import MapKit

typealias Coordinate = CLLocationCoordinate2D

//MARK: - Protocols

@objc protocol MarkerAnnotation: class, NSObjectProtocol, MKAnnotation {}

protocol VisualMarker: MarkerAnnotation {
    var iconName: String? { get }
}


//MARK: - MarkerGroup

class MarkerGroup : NSObject, MarkerAnnotation {
    
    var title: String? { return "\(markers.count)" }
    var coordinate: Coordinate
    
    var markers: [Marker] = []
    var highestSeverity: Int = 0
    
    convenience init?(markers: [Marker]) {
        self.init(coordinate: CLLocationCoordinate2DMake(0, 0))
        
        if let coord = markers.first?.coordinate {
            self.coordinate = coord
        }
        self.markers = markers
        for m in markers {
            highestSeverity = max(highestSeverity, m.severity)
        }
        if markers.count < 1 { return nil }
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}

/// Implement "subtitle" param declared in 'MKAnnotation'
extension MarkerGroup {
    var subtitle: String? { return markers.count == 1 ? "תאונה אחת" : "\(markers.count) תאונות" }
}

extension MarkerGroup : VisualMarker {
    var iconName: String? {
        switch highestSeverity {
        case Severity.Severe.rawValue: return "multiple_severe"
        case Severity.Various.rawValue: return "multiple_various"
        case Severity.Fatal.rawValue: return "multiple_lethal"
        case Severity.Light.rawValue: return "multiple_medium"
        default: return "multiple_various"
        }
    }
}



//MARK: - Marker

class Marker : NSObject, MarkerAnnotation {
    
    var title: String? { return localizedSubtype }
    var coordinate: CLLocationCoordinate2D
    
    var address: String = ""
    var descriptionContent: String = ""
    var titleAccident: String = ""
    var created: NSDate = NSDate(timeIntervalSince1970: 0)
    var followers: [AnyObject] = []
    var following: Bool = false
    var id: Int = 0
    var locationAccuracy: Int = 0
    var severity: Int = 0
    var subtype: Int = 0
    var type: Int = 0
    var user: String = ""
    
    //new
    var roadShape: Int = -1
    var cross_mode: Int = -1
    var secondaryStreet: String = ""
    var cross_location: Int = -1
    var one_lane: Int = -1
    var speed_limit: Int = -1
    var weather: Int = -1
    var provider_code: Int = -1
    var road_object: Int = -1
    var didnt_cross: Int = -1
    var object_distance: Int = -1
    var road_sign: Int = -1
    var intactness: Int = -1
    var junction: String = ""
    var road_control: Int = -1
    var road_light: Int = -1
    var multi_lane: Int = -1
    var dayType: Int = -1
    var unit: Int = -1
    var road_width: Int = -1
    var cross_direction: Int = -1
    var roadType: Int = -1
    var road_surface: Int = -1
    var mainStreet: String = ""
    
    convenience init(coord: Coordinate, address: String, content: String, title: String, created: NSDate, id: Int, accuracy: Int, severity: Int, subtype: Int, type: Int) {
        self.init(coordinate: coord)
        self.coordinate = coord
        self.address = address
        self.descriptionContent = content
        self.titleAccident = title
        self.created = created
        self.id = id
        self.locationAccuracy = accuracy
        self.severity = severity
        self.subtype = subtype
        self.type = type
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

/// Implement "subtitle" param declared in 'MKAnnotation'
extension Marker {
    var subtitle: String? { return localizedSeverity }
}

/// Localized descriptions for Marker
extension Marker: VisualMarker {
    //MARK: Localized Info
    
    var localizedSubtype: String {
        switch self.subtype {
        case 1: return "פגיעה בהולך רגל"
        case 2: return "התנגשות חזית אל צד"
        case 3: return "התנגשות חזית באחור"
        case 4: return "התנגשות צד בצד"
        case 5: return "התנגשות חזית אל חזית"
        case 6: return "התנגשות עם רכב חונה"
        case 7: return "התנגשות עם עצם דומם"
        case 8: return "ירידה מהכביש או עלייה למדרכה"
        case 9: return "ירידה מהכביש או עלייה למדרכה"
        case 10: return "התהפכות"
        case 11: return "החלקה"
        case 12: return "פגיעה בנוסע בתוך כלי רכב"
        case 13: return "נפילה ברכב נע"
        case 14: return "שריפה"
        case 15: return "אחר"
        case 17: return "התנגשות אחור אל חזית"
        case 18: return "התנגשות אחור אל צד"
        case 19: return "התנגשות עם בעל חיים"
        case 20: return "פגיעה ממטען של רכב"
        default: return ""
        }
    }
    
    var localizedSeverity: String {
        switch self.severity {
        case 1: return "קטלנית"
        case 2: return "קשה"
        case 3: return "קלה"
        default: return ""
        }
    }
    
    var localizedAccuracy: String {
        switch self.locationAccuracy {
        case 1: return "עיגון מדויק"
        case 2: return "מרכז ישוב"
        case 3: return "מרכז דרך"
        case 4: return "מרכז קילומטר"
        case 9: return "לא עוגן"
        default: return ""
        }
    }
    
    
    var iconName: String? {
        var icons = [Severity:[AccidentType:String]]()
        icons[Severity.Fatal] = [
            AccidentType.CarToPedestrian : "vehicle_person_lethal.png",
            AccidentType.CarToCar : "vehicle_vehicle_lethal.png",
            AccidentType.CarToObject : "vehicle_object_lethal.png"]
        icons[Severity.Severe] = [
            AccidentType.CarToPedestrian : "vehicle_person_severe.png",
            AccidentType.CarToCar : "vehicle_vehicle_severe.png",
            AccidentType.CarToObject : "vehicle_object_severe.png"]
        icons[Severity.Light] = [
            AccidentType.CarToPedestrian : "vehicle_person_medium.png",
            AccidentType.CarToCar : "vehicle_vehicle_medium.png",
            AccidentType.CarToObject : "vehicle_object_medium.png"]

        if let sev = Severity(rawValue: severity),
            let someIcons = icons[sev],
            let type = accidentMinorTypeToType(subtype),
            let icon = someIcons[type] {
                return icon
        }
        
        return nil
    }
}



