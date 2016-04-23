//
//  ExtensionsAndUtilities.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import Google

typealias BasicCompletionHandler = (success: Bool, error: ErrorType?) -> Void

struct Either<T1, T2>
{
    let left: T1?
    let right: T2?
}

func >(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs) == .OrderedDescending
}

func <(lhs: NSDate, rhs: NSDate) -> Bool
{
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate
{    
    func isBetween(startDate:NSDate, and endDate:NSDate) -> Bool
    {
        return startDate.compare(self) == .OrderedAscending && endDate.compare(self) == .OrderedDescending
    }
    
    func hasSameHourAndMinutesThan(date:NSDate) -> Bool
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let hourMinute: NSCalendarUnit = [.Hour, .Minute]

        let lhsComp = calendar!.components(hourMinute, fromDate: self)
        let rhsComp = calendar!.components(hourMinute, fromDate: date)
        
        return lhsComp.hour == rhsComp.hour && lhsComp.minute == rhsComp.minute
    }
    
    func hasSameWeekdayHourAndMinutesThan(date:NSDate) -> Bool
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
        
        let lhsComp = calendar!.components(weekdayHourMinute, fromDate: self)
        let rhsComp = calendar!.components(weekdayHourMinute, fromDate: date)
        
        return lhsComp.weekday == rhsComp.weekday && lhsComp.hour == rhsComp.hour && lhsComp.minute == rhsComp.minute
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    convenience init?(serverFormattedString: String)
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.timeZone = NSTimeZone(name: "UTC")
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let possibleDate = dateStringFormatter.dateFromString(serverFormattedString)
        
        guard let date = possibleDate else { return nil }
        
        self.init(timeInterval:0, sinceDate:date)
    }
    
    func serverFormattedString() -> String
    {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.timeZone = NSTimeZone(name: "UTC")
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateStringFormatter.stringFromDate(self)
    }
}

extension NSDateComponents
{
    /**
        Returns a new instance of NSDateComponents with all its components set to 0 except for the ones provided.
    */
    convenience init(weekday: Int, hour: Int, minute: Int)
    {
        self.init()

        self.weekday = weekday
        self.hour = hour
        self.minute = minute
    }
}

func -(lhs: NSDate, rhs: NSDate) -> NSDateComponents
{
    let dayHourMinuteSecond: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
    
    return NSCalendar.currentCalendar().components(dayHourMinuteSecond, fromDate: rhs, toDate: lhs, options: [])
}

extension Array
{
    mutating func removeObject<U: Equatable>(object: U) -> Bool
    {
        var index: Int?
        
        for (idx, objectToCompare) in self.enumerate()
        {
            if let to = objectToCompare as? U
            {
                if object == to
                {
                    index = idx
                }
            }
        }
        
        if(index != nil)
        {
            self.removeAtIndex(index!)
            return true
        }
        
        return false
    }
}

extension String
{
    func isBlank() -> Bool
    {
        let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return trimmed.isEmpty
    }
    
    /**
     Gets the localized string from the specified strings file using *self* as the key
     
     - parameter fileName: .strings file that contains the key
     */
    func localizedUsingFile(fileName: String) -> String
    {
        return NSLocalizedString(self, tableName: fileName, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    /// Localizes the receiver using the General.strings file
    func localizedUsingGeneralFile() -> String
    {
        return localizedUsingFile("General")
    }
    
    /**
     Gets the localized string from the specified strings file using *self* as the key
     
     - parameter fileName: .strings file that contains the key
     */
    func localizedUsingFile(fileName: String, withComment comment: String) -> String
    {
        return NSLocalizedString(self, tableName: fileName, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}

extension UIImage
{
    /// Initializes an image with the given size containing a given color
    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1))
    {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }  
}

protocol EHErrorType: ErrorType {
    
    var localizedDescription: String? { get }
}

extension ErrorType
{
    /**
     Attempts to extract a localized description that is suitable for display to the user. This
     is determined by the domain of the error.
     Recognized domains are NSURLErrorDomain, domains whith "com.jinglz" prefixes, and R3LPlatformErrorDomains.defaultDomain.
     
     - returns: Localized description or a generic uknown error description.
     */
    func localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage() -> String? {
        
        if self.dynamicType == NSError.self
        {
            /// Not forcing the downcast causes information loss because of compiler magic
            let nserror = self as! NSError
            
            let errorMessage: String
            
            if nserror.domain.hasPrefix(ehBaseErrorDomain) || nserror.domain == NSURLErrorDomain
            {
                errorMessage = nserror.localizedDescription
            }
            else
            {
                errorMessage = "SorryUnknownError".localizedUsingGeneralFile()
            }
            
            return errorMessage
            
        } else if let eherror = self as? EHErrorType {
            
            return eherror.localizedDescription
        }
        
        return nil
    }
}

extension UIView
{
    /// Rounds the corners of the view by setting the corner radius to height/2
    func roundCorners()
    {
        clipsToBounds = true
        layer.cornerRadius = bounds.height/2
    }
}

class Wrapper<T>
{
    let element : T
    init(element : T)
    {
        self.element = element
    }
}

extension UIViewController
{
    func reportScreenViewToGoogleAnalyticsWithName(name: String)
    {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}