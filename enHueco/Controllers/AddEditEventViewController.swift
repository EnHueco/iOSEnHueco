//
//  AddEditEventViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class AddEditEventViewController: UIViewController
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var embeddedTableViewController: EmbeddedAddEditEventTableViewController!
    
    var eventToEdit: Event?
    
    ///Parent schedule view controller
    var scheduleViewController: ScheduleViewController!

    // MARK: View Controller
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        topBarBackgroundView.backgroundColor = EHInterfaceColor.defaultTopBarsColor
        
        cancelButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        saveButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        
        if eventToEdit != nil
        {
            titleLabel.text = "Editar hueco"
            embeddedTableViewController.weekDaysCell.hidden = true
        }
        else
        {
            titleLabel.text = "Agregar Hueco"
        }
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
        embeddedTableViewController.view.endEditing(true)
    }
    
    @IBAction func save(sender: UIButton)
    {
        // If no weekdays selected
        if embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes.count == 0
        {
            TSMessage.showNotificationInViewController(self, title: "Selecciona por lo menos un día", subtitle: "Los huecos y clases tienen que pertenecer a al menos un día", type: TSMessageNotificationType.Warning)
            return
        }
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var canAddEvents = true
        
        var eventsToAdd = [Event]()
        
        for index in embeddedTableViewController.weekDaysSegmentedControl.selectedSegmentIndexes
        {
            let components: NSCalendarUnit = [.Year, .Month, .WeekOfMonth, .Weekday, .Hour, .Minute]
            
            let localStartHourComponents = localCalendar.components(components, fromDate: embeddedTableViewController.startHourDatePicker.date)
            let localEndHourComponents = localCalendar.components(components, fromDate: embeddedTableViewController.endHourDatePicker.date)
            
            localStartHourComponents.weekday = index+1
            localEndHourComponents.weekday = index+1
            
            let globalStartHourDateInWeekday = localCalendar.dateFromComponents(localStartHourComponents)!
            let globalEndHourDateInWeekday = localCalendar.dateFromComponents(localEndHourComponents)!
            
            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
            
            let globalStartHourComponentsInWeekday = globalCalendar.components(weekdayHourMinute, fromDate: globalStartHourDateInWeekday)
            let globalEndHourComponentsInWeekday = globalCalendar.components(weekdayHourMinute, fromDate: globalEndHourDateInWeekday)
            
            let daySchedule = system.appUser.schedule.weekDays[index+1]
            
            let type: EventType = (embeddedTableViewController.freeTimeOrClassSegmentedControl.selectedSegmentIndex == 0 ? .FreeTime : .Class)
                
            var name = embeddedTableViewController.nameTextField.text
                
            if name != nil && name! == "" { name = nil }
                
            let newEvent = Event(type: type, name: name, startHour: globalStartHourComponentsInWeekday, endHour: globalEndHourComponentsInWeekday, location: embeddedTableViewController.locationTextField.text)
                
            if !daySchedule.canAddEvent(newEvent, excludingEvent: eventToEdit)
            {
                canAddEvents = false
            }
            else
            {
                newEvent.daySchedule = daySchedule
                eventsToAdd.append(newEvent)
            }
        }
        
        if let eventToEdit = eventToEdit where canAddEvents
        {
            scheduleViewController.editEventWithUndoCapability(eventToEdit, withValuesOfEvent: eventsToAdd.first!)
            dismissViewControllerAnimated(true, completion: nil)
        }
        else if canAddEvents
        {
            scheduleViewController.addEventsWithUndoCapability(eventsToAdd)
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            UIAlertView(title: "Imposible agregar evento", message: (embeddedTableViewController.freeTimeOrClassSegmentedControl.selectedSegmentIndex == 0 ? "El hueco" : "La clase") + " que estas tratando de agregar se cruza con algún otro evento en tu calendario en alguno de los días que elegiste...", delegate: nil, cancelButtonTitle: "Ok, lo revisaré.").show()
        }
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Methods
    
    func deleteEventToEdit()
    {
        if let eventToEdit = eventToEdit
        {
            scheduleViewController.deleteEventsWithUndoCapability([eventToEdit])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let embeddedController = segue.destinationViewController as? EmbeddedAddEditEventTableViewController
        {
            embeddedTableViewController = embeddedController
        }
    }
}
