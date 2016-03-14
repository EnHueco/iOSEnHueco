//
//  EHNotifications.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 3/8/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import TSMessages

enum EHNotificationsNotificationType
{
    case Success, Error, Information, Warning
    
    private func toTSMessageNotificationType() -> TSMessageNotificationType {
        
        switch self
        {
        case Success:
            return .Success
            
        case Error:
            return .Error
            
        case Warning:
            return .Warning
            
        case Information:
            return .Message
            
        }
    }
}

enum EHNotificationsNotificationPosition
{
    case Top, Bottom
    
    private func toTSMessageNotificationPosition() -> TSMessageNotificationPosition {
        
        switch self {
            
        case Top:
            return .Top
            
        case Bottom:
            return .Bottom
        }
    }
}

class EHNotifications: NSObject, TSMessageViewProtocol
{
    private override init() {}
    
    private static var once = dispatch_once_t()
    
    /// Responsible for being the delegate of TSMessages to customize the views
    private static var tsMessagesDelegate = EHNotifications()
        
    /** Shows a notification message in a specific view controller
     
     - parameter viewController: The view controller to show the notification in.
     - parameter title: The title of the notification view
     - parameter subtitle: The message that is displayed underneath the title (optional)
     - parameter image: A custom icon image (optional). If no image is provided the defaults for the type are used.
     - parameter type: The notification type (Message, Warning, Error, Success)
     - parameter duration: The duration of the notification being displayed
     - parameter callback: The block that should be executed, when the user tapped on the message
     - parameter buttonTitle: The title for button (optional)
     - parameter buttonCallback: The block that should be executed, when the user tapped on the button
     - parameter messagePosition: The position of the message on the screen
     - parameter dismissingEnabled: Should the message be dismissed when the user taps/swipes it
     */
    class func showNotificationInViewController(viewController: UIViewController!, title: String, subtitle: String? = nil, image: UIImage? = nil, type: EHNotificationsNotificationType = .Information, duration: NSTimeInterval? = nil, callback: (() -> Void)? = nil, buttonTitle: String? = nil, buttonCallback: (() -> Void)? = nil, atPosition messagePosition: EHNotificationsNotificationPosition = .Top, canBeDismissedByUser dismissingEnabled: Bool = true) {
        
        TSMessage.showNotificationInViewController(viewController, title: title, subtitle: subtitle, image: image, type: type.toTSMessageNotificationType(), duration: duration ?? 0, callback: callback, buttonTitle: buttonTitle, buttonCallback: buttonCallback, atPosition: messagePosition.toTSMessageNotificationPosition(), canBeDismissedByUser: dismissingEnabled)
    }
    
    /** Shows a notification message in a specific view controller
     
     - parameter viewController: The view controller to show the notification in.
     - parameter title: The title of the notification view, **if title is nil the notification is not shown**
     - parameter subtitle: The message that is displayed underneath the title (optional)
     - parameter image: A custom icon image (optional). If no image is provided the defaults for the type are used.
     - parameter type: The notification type (Message, Warning, Error, Success)
     - parameter duration: The duration of the notification being displayed
     - parameter callback: The block that should be executed, when the user tapped on the message
     - parameter buttonTitle: The title for button (optional)
     - parameter buttonCallback: The block that should be executed, when the user tapped on the button
     - parameter messagePosition: The position of the message on the screen
     - parameter dismissingEnabled: Should the message be dismissed when the user taps/swipes it
     */
    class func tryToShowErrorNotificationInViewController(viewController: UIViewController!, withPossibleTitle title: String!, subtitle: String? = nil, image: UIImage? = nil, duration: NSTimeInterval? = nil, callback: (() -> Void)? = nil, buttonTitle: String? = nil, buttonCallback: (() -> Void)? = nil, atPosition messagePosition: EHNotificationsNotificationPosition = .Top, canBeDismissedByUser dismissingEnabled: Bool = true) {
        
        guard title != nil else { return }
        
        TSMessage.showNotificationInViewController(viewController, title: title, subtitle: subtitle, image: image, type: EHNotificationsNotificationType.Error.toTSMessageNotificationType(), duration: duration ?? 0, callback: callback, buttonTitle: buttonTitle, buttonCallback: buttonCallback, atPosition: messagePosition.toTSMessageNotificationPosition(), canBeDismissedByUser: dismissingEnabled)
    }
}
