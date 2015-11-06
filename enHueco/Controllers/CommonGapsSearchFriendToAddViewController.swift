//
//  CommonGapsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/9/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol CommonGapsSearchFriendToAddViewControllerDelegate: class
{
    func commonGapsSearchFriendToAddViewController(controller: CommonGapsSearchFriendToAddViewController, didSelectFriend friend: User)
}

class CommonGapsSearchFriendToAddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var resultsTableView: UITableView!
    
    var filteredFriends = system.appUser.friends
    
    weak var delegate: CommonGapsSearchFriendToAddViewControllerDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friend = filteredFriends[indexPath.row]
        
        let cell = resultsTableView.dequeueReusableCellWithIdentifier("CommonGapsSearchFriendToAddResultsCell") as! CommonGapsSearchFriendToAddResultsCell
        
        cell.friendNameLabel.text = friend.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = filteredFriends[indexPath.row]
        delegate?.commonGapsSearchFriendToAddViewController(self, didSelectFriend: friend)
    }
    
    func filterContentForSearchText(searchText: String)
    {
        if searchText == ""
        {
            filteredFriends = system.appUser.friends
        }
        else
        {
            filteredFriends = system.appUser.friends.filter({(user: User) -> Bool in
                
                return user.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || user.username.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            })
        }
        
        resultsTableView.reloadData()
    }
}
