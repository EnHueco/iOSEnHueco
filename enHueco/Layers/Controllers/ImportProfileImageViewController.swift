//
//  ImportProfileImageViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 1/1/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import RSKImageCropper
import MobileCoreServices

class ImportProfileImageViewController: UIViewController, UINavigationControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func importFromCameraRollButtonPressed(sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func importFromFacebookButtonPressed(sender: UIButton)
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            if !result.isCancelled
            {
                //We are logged into Facebook
                
                FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields":"url", "width":"500", "redirect":"false"], HTTPMethod: "GET").startWithCompletionHandler() { (_, result, error) -> Void in
                    
                    guard let data = result["data"],
                          let imageURL = data?["url"] as? String,
                          let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!),
                          let image = UIImage(data: imageData)
                        where error == nil
                    else
                    {
                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }
                    
                    let imageCropVC = RSKImageCropViewController(image: image)
                    imageCropVC.delegate = self
                    self.presentViewController(imageCropVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func goToMainTabViewController()
    {
        ProximityUpdatesManager.sharedManager().beginProximityUpdates()
        presentViewController(storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController"), animated: true, completion: nil)
    }
}

extension ImportProfileImageViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String:AnyObject]?)
    {
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.presentViewController(imageCropVC, animated: true, completion: nil)
    }
}

extension ImportProfileImageViewController: RSKImageCropViewControllerDelegate
{
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect)
    {
        AppUserInformationManager.sharedManager().pushProfilePicture(croppedImage) { success, error in
            
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            self.goToMainTabViewController()
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
