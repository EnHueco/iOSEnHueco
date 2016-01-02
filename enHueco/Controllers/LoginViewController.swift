//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit


@IBDesignable class LoginViewController: UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var verticalSpaceToBottomConstraint: NSLayoutConstraint!
    var verticalSpaceToBottomInitialValue: CGFloat!

    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidLogin:"), name: EHSystemNotification.SystemDidLogin, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemCouldNotLoginWithError:"), name: EHSystemNotification.SystemCouldNotLoginWithError, object: system)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

        verticalSpaceToBottomInitialValue = verticalSpaceToBottomConstraint.constant

        loginButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
    }

    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        if system.appUser != nil
        {
            goToMainTabViewController()
        }
    }

    @IBAction func login(sender: AnyObject)
    {
        view.endEditing(true)
        guard let username = usernameTextField.text, password = passwordTextField.text where username != "" && password != "" else
        {
            //TODO: Shake animation
            return
        }

        if usernameTextField.text == "test" && passwordTextField.text == "test"
        {
            // Test
            system.createTestAppUser()

            if system.appUser.imageURL == nil
            {
                navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("ImportProfileImageViewController"), animated: true)
            }
            else
            {
                goToMainTabViewController()
            }
            
            return
            /////////
        }

        MRProgressOverlayView.showOverlayAddedTo(view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHInterfaceColor.mainInterfaceColor)

        system.login(username, password: password)
    }

    func goToMainTabViewController()
    {
        ProximityManager.sharedManager().beginProximityUpdates()

        performSegueWithIdentifier("PresentMainTabViewController", sender: self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }

    // MARK: Notification Center

    func systemDidLogin(notification: NSNotification)
    {
        NSThread.sleepForTimeInterval(0.5)
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
        
        if system.appUser.imageURL == nil
        {
            navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("ImportProfileImageViewController"), animated: true)
        }
        else
        {
            goToMainTabViewController()
        }
    }

    func systemCouldNotLoginWithError(notification: NSNotification)
    {
        //TODO: Show error
        NSThread.sleepForTimeInterval(0.5)

        TSMessage.showNotificationWithTitle("IncorrectCredentialsMessage".localized(), type: TSMessageNotificationType.Error)
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
    }

    // MARK: Keyboard

    func keyboardWillShow(notification: NSNotification)
    {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        view.layoutIfNeeded()

        UIView.animateWithDuration(0.1)
        {
            self.verticalSpaceToBottomConstraint.constant = keyboardFrame.size.height + 20
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }
    }

    func keyboardWillHide(notification: NSNotification)
    {
        view.layoutIfNeeded()

        UIView.animateWithDuration(0.1, animations: {() -> Void in

            self.verticalSpaceToBottomConstraint.constant = self.verticalSpaceToBottomInitialValue
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()

        }, completion: {(finished) -> Void in

            self.view.layoutIfNeeded()
        })
    }
}
