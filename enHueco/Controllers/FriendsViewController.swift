//
//  FriendsViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SimpleAlert

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UISearchBarDelegate
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var friendRequestsNotificationsIndicator: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var emptyLabel: UILabel!
    let searchBar = UISearchBar()

    var lastUpdatesFetchDate = NSDate()

    //For safety and performance (because friends is originally a dictionary)
    var filteredFriends = Array(system.appUser.friends.values)
    
    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidAddFriend:"), name: EHSystemNotification.SystemDidAddFriend, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendAndScheduleUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendRequestUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendRequestUpdates, object: system)

        //topBarBackgroundView.backgroundColor = EHInterfaceColor.homeTopBarsColor

        tableView.dataSource = self
        tableView.delegate = self

        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        searchBar.delegate = self
        
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor

        createEmptyLabel()
        
        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: Selector("resignFirstResponder"))
        
        let friendRequestsButton = UIButton(type: .Custom)
        friendRequestsButton.frame.size = CGSize(width: 20, height: 20)
        friendRequestsButton.setBackgroundImage(UIImage(named: "FriendRequests")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        friendRequestsButton.addTarget(self, action: Selector("friendRequestsButtonPressed:"), forControlEvents: .TouchUpInside)
        friendRequestsButton.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: friendRequestsButton)

        let commonFreeTimeButton = UIButton(type: .Custom)
        commonFreeTimeButton.frame.size = CGSize(width: 20, height: 20)
        commonFreeTimeButton.setBackgroundImage(UIImage(named: "CommonFreeTime")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        commonFreeTimeButton.addTarget(self, action: Selector("commonFreeTimeButtonPressed:"), forControlEvents: .TouchUpInside)
        commonFreeTimeButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: commonFreeTimeButton)
    }

    func createEmptyLabel()
    {
        emptyLabel = UILabel()
        emptyLabel.text = "NoFriendsMessage".localized()
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.lineBreakMode = .ByWordWrapping
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        //friendRequestsNotificationsIndicator.clipsToBounds = true
        //friendRequestsNotificationsIndicator.layer.cornerRadius = friendRequestsNotificationsIndicator.frame.height / 2

        emptyLabel.center = tableView.center
    }

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        /*let animation = CATransition()
        animation.duration = 0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        
        navigationController?.navigationBar.layer.addAnimation(animation, forKey: nil)
                
        UIView.animateWithDuration(0)
        {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: EHInterfaceColor.defaultNavigationBarColor), forBarMetrics: .Default)
        }*/

        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        
        transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
            
            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
            self.navigationController?.navigationBar.shadowImage = UIImage()

        }, completion:{ (context) -> Void in
                
            if context.isCancelled()
            {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)), forBarMetrics: .Default)
            }
        })

        //friendRequestsNotificationsIndicator.hidden = system.appUser.incomingFriendRequests.isEmpty

        reloadFriendsAndTableView()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }

        let timeSinceLastUpdatesFetch = NSDate().timeIntervalSinceDate(lastUpdatesFetchDate)

        if timeSinceLastUpdatesFetch > 3 //3 seconds
        {
            lastUpdatesFetchDate = NSDate()
            fetchUpdates()
        }

    }

    func fetchUpdates()
    {
        system.appUser.fetchUpdatesForFriendsAndFriendSchedules()
        system.appUser.fetchUpdatesForFriendRequests()
    }
    
    func friendRequestsButtonPressed(sender: UIButton)
    {
        navigationController?.showViewController(storyboard!.instantiateViewControllerWithIdentifier("FriendRequestsViewController"), sender: self)
    }
    
    func commonFreeTimeButtonPressed(sender: UIButton)
    {
        navigationController?.showViewController(storyboard!.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsViewController"), sender: self)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        tableView.addGestureRecognizer(searchEndEditingGestureRecognizer)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        tableView.removeGestureRecognizer(searchEndEditingGestureRecognizer)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredFriends = Array(system.appUser.friends.values)
        
        if !searchText.isBlank()
        {
            filteredFriends = filteredFriends.filter { $0.name.lowercaseString.containsString(searchText.lowercaseString) }
        }
        
        tableView.reloadData()
    }

    func reloadFriendsAndTableView()
    {
        filteredFriends = Array(system.appUser.friends.values)

        if filteredFriends.isEmpty
        {
            tableView.hidden = true
            view.addSubview(emptyLabel)
        }
        else
        {
            tableView.hidden = false
            emptyLabel.removeFromSuperview()
        }

        UIView.transitionWithView(self.tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: {() -> Void in

            self.tableView.reloadData()

        }, completion: nil)
    }
    
    // MARK: Notification Center

    func systemDidAddFriend(notification: NSNotification)
    {
        reloadFriendsAndTableView()
    }

    func systemDidReceiveFriendAndScheduleUpdates(notification: NSNotification)
    {
        reloadFriendsAndTableView()
    }

    func systemDidReceiveFriendRequestUpdates(notification: NSNotification)
    {
        //friendRequestsNotificationsIndicator.hidden = system.appUser.incomingFriendRequests.isEmpty
    }

    // MARK: TableView Delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredFriends.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsCell

        let friend = filteredFriends[indexPath.row]
        
        cell.friendNameLabel.text = friend.name
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        cell.eventNameOrLocationLabel.text = nil
        
        cell.showFreeTimeStartEndHourIcon()
        
        let (currentFreeTimePeriod, nextFreeTimePeriod) = friend.currentAndNextFreeTimePeriods()
        
        if let currentFreeTimePeriod = currentFreeTimePeriod
        {
            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(currentFreeTimePeriod.endHourInDate(NSDate()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")
            //cell.eventNameOrLocationLabel.text = currentGap.name
        }
        else if let nextFreeTimePeriod = nextFreeTimePeriod
        {
            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(nextFreeTimePeriod.startHourInDate(NSDate()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")
            cell.eventNameOrLocationLabel.text = nextFreeTimePeriod.name ?? "FreeTime".localized()
        }
        else
        {
            cell.hideFreeTimeStartEndHourIcon()
            cell.freeTimeStartOrEndHourLabel.text = "-- --"
        }
        
        cell.backgroundColor = tableView.backgroundView?.backgroundColor
        
        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 53.0 / 2.0
        cell.friendImageImageView.image = nil
        cell.friendImageImageView.contentMode = .ScaleAspectFill
        
        SDWebImageManager().downloadImageWithURL(friend.imageURL, options: SDWebImageOptions.AllowInvalidSSLCertificates, progress: nil, completed: {(image, error, cacheType, bool, url) -> Void in
                
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

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 70
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = filteredFriends[indexPath.row]

        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        //friendDetailViewController.hidesBottomBarWhenPushed = true

        splitViewController?.showDetailViewController(friendDetailViewController, sender: self)
    }


}
