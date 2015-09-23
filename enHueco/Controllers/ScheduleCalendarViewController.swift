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
        User who's schedule will be displayed. Defaults to AppUser
    */
    var user: User! = system.appUser
    
    var currentDate: NSDate!
    let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        dayView.daysBackgroundView.backgroundColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        currentDate = NSDate()
        dayView.reloadData()
    }
    
    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventsForDate date: NSDate!) -> [AnyObject]!
    {
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: date)
        let weekDayDaySchedule = user.schedule.weekDays[localWeekDayNumber]
        
        var events = [TKCalendarDayEventView]()
        
        for gap in weekDayDaySchedule.gaps
        {
            var event = calendarDay.dequeueReusableEventView
            if event == nil { event = TKCalendarDayEventView() }
            
            event.titleLabel.text = gap.name
            event.backgroundColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 245/255.0, alpha: 0.15)
            
            event.startDate = gap.startHourInUTCEquivalentOfLocalDate(date)
            event.endDate = gap.endHourInUTCEquivalentOfLocalDate(date)
            
            events.append(event)
        }
        
        for aClass in weekDayDaySchedule.classes
        {
            var event = calendarDay.dequeueReusableEventView
            if event == nil { event = TKCalendarDayEventView() }
            
            event.titleLabel.text = aClass.name
            //event.titleLabel.textColor
            event.backgroundColor = UIColor(red: 255/255.0, green: 213/255.0, blue: 0/255.0, alpha: 0.15)
            
            event.startDate = aClass.startHourInUTCEquivalentOfLocalDate(date)
            event.endDate = aClass.endHourInUTCEquivalentOfLocalDate(date)
            
            events.append(event)
        }
        
        return events
    }
    
    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventViewWasSelected eventView: TKCalendarDayEventView!)
    {
        let viewController = storyboard?.instantiateViewControllerWithIdentifier("AddViewGapViewController") as! AddViewGapViewController
        
        let weekDayNumber = localCalendar.component(.Weekday, fromDate: eventView.startDate)
        let weekDayDaySchedule = user.schedule.weekDays[weekDayNumber]
        
        let componentUnits: NSCalendarUnit = [.Weekday, .Hour, .Minute]
        let startHour = globalCalendar.components(componentUnits, fromDate: eventView.startDate)

        viewController.eventToEdit = weekDayDaySchedule.gapOrClassWithStartHour(startHour)!
        
        presentViewController(viewController, animated: true, completion: nil)
    }
}
