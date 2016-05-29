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
import AVFoundation

// regift constants
let frameCount = 16 // frames per interval
let delayTime: Float = 0.2 // delay for interval
let loopCount = 0 // loop infinitely
let frameRate = 15

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func presentVideoOptions(sender: AnyObject) {
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            launchMediaPicker(.PhotoLibrary)
        } else {
            let actionSheet = UIAlertController(title: "Create new GIF", message: nil, preferredStyle: .ActionSheet)
            let recordVideo = UIAlertAction(title: "Record a Video", style: .Default, handler: { (UIAlertAction) in
                self.launchMediaPicker(.Camera)
            })
            let chooseFromExisting = UIAlertAction(title: "Choose from Existing", style: .Default, handler: { (UIAlertAction) in
                self.launchMediaPicker(.PhotoLibrary)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            actionSheet.addAction(recordVideo)
            actionSheet.addAction(chooseFromExisting)
            actionSheet.addAction(cancel)
            
            actionSheet.view.tintColor = UIColor(red: 255.0/255.0, green: 65.0/255.0, blue: 112.0/255.0, alpha: 1.0)
            
            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }
    
    func launchMediaPicker(sourceType: UIImagePickerControllerSourceType) {
        let mediaPickerController = UIImagePickerController()
        mediaPickerController.sourceType = sourceType
        mediaPickerController.mediaTypes = [kUTTypeMovie as String]
        mediaPickerController.allowsEditing = true
        mediaPickerController.delegate = self
        presentViewController(mediaPickerController, animated: true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        print(info)
        // determine if a start time is supplied and assign its value
        guard let start = info["_UIImagePickerControllerVideoEditingStart"] as? NSNumber else {
            // if not, then the video was not trimmed, start and duration should be nil
            if mediaType == kUTTypeMovie as String {
                let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
                self.convertVideoToGIF(videoURL, start: nil, duration: nil)
                dismissViewControllerAnimated(true, completion: nil)
            }
            return
        }
        guard let end = info["_UIImagePickerControllerVideoEditingEnd"] as? NSNumber else {
            // method will have already returned from failure to assign "start"
            // it's safe to do nothing here
            return
        }
        // calcu;ate the duration and use the value to convert the video
        let duration: Float? = end.floatValue - start.floatValue
        
        if mediaType == kUTTypeMovie as String {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            convertVideoToGIF(videoURL, start: start.floatValue, duration: duration)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func convertVideoToGIF(videoURL: NSURL, start: Float!, duration: Float!) {
        let regift: Regift
        if start == nil {
            regift = Regift(sourceFileURL: videoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        } else {
            regift = Regift(sourceFileURL: videoURL, destinationFileURL: nil, startTime: start, duration: duration, frameRate: frameRate, loopCount: loopCount)
        }
        
        let gifURL = regift.createGif()
        let gifImage = UIImage.gifWithURL(String(gifURL!))!
        let gif = Gif(url: gifURL!, caption: "", gifImage: gifImage, rawVideoURL: videoURL)
        displayGIF(gif)
    }
    
    func makeVideoSquare(rawVideoURL: NSURL, start: NSNumber, duration: NSNumber) {
        let videoAsset = AVAsset(URL: rawVideoURL)
        let composition = AVMutableComposition()
        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer = AVMutableVideoCompositionLayerInstruction()
        let t1 = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2)
        let t2 = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        let finalTransform = t2
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
        exporter.videoComposition = videoComposition
        let path = createPath()
        exporter.outputURL = NSURL(fileURLWithPath: path)
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        
        exporter.exportAsynchronouslyWithCompletionHandler({
            let croppedURL = exporter.outputURL
            self.convertVideoToGIF(croppedURL!, start: start.floatValue, duration: duration.floatValue)
        })
    }
    
    func createPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let manager = NSFileManager.defaultManager()
        var outputURL = "\(documentsDirectory)/output"
        do {
            try manager.createDirectoryAtPath(documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {}
        outputURL += "/output.mov"
        do {
            try manager.removeItemAtPath(outputURL)
        } catch {}
        
        return outputURL
    }
    
    func displayGIF(gif: Gif) {
        let gifEditorVC = storyboard?.instantiateViewControllerWithIdentifier("GifEditorViewController") as! GifEditorViewController
        gifEditorVC.gif = gif
        gifEditorVC.title = "Add Caption"
        navigationController?.pushViewController(gifEditorVC, animated: true)
    }
    
}
