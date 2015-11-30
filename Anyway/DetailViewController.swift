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

    static let storyboardId = "accident detail storyboard id"

    var detailData: Marker? { didSet{ handleMarkerChanged() } }
    var persons = [Person]()
    var vehicles = [Vehicle]()
    
    let network = Network()
    
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
    
    //MARK: - Logic
    
    func handleMarkerChanged() {
        guard let marker = detailData else {return}
        
        network.getMarkerDetails(markerId: marker.id) { [weak self] in
            self?.persons = $0.0
            self?.vehicles = $0.1
            self?.tableView.reloadData()
        }
        
    }
    
    //MARK: - WebPresentationDelegate
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
        case (4, 4): return persons.map({$0.info.count}).reduce(0, combine: +) + 1
        case (5, 5): return vehicles.map({$0.info.count}).reduce(0, combine: +) + 1
        case (6, 6): return 2
            
            // collapsed...
        case (1..<7, _): return 1
            
            // fallback
        default: return 0
        }
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Which cell to dequeue?
        let identifier: String
        switch (indexPath.section, indexPath.row) {
            case (0, 0): identifier = DetailCellTop.dequeueId
            case (_, 0): identifier = DetailCellHeader.dequeueId
            default: identifier = DetailCellInfo.dequeueId
        }
        
        // Get the recyced (dequeued) cell from the table view
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! DetailCell
        
        // Fill with data
        cell.indexPath = indexPath
        cell.marker = detailData
        cell.persons = persons
        cell.vehicles = vehicles
        
        // Ask the cell to setup itself with the data
        cell.setInfo(cell.marker)
        
        // Declare any needed delegate to get handle special events with the cell
        if let top = cell as? DetailCellTop {
            top.webDelegate = self
        }
        
        // Change anything related to specific cell type in the specific situation
        if cell is DetailCellHeader {
            if indexPath.section == openSection {
                cell.contentView.backgroundColor = UIColor(red:0.858, green:0.858, blue:0.858, alpha:0.197)
            } else {
                cell.contentView.backgroundColor = UIColor.whiteColor()
            }
        }
        
        // Done
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Ask the table to wait and listen to any update, than animate everythin in the end
        tableView.beginUpdates()
        
        
        if openSection == indexPath.section {
            
            // User selected the section that was open >> Simply collapse it
            
            openSection = 0
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            
        } else {
            
            // User selected a new section >> Collapse the old + Expand the new
            
            /* Set animation depending on relative sections positions (looks kinda ugly)
            let animation: UITableViewRowAnimation
            if openSection == 0 { animation = .Automatic }
            else if openSection > indexPath.section { animation = .Bottom }
            else { animation = .Top }
            */
            
            // close the currently open section
            if openSection != 0 {
                //collapse
                tableView.reloadSections(NSIndexSet(index: openSection), withRowAnimation: .None)
            }
            
            // open the selected section
            if indexPath.section != 0 {
                openSection = indexPath.section
                tableView.reloadSections(NSIndexSet(index: openSection), withRowAnimation: .Automatic)
            }
            
        }
        
        
        // Ask the table view to animate all the updates at once
        tableView.endUpdates()
        
        // Deselect the row
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

}
