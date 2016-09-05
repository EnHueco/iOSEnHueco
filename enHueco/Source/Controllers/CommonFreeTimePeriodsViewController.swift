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

    private var realtimeEventsAndSchedulesManager: RealtimeEventsAndSchedulesManager?
    private var realtimeFriendManagers = [RealtimeFriendManager]()
    
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
        
        addUserIDToSelectedIDsAndReloadData(AccountManager.sharedManager.userID)
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
        
        EHProgressHUD.showSpinnerInView(view)
        realtimeEventsAndSchedulesManager = RealtimeEventsAndSchedulesManager(delegate: self)
        
        if let initialFriendID = initialFriendID {
            addUserIDToSelectedIDsAndReloadData(initialFriendID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareInfoAndReloadScheduleData() {

        guard let commonFreeTimePeriodsSchedule = realtimeEventsAndSchedulesManager?.commonFreeTimePeriodsScheduleAmong(realtimeFriendManagers.map { $0.schedule } ) else {
            return
        }
    
        scheduleViewController.schedule = commonFreeTimePeriodsSchedule
        scheduleViewController.dayView.reloadData()
    }

    func addUserIDToSelectedIDsAndReloadData(ID: String) {
        
        // Prevent thread collisions
        dispatch_async(dispatch_get_main_queue()) {
            
            guard !realtimeFriendManagers.contains(ID) else { return }
            
            EHProgressHUD.showSpinnerInView(self.view)
            self.realtimeFriendManagers.append(RealtimeFriendManager(friendID: ID, delegate: self))
            
            let indexPathForLastItem = NSIndexPath(forItem: self.selectedFriendIDs.count - 1, inSection: 0)
            
            if self.selectedFriendIDs.count == 1 {
                self.selectedFriendsCollectionView.reloadData()
            } else {
                self.selectedFriendsCollectionView.insertItemsAtIndexPaths([indexPathForLastItem])
            }
            
            self.selectedFriendsCollectionView.scrollToItemAtIndexPath(indexPathForLastItem, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            self.prepareInfoAndReloadScheduleData()
        }
    }

    func deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath: NSIndexPath) {

        guard !(selectedFriends[indexPath.row] is AppUser) else {
            return
        }

        selectedFriendIDs.removeAtIndex(indexPath.row)
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
        
        guard manager.schedule != nil && !loadedSchedulesUserIDs.contains(manager.appUserID) else { return }
        EHProgressHUD.dismissSpinnerForView(view)
        loadedSchedulesUserIDs.append(manager.friendID)
        prepareInfoAndReloadScheduleData()
    }
}

extension CommonFreeTimePeriodsViewController: RealtimeEventsAndSchedulesManagerDelegate {
    
    func realtimeEventsAndSchedulesManagerDidReceiveScheduleUpdates(manager: RealtimeEventsAndSchedulesManager) {
        didReceiveInformationForUserID(manager.appUserID)
    }
}

extension CommonFreeTimePeriodsViewController: RealtimeFriendManagerDelegate {
    
    func realtimeFriendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendManager) {
        didReceiveInformationForUserID(manager.friendID)
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFriendIDs.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let friend = selectedFriendIDs[indexPath.item]

        let cell = selectedFriendsCollectionView.dequeueReusableCellWithReuseIdentifier("CommonFreeTimePeriodsSelectedFriendsCollectionViewCell", forIndexPath: indexPath) as! CommonFreeTimePeriodsSelectedFriendsCollectionViewCell

        cell.friendNameLabel.text = friend.name

        cell.setDeleteButtonHidden(friend === enHueco.appUser)

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
    
    func commonFreeTimePeriodsSearchFriendToAddViewController(controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friend: User) {
        addFriendIDToSelectedFriendsAndReloadData(friend)
        searchBar.endEditing(true)
    }
}
