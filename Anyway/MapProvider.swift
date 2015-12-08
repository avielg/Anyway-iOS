//
//  MapProvider.swift
//  Anyway
//
//  Created by Aviel Gross on 2/16/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation
import MapKit
import Alamofire
import SwiftyJSON

let MAX_DIST_OF_MAP_EDGES = 10000
let MIN_DIST_CLUSTER_DISABLE = 1000

typealias Edges = (ne: Coordinate, sw: Coordinate)

extension MKMapView {
    func edgePoints() -> Edges {
        let nePoint = CGPoint(x: self.bounds.maxX, y: self.bounds.origin.y)
        let swPoint = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let neCoord = self.convertPoint(nePoint, toCoordinateFromView: self)
        let swCoord = self.convertPoint(swPoint, toCoordinateFromView: self)
        return (ne: neCoord, sw: swCoord)
    }
    
    func edgesDistance() -> CLLocationDistance {
        let edges = self.edgePoints()
        return CLLocation.distance(from: edges.sw, to: edges.ne)
    }
}

extension CLLocation {
    // In meteres
    class func distance(from from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distanceFromLocation(to)
    }
}

class Network {
    
    var currentRequest: Request? = nil
    
    func cancelRequestIfNeeded() {
        if let current = currentRequest { current.cancel() }
    }
    
