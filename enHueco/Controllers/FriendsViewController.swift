//
//  FriendsViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SimpleAlert

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var friendRequestsNotificationsIndicator: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    var emptyLabel : UILabel!
    let searchBar = UISearchBar()
    
    var lastUpdatesFetchDate = NSDate()

    //For performance
    var friends = [User]()
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAddFriend:"), name: EHSystemNotification.SystemDidAddFriend, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendAndScheduleUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: system)        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendRequestUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: system)

        topBarBackgroundView.backgroundColor = EHIntefaceColor.homeTopBarsColor
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        emptyLabel = UILabel()
        emptyLabel.text = "No tienes amigos. \r\n Selecciona + para agregar uno"
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.lineBreakMode = .ByWordWrapping
        emptyLabel.numberOfLines = 0
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        emptyLabel.center = tableView.center
        
        friendRequestsNotificationsIndicator.clipsToBounds = true
        friendRequestsNotificationsIndicator.layer.cornerRadius = friendRequestsNotificationsIndicator.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        refreshInformation()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        friendRequestsNotificationsIndicator.hidden = system.appUser.incomingFriendRequests.isEmpty
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
        
        if system.appUser.friends.isEmpty
        {
            tableView.hidden = true
            view.addSubview(emptyLabel)
        }
        else
        {
            tableView.hidden = false
            emptyLabel.removeFromSuperview()
        }
        
        let timeSinceLastUpdatesFetch = NSDate().timeIntervalSinceDate(lastUpdatesFetchDate)
        
        if timeSinceLastUpdatesFetch > 3 //3 seconds
        {
            lastUpdatesFetchDate = NSDate()
            
            system.appUser.fetchUpdatesForFriendsAndFriendSchedules()
            system.appUser.fetchUpdatesForFriendRequests()
        }
    }

    @IBAction func addFriendButtonPressed(sender: AnyObject)
    {
        let actionSheet = SimpleAlert.Controller(title: nil, message: nil, style: .ActionSheet)
        
        actionSheet.configContentView = {(view: UIView!) -> Void in
         
            view.backgroundColor = EHIntefaceColor.mainInterfaceColor
        }
                
        actionSheet.addAction(SimpleAlert.Action(title: "Buscar usuario", style: .Default) { (action) -> Void in
            
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("SearchNewFriendViewController") as! SearchNewFriendViewController
            self.presentViewController(viewController, animated: true, completion: nil)
        })
        
        actionSheet.addAction(SimpleAlert.Action(title: "Agregar por QR", style: .Default, handler: { (action) -> Void in
            
            let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("AddFriendByQRViewController") as! AddFriendByQRViewController
            self.presentViewController(viewController, animated: true, completion: nil)

        }))
        
        //presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func refreshInformation()
    {
        friends = Array(system.appUser.friends.values)
        UIView.transitionWithView(self.tableView,
            duration:0.4,
            options:.TransitionCrossDissolve,
            animations:
            { () -> Void in
                self.tableView.reloadData()
            },
            completion: nil);
    }

    // MARK: Notification Center
    
    func systemDidAddFriend(notification: NSNotification)
    {
        refreshInformation()
    }
    
    func systemDidReceiveFriendAndScheduleUpdates(notification: NSNotification)
    {
        refreshInformation()
    }
    
    func systemDidReceiveFriendRequestUpdates(notification: NSNotification)
    {
        friendRequestsNotificationsIndicator.hidden = system.appUser.incomingFriendRequests.isEmpty
    }
    
    // MARK: SW TableView Cell
    
    
    
    // MARK: TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return system.appUser.friends.count
    }
    
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let more = UITableViewRowAction(style: .Normal, title: "More") { action, index in
//            print("more button tapped")
//        }
//        more.backgroundColor = UIColor.lightGrayColor()
//        
//        return [more]
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friend = friends[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsCell
        cell.friendNameLabel.text = friend.name
        cell.backgroundColor = tableView.backgroundView?.backgroundColor
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = friends[indexPath.row]
        
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        //friendDetailViewController.hidesBottomBarWhenPushed = true
        
        splitViewController?.showDetailViewController(friendDetailViewController, sender: self)
    }
    

}
