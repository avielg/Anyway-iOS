//
//  ViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit
import MapKit

private func newHud() -> JGProgressHUD {
    let hud = JGProgressHUD(style: .Light)
    hud.animation = JGProgressHUDFadeZoomAnimation() as JGProgressHUDFadeZoomAnimation
    hud.interactionType = JGProgressHUDInteractionType.BlockNoTouches
    return hud
}

public class Filter {
    var startDate = NSDate(timeIntervalSince1970: 1356991200) { didSet{ valueChanged() } } // Jan 1st 2013
    var endDate = NSDate(timeIntervalSince1970: 1388527200) { didSet{ valueChanged() } }  // Jan 1st 2014
    var showFatal = true { didSet{ valueChanged() } }
    var showSevere = true { didSet{ valueChanged() } }
    var showLight = true { didSet{ valueChanged() } }
    var showInaccurate = false { didSet{ valueChanged() } }
    
    var description: String { return "FILTER: Fatal: \(showFatal) | Severe: \(showSevere) | Light: \(showLight) | Inaccurate: \(showInaccurate)" }
    
    var onChange: ()->() = {}
    func valueChanged() { print("filter changed"); onChange() }
}

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, RMDateSelectionViewControllerDelegate, CLLocationManagerDelegate {
    
    
        
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
    
    var filter = Filter()
    var dateSelectionType = DateSelectionType.None
    
    var lastRegion = MKCoordinateRegionForMapRect(MKMapRectNull)
    let network = Network()
    let hud = newHud()
    var gettingInfo = false
    
    var initialLayout = true
    
    var shouldJumpToStartLocation = true
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.clusterSize = 0.1
        map.minimumAnnotationCountPerCluster = 4
        
        filter.onChange = { self.updateInfoIfPossible(self.map, filterChanged:true) }
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
            
            let rows = CGFloat(totalRowsForTable(.Filter))
            let rowHeight = CGFloat(44)// tableView.rowHeight -> is -1 at this point
            let sections = CGFloat(numberOfSectionsInTableView(tableView))
            let headerHeight = CGFloat( tableView(tableView, heightForHeaderInSection: 0) )
            
            constraintTableViewHeight.constant = rowHeight * rows + headerHeight * sections
            constraintTableViewBottom.constant = -constraintTableViewHeight.constant
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == DetailViewController.segueIdentifier {
            guard let
                dest = segue.destinationViewController as? DetailViewController,
                markerView = sender as? MarkerView,
                marker = markerView.annotation as? Marker
            else {return}
            
            dest.detailData = marker
        }
        else if segue.identifier == AccidentsViewController.segueId {
            if
                let nav = segue.destinationViewController as? UINavigationController,
                    dest = nav.viewControllers.first as? AccidentsViewController
            {
                
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
        
        //If too far - don't get anything
        if Int(map.edgesDistance()) > MAX_DIST_OF_MAP_EDGES {
            self.setAreaCanFetchDataUI(false)
            return
        }
        self.setAreaCanFetchDataUI(true)
        
        //If zommed in - don't update
        if !filterChanged && MKCoordinateRegionContainsRegion(lastRegion, map.region) && map.visibleAnnotations().count > 0 {
            return
        }
        
        
        //if gettingInfo { return }
        gettingInfo = true
        //self.detailLabel.text = "..."
        hud.showInView(view)
        
        print("Getting some...")
        network.getAnnotations(map.edgePoints(), filter: filter) { marks, count in
            print("finished parsing")
            self.map.annotationsToIgnore = nil
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotations(marks)
//            self.detailLabel.text = "מציג \(count) תאונות"
            self.detailLabel.hidden = true
            self.btnAccidents.title = "מציג \(count) תאונות"
            self.gettingInfo = false
            self.hud.dismiss()
        }

    }
    
    //MARK: - Actions
    @IBAction func actionFilter(sender: UIBarButtonItem) {
        openTableView(.Filter)
    }
    
    @IBAction func actionAccidents(sender: UIBarButtonItem) {
        
    }
    
    
    enum TableViewType { case Closed, Filter, Accidents }
    
    var tableViewType = TableViewType.Closed
    
    func openTableView(type: TableViewType) {
        tableViewType = type
//        backBlackView.alpha = 0
        backBlackView.hidden = false
        constraintTableViewBottom.constant = 0
        view.bringSubviewToFront(tableViewContainer)
        UIView.animateWithDuration(0.25) {
            self.tableViewContainer.layoutIfNeeded()
            self.backBlackView.alpha = 1
        }
    }
    
    func closeTableView() {
        tableViewType = .Closed
        
        constraintTableViewBottom.constant = -constraintTableViewHeight.constant
        UIView.animateWithDuration(0.25, animations:{
            self.tableViewContainer.layoutIfNeeded()
            self.backBlackView.alpha = 0
            }) { _ in
                self.backBlackView.hidden = true
        }
    }
    
    func openDateSelectionController() {
        let dateSelectionVC = RMDateSelectionViewController.dateSelectionController()
        dateSelectionVC.datePicker.datePickerMode = UIDatePickerMode.Date
        dateSelectionVC.disableBouncingWhenShowing = true
        dateSelectionVC.delegate = self
        dateSelectionVC.show()
    }

    //MARK: - Table View
    
    enum TableType {
        case Filter, Accidents
    }
    
    func numberOfRowsForTable(type: TableType, _ section: Int) -> Int {
        switch type {
        case .Filter: return section == 0 ? 2 : 4
        case .Accidents: return 0
        }
    }
    func totalRowsForTable(type: TableType) -> Int {
        switch type {
        case .Filter: return 6
        case .Accidents: return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsForTable(.Filter, section)
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
    
    //MARK: - Scrollview
    
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
                openTableView(tableViewType)
            }
        }
    }
    
    //MARK: - MapView
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        if let view = map.subviews.first {
            for gestureObj in view.gestureRecognizers ?? [] {
                if let gesture = gestureObj as? UIGestureRecognizer {
                    if gesture.state == .Began || gesture.state == .Ended {
                        return true
                    }
                }
            }
        }
        return false
    }
        
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        map.clusteringEnabled = Int(mapView.edgesDistance()) > MIN_DIST_CLUSTER_DISABLE
        
        if CLLocation.distance(from: lastRegion.center, to: mapView.region.center) > 50 {
            updateInfoIfPossible(mapView, filterChanged:false)
        }
        lastRegion = mapView.region
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        network.cancelRequestIfNeeded()
        
        if hud.visible {
            hud.dismissAnimated(false)
        }
        
        if mapViewRegionDidChangeFromUserInteraction() {
            shouldJumpToStartLocation = false
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if let cluster = annotation as? OCAnnotation {
            let pin = ClusterView(annotation: cluster, reuseIdentifier: clusterReuseIdentifierDefault)
            pin.label?.text = "\(cluster.annotationsInCluster().count)"
            return pin
        }
        if let marker = annotation as? Marker {
            
            if let mView = mapView.dequeueReusableAnnotationViewWithIdentifier(markerReuseIdentifierDefault) as? MarkerView {
                mView.annotation = marker
                return mView
            }
            return MarkerView(marker: marker)
            
        }
        if let markerGroup = annotation as? MarkerGroup {
            
            if let mView = mapView.dequeueReusableAnnotationViewWithIdentifier(markerGroupReuseIdentifierDefault) as? MarkerGroupView {
                mView.annotation = markerGroup
                return mView
            }
            return MarkerGroupView(markerGroup: markerGroup)
            
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let markerView = view as? MarkerView {
            performSegueWithIdentifier(DetailViewController.segueIdentifier, sender: markerView)
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let groupView = view as? MarkerGroupView {
            
            if let ann = view.annotation {
                mapView.removeAnnotation(ann)
            }
            
            let markerGroup = groupView.annotation as! MarkerGroup
            let markers = markerGroup.markers
            if map.annotationsToIgnore == nil {
                map.annotationsToIgnore = NSMutableSet()
            }
            map.annotationsToIgnore.addObjectsFromArray(markers)
            
//            for marker in markers { //to make sure...
//                marker.coordinate = markerGroup.coordinate
//            }
            
            let addMarkers = {
                mapView.addAnnotations(markers)
            }
            
            UIView.animateWithDuration(0, animations:addMarkers) { _ in
                UIView.animateWithDuration(0.25, animations: {
                    AnnotationCoordinateUtility.repositionAnnotations(markers, toAvoidClashAtCoordination: markerGroup.coordinate, circleDistanceDelta: mapView.edgesDistance()/100)
                })
            }
            
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if shouldJumpToStartLocation {
            let user = map.userLocation
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let mapRegion = MKCoordinateRegion(center: user.coordinate, span: span)
            map.setRegion(mapRegion, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        if shouldJumpToStartLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let mapRegion = MKCoordinateRegion(center: fallbackStartLocationCoordinate, span: span)
            map.setRegion(mapRegion, animated: true)
        }
    }
    
    
    //MARK: - Location Services
    
    func isLocationMonitoringAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .AuthorizedAlways || status == .AuthorizedWhenInUse
    }
    
    let locationManager = CLLocationManager()
    
    func beginTrackingLocation() {
        locationManager.delegate = self
//        man.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.NotDetermined {
            //NEVER ASKED
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
        else if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            //GRANTED
            map.showsUserLocation = true
            
        } else if status == .Restricted {
            //RESTRICTED
            //TODO: Hide "show me" button
            
        } else if status == .Denied {
            //DENIED
            //TODO: Set a "denied" alert for when tapping "show me" button
        }
    }

    //MARK: - Date selection delegate
    func dateSelectionViewController(vc: RMDateSelectionViewController!, didSelectDate aDate: NSDate!) {
        if dateSelectionType == .Start {
            filter.startDate = aDate
        } else {
            filter.endDate = aDate
        }
        tableView?.reloadData()
        openTableView(.Filter)
    }
    func dateSelectionViewControllerDidCancel(vc: RMDateSelectionViewController!) {
        openTableView(.Filter)
    }
    
    
}

