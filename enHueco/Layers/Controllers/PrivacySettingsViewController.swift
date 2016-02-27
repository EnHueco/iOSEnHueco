//
//  PrivacySettingsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/2/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class PrivacySettingsViewController: UITableViewController
{
    @IBOutlet weak var shareLocationWithBestFriendsSwitch: UISwitch!
    @IBOutlet weak var shareEventNamesSwitch: UISwitch!
    @IBOutlet weak var shareEventLocationsSwitch: UISwitch!
    
    @IBOutlet weak var selectFriendsShareLocationCell: UITableViewCell!
    @IBOutlet weak var selectFriendsShareEventNamesCell: UITableViewCell!
    @IBOutlet weak var selectFriendsShareEventLocationsCell: UITableViewCell!
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Privacidad"
        clearsSelectionOnViewWillAppear = true
        
        shareLocationWithBestFriendsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.shareLocationWithCloseFriends)
    }
    
    @IBAction func shareLocationWithBestFriendsToggleChanged(sender: UISwitch)
    {
        NSUserDefaults.standardUserDefaults().setBool(shareLocationWithBestFriendsSwitch.on, forKey: EHUserDefaultsKeys.shareLocationWithCloseFriends)
        
        ProximityManager.sharedManager().updateBackgroundFetchInterval()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @IBAction func shareEventNamesToggleChanged(sender: UISwitch)
    {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func shareEventLocationsToggleChanged(sender: UISwitch)
    {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if cell == selectFriendsShareLocationCell
        {
            return shareLocationWithBestFriendsSwitch.on ? 44:0
        }
        else if cell == selectFriendsShareEventNamesCell
        {
            return shareEventNamesSwitch.on ? 44:0
        }
        else if cell == selectFriendsShareEventLocationsCell
        {
            return shareEventLocationsSwitch.on ? 44:0
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
