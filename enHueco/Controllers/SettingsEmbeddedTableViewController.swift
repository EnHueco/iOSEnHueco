//
//  SettingsTableViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SettingsEmbeddedTableViewController: UITableViewController, UIAlertViewDelegate
{
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var authTouchIDSwitch: UISwitch!
    @IBOutlet weak var nearbyFriendsNotificationsSwitch: UISwitch!
    @IBOutlet weak var phoneNumberCell: UITableViewCell!
    
    //Temporary
    @IBOutlet weak var lastBackgroundFetchDateLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Ajustes"
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
        
        clearsSelectionOnViewWillAppear = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveAppUserWasUpdated:"), name: EHSystemNotification.SystemDidReceiveAppUserWasUpdated, object: system)
        
        authTouchIDSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        nearbyFriendsNotificationsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        phoneNumberCell.textLabel?.text = system.appUser.phoneNumber
        
        let lastBackgroundUpdate = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdate")).descriptionWithLocale(NSLocale.currentLocale())
        let lastBackgroundUpdateResponse = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdateResponse")).descriptionWithLocale(NSLocale.currentLocale())
        
        //lastBackgroundFetchDateLabel.text = "Last background fetch: \(lastBackgroundUpdate). Last response: \(lastBackgroundUpdateResponse)"
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject)
    {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nearbyFriendsNotificationsToggleChanged(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(nearbyFriendsNotificationsSwitch.on, forKey: EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        
        ProximityManager.sharedManager().updateBackgroundFetchInterval()
    }
    
    @IBAction func authenticateWithTIDChanged(sender: UISwitch)
    {
        var isOn = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        isOn = !isOn
        
        NSUserDefaults.standardUserDefaults().setBool(isOn, forKey: EHUserDefaultsKeys.authTouchID)
        
        authTouchIDSwitch.on = isOn
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell ==  logoutCell
        {
            system.logOut()
            
            if let loginViewController = storyboard?.instantiateViewControllerWithIdentifier("MainNavigationController")
            {
                presentViewController(loginViewController, animated: true, completion: nil)
            }
        }
        else if cell == phoneNumberCell
        {
            let alertView = UIAlertView(title: "Teléfono", message: "Agrega un nuevo número de teléfono", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Agregar")
            alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.PhonePad
            alertView.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        phoneNumberCell.setSelected(false, animated: true)
        if let newNumber = alertView.textFieldAtIndex(0)?.text where !newNumber.isEmpty
        {
            system.appUser.phoneNumber = newNumber
            system.appUser.pushPhoneNumber(newNumber)
        }
    }
    func didReceiveAppUserWasUpdated(notification : NSNotification)
    {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.phoneNumberCell.textLabel?.text = system.appUser.phoneNumber
            }, completion: nil)
    }
}
