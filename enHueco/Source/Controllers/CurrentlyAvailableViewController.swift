//
//  CurrentlyAvailableViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SWTableViewCell
import SDWebImage

class CurrentlyAvailableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var filteredFriendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()
    var filteredSoonFreefriendsAndFreeTimePeriods = [(friend: User, freeTime: Event)]()

    var emptyLabel: UILabel!
    
    let searchBar = UISearchBar()

    var imInvisibleBarItem: UIBarButtonItem!
    var imAvailableBarItem: UIBarButtonItem!

    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    /// The friends logic manager (if currently fetching updates)
    fileprivate var realtimeFriendsManager: RealtimeFriendsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        emptyLabel = UILabel()
        emptyLabel.text = "NobodyAvailableMessage".localizedUsingGeneralFile()
        emptyLabel.textColor = UIColor.gray
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()

        searchBar.delegate = self

        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar

        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: #selector(UIResponder.resignFirstResponder))

        let imInvisibleButton = UIButton(type: .custom)
        imInvisibleButton.frame.size = CGSize(width: 20, height: 20)
        imInvisibleButton.setBackgroundImage(UIImage(named: "Eye")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        imInvisibleButton.addTarget(self, action: #selector(CurrentlyAvailableViewController.imInvisibleButtonPressed(_:)), for: .touchUpInside)
        imInvisibleButton.tintColor = UIColor.white
        imInvisibleBarItem = UIBarButtonItem(customView: imInvisibleButton)
        navigationItem.leftBarButtonItem = imInvisibleBarItem

        let imFreeButton = UIButton(type: .custom)
        imFreeButton.frame.size = CGSize(width: 20, height: 20)
        imFreeButton.setBackgroundImage(UIImage(named: "HandRaised")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        imFreeButton.addTarget(self, action: #selector(CurrentlyAvailableViewController.imAvailableButtonPressed(_:)), for: .touchUpInside)
        imFreeButton.tintColor = UIColor.white
        imAvailableBarItem = UIBarButtonItem(customView: imFreeButton)
        navigationItem.rightBarButtonItem = imAvailableBarItem
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyLabel.center = tableView.center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        navigationController?.setNavigationBarHidden(false, animated: false)

        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

        transitionCoordinator?.animate(alongsideTransition: {
            (context) -> Void in

            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor

        }, completion: {
            (context) -> Void in

            if context.isCancelled {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)), for: .default)
            }
        })

        if let selectedIndex = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndex, animated: true)
        }

        /// This way we ensure this call will not collide with the next one in the completion handler
        DispatchQueue.main.async {
            self.updateFreeTimePeriodDataAndReloadTableView()
        }

        // Begin real time updates
        realtimeFriendsManager = RealtimeFriendsManager(delegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reportScreenViewToGoogleAnalyticsWithName(name: "Currently Available")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeFriendsManager = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }

    func imInvisibleButtonPressed(_ sender: UIButton) {

        // TODO: Update implementation
        /*
        if enHueco.appUser.isInvisible {
            turnVisible()
        } else {
            turnInvisible()
        }*/
    }

    fileprivate func turnInvisible() {

        // TODO: Update implementation
        /*
        let turnInvisibleForInterval = {
            (interval: NSTimeInterval) -> Void in

            EHProgressHUD.showSpinnerInView(self.view)
            PrivacyManager.shared.turnInvisibleForTimeInterval(interval, completionHandler: {
                (success, error) -> Void in

                EHProgressHUD.dismissSpinnerForView(self.view)

                guard success && error == nil else
                {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    return
                }

                self.updateFreeTimePeriodDataAndReloadTableView()
            })
        }

        let controller = UIAlertController(title: "TurnInvisibleActionSheetTitle".localizedUsingGeneralFile(), message: nil, preferredStyle: .ActionSheet)

        controller.addAction(UIAlertAction(title: "TurnInvisibleActionSheet1Hour20Minutes".localizedUsingGeneralFile(), style: .Default, handler: {
            (_) -> Void in

            turnInvisibleForInterval(80 * 60)
        }))

        controller.addAction(UIAlertAction(title: "TurnInvisibleActionSheet3Hours".localizedUsingGeneralFile(), style: .Default, handler: {
            (_) -> Void in

            turnInvisibleForInterval(3 * 60 * 60)
        }))

        controller.addAction(UIAlertAction(title: "TurnInvisibleActionSheetRestOfDay".localizedUsingGeneralFile(), style: .Default, handler: {
            (_) -> Void in

            let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!

            let tomorrow = globalCalendar.startOfDayForDate(NSDate().addDays(1))

            turnInvisibleForInterval(tomorrow.timeIntervalSinceNow)
        }))

        controller.addAction(UIAlertAction(title: "Cancel".localizedUsingGeneralFile(), style: .Cancel, handler: nil))

        presentViewController(controller, animated: true, completion: nil)
         */
    }

    fileprivate func turnVisible() {

        // TODO: Update implementation
        /*
        EHProgressHUD.showSpinnerInView(self.view)
        PrivacyManager.shared.turnVisibleWithCompletionHandler {(success, error) -> Void in

            EHProgressHUD.dismissSpinnerForView(self.view)

            guard success && error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            self.updateFreeTimePeriodDataAndReloadTableView()
        }*/
    }

    func imAvailableButtonPressed(_ sender: UIButton) {

        let instantFreeTimeViewController = storyboard!.instantiateViewController(withIdentifier: "InstantFreeTimeViewController") as! InstantFreeTimeViewController
        instantFreeTimeViewController.delegate = self
        instantFreeTimeViewController.showInViewController(navigationController!)
    }

    func resetDataArrays() {
        
        guard let realtimeFriendsManager = realtimeFriendsManager else { return }

        filteredFriendsAndFreeTimePeriods = realtimeFriendsManager.currentlyAvailableFriends()

        // TODO: Update to new model
        /*if let instantFreeTimePeriod = enHueco.appUser.schedule.instantFreeTimePeriod {
            filteredFriendsAndFreeTimePeriods.insert((enHueco.appUser, instantFreeTimePeriod), atIndex: 0)
        }*/
        
        filteredSoonFreefriendsAndFreeTimePeriods = realtimeFriendsManager.soonAvailableFriendsWithin(3600)
    }

    func updateFreeTimePeriodDataAndReloadTableView() {

        // TODO: Update to new model
        /*
        UIView.animateWithDuration(0.2) {

            let activeColor = UIColor(red: 220 / 255.0, green: 170 / 255.0, blue: 10 / 255.0, alpha: 1)
            self.imInvisibleBarItem.customView!.tintColor = enHueco.appUser.isInvisible ? activeColor : UIColor.whiteColor()
            self.imAvailableBarItem.customView!.tintColor = enHueco.appUser.schedule.instantFreeTimePeriod != nil ? activeColor : UIColor.whiteColor()
        }
        */
        
        DispatchQueue.main.async {
        
            let oldFilteredFriendsAndFreeTimePeriods = self.filteredFriendsAndFreeTimePeriods
            let oldFilteredSoonFreefriendsAndFreeTimePeriods = self.filteredSoonFreefriendsAndFreeTimePeriods
            
            self.resetDataArrays()
            
            if self.filteredFriendsAndFreeTimePeriods.isEmpty && self.filteredSoonFreefriendsAndFreeTimePeriods.isEmpty {
                self.tableView.isHidden = true
                self.view.addSubview(self.emptyLabel)
                
            } else {
                self.tableView.isHidden = false
                self.emptyLabel.removeFromSuperview()
            }
            
            if !oldFilteredFriendsAndFreeTimePeriods.elementsEqual(self.filteredFriendsAndFreeTimePeriods, by: ==)
                || !oldFilteredSoonFreefriendsAndFreeTimePeriods.elementsEqual(self.filteredSoonFreefriendsAndFreeTimePeriods, by: ==) {
                
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = IndexSet(integersIn: range.toRange() ?? 0..<0)
                self.tableView.reloadSections(sections, with: .automatic)
            }
        }
    }

    func rightButtons() -> NSArray {

        let rightUtilityButtons = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.flatMint, title: "WhatsApp")
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.flatWatermelon, title: "Call".localizedUsingGeneralFile())

        return rightUtilityButtons
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CurrentlyAvailableViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeFriendsManager) {
        
        updateFreeTimePeriodDataAndReloadTableView()
    }
}

