//
//  InGapViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var friendsAndGaps = [(friend: User, gap: Event)]()
    var soonInGapfriendsAndGaps = [(friend: User, gap: Event)]()
    var emptyLabel: UILabel!

    let searchBar = UISearchBar()

    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendAndScheduleUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: nil)

        topBarBackgroundView.backgroundColor = EHIntefaceColor.homeTopBarsColor

        tableView.dataSource = self
        tableView.delegate = self

        emptyLabel = UILabel()
        emptyLabel.text = "Nadie por ahí... \n No tienes amigos en hueco"
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = .Center
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()

        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
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
        navigationController?.setNavigationBarHidden(true, animated: false)
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

    func updateGapsDataAndReloadTableView()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.friendsAndGaps = system.appUser.friendsCurrentlyInGap()
            self.soonInGapfriendsAndGaps = system.appUser.friendsSoonInGapWithinTimeInterval(3600)

            self.tableView.reloadData()

            if self.friendsAndGaps.isEmpty && self.soonInGapfriendsAndGaps.isEmpty
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

            }, completion: nil);
        }
    }

    override func viewDidAppear(animated: Bool)
    {
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }

    // MARK: TableView Delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        if section == 0
        {
            return self.friendsAndGaps.count
        }
        else if section == 1
        {
            return self.soonInGapfriendsAndGaps.count
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

        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"

        var (friend, currentGap): (User, Event)

        if indexPath.section == 0
        {
            (friend, currentGap) = self.friendsAndGaps[indexPath.row]

            cell.friendUsername = self.friendsAndGaps[indexPath.row].friend.username
            cell.timeLeftUntilNextEventLabel.text = "🕐 \(formatter.stringFromDate(currentGap.endHourInDate(NSDate())))"
        }
        else
        {
            (friend, currentGap) = self.soonInGapfriendsAndGaps[indexPath.row]

            cell.friendUsername = self.soonInGapfriendsAndGaps[indexPath.row].friend.username
            cell.timeLeftUntilNextEventLabel.text = "🕐 \(formatter.stringFromDate(currentGap.endHourInDate(NSDate())))"
        }

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
        let friend = friendsAndGaps[indexPath.row].friend
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
