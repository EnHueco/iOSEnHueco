//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidLogin:"), name: EHSystemNotification.SystemDidLogin.rawValue, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemCouldNotLoginWithError:"), name: EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: system)
    }
    
    @IBAction func login(sender: AnyObject)
    {
        guard let username = usernameTextField.text, password = passwordTextField.text else { /* TODO: Mostrar error */ return  }
        
        system.login(username, password: password)
        
        //TODO: Mostrar indicador "cargando"
        
        //Pruebas
        
        let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
        navigationController!.pushViewController(mainViewController, animated: true)
        
        /////////
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func systemDidLogin (notification: NSNotification)
    {
        let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
        self.presentViewController(mainViewController, animated: true, completion: nil)
    }
    
    func systemCouldNotLoginWithError (notification: NSNotification)
    {
        //TODO: Mostrar error
    }
}
