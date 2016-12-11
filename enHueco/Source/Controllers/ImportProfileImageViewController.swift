//
//  ImportProfileImageViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 1/1/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import RSKImageCropper
import MobileCoreServices
import SwiftyJSON

protocol ImportProfileImageViewControllerDelegate: class {
    func importProfileImageViewControllerDidFinishImportingImage(_ controller: ImportProfileImageViewController)

    func importProfileImageViewControllerDidCancel(_ controller: ImportProfileImageViewController)
}

class ImportProfileImageViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var importFromLocalStorageButton: UIButton!
    @IBOutlet weak var importFromFacebookButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    let imagePicker = UIImagePickerController()

    var cancelButtonText: String?
    var hideCancelButton = false
    var translucent = false

    weak var delegate: ImportProfileImageViewControllerDelegate?

    /// Status bar style before presenting this controller
    fileprivate var originalStatusBarStyle: UIStatusBarStyle!

    override func viewDidLoad() {
        super.viewDidLoad()

        originalStatusBarStyle = UIApplication.shared.statusBarStyle

        modalPresentationStyle = .overCurrentContext

        if hideCancelButton {
            cancelButton.isHidden = true
        }

        if let cancelButtonText = cancelButtonText {
            cancelButton.setTitle(cancelButtonText, for: UIControlState())
        }

        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

        if translucent {
            view.backgroundColor = UIColor.clear
            view.insertSubview(effectView, at: 0)
        } else {
            effectView.backgroundColor = UIColor.white.withAlphaComponent(0.3)

            let backgroundImageView = UIImageView(imageNamed: "blurryBackground")
            view.insertSubview(backgroundImageView!, at: 0)
            backgroundImageView?.autoPinEdgesToSuperviewEdges()
            backgroundImageView?.addSubview(effectView)
        }

        effectView.autoPinEdgesToSuperviewEdges()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        importFromFacebookButton.roundCorners()
        importFromLocalStorageButton.roundCorners()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.default, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.setStatusBarStyle(originalStatusBarStyle, animated: animated)
    }

    @IBAction func importFromLocalStorageButtonPressed(_ sender: UIButton) {

        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // There is a camera on this device, so show the take photo button.

            alertController.addAction(UIAlertAction(title: "TakePhoto".localizedUsingGeneralFile(), style: .default, handler: {
                (action) -> Void in

                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }))
        }

        alertController.addAction(UIAlertAction(title: "ChoosePhoto".localizedUsingGeneralFile(), style: .default, handler: {
            (action) -> Void in

            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel".localizedUsingGeneralFile(), style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func importFromFacebookButtonPressed(_ sender: UIButton) {

        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile"], from: self) {(result, error) -> Void in

            guard error == nil else {
                EHNotifications.showError(in: self, error: error)
                return
            }

            if !(result?.isCancelled)! {
                //We are logged into Facebook

                FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields": "url", "width": "500", "redirect": "false"], httpMethod: "GET").start() {(_, result, error) -> Void in

                    let json = JSON(result ?? [:])
                    
                    guard let imageURLString = json["data"]["url"].string,
                        let imageURL = URL(string: imageURLString),
                        let imageData = try? Data(contentsOf: imageURL),
                        let image = UIImage(data: imageData), error == nil
                    else {
                        EHNotifications.showError(in: self, error: error)
                        return
                    }

                    let imageCropVC = RSKImageCropViewController(image: image)
                    imageCropVC.delegate = self
                    //self.presentViewController(imageCropVC, animated: true, completion: nil)
                    
                    var intent = UserUpdateIntent()
                    intent.image = imageURL
                    
                    AppUserManager.shared.updateUserWith(intent, completionHandler: { (error) in
                        
                        guard error == nil else {
                            EHNotifications.showError(in: self, error: error)
                            return
                        }
                        
                        self.delegate?.importProfileImageViewControllerDidFinishImportingImage(self)
                    })
                }
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {

        delegate?.importProfileImageViewControllerDidCancel(self)
    }
}

extension ImportProfileImageViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
     
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageCropVC = RSKImageCropViewController(image: image)
            imageCropVC.delegate = self
            
            picker.dismiss(animated: true) {
                self.present(imageCropVC, animated: true, completion: nil)
            }
            
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension ImportProfileImageViewController: RSKImageCropViewControllerDelegate {
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {

        // TODO: Update implementation
        /*
        EHProgressHUD.showSpinnerInView(controller.view)
        let finalImage = RBResizeImage(croppedImage, targetSize: CGSizeMake(275, 275))
        AppUserInformationManager.shared.pushProfilePicture(finalImage) {
            success, error in

            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            controller.dismissViewControllerAnimated(true) {
                self.delegate?.importProfileImageViewControllerDidFinishImportingImage(self)
            }
        }*/
    }

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {

        controller.dismiss(animated: true, completion: nil)
    }
}
