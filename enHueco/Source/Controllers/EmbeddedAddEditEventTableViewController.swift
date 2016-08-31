//
//  EmbededAddEditEventViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/30/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import MultiSelectSegmentedControl

class EmbeddedAddEditEventTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate {
    
    var addEditEventParentViewController: AddEditEventViewController!

    @IBOutlet weak var freeTimeOrClassSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nameLocationBackgroundView: UIView!
    @IBOutlet weak var weekDaysSegmentedControl: MultiSelectSegmentedControl!
    @IBOutlet weak var startHourDatePicker: UIDatePicker!
    @IBOutlet weak var endHourDatePicker: UIDatePicker!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var startHourCell: UITableViewCell!
    @IBOutlet weak var endHourCell: UITableViewCell!
    @IBOutlet weak var startHourDatePickerCell: UITableViewCell!
    @IBOutlet weak var endHourDatePickerCell: UITableViewCell!
    @IBOutlet weak var weekDaysCell: UITableViewCell!

    let datePickerHeight: CGFloat = 167

    var datePickerViewCellToDisplay: UITableViewCell?

    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)

        assert(parent is AddEditEventViewController)

        addEditEventParentViewController = parentViewController as! AddEditEventViewController

        freeTimeOrClassSegmentedControl.tintColor = EHInterfaceColor.mainInterfaceColor
        weekDaysSegmentedControl.tintColor = EHInterfaceColor.mainInterfaceColor

        nameTextField.delegate = self
        locationTextField.delegate = self

        startHourDatePicker.addTarget(self, action: #selector(EmbeddedAddEditEventTableViewController.startHourChanged(_:)), forControlEvents: .ValueChanged)
        endHourDatePicker.addTarget(self, action: #selector(EmbeddedAddEditEventTableViewController.endHourChanged(_:)), forControlEvents: .ValueChanged)

        if eventToEditID == nil {
            deleteButton.hidden = true
            deleteButtonHeightConstraint.constant = 0
            
            let indexSet = NSMutableIndexSet()
            weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
        } 

        // Set end datepicker min to startdatepicker+1
        endHourDatePicker.minimumDate = startHourDatePicker.date

        updateStartAndEndHourCells()
    }
    
    func refreshUIData() {
        
        guard let eventToEdit = addEditEventParentViewController.fetchedEventToEdit else {
            return
        }
        
        nameTextField.text = eventToEdit.name
        locationTextField.text = eventToEdit.location
        
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 5
        deleteButton.hidden = false
        
        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let indexSet = NSIndexSet(index: globalCalendar.component(.Weekday, fromDate: eventToEdit.startDate) - 1)
        weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
        
        if eventToEdit.type == .FreeTime {
            freeTimeOrClassSegmentedControl.selectedSegmentIndex = 0
        } else {
            freeTimeOrClassSegmentedControl.selectedSegmentIndex = 1
        }
        
        let currentDate = NSDate()
        
        startHourDatePicker.setDate(eventToEdit.startDateInNearestPossibleDateToDate(currentDate), animated: true)
        endHourDatePicker.setDate(eventToEdit.endDateInNearestPossibleDateToDate(currentDate), animated: true)
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if cell == startHourCell || cell == endHourCell {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if (cell == startHourCell && datePickerViewCellToDisplay != startHourDatePickerCell)
                || (cell == endHourCell && datePickerViewCellToDisplay != endHourDatePickerCell) {
            if cell == startHourCell {
                datePickerViewCellToDisplay = startHourDatePickerCell
            } else if cell == endHourCell {
                datePickerViewCellToDisplay = endHourDatePickerCell
            }
        } else {
            datePickerViewCellToDisplay = nil
        }

        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if cell == startHourCell || cell == endHourCell {
            cell.selectionStyle = .Blue
        } else {
            cell.selectionStyle = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if cell == weekDaysCell && weekDaysCell.hidden {
            return 0
        } else if cell == startHourDatePickerCell || cell == endHourDatePickerCell {
            if datePickerViewCellToDisplay == cell {
                return datePickerHeight
            } else {
                return 0
            }
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.backgroundColor = UIColor.clearColor()
    }

    // MARK: PickerView Delegate

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return 5
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return enHueco.appUser.schedule.weekDays[row + 2].weekDayName
    }

    // MARK Buttons

    func startHourChanged(sender: UIDatePicker) {

        endHourDatePicker.minimumDate = startHourDatePicker.date
        updateStartAndEndHourCells()
    }

    func endHourChanged(sender: UIDatePicker) {

        updateStartAndEndHourCells()
    }

    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        let title = "Eliminar " + (freeTimeOrClassSegmentedControl.selectedSegmentIndex == 0 ? "FreeTime".localizedUsingGeneralFile() : "Class".localizedUsingGeneralFile())
        let message = "AreYouSureDeleteEventMessage".localizedUsingGeneralFile()
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
            
        alertController.addAction(UIAlertAction(title: "Si", style: .Cancel, handler: { (action) in
            addEditEventParentViewController.deleteEventToEdit()
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: Methods

    func updateStartAndEndHourCells() {

        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"

        startHourCell.detailTextLabel?.text = formatter.stringFromDate(startHourDatePicker.date)
        endHourCell.detailTextLabel?.text = formatter.stringFromDate(endHourDatePicker.date)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
