//
//  DetailCells.swift
//  Anyway
//
//  Created by Aviel Gross on 23/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

protocol MarkerPresenter {
    var marker: Marker? { get set }
    func setInfo(marker: Marker?)
}

class DetailCell: UITableViewCell, MarkerPresenter {
    
    var marker: Marker?
    var vehicles = [Vehicle]()
    var persons = [Person]()
    
    var indexPath: NSIndexPath?
    
    func setInfo(marker: Marker?) {
        assertionFailure("Should be implemented by subclass!")
    }
}


//MARK: Specific

protocol WebPresentationDelegate: class {
    func shouldPresent(address: String)
}

class DetailCellTop: DetailCell {
    static let dequeueId = "DetailCellTop"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSource: UILabel!
    
    @IBOutlet weak var buttonSource: UIButton!
    
    /// Presents accident's date
    @IBOutlet weak var labelFooter: UILabel!
    
    weak var webDelegate: WebPresentationDelegate?
    
    override func setInfo(marker: Marker?) {
        guard let _ = indexPath else {return}
        // If marker is nil all labels will be nil -> clears any former label from cell dequeue...
        
        // Provider init can fail > button title will simply be nil...
        buttonSource.setTitle(Provider(marker?.provider_code ?? -1)?.name, forState: .Normal)
        
        labelFooter.text = marker.map{"\($0.created.longDate), \($0.created.shortTime)"} ?? ""
        
        //TODO: Change to the same nice title as in website.... (take algorithm from the website??)
        labelTitle.text = marker?.title
    }
    
    @IBAction func actionSource() {
        guard let m = marker, p = Provider(m.provider_code) else {return}
        webDelegate?.shouldPresent(p.url)
    }
    
}

class DetailCellHeader: DetailCell {
    static let dequeueId = "DetailCellHeader"
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func setInfo(marker: Marker?) {
        guard let path = indexPath else {return}
        
        let header = StaticData.header(forSection: path.section)
        
        imageIcon.image = header?.image
        labelTitle.text = header?.name
    }
}

class DetailCellInfo: DetailCell {
    static let dequeueId = "DetailCellInfo"
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    
    override func setInfo(marker: Marker?) {
        guard let path = indexPath else {return}
        
        labelTitle.text = StaticData.title(marker, atIndex: path, persons: persons, vehicles: vehicles)
        labelInfo.text = StaticData.info(marker, atIndex: path, persons: persons, vehicles: vehicles)
    }
    
}


private struct StaticData {
    
    struct Header {
        let name: String
        let image: UIImage
    }
    static func header(forSection section: Int) -> Header? {
        switch section {
        case 1: return Header(name: "פרטי התאונה", image: UIImage(named: "detail_warning")!)
        case 2: return Header(name: "תנאי הדרך", image: UIImage(named: "detail_road")!)
        case 3: return Header(name: "מיקום וזמן", image: UIImage(named: "detail_marker")!)
        case 4: return Header(name: "נפגעים", image: UIImage(named: "detail_pessanger")!)
        case 5: return Header(name: "רכבים מעורבים", image: UIImage(named: "detail_car")!)
        case 6: return Header(name: "מידע נוסף", image: UIImage(named: "detail_plus")!)
        default: return nil
        }
    }
    
    static func title(marker: Marker?, atIndex indexPath: NSIndexPath, persons: [Person], vehicles: [Vehicle]) -> String {
        switch (indexPath.section, indexPath.row) {
            case (1, 1): return "מספר סידורי"
            case (1, 2): return "סוג תיק"
            case (1, 3): return "חומרת תאונה"
            case (1, 4): return "סוג תאונה"
            
            case (2, let i): return marker?.roadConditionData.safeRetrieveElement(i)?.0 ?? ""
            
            case (3, 1): return "תאריך"
            case (3, 2): return "סוג יום"
            case (3, 3): return "" // address (no title on website design)
            
            case (4, let i): return fieldName(i, rawInfos: persons)
            case (5, let i): return fieldName(i, rawInfos: vehicles)
            
            case (6, 1): return "עיגון"
            case (6, 2): return "יחידה"

//        case 1: return "כותרת"
//        case 2: return "כתובת"
//        case 3: return "תיאור"
//        case 4: return "כותרת תאונה"
//        case 5: return "תאריך"
//        case 6: return "עוקבים"
//        case 7: return "עוקב"
//        case 8: return "ID"
//        case 9: return "רמת דיוק"
//        case 10: return "חומרה"
//        case 11: return "תת סוג"
//        case 12: return "סוג"
//        case 13: return "משתמש"
//        case 14: return "מיקום"
        default: return ""
        }
    }
    
    static func fieldName<T: RawInfo>(row: Int, rawInfos: [T]) -> String {
        guard let
            info = infoData(row, rawInfos: rawInfos),
            field = staticFieldNames[info.0]
        else { return "UNKNOWN FIELD" }
        
        return field
    }
    
    static func fieldValue<T: RawInfo>(row: Int, rawInfos: [T]) -> String {
        guard let
            info = infoData(row, rawInfos: rawInfos)
        else { return "UNKNOWN FIELD" }
        
        return info.1
    }
    
    static func infoData<T: RawInfo>(var row: Int, rawInfos: [T]) -> (String, String)? {
        
        row-- // row 0 is the "header" cell, so we begin from 1 instead 0...
        
        for p in rawInfos {
            if row < p.info.count {
                return p.info[row]
            }
            row -= p.info.count
        }
        return nil
    }
    
    static func info(marker: Marker?, atIndex indexPath: NSIndexPath, persons: [Person], vehicles: [Vehicle]) -> String {
        guard let data = marker else {return ""}
        
        switch (indexPath.section, indexPath.row) {
            
        case (1, 1): return "\(data.id)"
        case (1, 2): return "סוג תיק"
        case (1, 3): return data.localizedSeverity
        case (1, 4): return data.localizedSubtype
            
        case (2, let i): return marker?.roadConditionData.safeRetrieveElement(i)?.1 ?? ""
            
        case (3, 1): return "\(data.created.longDate), \(data.created.shortTime)"
        case (3, 2): return Localization.SUG_YOM[data.dayType] ?? ""
        case (3, 3): return data.address
            
        case (4, let i): return fieldValue(i, rawInfos: persons)
        case (5, let i): return fieldValue(i, rawInfos: vehicles)
            
        case (6, 1): return Localization.STATUS_IGUN[data.intactness] ?? "" //TODO: is right param?
        case (6, 2): return Localization.YEHIDA[data.unit] ?? ""

        default: return ""
        }
    }
    
}