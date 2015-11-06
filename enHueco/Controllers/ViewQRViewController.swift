//
//  ViewQRViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 9/27/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ViewQRViewController: UIViewController
{
    @IBOutlet weak var QRImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        backButton.clipsToBounds = true
        backButton.layer.cornerRadius = backButton.frame.height/2
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let code = QRCode(system.appUser.stringEncodedUserRepresentation())
        QRImageView.image = code?.image
        
        UIView.animateWithDuration(0.5)
        {
            self.view.backgroundColor = UIColor.blackColor()
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
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
