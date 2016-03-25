//
//  CurrentlyAvailableViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SWTableViewCell
import SDWebImage

class CurrentlyAvailableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var filteredFriendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
    var filteredSoonFreefriendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
    
    var emptyLabel: UILabel!

    let searchBar = UISearchBar()
    
    var imInvisibleBarItem: UIBarButtonItem!
    var imAvailableBarItem: UIBarButtonItem!
    
    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CurrentlyAvailableViewController.systemDidReceiveFriendAndScheduleUpdates(_:)), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: nil)

        tableView.dataSource = self
        tableView.delegate = self

        emptyLabel = UILabel()
        emptyLabel.text = "NobodyAvailableMessage".localizedUsingGeneralFile()
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()

        searchBar.delegate = self
        
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: #selector(UIResponder.resignFirstResponder))
        
        let imInvisibleButton = UIButton(type: .Custom)
        imInvisibleButton.frame.size = CGSize(width: 20, height: 20)
        imInvisibleButton.setBackgroundImage(UIImage(named: "Eye")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        imInvisibleButton.addTarget(self, action: #selector(CurrentlyAvailableViewController.imInvisibleButtonPressed(_:)), forControlEvents: .TouchUpInside)
        imInvisibleButton.tintColor = UIColor.whiteColor()
        imInvisibleBarItem = UIBarButtonItem(customView: imInvisibleButton)
        navigationItem.leftBarButtonItem = imInvisibleBarItem
        
        let imFreeButton = UIButton(type: .Custom)
        imFreeButton.frame.size = CGSize(width: 20, height: 20)
        imFreeButton.setBackgroundImage(UIImage(named: "HandRaised")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        imFreeButton.addTarget(self, action: #selector(CurrentlyAvailableViewController.imAvailableButtonPressed(_:)), forControlEvents: .TouchUpInside)
        imFreeButton.tintColor = UIColor.whiteColor()
        imAvailableBarItem = UIBarButtonItem(customView: imFreeButton)
        navigationItem.rightBarButtonItem = imAvailableBarItem
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        emptyLabel.center = tableView.center
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            return "Now".localizedUsingGeneralFile()
        }
        else
        {
            return "Soon".localizedUsingGeneralFile()
        }
    }

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        navigationController?.setNavigationBarHidden(false, animated: false)
       
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        
        transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
            
            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
            
        }, completion:{ (context) -> Void in
                
            if context.isCancelled()
            {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)), forBarMetrics: .Default)
            }
        })
        
        FriendsManager.sharedManager().fetchUpdatesForFriendsAndFriendSchedules()

        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }

        updateFreeTimePeriodDataAndReloadTableView()
    }

    func systemDidReceiveFriendAndScheduleUpdates(notification: NSNotification)
    {
        updateFreeTimePeriodDataAndReloadTableView()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    func imInvisibleButtonPressed(sender: UIButton)
    {
        if enHueco.appUser.invisible
        {
            turnVisible()
        }
        else
        {
            turnInvisible()
        }
    }
    
    private func turnInvisible ()
    {
        let turnInvisibleForInterval = { (interval: NSTimeInterval) -> Void in
            
            EHProgressHUD.showSpinnerInView(self.view)
            PrivacyManager.sharedManager().turnInvisibleForTimeInterval(interval, completionHandler: { (success, error) -> Void in
                
                EHProgressHUD.dismissSpinnerForView(self.view)
                
                guard success && error == nil else
                {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    return
                }
                
                UIView.animateWithDuration(0.2) {
                    
                    self.imInvisibleBarItem.customView!.tintColor = enHueco.appUser.invisible ? UIColor(red: 220/255.0, green: 170/255.0, blue: 10/255.0, alpha: 1) : UIColor.whiteColor()
                }
            })
        }

        let controller = UIAlertController(title: "turn_invisible_action_sheet_title".localizedUsingGeneralFile(), message: nil, preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "turn_invisible_action_sheet_1_hour_20_minutes".localizedUsingGeneralFile(), style: .Default, handler: { (_) -> Void in
            
            turnInvisibleForInterval(80 * 60)
        }))
        
        controller.addAction(UIAlertAction(title: "turn_invisible_action_sheet_3_hours".localizedUsingGeneralFile(), style: .Default, handler: { (_) -> Void in
            
            turnInvisibleForInterval(3 * 60 * 60)
        }))
        
        controller.addAction(UIAlertAction(title: "turn_invisible_action_sheet_rest_of_day".localizedUsingGeneralFile(), style: .Default, handler: { (_) -> Void in
            
            let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            let tomorrow = globalCalendar.startOfDayForDate(NSDate().addDays(1))
            
            turnInvisibleForInterval(tomorrow.timeIntervalSinceNow)
        }))
        
        controller.addAction(UIAlertAction(title: "cancel".localizedUsingGeneralFile(), style: .Cancel, handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    private func turnVisible()
    {
        EHProgressHUD.showSpinnerInView(self.view)
        PrivacyManager.sharedManager().turnVisibleWithCompletionHandler { (success, error) -> Void in
            
            EHProgressHUD.dismissSpinnerForView(self.view)
            
            guard success && error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            UIView.animateWithDuration(0.2) {
                
                self.imInvisibleBarItem.customView!.tintColor = enHueco.appUser.invisible ? UIColor(red: 220/255.0, green: 170/255.0, blue: 10/255.0, alpha: 1) : UIColor.whiteColor()
            }
        }
    }
    
    func imAvailableButtonPressed(sender: UIButton)
    {
        enHueco.appUser.invisible = false
        
        UIView.animateWithDuration(0.2)
        {
            self.imAvailableBarItem.customView!.tintColor = enHueco.appUser.invisible ? UIColor(red: 220 / 255.0, green: 170 / 255.0, blue: 10 / 255.0, alpha: 1) : UIColor.whiteColor()
        }
        
        let instantFreeTimeViewController = storyboard!.instantiateViewControllerWithIdentifier("InstantFreeTimeViewController") as! InstantFreeTimeViewController
        instantFreeTimeViewController.showInViewController(navigationController!)
    }
    
    func resetDataArrays()
    {
        filteredFriendsAndFreeTimePeriods = CurrentStateManager.sharedManager().currentlyAvailableFriends()
        
        if let instantFreeTimePeriod = enHueco.appUser.schedule.instantFreeTimePeriod
        {
            filteredFriendsAndFreeTimePeriods.insert((enHueco.appUser, instantFreeTimePeriod), atIndex: 0)
        }
        
        filteredSoonFreefriendsAndFreeTimePeriods = CurrentStateManager.sharedManager().soonAvailableFriendsWithinTimeInterval(3600)
    }

    func updateFreeTimePeriodDataAndReloadTableView()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.resetDataArrays()
            
            if self.filteredFriendsAndFreeTimePeriods.isEmpty && self.filteredSoonFreefriendsAndFreeTimePeriods.isEmpty
            {
                self.tableView.hidden = true
                self.view.addSubview(self.emptyLabel)
            }
            else
            {
                self.tableView.hidden = false
                self.emptyLabel.removeFromSuperview()
            }

            UIView.transitionWithView(self.tableView, duration: 0.35, options: .TransitionCrossDissolve, animations: {() -> Void in

                self.tableView.reloadData()

            }, completion: nil)
        }
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
        dispatch_async(dispatch_get_main_queue())
        {
            self.resetDataArrays()
            
            if !searchText.isBlank()
            {
                self.filteredFriendsAndFreeTimePeriods = self.filteredFriendsAndFreeTimePeriods.filter { $0.friend.name.lowercaseString.containsString(searchText.lowercaseString) }
                self.filteredSoonFreefriendsAndFreeTimePeriods = self.filteredSoonFreefriendsAndFreeTimePeriods.filter { $0.friend.name.lowercaseString.containsString(searchText.lowercaseString) }
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: TableView Delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return filteredFriendsAndFreeTimePeriods.count
        }
        else if section == 1
        {
            return filteredSoonFreefriendsAndFreeTimePeriods.count
        }
        else
        {
            return 0
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("AvailableFriendCell") as! AvailableFriendCell

        cell.delegate = self
        
        cell.freeTimeStartOrEndHourIconImageView.tintColor = cell.freeTimeStartOrEndHourLabel.textColor

        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"

        var (friend, freeTime): (User, Event)

        if indexPath.section == 0
        {
            (friend, freeTime) = filteredFriendsAndFreeTimePeriods[indexPath.row]

            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(freeTime.endHourInDate(NSDate()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        else
        {
            (friend, freeTime) = filteredSoonFreefriendsAndFreeTimePeriods[indexPath.row]
       
            cell.freeTimeStartOrEndHourLabel.text = formatter.stringFromDate(freeTime.startHourInDate(NSDate()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        if friend === enHueco.appUser
        {
            cell.setInstantFreeTimeIconVisibility(visible: true)
            
            let array = NSMutableArray()
            array.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "Delete".localizedUsingGeneralFile())
            
            cell.rightUtilityButtons = array as [AnyObject]
        }
        else
        {
            cell.setInstantFreeTimeIconVisibility(visible: false)
            cell.rightUtilityButtons = rightButtons() as [AnyObject]

        }
        
        cell.friendUsername = friend.username
        cell.freeNameAndLocationLabel.text = freeTime.name ?? "FreeTime".localizedUsingGeneralFile()
        
        let url = friend.imageURL

        cell.friendNameLabel.text = friend.name
        
        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 61 / 2
        cell.friendImageImageView.image = nil
        cell.friendImageImageView.contentMode = .ScaleAspectFill
        
        cell.instantFreeTimeIcon.image = cell.instantFreeTimeIcon.image?.imageWithRenderingMode(.AlwaysTemplate)
        cell.instantFreeTimeIcon.tintColor = UIColor.grayColor()

        SDWebImageManager().downloadImageWithURL(url, options: SDWebImageOptions.AllowInvalidSSLCertificates, progress: nil,
                completed: {(image, error, cacheType, bool, url) -> Void in
                    if error == nil
                    {
                        if cacheType == SDImageCacheType.None || cacheType == SDImageCacheType.Disk
                        {
                            cell.friendImageImageView.alpha = 0
                            cell.friendImageImageView.image = image
                            UIView.animateWithDuration(0.5, animations: {
                                () -> Void in
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend: User
        
        if indexPath.section == 0
        {
            friend = filteredFriendsAndFreeTimePeriods[indexPath.row].friend
        }
        else
        {
            friend = filteredSoonFreefriendsAndFreeTimePeriods[indexPath.row].friend
        }
        
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend

        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }


    // MARK: SW Table View
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int)
    {
        if let cell = cell as? AvailableFriendCell, friend = enHueco.appUser.friends[cell.friendUsername!]
        {
            if friend === enHueco.appUser
            {
                EHProgressHUD.showSpinnerInView(view)
                CurrentStateManager.sharedManager().deleteInstantFreeTimePeriodWithCompletionHandler({ (success, error) -> Void in
                    
                    EHProgressHUD.dismissSpinnerForView(self.view)

                    guard success && error == nil else {
                        
                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }

                })
            }
            else if index == 0
            {
                enHueco.getFriendABID(friend.phoneNumber, completionHandler: {
                    (abid) -> () in
                    enHueco.whatsappMessageTo(abid)
                })
            }
            else if index == 1
            {
                enHueco.callFriend(friend.phoneNumber)
            }
        }
        cell.hideUtilityButtonsAnimated(true)
    }

    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool
    {
        return true
    }

    func rightButtons() -> NSArray
    {
        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 29.0 / 255.0, green: 161.0 / 255.0, blue: 0, alpha: 1.0), title: "WhatsApp")
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 67.0 / 255.0, green: 142.0 / 255.0, blue: 1, alpha: 0.75), title: "Call".localizedUsingGeneralFile())

        return rightUtilityButtons
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
