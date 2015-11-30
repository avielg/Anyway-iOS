//
//  AccidentsViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 7/6/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

class AccidentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static let storyboardId = "all acidents storyboard id"

    var dataSource = [Marker]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo_rectangle")!)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let
            dest = segue.destinationViewController as? DetailViewController,
            cell = sender as? UITableViewCell,
            path = tableView.indexPathForCell(cell),
            marker = dataSource.safeRetrieveElement(path.row)
        else {return}
        
        dest.detailData = marker
    }
    
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
    
    @IBAction func ActionClose(sender: UIBarButtonItem) {
        (self.presentingViewController ?? self.navigationController?.presentingViewController)?.dismissViewControllerAnimated(true) { }
    }
}
