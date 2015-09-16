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
    @IBOutlet weak var tableView: UITableView!
    var friendsAndGaps = [(friend: User, gap: Gap)]()
    
    override func viewDidLoad()
    {
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        self.friendsAndGaps = system.appUser.friendsCurrentlyInGap()
        self.tableView.reloadData()
        
        var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        emptyLabel.text = "No tienes amigos en hueco"
        emptyLabel.textColor = UIColor.grayColor()
        emptyLabel.textAlignment = NSTextAlignment.Center
        
        if(friendsAndGaps.count == 0 ){
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else {
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        return self.friendsAndGaps.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friendAndGap = self.friendsAndGaps[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InGapFriendCell") as! InGapFriendCell
        cell.friendNameLabel.text = friendAndGap.friend.name
        cell.friendUsernameLabel.text = self.friendsAndGaps[indexPath.row].friend.username
        
        // TODO: Update InGapFriendCell image to match friend.
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = system.appUser.friends[indexPath.row]
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        
        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
}
