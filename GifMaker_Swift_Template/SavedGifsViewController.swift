//
//  SavedGifsViewController.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/27/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import UIKit

class SavedGifsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyView: UIStackView!
    
    private var gifs = [Gif]()
    let cellMargin: CGFloat = 8.0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        gifs = (UIApplication.sharedApplication().delegate as! AppDelegate).savedGifs
        emptyView.hidden = gifs.count > 0
        collectionView.reloadData()
    }
    
}

extension SavedGifsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GifCell", forIndexPath: indexPath) as! GifCell
        let gif = gifs[indexPath.row]
        cell.configureForGif(gif)
        return cell
    }
    
}

extension SavedGifsViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

extension SavedGifsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - cellMargin * 3.0)/2
        return CGSizeMake(width, width)
    }
    
}
