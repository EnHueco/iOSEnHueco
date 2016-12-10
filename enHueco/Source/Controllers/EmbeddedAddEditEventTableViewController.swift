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
    
    fileprivate let weekdayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"].map { $0.localizedUsingGeneralFile() }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        assert(parent is AddEditEventViewController)

        addEditEventParentViewController = parent as! AddEditEventViewController

        freeTimeOrClassSegmentedControl.tintColor = EHInterfaceColor.mainInterfaceColor
        weekDaysSegmentedControl.tintColor = EHInterfaceColor.mainInterfaceColor

        nameTextField.delegate = self
        locationTextField.delegate = self

        startHourDatePicker.addTarget(self, action: #selector(EmbeddedAddEditEventTableViewController.startHourChanged(_:)), for: .valueChanged)
        endHourDatePicker.addTarget(self, action: #selector(EmbeddedAddEditEventTableViewController.endHourChanged(_:)), for: .valueChanged)

        if addEditEventParentViewController.eventToEditID == nil {
            deleteButton.isHidden = true
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
        deleteButton.isHidden = false
        
        var globalCalendar = Calendar.current
        globalCalendar.timeZone = TimeZone(identifier: "UTC")!
        
        let indexSet = IndexSet(integer: globalCalendar.component(.weekday, from: eventToEdit.startDate as Date) - 1)
        weekDaysSegmentedControl.selectedSegmentIndexes = indexSet as NSIndexSet!
        
        if eventToEdit.type == .FreeTime {
            freeTimeOrClassSegmentedControl.selectedSegmentIndex = 0
        } else {
            freeTimeOrClassSegmentedControl.selectedSegmentIndex = 1
        }
        
        startHourDatePicker.setDate(eventToEdit.startDate as Date, animated: true)
        endHourDatePicker.setDate(eventToEdit.endDate as Date, animated: true)
        updateStartAndEndHourCells()
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if cell == startHourCell || cell == endHourCell {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

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
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if cell == startHourCell || cell == endHourCell {
            cell.selectionStyle = .blue
        } else {
            cell.selectionStyle = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if cell == weekDaysCell && weekDaysCell.isHidden {
            return 0
        } else if cell == startHourDatePickerCell || cell == endHourDatePickerCell {
            if datePickerViewCellToDisplay == cell {
                return datePickerHeight
            } else {
                return 0
            }
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.backgroundColor = UIColor.clear
    }

    // MARK: PickerView Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return 5
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return weekdayNames[row + 2]
    }

    // MARK Buttons

    func startHourChanged(_ sender: UIDatePicker) {

        endHourDatePicker.minimumDate = startHourDatePicker.date
        updateStartAndEndHourCells()
    }

    func endHourChanged(_ sender: UIDatePicker) {

        updateStartAndEndHourCells()
    }

    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        
        let title = "Eliminar " + (freeTimeOrClassSegmentedControl.selectedSegmentIndex == 0 ? "FreeTime".localizedUsingGeneralFile() : "Class".localizedUsingGeneralFile())
        let message = "AreYouSureDeleteEventMessage".localizedUsingGeneralFile()
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
            
        alertController.addAction(UIAlertAction(title: "Si", style: .destructive, handler: { (action) in
            self.addEditEventParentViewController.deleteEventToEdit()
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: Methods

    func updateStartAndEndHourCells() {

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"

        startHourCell.detailTextLabel?.text = formatter.string(from: startHourDatePicker.date)
        endHourCell.detailTextLabel?.text = formatter.string(from: endHourDatePicker.date)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
