//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class CommonFreeTimePeriodsViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate
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

        title = "Huecos en común"
        
        searchBar.delegate = self
        
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
        
        commonFreeTimePeriodsSearchFriendViewController = storyboard!.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsSearchFriendToAddViewController") as! CommonFreeTimePeriodsSearchFriendToAddViewController
        
        commonFreeTimePeriodsSearchFriendViewController.delegate = self
        
        scheduleViewController = storyboard!.instantiateViewControllerWithIdentifier("ScheduleCalendarViewController") as! ScheduleCalendarViewController
        scheduleViewController.schedule = Schedule()
        
        switchToSchedule()
        addFriendToSelectedFriendsAndReloadData(system.appUser)
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
        let commonFreeTimePeriodsSchedule = system.appUser.commonFreeTimePeriodsScheduleForUsers(selectedFriends)
        scheduleViewController.schedule = commonFreeTimePeriodsSchedule
        scheduleViewController.dayView.reloadData()
    }
    
    func addFriendToSelectedFriendsAndReloadData(friend: User)
    {
        if friend is AppUser
        {
            selectedFriends.insert(friend, atIndex: 0)
        }
        else
        {
            selectedFriends.append(friend)
        }
        
        selectedFriendsCollectionView.reloadData()
        prepareInfoAndReloadScheduleData()
    }
    
    // MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return selectedFriends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let friend = selectedFriends[indexPath.item]
        
        let cell = selectedFriendsCollectionView.dequeueReusableCellWithReuseIdentifier("CommonFreeTimePeriodsSelectedFriendsCollectionViewCell", forIndexPath: indexPath) as! CommonFreeTimePeriodsSelectedFriendsCollectionViewCell
        
        cell.friendNameLabel.text = friend.name
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        
        cell.contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let height = CGFloat(28.0)
        
        let label = UILabel()
        label.text = selectedFriends[indexPath.item].name
        label.font = UIFont.systemFontOfSize(12)
        let size = label.sizeThatFits(CGSizeMake(CGFloat.max, height))
        
        return CGSizeMake(size.width + 20, height)
    }
    
    // MARK: SearchBar Delegate
    
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
        switchToSchedule()
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
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
    
    // MARK: commonFreeTimePeriodsSearchFriendToAddViewController Delegate
    
    func commonFreeTimePeriodsSearchFriendToAddViewController(controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friend: User)
    {
        addFriendToSelectedFriendsAndReloadData(friend)
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
        
        UIView.animateWithDuration(0.5)
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
        
        UIView.animateWithDuration(0.5)
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
