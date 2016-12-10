//
//  InstantFreeTimeViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/11/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol InstantFreeTimeViewControllerDelegate: class {
    func instantFreeTimeViewControllerDidPostInstantFreeTimePeriod(_ controller: InstantFreeTimeViewController)
}

class InstantFreeTimeViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!

    @IBOutlet weak var endTimeLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endTimeDatePickerHeightConstraint: NSLayoutConstraint!

    var originalFrame: CGRect!
    var backgroundView: UIView!

    weak var delegate: InstantFreeTimeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        endTimeDatePicker.timeZone = TimeZone.autoupdatingCurrent
        endTimeDatePicker.locale = Locale(identifier: "en_US")
        endTimeDatePicker.minimumDate = Date().addingTimeInterval(60)

        NotificationCenter.default.addObserver(self, selector: #selector(InstantFreeTimeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InstantFreeTimeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        navigationBar.barStyle = .black
        navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
        navigationBar.tintColor = UIColor.white

        view.clipsToBounds = true
        view.layer.cornerRadius = 8
    }

    func showInViewController(_ controller: UIViewController) {

        view.frame = CGRect(x: 20, y: -300, width: controller.view.bounds.width - 40, height: 270)

        controller.addChildViewController(self)
        controller.view.addSubview(view)

        backgroundView = UIView()
        backgroundView.frame = controller.view.bounds
        backgroundView.backgroundColor = UIColor.clear
        controller.view.insertSubview(backgroundView, belowSubview: view)

        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InstantFreeTimeViewController.hideKeyboard)))

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1.6, options: UIViewAnimationOptions(), animations: {

            self.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            self.view.frame.origin.y = 110
            self.originalFrame = self.view.frame

        }, completion: {
            finished in

            self.didMove(toParentViewController: controller)
            self.nameTextField.becomeFirstResponder()
        })
    }

    func dismiss() {

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {

            self.view.frame.origin.y = -self.view.frame.height - 30
            self.backgroundView.backgroundColor = UIColor.clear

        }, completion: {
            finished in

            self.backgroundView.removeFromSuperview()

            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            self.didMove(toParentViewController: nil)
        })
    }

    func hideKeyboard() {

        view.endEditing(true)
    }

    @IBAction func postButtonPressed(_ sender: Any) {

        let newFreeTimePeriod = BaseEvent(type: .FreeTime, name: nameTextField.text, location: locationTextField.text, startDate: Date(), endDate: endTimeDatePicker.date, repeating: false)

        EHProgressHUD.showSpinnerInView(view)
        CurrentStateManager.sharedManager.postInstantFreeTimePeriod(newFreeTimePeriod) { error in
            EHProgressHUD.dismissSpinnerForView(self.view)

            guard error == nil else {

                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            self.delegate?.instantFreeTimeViewControllerDidPostInstantFreeTimePeriod(self)
            self.dismiss()
        }
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {

        dismiss()
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func keyboardWillShow(_ notification: Notification) {

        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.1, animations: {
            let offset = (self.view.frame.origin.y + self.view.frame.height) - keyboardFrame.origin.y

            if offset > 0 {
                self.view.frame.origin.y -= (offset + 8)
                //self.endTimeLabelHeightConstraint.constant = 0
                //self.endTimeDatePickerHeightConstraint.constant = 0
                //self.view.frame.size.height = 130
                self.view.layoutIfNeeded()
            }
        }) 
    }

    func keyboardWillHide(_ notification: Notification) {

        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.1, animations: {
            self.view.frame = self.originalFrame
            //self.endTimeLabelHeightConstraint.constant = 20
            //self.endTimeDatePickerHeightConstraint.constant = 104
            self.view.layoutIfNeeded()
        }) 
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
