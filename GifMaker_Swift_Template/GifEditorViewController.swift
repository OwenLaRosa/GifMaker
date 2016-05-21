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
    
    @IBOutlet weak var captionTextField: UITextField!
    
    var gif: Gif!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        print("viewWillAppear")
        captionTextField.delegate = self
        gifImageView.image = gif?.gifImage
        
        print(navigationItem.rightBarButtonItem)
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = "showPreview"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrameEndRect = keyboardFrameEnd.CGRectValue()
        return keyboardFrameEndRect.size.height
    }
    
    @IBAction func presentPreview(sender: AnyObject) {
        let previewVC = storyboard?.instantiateViewControllerWithIdentifier("GifPreviewViewController") as! PreviewViewController
        gif.caption = captionTextField.text!
        let regift = Regift(sourceFileURL: gif.rawVideoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        
        let captionFont = captionTextField.font!
        let gifURL = regift.createGifWithCaption(captionTextField.text!, font: captionFont)
        let newGif = Gif(url: gifURL!, caption: captionTextField.text!, gifImage: UIImage.gifWithURL(String(gifURL))!, rawVideoURL: gifURL!)
        
        // TODO: assign the gif to preview view
        
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func showPreview() {
        print("showPreview")
        performSegueWithIdentifier("ShowPreview", sender: gif)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "ShowPreview" {
            let destinationVC = segue.destinationViewController as! PreviewViewController
            destinationVC.gif = gif
        }
    }
    
}

extension GifEditorViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.placeholder = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
