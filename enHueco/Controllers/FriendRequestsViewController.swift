//
//  FriendRequestsViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendRequestsViewController: UIViewController, UITableViewDataSource, IncomingFriendRequestCellDelegate
{
    @IBOutlet weak var incomingOutgoingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requestsTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAcceptFriendRequest:"), name:EHSystemNotification.SystemDidAcceptFriendRequest, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidFailToAcceptFriendRequest:"), name:EHSystemNotification.SystemDidFailToAcceptFriendRequest, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendRequestUpdates:"), name:EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: system)

        view.backgroundColor = EHInterfaceColor.defaultColoredBackgroundColor
        
        requestsTableView.dataSource = self
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
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("OutgoingFriendRequestCell") as! OutgoingFriendRequestCell
            
            return cell
        }
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
