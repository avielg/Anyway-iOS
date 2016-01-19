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
        
        // get title and row type for this marker at this index path
        let (title, rowType) = StaticData.title(marker, atIndex: path, persons: persons, vehicles: vehicles)
        
        // set the title
        labelTitle.text = title
        
        // make inter-titles a stand out a bit
        switch rowType {
        case .IntermediateTitle: self.contentView.alpha = 1
        case .Info: self.contentView.alpha = 0.6
        }
        
        // set the info itself
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
    
    enum InfoRowType {
        case Info, IntermediateTitle
    }
    
    static func title(marker: Marker?, atIndex indexPath: NSIndexPath, persons: [Person], vehicles: [Vehicle]) -> (String, InfoRowType) {
        switch (indexPath.section, indexPath.row) {
            case (1, 1): return ("מספר סידורי", .Info)
            case (1, 2): return ("סוג תיק", .Info)
            case (1, 3): return ("חומרת תאונה", .Info)
            case (1, 4): return ("סוג תאונה", .Info)
            
            case (2, let i): return (marker?.roadConditionData.safeRetrieveElement(i)?.0 ?? "", .Info)
            
            case (3, 1): return ("תאריך", .Info)
            case (3, 2): return ("סוג יום", .Info)
            case (3, 3): return ("", .Info) // address (no title on website design)
            
            case (4, let i): return fieldName(i, rawInfos: persons)
            case (5, let i): return fieldName(i, rawInfos: vehicles)
            
            case (6, 1): return ("עיגון", .Info)
            case (6, 2): return ("יחידה", .Info)

            default: return ("", .Info)
        }
    }
    
    static func fieldName<T: RawInfo>(row: Int, rawInfos: [T]) -> (String, InfoRowType) {
        guard let
            info = infoData(row, rawInfos: rawInfos),
            titleKey = rawInfos.first?.innerTitleKey
            else { return ("UNKNOWN FIELD", .Info) }
        
        
        if info.0 == staticFieldNames[titleKey] {
            return (info.0, .IntermediateTitle)
        }
        return (info.0, .Info)
    }
    
    static func fieldValue<T: RawInfo>(row: Int, rawInfos: [T]) -> String {
        guard let
            info = infoData(row, rawInfos: rawInfos)
        else { return "UNKNOWN FIELD" }
        
        return info.1
    }
    
    static func infoData<T: RawInfo>(var row: Int, rawInfos: [T]) -> (String, String)? {
        
        row-- // row 0 is the "header" cell, so we begin from 1 instead 0...
        assert(row >= 0, "row must never be less than zero here")
        
        let infos = rawInfos.flatMap{ $0.info }
        return infos.safeRetrieveElement(row)
        
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