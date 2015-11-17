//
//  DetailViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 4/27/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    static let segueIdentifier = "show accident detail"
    
    var detailData: Marker?

    @IBOutlet weak var tableTopEdgeConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBAction func dismissAction() {
        dismissViewControllerAnimated(true) { }
    }

    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if navigationController != nil {
//            btnClose.removeFromSuperview()
//            tableTopEdgeConstraint.constant = 0
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController != nil {
            btnClose.removeFromSuperview()
            tableTopEdgeConstraint.constant = 0
        }
    }
    
    //MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail cell", forIndexPath: indexPath) 
        cell.textLabel?.text = title(atIndex: indexPath.row)
        cell.detailTextLabel?.text = info(atIndex: indexPath.row)
        return cell
    }
    
    func title(atIndex index: Int) -> String {
        switch index {
        case 0: return "כותרת"
        case 1: return "מיקום"
        case 2: return "כתובת"
        case 3: return "תיאור"
        case 4: return "כותרת תאונה"
        case 5: return "תאריך"
        case 6: return "עוקבים"
        case 7: return "עוקב"
        case 8: return "ID"
        case 9: return "רמת דיוק"
        case 10: return "חומרה"
        case 11: return "תת סוג"
        case 12: return "סוג"
        case 13: return "משתמש"
        default: return ""
        }
    }
    
    func info(atIndex index: Int) -> String {
        if let data = detailData {
            switch index {
            case 0: return data.title ?? ""
            case 1: return data.coordinate.humanDescription
            case 2: return data.address
            case 3: return data.descriptionContent
            case 4: return data.titleAccident
            case 5: return data.created.shortDescription
            case 6: return "\(data.followers.count)"
            case 7: return data.following ? "כן" : "לא"
            case 8: return "\(data.id)"
            case 9: return data.localizedAccuracy
            case 10: return data.localizedSeverity
            case 11: return data.localizedSubtype
            case 12: return "\(data.type)"
            case 13: return data.user
            default: return ""
            }
        }
        return ""
    }

}
