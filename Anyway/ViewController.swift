//
//  ViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

private func newHud() -> JGProgressHUD {
    let hud = JGProgressHUD(style: .Light)
    hud.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
    hud.interactionType = JGProgressHUDInteractionType.BlockNoTouches
    return hud
}

/**
 Main app screen
  Main view is the map, on the botton a bar with
  "accidents list" button and "filter" button.
*/
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    enum DateSelectionType { case None, Start, End }

    @IBOutlet weak var btnFilter: UIBarButtonItem!
    @IBOutlet weak var btnAccidents: UIBarButtonItem!
    @IBOutlet weak var btnInfo: UIButton!
    
    
    @IBOutlet weak var detailLabel: UILabel! {
        didSet{
            detailLabel?.backgroundColor = UIColor.whiteColor()
            detailLabel?.layer.borderColor = UIColor.grayColor().CGColor
            detailLabel?.layer.borderWidth = 0.5
            detailLabel?.layer.cornerRadius = 4
            detailLabel?.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var map: OCMapView!
    
    @IBOutlet weak var backBlackView: UIView!
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintTableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    
    
    /// Holds the filter params for the current results
    var filter = Filter()
    
    /// Filter table current state
    var tableViewState = TableViewState.Closed

    /// Wether the user is currently selecting start date, end, or none
    var dateSelectionType = DateSelectionType.None
    
    /// Last area shown on the map
    var lastRegion = MKCoordinateRegionForMapRect(MKMapRectNull)
    
    /// Location Services
    let locationManager = CLLocationManager()
    
    /// Handling the network calls
    let network = Network()
    
    /// Progress hud
    let hud = newHud()
    
    /// Wether we currently get info from server
    var gettingInfo = false
    
    /// flag for determine the first time the view layed out
    var initialLayout = true
    
    /// flag for handling auto-moving the map when app launches
    var shouldJumpToStartLocation = true
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.clusterSize = 0.1
        map.minimumAnnotationCountPerCluster = 4
        
        filter.onChange = { self.updateInfoIfPossible(self.map, filterChanged:true) }
        
        // Always present master and detail side-by-side
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        // Set the master (map) relative side
        splitViewController?.minimumPrimaryColumnWidth = view.frame.width * 0.6
        splitViewController?.maximumPrimaryColumnWidth = view.frame.width * 0.6
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        backBlackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "closeTableView"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLocationMonitoringAuthorized() {
            sync{ self.beginTrackingLocation() }
        }
    }
    
    override func viewWillLayoutSubviews() {
        if initialLayout {
            initialLayout = false
            
            let rows = CGFloat(totalRowsForFilterTable())
            let rowHeight = CGFloat(44)// tableView.rowHeight -> is -1 at this point
            let sections = CGFloat(numberOfSectionsInTableView(tableView))
            let headerHeight = CGFloat( tableView(tableView, heightForHeaderInSection: 0) )
            
            constraintTableViewHeight.constant = rowHeight * rows + headerHeight * sections
            constraintTableViewBottom.constant = -constraintTableViewHeight.constant
        }
    }
    
    
    //MARK: - Logic
    
    var isMapCloseEnoughToFetchData: Bool {
        return btnFilter.enabled
    }
    
    func setAreaCanFetchDataUI(canFetch: Bool) {
        if !canFetch {
            self.detailLabel.text = "איזור גדול מדי, נסה להתקרב"
            self.detailLabel.hidden = false
            self.btnAccidents.title = "תאונות"
        }
        btnFilter.enabled = canFetch
        btnAccidents.enabled = canFetch
    }
    
    func updateInfoIfPossible(map: MKMapView, filterChanged: Bool) {
        
        // Too far >> don't get anything
        if Int(map.edgesDistance()) > MAX_DIST_OF_MAP_EDGES {
            self.setAreaCanFetchDataUI(false)
            return
        }
        self.setAreaCanFetchDataUI(true)
        
        // Only Zoomed in >> don't update
        if !filterChanged && MKCoordinateRegionContainsRegion(lastRegion, map.region) && map.visibleAnnotations().count > 0 {
            return
        }
        
        // In the middle >> don't update
        if gettingInfo { return }
        
        
        gettingInfo = true
        hud.showInView(view)
        print("Getting some...")
        
        
        network.getAnnotations(map.edgePoints(), filter: filter) { [weak self] marks, count in
            print("finished parsing")
            guard let s = self else {return}
            
            s.map.annotationsToIgnore = nil
            s.map.removeAnnotations(s.map.annotations) // remove old
            s.map.addAnnotations(marks) // add new
            s.detailLabel.hidden = true
            s.btnAccidents.title = String.localizedStringWithFormat(local("main_presenting_count_label"), count)
            
            s.gettingInfo = false
            
            // iPad/big iPhone >> update accidents list in split view
            if let
                nav = s.splitViewController?.viewControllers.safeRetrieveElement(1) as? UINavigationController,
                detail = nav.viewControllers.first as? AccidentsViewController
            {
                s.populate(accidentsViewController: detail)
                detail.refreshUI()
            }
            
            s.hud.dismiss() // hide progress hud
        }

    }
    
    
    
    //MARK: - Actions
    
    @IBAction func actionFilter(sender: UIBarButtonItem) {
        openTableView(.Filter)
    }
    
    @IBAction func actionAccidents(sender: UIBarButtonItem) {
        
        // Create the accidents VC from the current storyboard
        let destNav = storyboard?.instantiateViewControllerWithIdentifier(AccidentsViewController.storyboardId) as! UINavigationController
        
        guard let dest = destNav.topViewController as? AccidentsViewController
            else {return}
        
        
        //Populate the accidents VC with data
        populate(accidentsViewController: dest)
        
        // Show it
        showDetailViewController(destNav, sender: self)
        
    }
    
    
    
    //MARK: - UI Logic
    
    func populate(accidentsViewController dest: AccidentsViewController) {
        // get map annotations as MarkerAnnotation
        let annots = map.annotations.flatMap{ ($0 as? MarkerAnnotation) ?? nil }
        
        // break any MarkerGroup and create Marker array
        var markers = [Marker]()
        for annot in annots {
            if let group = annot as? MarkerGroup {
                markers += group.markers
            }
            if let marker = annot as? Marker {
                markers.append(marker)
            }
        }
        
        
        dest.dataSource = markers.sort{$0.created.compare($1.created) == .OrderedDescending}
    }
    
    func openDateSelectionController() {
        let dateSelectionVC = RMDateSelectionViewController.dateSelectionController()
        dateSelectionVC.datePicker.datePickerMode = UIDatePickerMode.Date
        dateSelectionVC.disableBouncingWhenShowing = true
        dateSelectionVC.delegate = self
        dateSelectionVC.show()
    }
    
    
}

