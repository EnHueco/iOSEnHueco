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
    fileprivate(set) var fetchedEventToEdit: Event?

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
            embeddedTableViewController.weekDaysCell.isHidden = true
            
            EHProgressHUD.showSpinnerInView(view)
            EventsAndSchedulesManager.shared.fetchEvent(eventToEditID) { (event, error) in
                EHProgressHUD.dismissSpinnerForView(self.view)
                
                guard error == nil else {
                    EHNotifications.showError(in: self, error: error)
                    self.dismiss(animated: true, completion: nil)
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
        embeddedTableViewController.view.endEditing(true)
    }

    @IBAction func save(_ sender: UIButton) {

        // If no weekdays selected
        guard embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes.count != 0 else {
            EHNotifications.showNotification(in: self, title: "SelectAtLeastOneDayErrorMessage".localizedUsingGeneralFile(), type: .warning)
            return
        }

        let localCalendar = Calendar(identifier: Calendar.Identifier.gregorian)

        var globalCalendar = Calendar.current
        globalCalendar.timeZone = TimeZone(identifier: "UTC")!

        var eventsToAdd = [BaseEvent]()

        for index in embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes {
            let components: Set<Calendar.Component> = [.year, .month, .weekOfMonth, .weekday, .hour, .minute]

            var localStartHourComponents = localCalendar.dateComponents(components, from: embeddedTableViewController.startHourDatePicker.date)
            var localEndHourComponents = localCalendar.dateComponents(components, from: embeddedTableViewController.endHourDatePicker.date)

            localStartHourComponents.weekday = index + 1
            localEndHourComponents.weekday = index + 1

            let globalStartTimeDateInWeekday = localCalendar.date(from: localStartHourComponents)!
            let globalEndTimeDateInWeekday = localCalendar.date(from: localEndHourComponents)!

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
                self.dismiss(animated: true, completion: nil)
            })
            
        } else {
            
            scheduleViewController.addEventsWithUndoCapability(eventsToAdd) { error in
                
                guard (error as? EventsAndSchedulesManagerError) != EventsAndSchedulesManagerError.eventsOverlap else {
                    
                    let alert = UIAlertController(title: "CouldNotAddEventErrorMessage".localizedUsingGeneralFile(), message: "EventOverlapExplanation".localizedUsingGeneralFile(), preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OKIwillCheck".localizedUsingGeneralFile(), style: .cancel, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func cancel(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)
    }

    // MARK: Methods

    func deleteEventToEdit() {

        if let eventToEdit = fetchedEventToEdit {
            scheduleViewController.deleteEventsWithUndoCapability([eventToEdit], IDs: [eventToEdit.id], completionHandler: { (error) in
                
                if error != nil {
                    EHNotifications.showError(in: self, error: error)
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let embeddedController = segue.destination as? EmbeddedAddEditEventTableViewController {
            embeddedTableViewController = embeddedController
        }
    }
}
