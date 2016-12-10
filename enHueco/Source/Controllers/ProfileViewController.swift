//
//  ProfileViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import LocalAuthentication
import ChameleonFramework

class ProfileViewController: UIViewController {
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var editScheduleButton: UIButton!
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    var imageActivityIndicator: UIActivityIndicatorView!

    var realtimeAppUserManager: RealtimeUserManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor

        imageActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.addSubview(imageActivityIndicator!)
        imageActivityIndicator.autoAlignAxis(.horizontal, toSameAxisOf: imageImageView)
        imageActivityIndicator.autoAlignAxis(.vertical, toSameAxisOf: imageImageView)
        
        imageImageView.contentMode = .scaleAspectFill
        backgroundImageView.contentMode = .scaleAspectFill
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        editScheduleButton.clipsToBounds = true
        editScheduleButton.layer.cornerRadius = editScheduleButton.frame.height / 2

        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !(UIApplication.shared.delegate as! AppDelegate).loggingOut else {
            return
        }

        realtimeAppUserManager = RealtimeUserManager(delegate: self)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !(UIApplication.shared.delegate as! AppDelegate).loggingOut else {
            return
        }

        reportScreenViewToGoogleAnalyticsWithName(name: "Profile")
    }

    func refreshUIData() {
        
        guard let user = realtimeAppUserManager?.user else {
            return
        }
        
        firstNamesLabel.text = user.firstNames
        lastNamesLabel.text = user.lastNames
        
        imageImageView.isHidden = false
        backgroundImageView.isHidden = false
        
        imageImageView.sd_setImage(with: user.image as URL!, placeholderImage: nil, options: [.refreshCached, .retryFailed, .avoidAutoSetImage]) { (image, error, cacheType, url) in
            
            defer {
                self.updateButtonColors()
            }
            
            guard let image = image ?? UIImage(named: "stripes") else { return }
            
            UIView.transition(with: self.imageImageView, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.imageImageView.image = image
            }, completion: nil)
            
            UIView.transition(with: self.backgroundImageView, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.backgroundImageView.image = image.applyBlur(withRadius: 40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
            }, completion: nil)
        }
    }
    
    func updateButtonColors() {

        guard let image = imageImageView.image else { return }
        
        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFrom: image), isFlat: true, alpha: 0.4)

        UIView.animate(withDuration: 0.8) {
            self.editScheduleButton.backgroundColor = averageImageColor
        }
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {

        if UserDefaults.standard.bool(forKey: "authTouchID") {
            authenticateUser()
        } else {
            showSettings()
        }
    }

    fileprivate func showSettings() {

        let viewController = storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationViewController")
        present(viewController!, animated: true, completion: nil)
    }

    enum LAError: Int {
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case touchIDNotAvailable
        case touchIDNotEnrolled
    }

    func authenticateUser() {

        // Get the local authentication context.
        let context = LAContext()
        var error: NSError?
        let reasonString = "AuthenticationRequired".localizedUsingGeneralFile()

        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: {
                (success: Bool, evalPolicyError: NSError?) -> Void in

                if success {
                    DispatchQueue.main.async {
                        self.showSettings()
                    }
                } else {
                    switch evalPolicyError!.code {
                    case LAError.systemCancel.rawValue:
                        break
                    case LAError.userCancel.rawValue:
                        break
                    case LAError.userFallback.rawValue:
                        break
                    default:
                        break
                            //                        println("Authentication failed")
                            //                        self.showPasswordAlert()
                    }
                }
            } as! (Bool, Error?) -> Void)
        } else {
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code {
            case LAError.touchIDNotEnrolled.rawValue:
                break

            case LAError.passcodeNotSet.rawValue:
                break

            default:
                break
                    // The LAError.TouchIDNotAvailable case.
            }

            //            println(error?.localizedDescription)

            // Allow users to enter the password.
            //            self.showPasswordAlert()
        }
    }

    // MARK: Image Handlers

    @IBAction func imageViewClicked(_ sender: Any) {

        definesPresentationContext = true

        let importPictureController = storyboard?.instantiateViewController(withIdentifier: "ImportProfileImageViewController") as! ImportProfileImageViewController
        importPictureController.delegate = self
        importPictureController.translucent = true

        present(importPictureController, animated: true, completion: nil)
    }
}

extension ProfileViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager) {
        refreshUIData()
    }
}

extension ProfileViewController: ImportProfileImageViewControllerDelegate {
    func importProfileImageViewControllerDidFinishImportingImage(_ controller: ImportProfileImageViewController) {

        dismiss(animated: true, completion: nil)
    }

    func importProfileImageViewControllerDidCancel(_ controller: ImportProfileImageViewController) {

        dismiss(animated: true, completion: nil)
    }
}