    func getMarkerDetails(markerId id: Int, result:([Person], [Vehicle])->Void) {
        
        let domain = "http://www.anyway.co.il/markers/"
        let url = "\(domain)\(id)"
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let response = { (req: NSURLRequest, response: NSHTTPURLResponse?, json: JSON, err: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("getMarkerDetails response from server ended")
            
            if err == nil {
                var persons = [Person]()
                var vehicles = [Vehicle]()
                
                for obj in json.array ?? [] {
                    if obj["sex"].number != nil {
                        persons.append(Person(json: obj, index: persons.count + 1))
                    } else {
                        vehicles.append(Vehicle(json: obj, index: vehicles.count + 1))
                    }
                }
                
                result(persons, vehicles)
                
            } else {
                print("Error! \(err)")
                result([], [])
            }
        }
        
        
        currentRequest = Alamofire.request(.GET, url, parameters: nil, encoding: .URL, headers: nil).responseSwiftyJSON(response)
        
    }
    
    func getAnnotations(edges: Edges, filter: Filter, anots: (markers: [MarkerAnnotation], totalCount: Int)->()) {
        
        let ne_lat = edges.ne.latitude // 32.158091269627874
        let ne_lng = edges.ne.longitude // 34.88087036877948
        let sw_lat = edges.sw.latitude // 32.146882347101766
        let sw_lng = edges.sw.longitude // 34.858318355382266
        let zoom = 16
        let thinMarkers = true
        let startDate = Int(filter.startDate.timeIntervalSince1970)
        let endDate = Int(filter.endDate.timeIntervalSince1970)
        let showFatal = filter.showFatal ? 1 : 0
        let showSevere = filter.showSevere ? 1 : 0
        let showLight = filter.showLight ? 1 : 0
        let showInaccurate = filter.showInaccurate ? 1 : 0
        
        print("Fetching with filter:\n\(filter.description)")
        
        let params: [String : AnyObject] = [
            "ne_lat" : ne_lat,
            "ne_lng" : ne_lng,
            "sw_lat" : sw_lat,
            "sw_lng" : sw_lng,
            "zoom"   : zoom,
            "thin_markers" : thinMarkers,
            "start_date"   : startDate,
            "end_date"     : endDate,
            "show_fatal"   : showFatal,
            "show_severe"  : showSevere,
            "show_light"   : showLight,
            "show_inaccurate" : showInaccurate,
            "show_markers" : 1,
            "show_discussions" : 1
        ]
        
        //print("params: \(params)")
        
        cancelRequestIfNeeded()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let response = { (req: NSURLRequest, response: NSHTTPURLResponse?, json: JSON, err: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("getAnnotations response from server ended")
            
            if err == nil {
                let markers = self.parseJson(json)
                
                //Sometimes multiple markers would have the exact same coordinate.
                //This method would arrange the identical markers in a circle around the coordinate.
                //AnnotationCoordinateUtility.mutateCoordinatesOfClashingAnnotations(markers)
                print("markers:\(markers.count)")
                let finalMarkers = self.groupMarkersWithColidingCoordinates(markers)
                
                anots(markers: finalMarkers, totalCount: markers.count)
            } else {
                print("Error! \(err)")
                anots(markers: [], totalCount: 0)
            }
        }
        
        
        currentRequest = Alamofire.request(.GET, "http://www.anyway.co.il/markers", parameters: params, encoding: .URL, headers: nil)
            
            /* Raw response, for debug */
//            .responseString(completionHandler: { (response) -> Void in
//                switch response.result {
//                case .Success(let val):
//                    if let encoded = response.data.map({ String(data: $0, encoding: NSUTF8StringEncoding) }) {
//                        println("response: ###\(encoded)###") //solve hebrew string bug...
//                    } else {
//                        println("response: ###\(val)###")
//                    }
//                case .Failure(let err): println("error: \(err)")
//                }
//            })
            
            /* JSON+Alamofire */
            .responseSwiftyJSON(response)
        
    }
    
    /*
        Checking for coliding Marker group and creating MarkerGroup for them
    */
    private func groupMarkersWithColidingCoordinates(markers: [Marker]) -> [MarkerAnnotation] {
        
        var markerAnnotations = [MarkerAnnotation]()
        
        let annotsDict = AnnotationCoordinateUtility.groupAnnotationsByLocationValue(markers) as! [NSValue:[Marker]]
        for (_ /* coordVal */, annotsAtLocation) in annotsDict {
            if annotsAtLocation.count > 1 {
                let group = MarkerGroup(markers: annotsAtLocation)!
                //print("Added markerGroup of \(group.markers.count) markers at \(coordVal)")
                markerAnnotations.append(group)
            } else {
                markerAnnotations.append(annotsAtLocation.first!)
            }
        }
        
        return markerAnnotations
    }
    
    /*
        Parsing server JSON response to [Marker], ignoring coliding markers
    */
    private func parseJson(json: JSON) -> [Marker] {

        var annots = [Marker]()
        
        if let markers = json["markers"].array {
            
            for marker in markers {

                let lat = marker["latitude"].number!.doubleValue
                let lng = marker["longitude"].number!.doubleValue
                let coord = CLLocationCoordinate2DMake(lat, lng)
                
                let address = marker["address"].string ?? ""
                let content = marker["description"].string ?? ""
                let title = marker["title"].string ?? ""
                
                let created: NSDate = {
                    if let createdRaw = marker["created"].string {
                        let form = NSDateFormatter()
                        form.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        return form.dateFromString(createdRaw) ?? NSDate(timeIntervalSince1970: 0)
                    }
                    return NSDate(timeIntervalSince1970: 0)
                }()
                
                let id = Int(marker["id"].string ?? "") ?? 0
                let accuracy = marker["locationAccuracy"].number ?? 0
                let severity = marker["severity"].number ?? 0
                let subtype = marker["subtype"].number ?? 0
                let type = marker["type"].number ?? 0
                
                let mView = Marker(coord: coord, address: address, content: content, title: title, created: created, id: id, accuracy: accuracy.integerValue, severity: severity.integerValue, subtype: subtype.integerValue, type: type.integerValue)
                
                mView.roadShape = marker["roadShape"].intValue
                mView.cross_mode = marker["cross_mode"].intValue
                mView.secondaryStreet = marker["secondaryStreet"].stringValue
                mView.cross_location = marker["cross_location"].intValue
                mView.one_lane = marker["one_lane"].intValue
                mView.speed_limit = marker["speed_limit"].intValue
                mView.weather = marker["weather"].intValue
                mView.provider_code = marker["provider_code"].intValue
                mView.road_object = marker["road_object"].intValue
                mView.didnt_cross = marker["didnt_cross"].intValue
                mView.object_distance = marker["object_distance"].intValue
                mView.road_sign = marker["road_sign"].intValue
                mView.intactness = marker["intactness"].intValue
                mView.junction = marker["secondaryStreet"].stringValue
                mView.road_control = marker["road_control"].intValue
                mView.road_light = marker["road_light"].intValue
                mView.multi_lane = marker["multi_lane"].intValue
                mView.dayType = marker["dayType"].intValue
                mView.unit = marker["unit"].intValue
                mView.road_width = marker["road_width"].intValue
                mView.cross_direction = marker["cross_direction"].intValue
                mView.roadType = marker["roadType"].intValue
                mView.road_surface = marker["road_surface"].intValue
                mView.mainStreet = marker["secondaryStreet"].stringValue
                
                
                annots.append(mView)
            }
            
        }
        
        return annots
    }
}




