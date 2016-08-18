//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth


@IBDesignable class LoginViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoTitleLabel: UILabel!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var verticalSpaceToBottomConstraint: NSLayoutConstraint!
    var verticalSpaceToBottomInitialValue: CGFloat!

    private var firstAppearance = true

    override func viewDidLoad() {

        (UIApplication.sharedApplication().delegate as! AppDelegate).mainNavigationController = navigationController

        navigationController?.navigationBarHidden = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        verticalSpaceToBottomInitialValue = verticalSpaceToBottomConstraint.constant

        loginButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        let title = NSMutableAttributedString(string: "ENHUECO")
        let boldFont = UIFont.boldSystemFontOfSize(logoTitleLabel.font.pointSize)

        title.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, 2))

        logoTitleLabel.attributedText = title

        let backgroundImageView = UIImageView(imageNamed: "blurryBackground")

        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        effectView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)

        backgroundImageView.addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        view.insertSubview(backgroundImageView, atIndex: 0)
        backgroundImageView.autoPinEdgesToSuperviewEdges()

        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self

        fbLoginButton.center = view.center
        view.addSubview(fbLoginButton)


    }

    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)

        if firstAppearance && enHueco.appUser != nil {
            goToMainTabViewController()
        } else {
            AccountManager.sharedManager.logOut()
            (UIApplication.sharedApplication().delegate as! AppDelegate).loggingOut = false
        }
    }

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        firstAppearance = false
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        loginButton.roundCorners()
        logoImageView.roundCorners()
    }


    @IBAction func login(sender: AnyObject) {

        view.endEditing(true)

        guard let username = usernameTextField.text, password = passwordTextField.text where username != "" && password != "" else
        {
            //TODO: Shake animation
            return
        }

        if usernameTextField.text == "test" && passwordTextField.text == "test" {
            // Test
            enHueco.createTestAppUser()

            if enHueco.appUser.imageURL == nil {
                let importImageController = self.storyboard!.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
                importImageController.cancelButtonText = "Skip".localizedUsingGeneralFile()
                importImageController.delegate = self

                self.navigationController?.pushViewController(importImageController, animated: true)
            } else {
                self.goToMainTabViewController()
            }

            return
            /////////
        }

        EHProgressHUD.showSpinnerInView(view)

        AccountManager.loginWithUsername(username, password: password) {
            (success, error) -> Void in

            EHProgressHUD.dismissSpinnerForView(self.view)

            guard success && error == nil else {

                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            if enHueco.appUser.imageURL == nil {
                let importImageController = self.storyboard!.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
                importImageController.cancelButtonText = "Skip".localizedUsingGeneralFile()
                importImageController.delegate = self

                self.navigationController?.pushViewController(importImageController, animated: true)
            } else {
                self.goToMainTabViewController()
            }
        }
    }

    func goToMainTabViewController() {

        //ProximityUpdatesManager.sharedManager.beginProximityUpdates()

        let mainTabBarController = storyboard?.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController

        navigationController?.presentViewController(mainTabBarController, animated: true, completion: {

            self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!], animated: false)
        })
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        self.view.endEditing(true)
    }

    // MARK: Keyboard

    func keyboardWillShow(notification: NSNotification) {

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        view.layoutIfNeeded()

        UIView.animateWithDuration(0.1) {
            self.verticalSpaceToBottomConstraint.constant = keyboardFrame.size.height + 20
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }
    }

    func keyboardWillHide(notification: NSNotification) {

        view.layoutIfNeeded()

        UIView.animateWithDuration(0.1, animations: {
            () -> Void in

            self.verticalSpaceToBottomConstraint.constant = self.verticalSpaceToBottomInitialValue
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()

        }, completion: {
            (finished) -> Void in

            self.view.layoutIfNeeded()
        })
    }
}

extension LoginViewController: ImportProfileImageViewControllerDelegate {
    func importProfileImageViewControllerDidFinishImportingImage(controller: ImportProfileImageViewController) {

        goToMainTabViewController()
    }

    func importProfileImageViewControllerDidCancel(controller: ImportProfileImageViewController) {

        goToMainTabViewController()
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) {
                (user, error) in
                print(" SUCCESSFULLY LOGGED IN ")
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }
}
