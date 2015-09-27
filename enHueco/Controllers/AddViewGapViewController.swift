//
//  AddGapViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class AddViewGapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gapOrClassSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nameLocationBackgroundView: UIView!
    @IBOutlet weak var weekDaysSegmentedControl: MultiSelectSegmentedControl!
    @IBOutlet weak var startHourDatePicker: UIDatePicker!
    @IBOutlet weak var endHourDatePicker: UIDatePicker!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var eventToEdit: Event?

    
    override func viewDidLoad()
    {

        super.viewDidLoad()
        
        nameTextField.delegate = self
        locationTextField.delegate = self
        
        if let eventToEdit = eventToEdit
        {
            titleLabel.text = "Editar hueco"
            
            nameTextField.text = eventToEdit.name
            locationTextField.text = eventToEdit.location
            
            deleteButton.clipsToBounds = true
            deleteButton.layer.cornerRadius = 5
            deleteButton.hidden = false
            
            let globalCalendar = NSCalendar.currentCalendar()
            globalCalendar.timeZone = NSTimeZone(name: "UTC")!
            
            let indexSet = NSIndexSet(index: system.appUser.schedule.weekDays.indexOf(eventToEdit.daySchedule)!-1)
            weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
            
            if eventToEdit is Gap
            {
                gapOrClassSegmentedControl.selectedSegmentIndex = 0
            }
            else
            {
                gapOrClassSegmentedControl.selectedSegmentIndex = 1
            }
            
            let currentDate = NSDate()
            
            startHourDatePicker.setDate(eventToEdit.startHourInUTCEquivalentOfDate(currentDate), animated: true)
            endHourDatePicker.setDate(eventToEdit.endHourInUTCEquivalentOfDate(currentDate), animated: true)
        }
        else
        {
            titleLabel.text = "Agregar Hueco"

            deleteButton.hidden = true
            deleteButtonHeightConstraint.constant = 0
            
            let indexSet = NSMutableIndexSet()
            indexSet.addIndex(2)
            indexSet.addIndex(4)
            weekDaysSegmentedControl.selectedSegmentIndexes = indexSet
        }
    
        // Set end datepicker min to startdatepicker+1
        endHourDatePicker.minimumDate = startHourDatePicker.date
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        scrollView.flashScrollIndicators()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }

    // returns the # of rows in each component..
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return system.appUser.schedule.weekDays[row+2].weekDayName
    }
    
    @IBAction func startHourChanged(sender: UIDatePicker)
    {
        endHourDatePicker.minimumDate = startHourDatePicker.date
    }
    
    @IBAction func save(sender: UIButton)
    {
        if weekDaysSegmentedControl.selectedSegmentIndexes.count == 0
        {
            TSMessage.showNotificationInViewController(self, title: "Selecciona por lo menos un día", subtitle: "Los huecos y clases tienen que pertenecer a al menos un día", type: TSMessageNotificationType.Warning)
            return
        }
        
        let localCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var eventsToAdd = [Event]()
        var canAddEvents = true
        
        for index in weekDaysSegmentedControl.selectedSegmentIndexes
        {
            let components: NSCalendarUnit = [.Year, .Month, .WeekOfMonth, .Weekday, .Hour, .Minute]
            
            let localStartHourComponents = localCalendar.components(components, fromDate: startHourDatePicker.date)
            let localEndHourComponents = localCalendar.components(components, fromDate: endHourDatePicker.date)
            
            localStartHourComponents.weekday = index+1
            localEndHourComponents.weekday = index+1
            
            let globalStartHourDateInWeekday = localCalendar.dateFromComponents(localStartHourComponents)!
            let globalEndHourDateInWeekday = localCalendar.dateFromComponents(localEndHourComponents)!
            
            let weekdayHourMinute: NSCalendarUnit = [.Weekday, .Hour, .Minute]
            
            let globalStartHourComponentsInWeekday = globalCalendar.components(weekdayHourMinute, fromDate: globalStartHourDateInWeekday)
            let globalEndHourComponentsInWeekday = globalCalendar.components(weekdayHourMinute, fromDate: globalEndHourDateInWeekday)
            
            /*var localWeekDayNumber = localCalendar.component(.Weekday, fromDate: startHourDatePicker.date)
            var dayOffset = Int(localWeekDayNumber-startHour.weekday)
            startHour.weekday = index+1 - dayOffset
            
            localWeekDayNumber = localCalendar.component(.Weekday, fromDate: endHourDatePicker.date)
            dayOffset = Int(localWeekDayNumber-endHour.weekday)
            endHour.weekday = index+1 - dayOffset*/
            
            let daySchedule = system.appUser.schedule.weekDays[index+1]
            
            if gapOrClassSegmentedControl.selectedSegmentIndex == 0 //Gap selected
            {
                var name = nameTextField.text
                
                if name != nil && name! == "" { name = nil }
                
                let newGap = Gap(daySchedule: daySchedule, name: name, startHour: globalStartHourComponentsInWeekday, endHour: globalEndHourComponentsInWeekday, location: locationTextField.text)
                
                if !daySchedule.canAddGap(newGap, excludingEvent: eventToEdit)
                {
                    canAddEvents = false
                }
                else
                {
                    eventsToAdd.append(newGap)
                }
            }
            else //Class selected
            {
                var name: String?
                
                if name != nil && name! == "" { name = nil }
                
                let newClass = Class(daySchedule: daySchedule, name: nameTextField.text, startHour: globalStartHourComponentsInWeekday, endHour: globalEndHourComponentsInWeekday, location: locationTextField.text)
                
                if !daySchedule.canAddClass(newClass, excludingEvent: eventToEdit)
                {
                    canAddEvents = false
                }
                else
                {
                    eventsToAdd.append(newClass)
                }
            }
        }
        
        if canAddEvents
        {
            if let gapToEdit = eventToEdit as? Gap
            {
                gapToEdit.daySchedule.removeGap(gapToEdit)
            }
            else if let classToEdit = eventToEdit as? Class
            {
                classToEdit.daySchedule.removeClass(classToEdit)
            }

            for event in eventsToAdd
            {
                if let newGap = event as? Gap
                {
                    newGap.daySchedule.addGap(newGap)
                }
                else if let newClass = event as? Class
                {
                    newClass.daySchedule.addClass(newClass)
                }
            }
            
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            UIAlertView(title: "Imposible agregar evento", message: (gapOrClassSegmentedControl.selectedSegmentIndex == 0 ? "El hueco":"La clase")+" que estas tratando de agregar se cruza con algún otro evento en tu calendario en alguno de los días que elegiste...", delegate: nil, cancelButtonTitle: "Ok, lo revisaré.").show()
        }
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject)
    {
        UIAlertView(title: "Eliminar "+(gapOrClassSegmentedControl.selectedSegmentIndex == 0 ? "Hueco":"Clase"), message: "¿Estás seguro que quieres eliminar " + (gapOrClassSegmentedControl.selectedSegmentIndex == 0 ? "este hueco":"esta clase")+"?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Si").show()
    }
    
    func deleteEvent()
    {
        if let gapToEdit = eventToEdit as? Gap
        {
            gapToEdit.daySchedule.removeGap(gapToEdit)
        }
        else if let classToEdit = eventToEdit as? Class
        {
            classToEdit.daySchedule.removeClass(classToEdit)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            deleteEvent()
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
