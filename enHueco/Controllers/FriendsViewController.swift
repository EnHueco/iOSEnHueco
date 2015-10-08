//
//  FriendsViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var friendRequestsNotificationsIndicator: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    var emptyLabel : UILabel?
    
    let searchBar = UISearchBar()
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAddFriend:"), name: EHSystemNotification.SystemDidAddFriend.rawValue, object: system)

        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        searchBar.sizeToFit()
        friendsTableView.tableHeaderView = searchBar
        
        emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        emptyLabel!.text = "No tienes amigos. \r\n Selecciona + para agregar uno"
        emptyLabel!.lineBreakMode = .ByWordWrapping
        emptyLabel!.numberOfLines = 0
        emptyLabel!.textColor = UIColor.grayColor()
        emptyLabel!.textAlignment = NSTextAlignment.Center
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        friendRequestsNotificationsIndicator.clipsToBounds = true
        friendRequestsNotificationsIndicator.layer.cornerRadius = friendRequestsNotificationsIndicator.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        friendsTableView.reloadData()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if system.appUser.friends.count == 0
        {
            friendsTableView.backgroundView = emptyLabel
            friendsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        else
        {
            friendsTableView.backgroundView = nil
            friendsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            friendsTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let selectedIndex = friendsTableView.indexPathForSelectedRow
        {
            friendsTableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
        
        if system.appUser.friends.count == 0
        {
            friendsTableView.backgroundView = emptyLabel
            friendsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        else
        {
            friendsTableView.backgroundView = nil
            friendsTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            friendsTableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }

    @IBAction func addFriendButtonPressed(sender: AnyObject)
    {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("AddFriendViewController") as! AddFriendViewController
    }
    
    func systemDidAddFriend(notification: NSNotification)
    {
        friendsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return system.appUser.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friend = system.appUser.friends[indexPath.row]
        
        let cell = friendsTableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsCell
        cell.friendNameLabel.text = friend.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = system.appUser.friends[indexPath.row]
        
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        //friendDetailViewController.hidesBottomBarWhenPushed = true
        
        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }
}
