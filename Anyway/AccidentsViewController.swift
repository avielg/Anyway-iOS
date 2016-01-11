//
//  AccidentsViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 7/6/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

/**
 A screen for a list of accidents
 
 Visible:
    a. when tapping the button at the
       bottom bar in the main screen.
    b. on an iPad, in a split-screen enviroment.
 
*/
class AccidentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let storyboardId = "all acidents storyboard id"

    var dataSource = [Marker]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "logo_rectangle")!
        navigationItem.titleView = UIImageView(image: img)
        
        if splitViewController?.collapsed ?? true {
            // show the close button
            closeBarButton.enabled = true
            closeBarButton.tintColor = nil
        } else {
            // hide
            closeBarButton.enabled = false
            closeBarButton.tintColor = UIColor.clearColor()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.deselectRowIfNeeded()
    }
    
    func refreshUI() {
        tableView.reloadData()
    }
    
    /**
     Prepare for presenting another screen
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let
            dest = segue.destinationViewController as? DetailViewController,
            cell = sender as? UITableViewCell,
            path = tableView.indexPathForCell(cell),
            marker = dataSource.safeRetrieveElement(path.row)
        else {return}
        
        dest.detailData = marker
    }
    
    
    //MARK: TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detail cell", forIndexPath: indexPath) 
        
        let data = dataSource[indexPath.row]
        
        if let name = data.iconName {
            cell.imageView?.image = UIImage(named: name)
        }
        
        cell.textLabel?.text = data.title ?? ""
        cell.detailTextLabel?.text = "\(data.subtitle ?? "") \(data.created.shortDate)"
        
        
        return cell
    }
    
    
    //MARK: Actions
    
    @IBAction func ActionClose(sender: UIBarButtonItem) {
        let controller = self.presentingViewController ?? self.navigationController?.presentingViewController
        controller?.dismissViewControllerAnimated(true) { }
    }
}
