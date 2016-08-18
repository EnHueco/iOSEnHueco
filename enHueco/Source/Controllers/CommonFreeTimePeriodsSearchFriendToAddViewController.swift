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

class CommonFreeTimePeriodsSearchFriendToAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var resultsTableView: UITableView!

    var filteredFriends = Array(enHueco.appUser.friends.values)

    weak var delegate: CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate?

    override func viewDidLoad() {

        super.viewDidLoad()

        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredFriends.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let friend = filteredFriends[indexPath.row]

        let cell = resultsTableView.dequeueReusableCellWithIdentifier("CommonFreeTimePeriodsSearchFriendToAddResultsCell") as! CommonFreeTimePeriodsSearchFriendToAddResultsCell

        cell.friendNameLabel.text = friend.name

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let friend = filteredFriends[indexPath.row]
        delegate?.commonFreeTimePeriodsSearchFriendToAddViewController(self, didSelectFriend: friend)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func filterContentForSearchText(searchText: String) {

        if searchText == "" {
            filteredFriends = Array(enHueco.appUser.friends.values)
        } else {
            filteredFriends = Array(enHueco.appUser.friends.values).filter({
                (user: User) -> Bool in

                return user.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || user.username.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            })
        }

        resultsTableView.reloadData()
    }
}
