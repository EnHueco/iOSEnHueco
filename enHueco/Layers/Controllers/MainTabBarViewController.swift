//
//  MainViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import TSMessages

class MainTabBarViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        TSMessage.setDefaultViewController(self)
        
        navigationController?.navigationBarHidden = true
        
        tabBar.barTintColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        tabBar.tintColor = UIColor.whiteColor()
        
        tabBar.translucent = true
    }
}
