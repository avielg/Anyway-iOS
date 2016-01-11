//
//  ViewController+MapView.swift
//  Anyway
//
//  Created by Aviel Gross on 14/12/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

/**
 Handling the map view - populating markers
 and dealing with events on the map (touching
 markers, draggin the map etc.)
*/
extension ViewController: MKMapViewDelegate {
    
    /**
     Figure out wether the map was moved due
     to user interaction or not.
     */
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        if let view = map.subviews.first {
            for gesture in view.gestureRecognizers ?? [] {
                if gesture.state == .Began || gesture.state == .Ended {
                    return true
                }
            }
        }
        return false
    }
    
    /**
     The map's region was changed somehow - 
     wether due to user interaction ot not....
     */
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        map.clusteringEnabled = Int(mapView.edgesDistance()) > MIN_DIST_CLUSTER_DISABLE
        
        printFunc()
        print("old region: \(lastRegion.center) | new: \(mapView.region.center)")
        
        let distance = CLLocation.distance(from: lastRegion.center, to: mapView.region.center)
        print("distance: \(distance)")
        
        if distance > 50 {
            updateInfoIfPossible(mapView, filterChanged:false)
        }
        lastRegion = mapView.region
    }
    
    /**
     The map region is about to change
     */
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        network.cancelRequestIfNeeded()
        
        if hud.visible {
            hud.dismissAnimated(false)
        }
        
        if mapViewRegionDidChangeFromUserInteraction() {
            shouldJumpToStartLocation = false
        }
    }
    
    /**
     Called for every 'annotation' (marker) before it is
     about to be rendered on the screen.
     
     - returns: the view representing the marker
     */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    /**
     Handling the event of user taps on the callout (usually the
     "bubble" that pops).
     Opens the screen to show more details about the accident.
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let sbID = DetailViewController.storyboardId
        
        guard let
            markerView = view as? MarkerView,
            dest = storyboard?.instantiateViewControllerWithIdentifier(sbID) as? DetailViewController,
            marker = markerView.annotation as? Marker
        else {return}
        
        dest.detailData = marker
        
        if let
            nav = splitViewController?.viewControllers.safeRetrieveElement(1) as? UINavigationController,
            first = nav.viewControllers.first
        {
            nav.setViewControllers([first, dest], animated: true)
        } else {
            showDetailViewController(dest, sender: self)
        }
    }
    
    /**
     Handles the event of user selecting an annotation.
     
     For a single marker: presents a "bubble" callout 
      view with few words about the accident (this
      one is done automatically by MKMapView).
     
     For marker group: animates spreading the group
     into a circle of single markers.
     */
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        // handle a marker group
        if let groupView = view as? MarkerGroupView {
            
            // remove the center, "fake", annotation
            if let ann = view.annotation {
                mapView.removeAnnotation(ann)
            }
            
            let markerGroup = groupView.annotation as! MarkerGroup
            let markers = markerGroup.markers
            if map.annotationsToIgnore == nil {
                map.annotationsToIgnore = NSMutableSet()
            }
            map.annotationsToIgnore.addObjectsFromArray(markers)
            
            let addMarkers = {
                mapView.addAnnotations(markers)
            }
            
            // animate the new markers
            UIView.animateWithDuration(0, animations:addMarkers) { _ in
                UIView.animateWithDuration(0.25, animations: {
                    let cord = markerGroup.coordinate
                    let delta = mapView.edgesDistance()/100
                    AnnotationCoordinateUtility.repositionAnnotations(markers,
                        toAvoidClashAtCoordination: cord, circleDistanceDelta: delta)
                })
            }
            
        }
    }
    
    /**
     When the user location was updated and the
     new location is visible on the map.
     
     If the app was just launched and the user
     has yet to move the map, we zoom the map
     to the user's location.
     */
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if shouldJumpToStartLocation {
            shouldJumpToStartLocation = false
            map.moveAndZoom(to: map.userLocation.coordinate)
        }
    }
    
    /**
     Error fallback when the map fails to locate
     the user location.
     
     If the app was just launched and the user
     has yet to move the map, we zoom the map
     to the a default location.
     */
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        if shouldJumpToStartLocation {
            shouldJumpToStartLocation = false
            map.moveAndZoom(to: fallbackStartLocationCoordinate)
        }
    }
}

/**
 This extension use is very specific for this screen
 behavior and is therefore declared as 'private'.
*/
private extension MKMapView {
    func moveAndZoom(to coord: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegion(center: coord, span: span)
        setRegion(mapRegion, animated: true)
    }
}

