//
//  ProfileViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ASMediasFocusDelegate
{
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editScheduleButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    
    @IBOutlet weak var appUserQRImageView: UIImageView!
    let QRTmpPath = NSTemporaryDirectory() + "AppUser_QR"
    
    var mediaFocusManager = ASMediaFocusManager()
    
    override func viewDidLoad()
    {
        firstNamesLabel.text = system.appUser.firstNames
        lastNamesLabel.text = system.appUser.lastNames
        usernameLabel.text = system.appUser.username

        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = 4
        
        mediaFocusManager.delegate = self
        mediaFocusManager.installOnView(appUserQRImageView)
        mediaFocusManager.animationDuration = 0.2
        mediaFocusManager.elasticAnimation = false
        
        imageImageView.sd_setImageWithURL(system.appUser.imageURL)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height/2
    }
    
    override func viewDidAppear(animated: Bool)
    {
        let code = QRCode(system.appUser.stringEncodedUserRepresentation())
        appUserQRImageView.image = code?.image
        
        UIGraphicsBeginImageContext(appUserQRImageView.image!.size)
        appUserQRImageView.image!.drawInRect(CGRectMake(0, 0, appUserQRImageView.image!.size.width, appUserQRImageView.image!.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImagePNGRepresentation(newImage)!.writeToFile(QRTmpPath, atomically: true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    @IBAction func settingsButtonPressed(sender: AnyObject)
    {
        system.logOut()
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("MainNavigationController")
        presentViewController(controller, animated: true, completion: nil)
    }
    
    //mark: ASMediaFocusManager delegate
    
    func parentViewControllerForMediaFocusManager(mediaFocusManager: ASMediaFocusManager!) -> UIViewController!
    {
        return self
    }
    
    func mediaFocusManager(mediaFocusManager: ASMediaFocusManager!, mediaURLForView view: UIView!) -> NSURL!
    {
        return NSURL(fileURLWithPath: QRTmpPath)
    }
    
    func mediaFocusManager(mediaFocusManager: ASMediaFocusManager!, titleForView view: UIView!) -> String!
    {
        return "Tu QR"
    }
}
