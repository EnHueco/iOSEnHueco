//
//  FriendRequestsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SDWebImage

class FriendRequestsViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var incomingOutgoingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requestsTableView: UITableView!

    private var realtimeFriendRequestsManager: RealtimeFriendRequestsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestsTableView.dataSource = self
        requestsTableView.delegate = self
        requestsTableView.allowsSelection = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.mainInterfaceColor
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        EHProgressHUD.showSpinnerInView(view)
        realtimeFriendRequestsManager = RealtimeFriendRequestsManager(delegate: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeFriendRequestsManager = nil
    }

    @IBAction func addFriendButtonPressed(sender: AnyObject) {

        let viewController = storyboard!.instantiateViewControllerWithIdentifier("SearchNewFriendViewController") as! SearchNewFriendViewController
        viewController.modalPresentationStyle = .OverCurrentContext

        presentViewController(viewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func incomingOutgoingSegmentedControlDidChangeValue(sender: AnyObject) {
        requestsTableView.reloadData()
    }
}

extension FriendRequestsViewController: RealtimeFriendRequestsManagerDelegate {
    
    func realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(manager: RealtimeFriendRequestsManager) {
        
        EHProgressHUD.dismissAllSpinnersForView(self.view)
        requestsTableView.reloadData()
    }
}

extension FriendRequestsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let realtimeFriendRequestsManager = realtimeFriendRequestsManager else { return }
        
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0 {
            return realtimeFriendRequestsManager.receivedFriendRequests.count
        } else {
            return realtimeFriendRequestsManager.sentFriendRequests.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0 {
            
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("IncomingFriendRequestCell") as! IncomingFriendRequestCell
            
            let requestFriend = realtimeFriendRequestsManager!.receivedFriendRequests[indexPath.row]
            
            cell.friendNameLabel.text = requestFriend.name
            
            cell.friendImageImageView.clipsToBounds = true
            cell.friendImageImageView.layer.cornerRadius = 50.0 / 2.0
            cell.friendImageImageView.image = nil
            cell.friendImageImageView.contentMode = .ScaleAspectFill
            
            SDWebImageManager().downloadImageWithURL(requestFriend.imageURL, options: SDWebImageOptions.AllowInvalidSSLCertificates, progress: nil) {
                (image, error, cacheType, bool, url) -> Void in
                
                guard error == nil else { return }
                
                if cacheType == SDImageCacheType.None || cacheType == SDImageCacheType.Disk {
                    cell.friendImageImageView.alpha = 0
                    cell.friendImageImageView.image = image
                    
                    UIView.animateWithDuration(0.5) {
                        cell.friendImageImageView.alpha = 1
                    }
                    
                } else if cacheType == SDImageCacheType.Memory {
                    cell.friendImageImageView.image = image
                }
            }
            
            cell.acceptButton.layer.cornerRadius = 4
            
            cell.deleteButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.deleteButton.layer.borderWidth = 1
            cell.deleteButton.layer.cornerRadius = 4
            
            cell.delegate = self
            
            return cell
            
        } else {
            
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("OutgoingFriendRequestCell") as! OutgoingFriendRequestCell
            return cell
        }
    }
}

extension FriendRequestsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}

extension FriendRequestsViewController: IncomingFriendRequestCellDelegate {
    
    func didPressAcceptButtonInIncomingFriendRequestCell(cell: IncomingFriendRequestCell) {
        
        guard let realtimeFriendRequestsManager = realtimeFriendRequestsManager,
              let indexPath = requestsTableView.indexPathForCell(cell) else {
            return
        }
        
        let requestFriend = realtimeFriendRequestsManager.receivedFriendRequests[indexPath.row]
        
        EHProgressHUD.showSpinnerInView(view)
        FriendsManager.sharedManager.acceptFriendRequestFrom(id: requestFriend.id, completionHandler: { (error) in
            EHProgressHUD.dismissSpinnerForView(self.view)
            
            guard error == nil else {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            self.requestsTableView.reloadData()
        })
    }
    
    func didPressDiscardButtonInIncomingFriendRequestCell(cell: IncomingFriendRequestCell) {
        
        let indexPath = requestsTableView.indexPathForCell(cell)
        
        // TODO:
    }
}