extension CurrentlyAvailableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        // Should be and stay constant in order for animations to work
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return filteredFriendsAndFreeTimePeriods.count
        } else if section == 1 {
            return filteredSoonFreefriendsAndFreeTimePeriods.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableFriendCell") as! AvailableFriendCell

        cell.delegate = self

        cell.freeTimeStartOrEndHourIconImageView.tintColor = cell.freeTimeStartOrEndHourLabel.textColor

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"

        var (friend, freeTime): (User, Event)

        if indexPath.section == 0 {
            (friend, freeTime) = filteredFriendsAndFreeTimePeriods[indexPath.row]

            cell.freeTimeStartOrEndHourLabel.text = formatter.string(from: freeTime.endDateInNearestPossibleWeekToDate(Date()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")?.withRenderingMode(.alwaysTemplate)
        } else {
            (friend, freeTime) = filteredSoonFreefriendsAndFreeTimePeriods[indexPath.row]

            cell.freeTimeStartOrEndHourLabel.text = formatter.string(from: freeTime.startDateInNearestPossibleWeekToDate(Date()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")?.withRenderingMode(.alwaysTemplate)
        }

        if friend.id == AccountManager.shared.userID {
            cell.setInstantFreeTimeIconVisibility(true)

            let array = NSMutableArray()
            array.sw_addUtilityButton(with: UIColor.red, title: "Delete".localizedUsingGeneralFile())

            cell.rightUtilityButtons = Array(array) as [Any]
            
        } else {
            cell.setInstantFreeTimeIconVisibility(false)
            cell.rightUtilityButtons = Array(rightButtons()) as [Any]

        }

        cell.freeNameAndLocationLabel.text = freeTime.name ?? "FreeTime".localizedUsingGeneralFile()

        let url = friend.imageThumbnail

        cell.friendNameLabel.text = friend.name

        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 61 / 2
        cell.friendImageImageView.image = nil
        cell.friendImageImageView.contentMode = .scaleAspectFill

        cell.instantFreeTimeIcon.image = cell.instantFreeTimeIcon.image?.withRenderingMode(.alwaysTemplate)
        cell.instantFreeTimeIcon.tintColor = UIColor.gray

        SDWebImageManager().downloadImage(with: url as URL!, options: SDWebImageOptions.allowInvalidSSLCertificates, progress: nil, completed: { (image, error, cacheType, bool, url) -> Void in
            
            guard error == nil else { return }
            
            if cacheType == .none || cacheType == .disk {
                
                cell.friendImageImageView.alpha = 0
                cell.friendImageImageView.image = image
                
                UIView.animate(withDuration: 0.5, animations: {
                    cell.friendImageImageView.alpha = 1
                }) 
                
            } else if cacheType == SDImageCacheType.memory {
                cell.friendImageImageView.image = image
            }
        })

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if section == 0 {
            return "Now".localizedUsingGeneralFile()
        } else {
            return "Soon".localizedUsingGeneralFile()
        }
    }
}

extension CurrentlyAvailableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let friend: User

        if indexPath.section == 0 {
            friend = filteredFriendsAndFreeTimePeriods[indexPath.row].friend
        } else {
            friend = filteredSoonFreefriendsAndFreeTimePeriods[indexPath.row].friend
        }

        let friendDetailViewController = storyboard?.instantiateViewController(withIdentifier: "FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friendID = friend.id

        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }
}

extension CurrentlyAvailableViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {

        if let cell = cell as? AvailableFriendCell {
            let indexPath = tableView.indexPath(for: cell)!
            let friend: User

            if indexPath.section == 0 {
                friend = filteredFriendsAndFreeTimePeriods[indexPath.row].friend
            } else {
                friend = filteredSoonFreefriendsAndFreeTimePeriods[indexPath.row].friend
            }

            let appDelegate = AppDelegate.shared
            
            if friend.id == AccountManager.shared.userID {
                EHProgressHUD.showSpinnerInView(view)
                
                // TODO: Update implementation
                /*
                CurrentStateManager.shared.deleteInstantFreeTimePeriodWithCompletionHandler({ (success, error) -> Void in

                    EHProgressHUD.dismissSpinnerForView(self.view)

                    guard success && error == nil else {

                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }

                    self.updateFreeTimePeriodDataAndReloadTableView()
                })*/
                
            } else if index == 0 {
                
                guard let phoneNumber  = friend.phoneNumber else { return }
                appDelegate.getFriendABID(phoneNumber, completionHandler: { (abid) -> () in
                    appDelegate.whatsappMessageTo(abid)
                })

            } else if index == 1 {
                
                guard let phoneNumber  = friend.phoneNumber else { return }
                appDelegate.callFriend(phoneNumber)
            }
        }
        cell.hideUtilityButtons(animated: true)
    }

    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
}

extension CurrentlyAvailableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        tableView.addGestureRecognizer(searchEndEditingGestureRecognizer)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {

        tableView.removeGestureRecognizer(searchEndEditingGestureRecognizer)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        DispatchQueue.main.async {
            self.resetDataArrays()

            let nameContainsPrefix = {
                (name: String, string: String) -> Bool in

                for word in name.components(separatedBy: " ") where word.lowercased().hasPrefix(string) {
                    return true
                }

                return false
            }

            if !searchText.isBlank() {
                self.filteredFriendsAndFreeTimePeriods = self.filteredFriendsAndFreeTimePeriods.filter {
                    nameContainsPrefix($0.friend.name, searchText.lowercased())
                }
                self.filteredSoonFreefriendsAndFreeTimePeriods = self.filteredSoonFreefriendsAndFreeTimePeriods.filter {
                    nameContainsPrefix($0.friend.name, searchText.lowercased())
                }
            }

            self.tableView.reloadData()
        }
    }
}

extension CurrentlyAvailableViewController: InstantFreeTimeViewControllerDelegate {
    
    func instantFreeTimeViewControllerDidPostInstantFreeTimePeriod(_ controller: InstantFreeTimeViewController) {
        updateFreeTimePeriodDataAndReloadTableView()
    }
}
