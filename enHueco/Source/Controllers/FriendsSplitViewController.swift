//
//  FriendsSplitViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/30/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(FriendsSplitViewController.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func orientationChanged(_ notification: Notification) {

        switch UIApplication.shared.statusBarOrientation {

        case .portrait, .portraitUpsideDown:

            preferredDisplayMode = .primaryHidden

        default: break

        }
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
