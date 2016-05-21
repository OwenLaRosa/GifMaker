//
//  UIViewController+Record.swift
//  GifMaker_Swift_Template
//
//  Created by Owen LaRosa on 5/16/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

// regift constants
let frameCount = 16 // frames per interval
let delayTime: Float = 0.2 // delay for interval
let loopCount = 0 // loop infinitely

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func presentVideoOptions(sender: AnyObject) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            launchPhotoLibrary()
        } else {
            let actionSheet = UIAlertController(title: "Create new GIF", message: nil, preferredStyle: .ActionSheet)
            let recordVideo = UIAlertAction(title: "Record a Video", style: .Default, handler: { (UIAlertAction) in
                self.launchVideoCamera()
            })
            let chooseFromExisting = UIAlertAction(title: "Choose from Existing", style: .Default, handler: { (UIAlertAction) in
                self.launchPhotoLibrary()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            actionSheet.addAction(recordVideo)
            actionSheet.addAction(chooseFromExisting)
            actionSheet.addAction(cancel)
            
            actionSheet.view.tintColor = UIColor(red: 255.0/255.0, green: 65.0/255.0, blue: 112.0/255.0, alpha: 1.0)
            
            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    func launchVideoCamera() {
        let recordVideoController = UIImagePickerController()
        recordVideoController.sourceType = .Camera
        recordVideoController.mediaTypes = [kUTTypeMovie as String]
        recordVideoController.allowsEditing = false
        recordVideoController.delegate = self
        presentViewController(recordVideoController, animated: true, completion: nil)
    }
    
    func launchPhotoLibrary() {
        let chooseExistingController = UIImagePickerController()
        chooseExistingController.sourceType = .PhotoLibrary
        chooseExistingController.allowsEditing = false
        chooseExistingController.delegate = self
        presentViewController(chooseExistingController, animated: true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == kUTTypeMovie as! String {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            convertVideoToGIF(videoURL)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func convertVideoToGIF(videoURL: NSURL) {
        let regift = Regift(sourceFileURL: videoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        let gifURL = regift.createGif()
        let gifImage = UIImage.gifWithURL(String(gifURL!))!
        let gif = Gif(url: gifURL!, caption: "", gifImage: gifImage, rawVideoURL: videoURL)
        displayGIF(gif)
    }
    
    func displayGIF(gif: Gif) {
        let gifEditorVC = storyboard?.instantiateViewControllerWithIdentifier("GifEditorViewController") as! GifEditorViewController
        gifEditorVC.gif = gif
        navigationController?.pushViewController(gifEditorVC, animated: true)
    }
    
}
