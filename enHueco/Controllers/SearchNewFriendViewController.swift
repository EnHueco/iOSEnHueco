//
//  SearchFriendViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SearchNewFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SystemUsersSearchDelegate, SearchFriendCellDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchResults = [User]()
    
    var searchText: String!
    var searchTimer: NSTimer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Buscar amigo"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidSendFriendRequest:"), name:EHSystemNotification.SystemDidSendFriendRequest, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidFailToSendFriendRequest:"), name:EHSystemNotification.SystemDidFailToSendFriendRequest, object: system)
        
        view.backgroundColor = EHIntefaceColor.defaultColoredBackgroundColor

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()

    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let navController = self.navigationController {
            navController.dismissViewControllerAnimated(true, completion: nil) 
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let searchResult = searchResults[indexPath.row]
        
        let cell = searchResultsTableView.dequeueReusableCellWithIdentifier("SearchFriendCell") as! SearchFriendCell
        cell.friendNameLabel.text = searchResult.name
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = searchResults[indexPath.row]
        
        searchResultsTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //let controller = storyboard!.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        //controller.friend = friend
    }
    
    func didPressAddButtonInSearchFriendCell(cell: SearchFriendCell)
    {
        let indexPath = searchResultsTableView.indexPathForCell(cell)!
        let friend = searchResults[indexPath.row]
        
        MRProgressOverlayView.showOverlayAddedTo(view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHIntefaceColor.mainInterfaceColor)
        
        system.appUser.sendFriendRequestToUser(friend)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        searchBar.endEditing(true)
    }
    
    /*func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        navigationController?.setNavigationBarHidden(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool
    {
        navigationController?.setNavigationBarHidden(false, animated: true)
        return true
    }*/
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if let timer = searchTimer
        {
            timer.invalidate()
        }
        
        self.searchText = searchText
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("timeToSearch:"), userInfo: nil, repeats: false)
    }
    
    func timeToSearch(timer: NSTimer)
    {
        system.searchUsersWithText(searchText, delegate: self)
    }
    
    func systemDidReceiveUserSearchResults(results: [User])
    {
        searchResults = results
        searchResultsTableView.reloadData()
    }
    
    func systemDidSendFriendRequest(notification: NSNotification)
    {
        TSMessage.showNotificationWithTitle("¡Solicitud enviada!", type: TSMessageNotificationType.Success)
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func systemDidFailToSendFriendRequest(notification: NSNotification)
    {
        TSMessage.showNotificationWithTitle("Hubo un error enviando la solicitud...", type: TSMessageNotificationType.Error)
        MRProgressOverlayView.dismissOverlayForView(view, animated: true)
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
