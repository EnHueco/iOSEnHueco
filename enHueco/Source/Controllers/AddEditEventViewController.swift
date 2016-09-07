//
//  AddEditEventViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit


class AddEditEventViewController: UIViewController {
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var embeddedTableViewController: EmbeddedAddEditEventTableViewController!

    /// The ID of the event to edit
    var eventToEditID: String?
    
    /// The event to edit that was fetched using the eventToEditID
    private(set) var fetchedEventToEdit: Event?

    ///Parent schedule view controller
    var scheduleViewController: ScheduleViewController!
    
    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        topBarBackgroundView.backgroundColor = EHInterfaceColor.defaultTopBarsColor

        cancelButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        saveButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor

        if let eventToEditID = eventToEditID {
            titleLabel.text = "EditEvent".localizedUsingGeneralFile()
            embeddedTableViewController.weekDaysCell.hidden = true
            
            EHProgressHUD.showSpinnerInView(view)
            EventsAndSchedulesManager.sharedManager.fetchEvent(id: eventToEditID) { (event, error) in
                EHProgressHUD.dismissSpinnerForView(self.view)
                
                guard error == nil else {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                    self.dismissViewControllerAnimated(true, completion: nil)
                    return
                }
                
                self.fetchedEventToEdit = event
                self.embeddedTableViewController.refreshUIData()
            }
            
        } else {
            titleLabel.text = "AddEvent".localizedUsingGeneralFile()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
        embeddedTableViewController.view.endEditing(true)
    }

    @IBAction func save(sender: UIButton) {

        // If no weekdays selected
        guard embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes.count != 0 else {
            EHNotifications.showNotificationInViewController(self, title: "SelectAtLeastOneDayErrorMessage".localizedUsingGeneralFile(), type: .Warning)
            return
        }

        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!

        var eventsToAdd = [BaseEvent]()

        for index in embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes {
            let components: NSCalendarUnit = [.Year, .Month, .WeekOfMonth, .Weekday, .Hour, .Minute]

            let localStartHourComponents = localCalendar.components(components, fromDate: embeddedTableViewController.startHourDatePicker.date)
            let localEndHourComponents = localCalendar.components(components, fromDate: embeddedTableViewController.endHourDatePicker.date)

            localStartHourComponents.weekday = index + 1
            localEndHourComponents.weekday = index + 1

            let globalStartTimeDateInWeekday = localCalendar.dateFromComponents(localStartHourComponents)!
            let globalEndTimeDateInWeekday = localCalendar.dateFromComponents(localEndHourComponents)!

            let type: EventType = (embeddedTableViewController.freeTimeOrClassSegmentedControl.selectedSegmentIndex == 0 ? .FreeTime : .Class)

            var name = embeddedTableViewController.nameTextField.text

            if name != nil && name! == "" {
                name = nil
            }

            let newEvent = BaseEvent(type: type, name: name, location: embeddedTableViewController.locationTextField.text, startDate: globalStartTimeDateInWeekday, endDate: globalEndTimeDateInWeekday, repeating: true)
            eventsToAdd.append(newEvent)
        }
        
        if let eventToEdit = fetchedEventToEdit {
            
            guard let dummyEvent = eventsToAdd.first else {
                return
            }
            
            var intent = EventUpdateIntent(id: eventToEdit.id)
            intent.type = dummyEvent.type
            intent.name = dummyEvent.name
            intent.location = dummyEvent.location
            intent.startDate = dummyEvent.startDate
            intent.endDate = dummyEvent.endDate
            intent.location = dummyEvent.location
            
            scheduleViewController.editEventWithUndoCapability(eventToEdit, withIntent: intent, completionHandler: { (error) in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        } else {
            
            scheduleViewController.addEventsWithUndoCapability(eventsToAdd) { error in
                
                guard (error as? EventsAndSchedulesManagerError) != EventsAndSchedulesManagerError.EventsOverlap else {
                    
                    let alert = UIAlertController(title: "CouldNotAddEventErrorMessage".localizedUsingGeneralFile(), message: "EventOverlapExplanation".localizedUsingGeneralFile(), preferredStyle: .Alert)
                    
                    alert.addAction(UIAlertAction(title: "OKIwillCheck".localizedUsingGeneralFile(), style: .Cancel, handler: { (action) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Methods

    func deleteEventToEdit() {

        if let eventToEdit = fetchedEventToEdit {
            scheduleViewController.deleteEventsWithUndoCapability([eventToEdit], IDs: [eventToEdit.id], completionHandler: { (error) in
                
                if error != nil {
                    EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let embeddedController = segue.destinationViewController as? EmbeddedAddEditEventTableViewController {
            embeddedTableViewController = embeddedController
        }
    }
}