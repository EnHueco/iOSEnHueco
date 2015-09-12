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
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAddFriend:"), name: EHSystemNotification.SystemDidAddFriend.rawValue, object: system)

        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        system.createTestAppUser()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        friendsTableView.reloadData()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = system.appUser.friends[indexPath.row]
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        
        navigationController!.pushViewController(friendDetailViewController, animated: true)
        
    }
}
