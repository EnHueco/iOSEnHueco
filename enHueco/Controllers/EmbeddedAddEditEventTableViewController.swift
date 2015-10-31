//
//  EmbededAddEditEventViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/30/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class EmbeddedAddEditEventTableViewController: StaticDataTableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate
{
    var addEditEventParentViewController: AddEditEventViewController!
    
    @IBOutlet weak var gapOrClassSegmentedControl: UISegmentedControl!
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
    
    let datePickerHeight: CGFloat = 167
    let startHourDatePickerCellIndexPath = NSIndexPath(forRow: 4, inSection: 0)
    let endHourDatePickerCellIndexPath = NSIndexPath(forRow: 6, inSection: 0)
    
    var datePickerViewIndexPathToDisplay: NSIndexPath?
    
    override func didMoveToParentViewController(parent: UIViewController?)
    {
        super.didMoveToParentViewController(parent)
        
        assert(parent is AddEditEventViewController)
        
        insertTableViewRowAnimation = .Middle
        deleteTableViewRowAnimation = .Middle
        
        addEditEventParentViewController = parentViewController as! AddEditEventViewController
        
        gapOrClassSegmentedControl.tintColor = EHIntefaceColor.mainInterfaceColor
        weekDaysSegmentedControl.tintColor = EHIntefaceColor.mainInterfaceColor
        
        nameTextField.delegate = self
        locationTextField.delegate = self
        
        startHourDatePicker.addTarget(self, action: Selector("startHourChanged:"), forControlEvents: .ValueChanged)
        endHourDatePicker.addTarget(self, action: Selector("endHourChanged:"), forControlEvents: .ValueChanged)
        
        if let eventToEdit = addEditEventParentViewController.eventToEdit
        {
            nameTextField.text = eventToEdit.name
            locationTextField.text = eventToEdit.location
            
            deleteButton.clipsToBounds = true
            deleteButton.layer.cornerRadius = 5
            deleteButton.hidden = false
            
            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            let indexSet = NSIndexSet(index: system.appUser.schedule.weekDays.indexOf(eventToEdit.daySchedule)!-1)
            weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
            
            if eventToEdit.type == .Gap
            {
                gapOrClassSegmentedControl.selectedSegmentIndex = 0
            }
            else
            {
                gapOrClassSegmentedControl.selectedSegmentIndex = 1
            }
            
            let currentDate = NSDate()
            
            startHourDatePicker.setDate(eventToEdit.startHourInDate(currentDate), animated: true)
            endHourDatePicker.setDate(eventToEdit.endHourInDate(currentDate), animated: true)
        }
        else
        {
            deleteButton.hidden = true
            deleteButtonHeightConstraint.constant = 0
            
            let indexSet = NSMutableIndexSet()
            indexSet.addIndex(2)
            indexSet.addIndex(4)
            weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
        }
        
        // Set end datepicker min to startdatepicker+1
        endHourDatePicker.minimumDate = startHourDatePicker.date
        
        updateStartAndEndHourCells()
        
//        cell(startHourDatePickerCell, setHidden: true)
//        cell(endHourDatePickerCell, setHidden: true)
//        reloadDataAnimated(true)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        if indexPath == tableView.indexPathForCell(startHourCell) || indexPath == tableView.indexPathForCell(endHourCell)
        {
            return indexPath
        }
        else
        {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath == tableView.indexPathForCell(startHourCell) || indexPath == tableView.indexPathForCell(endHourCell)
        {
            let newIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: 0)
            
            if datePickerViewIndexPathToDisplay != newIndexPath
            {
                datePickerViewIndexPathToDisplay = newIndexPath
            }
            else
            {
                datePickerViewIndexPathToDisplay = nil
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
//            cell(startHourDatePickerCell, setHidden: !cellIsHidden(startHourDatePickerCell))
//            cell(endHourDatePickerCell, setHidden: true)
        }
//        else if indexPath == tableView.indexPathForCell(endHourCell)
//        {
//            cell(endHourDatePickerCell, setHidden: !cellIsHidden(endHourDatePickerCell))
//            cell(startHourDatePickerCell, setHidden: true)
//        }
        
        reloadDataAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if indexPath == NSIndexPath(forRow: startHourDatePickerCellIndexPath.row-1, inSection: startHourDatePickerCellIndexPath.section) || indexPath == NSIndexPath(forRow: endHourDatePickerCellIndexPath.row-1, inSection: endHourDatePickerCellIndexPath.section)
        {
            cell.selectionStyle = .Blue
        }
        else
        {
            cell.selectionStyle = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath == startHourDatePickerCellIndexPath || indexPath == endHourDatePickerCellIndexPath
        {
            if datePickerViewIndexPathToDisplay != nil && datePickerViewIndexPathToDisplay! == indexPath
            {
                return datePickerHeight
            }
            else
            {
                return 0
            }
        }
        else
        {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: PickerView Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return system.appUser.schedule.weekDays[row+2].weekDayName
    }
    
    // MARK Buttons
    
    func startHourChanged(sender: UIDatePicker)
    {
        endHourDatePicker.minimumDate = startHourDatePicker.date
        updateStartAndEndHourCells()
    }
    
    func endHourChanged(sender: UIDatePicker)
    {
        updateStartAndEndHourCells()
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject)
    {
        UIAlertView(title: "Eliminar "+(gapOrClassSegmentedControl.selectedSegmentIndex == 0 ? "Hueco":"Clase"), message: "¿Estás seguro que quieres eliminar " + (gapOrClassSegmentedControl.selectedSegmentIndex == 0 ? "este hueco":"esta clase")+"?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Si").show()
    }
    
    // MARK: Methods
    
    func changeCurrentlyDisplayedDatePickerViewToPickerViewWithIndexPath(indexPath: NSIndexPath?)
    {
        tableView.beginUpdates()

        datePickerViewIndexPathToDisplay = indexPath
        
        if indexPath == nil
        {
            tableView.deleteRowsAtIndexPaths([startHourDatePickerCellIndexPath, endHourDatePickerCellIndexPath], withRowAnimation: .Fade)
        }
        else
        {
            
        }
        
        tableView.endUpdates()
    }
    
    func updateStartAndEndHourCells()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        startHourCell.detailTextLabel?.text = formatter.stringFromDate(startHourDatePicker.date)
        endHourCell.detailTextLabel?.text = formatter.stringFromDate(endHourDatePicker.date)
    }
    
    func deleteEventToEdit()
    {
        addEditEventParentViewController.deleteEventToEdit()
    }
    
    // MARK: Other Delegates
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            deleteEventToEdit()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
