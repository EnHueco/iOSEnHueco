//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class CommonFreeTimePeriodsViewController: UIViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var selectedFriends = [User]()
    
    var commonFreeTimePeriodsSearchFriendViewController: CommonFreeTimePeriodsSearchFriendToAddViewController!
    var scheduleViewController: ScheduleCalendarViewController!
    
    var currentController: UIViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
        
        if let layout = selectedFriendsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            layout.estimatedItemSize = CGSize(width: 150, height: 29)
        }
        
        commonFreeTimePeriodsSearchFriendViewController = storyboard!.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsSearchFriendToAddViewController") as! CommonFreeTimePeriodsSearchFriendToAddViewController
        
        commonFreeTimePeriodsSearchFriendViewController.delegate = self
        
        scheduleViewController = storyboard!.instantiateViewControllerWithIdentifier("ScheduleCalendarViewController") as! ScheduleCalendarViewController
        scheduleViewController.schedule = Schedule()
        
        switchToSchedule()
        addFriendToSelectedFriendsAndReloadData(enHueco.appUser)
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
    
    func prepareInfoAndReloadScheduleData()
    {
        let commonFreeTimePeriodsSchedule = ScheduleManager.sharedManager.commonFreeTimePeriodsScheduleForUsers(selectedFriends)
        scheduleViewController.schedule = commonFreeTimePeriodsSchedule
        scheduleViewController.dayView.reloadData()
    }
    
    func addFriendToSelectedFriendsAndReloadData(friend: User)
    {
        guard !selectedFriends.contains(friend) else { return }
        
        if friend is AppUser
        {
            selectedFriends.insert(friend, atIndex: 0)
        }
        else
        {
            selectedFriends.append(friend)
        }
        
        let indexPathForLastItem = NSIndexPath(forItem: self.selectedFriends.count-1, inSection: 0)
        
        if selectedFriends.count == 1
        {
            selectedFriendsCollectionView.reloadData()
        }
        else
        {
            selectedFriendsCollectionView.insertItemsAtIndexPaths([indexPathForLastItem])
        }
        
        selectedFriendsCollectionView.scrollToItemAtIndexPath(indexPathForLastItem, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
        
        prepareInfoAndReloadScheduleData()
    }
    
    func deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath: NSIndexPath)
    {
        guard selectedFriends[indexPath.row] !== enHueco.appUser else { return }
        
        selectedFriends.removeAtIndex(indexPath.row)
        selectedFriendsCollectionView.deleteItemsAtIndexPaths([indexPath])
        prepareInfoAndReloadScheduleData()
    }
    
    // MARK: Controller switching
    
    func switchToSchedule()
    {
        removeCurrentController()
        
        addChildViewController(scheduleViewController)
        scheduleViewController.view.frame = containerView.bounds
        scheduleViewController.view.alpha = 0
        containerView.addSubview(scheduleViewController.view)
        scheduleViewController.didMoveToParentViewController(self)
        
        currentController = scheduleViewController
        
        UIView.animateWithDuration(0.25)
        {
            self.currentController!.view.alpha = 1
        }
    }
    
    func switchToSearch()
    {
        removeCurrentController()
        
        addChildViewController(commonFreeTimePeriodsSearchFriendViewController)
        commonFreeTimePeriodsSearchFriendViewController.view.frame = containerView.bounds
        containerView.addSubview(commonFreeTimePeriodsSearchFriendViewController.view)
        commonFreeTimePeriodsSearchFriendViewController.view.alpha = 0
        commonFreeTimePeriodsSearchFriendViewController.didMoveToParentViewController(self)
        
        currentController = commonFreeTimePeriodsSearchFriendViewController
        
        UIView.animateWithDuration(0.25)
        {
            self.currentController!.view.alpha = 1
        }
    }
    
    func removeCurrentController()
    {
        if let currentController = currentController
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                currentController.view.alpha = 0
                
            }, completion: { (_) -> Void in
                
                currentController.view.removeFromSuperview()
                currentController.removeFromParentViewController()
                currentController.didMoveToParentViewController(nil)
            })
        }
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDataSource
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return selectedFriends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let friend = selectedFriends[indexPath.item]
        
        let cell = selectedFriendsCollectionView.dequeueReusableCellWithReuseIdentifier("CommonFreeTimePeriodsSelectedFriendsCollectionViewCell", forIndexPath: indexPath) as! CommonFreeTimePeriodsSelectedFriendsCollectionViewCell
        
        cell.friendNameLabel.text = friend.name
        
        cell.setDeleteButtonHidden(friend === enHueco.appUser)
        
        cell.contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    {
        cell.roundCorners()
    }
}

// MARK: SearchBar Delegate
extension CommonFreeTimePeriodsViewController: UISearchBarDelegate
{
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        switchToSearch()
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool
    {
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        switchToSchedule()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        commonFreeTimePeriodsSearchFriendViewController.filterContentForSearchText(searchText)
    }
}

// MARK: commonFreeTimePeriodsSearchFriendToAddViewController Delegate
extension CommonFreeTimePeriodsViewController: CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate
{
    func commonFreeTimePeriodsSearchFriendToAddViewController(controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friend: User)
    {
        addFriendToSelectedFriendsAndReloadData(friend)
        searchBar.endEditing(true)
    }
}
