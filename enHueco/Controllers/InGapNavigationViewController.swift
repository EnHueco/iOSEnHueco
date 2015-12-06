//
//  InGapNavigationViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/11/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapNavigationViewController: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationBar.barStyle = UIBarStyle.Black
        navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
        navigationBar.tintColor = UIColor.whiteColor()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
