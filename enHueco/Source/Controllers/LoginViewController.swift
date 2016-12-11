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

    @IBOutlet weak var loginButton: FBSDKLoginButton!

    @IBOutlet weak var verticalSpaceToBottomConstraint: NSLayoutConstraint!
    var verticalSpaceToBottomInitialValue: CGFloat!

    fileprivate var firstAppearance = true

    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.shared.mainNavigationController = navigationController

        navigationController?.isNavigationBarHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        verticalSpaceToBottomInitialValue = verticalSpaceToBottomConstraint.constant

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

        loginButton.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if firstAppearance && AccountManager.shared.userID != nil {
            goToMainTabViewController()
        } else {
            try? AccountManager.shared.logOut()
            AppDelegate.shared.loggingOut = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        firstAppearance = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoImageView.roundCorners()
    }

    func goToMainTabViewController() {

        //ProximityUpdatesManager.shared.beginProximityUpdates()

        let window = AppDelegate.shared.window!
        let mainTabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController

        // FIXME: Use a decent animation
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = mainTabBarController
        }, completion: nil)
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
            EHNotifications.showError(in: self, error: error)
            debugPrint(error)
            return
            
        } else {
            EHProgressHUD.showSpinnerInView(view)
            AccountManager.shared.loginWith(FBSDKAccessToken.current().tokenString) { error in
                EHProgressHUD.dismissSpinnerForView(self.view)
                
                guard error == nil else {
                    EHNotifications.showError(in: self, error: error)
                    return
                }
                
                self.goToMainTabViewController()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {}
}
