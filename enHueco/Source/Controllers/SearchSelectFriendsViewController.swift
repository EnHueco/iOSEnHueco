//
//  SearchFriendsPrivacyViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol SearchSelectFriendsViewControllerDelegate: class {
    func searchSelectFriendsViewController(_ controller: SearchSelectFriendsViewController, didSelectFriends friends: [User])
}

class SearchSelectFriendsViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SearchSelectFriendsViewControllerDelegate?
    
    var filteredFriendsAndSchedules = [(friend: User, schedule: Schedule)]()

    /// The friends logic manager (if currently fetching updates)
    fileprivate var realtimeFriendsManager: RealtimeFriendsManager?

    var selectedCells = [IndexPath: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = UIColor.white
        navigationBar.barStyle = .blackTranslucent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = EHInterfaceColor.defaultNavigationBarColor

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        var selectedFriends = [User]()

        for indexPath in selectedCells.keys {
            selectedFriends.append(filteredFriendsAndSchedules[indexPath.row].friend)
        }

        delegate?.searchSelectFriendsViewController(self, didSelectFriends: selectedFriends)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }

    /// Reloads the friends and schedules array
    func reloadFriendsData() {
        
        guard let friendsManager = realtimeFriendsManager else { return }
        
        filteredFriendsAndSchedules = friendsManager.friendAndSchedules().flatMap {
            guard let friend = $0.friend, let schedule = $0.schedule else { return nil }
            return (friend, schedule)
        }
    }
}

extension SearchSelectFriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredFriendsAndSchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friend = filteredFriendsAndSchedules[indexPath.row].friend
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendsPrivacyViewControllerCell")!
        
        cell.textLabel?.text = friend.name
        cell.accessoryType = (selectedCells[indexPath] != nil ? .checkmark : .none)
        
        return cell
    }
}

extension SearchSelectFriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedCells[indexPath] != nil {
            selectedCells.removeValue(forKey: indexPath)
        } else {
            selectedCells[indexPath] = true as Any?
        }
        
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}

extension SearchSelectFriendsViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeFriendsManager) {
        reloadFriendsData()
        tableView.reloadData()
    }
}

extension SearchSelectFriendsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        reloadFriendsData()
        
        if !searchText.isBlank() {
            filteredFriendsAndSchedules = filteredFriendsAndSchedules.filter {
                
                for word in $0.friend.name.components(separatedBy: " ") where word.lowercased().hasPrefix(searchText.lowercased()) {
                    return true
                }
                
                return false
            }
        }
        
        tableView.reloadData()
    }
}
