//
//  EHNotifications.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 3/8/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import TSMessages

enum EHNotificationsNotificationType {
    case success, error, information, warning

    fileprivate func toTSMessageNotificationType() -> TSMessageNotificationType {

        switch self {
        case .success:
            return .success

        case .error:
            return .error

        case .warning:
            return .warning

        case .information:
            return .message

        }
    }
}

enum EHNotificationsNotificationPosition {
    case top, bottom

    fileprivate func toTSMessageNotificationPosition() -> TSMessageNotificationPosition {

        switch self {

        case .top:
            return .top

        case .bottom:
            return .bottom
        }
    }
}

class EHNotifications: NSObject, TSMessageViewProtocol {
    fileprivate override init() {
    }

    fileprivate static var once = Int()

    /// Responsible for being the delegate of TSMessages to customize the views
    fileprivate static var tsMessagesDelegate = EHNotifications()

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
    class func showNotification(in viewController: UIViewController!, title: String, subtitle: String? = nil, image: UIImage? = nil, type: EHNotificationsNotificationType = .information, duration: TimeInterval? = nil, callback: (() -> Void)? = nil, buttonTitle: String? = nil, buttonCallback: (() -> Void)? = nil, atPosition messagePosition: EHNotificationsNotificationPosition = .top, canBeDismissedByUser dismissingEnabled: Bool = true) {

        TSMessage.showNotification(in: viewController, title: title, subtitle: subtitle, image: image, type: type.toTSMessageNotificationType(), duration: duration ?? 0, callback: callback, buttonTitle: buttonTitle, buttonCallback: buttonCallback, at: messagePosition.toTSMessageNotificationPosition(), canBeDismissedByUser: dismissingEnabled)
    }
    
    /** Shows an error in a specific view controller
     
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
    class func showError(in viewController: UIViewController!, error: Error?, subtitle: String? = nil, image: UIImage? = nil, duration: TimeInterval? = nil, callback: (() -> Void)? = nil, buttonTitle: String? = nil, buttonCallback: (() -> Void)? = nil, atPosition messagePosition: EHNotificationsNotificationPosition = .top, canBeDismissedByUser dismissingEnabled: Bool = true) {
        
        let title = (error ?? NSError(domain: "", code: 0, userInfo: nil)).localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage()
            
        TSMessage.showNotification(in: viewController, title: title, subtitle: subtitle, image: image, type: EHNotificationsNotificationType.error.toTSMessageNotificationType(), duration: duration ?? 0, callback: callback, buttonTitle: buttonTitle, buttonCallback: buttonCallback, at: messagePosition.toTSMessageNotificationPosition(), canBeDismissedByUser: dismissingEnabled)
    }
}
