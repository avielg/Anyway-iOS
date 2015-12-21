//
//  ViewController+MapView.swift
//  Anyway
//
//  Created by Aviel Gross on 14/12/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

extension ViewController: MKMapViewDelegate {
    
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
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        network.cancelRequestIfNeeded()
        
        if hud.visible {
            hud.dismissAnimated(false)
        }
        
        if mapViewRegionDidChangeFromUserInteraction() {
            shouldJumpToStartLocation = false
        }
    }
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let markerView = view as? MarkerView {
            
            guard let dest = storyboard?.instantiateViewControllerWithIdentifier(DetailViewController.storyboardId) as? DetailViewController
                else {return}
            
            guard let marker = markerView.annotation as? Marker
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
            shouldJumpToStartLocation = false
            let user = map.userLocation
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let mapRegion = MKCoordinateRegion(center: user.coordinate, span: span)
            map.setRegion(mapRegion, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        if shouldJumpToStartLocation {
            shouldJumpToStartLocation = false
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let mapRegion = MKCoordinateRegion(center: fallbackStartLocationCoordinate, span: span)
            map.setRegion(mapRegion, animated: true)
        }
    }
}