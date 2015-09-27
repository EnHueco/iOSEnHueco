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
        firstNamesLabel.text = system.appUser.firstNames
        lastNamesLabel.text = system.appUser.lastNames
        usernameLabel.text = system.appUser.username
        
        backgroundImageView.alpha = 0
        
        imageImageView.sd_setImageWithURL(system.appUser.imageURL)
        backgroundImageView.sd_setImageWithURL(system.appUser.imageURL)
        { (_, _, _, _) -> Void in
            
            UIView.animateWithDuration(0.4)
            {
                self.backgroundImageView.image = self.backgroundImageView.image!.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                self.backgroundImageView.alpha = 1
            }
        }
        
        imageImageView.contentMode = .ScaleAspectFill
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
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
