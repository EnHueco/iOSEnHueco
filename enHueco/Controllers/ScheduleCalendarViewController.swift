//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15./Users/Diego/Dropbox/Proyectos/EH/iOSEnHueco/enHueco/Controllers/ScheduleCalendarViewController.swift
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ScheduleCalendarViewController: TKCalendarDayViewController
{
    /**
        Schedule to be displayed. Defaults to AppUser's
    */
    var schedule: Schedule! = system.appUser.schedule

    let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        dayView.daysBackgroundView.backgroundColor = UIColor(red: 248 / 255.0, green: 248 / 255.0, blue: 248 / 255.0, alpha: 1)
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        dayView.reloadData()
    }

    func reloadData()
    {
        dayView.reloadData()
    }

    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventsForDate date: NSDate!) -> [AnyObject]!
    {
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: date)
        let weekDayDaySchedule = schedule.weekDays[localWeekDayNumber]

        var eventViews = [TKCalendarDayEventView]()

        for event in weekDayDaySchedule.events
        {
            var eventView = calendarDay.dequeueReusableEventView

            if eventView == nil
            {
                eventView = TKCalendarDayEventView()
            }

            eventView.titleLabel.text = event.name ?? (event.type == .FreeTime ? "FreeTime".localized() : "Class".localized())
            eventView.locationLabel.text = event.location
            eventView.backgroundColor = (event.type == .FreeTime ? UIColor(red: 0 / 255.0, green: 150 / 255.0, blue: 245 / 255.0, alpha: 0.15) : UIColor(red: 255 / 255.0, green: 213 / 255.0, blue: 0 / 255.0, alpha: 0.15))

            globalCalendar.timeZone = NSTimeZone(name: "UTC")!

            eventView.startDate = event.startHourInDate(date)

            if localCalendar.component(.Day, fromDate: date) != localCalendar.component(.Day, fromDate: eventView.startDate)
            {
                let diff = localCalendar.component(.WeekOfMonth, fromDate: date) - localCalendar.component(.WeekOfMonth, fromDate: eventView.startDate)
                eventView.startDate = localCalendar.dateByAddingUnit(.WeekOfMonth, value: diff, toDate: eventView.startDate, options: .MatchStrictly)!
            }

            eventView.endDate = event.endHourInDate(date)

            if localCalendar.component(.Day, fromDate: date) != localCalendar.component(.Day, fromDate: eventView.endDate)
            {
                let diff = localCalendar.component(.WeekOfMonth, fromDate: date) - localCalendar.component(.WeekOfMonth, fromDate: eventView.endDate)
                eventView.endDate = localCalendar.dateByAddingUnit(.WeekOfMonth, value: diff, toDate: eventView.endDate, options: .MatchStrictly)!
            }

            eventViews.append(eventView)
        }

        return eventViews
    }

    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventViewWasSelected eventView: TKCalendarDayEventView!)
    {
        guard schedule === system.appUser.schedule else {
            return
        }

        let viewController = storyboard?.instantiateViewControllerWithIdentifier("AddEditEventViewController") as! AddEditEventViewController

        let weekDayNumber = localCalendar.component(.Weekday, fromDate: eventView.startDate)
        let weekDayDaySchedule = schedule.weekDays[weekDayNumber]

        let componentUnits: NSCalendarUnit = [.Weekday, .Hour, .Minute]
        let startHour = globalCalendar.components(componentUnits, fromDate: eventView.startDate)

        viewController.eventToEdit = weekDayDaySchedule.eventWithStartHour(startHour)!
        viewController.scheduleViewController = parentViewController as! ScheduleViewController
        presentViewController(viewController, animated: true, completion: nil)
    }
}
