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

func *(l: CGSize, r: Int) -> CGSize {
    return CGSize(width: l.width * CGFloat(r), height: l.height * CGFloat(r))
}

func *(l: CGRect, r: Int) -> CGRect {
    return CGRect(origin: l.origin, size: l.size * r)
}



//MARK: - Views

/**
 Represents a view with:
    - A big pin
    - An icon on top of it
    - White circular background view for the icon.
    
 Used in the markers on the map ('MarkerView' and
 'MaarkerGroupView' only, not clusters)
*/
class IconPinView: UIView {

    /**
     Should always be called after 'init'!
     
     - parameter alpha: the expected alpha for the view
     */
    func setup(alpha: CGFloat = 1.0) {
        guard let img = UIImage(named: "ic_loupe")
            else { assertionFailure("no img"); return }
        
        // main pin
        let back = UIImageView(image: img)
        self.frame = back.frame
        back.transform = CGAffineTransformMakeRotation(CGFloat(45.0 * (M_PI/180)))
        
        // white back view
        let mainPinVisibleDiameter = CGFloat(35)
        let size = CGSize(squareSide: mainPinVisibleDiameter)
        let v = UIView(frame: CGRect(origin: CGPointZero, size: size))
        v.backgroundColor = UIColor(white: 1, alpha: alpha * 1.5)
        v.layer.cornerRadius = v.frame.width / 2 //make it circle
        v.layer.masksToBounds = true
        v.center.x = center.x //position it
        v.center.y = frame.width / 2
        
        // add the views to self (the container view)
        addSubview(v)
        addSubview(back)
    }
    
    /**
     Add an icon to the pin. Does not
     override any existing icon (will
     add it on top).
     
     - parameter icon: the icon to add
     */
    func insertIcon(icon: UIImage) {
        
        // icon
        let iv = UIImageView(image: icon)
        iv.center.x = center.x
        iv.center.y = frame.width / 2
        
        addSubview(iv)
    }
    
    /// Will be the icon and the pin tint color
    var color: UIColor = UIApplication.sharedApplication().delegate?.window??.tintColor ?? UIColor.blackColor() {
        didSet {
            // whenever the color changes > change
            //  the tint for any subview
            for i in subviews.flatMap({ $0 as? UIImageView }) {
                i.tintColor = color
            }
        }
    }
    
}

extension MKAnnotationView {
    /// Setup Icon
    func setupIcon(marker: VisualMarker, color: UIColor) {
        
        // make the pin
        let iconPin = IconPinView(frame: frame)
        
        // setup with the marker color
        var alpha: CGFloat = 0
        var white: CGFloat = 0
        color.getWhite(&white, alpha: &alpha)
        iconPin.setup(alpha)
        
        // add the icon
        if let
            name = marker.iconName,
            img = UIImage(named: name) {
                iconPin.insertIcon(img)
        }
        iconPin.color = color
        frame = iconPin.frame
        addSubview(iconPin)
    }
}

/**
 A view for a single marker, representing
 a single accident.
*/
class MarkerView: MKAnnotationView {
    
    convenience init(marker: Marker, reuseIdentifier: String! = markerReuseIdentifierDefault) {
        self.init(annotation: marker, reuseIdentifier: reuseIdentifier)
        
        enabled = true
        canShowCallout = true
        
        rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        
        let c: UIColor
        switch marker.severity {
        case 1: c = Color.red
        case 2: c = Color.orange
        case 3: c = Color.yellow
        default: c = Color.blue //should never happen
        }
        
        setupIcon(marker, color: c)
    }
    
}

/**
 A view for a group of markers, representing
 multiple accidents that share the same coordinates.
 */
class MarkerGroupView: MKAnnotationView {

    convenience init(markerGroup: MarkerGroup, reuseIdentifier: String! = markerGroupReuseIdentifierDefault) {
        self.init(annotation: markerGroup, reuseIdentifier: reuseIdentifier)
        
        enabled = true
        canShowCallout = true
        
        // groups are half-transperent per website design
        let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        setupIcon(markerGroup, color: color)
    }
    
}

/**
 A view for a for a cluster of
 accidents, representing accidents
 that happened in a certain area.
 */
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
        let size = CGSize(squareSide: 30)
        
        // the label for the number
        
        let aLabel = UILabel(frame: CGRect(origin: CGPointZero, size: size))
        aLabel.textAlignment = .Center
        aLabel.font = UIFont.systemFontOfSize(14)
        
        // the background/border image
        let anImage = UIImageView(image: UIImage(named: "cluster_1")!)
        if let cluster = annotation as? OCAnnotation {
            let numOfAccidents = cluster.annotationsInCluster().count
            anImage.image = clusterImageForClusterCount(numOfAccidents)
        }
        anImage.frame.size = size
        
        // keep references
        label = aLabel
        backImage = anImage
        
        // add subviews to self
        addSubview(backImage!)
        addSubview(label!)
    }
    
    /**
     Backgound image suitable for the size
     of the cluster. Bigger clusters have
     "bolder" borders...
     
     - parameter count: amnt of accidents in cluster
     
     - returns: an image for the cluster background
     */
    func clusterImageForClusterCount(count: Int) -> UIImage {
        switch count {
        case let x where x < 10: return UIImage(named: "cluster_1")!
        case let x where x < 50: return UIImage(named: "cluster_2")!
        case let x where x < 100: return UIImage(named: "cluster_3")!
        default: return UIImage(named: "cluster_4")!
        }
    }
    
}