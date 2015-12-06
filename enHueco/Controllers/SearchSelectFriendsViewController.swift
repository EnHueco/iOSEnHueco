//
//  SearchFriendsPrivacyViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

protocol SearchSelectFriendsViewControllerDelegate: class
{
    func searchSelectFriendsViewController(controller: SearchSelectFriendsViewController, didSelectFriends friends: [User])
}

class SearchSelectFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SearchSelectFriendsViewControllerDelegate?
    
    //For safety and performance (because friends is originally a dictionary)
    var filteredFriends = Array(system.appUser.friends.values)
    
    var selectedCells = [NSIndexPath : AnyObject]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Seleccionar Amigos"

        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barStyle = .BlackTranslucent
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        view.backgroundColor = EHInterfaceColor.defaultNavigationBarColor
   
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem)
    {
        var selectedFriends = [User]()
        
        for indexPath in selectedCells.keys
        {
            selectedFriends.append(filteredFriends[indexPath.row])
        }
        
        delegate?.searchSelectFriendsViewController(self, didSelectFriends: selectedFriends)
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if selectedCells[indexPath] != nil
        {
            selectedCells.removeValueForKey(indexPath)
        }
        else
        {
            selectedCells[indexPath] = true
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friend = filteredFriends[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchFriendsPrivacyViewControllerCell")!
        
        cell.textLabel?.text = friend.name
        
        cell.accessoryType = (selectedCells[indexPath] != nil ? .Checkmark : .None)
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredFriends = Array(system.appUser.friends.values)
        
        if !searchText.isBlank()
        {
            filteredFriends = filteredFriends.filter { $0.name.lowercaseString.containsString(searchText.lowercaseString) }
        }        
        
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
