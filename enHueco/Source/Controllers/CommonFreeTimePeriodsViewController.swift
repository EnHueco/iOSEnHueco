//
//  CommonFreeTimePeriodsSearchFriendToAddViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CommonFreeTimePeriodsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    /// User managers
    fileprivate var realtimeUserManagers = [RealtimeUserManager]()
    
    /// A friend the controller should display upon appearance.
    var initialFriendID: String?

    fileprivate(set) var loadedSchedulesUserIDs = [String]()

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

        commonFreeTimePeriodsSearchFriendViewController = storyboard!.instantiateViewController(withIdentifier: "CommonFreeTimePeriodsSearchFriendToAddViewController") as! CommonFreeTimePeriodsSearchFriendToAddViewController
        commonFreeTimePeriodsSearchFriendViewController.delegate = self

        scheduleViewController = storyboard!.instantiateViewController(withIdentifier: "ScheduleCalendarViewController") as! ScheduleCalendarViewController
        scheduleViewController.scheduleToDisplay = Schedule(events: [])

        switchToSchedule()
        
        addUserIDToSelectedIDsAndReloadData(AccountManager.sharedManager.userID!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

        transitionCoordinator?.animate(alongsideTransition: {
            (context) -> Void in

            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
            self.navigationController?.navigationBar.shadowImage = UIImage()

        }, completion: {
            (context) -> Void in

            let navigationStack = self.navigationController?.viewControllers

            if context.isCancelled && navigationStack?.count > 1 && navigationStack![navigationStack!.count - 1] is FriendDetailViewController {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)), for: .default)
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

    func addUserIDToSelectedIDsAndReloadData(_ ID: String) {
        
        // Prevent thread collisions
        DispatchQueue.main.async {
            
            guard !(self.realtimeUserManagers.contains { $0.user?.id == ID }) else { return }
            
            EHProgressHUD.showSpinnerInView(self.view)
            self.realtimeUserManagers.append(RealtimeUserManager(userID: ID, delegate: self)!)
            
            let indexPathForLastItem = IndexPath(item: self.realtimeUserManagers.count - 1, section: 0)
            
            if self.realtimeUserManagers.count == 1 {
                self.selectedFriendsCollectionView.reloadData()
            } else {
                self.selectedFriendsCollectionView.insertItems(at: [indexPathForLastItem])
            }
            
            self.selectedFriendsCollectionView.scrollToItem(at: indexPathForLastItem, at: UICollectionViewScrollPosition.right, animated: true)
            self.prepareInfoAndReloadScheduleData()
        }
    }

    func deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(_ indexPath: IndexPath) {

        guard realtimeUserManagers[indexPath.row].user?.id != AccountManager.sharedManager.userID else {
            return
        }

        realtimeUserManagers.remove(at: indexPath.item)
        selectedFriendsCollectionView.deleteItems(at: [indexPath])
        prepareInfoAndReloadScheduleData()
    }

    // MARK: Controller switching

    func switchToSchedule() {

        removeCurrentController()

        addChildViewController(scheduleViewController)
        scheduleViewController.view.frame = containerView.bounds
        scheduleViewController.view.alpha = 0
        containerView.addSubview(scheduleViewController.view)
        scheduleViewController.didMove(toParentViewController: self)

        currentController = scheduleViewController

        UIView.animate(withDuration: 0.25, animations: {
            self.currentController!.view.alpha = 1
        }) 
    }

    func switchToSearch() {

        removeCurrentController()

        addChildViewController(commonFreeTimePeriodsSearchFriendViewController)
        commonFreeTimePeriodsSearchFriendViewController.view.frame = containerView.bounds
        containerView.addSubview(commonFreeTimePeriodsSearchFriendViewController.view)
        commonFreeTimePeriodsSearchFriendViewController.view.alpha = 0
        commonFreeTimePeriodsSearchFriendViewController.didMove(toParentViewController: self)

        currentController = commonFreeTimePeriodsSearchFriendViewController

        UIView.animate(withDuration: 0.25, animations: {
            self.currentController!.view.alpha = 1
        }) 
    }

    func removeCurrentController() {

        if let currentController = currentController {
            UIView.animate(withDuration: 0.5, animations: {
                () -> Void in

                currentController.view.alpha = 0

            }, completion: {
                (_) -> Void in

                currentController.view.removeFromSuperview()
                currentController.removeFromParentViewController()
                currentController.didMove(toParentViewController: nil)
            })
        }
    }
    
    func didReceiveInformationForUserID(_ ID: String) {
        
        let manager = realtimeUserManagers.first { $0.user?.id == ID }
        
        guard manager?.schedule != nil && manager?.user != nil else {
            return
        }
        
        EHProgressHUD.dismissSpinnerForView(view)
        loadedSchedulesUserIDs.append(ID)
        prepareInfoAndReloadScheduleData()
    }
}

extension CommonFreeTimePeriodsViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager) {
        didReceiveInformationForUserID(manager.userID)
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realtimeUserManagers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = selectedFriendsCollectionView.dequeueReusableCell(withReuseIdentifier: "CommonFreeTimePeriodsSelectedFriendsCollectionViewCell", for: indexPath) as! CommonFreeTimePeriodsSelectedFriendsCollectionViewCell

        cell.friendNameLabel.text = realtimeUserManagers[indexPath.item].user?.name

        cell.setDeleteButtonHidden(indexPath.item == 0)

        cell.contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }
}

extension CommonFreeTimePeriodsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        deleteFriendFromSelectedFriendsAtIndexPathAndReloadData(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        cell.roundCorners()
    }
}

// MARK: SearchBar Delegate

extension CommonFreeTimePeriodsViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        switchToSearch()
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        switchToSchedule()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        commonFreeTimePeriodsSearchFriendViewController.filterContentForSearchText(searchText)
    }
}

// MARK: commonFreeTimePeriodsSearchFriendToAddViewController Delegate

extension CommonFreeTimePeriodsViewController: CommonFreeTimePeriodsSearchFriendToAddViewControllerDelegate {
    
    func commonFreeTimePeriodsSearchFriendToAddViewController(_ controller: CommonFreeTimePeriodsSearchFriendToAddViewController, didSelectFriend friendID: String) {
        
        addUserIDToSelectedIDsAndReloadData(friendID)
        searchBar.endEditing(true)
    }
}
