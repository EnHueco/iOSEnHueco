//
//  SearchFriendViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SearchNewFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!

    var searchResults = [User]()

    var searchText: String!
    var searchTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self

        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.tintColor = UIColor.whiteColor()

        //Ugly, but... is there another solution?
        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.whiteColor()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clearColor()

        navigationBar.barStyle = .Black
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = UIColor.whiteColor()
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.insertSubview(blurView, atIndex: 0)

        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        vibrancyView.frame = view.bounds
        blurView.addSubview(vibrancyView)
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchResults.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let searchResult = searchResults[indexPath.row]

        let cell = searchResultsTableView.dequeueReusableCellWithIdentifier("SearchFriendCell") as! SearchFriendCell
        cell.friendNameLabel.text = searchResult.name

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let friend = searchResults[indexPath.row]

        let window = UIApplication.sharedApplication().delegate!.window!!

        EHProgressHUD.showSpinnerInView(window)
        FriendsManager.sharedManager.sendFriendRequestTo(id: friend.id, completionHandler: { (error) in
            EHProgressHUD.dismissSpinnerForView(window)
            self.searchResultsTableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            // TODO: Check this
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            EHNotifications.showNotificationInViewController(self, title: "RequestSentConfirmation".localizedUsingGeneralFile(), type: .Success)
            
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.backgroundColor = UIColor.clearColor()
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
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

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        if let timer = searchTimer {
            timer.invalidate()
        }

        self.searchText = searchText
        searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SearchNewFriendViewController.timeToSearch(_:)), userInfo: nil, repeats: false)
    }

    func timeToSearch(timer: NSTimer) {

        FriendsManager.sharedManager.searchUsersWithText(searchText) {
            (results) -> () in

            self.searchResults = results
            self.searchResultsTableView.reloadData()
        }
    }
}
