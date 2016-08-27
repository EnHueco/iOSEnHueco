//
//  PrivacySettingsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/2/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit


class PrivacySettingsViewController: UITableViewController {
    @IBOutlet weak var shareLocationWithBestFriendsSwitch: UISwitch!
    @IBOutlet weak var shareEventNamesSwitch: UISwitch!
    @IBOutlet weak var shareEventLocationsSwitch: UISwitch!

    @IBOutlet weak var selectFriendsShareLocationCell: UITableViewCell!
    @IBOutlet weak var selectFriendsShareEventNamesCell: UITableViewCell!
    @IBOutlet weak var selectFriendsShareEventLocationsCell: UITableViewCell!

    /// !!! Sections that must be hidden because they are not implemented yet
    private let unimplementedSections = [0]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Privacidad"
        clearsSelectionOnViewWillAppear = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //shareLocationWithBestFriendsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.shareLocationWithCloseFriends)

        shareEventNamesSwitch.on = PrivacyManager.sharedManager.isPrivacySettingTurnedOn(.ShowEventNames)
        shareEventLocationsSwitch.on = PrivacyManager.sharedManager.isPrivacySettingTurnedOn(.ShowEventLocations)
    }

    @IBAction func shareLocationWithBestFriendsToggleChanged(sender: UISwitch) {

        //TODO
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @IBAction func shareEventNamesToggleChanged(sender: UISwitch) {

        tableView.beginUpdates()
        tableView.endUpdates()

        _togglePrivacySetting(.ShowEventNames, on: sender.on, senderSwitch: sender)
    }

    @IBAction func shareEventLocationsToggleChanged(sender: UISwitch) {

        tableView.beginUpdates()
        tableView.endUpdates()

        _togglePrivacySetting(.ShowEventLocations, on: sender.on, senderSwitch: sender)
    }

    /**
     Toggles a privacy setting on or off.
     Must only be called after a UISwitch triggered the event.
     
     - parameter setting:      Privacy setting to change
     - parameter on:           True if the setting should be turned on
     - parameter senderSwitch: The switch that triggered the event
     */
    private func _togglePrivacySetting(setting: PrivacySetting, on: Bool, senderSwitch: UISwitch) {

        EHProgressHUD.showSpinnerInView(view)
        let completionHandler: BasicCompletionHandler = {
            success, error in

            EHProgressHUD.dismissSpinnerForView(self.view)

            if !success {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                senderSwitch.on = !senderSwitch.on
            }
        }
        if on {
            PrivacyManager.sharedManager.turnOnSetting(setting, withCompletionHandler: completionHandler)
        } else {
            PrivacyManager.sharedManager.turnOffSetting(setting, withCompletionHandler: completionHandler)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if cell == selectFriendsShareLocationCell {
            return 0 // !!! <- REMOVE WHEN READY TO IMPLEMENT GROUPS
            //return shareLocationWithBestFriendsSwitch.on ? 44:0
        } else if cell == selectFriendsShareEventNamesCell {
            return 0 // !!! <- REMOVE WHEN READY TO IMPLEMENT GROUPS
            //return shareEventNamesSwitch.on ? 44:0
        } else if cell == selectFriendsShareEventLocationsCell {
            return 0 // !!! <- REMOVE WHEN READY TO IMPLEMENT GROUPS
            //return shareEventLocationsSwitch.on ? 44:0
        }

        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // !!! REMOVE WHEN READY TO IMPLEMENT THE FEATURES IN THE HIDDEN SECTIONS

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard !unimplementedSections.contains(section) else {
            return 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard !unimplementedSections.contains(section) else {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        guard !unimplementedSections.contains(section) else {
            return nil
        }
        return super.tableView(tableView, titleForFooterInSection: section)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        guard !unimplementedSections.contains(section) else {
            return 1
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        guard !unimplementedSections.contains(section) else {
            return 1
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////
}
