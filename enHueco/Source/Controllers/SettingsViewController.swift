//
//  SettingsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 11/25/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func exitButtonPressed(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)
    }
}
