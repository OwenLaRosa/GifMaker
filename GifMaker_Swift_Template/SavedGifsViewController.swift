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
    
    let gifsURL = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/savedGifs")
    private var gifs = [Gif]()
    let cellMargin: CGFloat = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showWelcome()
        
        if NSFileManager.defaultManager().fileExistsAtPath(gifsURL) {
            print("unarchiving")
            
            let gifs = NSKeyedUnarchiver.unarchiveObjectWithFile(gifsURL) as! [Gif]
            self.gifs = gifs
            (UIApplication.sharedApplication().delegate as! AppDelegate).savedGifs = gifs
            print(gifs.count)
        }
        
        // set up bottom blur
        let bottomBlur = CAGradientLayer()
        bottomBlur.frame = CGRectMake(0, view.frame.size.height - 100, view.frame.size.width, 100)
        bottomBlur.colors = [UIColor.whiteColor().colorWithAlphaComponent(0.0).CGColor, UIColor.whiteColor().CGColor]
        view.layer.insertSublayer(bottomBlur, above: collectionView.layer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let previousGifCount = gifs.count
        gifs = (UIApplication.sharedApplication().delegate as! AppDelegate).savedGifs
        if previousGifCount != gifs.count {
            print("archiving")
            // a new gif has been added, data should be saved
            NSKeyedArchiver.archiveRootObject(gifs, toFile: gifsURL)
        }
        emptyView.hidden = gifs.count > 0
        collectionView.reloadData()
        
        title = "My Collection"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let destinationVC = segue.destinationViewController as! DetailViewController
            destinationVC.gif = sender as! Gif
        }
    }
    
    func showWelcome() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("WelcomeViewSeen") {
            let welcomeViewController = storyboard?.instantiateViewControllerWithIdentifier("WelcomeViewController") as! WelcomeViewController
            navigationController?.pushViewController(welcomeViewController, animated: true)
        }
    }
    
}

extension SavedGifsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(gifs.count)
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
        let gif = gifs[indexPath.row]
        performSegueWithIdentifier("ShowDetail", sender: gif)
    }
    
}

extension SavedGifsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - cellMargin * 3.0)/2
        return CGSizeMake(width, width)
    }
    
}
