//
//  ViewController+DatePicker.swift
//  Anyway
//
//  Created by Aviel Gross on 14/12/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

/**
 Date picker for the filter "from" and "to" parameters
*/
extension ViewController: RMDateSelectionViewControllerDelegate {
    
    func dateSelectionViewController(vc: RMDateSelectionViewController!, didSelectDate aDate: NSDate!) {
        if dateSelectionType == .Start {
            filter.startDate = aDate
        } else {
            filter.endDate = aDate
        }
        tableView?.reloadData()
        openTableView(.Filter)
    }
    
    func dateSelectionViewControllerDidCancel(vc: RMDateSelectionViewController!) {
        openTableView(.Filter)
    }
    
}