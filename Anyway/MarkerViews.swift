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

class IconPinView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        guard let img = UIImage(named: "ic_loupe")
            else { assertionFailure("no img"); return }
        
        
        let back = UIImageView(image: img)
        self.frame = back.frame
        back.transform = CGAffineTransformMakeRotation(CGFloat(45.0 * (M_PI/180)))
        addSubview(back)
    }
    
    func insertIcon(icon: UIImage) {
        let iv = UIImageView(image: icon)
        iv.center.x = center.x
        iv.center.y = frame.width / 2
        addSubview(iv)
    }
    
    var color: UIColor = UIApplication.sharedApplication().delegate?.window??.tintColor ?? UIColor.blackColor() {
        didSet {
            for i in subviews.flatMap({ $0 as? UIImageView }) {
                i.tintColor = color
            }
        }
    }
    
}

extension MKAnnotationView {
    /// Setup Icon
    func setupIcon(marker: VisualMarker, color: UIColor) {
        let iconPin = IconPinView(frame: frame)
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

class MarkerView: MKAnnotationView {
    
    convenience init(marker: Marker, reuseIdentifier: String! = markerReuseIdentifierDefault) {
        self.init(annotation: marker, reuseIdentifier: reuseIdentifier)
        enabled = true
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        let c: UIColor
        switch marker.severity {
        case 1: c = Color.red
        case 2: c = Color.orange
        case 3: c = Color.yellow
        default: c = Color.blue
        }
        setupIcon(marker, color: c)
    }
    
}

class MarkerGroupView: MKAnnotationView {

    convenience init(markerGroup: MarkerGroup, reuseIdentifier: String! = markerGroupReuseIdentifierDefault) {
        self.init(annotation: markerGroup, reuseIdentifier: reuseIdentifier)
        enabled = true
        canShowCallout = true
        setupIcon(markerGroup, color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3))
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