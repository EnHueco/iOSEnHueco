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
    var schedule: Schedule = system.appUser.schedule
    
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
       
        if schedule !== system.appUser.schedule
        {
            importCalendarButton.hidden = true
            addEventButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if schedule === system.appUser.schedule
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
        return schedule === system.appUser.schedule
    }
    
    ///Adds the event to their assigned daySchedules, giving the ability to undo and redo the actions.
    func addEventsWithUndoCapability(eventsToAdd: [Event])
    {
        for event in eventsToAdd
        {
            event.daySchedule.addEvent(event)
            SynchronizationManager.sharedManager().reportNewEvent(event)
        }
        
        undoManager?.registerUndoWithTarget(self, selector: Selector("deleteEventsWithUndoCapability:"), object: eventsToAdd)
        
        if undoManager != nil && !undoManager!.undoing
        {
            undoManager?.setActionName("Agregar Eventos")
        }
        
        scheduleCalendarViewController.reloadData()
    }
    
    ///Edits the event, giving the ability to undo and redo the actions.
    func editEventWithUndoCapability(eventToEdit: Event, withValuesOfEvent newEvent: Event)
    {
        let oldEvent = eventToEdit.copy() as! Event
        
        eventToEdit.replaceValuesWithThoseOfTheEvent(newEvent)
        SynchronizationManager.sharedManager().reportEventEdited(eventToEdit)
        
        undoManager?.prepareWithInvocationTarget(self).editEventWithUndoCapability(eventToEdit, withValuesOfEvent: oldEvent)
        
        if undoManager != nil && !undoManager!.undoing
        {
            undoManager?.setActionName("Editar Evento")
        }
        
        scheduleCalendarViewController.reloadData()
    }
    
    ///Deletes the events from their assigned daySchedules, giving the ability to undo and redo the actions.
    func deleteEventsWithUndoCapability(events: [Event])
    {
        for event in events
        {
            event.daySchedule.removeEvent(event)
            SynchronizationManager.sharedManager().reportEventDeleted(event)
        }
        
        undoManager?.registerUndoWithTarget(self, selector: Selector("addEventsWithUndoCapability:"), object: events)
        
        if undoManager != nil && !undoManager!.undoing
        {
            undoManager?.setActionName("Borrar Eventos")
        }
        
        scheduleCalendarViewController.reloadData()
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
