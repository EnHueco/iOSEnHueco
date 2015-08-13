//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, AppControllerDelegate
{
    @IBOutlet weak var loginInput: UITextField!
    
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func logIn(sender: AnyObject)
    {
        let app : AppController = AppController(delegate:self)
        app.authenticateUser(loginInput.text!, password: passwordInput.text!)
        
//        var api: APIConnector = APIConnector(delegate: self)
//        api.sendLoginRequest(loginInput.text, password: passwordInput.text)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func AppControllerValidResponseReceived()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.loginSuccess()
        }
    }
    private func loginSuccess()
    {
        let mainMenu = self.storyboard!.instantiateViewControllerWithIdentifier("mainMenu") as! UITabBarController
        self.presentViewController(mainMenu as UITabBarController, animated: true, completion: nil)
    }
    
    func AppControllerInvalidResponseReceived(errorResponse:NSString)
    {
        
    }
}
