//
//  ViewController+LocationServices.swift
//  Anyway
//
//  Created by Aviel Gross on 04/01/2016.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation

/**
 Handling location services for the main screen
*/
extension ViewController {
    
    func isLocationMonitoringAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .AuthorizedAlways || status == .AuthorizedWhenInUse
    }
    
    
    
    func beginTrackingLocation() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
            
        case .NotDetermined: //NEVER ASKED
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization() //iOS 8+
            } else {
                locationManager.startUpdatingLocation() //iOS 7
            }
            
        case .AuthorizedAlways: fallthrough
        case .AuthorizedWhenInUse: //GRANTED
            map.showsUserLocation = true
            
        case .Restricted: //RESTRICTED
            break
            
        case .Denied: //DENIED
            break
            
        }
        
    }
    
}