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

    fileprivate var realtimeFriendRequestsManager: RealtimeFriendRequestsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestsTableView.dataSource = self
        requestsTableView.delegate = self
        requestsTableView.allowsSelection = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.mainInterfaceColor
        navigationController?.navigationBar.tintColor = UIColor.white

        EHProgressHUD.showSpinnerInView(view)
        realtimeFriendRequestsManager = RealtimeFriendRequestsManager(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeFriendRequestsManager = nil
    }

    @IBAction func addFriendButtonPressed(_ sender: AnyObject) {

        let viewController = storyboard!.instantiateViewController(withIdentifier: "SearchNewFriendViewController") as! SearchNewFriendViewController
        viewController.modalPresentationStyle = .overCurrentContext

        present(viewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func incomingOutgoingSegmentedControlDidChangeValue(_ sender: AnyObject) {
        requestsTableView.reloadData()
    }
}

extension FriendRequestsViewController: RealtimeFriendRequestsManagerDelegate {
    
    func realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(_ manager: RealtimeFriendRequestsManager) {
        
        EHProgressHUD.dismissAllSpinnersForView(self.view)
        requestsTableView.reloadData()
    }
}

extension FriendRequestsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let realtimeFriendRequestsManager = realtimeFriendRequestsManager else { return 0 }
        
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0 {
            return realtimeFriendRequestsManager.receivedFriendRequests.count
        } else {
            return realtimeFriendRequestsManager.sentFriendRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0 {
            
            let cell = requestsTableView.dequeueReusableCell(withIdentifier: "IncomingFriendRequestCell") as! IncomingFriendRequestCell
            
            let requestFriend = realtimeFriendRequestsManager!.receivedFriendRequests[indexPath.row]
            
            cell.friendNameLabel.text = requestFriend.name
            
            cell.friendImageImageView.clipsToBounds = true
            cell.friendImageImageView.layer.cornerRadius = 50.0 / 2.0
            cell.friendImageImageView.image = nil
            cell.friendImageImageView.contentMode = .scaleAspectFill
            
            SDWebImageManager().downloadImage(with: requestFriend.image as URL!, options: SDWebImageOptions.allowInvalidSSLCertificates, progress: nil) {
                (image, error, cacheType, bool, url) -> Void in
                
                guard error == nil else { return }
                
                if cacheType == SDImageCacheType.none || cacheType == SDImageCacheType.disk {
                    cell.friendImageImageView.alpha = 0
                    cell.friendImageImageView.image = image
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.friendImageImageView.alpha = 1
                    }) 
                    
                } else if cacheType == SDImageCacheType.memory {
                    cell.friendImageImageView.image = image
                }
            }
            
            cell.acceptButton.layer.cornerRadius = 4
            
            cell.deleteButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.deleteButton.layer.borderWidth = 1
            cell.deleteButton.layer.cornerRadius = 4
            
            cell.delegate = self
            
            return cell
            
        } else {
            
            let cell = requestsTableView.dequeueReusableCell(withIdentifier: "OutgoingFriendRequestCell") as! OutgoingFriendRequestCell
            return cell
        }
    }
}

extension FriendRequestsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}

extension FriendRequestsViewController: IncomingFriendRequestCellDelegate {
    
    func didPressAcceptButtonInIncomingFriendRequestCell(_ cell: IncomingFriendRequestCell) {
        
        guard let realtimeFriendRequestsManager = realtimeFriendRequestsManager,
              let indexPath = requestsTableView.indexPath(for: cell) else {
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
    
    func didPressDiscardButtonInIncomingFriendRequestCell(_ cell: IncomingFriendRequestCell) {
        
        let indexPath = requestsTableView.indexPath(for: cell)
        
        // TODO:
    }
}
