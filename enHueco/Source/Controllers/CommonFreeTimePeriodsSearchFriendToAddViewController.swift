//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/9/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate: class {
    func commonFreeTimePeriodsSearchFriendToAddViewController(_ controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friendID: String)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        realtimeFriendsManager = RealtimeFriendsManager(delegate: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
            guard let friend = $0.friend, let schedule = $0.schedule else { return nil }
            return (friend, schedule)
        }
    }

    func filterContentForSearchText(_ searchText: String) {

        reloadFriendsData()
        
        defer {
            resultsTableView.reloadData()
        }
        
        guard searchText != "" else { return }
        
        filteredFriendsAndSchedules = filteredFriendsAndSchedules.filter {
            return $0.friend.name.lowercased().range(of: searchText.lowercased()) != nil
        }
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriendsAndSchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friend = filteredFriendsAndSchedules[indexPath.row].friend
        
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "CommonFreeTimePeriodsSearchFriendToAddResultsCell") as! CommonFreeTimePeriodsSearchFriendToAddResultsCell
        cell.friendNameLabel.text = friend.name
        
        return cell
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let friend = filteredFriendsAndSchedules[indexPath.row].friend
        delegate?.commonFreeTimePeriodsSearchFriendToAddViewController(self, didSelectFriend: friend.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CommonFreeTimePeriodsSearchFriendToAddViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeFriendsManager) {
        reloadFriendsData()
        resultsTableView.reloadData()
    }    
}
