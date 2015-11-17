//
//  InsetLabel.swift
//  Anyway
//
//  Created by Aviel Gross on 2/24/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    
    @IBInspectable var insetVertical: CGFloat = 8 {
        didSet{
            insets.bottom = insetVertical
            insets.top = insetVertical
        }
    }
    
    @IBInspectable var insetHorizontal: CGFloat = 8 {
        didSet{
            insets.left = insetHorizontal
            insets.right = insetHorizontal
        }
    }
    
    var insets: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    

    override func drawTextInRect(rect: CGRect) {
        return super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRectForBounds(UIEdgeInsetsInsetRect(bounds, insets), limitedToNumberOfLines: numberOfLines)
        
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width  += (insets.left + insets.right);
        rect.size.height += (insets.top + insets.bottom);
        
        return rect
    }
}
