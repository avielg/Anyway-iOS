//
//  ViewController+Table.swift
//  Anyway
//
//  Created by Aviel Gross on 14/12/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import UIKit

/**
 Filter Table View Logic
*/
extension ViewController {
    
    enum TableViewState { case Closed, Filter }
        
    func openTableView(type: TableViewState) {
        tableViewState = type
        backBlackView.hidden = false
        constraintTableViewBottom.constant = 0
        view.bringSubviewToFront(tableViewContainer)
        UIView.animateWithDuration(0.25) {
            self.tableViewContainer.layoutIfNeeded()
            self.backBlackView.alpha = 1
        }
    }
    
    func closeTableView() {
        tableViewState = .Closed
        
        constraintTableViewBottom.constant = -constraintTableViewHeight.constant
        UIView.animateWithDuration(0.25, animations:{
            self.tableViewContainer.layoutIfNeeded()
            self.backBlackView.alpha = 0
        }) { _ in
            self.backBlackView.hidden = true
        }
    }
    
    func numberOfRowsForFilterTable(section s: Int) -> Int {
        return s == 0 ? 2 : 4
    }
    
    func totalRowsForFilterTable() -> Int {
        return 6
    }
    
}

/**
 Managing the filter table view UI
 
    Data for populating the table is
    harcoded. Much of the logic and data
    is in 'FilterCellTableViewCell' and
    is defined by setting it's 'filterType'.
 
*/
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    //MARK: UITableViewDataSource
    /* 
        What to show? 
    */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsForFilterTable(section: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dateId = "dateFilterCellIdentifier"
        let switchId = "switchFilterCellIdentifier"
        var cell: FilterCellTableViewCell!
        
        switch (indexPath.row, indexPath.section) {
            //        case (0, 0): fallthrough //Pick start date
        case (_, 0):             //Pick end date
            cell = tableView.dequeueReusableCellWithIdentifier(dateId) as! FilterCellTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        default:
            cell = tableView.dequeueReusableCellWithIdentifier(switchId) as! FilterCellTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        switch (indexPath.row, indexPath.section) {
        case (0, 0): cell.filterType = .StartDate
        case (1, 0): cell.filterType = .EndDate
        case (0, 1): cell.filterType = .ShowFatal
        case (1, 1): cell.filterType = .ShowSevere
        case (2, 1): cell.filterType = .ShowLight
        case (3, 1): cell.filterType = .ShowInaccurate
        default: break
        }
        
        cell.filter = filter
        
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    /* 
        - How to show it?
        - What to do on when X happens?
    */
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row, indexPath.section) {
        case (0, 0): //Pick start date
            dateSelectionType = .Start
            closeTableView()
            openDateSelectionController()
        case (1, 0): //Pick end date
            dateSelectionType = .End
            closeTableView()
            openDateSelectionController()
        default:
            break
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    //MARK: UIScrollViewDelegate
    /* 
        What to do when the table (which
        is actually a UISCrollView
        subclass...) moves/gets dragged?
    */
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableView {
            constraintTableViewBottom.constant += scrollView.contentOffset.y
            constraintTableViewBottom.constant = min(0, constraintTableViewBottom.constant)
            scrollView.contentOffset = CGPointZero
            tableView.setNeedsLayout()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tableView {
            let delta = constraintTableViewHeight.constant / 3
            if abs(constraintTableViewBottom.constant) > delta || velocity.y < -1 {
                closeTableView()
            } else {
                openTableView(tableViewState)
            }
        }
    }
}