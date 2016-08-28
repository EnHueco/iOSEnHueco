//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var importCalendarButton: UIButton!

    private let appUserID = AccountManager.sharedManager.userID
    
    /// ID of the user who's schedule will be displayed. Defaults to the AppUser's
    var userID = AccountManager.sharedManager.userID
    
    ///Reference to the embeded calendar view controller
    var scheduleCalendarViewController: ScheduleCalendarViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        topBarBackgroundView.backgroundColor = EHInterfaceColor.defaultTopBarsColor
        closeButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        importButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
        addEventButton.titleLabel?.textColor = EHInterfaceColor.defaultEmbededTopBarButtonsColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        addEventButton.clipsToBounds = true
        addEventButton.layer.cornerRadius = addEventButton.frame.size.height / 2
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = true

        if userID != nil && userID == appUserID {
            importCalendarButton.hidden = true
            addEventButton.hidden = true
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if userID == appUserID {
            becomeFirstResponder()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignFirstResponder()
    }

    override func canBecomeFirstResponder() -> Bool {

        return userID == appUserID
    }

    ///Adds the event to their assigned daySchedules, giving the ability to undo and redo the actions.
    func addEventsWithUndoCapability(eventsToAdd: [BaseEvent], completionHandler: BasicCompletionHandler?) {

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.addEventsWithDataFrom(eventsToAdd) { (addedEventIDs, error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error: error)

            guard let addedEventIDs = addedEventIDs where error == nil else {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            (self.undoManager?.prepareWithInvocationTarget(self) as? ScheduleViewController)?.deleteEventsWithUndoCapability(eventsToAdd, IDs: addedEventIDs, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.undoing {
                self.undoManager?.setActionName("AddEvents".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    ///Edits the event, giving the ability to undo and redo the actions.
    func editEventWithUndoCapability(event: Event, withIntent intent: EventUpdateIntent, completionHandler: BasicCompletionHandler?) {

        // TODO: Add info to the old intent in order to allow for undo
        let oldEventIntent = EventUpdateIntent(valuesOfEvent: event)

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.editEvent(eventID: event.id, withIntent: intent) { (error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error: error)

            guard error == nil else {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            (self.undoManager?.prepareWithInvocationTarget(self) as? ScheduleViewController)?.editEventWithUndoCapability(event, withIntent: oldEventIntent, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.undoing {
                self.undoManager?.setActionName("EditEvent".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    ///Deletes the events from their assigned daySchedules, giving the ability to undo and redo the actions.
    func deleteEventsWithUndoCapability(events: [BaseEvent], IDs: [String], completionHandler: BasicCompletionHandler?) {

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.sharedManager.deleteEvents(IDs) { (error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error: error)

            guard error == nil else {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }

            (self.undoManager?.prepareWithInvocationTarget(self) as? ScheduleViewController)?.addEventsWithUndoCapability(events, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.undoing {
                self.undoManager?.setActionName("DeleteEvents".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    @IBAction func importScheduleButtonPressed(sender: AnyObject) {

        let controller = storyboard!.instantiateViewControllerWithIdentifier("SelectCalendarViewController") as! SelectCalendarViewController
        navigationController!.pushViewController(controller, animated: true)
    }

    @IBAction func cancel(sender: AnyObject) {

        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let controller = segue.destinationViewController as? ScheduleCalendarViewController {
            scheduleCalendarViewController = controller
            controller.userID = userID
        } else if let controller = segue.destinationViewController as? AddEditEventViewController {
            controller.scheduleViewController = self
        }
    }
}
