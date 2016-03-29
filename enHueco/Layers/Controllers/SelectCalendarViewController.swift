//
//  SelectCalendarViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class SelectCalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate
{
    let eventStore = EKEventStore()
    var selectedCalendar: EKCalendar!
    
    @IBOutlet weak var calendarsTableView: UITableView!
    
    var calendars: [EKCalendar]?
    
    var importScheduleQuestionAlertView: UIAlertView?
    var generateFreeTimePeriodsQuestionAlertView: UIAlertView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        calendarsTableView.dataSource = self
        calendarsTableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController!.navigationBarHidden = false
        
        checkCalendarAuthorizationStatus()
    }
    
    func checkCalendarAuthorizationStatus()
    {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        if status == EKAuthorizationStatus.NotDetermined
        {
            //First Time
            requestAccessToCalendar()
        }
        else if status == EKAuthorizationStatus.Authorized
        {
            loadCalendars()
            calendarsTableView.reloadData()
        }
        else if status == EKAuthorizationStatus.Restricted || status == EKAuthorizationStatus.Denied
        {
            
        }
        else
        {
            UIAlertView(title: "Advertencia", message: "No nos has dado permiso para acceder a tus calendarios. Para arreglarlo debes ingresar a tus ajustes de privacidad en el dispositivo", delegate: nil, cancelButtonTitle: "OK, lo siento").show()
        }
    }
    
    func requestAccessToCalendar()
    {
        eventStore.requestAccessToEntityType(.Event) { (accessGranted, error) -> Void in
            
            if accessGranted
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.loadCalendars()
                    self.calendarsTableView.reloadData()
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    UIAlertView(title: "Advertencia", message: "No nos has dado permiso para acceder a tus calendarios. Para arreglarlo debes ingresar a tus ajustes de privacidad en el dispositivo", delegate: nil, cancelButtonTitle: "OK, lo siento").show()
                }
            }
        }
    }
    
    func loadCalendars()
    {
        calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        calendarsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return calendars != nil ? calendars!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CalendarSelectionCell")!
        
        let calendarName = calendars![indexPath.row].title
        cell.textLabel?.text = calendarName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedCalendar = calendars![indexPath.row]
        
        importScheduleQuestionAlertView = UIAlertView(title: "Importar horario", message: "¿Estás seguro que deseas importar tu horario del calendario \"\(selectedCalendar.title)\"?", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Importar")
        importScheduleQuestionAlertView!.show()
        
        /*let controller = storyboard!.instantiateViewControllerWithIdentifier("ImportScheduleFromLocalCalendarViewController") as! ImportScheduleFromLocalCalendarViewController
        controller.calendar = calendar
        
        navigationController!.pushViewController(controller, animated: true)*/
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if alertView === importScheduleQuestionAlertView && buttonIndex == 1
        {
            generateFreeTimePeriodsQuestionAlertView = UIAlertView(title: "Generar huecos", message: "¿Deseas que generemos los huecos que detectemos entre clases por ti? \n Recuerda que a menos de que agregues huecos a tu tiempo libre tus amigos no verán que estás en hueco.", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "No, Gracias", "Si")
            generateFreeTimePeriodsQuestionAlertView!.show()
        }
        else
        {
            if ScheduleManager.sharedManager.importScheduleFromCalendar(selectedCalendar, generateFreeTimePeriodsBetweenClasses: buttonIndex == 1)
            {
                navigationController!.popViewControllerAnimated(true)
            }
            else
            {
                UIAlertView(title: "Error", message: "Lo sentimos, hubo un error importando el calendario", delegate: nil, cancelButtonTitle: "Que raro").show()
            }
        }
    }
}
