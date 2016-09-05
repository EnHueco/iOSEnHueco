//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15./Users/Diego/Dropbox/Proyectos/EH/iOSEnHueco/enHueco/Controllers/ScheduleCalendarViewController.swift
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import TapkuLibrary

class ScheduleCalendarViewController: TKCalendarDayViewController {
    
    private let appUserID = AccountManager.sharedManager.userID
    
    /// ID of the user who's schedule will be displayed. Defaults to the AppUser's
    var userID = AccountManager.sharedManager.userID
    
    /// An optional (existing) schedule to display, setting this will make the controller ignore the `userID` property.
    var scheduleToDisplay: Schedule? {
        
        didSet {
            userID = nil
            reloadData()
        }
    }
    
    /// The real-time updates manager
    private var friendManager: RealtimeFriendManager?

    let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        dayView.daysBackgroundView.backgroundColor = UIColor(red: 248 / 255.0, green: 248 / 255.0, blue: 248 / 255.0, alpha: 1)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let userID = userID where scheduleToDisplay == nil {
            friendManager = RealtimeFriendManager(friendID: userID, delegate: self)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        friendManager = nil
    }

    func reloadData() {

        dayView.reloadData()
    }

    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventsForDate date: NSDate!) -> [AnyObject]! {

        guard let schedule = scheduleToDisplay ?? friendManager?.schedule else {
            return []
        }
        
        let eventsInDay = schedule.eventsInDayOfDate(date)
        var eventViews = [TKCalendarDayEventView]()

        for event in eventsInDay {
            var eventView = calendarDay.dequeueReusableEventView

            if eventView == nil {
                eventView = TKCalendarDayEventView()
            }
            
            eventView.identifier = NSNumber(integer: Int(event.id) ?? -1)
            eventView.titleLabel.text = event.name ?? (event.type == .FreeTime ? "FreeTime".localizedUsingGeneralFile() : "Class".localizedUsingGeneralFile())
            eventView.locationLabel.text = event.location
            eventView.backgroundColor = (event.type == .FreeTime ? UIColor(red: 0 / 255.0, green: 150 / 255.0, blue: 245 / 255.0, alpha: 0.15) : UIColor(red: 255 / 255.0, green: 213 / 255.0, blue: 0 / 255.0, alpha: 0.15))

            globalCalendar.timeZone = NSTimeZone(name: "UTC")!

            eventView.startDate = event.startDateInNearestPossibleWeekToDate(date)
            eventView.endDate = event.endDateInNearestPossibleWeekToDate(date)

            eventViews.append(eventView)
        }

        return eventViews
    }

    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventViewWasSelected eventView: TKCalendarDayEventView!) {

        guard userID == appUserID else {
            return
        }

        let viewController = storyboard?.instantiateViewControllerWithIdentifier("AddEditEventViewController") as! AddEditEventViewController
        
        viewController.eventToEditID = String(eventView.identifier)
        viewController.scheduleViewController = parentViewController as! ScheduleViewController
        presentViewController(viewController, animated: true, completion: nil)
    }
}

extension ScheduleCalendarViewController: RealtimeFriendManagerDelegate {
    
    func realtimeFriendManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeFriendManager) {
        reloadData()
    }
}
