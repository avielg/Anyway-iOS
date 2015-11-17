//
//  InfoViewController.swift
//  Anyway
//
//  Created by Aviel Gross on 4/27/15.
//  Copyright (c) 2015 Hasadna. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoLabelText: UILabel! {
        didSet{
            infoLabelText.text = infoLabelText.text?.stringByForcingWritingDirectionRTL()
        }
    }
    
    @IBAction func dismissAction() {
        dismissViewControllerAnimated(true) { }
    }
    
    @IBAction func moroInfoLinkAction() {
        
    }
    
}
