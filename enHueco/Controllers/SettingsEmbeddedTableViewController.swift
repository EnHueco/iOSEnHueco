//
//  SettingsTableViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SettingsEmbeddedTableViewController: UITableViewController
{
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var authTouchIDSwitch: UISwitch!
    @IBOutlet weak var nearbyFriendsNotificationsSwitch: UISwitch!
    @IBOutlet weak var shareLocationWithCloseFriendsSwitch: UISwitch!

    //Temporary
    @IBOutlet weak var lastBackgroundFetchDateLabel: UILabel!
    
    @IBAction func nearbyFriendsNotificationsToggleChanged(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(nearbyFriendsNotificationsSwitch.on, forKey: EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        
        ProximityManager.sharedManager().updateBackgroundFetchIntervalBecauseUserChangedLocationSharingSettings()
    }
    
    @IBAction func shareLocationWithCloseFriendsToggleChanged(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(shareLocationWithCloseFriendsSwitch.on, forKey: EHUserDefaultsKeys.shareLocationWithCloseFriends)
        
        ProximityManager.sharedManager().updateBackgroundFetchIntervalBecauseUserChangedLocationSharingSettings()
    }
    
    @IBAction func authenticateWithTIDChanged(sender: UISwitch)
    {
        var isOn = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        isOn = !isOn
        
        NSUserDefaults.standardUserDefaults().setBool(isOn, forKey: EHUserDefaultsKeys.authTouchID)
        
        authTouchIDSwitch.on = isOn
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        authTouchIDSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        shareLocationWithCloseFriendsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.shareLocationWithCloseFriends)
        nearbyFriendsNotificationsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)

        clearsSelectionOnViewWillAppear = false
        
        let lastBackgroundUpdate = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdate")).descriptionWithLocale(NSLocale.currentLocale())
        let lastBackgroundUpdateResponse = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdateResponse")).descriptionWithLocale(NSLocale.currentLocale())
        
        lastBackgroundFetchDateLabel.text = "Last background fetch: \(lastBackgroundUpdate). Last response: \(lastBackgroundUpdateResponse)"
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
    }
}
