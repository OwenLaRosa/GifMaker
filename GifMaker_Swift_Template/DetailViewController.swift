//
//  DetailViewController.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/27/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    var gif: Gif!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifImageView.image = gif.gifImage
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
