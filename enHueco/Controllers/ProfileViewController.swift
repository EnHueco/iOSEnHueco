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
    
    @IBOutlet weak var appUserQRImageView: UIImageView!
    
    override func viewDidLoad()
    {
        firstNamesLabel.text = system.appUser.firstNames
        lastNamesLabel.text = system.appUser.lastNames
        usernameLabel.text = system.appUser.username

        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = 4
    }
    
    override func viewDidAppear(animated: Bool)
    {
        let code = QRCode(system.appUser.stringEncodedUserRepresentation())
        appUserQRImageView.image = code?.image
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
}
