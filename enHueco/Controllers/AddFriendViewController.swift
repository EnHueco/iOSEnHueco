//
//  AddFriendViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = EHIntefaceColor.defaultColoredBackgroundColor
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController!.navigationBarHidden = false
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = UIColor(red: 40/255.0, green: 100/255.0, blue: 90/255.0, alpha: 1)
        navigationController!.navigationBar.translucent = true
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "dismissViewController:")
        doneItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = doneItem
    }

    @IBAction func addByQRButtonPressed(sender: AnyObject)
    {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("AddFriendByQRViewController") as! AddFriendByQRViewController
        
        navigationController!.pushViewController(viewController, animated: true)
    }
    
    func dismissViewController (sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}