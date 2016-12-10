//
//  FriendsViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SWTableViewCell
import SDWebImage
import RKNotificationHub

class FriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var emptyLabel: UILabel!
    let searchBar = UISearchBar()
    
    var friendsAndSchedules = [(user: User, schedule: Schedule)]()

    /// The friends logic manager (if currently fetching updates)
    fileprivate var realtimeFriendsManager: RealtimeFriendsManager?
    
    fileprivate var realtimeFriendRequestsManager: RealtimeFriendRequestsManager?

    /// Notification indicator for the friend requests button. Set count to change the number (animatable)
    fileprivate(set) var friendRequestsNotificationHub: RKNotificationHub!

    var searchEndEditingGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar

        searchBar.delegate = self

        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor

        createEmptyLabel()

        searchEndEditingGestureRecognizer = UITapGestureRecognizer(target: searchBar, action: #selector(UIResponder.resignFirstResponder))

        let friendRequestsButton = UIButton(type: .custom)
        friendRequestsButton.frame.size = CGSize(width: 20, height: 20)
        friendRequestsButton.setBackgroundImage(UIImage(named: "FriendRequests")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        friendRequestsButton.addTarget(self, action: #selector(FriendsViewController.friendRequestsButtonPressed(_:)), for: .touchUpInside)
        friendRequestsButton.tintColor = UIColor.white

        friendRequestsNotificationHub = RKNotificationHub(view: friendRequestsButton)
        friendRequestsNotificationHub.scaleCircleSize(by: 0.48)
        friendRequestsNotificationHub.moveCircleBy(x: 0, y: 0)
        friendRequestsNotificationHub.setCircleColor(UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0), label: UIColor.white)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: friendRequestsButton)

        let commonFreeTimeButton = UIButton(type: .custom)
        commonFreeTimeButton.frame.size = CGSize(width: 20, height: 20)
        commonFreeTimeButton.setBackgroundImage(UIImage(named: "CommonFreeTime")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        commonFreeTimeButton.addTarget(self, action: #selector(FriendsViewController.commonFreeTimeButtonPressed(_:)), for: .touchUpInside)
        commonFreeTimeButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: commonFreeTimeButton)
    }

    func createEmptyLabel() {

        emptyLabel = UILabel()
        emptyLabel.text = "NoFriendsMessage".localizedUsingGeneralFile()
        emptyLabel.textColor = UIColor.gray
        emptyLabel.textAlignment = .center
        emptyLabel.lineBreakMode = .byWordWrapping
        emptyLabel.numberOfLines = 0
        emptyLabel.sizeToFit()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emptyLabel.center = tableView.center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)

        transitionCoordinator?.animate(alongsideTransition: {
            (context) -> Void in

            self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
            self.navigationController?.navigationBar.shadowImage = UIImage()

        }, completion: {
            (context) -> Void in

            if context.isCancelled {
                self.navigationController?.navigationBar.barTintColor = UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)), for: .default)
            }
        })

        // Begin real time updates
        realtimeFriendsManager = RealtimeFriendsManager(delegate: self)
        realtimeFriendRequestsManager = RealtimeFriendRequestsManager(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reportScreenViewToGoogleAnalyticsWithName(name: "Friends")

        if let selectedIndex = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndex, animated: true)
        }
    }
    
    func refreshFriendRequestsHub() {
        
        guard let requestsCount = realtimeFriendRequestsManager?.receivedFriendRequests.count else {
            return
        }
        
        if requestsCount > 10 {
            friendRequestsNotificationHub.hideCount()
        } else {
            friendRequestsNotificationHub.showCount()
        }

        friendRequestsNotificationHub.count = Int32(requestsCount)
        friendRequestsNotificationHub.pop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop realtime updates
        realtimeFriendsManager = nil
        realtimeFriendRequestsManager = nil
    }

    func friendRequestsButtonPressed(_ sender: UIButton) {

        navigationController?.show(storyboard!.instantiateViewController(withIdentifier: "FriendRequestsViewController"), sender: self)
    }

    func commonFreeTimeButtonPressed(_ sender: UIButton) {

        navigationController?.show(storyboard!.instantiateViewController(withIdentifier: "CommonFreeTimePeriodsViewController"), sender: self)
    }
    
    /// Reloads the friends and schedules array
    func reloadFriendsData() {
        
        guard let friendsManager = realtimeFriendsManager else { return }

        friendsAndSchedules = friendsManager.friendAndSchedules().flatMap {
            guard let friend = $0.friend, let schedule = $0.schedule else { return nil }
            return (friend, schedule)
        }
    }

    func reloadFriendsAndTableView() {
        
        let oldFriendsAndSchedules = friendsAndSchedules
        
        reloadFriendsData()
        
        if friendsAndSchedules.isEmpty {
            tableView.isHidden = true
            view.addSubview(emptyLabel)
        } else {
            tableView.isHidden = false
            emptyLabel.removeFromSuperview()
        }

        if !oldFriendsAndSchedules.elementsEqual(friendsAndSchedules, by: ==) {

            let range = NSMakeRange(0, tableView.numberOfSections)
            let sections = IndexSet(integersIn: range.toRange() ?? 0..<0)
            tableView.reloadSections(sections, with: .automatic)
        }
    }
}

