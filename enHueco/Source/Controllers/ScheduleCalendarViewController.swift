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
    
    /// The IDs of the events. This array serves as a String -> Int mapping based on the index of the string
    var eventIDs = [String]()
    
    /// The real-time updates manager
    private var realtimeUserManager: RealtimeUserManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayView.daysBackgroundView.backgroundColor = UIColor(red: 248 / 255.0, green: 248 / 255.0, blue: 248 / 255.0, alpha: 1)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let userID = userID where scheduleToDisplay == nil {
            realtimeUserManager = RealtimeUserManager(userID: userID, delegate: self)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        realtimeUserManager = nil
    }

    func reloadData() {

        eventIDs = realtimeUserManager?.schedule?.events.map { $0.id } ?? []
        dayView.reloadData()
    }

    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventsForDate date: NSDate!) -> [AnyObject]! {

        guard let schedule = scheduleToDisplay ?? realtimeUserManager?.schedule else {
            return []
        }
        
        let eventsInDay = schedule.eventsInDayOfDate(date)
        var eventViews = [TKCalendarDayEventView]()

        for event in eventsInDay {
            var eventView = calendarDay.dequeueReusableEventView

            if eventView == nil {
                eventView = TKCalendarDayEventView()
            }
            
            eventView.identifier = eventIDs.indexOf(event.id) ?? -1
            eventView.titleLabel.text = event.name ?? (event.type == .FreeTime ? "FreeTime".localizedUsingGeneralFile() : "Class".localizedUsingGeneralFile())
            eventView.locationLabel.text = event.location
            eventView.backgroundColor = (event.type == .FreeTime ? UIColor(red: 0 / 255.0, green: 150 / 255.0, blue: 245 / 255.0, alpha: 0.15) : UIColor(red: 255 / 255.0, green: 213 / 255.0, blue: 0 / 255.0, alpha: 0.15))

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
        
        viewController.eventToEditID = eventIDs[eventView.identifier.integerValue]
        viewController.scheduleViewController = parentViewController as! ScheduleViewController
        presentViewController(viewController, animated: true, completion: nil)
    }
}

extension ScheduleCalendarViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(manager: RealtimeUserManager) {
        reloadData()
    }
}
