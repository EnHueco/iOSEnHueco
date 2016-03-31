//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

/// A user.
class User: EHSynchronizable
{
    let username: String
    
    var firstNames: String
    var lastNames: String
    
    var name: String { return "\(firstNames) \(lastNames)" }
    
    var imageURL: NSURL?
    var imageThumbnailURL: NSURL?
    var phoneNumber: String! = ""
    
    var schedule: Schedule
    
    /// (For efficiency) True if the user is near the App User at the current time, given the currentBSSID values.
    private(set) var isNearby = false
    
    var currentBSSID: String?
    {
        didSet
        {
            if currentBSSID != nil
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    NSTimer.scheduledTimerWithTimeInterval(self.currentBSSIDTimeToLive, target: self, selector: #selector(User.currentBSSIDTimeToLiveReached(_:)), userInfo: nil, repeats: false)
                }
            }
            
            refreshIsNearby()
        }
    }
    
    /// Time until currentBSSID is set back to nil
    let currentBSSIDTimeToLive: NSTimeInterval = 60*5 //5 minutes
    
    ///Last time we notified the app user that this user was nearby
    var lastNotifiedNearbyStatusDate: NSDate?
    
    /** The ending date of the user invisibility.
     The user is visible if this is either nil or a date in the past.
    */
    private var inivisibilityEndDate: NSDate?
    
    ///User visibility state
    var isInvisible: Bool
    {
        return inivisibilityEndDate != nil && inivisibilityEndDate!.timeIntervalSinceNow > 0
    }
    
    init(username: String, firstNames: String, lastNames: String, phoneNumber:String!, imageURL: NSURL?, imageThumbnailURL: NSURL?, ID: String, lastUpdatedOn: NSDate)
    {
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        self.imageThumbnailURL = imageThumbnailURL
        
        schedule = Schedule()
        
        super.init(ID: ID, lastUpdatedOn: lastUpdatedOn)
    }
    
    convenience init(JSONDictionary: [String : AnyObject])
    {
        let username = JSONDictionary["login"] as! String
        let firstNames = JSONDictionary["firstNames"] as! String
        let lastNames = JSONDictionary["lastNames"] as! String
        let imageURL = ((JSONDictionary["imageURL"] == nil || JSONDictionary["imageURL"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["imageURL"]! as! String)).replace("https", withString: "http")))
        let imageThumbnailURL = ((JSONDictionary["image_thumbnail"] == nil || JSONDictionary["image_thumbnail"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["image_thumbnail"]! as! String)).replace("https", withString: "http")))
        let phoneNumber = JSONDictionary["phoneNumber"] as? String
        let lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
        
        self.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber ?? "", imageURL: imageURL, imageThumbnailURL: imageThumbnailURL, ID:username, lastUpdatedOn: lastUpdatedOn)
        
        if let invisibilityEvent = JSONDictionary["immediate_event"] where (invisibilityEvent["type"] as! String) == "INVISIBILITY"
        {
            let endDate = NSDate(serverFormattedString: invisibilityEvent["valid_until"] as! String)!
            inivisibilityEndDate = endDate.timeIntervalSinceNow > 0 ? endDate : nil
        }
        else if var instantFreeTimePeriod = JSONDictionary["immediate_event"] as? [String : AnyObject] where (instantFreeTimePeriod["type"] as! String) == "EVENT"
        {
            schedule.instantFreeTimePeriod = Event(instantFreeTimeJSONDictionary: instantFreeTimePeriod)
        }
    }
    
    func updateUserWithJSONDictionary(JSONDictionary: [String : AnyObject])
    {
        self.firstNames = JSONDictionary["firstNames"] as! String
        self.lastNames = JSONDictionary["lastNames"] as! String
        self.imageURL = ((JSONDictionary["imageURL"] == nil || JSONDictionary["imageURL"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["imageURL"]! as! String)).replace("https", withString: "http")))
        self.imageThumbnailURL = ((JSONDictionary["image_thumbnail"] == nil || JSONDictionary["image_thumbnail"] is NSNull) ? nil : NSURL(string: (EHURLS.Base+(JSONDictionary["image_thumbnail"]! as! String)).replace("https", withString: "http")))
        self.phoneNumber = JSONDictionary["phoneNumber"] as? String
        self.lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!
        
        if let invisibilityEvent = JSONDictionary["immediate_event"] where (invisibilityEvent["type"] as! String) == "INVISIBILITY"
        {
            let endDate = NSDate(serverFormattedString: invisibilityEvent["valid_until"] as! String)!
            inivisibilityEndDate = endDate.timeIntervalSinceNow > 0 ? endDate : nil
        }
        else if var instantFreeTimePeriod = JSONDictionary["immediate_event"] as? [String : AnyObject] where (instantFreeTimePeriod["type"] as! String) == "EVENT"
        {
            schedule.instantFreeTimePeriod = Event(instantFreeTimeJSONDictionary: instantFreeTimePeriod)
        }
    }
    
    /** The ending date of the user invisibility.
     The user is visible if this is either nil or a date in the past.
     */
    func setInivisibilityEndDate(date: NSDate?)
    {
        inivisibilityEndDate = date
    }
    
    func addEvents(JSONDictionary: [String: AnyObject])
    {
        let eventSet = JSONDictionary["gap_set"] as! [[String : AnyObject]]
       
        for eventJSON in eventSet
        {
            let event = Event(JSONDictionary: eventJSON)
            schedule.weekDays[event.localWeekDay()].addEvent(event)
        }
    }
    
    /// Returns user current free time period, or nil if user is not free.
    func currentFreeTimePeriod() -> Event?
    {
        guard !isInvisible else { return nil }
        
        if schedule.instantFreeTimePeriod != nil { return schedule.instantFreeTimePeriod }
        
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!        
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .FreeTime
        {
            let startHourInCurrentDate = event.startHourInDate(currentDate)
            let endHourInCurrentDate = event.endHourInDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate)
            {
                return event
            }
        }

        return nil
    }
    
    ///For Performance
    func currentAndNextFreeTimePeriods() -> (currentFreeTimePeriod: Event?, nextFreeTimePeriod: Event?)
    {
        guard !isInvisible else { return (nil, nil) }
        
        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)
        
        let localWeekdayEvents = schedule.weekDays[localWeekDayNumber].events
        
        var currentFreeTimePeriod: Event?
        
        for event in localWeekdayEvents where event.type == .FreeTime
        {
            let startHourInCurrentDate = event.startHourInDate(currentDate)
            let endHourInCurrentDate = event.endHourInDate(currentDate)
            
            if currentDate.isBetween(startHourInCurrentDate, and: endHourInCurrentDate) || startHourInCurrentDate.hasSameHourAndMinutesThan(currentDate)
            {
                currentFreeTimePeriod = event
            }
            else if startHourInCurrentDate > currentDate
            {
                return (currentFreeTimePeriod, event)
            }
        }
        
        return (currentFreeTimePeriod, nil)
    }
    
    /// Returns user's next event
    func nextEvent () -> Event?
    {
        return nil //TODO: 
    }
    
    func nextFreeTimePeriod() -> Event?
    {
        guard !isInvisible else { return nil }

        let currentDate = NSDate()
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let localWeekDayNumber = localCalendar.component(.Weekday, fromDate: currentDate)

        for event in schedule.weekDays[localWeekDayNumber].events where event.type == .FreeTime && event.startHourInDate(currentDate) > currentDate
        {
            return event
        }
        
        return nil
    }
    
    func currentBSSIDTimeToLiveReached (timer: NSTimer)
    {
        currentBSSID = nil
    }
    
    /// When current BSSID is set, checks if user is near the App User and updates the value of the isNearby property.
    func refreshIsNearby()
    {
        if let appUserBSSID = enHueco.appUser.currentBSSID, currentBSSID = currentBSSID
        {
            isNearby = ProximityUpdatesManager.sharedManager.wifiAccessPointWithBSSID(appUserBSSID, isNearAccessPointWithBSSID: currentBSSID)
        }
        else
        {
            isNearby = false
        }
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let username = decoder.decodeObjectForKey("username") as? String,
            let firstNames = decoder.decodeObjectForKey("firstNames") as? String,
            let lastNames = decoder.decodeObjectForKey("lastNames") as? String,
            let schedule = decoder.decodeObjectForKey("schedule") as? Schedule
        else
        {
            self.username = ""
            self.firstNames = ""
            self.lastNames = ""
            self.phoneNumber = ""
            self.schedule = Schedule()

            super.init(coder: decoder)
            return nil
        }
        
        self.username = username
        
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = decoder.decodeObjectForKey("phoneNumber") as? String
        self.imageURL = decoder.decodeObjectForKey("imageURL") as? NSURL
        self.imageThumbnailURL = decoder.decodeObjectForKey("imageThumbnailURL") as? NSURL
        self.schedule = schedule
        self.lastNotifiedNearbyStatusDate = decoder.decodeObjectForKey("lastNotifiedNearbyStatusDate") as? NSDate
        
        super.init(coder: decoder)
    }
    
    override func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(firstNames, forKey: "firstNames")
        coder.encodeObject(lastNames, forKey: "lastNames")
        coder.encodeObject(phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(imageURL, forKey: "imageURL")
        coder.encodeObject(imageThumbnailURL, forKey: "imageThumbnailURL")
        coder.encodeObject(schedule, forKey: "schedule")
        coder.encodeObject(lastNotifiedNearbyStatusDate, forKey: "lastNotifiedNearbyStatusDate")
        
        super.encodeWithCoder(coder)
    }
    
}
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}

