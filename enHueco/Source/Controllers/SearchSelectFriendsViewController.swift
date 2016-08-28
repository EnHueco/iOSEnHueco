//
//  SearchFriendsPrivacyViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol SearchSelectFriendsViewControllerDelegate: class {
    func searchSelectFriendsViewController(controller: SearchSelectFriendsViewController, didSelectFriends friends: [User])
}

class SearchSelectFriendsViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SearchSelectFriendsViewControllerDelegate?
    
    var filteredFriendsAndSchedules = [(friend: User, schedule: Schedule)]()

    /// The friends logic manager (if currently fetching updates)
    private var realtimeFriendsManager: RealtimeFriendsManager?

    var selectedCells = [NSIndexPath: AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barStyle = .BlackTranslucent
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        view.backgroundColor = EHInterfaceColor.defaultNavigationBarColor

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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

    @IBAction func addButtonPressed(sender: UIBarButtonItem) {

        var selectedFriends = [User]()

        for indexPath in selectedCells.keys {
            selectedFriends.append(filteredFriendsAndSchedules[indexPath.row].friend)
        }

        delegate?.searchSelectFriendsViewController(self, didSelectFriends: selectedFriends)

        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    /// Reloads the friends and schedules array
    func reloadFriendsData() {
        
        guard let friendsManager = realtimeFriendsManager else { return }
        
        filteredFriendsAndSchedules = friendsManager.friendAndSchedules().flatMap {
            guard let friend = $0.friend, schedule = $0.schedule else { return nil }
            return (friend, schedule)
        }
    }
}

extension SearchSelectFriendsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriendsAndSchedules.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let friend = filteredFriendsAndSchedules[indexPath.row].friend
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchFriendsPrivacyViewControllerCell")!
        
        cell.textLabel?.text = friend.name
        cell.accessoryType = (selectedCells[indexPath] != nil ? .Checkmark : .None)
        
        return cell
    }
}

extension SearchSelectFriendsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if selectedCells[indexPath] != nil {
            selectedCells.removeValueForKey(indexPath)
        } else {
            selectedCells[indexPath] = true
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
}

extension SearchSelectFriendsViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendsManagerDelegate) {
        reloadFriendsData()
        tableView.reloadData()
    }
}

extension SearchSelectFriendsViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        reloadFriendsData()
        
        if !searchText.isBlank() {
            filteredFriendsAndSchedules = filteredFriendsAndSchedules.filter {
                
                for word in $0.friend.name.componentsSeparatedByString(" ") where word.lowercaseString.hasPrefix(searchText.lowercaseString) {
                    return true
                }
                
                return false
            }
        }
        
        tableView.reloadData()
    }
}
