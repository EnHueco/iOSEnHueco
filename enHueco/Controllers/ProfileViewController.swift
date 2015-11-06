//
//  ProfileViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController
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
        usernameLabel.text = system.appUser.username
        
        backgroundImageView.alpha = 0
        imageImageView.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
        {
            if let imageURL = system.appUser.imageURL
            {
                self.imageImageView.hidden = false
                self.backgroundImageView.hidden = false
                
                self.imageImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
                    
                    if error == nil
                    {
                        UIView.animateWithDuration(0.4)
                        {
                            self.imageImageView.alpha = 1
                        }
                    }
                })
                
                self.backgroundImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
                    
                    if error == nil
                    {
                        UIView.animateWithDuration(0.4)
                        {
                            self.backgroundImageView.image = self.backgroundImageView.image?.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                            self.backgroundImageView.alpha = 1
                        }
                    }
                })
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
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        /*if let imageURL = system.appUser.imageURL
        {
            imageImageView.hidden = false
            backgroundImageView.hidden = false
            
            imageImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
                
                if error == nil
                {
                    UIView.animateWithDuration(0.4)
                    {
                        self.imageImageView.alpha = 1
                    }
                }
            })
            
            backgroundImageView.sd_setImageWithURL(imageURL, completed: { (_, error, _, _) -> Void in
                
                if error == nil
                {
                    UIView.animateWithDuration(0.4)
                    {
                        self.backgroundImageView.image = self.backgroundImageView.image?.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                        self.backgroundImageView.alpha = 1
                    }
                }
            })
        }
        else
        {
            imageImageView.hidden = true
            backgroundImageView.hidden = true
        }*/        
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject)
    {
        system.logOut()
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("MainNavigationController")
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func myQRButtonPressed(sender: AnyObject)
    {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("ViewQRViewController") as! ViewQRViewController
        
        viewController.view.backgroundColor = UIColor.clearColor()
        
        providesPresentationContextTransitionStyle = true
        viewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(viewController, animated: true, completion: nil)
    }
}
