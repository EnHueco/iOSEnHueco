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
    }
    
    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventsForDate date: NSDate!) -> [AnyObject]!
    {
        let weekDayNumber = localCalendar.component(.Weekday, fromDate: date)
        let weekDayDaySchedule = user.schedule.weekDays[weekDayNumber]
        
        var events = [TKCalendarDayEventView]()
        
        for gap in weekDayDaySchedule.gaps
        {
            var event = calendarDay.dequeueReusableEventView
            if event == nil { event = TKCalendarDayEventView() }
            
            event.titleLabel.text = "Hueco"
            event.backgroundColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 245/255.0, alpha: 0.15)
            event.startDate = globalCalendar.dateBySettingHour(gap.startHour.hour, minute: gap.startHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
            event.endDate = globalCalendar.dateBySettingHour(gap.endHour.hour, minute: gap.endHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
            
            events.append(event)
        }
        
        for aClass in weekDayDaySchedule.classes
        {
            var event = calendarDay.dequeueReusableEventView
            if event == nil { event = TKCalendarDayEventView() }
            
            event.titleLabel.text = aClass.name
            //event.titleLabel.textColor
            event.backgroundColor = UIColor(red: 255/255.0, green: 213/255.0, blue: 0/255.0, alpha: 0.15)
            event.startDate = globalCalendar.dateBySettingHour(aClass.startHour.hour, minute: aClass.startHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
            event.endDate = globalCalendar.dateBySettingHour(aClass.endHour.hour, minute: aClass.endHour.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
            
            events.append(event)
        }
        
        return events
    }
    
    override func calendarDayTimelineView(calendarDay: TKCalendarDayView!, eventViewWasSelected eventView: TKCalendarDayEventView!)
    {

    }
    
    
}
