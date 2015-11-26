//
//  InGapViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var friendsAndGaps = [(friend: User, gap: Event)]()
    var emptyLabel : UILabel!
    
    let searchBar = UISearchBar()
    
    override func viewDidLoad()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidReceiveFriendAndScheduleUpdates:"), name: EHSystemNotification.SystemDidReceiveFriendAndScheduleUpdates, object: system)
        
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

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
        
        updateGapsDataAndReloadTableView()
    }
    
    func updateGapsDataAndReloadTableView()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.friendsAndGaps = system.appUser.friendsCurrentlyInGap()
            
            if self.friendsAndGaps.isEmpty
            {
                self.tableView.hidden = true
                self.view.addSubview(self.emptyLabel)
            }
            else
            {
                self.tableView.hidden = false
                self.emptyLabel.removeFromSuperview()
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        system.appUser.fetchUpdatesForFriendsAndFriendSchedules()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    // MARK: TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        return self.friendsAndGaps.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friendAndGap = self.friendsAndGaps[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InGapFriendCell") as! InGapFriendCell
        cell.friendNameLabel.text = friendAndGap.friend.name
        
        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        let currentDate = NSDate()
        let gapEndHour = friendAndGap.gap.endHour
        let gapEndHourWithTodaysDate = globalCalendar.dateBySettingHour(gapEndHour.hour, minute: gapEndHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
        
        let (currentGap, nextGap) = friendAndGap.friend.currentAndNextGap()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"

        if let currentGap = currentGap
        {
            cell.timeLeftUntilNextEventLabel.text = "↘ \( formatter.stringFromDate(currentGap.endHourInDate(NSDate())) )"
        }
        
        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 70/2
        
        cell.friendImageImageView.contentMode = .ScaleAspectFill
        cell.friendImageImageView.sd_setImageWithURL(friendAndGap.friend.imageURL)
        
        // TODO: Update InGapFriendCell image to match friend.
        
        return cell
    }
        
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = friendsAndGaps[indexPath.row].friend
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        
        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }
    
    func systemDidReceiveFriendAndScheduleUpdates(notification: NSNotification)
    {
        updateGapsDataAndReloadTableView()
    }
}
