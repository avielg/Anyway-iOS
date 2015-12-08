//
//  Person.swift
//  Anyway
//
//  Created by Aviel Gross on 30/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Person: RawInfo {
    
    let info: [(String, String)] //(title key, content
    
    init(json: JSON, index: Int) {
        
        // Constant keys to create the object
        let rawInfo = [
        ("SUG_MEORAV","involved_type"),
        ("SHNAT_HOZAA","license_acquiring_date"),
        ("KVUZA_GIL","age_group"),
        ("MIN","sex"),
        ("MAHOZ_MEGURIM","home_district"),
        ("SUG_REHEV_NASA_LMS","car_type"),
        ("EMZAE_BETIHUT","safety_measures"),
        ("HUMRAT_PGIA","injury_severity"),
        ("SUG_NIFGA_LMS","injured_type"),
        ("PEULAT_NIFGA_LMS","injured_position"),
        ("KVUTZAT_OHLUSIYA_LMS","population_type")
            ]
        
        // Build the actuall info:
        // For values that are string > leave as is
        // For number > parse to the actual value
        let finalInfo = [("INNER_PERSON_TITLE", "\(index)")] + rawInfo.map { (local, jsonKey) in
                
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
        
        "population_type":"יהודים",
        "release_dest":-1,
        "home_nafa":"בית לחם",
        "injury_severity":3,
        "license_acquiring_date":2013,
        "hospital_time":-1,
        "involved_type":2,
        "home_area":"נפת בית לחם",
        "late_deceased":-1,
        "safety_measures_use":-1,
        "home_district":"יהודה ושומרון",
        "injured_position":null,
        "home_residence_type":"יישובים יהודיים 49999-20000 תושבים",
        "id":799949,
        "provider_code":3,
        "medical_type":-1,
        "age_group":"40-44",
        "safety_measures":2,
        "accident_id":2014000964,
        "home_municipal_status":null,
        "car_type":10,
        "injured_type":4,
        "home_city":3780,
        "sex":1
        
        
        */
    }
    
}