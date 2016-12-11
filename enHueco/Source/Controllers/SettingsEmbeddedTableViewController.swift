//
//  SettingsTableViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SettingsEmbeddedTableViewController: UITableViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var changeProfilePictureCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var authTouchIDSwitch: UISwitch!
    @IBOutlet weak var nearbyFriendsNotificationsSwitch: UISwitch!
    @IBOutlet weak var phoneNumberCell: UITableViewCell!

    /// !!! Sections that must be hidden because they are not implemented yet
    fileprivate let unimplementedSections = [1, 3]
    
    fileprivate var realtimeAppUserManager: RealtimeUserManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Ajustes"

        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor

        clearsSelectionOnViewWillAppear = true

        authTouchIDSwitch.isOn = UserDefaults.standard.bool(forKey: EHUserDefaultsKeys.authTouchID)
//        nearbyFriendsNotificationsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        realtimeAppUserManager = RealtimeUserManager(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeAppUserManager = nil
    }
    
    func refreshUIData() {
        
        phoneNumberCell.textLabel?.text = realtimeAppUserManager?.user?.phoneNumber
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////

    // !!! REMOVE WHEN READY TO IMPLEMENT THE FEATURES IN THE HIDDEN SECTIONS

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard !unimplementedSections.contains(section) else {
            return 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard !unimplementedSections.contains(section) else {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        guard !unimplementedSections.contains(section) else {
            return nil
        }
        return super.tableView(tableView, titleForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        guard !unimplementedSections.contains(section) else {
            return 1
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        guard !unimplementedSections.contains(section) else {
            return 1
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////


    @IBAction func doneButtonPressed(_ sender: AnyObject) {

        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func nearbyFriendsNotificationsToggleChanged(_ sender: AnyObject) {

        //TODO
    }

    @IBAction func authenticateWithTIDChanged(_ sender: UISwitch) {

        var isOn = UserDefaults.standard.bool(forKey: EHUserDefaultsKeys.authTouchID)
        isOn = !isOn

        UserDefaults.standard.set(isOn, forKey: EHUserDefaultsKeys.authTouchID)

        authTouchIDSwitch.isOn = isOn
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)

        if cell == logoutCell {
            logout()
            
        } else if cell == phoneNumberCell {
            
            let alertView = UIAlertView(title: "Teléfono", message: "Agrega un nuevo número de teléfono", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Agregar")
            alertView.alertViewStyle = UIAlertViewStyle.plainTextInput
            alertView.textField(at: 0)?.keyboardType = UIKeyboardType.phonePad
            alertView.show()
            
        } else if cell == changeProfilePictureCell {
            
            let importPictureController = storyboard?.instantiateViewController(withIdentifier: "ImportProfileImageViewController") as! ImportProfileImageViewController
            importPictureController.delegate = self

            present(importPictureController, animated: true, completion: nil)
        }
    }

    func logout() {

        /*The actual logout will be done by the login view controller. We do this this way becase there seems to be a bug in iOS. 
         We are calling dismissViewController from the presenting controller that is first in the controller stack (i.e. AppDelegate.mainNavigationController).
         As a consequence, all intermediate controllers will also be dismissed behind the scenes.
         
         From Apple docs:
         
         "If you present several view controllers in succession, thus building a stack of presented view controllers, calling this method on a view controller lower
         in the stack dismisses its immediate child view controller and all view controllers above that child on the stack. When this happens, only the top-most view 
         is dismissed in an animated fashion; any intermediate view controllers are simply removed from the stack. The top-most view is dismissed using its modal transition 
         style, which may differ from the styles used by other view controllers lower in the stack."
         
         The problem is that view(Will/Did)Appear is being called on all intermediate controllers without them ever appearing on screen, causing unexpected behavior if
         we did the actual logout procedure here*/

        DispatchQueue.main.async {

            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            appDelegate.loggingOut = true
            appDelegate.mainNavigationController.dismiss(animated: true, completion: nil)
        }
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {

        phoneNumberCell.setSelected(false, animated: true)
        
        if let newNumber = alertView.textField(at: 0)?.text, !newNumber.isEmpty {
//            enHueco.appUser.phoneNumber = newNumber
/*
            AppUserInformationManager.shared.pushPhoneNumber(newNumber) {
                success, error in

                guard success && error == nil else
                {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    return
                }

                UIView.animateWithDuration(0.4) {
                    self.phoneNumberCell.textLabel?.text = enHueco.appUser.phoneNumber
                }
            }
*/
        }
    }
 
}

extension SettingsEmbeddedTableViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager) {
        refreshUIData()
    }
}

extension SettingsEmbeddedTableViewController: ImportProfileImageViewControllerDelegate {
    
    func importProfileImageViewControllerDidFinishImportingImage(_ controller: ImportProfileImageViewController) {

        dismiss(animated: true, completion: nil)
    }

    func importProfileImageViewControllerDidCancel(_ controller: ImportProfileImageViewController) {

        dismiss(animated: true, completion: nil)
    }
}
