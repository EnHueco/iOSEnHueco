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

        view.backgroundColor = EHIntefaceColor.defaultColoredBackgroundColor
        
        requestsTableView.dataSource = self        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHIntefaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()

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
            
            cell.delegate = self
            
            return cell
        }
        else
        {
            let cell = requestsTableView.dequeueReusableCellWithIdentifier("OutgoingFriendRequestCell") as! OutgoingFriendRequestCell
            
            return cell
        }
    }
    
    @IBAction func incomingOutgoingSegmentedControlDidChangeValue(sender: AnyObject)
    {
        requestsTableView.reloadData()
    }
    
    func didPressAcceptButtonOnIncomingFriendRequestCell(cell: IncomingFriendRequestCell)
    {
        let indexPath = requestsTableView.indexPathForCell(cell)
        
        // TODO:
    }
    
    func didPressDiscardButtonOnIncomingFriendRequestCell(cell: IncomingFriendRequestCell)
    {
        let indexPath = requestsTableView.indexPathForCell(cell)
        
        // TODO:
    }
}
