//
//  ProfileViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import LocalAuthentication
import ChameleonFramework

class ProfileViewController: UIViewController, ServerPoller
{
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var editScheduleButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var imageActivityIndicator: UIActivityIndicatorView!
    
    var requestTimer = NSTimer()
    var pollingInterval = 10.0

    override func viewDidLoad()
    {
        editScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        firstNamesLabel.text = enHueco.appUser.firstNames
        lastNamesLabel.text = enHueco.appUser.lastNames
        
        imageActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        view.addSubview(imageActivityIndicator!)
        imageActivityIndicator.autoAlignAxis(.Horizontal, toSameAxisOfView: imageImageView)
        imageActivityIndicator.autoAlignAxis(.Vertical, toSameAxisOfView: imageImageView)
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = editScheduleButton.frame.height / 2

        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height / 2
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        guard !(UIApplication.sharedApplication().delegate as! AppDelegate).loggingOut else { return }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        guard !(UIApplication.sharedApplication().delegate as! AppDelegate).loggingOut else { return }
        
        reportScreenViewToGoogleAnalyticsWithName("Profile")
        startPolling()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        stopPolling()
    }
    
    func updateButtonColors()
    {
        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFromImage: imageImageView.image), isFlat: true, alpha: 0.4)
        
        UIView.animateWithDuration(0.8)
        {
            self.editScheduleButton.backgroundColor = averageImageColor
        }
    }

    func assignImages()
    {
        PersistenceManager.sharedManager.loadImageFromPath(PersistenceManager.sharedManager.documentsPath + "/profile.jpg") {(image) -> () in

            dispatch_async(dispatch_get_main_queue())
            {
                var image: UIImage! = image
                
                if image == nil
                {
                    image = UIImage(named: "stripes")
                }
                
                self.imageImageView.hidden = false
                self.backgroundImageView.hidden = false
                
                UIView.transitionWithView(self.imageImageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    
                    self.imageImageView.image = image
                    
                }, completion: nil)
                
                UIView.transitionWithView(self.backgroundImageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    
                    self.backgroundImageView.image = image.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                    
                }, completion: nil)
                
                self.imageImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.clipsToBounds = true
                self.imageActivityIndicator.stopAnimating()
                
                self.updateButtonColors()
            }
        }
    }
    
    func startPolling()
    {
        requestTimer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: #selector(ProfileViewController.pollFromServer(_:)), userInfo: nil, repeats: true)
        requestTimer.fire()
    }
    
    func pollFromServer(timer: NSTimer)
    {
        if imageImageView.image == nil
        {
            imageActivityIndicator.startAnimating()
        }
        
        AppUserInformationManager.sharedManager.fetchUpdatesForAppUserAndScheduleWithCompletionHandler { success, error in
            
            self.assignImages()
            
            if !success
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
            }
        }
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
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("SettingsNavigationViewController")
        presentViewController(viewController!, animated: true, completion: nil)
    }

    enum LAError: Int
    {
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
        var error: NSError?
        let reasonString = "AuthenticationRequired".localizedUsingGeneralFile()

        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                (success: Bool, evalPolicyError: NSError?) -> Void in

                if success
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.showSettings()
                    }
                }
                else
                {
                    switch evalPolicyError!.code
                    {
                        case LAError.SystemCancel.rawValue:
                            break
                        case LAError.UserCancel.rawValue:
                            break
                        case LAError.UserFallback.rawValue:
                            break
                        default:
                            break
                            //                        println("Authentication failed")
                            //                        self.showPasswordAlert()
                    }
                }
            })
        }
        else
        {
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code
            {
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

    // MARK: Image Handlers

    @IBAction func imageViewClicked(sender: AnyObject)
    {
        definesPresentationContext = true
        
        let importPictureController = storyboard?.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
        importPictureController.delegate = self
        importPictureController.translucent = true
        
        presentViewController(importPictureController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ImportProfileImageViewControllerDelegate
{
    func importProfileImageViewControllerDidFinishImportingImage(controller: ImportProfileImageViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func importProfileImageViewControllerDidCancel(controller: ImportProfileImageViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}