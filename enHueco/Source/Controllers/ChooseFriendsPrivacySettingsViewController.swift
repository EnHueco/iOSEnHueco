//
//  ChooseFriendsPrivacySettingsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/2/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ChooseFriendsPrivacySettingsViewController: UIViewController, SearchSelectFriendsViewControllerDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.tintColor = EHInterfaceColor.defaultNavigationBarColor
    }

    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {

        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.addButtonPressed(_:))), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.doneButtonPressed(_:))), animated: true)

        navigationItem.setHidesBackButton(true, animated: true)
    }

    func addButtonPressed(_ sender: UIBarButtonItem) {

        let controller = storyboard?.instantiateViewController(withIdentifier: "SearchSelectFriendsViewController") as! SearchSelectFriendsViewController

        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    func doneButtonPressed(_ sender: UIBarButtonItem) {

        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ChooseFriendsPrivacySettingsViewController.editButtonPressed(_:))), animated: true)
        navigationItem.setLeftBarButton(nil, animated: true)

        navigationItem.setHidesBackButton(false, animated: true)
    }

    @IBAction func segmentedControlSelectionChanged(_ sender: UISegmentedControl) {

    }

    func searchSelectFriendsViewController(_ controller: SearchSelectFriendsViewController, didSelectFriends friends: [User]) {

    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
