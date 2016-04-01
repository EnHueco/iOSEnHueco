//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var importCalendarButton: UIButton!
    
    /**
     Schedule to be displayed. Defaults to AppUser's
     */
    var schedule: Schedule = enHueco.appUser.schedule
    
    ///Reference to the embeded calendar view controller
    var scheduleCalendarViewController: ScheduleCalendarViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        topBarBackgroundView.backgroundColor = EHInterfaceColor.defaultTopBarsColor
        closeButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        importButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        addEventButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        addEventButton.clipsToBounds = true
        addEventButton.layer.cornerRadius = addEventButton.frame.size.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController?.navigationBarHidden = true
       
        if schedule !== enHueco.appUser.schedule
        {
            importCalendarButton.hidden = true
            addEventButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if schedule === enHueco.appUser.schedule
        {
            becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool
    {
        return schedule === enHueco.appUser.schedule
    }
    
    ///Adds the event to their assigned daySchedules, giving the ability to undo and redo the actions.
    func addEventsWithUndoCapability(eventsToAdd: [Event])
    {
        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.addEvents(eventsToAdd) { (success, error) in
            
            EHProgressHUD.dismissSpinnerForView(self.view)

            guard success && error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            self.undoManager?.registerUndoWithTarget(self, selector: #selector(ScheduleViewController.deleteEventsWithUndoCapability(_:)), object: eventsToAdd)
            
            if self.undoManager != nil && !self.undoManager!.undoing
            {
                self.undoManager?.setActionName("AddEvents".localizedUsingGeneralFile())
            }
            
            self.scheduleCalendarViewController.reloadData()
        }
    }
    
    ///Edits the event, giving the ability to undo and redo the actions.
    func editEventWithUndoCapability(eventToEdit: Event, withValuesOfEvent newEvent: Event)
    {
        let oldEvent = eventToEdit.copy() as! Event
        
        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.editEvent(eventToEdit, withValuesOfDummyEvent: newEvent) { success, error in
            
            EHProgressHUD.dismissSpinnerForView(self.view)
            
            guard success && error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            self.undoManager?.prepareWithInvocationTarget(self).editEventWithUndoCapability(eventToEdit, withValuesOfEvent: oldEvent)
            
            if self.undoManager != nil && !self.undoManager!.undoing
            {
                self.undoManager?.setActionName("EditEvent".localizedUsingGeneralFile())
            }
            
            self.scheduleCalendarViewController.reloadData()
        }
    }
    
    ///Deletes the events from their assigned daySchedules, giving the ability to undo and redo the actions.
    func deleteEventsWithUndoCapability(events: [Event])
    {
        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.deleteEvents(events) { (success, error) in
            
            EHProgressHUD.dismissSpinnerForView(self.view)

            guard success && error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            self.undoManager?.registerUndoWithTarget(self, selector: #selector(ScheduleViewController.addEventsWithUndoCapability(_:)), object: events)
            
            if self.undoManager != nil && !self.undoManager!.undoing
            {
                self.undoManager?.setActionName("DeleteEvents".localizedUsingGeneralFile())
            }
            
            self.scheduleCalendarViewController.reloadData()
        }
    }
    
    @IBAction func importScheduleButtonPressed(sender: AnyObject)
    {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("SelectCalendarViewController") as! SelectCalendarViewController
        navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? ScheduleCalendarViewController
        {
            scheduleCalendarViewController = controller
            controller.schedule = schedule
        }
        else if let controller = segue.destinationViewController as? AddEditEventViewController
        {
            controller.scheduleViewController = self
        }
    }
}
