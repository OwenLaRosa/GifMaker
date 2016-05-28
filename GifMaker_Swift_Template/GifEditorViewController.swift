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
        navigationItem.rightBarButtonItem?.action = "presentPreview"
        
        let color = UIColor.whiteColor()
        let attributes: [String: AnyObject] = [NSForegroundColorAttributeName:color, NSFontAttributeName:captionTextField.font!, NSStrokeColorAttributeName : UIColor.blackColor(), NSStrokeWidthAttributeName : -4]
        captionTextField.defaultTextAttributes = attributes
        captionTextField.textAlignment = .Center
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
    
    @IBAction func presentPreview() {
        gif.caption = captionTextField.text!
        let regift = Regift(sourceFileURL: gif.rawVideoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount)
        
        let captionFont = captionTextField.font!
        let gifURL = regift.createGif(caption: captionTextField.text!, font: captionFont)
        print(gifURL)
        let newGif = Gif(url: gifURL!, caption: captionTextField.text!, gifImage: UIImage.gifWithURL(String(gifURL!))!, rawVideoURL: gifURL!)
        
        performSegueWithIdentifier("ShowPreview", sender: newGif)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "ShowPreview" {
            let destinationVC = segue.destinationViewController as! PreviewViewController
            destinationVC.gif = sender as! Gif
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
