//
//  GifEditorViewController.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/16/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class GifEditorViewController: UIViewController {
    
    @IBOutlet weak var gifImageView: UIImageView!
    var gifURL = NSURL()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        let gif = UIImage.gifWithURL(String(gifURL))
        gifImageView.image = gif
    }
    
}
