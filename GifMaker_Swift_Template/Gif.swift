//
//  Gif.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/17/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class Gif {
    
    let url: NSURL
    var caption: String
    let gifImage: UIImage
    let rawVideoURL: NSURL
    
    init(url: NSURL, caption: String, gifImage: UIImage, rawVideoURL: NSURL) {
        self.url = url
        self.caption = caption
        self.gifImage = gifImage
        self.rawVideoURL = rawVideoURL
    }
    
}
