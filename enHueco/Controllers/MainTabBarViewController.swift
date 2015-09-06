//
//  MainViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController
{
    override func viewWillAppear(animated: Bool)
    {
        navigationController!.navigationBarHidden = true
    }
}
