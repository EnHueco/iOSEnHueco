//
//  ProfileViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import LocalAuthentication
import MobileCoreServices

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editScheduleButton: UIButton!
    @IBOutlet weak var myQRButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    override func viewDidLoad()
    {
        editScheduleButton.backgroundColor = EHIntefaceColor.defaultBigRoundedButtonsColor
        myQRButton.backgroundColor = EHIntefaceColor.defaultBigRoundedButtonsColor
        
        firstNamesLabel.text = system.appUser.firstNames
        lastNamesLabel.text = system.appUser.lastNames
//        usernameLabel.text = system.appUser.username
        
        backgroundImageView.alpha = 0
        imageImageView.alpha = 0

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appUserRefreshed:"), name: EHSystemNotification.SystemDidReceiveAppUserImage, object: system)
        
        self.assignImages()

    }
    
    func assignImages()
    {
        dispatch_async(dispatch_get_main_queue())
            {
                if let image = ImagePersistenceManager.loadImageFromPath(ImagePersistenceManager.fileInDocumentsDirectory("profile.jpg"))
                {
                    self.imageImageView.hidden = false
                    self.backgroundImageView.hidden = false
                    
                    
                    if(self.imageImageView.image != nil)
                    {
                        UIView.transitionWithView(self.imageImageView,
                            duration:1,
                            options: UIViewAnimationOptions.TransitionFlipFromTop,
                            animations: { self.imageImageView.image = image },
                            completion: nil)
                    }
                    else
                    {
                        self.imageImageView.image = image
                        
                        UIView.animateWithDuration(0.4)
                        {
                            self.imageImageView.alpha = 1
                        }
                    }
      
                    if self.backgroundImageView.image != nil
                    {
                        UIView.transitionWithView(self.backgroundImageView,
                            duration:1, options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.backgroundImageView.image = image.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                                self.backgroundImageView.alpha = 1
                            },completion: nil)
                    }
                    else
                    {
                        self.backgroundImageView.image = image
                        UIView.animateWithDuration(0.4)
                            {
                                self.backgroundImageView.image = self.backgroundImageView.image?.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                                self.backgroundImageView.alpha = 1
                        }
                    }
                }
                else
                {
                    self.imageImageView.hidden = true
                    self.backgroundImageView.hidden = true
                }
                
                self.imageImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.clipsToBounds = true
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = editScheduleButton.frame.height/2
        myQRButton.clipsToBounds = true
        myQRButton.layer.cornerRadius = myQRButton.frame.height/2
        
        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
      
        system.appUser.fetchAppUser()
        system.appUser.fetchUpdatesForAppUserAndSchedule()
    }
    
    override func viewDidAppear(animated: Bool)
    {
//        super.viewDidAppear(animated)
//        
//        if let imageURL = system.appUser.imageURL
//        {
//            imageImageView.hidden = false
//            backgroundImageView.hidden = false
//            
//            imageImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
//                
//                if error == nil
//                {
//                    UIView.animateWithDuration(0.4)
//                    {
//                        self.imageImageView.alpha = 1
//                    }
//                }
//                else
//                {
//                    print(error)
//                }
//            })
//
//            backgroundImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
//                
//                if error == nil
//                {
//                    UIView.animateWithDuration(0.4)
//                    {
//                        self.backgroundImageView.image = self.backgroundImageView.image?.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
//                        self.backgroundImageView.alpha = 1
//                    }
//                }
//            })
//
//        }
//        else
//        {
//            imageImageView.hidden = true
//            backgroundImageView.hidden = true
//        }

    }
        
    
    @IBAction func myQRButtonPressed(sender: AnyObject)
    {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("ViewQRViewController") as! ViewQRViewController
        
        viewController.view.backgroundColor = UIColor.clearColor()
        
        providesPresentationContextTransitionStyle = true
        viewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton)
    {
        if NSUserDefaults.standardUserDefaults().boolForKey("authTouchID")
        {
            authenticateUser()
        }
        else
        {
            showSettings()            
        }

    }
    
    private func showSettings()
    {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("SettingsTableViewController") as! SettingsTableViewController
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    
    
    enum LAError : Int {
        case AuthenticationFailed
        case UserCancel
        case UserFallback
        case SystemCancel
        case PasscodeNotSet
        case TouchIDNotAvailable
        case TouchIDNotEnrolled
    }
    
    func authenticateUser()
    {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access your settings."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.showSettings()
                    })
                }
                else{
                    //                    println(evalPolicyError?.localizedDescription)
                    switch evalPolicyError!.code
                    {
                        case LAError.SystemCancel.rawValue:
                            break
                        case LAError.UserCancel.rawValue:
                            break
                        case LAError.UserFallback.rawValue:
                            break
                        //                        println("User selected to enter custom password")
                        //                        self.showPasswordAlert()
                        default:
                            break
                        //                        println("Authentication failed")
                        //                        self.showPasswordAlert()
                    }
                }
            })
        }
        else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                break
                
            case LAError.PasscodeNotSet.rawValue:
                break
                
            default:
                break
                // The LAError.TouchIDNotAvailable case.
            }
            
            //            println(error?.localizedDescription)
            
            // Allow users to enter the password.
            //            self.showPasswordAlert()
        }
    }
    @IBAction func imageViewClicked(sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        
        self.presentViewController(imagePicker, animated: true,
            completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        system.appUser.pushProfilePicture(image)
    }
    
    func appUserRefreshed(notification: NSNotification)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.assignImages()
        }
    }
}
