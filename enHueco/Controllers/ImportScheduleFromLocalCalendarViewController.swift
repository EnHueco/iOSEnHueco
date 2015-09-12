//
//  ImportScheduleFromLocalCalendarViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import EventKit

class ImportScheduleFromLocalCalendarViewController: UIViewController
{
    /*func checkCalendarAuthorizationStatus()
    {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
        
        switch (status)
        {
            case EKAuthorizationStatus.NotDetermined:
                // This happens on first-run
                requestAccessToCalendar()
            case EKAuthorizationStatus.Authorized:
                // Things are in line with being able to show the calendars in the table view
                loadCalendars()
                refreshTableView()
            case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
                // We need to help them give us permission
                needPermissionView.fadeIn()
            default:
                let alert = UIAlertView(title: "Privacy Warning", message: "You have not granted permission for this app to access your Calendar", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
        }
        
        func requestAccessToCalendar()
        {
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
                (accessGranted: Bool, error: NSError!) in
                
                if accessGranted == true {
                    // Ensure that UI refreshes happen back on the main thread!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.loadCalendars()
                        self.refreshTableView()
                    })
                } else {
                    // Ensure that UI refreshes happen back on the main thread!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.needPermissionView.fadeIn()
                    })
                }
            })
        }
    }*/
}
