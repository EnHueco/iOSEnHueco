//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/9/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate: class {
    func commonFreeTimePeriodsSearchFriendToAddViewController(controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friend: User)
}

class CommonFreeTimePeriodsSearchFriendToAddViewController: UIViewController {
    @IBOutlet weak var resultsTableView: UITableView!

    var realtimeFriendsManager: RealtimeFriendsManager?
    
    var filteredFriendsAndSchedules = [(friend: User, schedule: Schedule)]()

    weak var delegate: CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        realtimeFriendsManager = RealtimeFriendsManager(delegate: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeFriendsManager = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Reloads the friends and schedules array
    func reloadFriendsData() {
        
        guard let friendsManager = realtimeFriendsManager else { return }
        
        filteredFriendsAndSchedules = friendsManager.friendAndSchedules().flatMap {
            guard let friend = $0.friend, schedule = $0.schedule else { return nil }
            return (friend, schedule)
        }
    }

    func filterContentForSearchText(searchText: String) {

        reloadFriendsData()
        
        defer {
            resultsTableView.reloadData()
        }
        
        guard searchText != "" else { return }
        
        filteredFriendsAndSchedules = filteredFriendsAndSchedules.filter {
            
            return $0.friend.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || $0.friend.username.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        }
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let friend = filteredFriends[indexPath.row]
        
        let cell = resultsTableView.dequeueReusableCellWithIdentifier("CommonFreeTimePeriodsSearchFriendToAddResultsCell") as! CommonFreeTimePeriodsSearchFriendToAddResultsCell
        
        cell.friendNameLabel.text = friend.name
        
        return cell
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let friend = filteredFriends[indexPath.row]
        delegate?.commonFreeTimePeriodsSearchFriendToAddViewController(self, didSelectFriend: friend)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendsManagerDelegate) {
        reloadFriendsData()
        resultsTableView.reloadData()
    }
}