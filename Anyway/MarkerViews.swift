//
//  MarkerViews.swift
//  Anyway
//
//  Created by Aviel Gross on 9/1/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import Foundation

let markerReuseIdentifierDefault = "MarkerIdentifier"
let markerGroupReuseIdentifierDefault = "MarkerGroupIdentifier"
let clusterReuseIdentifierDefault = "ClusterIdentifier"


//MARK: - Views

class MarkerView: MKPinAnnotationView {
    
    convenience init(marker: Marker, reuseIdentifier: String! = markerReuseIdentifierDefault) {
        self.init(annotation: marker, reuseIdentifier: reuseIdentifier)
        enabled = true
        canShowCallout = true
        if let name = marker.iconName {
            image = UIImage(named: name) //TODO fallback?
        }
        rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        //        leftCalloutAccessoryView
    }
    
}

class MarkerGroupView: MKPinAnnotationView {
    
    convenience init(markerGroup: MarkerGroup, reuseIdentifier: String! = markerGroupReuseIdentifierDefault) {
        self.init(annotation: markerGroup, reuseIdentifier: reuseIdentifier)
        enabled = true
        canShowCallout = true
        
        //        self.pinColor = MKPinAnnotationColor.Green
        if let name = markerGroup.iconName {
            image = UIImage(named: name) //TODO fallback?
        }
        //rightCalloutAccessoryView
        //leftCalloutAccessoryView
    }
    
}

class ClusterView: MKAnnotationView {
    
    var label: UILabel?
    var backImage: UIImageView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let aLabel = UILabel(frame: CGRect(origin: CGPointZero, size: CGSizeMake(30, 30)))
        aLabel.textAlignment = .Center
        aLabel.font = UIFont.systemFontOfSize(14)
        //        aLabel.backgroundColor = UIColor.whiteColor()
        //        aLabel.layer.borderColor = UIColor.grayColor().CGColor
        //        aLabel.layer.borderWidth = 0.5
        //        aLabel.layer.cornerRadius = aLabel.frame.width / 2
        //        aLabel.layer.masksToBounds = true
        
        
        let anImage = UIImageView(image: UIImage(named: "cluster_1")!)
        if let cluster = annotation as? OCAnnotation {
            anImage.image = clusterImageForClusterCount(cluster.annotationsInCluster().count)
        }
        anImage.frame.size = CGSizeMake(30, 30)
        
        
        label = aLabel
        backImage = anImage
        addSubview(backImage!)
        addSubview(label!)
    }
    
    func clusterImageForClusterCount(count: Int) -> UIImage {
        switch count {
        case let x where x < 10: return UIImage(named: "cluster_1")!
        case let x where x < 50: return UIImage(named: "cluster_2")!
        case let x where x < 100: return UIImage(named: "cluster_3")!
        default: return UIImage(named: "cluster_4")!
        }
    }
    
}