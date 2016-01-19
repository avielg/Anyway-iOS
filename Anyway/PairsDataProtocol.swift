//
//  PairsDataProtocol.swift
//  Anyway
//
//  Created by Aviel Gross on 1/18/16.
//  Copyright © 2016 Hasadna. All rights reserved.
//

import Foundation

typealias Title = String
typealias Detail = String

protocol PairsData {}
extension PairsData {
    
    static func pair(forType type: Localization, value: Int) -> (Title, Detail)? {
        guard let
            field = staticFieldNames["\(type)"],
            result = type[value]
            where result.isEmpty == false
            else { return nil }
        
        return (field, result)
    }
}
