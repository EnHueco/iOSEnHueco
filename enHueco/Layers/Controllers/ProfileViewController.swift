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

class ProfileViewController: UIViewController
{
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editScheduleButton: UIButton!
    @IBOutlet weak var myQRButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var imageIndicator: UIActivityIndicatorView? = nil

    override func viewDidLoad()
    {
        editScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        myQRButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        firstNamesLabel.text = enHueco.appUser.firstNames
        lastNamesLabel.text = enHueco.appUser.lastNames

        backgroundImageView.alpha = 0
        imageImageView.alpha = 0
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = editScheduleButton.frame.height / 2
        myQRButton.clipsToBounds = true
        myQRButton.layer.cornerRadius = myQRButton.frame.height / 2

        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height / 2
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        AppUserInformationManager.sharedManager().fetchAppUser()
        AppUserInformationManager.sharedManager().fetchUpdatesForAppUserAndSchedule()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        assignImages()
    }
    
    func updateButtonColors()
    {
        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFromImage: imageImageView.image), isFlat: true, alpha: 0.4)
        
        UIView.animateWithDuration(0.8)
        {
            self.editScheduleButton.backgroundColor = averageImageColor
            self.myQRButton.backgroundColor = averageImageColor
        }
    }

    func startAnimatingImageLoadingIndicator()
    {
        if imageIndicator == nil
        {
            imageIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            imageIndicator!.center = imageImageView.center
            view.addSubview(imageIndicator!)
        }

        if !imageIndicator!.isAnimating()
        {
            imageIndicator!.startAnimating()
        }
    }

    func stopAnimatingImageLoadingIndicator()
    {
        if let imageIndicator = imageIndicator
        {
            if imageIndicator.isAnimating()
            {
                imageIndicator.stopAnimating()
            }
            
            self.imageIndicator!.removeFromSuperview()
            self.imageIndicator = nil
        }
    }

    func assignImages()
    {
        if imageImageView.image == nil
        {
            startAnimatingImageLoadingIndicator()
        }
        
        PersistenceManager.sharedManager().loadImageFromPath(PersistenceManager.sharedManager().documentsPath + "profile.jpg") {(image) -> () in

            dispatch_async(dispatch_get_main_queue())
            {
                var image: UIImage! = image
                
                if image == nil
                {
                    image = UIImage(named: "stripes")
                    
                    AppUserInformationManager.sharedManager().downloadProfilePictureWithCompletionHandler(nil)
                }
                
                self.imageImageView.hidden = false
                self.backgroundImageView.hidden = false
                
                if (self.imageImageView.image != nil)
                {
                    UIView.transitionWithView(self.imageImageView, duration: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        
                        self.imageImageView.image = image
                    }, completion: nil)
                }
                else
                {
                    self.imageImageView.image = image
                    
                    UIView.animateWithDuration(0.4) {
                        self.imageImageView.alpha = 1
                    }
                }
                
                if self.backgroundImageView.image != nil
                {
                    UIView.transitionWithView(self.backgroundImageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                                                
                        self.backgroundImageView.image = image.applyBlurWithRadius(50, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                        self.backgroundImageView.alpha = 1
                        
                    }, completion: nil)
                }
                else
                {
                    self.backgroundImageView.image = image
                    
                    UIView.animateWithDuration(0.4) {
                        
                        self.backgroundImageView.image = self.backgroundImageView.image?.applyBlurWithRadius(50, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                        self.backgroundImageView.alpha = 1
                    }
                }
                
                self.imageImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.contentMode = .ScaleAspectFill
                self.backgroundImageView.clipsToBounds = true
                self.stopAnimatingImageLoadingIndicator()
                
                self.updateButtonColors()
            }
        }
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
        let importPictureController = storyboard?.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
        importPictureController.delegate = self
        
        presentViewController(importPictureController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ImportProfileImageViewControllerDelegate
{
    func importProfileImageViewControllerDidFinishImportingImage(controller: ImportProfileImageViewController)
    {
        assignImages()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func importProfileImageViewControllerDidCancel(controller: ImportProfileImageViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}