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
    var searchTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self

        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.tintColor = UIColor.white

        //Ugly, but... is there another solution?
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.white
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.clear

        navigationBar.barStyle = .black
        navigationBar.tintColor = UIColor.white
        navigationBar.barTintColor = UIColor.white
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.insertSubview(blurView, at: 0)

        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        vibrancyView.frame = view.bounds
        blurView.addSubview(vibrancyView)
    }

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let searchResult = searchResults[indexPath.row]

        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "SearchFriendCell") as! SearchFriendCell
        cell.friendNameLabel.text = searchResult.name

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let friend = searchResults[indexPath.row]

        let window = UIApplication.shared.delegate!.window!!

        EHProgressHUD.showSpinnerInView(window)
        FriendsManager.sharedManager.sendFriendRequestTo(id: friend.id, completionHandler: { (error) in
            EHProgressHUD.dismissSpinnerForView(window)
            self.searchResultsTableView.deselectRow(at: indexPath, animated: true)
            
            // TODO: Check this
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            EHNotifications.showNotificationInViewController(self, title: "RequestSentConfirmation".localizedUsingGeneralFile(), type: .success)
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.backgroundColor = UIColor.clear
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if let timer = searchTimer {
            timer.invalidate()
        }

        self.searchText = searchText
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SearchNewFriendViewController.timeToSearch(_:)), userInfo: nil, repeats: false)
    }

    func timeToSearch(_ timer: Timer) {

        FriendsManager.sharedManager.searchUsersByName(searchText, institutionID: nil, completionHandler: { (results) in
            
            self.searchResults = results
            self.searchResultsTableView.reloadData()
        })
    }
}
