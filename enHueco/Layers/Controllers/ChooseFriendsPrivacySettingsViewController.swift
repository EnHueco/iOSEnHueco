//
//  ChooseFriendsPrivacySettingsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/2/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ChooseFriendsPrivacySettingsViewController: UIViewController, SearchSelectFriendsViewControllerDelegate
{
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        segmentedControl.tintColor = EHInterfaceColor.defaultNavigationBarColor
    }

    @IBAction func editButtonPressed(sender: UIBarButtonItem)
    {
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.addButtonPressed(_:))), animated: true)
        navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.doneButtonPressed(_:))), animated: true)
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    func addButtonPressed(sender: UIBarButtonItem)
    {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SearchSelectFriendsViewController") as! SearchSelectFriendsViewController
        
        controller.delegate = self
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func doneButtonPressed(sender: UIBarButtonItem)
    {
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.editButtonPressed(_:))), animated: true)
        navigationItem.setLeftBarButtonItem(nil, animated: true)
        
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    @IBAction func segmentedControlSelectionChanged(sender: UISegmentedControl)
    {
    }
    
    func searchSelectFriendsViewController(controller: SearchSelectFriendsViewController, didSelectFriends friends: [User])
    {
        
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
