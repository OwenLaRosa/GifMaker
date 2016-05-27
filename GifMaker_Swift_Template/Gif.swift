//
//  Gif.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/17/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class Gif: NSObject, NSCoding {
    
    private struct Keys {
        static let url = "url"
        static let caption = "caption"
        static let gifImage = "gifImage"
        static let rawVideoURL = "rawVideoURL"
    }
    
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
    
    required init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decodeObjectForKey(Keys.url) as! NSURL
        self.caption = aDecoder.decodeObjectForKey(Keys.caption) as! String
        self.gifImage = aDecoder.decodeObjectForKey(Keys.gifImage) as! UIImage
        self.rawVideoURL = aDecoder.decodeObjectForKey(Keys.rawVideoURL) as! NSURL
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url, forKey: Keys.url)
        aCoder.encodeObject(caption, forKey: Keys.caption)
        aCoder.encodeObject(gifImage, forKey: Keys.gifImage)
        aCoder.encodeObject(rawVideoURL, forKey: Keys.rawVideoURL)
    }
    
}
