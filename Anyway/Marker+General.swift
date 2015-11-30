//
//  Marker+General.swift
//  Anyway
//
//  Created by Aviel Gross on 30/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation


typealias Coordinate = CLLocationCoordinate2D


//MARK: - Protocols

@objc protocol MarkerAnnotation: class, NSObjectProtocol, MKAnnotation {}

protocol VisualMarker: MarkerAnnotation {
    var iconName: String? { get }
}