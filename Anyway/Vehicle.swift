//
//  Vehicle.swift
//  Anyway
//
//  Created by Aviel Gross on 30/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol RawInfo {
    var info: [(String, String)] { get } //(title key, content)
}

class Vehicle: RawInfo {
    
    let info: [(String, String)] //(title key, content
    
    init(json: JSON) {
        
        // Constant keys to create the object
        let rawInfo = [
            ("SUG_REHEV_LMS","vehicle_type"),
            ("NEFAH","engine_volume"),
            ("SHNAT_YITZUR","manufacturing_year"),
            ("KIVUNE_NESIA","driving_directions"),
            ("MATZAV_REHEV","vehicle_status"),
            ("SHIYUH_REHEV_LMS","vehicle_attribution"),
            ("MEKOMOT_YESHIVA_LMS","seats"),
            ("MISHKAL_KOLEL_LMS","total_weight")
        ]
        
        // Build the actuall info:
        // For values that are string > leave as is
        // For number > parse to the actual value
        let finalInfo = rawInfo.map { (local, jsonKey) in
            
            let value: String
            
            if let str = json[jsonKey].string {
                value = str
            } else if let num = json[jsonKey].number {
                value = "\(num)"
            } else {
                value = ""
            }
            
            return (local, value)
            } as [(String, String)]
        
        
        // Set the info to self
        self.info = finalInfo
        
        
        /*
        
        "seats":1,
        "id":636806,
        "engine_volume":"51-250",
        "vehicle_type":10,
        "vehicle_attribution":1,
        "provider_code":3,
        "manufacturing_year":2013,
        "vehicle_status":-1,
        "accident_id":2014000964,
        "total_weight":"עד 1.9",
        "driving_directions":"\tממזרח למערב"
        
        
        */
    }

    
}