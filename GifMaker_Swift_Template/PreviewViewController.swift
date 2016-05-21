//
//  PreviewViewController.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/16/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var gif: Gif!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifImageView.image = gif.gifImage
    }
    
    @IBAction func shareGif(sender: AnyObject) {
        let animatedGif = NSData(contentsOfURL: gif.url)!
        let itemsToShare = [animatedGif]
        let shareController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        shareController.completionWithItemsHandler = {activityType, completed, returnedItems, activityError in
            if completed {
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        presentViewController(shareController, animated: true, completion: nil)
    }
    
}
