//
//  FriendRequestsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, IncomingFriendRequestCellDelegate
{
    @IBOutlet weak var incomingOutgoingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requestsTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Solicitudes"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAcceptFriendRequest:"), name:EHSystemNotification.SystemDidAcceptFriendRequest, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidFailToAcceptFriendRequest:"), name:EHSystemNotification.SystemDidFailToAcceptFriendRequest, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendRequestUpdates:"), name:EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: system)

        //view.backgroundColor = EHInterfaceColor.defaultColoredBackgroundColor
        
        requestsTableView.dataSource = self
        requestsTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHInterfaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        MRProgressOverlayView.showOverlayAddedTo(view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHInterfaceColor.mainInterfaceColor)

        system.appUser.fetchUpdatesForFriendRequests()
    }
    
    @IBAction func addFriendButtonPressed(sender: AnyObject)
    {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancelar", destructiveButtonTitle: nil)
        
        actionSheet.addButtonWithTitle("Buscar Amigo")
        actionSheet.addButtonWithTitle("Agregar por QR")
        actionSheet.showFromTabBar(tabBarController!.tabBar)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            let viewController = storyboard!.instantiateViewControllerWithIdentifier("SearchNewFriendViewController") as! SearchNewFriendViewController
            viewController.modalPresentationStyle = .OverCurrentContext
            
            presentViewController(viewController, animated: true, completion: nil)
        }
        else if buttonIndex == 2
        {
            let viewController = storyboard!.instantiateViewControllerWithIdentifier("AddFriendByQRViewController") as! AddFriendByQRViewController
            presentViewController(viewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0
        {
            return system.appUser.incomingFriendRequests.count
        }
        else
        {
            return system.appUser.outgoingFriendRequests.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if incomingOutgoingSegmentedControl.selectedSegmentIndex == 0
        {
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("IncomingFriendRequestCell") as! IncomingFriendRequestCell
            
            let requestFriend = system.appUser.incomingFriendRequests[indexPath.row]
            
            cell.friendNameLabel.text = requestFriend.name
        
            cell.friendImageImageView.clipsToBounds = true
            cell.friendImageImageView.layer.cornerRadius = 50.0 / 2.0
            cell.friendImageImageView.image = nil
            cell.friendImageImageView.contentMode = .ScaleAspectFill
            
            SDWebImageManager().downloadImageWithURL(requestFriend.imageURL, options: SDWebImageOptions.AllowInvalidSSLCertificates, progress: nil, completed: {(image, error, cacheType, bool, url) -> Void in
                
                if error == nil
                {
                    if cacheType == SDImageCacheType.None || cacheType == SDImageCacheType.Disk
                    {
                        cell.friendImageImageView.alpha = 0
                        cell.friendImageImageView.image = image
                        
                        UIView.animateWithDuration(0.5, animations: {() -> Void in
                            
                            cell.friendImageImageView.alpha = 1
                            
                            }, completion: nil)
                    }
                    else if cacheType == SDImageCacheType.Memory
                    {
                        cell.friendImageImageView.image = image
                    }
                }
            })
            
            cell.acceptButton.layer.cornerRadius = 4
            
            cell.deleteButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.deleteButton.layer.borderWidth = 1
            cell.deleteButton.layer.cornerRadius = 4
            
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("OutgoingFriendRequestCell") as! OutgoingFriendRequestCell
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 66
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func incomingOutgoingSegmentedControlDidChangeValue(sender: AnyObject)
    {
        requestsTableView.reloadData()
    }
    
    func didPressAcceptButtonInIncomingFriendRequestCell(cell: IncomingFriendRequestCell)
    {
        let indexPath = requestsTableView.indexPathForCell(cell)!
        let requestFriend = system.appUser.incomingFriendRequests[indexPath.row]

        MRProgressOverlayView.showOverlayAddedTo(view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHInterfaceColor.mainInterfaceColor)

        system.appUser.acceptFriendRequestFromFriend(requestFriend)
    }
    
    func didPressDiscardButtonInIncomingFriendRequestCell(cell: IncomingFriendRequestCell)
    {
        let indexPath = requestsTableView.indexPathForCell(cell)
        
        // TODO:
    }
    
    func systemDidAcceptFriendRequest(notification: NSNotification)
    {
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
        requestsTableView.reloadData()
    }
    
    func systemDidFailToAcceptFriendRequest(notification: NSNotification)
    {
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
        requestsTableView.reloadData()
    }
    
    func systemDidReceiveFriendRequestUpdates(notification: NSNotification)
    {
        MRProgressOverlayView.dismissAllOverlaysForView(view, animated: true)
        requestsTableView.reloadData()
    }
}
