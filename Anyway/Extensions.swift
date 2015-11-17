//
//  Extensions.swift
//  Anyway
//
//  Created by Aviel Gross on 3/24/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation


extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue
            layer.borderColor = titleLabel?.textColor.CGColor ?? layer.borderColor
        }
    }
}

extension CLLocationCoordinate2D {
    var humanDescription: String {
        return "\(latitude),\(longitude)"
    }
}

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        
        var visibleAnots = [MKAnnotation]()
        let selfRegion = self.region
        
        for anot in self.annotations {
            if MKCoordinateRegionContainsPoint(selfRegion, anot.coordinate) {
                visibleAnots.append(anot)
            }
        }
        
        return visibleAnots
    }
}