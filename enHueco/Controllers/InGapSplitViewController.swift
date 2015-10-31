//
//  InGapSplitViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/30/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapSplitViewController: UISplitViewController, UISplitViewControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
    {
        return true
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
