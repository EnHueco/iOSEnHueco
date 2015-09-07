//
//  InGapViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapViewController: UIViewController
{
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
}
