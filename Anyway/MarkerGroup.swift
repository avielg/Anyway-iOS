//
//  MarkerGroup.swift
//  Anyway
//
//  Created by Aviel Gross on 30/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

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