extension FriendsViewController: RealtimeFriendsManagerDelegate {
    
    func realtimeFriendsManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeFriendsManager) {
        reloadFriendsAndTableView()
    }
}

extension FriendsViewController: RealtimeFriendRequestsManagerDelegate {
    
    func realtimeFriendRequestsManagerDidReceiveFriendRequestUpdates(_ manager: RealtimeFriendRequestsManager) {
        refreshFriendRequestsHub()
    }
}

extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return friendsAndSchedules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell") as! FriendsCell

        let (friend, schedule) = friendsAndSchedules[indexPath.row]
        
        cell.friendNameLabel.text = friend.name

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"

        cell.eventNameOrLocationLabel.text = nil

        cell.showFreeTimeStartEndHourIcon()

        let (currentFreeTimePeriod, nextFreeTimePeriod) = schedule.currentAndNextFreeTimePeriods()

        if let currentFreeTimePeriod = currentFreeTimePeriod {
            
            let currentFreeTimePeriodEndDate = currentFreeTimePeriod.endDateInNearestPossibleWeekToDate(Date())

            cell.freeTimeStartOrEndHourLabel.text = formatter.string(from: currentFreeTimePeriodEndDate)
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "SouthEastArrow")

            if let nextEvent = schedule.nextEvent(), let nextEventName = nextEvent.name, nextEvent.type == .Class && nextEvent.startDateInNearestPossibleWeekToDate(Date()).timeIntervalSince(currentFreeTimePeriodEndDate) < 60 * 10000 {
                cell.eventNameOrLocationLabel.text = nextEventName

                if let nextEventLocation = nextEvent.location {
                    cell.eventNameOrLocationLabel.text! += " (" + nextEventLocation + ")"
                }
            }
            
        } else if let nextFreeTimePeriod = nextFreeTimePeriod {
            cell.freeTimeStartOrEndHourLabel.text = formatter.string(from: nextFreeTimePeriod.startDateInNearestPossibleWeekToDate(Date()))
            cell.freeTimeStartOrEndHourIconImageView.image = UIImage(named: "NorthEastArrow")
            cell.eventNameOrLocationLabel.text = nextFreeTimePeriod.name ?? "FreeTime".localizedUsingGeneralFile()
        } else {
            cell.hideFreeTimeStartEndHourIcon()
            cell.freeTimeStartOrEndHourLabel.text = "-- --"
        }

        cell.backgroundColor = tableView.backgroundView?.backgroundColor

        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = 53.0 / 2.0
        cell.friendImageImageView.contentMode = .scaleAspectFill
        cell.friendImageImageView.image = nil

        cell.friendImageImageView.sd_setImage(with: friend.imageThumbnail as URL!, placeholderImage: nil, options: [.avoidAutoSetImage, .highPriority, .refreshCached, .retryFailed, .allowInvalidSSLCertificates]) {
            (image, error, cacheType, _) in

            if error == nil {
                if cacheType == SDImageCacheType.none || cacheType == SDImageCacheType.disk {
                    cell.friendImageImageView.alpha = 0
                    cell.friendImageImageView.image = image

                    UIView.animate(withDuration: 0.4, animations: {
                        () -> Void in

                        cell.friendImageImageView.alpha = 1

                    }, completion: nil)
                } else if cacheType == SDImageCacheType.memory {
                    cell.friendImageImageView.image = image
                }
            }
        }

        return cell
    }
}

extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let friend = friendsAndSchedules[indexPath.row].user

        let friendDetailViewController = storyboard?.instantiateViewController(withIdentifier: "FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friendID = friend.id
        //friendDetailViewController.hidesBottomBarWhenPushed = true

        splitViewController?.showDetailViewController(friendDetailViewController, sender: self)
    }
}

extension FriendsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.addGestureRecognizer(searchEndEditingGestureRecognizer)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.removeGestureRecognizer(searchEndEditingGestureRecognizer)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        reloadFriendsData()

        if !searchText.isBlank() {
            friendsAndSchedules = friendsAndSchedules.filter {

                for word in $0.0.name.components(separatedBy: " ") where word.lowercased().hasPrefix(searchText.lowercased()) {
                    return true
                }

                return false
            }
        }

        tableView.reloadData()
    }
}

//func == (lhs: (user: User, schedule: Schedule), rhs: (user: User, schedule: Schedule)) -> Bool {
//    
//    return lhs.user == rhs.user
//}
