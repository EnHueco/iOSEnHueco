//
//  FriendsViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SWTableViewCell
import SDWebImage
import RKNotificationHub

class FriendsViewController: UIViewController, ServerPoller
{
    @IBOutlet weak var tableView: UITableView!

    var emptyLabel: UILabel!
    let searchBar = UISearchBar()
    
    var requestTimer = NSTimer()
    var pollingInterval = 10.0
    
    
    /// Notification indicator for the friend requests button. Set count to change the number (animatable)
    private(set) var friendRequestsNotificationHub: RKNotificationHub!

    //For safety and performance (because friends is originally a dictionary)
    var filteredFriends = Array(enHueco.appUser.friends.values)
    
    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad()
    {
        tableView.dataSource = self
        tableView.delegate = self

        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        searchBar.delegate = self
        
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor

        createEmptyLabel()
        
        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: #selector(UIResponder.resignFirstResponder))
        
        let friendRequestsButton = UIButton(type: .Custom)
        friendRequestsButton.frame.size = CGSize(width: 20, height: 20)
        friendRequestsButton.setBackgroundImage(UIImage(named: "FriendRequests")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        friendRequestsButton.addTarget(self, action: #selector(FriendsViewController.friendRequestsButtonPressed(_:)), forControlEvents: .TouchUpInside)
        friendRequestsButton.tintColor = UIColor.whiteColor()
        
        friendRequestsNotificationHub = RKNotificationHub(view: friendRequestsButton)
        friendRequestsNotificationHub.scaleCircleSizeBy(0.45)
        friendRequestsNotificationHub.moveCircleByX(0, y: -2)
        friendRequestsNotificationHub.setCircleColor(UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), labelColor: UIColor.whiteColor())
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: friendRequestsButton)

        let commonFreeTimeButton = UIButton(type: .Custom)
        commonFreeTimeButton.frame.size = CGSize(width: 20, height: 20)
        commonFreeTimeButton.setBackgroundImage(UIImage(named: "CommonFreeTime")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        commonFreeTimeButton.addTarget(self, action: #selector(FriendsViewController.commonFreeTimeButtonPressed(_:)), forControlEvents: .TouchUpInside)
        commonFreeTimeButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: commonFreeTimeButton)
    }

    func createEmptyLabel()
    {
        emptyLabel = UILabel()
        emptyLabel.text = "NoFriendsMessage".localizedUsingGeneralFile()
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.lineBreakMode = .ByWordWrapping
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        emptyLabel.center = tableView.center
    }

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

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

        if enHueco.appUser.incomingFriendRequests.count > 10
        {
            friendRequestsNotificationHub.hideCount()
        }
        else
        {
            friendRequestsNotificationHub.showCount()
        }

        reloadFriendsAndTableView()
        startPolling()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopPolling()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
        
        friendRequestsNotificationHub.count = UInt(enHueco.appUser.incomingFriendRequests.count)
        friendRequestsNotificationHub.pop()
    }
    
    func friendRequestsButtonPressed(sender: UIButton)
    {
        navigationController?.showViewController(storyboard!.instantiateViewControllerWithIdentifier("FriendRequestsViewController"), sender: self)
    }
    
    func commonFreeTimeButtonPressed(sender: UIButton)
    {
        navigationController?.showViewController(storyboard!.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsViewController"), sender: self)
    }
    
    func reloadFriendsAndTableView()
    {
        filteredFriends = Array(enHueco.appUser.friends.values)

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
    
    // Server Polling
    
    func startPolling()
    {
        requestTimer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: #selector(FriendsViewController.pollFromServer), userInfo: nil, repeats: true)
        requestTimer.fire()
    }
    
    func pollFromServer()
    {
        FriendsManager.sharedManager.fetchUpdatesForFriendsAndFriendSchedulesWithCompletionHandler { success, error in
            self.reloadFriendsAndTableView()
        }
        
        FriendsManager.sharedManager.fetchUpdatesForFriendRequestsWithCompletionHandler { success, error in
            
            self.friendRequestsNotificationHub.count = UInt(enHueco.appUser.incomingFriendRequests.count)
            self.friendRequestsNotificationHub.pop()
        }
    }

    
}


extension FriendsViewController: UITableViewDataSource
{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredFriends.count
    }

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
            let currentFreeTimePeriodEndDate = currentFreeTimePeriod.endHourInDate(NSDate())
            
            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(currentFreeTimePeriodEndDate)
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")
            
            if let nextEvent = friend.nextEvent(), nextEventName = nextEvent.name
                where nextEvent.type == .Class && nextEvent.startHourInDate(NSDate()).timeIntervalSinceDate(currentFreeTimePeriodEndDate) < 60*10000
            {
                cell.eventNameOrLocationLabel.text = nextEventName
                
                if let nextEventLocation = nextEvent.location
                {
                    cell.eventNameOrLocationLabel.text! += " (" + nextEventLocation + ")"
                }
            }
        }
        else if let nextFreeTimePeriod = nextFreeTimePeriod
        {
            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(nextFreeTimePeriod.startHourInDate(NSDate()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")
            cell.eventNameOrLocationLabel.text = nextFreeTimePeriod.name ?? "FreeTime".localizedUsingGeneralFile()
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
        
        SDWebImageManager().downloadImageWithURL(friend.imageThumbnailURL, options: SDWebImageOptions.AllowInvalidSSLCertificates, progress: nil, completed: {(image, error, cacheType, bool, url) -> Void in
            
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
}

extension FriendsViewController: UITableViewDelegate
{
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

extension FriendsViewController: UISearchBarDelegate
{
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
        filteredFriends = Array(enHueco.appUser.friends.values)
        
        if !searchText.isBlank()
        {
            filteredFriends = filteredFriends.filter { $0.name.lowercaseString.containsString(searchText.lowercaseString) }
        }
        
        tableView.reloadData()
    }
}
