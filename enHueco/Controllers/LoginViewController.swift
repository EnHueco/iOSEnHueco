//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit


@IBDesignable class LoginViewController : UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidLogin:"), name: EHSystemNotification.SystemDidLogin.rawValue, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemCouldNotLoginWithError:"), name: EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: system)
        
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height/2
    }
    
    @IBAction func login(sender: AnyObject)
    {
        guard let username = usernameTextField.text, password = passwordTextField.text where username != "" && password != "" else
        {
            if usernameTextField.text == "" { TSMessage.showNotificationWithTitle("El login se encuentra vacío", type: TSMessageNotificationType.Warning) }
            else if passwordTextField.text == "" { TSMessage.showNotificationWithTitle("La contraseña se encuentra vacía", type: TSMessageNotificationType.Warning) }
            return
        }
            
        if usernameTextField.text == "test" && passwordTextField.text == "test"
        {
            // Test
            let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
            navigationController!.pushViewController(mainViewController, animated: true)
            return
            /////////
        }
        
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHIntefaceColor.mainInterfaceColor)
        
        system.login(username, password: password)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func systemDidLogin (notification: NSNotification)
    {
        NSThread.sleepForTimeInterval(0.5)
        let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
        dispatch_async(dispatch_get_main_queue())
        {
            self.presentViewController(mainViewController, animated: true, completion: nil)
            MRProgressOverlayView.dismissOverlayForView(self.view, animated:true);
        }
        

    }
    
    func systemCouldNotLoginWithError (notification: NSNotification)
    {
        //TODO: Show error
        NSThread.sleepForTimeInterval(0.5)
        dispatch_async(dispatch_get_main_queue())
        {
            TSMessage.showNotificationWithTitle("Credenciales Inválidas", type: TSMessageNotificationType.Error)
            MRProgressOverlayView.dismissOverlayForView(self.view, animated:true);
        }
    }
}
