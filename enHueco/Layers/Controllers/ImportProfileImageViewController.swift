//
//  ImportProfileImageViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 1/1/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ImportProfileImageViewController: UIViewController
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
    
    @IBAction func importFromCameraRollButtonPressed(sender: UIButton)
    {
    }

    @IBAction func importFromFacebookButtonPressed(sender: UIButton)
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            
            if error != nil
            {
                
            }
            else if result.isCancelled
            {
                
            }
            else
            {
                //We are logged into Facebook
                
                FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields":"url", "width":"500", "redirect":"false"], HTTPMethod: "GET").startWithCompletionHandler() { (_, result, error) -> Void in
                    
                    guard let data = result["data"],
                          let imageURL = data?["url"] as? String
                        where error == nil
                    else
                    {
                        self.goToMainTabViewController()
                        return
                    }
                    
                    enHueco.appUser.imageURL = NSURL(string: imageURL)
                    
                    self.goToMainTabViewController()
                }
            }
        }
    }
    
    func goToMainTabViewController()
    {
        ProximityUpdatesManager.sharedManager().beginProximityUpdates()
        
        presentViewController(storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController"), animated: true, completion: nil)
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
