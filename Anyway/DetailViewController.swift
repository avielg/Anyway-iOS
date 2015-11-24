//
//  DetailViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 4/27/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit
import SVWebViewController

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebPresentationDelegate {

    static let segueIdentifier = "show accident detail"
    
    var detailData: Marker?

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.estimatedRowHeight =  150
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
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
    
    
    //MAR: - WebPresentationDelegate
    func shouldPresent(address: String) {
        let webView = SVWebViewController(address: address)
        presentViewController(webView, animated: true, completion: nil)
    }
    
    //MARK: - Table View
    
    var openSection: Int = 0
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section, openSection) {
            
            // top cell
        case (0, _): return 1
            
            // info cells: expanded
        case (1, 1): return 4
        case (2, 2): return 10
        case (3, 3): return 3
        case (4, 4): return 2 //FIXME: number of people in accident...
        case (5, 5): return 2 //FIXME: number of cars in accident...
        case (6, 6): return 2
            
            // collapsed...
        case (1..<7, _): return 1
            
            // fallback
        default: return 0
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier: String
        switch (indexPath.section, indexPath.row) {
            case (0, 0): identifier = DetailCellTop.dequeueId
            case (_, 0): identifier = DetailCellHeader.dequeueId
            default: identifier = DetailCellInfo.dequeueId
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! DetailCell
        cell.indexPath = indexPath
        cell.marker = detailData
        cell.setInfo(cell.marker)
        
        if let top = cell as? DetailCellTop {
            top.webDelegate = self
        }
        
        if cell is DetailCellHeader {
            if indexPath.section == openSection {
                cell.contentView.backgroundColor = UIColor.whiteColor()
            } else {
                cell.contentView.backgroundColor = UIColor(red:0.858, green:0.858, blue:0.858, alpha:0.197)
            }
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        if openSection == indexPath.section {
            
            // Only collapse
            openSection = 0
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            
        } else {
            
            // Collapse old + Expand new
//            let higher = max(openSection, indexPath.section)
//            let lower = min(openSection, indexPath.section)
            
            let animation: UITableViewRowAnimation
            if openSection == 0 { animation = .Automatic }
            else if openSection > indexPath.section { animation = .Bottom }
            else { animation = .Top }
            
            if openSection != 0 {
                //collapse
                tableView.reloadSections(NSIndexSet(index: openSection), withRowAnimation: .None)
            }
            if indexPath.section != 0 {
                openSection = indexPath.section
                tableView.reloadSections(NSIndexSet(index: openSection), withRowAnimation: .Automatic)
            }
            
        }
        
        
        
        tableView.endUpdates()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

}
