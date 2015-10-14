//
//  SearchFriendViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SearchFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    var searchResults = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = EHIntefaceColor.defaultColoredBackgroundColor

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        cell.friendNameLabel.text = searchResult
        
        return cell
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
        fetchResultsAndUpdateTableViewForSearchText(searchText)
    }
    
    func fetchResultsAndUpdateTableViewForSearchText(searchText: String)
    {
        // TODO:
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
