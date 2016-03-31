//
//  InstantFreeTimeViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/11/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol InstantFreeTimeViewControllerDelegate: class
{
    func instantFreeTimeViewControllerDidPostInstantFreeTimePeriod(controller: InstantFreeTimeViewController)
}

class InstantFreeTimeViewController: UIViewController
{
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        endTimeDatePicker.timeZone = NSTimeZone.localTimeZone()
        endTimeDatePicker.minimumDate = NSDate().dateByAddingTimeInterval(60)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InstantFreeTimeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InstantFreeTimeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    
        navigationBar.barStyle = .Black
        navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
        navigationBar.tintColor = UIColor.whiteColor()
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        //view.layer.borderColor = UIColor(white: 0.8, alpha: 1).CGColor
        //view.layer.borderWidth = 1
    }
    
    func showInViewController(controller: UIViewController)
    {
        view.frame = CGRect(x: 20, y: -300, width: controller.view.bounds.width-40, height: 270)
        
        controller.addChildViewController(self)
        controller.view.addSubview(view)
        
        backgroundView = UIView()
        backgroundView.frame = controller.view.bounds
        backgroundView.backgroundColor = UIColor.clearColor()
        controller.view.insertSubview(backgroundView, belowSubview: view)
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InstantFreeTimeViewController.hideKeyboard)))
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1.6, options: .CurveEaseInOut, animations: {
        
            self.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            self.view.frame.origin.y = 110
            self.originalFrame = self.view.frame
            
        }, completion: { finished in
    
            self.didMoveToParentViewController(controller)
            self.nameTextField.becomeFirstResponder()
        })
    }
    
    func dismiss()
    {
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            
            self.view.frame.origin.y = -self.view.frame.height - 30
            self.backgroundView.backgroundColor = UIColor.clearColor()
            
        }, completion: { finished in
            
            self.backgroundView.removeFromSuperview()
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            self.didMoveToParentViewController(nil)
        })
    }
    
    func hideKeyboard()
    {
        view.endEditing(true)
    }

    @IBAction func postButtonPressed(sender: AnyObject)
    {
        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let startHourComponents = globalCalendar.components([.Weekday, .Hour, .Minute], fromDate: NSDate())
        let endHourComponents = globalCalendar.components([.Weekday, .Hour, .Minute], fromDate: endTimeDatePicker.date)
        
        let newFreeTimePeriod = Event(type: .FreeTime, name: nameTextField.text, startHour: startHourComponents, endHour: endHourComponents, location: locationTextField.text, ID: nil, lastUpdatedOn: NSDate())
        
        EHProgressHUD.showSpinnerInView(view)
        CurrentStateManager.sharedManager.postInstantFreeTimePeriod(newFreeTimePeriod) { (success, error) in
            
            EHProgressHUD.dismissSpinnerForView(self.view)
            
            guard success && error == nil else {
                
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            self.delegate?.instantFreeTimeViewControllerDidPostInstantFreeTimePeriod(self)
            self.dismiss()
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        dismiss()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        view.layoutIfNeeded()

        UIView.animateWithDuration(0.1)
        {
            let offset = (self.view.frame.origin.y + self.view.frame.height) - keyboardFrame.origin.y
            
            if offset > 0
            {
                self.view.frame.origin.y -= (offset+8)
                //self.endTimeLabelHeightConstraint.constant = 0
                //self.endTimeDatePickerHeightConstraint.constant = 0
                //self.view.frame.size.height = 130
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        self.view.layoutIfNeeded()

        UIView.animateWithDuration(0.1)
        {
            self.view.frame = self.originalFrame
            //self.endTimeLabelHeightConstraint.constant = 20
            //self.endTimeDatePickerHeightConstraint.constant = 104
            self.view.layoutIfNeeded()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
