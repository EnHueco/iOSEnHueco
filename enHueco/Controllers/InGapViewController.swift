//
//  InGapViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var filteredFriendsAndGaps = [(friend: User, gap: Event)]()
    var filteredSoonInGapfriendsAndGaps = [(friend: User, gap: Event)]()
    
    var emptyLabel: UILabel!

    let searchBar = UISearchBar()
    
    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendAndScheduleUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: nil)

        tableView.dataSource = self
        tableView.delegate = self

        emptyLabel = UILabel()
        emptyLabel.text = "Nadie por ahí... \n No tienes amigos en hueco"
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()

        searchBar.delegate = self
        
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: Selector("resignFirstResponder"))
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
            return "Ahora"
        }
        else
        {
            return "Próximamente"
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
        
        system.appUser.fetchUpdatesForFriendsAndFriendSchedules()

        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }

        updateGapsDataAndReloadTableView()
    }

    func systemDidReceiveFriendAndScheduleUpdates(notification: NSNotification)
    {
        updateGapsDataAndReloadTableView()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }

    func updateGapsDataAndReloadTableView()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.filteredFriendsAndGaps = system.appUser.friendsCurrentlyInGap()
            self.filteredSoonInGapfriendsAndGaps = system.appUser.friendsSoonInGapWithinTimeInterval(3600)

            if self.filteredFriendsAndGaps.isEmpty && self.filteredSoonInGapfriendsAndGaps.isEmpty
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
            self.filteredFriendsAndGaps = system.appUser.friendsCurrentlyInGap()
            self.filteredSoonInGapfriendsAndGaps = system.appUser.friendsSoonInGapWithinTimeInterval(3600)
            
            if !searchText.isBlank()
            {
                self.filteredFriendsAndGaps = self.filteredFriendsAndGaps.filter { $0.friend.name.lowercaseString.containsString(searchText.lowercaseString) }
                self.filteredSoonInGapfriendsAndGaps = self.filteredSoonInGapfriendsAndGaps.filter { $0.friend.name.lowercaseString.containsString(searchText.lowercaseString) }
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: TableView Delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return filteredFriendsAndGaps.count
        }
        else if section == 1
        {
            return filteredSoonInGapfriendsAndGaps.count
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
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InGapFriendCell") as! InGapFriendCell
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        
        cell.gapStartOrEndHourIconImageView.tintColor = cell.gapStartOrEndHourLabel.textColor

        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"

        var (friend, gap): (User, Event)

        if indexPath.section == 0
        {
            (friend, gap) = self.filteredFriendsAndGaps[indexPath.row]

            cell.gapStartOrEndHourLabel.text = formatter.stringFromDate(gap.endHourInDate(NSDate()))
            cell.gapStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        else
        {
            (friend, gap) = self.filteredSoonInGapfriendsAndGaps[indexPath.row]
       
            cell.gapStartOrEndHourLabel.text = formatter.stringFromDate(gap.startHourInDate(NSDate()))
            cell.gapStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        cell.friendUsername = friend.username
        
        cell.gapNameAndLocationLabel.text = gap.name
        
        let url = friend.imageURL

        cell.friendNameLabel.text = friend.name
        
        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 70 / 2
        cell.friendImageImageView.image = nil
        cell.friendImageImageView.contentMode = .ScaleAspectFill

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
            friend = filteredFriendsAndGaps[indexPath.row].friend
        }
        else
        {
            friend = filteredSoonInGapfriendsAndGaps[indexPath.row].friend
        }
        
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend

        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }


    // MARK: SW Table View
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int)
    {
        if let cell = cell as? InGapFriendCell, friend = system.appUser.friends[cell.friendUsername!]
        {
            switch index
            {
                case 0:
                    system.getFriendABID(friend.phoneNumber, onSuccess: {
                        (abid) -> () in
                        system.whatsappMessageTo(abid)
                    })
                    break
                case 1:
                    system.callFriend(friend.phoneNumber)
                    break
                default:
                    break
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
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 29.0 / 255.0, green: 161.0 / 255.0, blue: 0, alpha: 1.0), title: "Escribir")
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 67.0 / 255.0, green: 142.0 / 255.0, blue: 1, alpha: 0.75), title: "Llamar")

        return rightUtilityButtons
    }
}
