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

    fileprivate let appUserID = AccountManager.shared.userID
    
    /// ID of the user who's schedule will be displayed. Defaults to the AppUser's
    var userID = AccountManager.shared.userID
    
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true

        let canEdit = userID != nil && userID == appUserID
        importCalendarButton.isHidden = !canEdit
        addEventButton.isHidden = !canEdit
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userID == appUserID {
            becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        resignFirstResponder()
    }

    override var canBecomeFirstResponder : Bool {

        return userID == appUserID
    }

    ///Adds the event to their assigned daySchedules, giving the ability to undo and redo the actions.
    func addEventsWithUndoCapability(_ eventsToAdd: [BaseEvent], completionHandler: BasicCompletionHandler?) {

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.shared.addEventsWithDataFrom(eventsToAdd) { (addedEventIDs, error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error)

            guard let addedEventIDs = addedEventIDs, error == nil else {
                EHNotifications.showError(in: self, error: error)
                return
            }

            (self.undoManager?.prepare(withInvocationTarget: self) as? ScheduleViewController)?.deleteEventsWithUndoCapability(eventsToAdd, IDs: addedEventIDs, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.isUndoing {
                self.undoManager?.setActionName("AddEvents".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    ///Edits the event, giving the ability to undo and redo the actions.
    func editEventWithUndoCapability(_ event: Event, withIntent intent: EventUpdateIntent, completionHandler: BasicCompletionHandler?) {

        let oldEventIntent = EventUpdateIntent(valuesOfEvent: event)

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.shared.editEvent(event.id, withIntent: intent) { (error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error)

            guard error == nil else {
                EHNotifications.showError(in: self, error: error)
                return
            }

            (self.undoManager?.prepare(withInvocationTarget: self) as? ScheduleViewController)?.editEventWithUndoCapability(event, withIntent: oldEventIntent, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.isUndoing {
                self.undoManager?.setActionName("EditEvent".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    ///Deletes the events from their assigned daySchedules, giving the ability to undo and redo the actions.
    func deleteEventsWithUndoCapability(_ events: [BaseEvent], IDs: [String], completionHandler: BasicCompletionHandler?) {

        EHProgressHUD.showSpinnerInView(view)
        EventsAndSchedulesManager.shared.deleteEvents(IDs) { (error) in
            EHProgressHUD.dismissSpinnerForView(self.view)

            completionHandler?(error)

            guard error == nil else {
                EHNotifications.showError(in: self, error: error)
                return
            }

            (self.undoManager?.prepare(withInvocationTarget: self) as? ScheduleViewController)?.addEventsWithUndoCapability(events, completionHandler: nil)

            if self.undoManager != nil && !self.undoManager!.isUndoing {
                self.undoManager?.setActionName("DeleteEvents".localizedUsingGeneralFile())
            }

            self.scheduleCalendarViewController.reloadData()
        }
    }

    @IBAction func importScheduleButtonPressed(_ sender: AnyObject) {

        let controller = storyboard!.instantiateViewController(withIdentifier: "SelectCalendarViewController") as! SelectCalendarViewController
        navigationController!.pushViewController(controller, animated: true)
    }

    @IBAction func cancel(_ sender: AnyObject) {

        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? ScheduleCalendarViewController {
            scheduleCalendarViewController = controller
            controller.userID = userID
        } else if let controller = segue.destination as? AddEditEventViewController {
            controller.scheduleViewController = self
        }
    }
}
