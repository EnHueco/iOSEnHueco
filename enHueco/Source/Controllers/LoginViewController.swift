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

    fileprivate var firstAppearance = true

    override func viewDidLoad() {
        super.viewDidLoad()

        (UIApplication.shared.delegate as! AppDelegate).mainNavigationController = navigationController

        navigationController?.isNavigationBarHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        verticalSpaceToBottomInitialValue = verticalSpaceToBottomConstraint.constant

        loginButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        let title = NSMutableAttributedString(string: "ENHUECO")
        let boldFont = UIFont.boldSystemFont(ofSize: logoTitleLabel.font.pointSize)

        title.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, 2))

        logoTitleLabel.attributedText = title

        let backgroundImageView = UIImageView(imageNamed: "blurryBackground")

        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        effectView.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        backgroundImageView?.addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()

        view.insertSubview(backgroundImageView!, at: 0)
        backgroundImageView?.autoPinEdgesToSuperviewEdges()

        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self

        fbLoginButton.center = view.center
        view.addSubview(fbLoginButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstAppearance && AccountManager.sharedManager.userID != nil {
            goToMainTabViewController()
        } else {
            try? AccountManager.sharedManager.logOut()
            (UIApplication.shared.delegate as! AppDelegate).loggingOut = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        firstAppearance = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        loginButton.roundCorners()
        logoImageView.roundCorners()
    }


    @IBAction func login(_ sender: Any) {

        view.endEditing(true)

        guard let username = usernameTextField.text, let password = passwordTextField.text, username != "" && password != "" else{
            //TODO: Shake animation
            return
        }

        EHProgressHUD.showSpinnerInView(view)
        AccountManager.sharedManager.loginWith(username, password: password) { error -> Void in
            EHProgressHUD.dismissSpinnerForView(self.view)

            guard error == nil else {

                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            // TODO: Update
            /*
            if enHueco.appUser.imageURL == nil {
                let importImageController = self.storyboard!.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
                importImageController.cancelButtonText = "Skip".localizedUsingGeneralFile()
                importImageController.delegate = self

                self.navigationController?.pushViewController(importImageController, animated: true)
            } else {
                self.goToMainTabViewController()
            }*/
        }
    }

    func goToMainTabViewController() {

        //ProximityUpdatesManager.sharedManager.beginProximityUpdates()

        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController

        navigationController?.present(mainTabBarController, animated: true, completion: {

            self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!], animated: false)
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    // MARK: Keyboard

    func keyboardWillShow(_ notification: Notification) {

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.1, animations: {
            self.verticalSpaceToBottomConstraint.constant = keyboardFrame.size.height + 20
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        }) 
    }

    func keyboardWillHide(_ notification: Notification) {

        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.1, animations: {() -> Void in

            self.verticalSpaceToBottomConstraint.constant = self.verticalSpaceToBottomInitialValue
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()

        }, completion: {(finished) -> Void in

            self.view.layoutIfNeeded()
        })
    }
}

extension LoginViewController: ImportProfileImageViewControllerDelegate {
    
    func importProfileImageViewControllerDidFinishImportingImage(_ controller: ImportProfileImageViewController) {
        goToMainTabViewController()
    }

    func importProfileImageViewControllerDidCancel(_ controller: ImportProfileImageViewController) {
        goToMainTabViewController()
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
            
        } else {
            EHProgressHUD.showSpinnerInView(view)
            AccountManager.sharedManager.loginWith(FBSDKAccessToken.current().tokenString) { error in
                EHProgressHUD.dismissSpinnerForView(self.view)
                
                guard error == nil else {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    return
                }
                
                self.goToMainTabViewController()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
