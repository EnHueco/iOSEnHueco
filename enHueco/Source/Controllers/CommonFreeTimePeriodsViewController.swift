//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class CommonFreeTimePeriodsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    /// User managers
    private var realtimeUserManagers = [RealtimeUserManager]()
    
    /// A friend the controller should display upon appearance.
    var initialFriendID: String?

    private(set) var loadedSchedulesUserIDs = [String]()

    var commonFreeTimePeriodsSearchFriendViewController: CommonFreeTimePeriodsSearchFriendToAddViewController!
    var scheduleViewController: ScheduleCalendarViewController!

    var currentController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self

        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self

        if let layout = selectedFriendsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 29)
        }

        commonFreeTimePeriodsSearchFriendViewController = storyboard!.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsSearchFriendToAddViewController") as! CommonFreeTimePeriodsSearchFriendToAddViewController
        commonFreeTimePeriodsSearchFriendViewController.delegate = self

        scheduleViewController = storyboard!.instantiateViewControllerWithIdentifier("ScheduleCalendarViewController") as! ScheduleCalendarViewController
        scheduleViewController.scheduleToDisplay = Schedule(events: [])

        switchToSchedule()
        
        addUserIDToSelectedIDsAndReloadData(AccountManager.sharedManager.userID!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)

        transitionCoordinator()?.animateAlongsideTransition({
            (context) -> Void in

            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
            self.navigationController?.navigationBar.shadowImage = UIImage()

        }, completion: {
            (context) -> Void in

            let navigationStack = self.navigationController?.viewControllers

            if context.isCancelled() && navigationStack?.count > 1 && navigationStack![navigationStack!.count - 1] is FriendDetailViewController {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)), forBarMetrics: .Default)
            }
        })
        
        if let initialFriendID = initialFriendID {
            addUserIDToSelectedIDsAndReloadData(initialFriendID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareInfoAndReloadScheduleData() {

        guard let firstSchedule = realtimeUserManagers.first?.schedule else {
            return
        }
    
        let commonFreeTimePeriodsSchedule = firstSchedule.commonFreeTimePeriodsScheduleAmong(realtimeUserManagers[1..<realtimeUserManagers.count].flatMap { $0.schedule } )
        scheduleViewController.scheduleToDisplay = commonFreeTimePeriodsSchedule
        scheduleViewController.dayView.reloadData()
    }

    func addUserIDToSelectedIDsAndReloadData(ID: String) {
        
        // Prevent thread collisions
        dispatch_async(dispatch_get_main_queue()) {
            
            guard !(self.realtimeUserManagers.contains { $0.user?.id == ID }) else { return }
            
            EHProgressHUD.showSpinnerInView(self.view)
            self.realtimeUserManagers.append(RealtimeUserManager(userID: ID, delegate: self)!)
            
            let indexPathForLastItem = NSIndexPath(forItem: self.realtimeUserManagers.count - 1, inSection: 0)
            
            if self.realtimeUserManagers.count == 1 {
                self.selectedFriendsCollectionView.reloadData()
            } else {
                self.selectedFriendsCollectionView.insertItemsAtIndexPaths([indexPathForLastItem])
            }
            
            self.selectedFriendsCollectionView.scrollToItemAtIndexPath(indexPathForLastItem, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            self.prepareInfoAndReloadScheduleData()
        }
    }

    func deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath: NSIndexPath) {

        guard realtimeUserManagers[indexPath.row].user?.id != AccountManager.sharedManager.userID else {
            return
        }

        realtimeUserManagers.removeAtIndex(indexPath.item)
        selectedFriendsCollectionView.deleteItemsAtIndexPaths([indexPath])
        prepareInfoAndReloadScheduleData()
    }

    // MARK: Controller switching

    func switchToSchedule() {

        removeCurrentController()

        addChildViewController(scheduleViewController)
        scheduleViewController.view.frame = containerView.bounds
        scheduleViewController.view.alpha = 0
        containerView.addSubview(scheduleViewController.view)
        scheduleViewController.didMoveToParentViewController(self)

        currentController = scheduleViewController

        UIView.animateWithDuration(0.25) {
            self.currentController!.view.alpha = 1
        }
    }

    func switchToSearch() {

        removeCurrentController()

        addChildViewController(commonFreeTimePeriodsSearchFriendViewController)
        commonFreeTimePeriodsSearchFriendViewController.view.frame = containerView.bounds
        containerView.addSubview(commonFreeTimePeriodsSearchFriendViewController.view)
        commonFreeTimePeriodsSearchFriendViewController.view.alpha = 0
        commonFreeTimePeriodsSearchFriendViewController.didMoveToParentViewController(self)

        currentController = commonFreeTimePeriodsSearchFriendViewController

        UIView.animateWithDuration(0.25) {
            self.currentController!.view.alpha = 1
        }
    }

    func removeCurrentController() {

        if let currentController = currentController {
            UIView.animateWithDuration(0.5, animations: {
                () -> Void in

                currentController.view.alpha = 0

            }, completion: {
                (_) -> Void in

                currentController.view.removeFromSuperview()
                currentController.removeFromParentViewController()
                currentController.didMoveToParentViewController(nil)
            })
        }
    }
    
    func didReceiveInformationForUserID(ID: String) {
        
        let manager = realtimeUserManagers.find { $0.user?.id == ID }
        
        guard manager?.schedule != nil && manager?.user != nil else {
            return
        }
        
        EHProgressHUD.dismissSpinnerForView(view)
        loadedSchedulesUserIDs.append(ID)
        prepareInfoAndReloadScheduleData()
    }
}

extension CommonFreeTimePeriodsViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeUserManager) {
        didReceiveInformationForUserID(manager.userID)
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realtimeUserManagers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = selectedFriendsCollectionView.dequeueReusableCellWithReuseIdentifier("CommonFreeTimePeriodsSelectedFriendsCollectionViewCell", forIndexPath: indexPath) as! CommonFreeTimePeriodsSelectedFriendsCollectionViewCell

        cell.friendNameLabel.text = realtimeUserManagers[indexPath.item].user?.name

        cell.setDeleteButtonHidden(indexPath.item == 0)

        cell.contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        cell.roundCorners()
    }
}

// MARK: SearchBar Delegate

extension CommonFreeTimePeriodsViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        switchToSearch()
        return true
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        switchToSchedule()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        commonFreeTimePeriodsSearchFriendViewController.filterContentForSearchText(searchText)
    }
}

// MARK: commonFreeTimePeriodsSearchFriendToAddViewController Delegate

extension CommonFreeTimePeriodsViewController: CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate {
    
    func commonFreeTimePeriodsSearchFriendToAddViewController(controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friendID: String) {
        
        addUserIDToSelectedIDsAndReloadData(friendID)
        searchBar.endEditing(true)
    }
}
