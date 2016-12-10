//
//  ExtensionsAndUtilities.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import Genome

enum GenericError: Error {
    case notLoggedIn
    case unknownError
    case error(message: String)
    case unsupportedOperation
}

typealias BasicCompletionHandler = (_ error:Error?) -> Void

struct Either<T1, T2> {
    let left: T1?
    let right: T2?
}

extension Array where Element: NodeInitializable {

    init(node: Any) throws {
        try self.init(node: node as? [Any] ?? [])
    }
    
    init(node: [Any]) throws {
        try self.init(node: Node(any: node))
    }
}

extension MappableObject {
    
    init(node: Any) throws {
        try self.init(node: Node(any: node))
    }
    
    init(node: [Any]) throws {
        try self.init(node: Node(any: node))
    }
}

extension Date {
    func isBetween(_ startDate: Date, and endDate: Date) -> Bool {

        return startDate.compare(self) == .orderedAscending && endDate.compare(self) == .orderedDescending
    }

    func hasSameHourAndMinutesThan(_ date: Date) -> Bool {

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let hourMinute: Set<Calendar.Component> = [.hour, .minute]

        let lhsComp = calendar.dateComponents(hourMinute, from: self)
        let rhsComp = calendar.dateComponents(hourMinute, from: date)

        return lhsComp.hour == rhsComp.hour && lhsComp.minute == rhsComp.minute
    }

    func hasSameWeekdayHourAndMinutesThan(_ date: Date) -> Bool {

        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let weekdayHourMinute: Set<Calendar.Component> = [.weekday, .hour, .minute]

        let lhsComp = calendar.dateComponents(weekdayHourMinute, from: self)
        let rhsComp = calendar.dateComponents(weekdayHourMinute, from: date)

        return lhsComp.weekday == rhsComp.weekday && lhsComp.hour == rhsComp.hour && lhsComp.minute == rhsComp.minute
    }

    func addDays(_ daysToAdd: Int) -> Date {

        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)

        //Return Result
        return dateWithDaysAdded
    }

    func addHours(_ hoursToAdd: Int) -> Date {

        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)

        //Return Result
        return dateWithHoursAdded
    }

    init?(serverFormattedString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.timeZone = TimeZone(identifier: "UTC")
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let possibleDate = dateStringFormatter.date(from: serverFormattedString)

        guard let date = possibleDate else {
            return nil
        }

        self.init(timeInterval: 0, since: date)
    }

    func serverFormattedString() -> String {

        let dateStringFormatter = DateFormatter()
        dateStringFormatter.timeZone = TimeZone(identifier: "UTC")
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        return dateStringFormatter.string(from: self)
    }
}

extension DateComponents {
    /**
        Returns a new instance of NSDateComponents with all its components set to 0 except for the ones provided.
    */
    init(weekday: Int, hour: Int, minute: Int) {
        self.init()

        self.weekday = weekday
        self.hour = hour
        self.minute = minute
    }
}

func -(lhs: Date, rhs: Date) -> DateComponents {
    return Calendar.current.dateComponents([.day, .hour, .minute, .second], from: rhs, to: lhs)
}

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    
    mutating func removeObject<U:Equatable>(_ object: U) -> Bool {

        var index: Int?

        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }

        if (index != nil) {
            self.remove(at: index!)
            return true
        }

        return false
    }
}

extension String {
    func isBlank() -> Bool {

        let trimmed = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }

    /**
     Gets the localized string from the specified strings file using *self* as the key
     
     - parameter fileName: .strings file that contains the key
     */
    func localizedUsingFile(_ fileName: String) -> String {

        return NSLocalizedString(self, tableName: fileName, bundle: Bundle.main, value: "", comment: "")
    }

    /// Localizes the receiver using the General.strings file
    func localizedUsingGeneralFile() -> String {

        return localizedUsingFile("General")
    }

    /**
     Gets the localized string from the specified strings file using *self* as the key
     
     - parameter fileName: .strings file that contains the key
     */
    func localizedUsingFile(_ fileName: String, withComment comment: String) -> String {

        return NSLocalizedString(self, tableName: fileName, bundle: Bundle.main, value: "", comment: comment)
    }
}

extension UIImage {
    /// Initializes an image with the given size containing a given color
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

protocol EHErrorType: Error {

    var localizedDescription: String? { get }
}

extension Error {
    /**
     Attempts to extract a localized description that is suitable for display to the user. This
     is determined by the domain of the error.
     Recognized domains are NSURLErrorDomain, domains whith "com.jinglz" prefixes, and R3LPlatformErrorDomains.defaultDomain.
     
     - returns: Localized description or a generic uknown error description.
     */
    func localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage() -> String? {

        if type(of: self) == NSError.self {
            /// Not forcing the downcast causes information loss because of compiler magic
            let nserror = self as NSError

            let errorMessage: String

            if nserror.domain.hasPrefix(ehBaseErrorDomain) || nserror.domain == NSURLErrorDomain {
                errorMessage = nserror.localizedDescription
            } else {
                errorMessage = "SorryUnknownError".localizedUsingGeneralFile()
            }

            return errorMessage

        } else if let eherror = self as? EHErrorType {

            return eherror.localizedDescription
        }

        return nil
    }
}

extension UIView {
    /// Rounds the corners of the view by setting the corner radius to height/2
    func roundCorners() {

        clipsToBounds = true
        layer.cornerRadius = bounds.height / 2
    }
}

class Wrapper<T> {
    let element: T
    init(element: T) {
        self.element = element
    }
}

extension UIViewController {
    func reportScreenViewToGoogleAnalyticsWithName(name: String) {
        
        // TODO: Send report to Firebase analytics
    }
}
