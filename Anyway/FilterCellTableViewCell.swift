//
//  FilterCellTableViewCell.swift
//  Anyway
//
//  Created by Aviel Gross on 3/30/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

protocol FilterCellDelegate {
    func filterSwitchChanged(to: Bool, filterType: FilterCellTableViewCell.FilterType)
}

class FilterCellTableViewCell: UITableViewCell {

    enum FilterType: Int {
        case StartDate = 0, EndDate // Date pickers
        case ShowFatal, ShowSevere, ShowLight, ShowInaccurate // Switches
    }
    
    var filterType: FilterType?
    weak var filter: Filter? { didSet{ updateCellUI() } }
    
    @IBOutlet weak var btnSwitch: UISwitch! { didSet{ updateCellUI() } }
    @IBOutlet weak var titleLabel: UILabel! { didSet{ updateCellUI() } }
    @IBOutlet weak var detailLabel: UILabel! { didSet{ updateCellUI() } }
    
    var filterCellLabel: String? {
        if let type = filterType {
            switch type {
            case .StartDate: return "תאריך התחלה"
            case .EndDate: return "תאריך סיום"
            case .ShowFatal: return "הצג תאונות קטלניות"
            case .ShowSevere: return "הצג פגיעות בינוניות"
            case .ShowLight: return "הצג פגיעות קלות"
            case .ShowInaccurate: return "הצג תאונות לא מדויקות"
            }
        }
        return nil
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        if let type = filterType {
            switch type {
            case .ShowFatal: filter?.showFatal = btnSwitch.on
            case .ShowSevere: filter?.showSevere = btnSwitch.on
            case .ShowLight: filter?.showLight = btnSwitch.on
            case .ShowInaccurate: filter?.showInaccurate = btnSwitch.on
            default: break
            }
        }
    }
    
    
    func updateCellUI() {
        //Labels
        titleLabel?.text = filterCellLabel
        
        //Filter
        if let type = filterType, let fil = filter {
            switch type {
            case .StartDate: detailLabel?.text = dateLabel(fil.startDate)
            case .EndDate: detailLabel?.text = dateLabel(fil.endDate)
            case .ShowFatal: btnSwitch?.on = fil.showFatal
            case .ShowSevere: btnSwitch?.on = fil.showSevere
            case .ShowLight: btnSwitch?.on = fil.showLight
            case .ShowInaccurate: btnSwitch?.on = fil.showInaccurate
            }
        }
    }
    
    func dateLabel(fromDate: NSDate?) -> String {
        if let date = fromDate {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale.currentLocale()
            formatter.timeStyle = NSDateFormatterStyle.NoStyle
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            return formatter.stringFromDate(date)
        }
        return "בחר תאריך"
    }
    
}
